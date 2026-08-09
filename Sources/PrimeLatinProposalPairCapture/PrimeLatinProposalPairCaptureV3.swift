import Foundation

public struct PrimeLatinProposalPairLocatorV3: Equatable, Sendable {
    public let sha256: String
    public let relativePath: String

    public init(sha256: String) throws {
        guard PrimeLatinProposalPairContractV3.isSHA256(sha256) else {
            throw PrimeLatinProposalPairCaptureError.invalidLocator(sha256)
        }
        self.sha256 = sha256
        relativePath = PrimeLatinProposalPairContractV3.publicationRoot
            + "/pairs/\(sha256).json"
    }
}

public struct PrimeLatinProposalPairAuthorityBoundaryV3:
    Equatable,
    Sendable
{
    public let disposition: String
    public let canonicalReceiptRedecodeComplete: Bool
    public let receiptContentAddressBindingVerified: Bool
    public let childContentAddressBindingsVerified: Bool
    public let stableRootBoundCaptureComplete: Bool
    public let pairChildDocumentBytesAvailable: Bool
    public let embeddedHashChainRecomputationComplete: Bool
    public let llmPairReceiptObserved: Bool
    public let referencedInputSnapshotAvailable: Bool
    public let referencedArtifactBytesAvailable: Bool
    public let liveProducerWorkspaceRevalidationComplete: Bool
    public let llmGitStateIndependentlyObserved: Bool
    public let independentReplayComplete: Bool
    public let runtimeDecoderImplementationAvailable: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let primeProposalPacketProduced: Bool
    public let primeTrialAuthorizationProduced: Bool
    public let primeDecisionReceiptProduced: Bool
    public let candidateSelectionAuthorized: Bool
    public let trialExecutionAuthorized: Bool
    public let furtherTrainingAuthorized: Bool
    public let promotionAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let primeDurableReceiptPublished: Bool

    fileprivate init() {
        disposition =
            "abstain_requires_original_bound_input_bytes_and_live_provenance"
        canonicalReceiptRedecodeComplete = true
        receiptContentAddressBindingVerified = true
        childContentAddressBindingsVerified = true
        stableRootBoundCaptureComplete = true
        pairChildDocumentBytesAvailable = true
        embeddedHashChainRecomputationComplete = true
        llmPairReceiptObserved = true
        referencedInputSnapshotAvailable = false
        referencedArtifactBytesAvailable = false
        liveProducerWorkspaceRevalidationComplete = false
        llmGitStateIndependentlyObserved = false
        independentReplayComplete = false
        runtimeDecoderImplementationAvailable = false
        runtimeDependencyClosureEstablished = false
        runtimeInitializationEstablished = false
        primeProposalPacketProduced = false
        primeTrialAuthorizationProduced = false
        primeDecisionReceiptProduced = false
        candidateSelectionAuthorized = false
        trialExecutionAuthorized = false
        furtherTrainingAuthorized = false
        promotionAuthorized = false
        productUseAuthorized = false
        publicationAuthorized = false
        primeDurableReceiptPublished = false
    }
}

public struct PrimeLatinProposalPairObservationV3: Equatable, Sendable {
    public let schema: String
    public let outcome: String
    public let verificationScope: String
    public let pairReceiptSHA256: String
    public let pairReceiptByteCount: UInt64
    public let llmSource: PrimeLatinProposalInputsV3SourceObservation
    public let candidateCatalogSHA256: String
    public let candidateCatalogByteCount: UInt64
    public let experimentManifestSHA256: String
    public let experimentManifestByteCount: UInt64
    public let candidateDeclarationSetSHA256: String
    public let candidateDeclarationSetByteCount: UInt64
    public let tokenizerBundleSHA256: String
    public let tokenizerBundleByteCount: UInt64
    public let candidateIDs: [String]
    public let candidateIdentitySHA256s: [String]
    public let declarationBundleSHA256s: [String]
    public let outputNamespace: String
    public let authority: PrimeLatinProposalPairAuthorityBoundaryV3

    fileprivate init(
        pairReceiptSHA256: String,
        pairReceiptByteCount: UInt64,
        experimentManifestSHA256: String,
        experimentManifestByteCount: UInt64,
        inputs: PrimeLatinProposalInputsV3Observation
    ) {
        schema = "ergentics_prime_latin_proposal_pair_capture_v3_observation"
        outcome = "abstain"
        verificationScope =
            "descriptor_safe_content_addressed_v3_pair_capture_and_embedded_hash_chain_only_non_authorizing"
        self.pairReceiptSHA256 = pairReceiptSHA256
        self.pairReceiptByteCount = pairReceiptByteCount
        llmSource = inputs.llmSource
        candidateCatalogSHA256 = inputs.candidateCatalogSHA256
        candidateCatalogByteCount = inputs.candidateCatalogByteCount
        self.experimentManifestSHA256 = experimentManifestSHA256
        self.experimentManifestByteCount = experimentManifestByteCount
        candidateDeclarationSetSHA256 =
            inputs.candidateDeclarationSetSHA256
        candidateDeclarationSetByteCount =
            inputs.candidateDeclarationSetByteCount
        tokenizerBundleSHA256 = inputs.tokenizerBundleSHA256
        tokenizerBundleByteCount = inputs.tokenizerBundleByteCount
        candidateIDs = inputs.candidateIDs
        candidateIdentitySHA256s = inputs.candidateIdentitySHA256s
        declarationBundleSHA256s = inputs.declarationBundleSHA256s
        outputNamespace = inputs.outputNamespace
        authority = PrimeLatinProposalPairAuthorityBoundaryV3()
    }
}

/// A live, non-Codable observation of one exact V3 proposal-pair receipt and
/// its two immutable children. It grants no proposal, trial, or publication
/// authority and does not observe the external bytes referenced by the pair.
public final class PrimeLatinProposalPairCaptureV3: @unchecked Sendable {
    public let observation: PrimeLatinProposalPairObservationV3

    private let root: PrimeLatinArtifactRoot
    private let locator: PrimeLatinProposalPairLocatorV3
    private let snapshot: PrimeLatinProposalPairSnapshotV3

    private init(
        root: PrimeLatinArtifactRoot,
        locator: PrimeLatinProposalPairLocatorV3,
        snapshot: PrimeLatinProposalPairSnapshotV3
    ) {
        self.root = root
        self.locator = locator
        self.snapshot = snapshot
        observation = snapshot.observation
    }

    public static func capture(
        labRoot: URL,
        pairSHA256: String
    ) throws -> PrimeLatinProposalPairCaptureV3 {
        try PrimeLatinProposalPairContractV3.requireCanonicalRoot(labRoot)
        let root = try PrimeLatinArtifactRoot(directoryURL: labRoot)
        return try capture(root: root, pairSHA256: pairSHA256)
    }

    static func capture(
        root: PrimeLatinArtifactRoot,
        pairSHA256: String
    ) throws -> PrimeLatinProposalPairCaptureV3 {
        let locator = try PrimeLatinProposalPairLocatorV3(
            sha256: pairSHA256)
        let first = try PrimeLatinProposalPairLoaderV3.load(
            root: root,
            locator: locator)
        let second = try PrimeLatinProposalPairLoaderV3.load(
            root: root,
            locator: locator)
        guard first == second else {
            throw PrimeLatinProposalPairCaptureError.captureChanged
        }
        return PrimeLatinProposalPairCaptureV3(
            root: root,
            locator: locator,
            snapshot: second)
    }

    func inputSnapshotMaterial()
        -> PrimeLatinProposalPairInputMaterialV3
    {
        PrimeLatinProposalPairInputMaterialV3(
            rootIdentity: snapshot.rootIdentity,
            observation: snapshot.observation,
            catalogData: snapshot.catalogData,
            experimentData: snapshot.experimentData)
    }

    package func retainedByteViewForIndependentReplayV1()
        -> PrimeLatinProposalPairRetainedByteViewV3
    {
        PrimeLatinProposalPairRetainedByteViewV3(
            observation: snapshot.observation,
            receiptData: snapshot.receiptData,
            candidateCatalogData: snapshot.catalogData,
            experimentManifestData: snapshot.experimentData)
    }

    @discardableResult
    public func recaptureAndValidateUnchanged() throws
        -> PrimeLatinProposalPairObservationV3
    {
        let current = try PrimeLatinProposalPairLoaderV3.load(
            root: root,
            locator: locator)
        guard current == snapshot else {
            throw PrimeLatinProposalPairCaptureError.captureChanged
        }
        return current.observation
    }
}

/// Package-scoped immutable bytes retained by the descriptor-bound pair
/// capture. This value exposes no root, descriptor, path capability, or
/// publication operation and is unavailable outside this Swift package.
package struct PrimeLatinProposalPairRetainedByteViewV3:
    Equatable,
    Sendable
{
    package let observation: PrimeLatinProposalPairObservationV3
    package let receiptData: Data
    package let candidateCatalogData: Data
    package let experimentManifestData: Data

    package init(
        observation: PrimeLatinProposalPairObservationV3,
        receiptData: Data,
        candidateCatalogData: Data,
        experimentManifestData: Data
    ) {
        self.observation = observation
        self.receiptData = receiptData
        self.candidateCatalogData = candidateCatalogData
        self.experimentManifestData = experimentManifestData
    }
}

struct PrimeLatinProposalPairInputMaterialV3: Equatable, Sendable {
    let rootIdentity: PrimeLatinArtifactRootIdentity
    let observation: PrimeLatinProposalPairObservationV3
    let catalogData: Data
    let experimentData: Data
}

private struct PrimeLatinProposalPairSnapshotV3: Equatable {
    let rootIdentity: PrimeLatinArtifactRootIdentity
    let observation: PrimeLatinProposalPairObservationV3
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

private enum PrimeLatinProposalPairLoaderV3 {
    static func load(
        root: PrimeLatinArtifactRoot,
        locator: PrimeLatinProposalPairLocatorV3
    ) throws -> PrimeLatinProposalPairSnapshotV3 {
        let rootIdentity = try root.verifiedRootIdentity()
        let receiptBinding = try root.bindExisting(
            at: locator.relativePath,
            purpose: .immutableData,
            maximumByteCount:
                PrimeLatinProposalPairContractV3.maximumDocumentBytes)
        guard receiptBinding.sha256 == locator.sha256,
              receiptBinding.byteCount > 0 else {
            throw PrimeLatinProposalPairCaptureError.invalidDocument(
                PrimeLatinProposalPairContractV3.receiptKind + "_binding")
        }
        let receiptRead = try root.readVerifiedArtifact(
            receiptBinding,
            maximumByteCount:
                PrimeLatinProposalPairContractV3.maximumDocumentBytes)
        let receipt = try decode(
            PrimeLatinProposalPairReceiptWireV3.self,
            data: receiptRead.data,
            path: locator.relativePath)
        try validate(receipt)

        let catalogBinding = try childBinding(
            receipt.candidateCatalog,
            kind: PrimeLatinProposalPairContractV3.candidateCatalogKind,
            directory: "catalogs")
        let experimentBinding = try childBinding(
            receipt.experimentManifest,
            kind: PrimeLatinProposalPairContractV3.experimentManifestKind,
            directory: "experiments")
        let catalogRead = try root.readVerifiedArtifact(
            catalogBinding,
            maximumByteCount:
                PrimeLatinProposalPairContractV3.maximumDocumentBytes)
        let experimentRead = try root.readVerifiedArtifact(
            experimentBinding,
            maximumByteCount:
                PrimeLatinProposalPairContractV3.maximumDocumentBytes)

        let inputs: PrimeLatinProposalInputsV3Observation
        do {
            inputs = try PrimeLatinProposalInputsV3.consume(
                candidateCatalogData: catalogRead.data,
                experimentManifestData: experimentRead.data)
        } catch {
            throw PrimeLatinProposalPairCaptureError.invalidSemantics(
                "proposal_pair_inputs_v3")
        }
        try validateCrossBindings(
            receipt: receipt,
            catalogData: catalogRead.data,
            experimentData: experimentRead.data,
            inputs: inputs)

        let finalReceiptRead = try root.readVerifiedArtifact(
            receiptBinding,
            maximumByteCount:
                PrimeLatinProposalPairContractV3.maximumDocumentBytes)
        let finalCatalogRead = try root.readVerifiedArtifact(
            catalogBinding,
            maximumByteCount:
                PrimeLatinProposalPairContractV3.maximumDocumentBytes)
        let finalExperimentRead = try root.readVerifiedArtifact(
            experimentBinding,
            maximumByteCount:
                PrimeLatinProposalPairContractV3.maximumDocumentBytes)
        guard try root.verifiedRootIdentity() == rootIdentity,
              finalReceiptRead == receiptRead,
              finalCatalogRead == catalogRead,
              finalExperimentRead == experimentRead else {
            throw PrimeLatinProposalPairCaptureError.captureChanged
        }

        let observation = PrimeLatinProposalPairObservationV3(
            pairReceiptSHA256: locator.sha256,
            pairReceiptByteCount: receiptBinding.byteCount,
            experimentManifestSHA256: experimentBinding.sha256,
            experimentManifestByteCount: experimentBinding.byteCount,
            inputs: inputs)
        return PrimeLatinProposalPairSnapshotV3(
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
                <= PrimeLatinProposalPairContractV3.maximumDocumentBytes
        else {
            throw PrimeLatinProposalPairCaptureError.invalidDocument(path)
        }
        do {
            return try PrimeLatinCanonicalJSON.decode(
                type,
                from: data,
                artifact: path)
        } catch {
            throw PrimeLatinProposalPairCaptureError.invalidDocument(path)
        }
    }

    private static func childBinding(
        _ document: PrimeLatinPublishedDocumentWireV3,
        kind: String,
        directory: String
    ) throws -> PrimeLatinCapturedArtifactBinding {
        guard PrimeLatinProposalPairContractV3.isSHA256(document.sha256),
              document.documentKind == kind,
              document.byteCount > 0,
              document.byteCount
                <= PrimeLatinProposalPairContractV3.maximumDocumentBytes,
              document.relativePath
                == PrimeLatinProposalPairContractV3.publicationRoot
                    + "/\(directory)/\(document.sha256).json" else {
            throw PrimeLatinProposalPairCaptureError.invalidDocument(kind)
        }
        return PrimeLatinCapturedArtifactBinding(
            relativePath: document.relativePath,
            sha256: document.sha256,
            byteCount: document.byteCount,
            purpose: .immutableData)
    }

    private static func validate(
        _ receipt: PrimeLatinProposalPairReceiptWireV3
    ) throws {
        try PrimeLatinProposalPairContractV3.requireExactPublisherSource(
            receipt.llmSource)
        guard receipt.schema
                == PrimeLatinProposalPairContractV3.receiptSchema,
              PrimeLatinProposalPairContractV3.isSHA256(
                receipt.candidateDeclarationSetSHA256),
              receipt.candidateDeclarationSetByteCount > 0,
              receipt.candidateDeclarationSetByteCount
                <= PrimeLatinProposalPairContractV3.maximumDocumentBytes,
              receipt.publicationMechanicsStatus
                == "content_addressed_create_once_pair_complete",
              receipt.authorityStatus == "mechanics_only_non_authorizing",
              receipt.completionScope
                == "canonical_v3_catalog_experiment_pair_only",
              receipt.referencedInputSnapshot == "absent",
              receipt.referencedArtifactBytes
                == "absent_from_pair_except_catalog_and_experiment_children",
              receipt.independentReplayStatus
                == "requires_original_bound_input_bytes_and_live_provenance",
              receipt.primeConsumerStatus
                == "prime_consumer_state_not_observed_by_producer",
              receipt.externalStateCommitAtomicity
                == "absent_live_roots_revalidated_before_receipt_rename",
              receipt.publicationCoordination
                == "cooperative_process_lock_only",
              receipt.authority.isExactlyAbsent else {
            throw PrimeLatinProposalPairCaptureError.invalidSemantics(
                "proposal_pair_receipt_v3")
        }
        _ = try childBinding(
            receipt.candidateCatalog,
            kind: PrimeLatinProposalPairContractV3.candidateCatalogKind,
            directory: "catalogs")
        _ = try childBinding(
            receipt.experimentManifest,
            kind: PrimeLatinProposalPairContractV3.experimentManifestKind,
            directory: "experiments")
    }

    private static func validateCrossBindings(
        receipt: PrimeLatinProposalPairReceiptWireV3,
        catalogData: Data,
        experimentData: Data,
        inputs: PrimeLatinProposalInputsV3Observation
    ) throws {
        guard receipt.llmSource.repository == inputs.llmSource.repository,
              receipt.llmSource.commit == inputs.llmSource.commit,
              receipt.llmSource.tree == inputs.llmSource.tree,
              receipt.candidateCatalog.sha256
                == inputs.candidateCatalogSHA256,
              receipt.candidateCatalog.byteCount
                == inputs.candidateCatalogByteCount,
              receipt.candidateCatalog.sha256
                == PrimeLatinSHA256.hexDigest(of: catalogData),
              receipt.candidateCatalog.byteCount == UInt64(catalogData.count),
              receipt.experimentManifest.sha256
                == PrimeLatinSHA256.hexDigest(of: experimentData),
              receipt.experimentManifest.byteCount
                == UInt64(experimentData.count),
              receipt.candidateDeclarationSetSHA256
                == inputs.candidateDeclarationSetSHA256,
              receipt.candidateDeclarationSetByteCount
                == inputs.candidateDeclarationSetByteCount else {
            throw PrimeLatinProposalPairCaptureError.invalidSemantics(
                "proposal_pair_receipt_v3_cross_binding")
        }
    }
}

enum PrimeLatinProposalPairContractV3 {
    static let publicationRoot = "evidence/latin-proposal-artifacts/v3"
    static let receiptSchema = "ergentics_latin_proposal_pair_receipt_v3"
    static let receiptKind = "proposal_pair_receipt_v3"
    static let candidateCatalogKind = "candidate_catalog_v3"
    static let experimentManifestKind = "experiment_manifest_v3"
    static let repository = "Ergentics/ergentics-llm"
    static let publisherCommit =
        "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831"
    static let publisherTree =
        "c1f41758aea2860ab06039776f5ea0403dff1b61"
    static let maximumDocumentBytes: UInt64 = 1_048_576

    static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    static func isGitOID(_ value: String) -> Bool {
        value.utf8.count == 40 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    fileprivate static func requireExactPublisherSource(
        _ source: PrimeLatinGitSourceWireV3
    ) throws {
        guard isGitOID(source.commit),
              isGitOID(source.tree),
              source.repository == repository,
              source.commit == publisherCommit,
              source.tree == publisherTree else {
            throw PrimeLatinProposalPairCaptureError.invalidSemantics(
                "unsupported_v3_publisher_source")
        }
    }

    static func requireCanonicalRoot(_ root: URL) throws {
        let path = root.path
        guard root.isFileURL,
              path.hasPrefix("/"),
              path != "/",
              !path.utf8.contains(0),
              root.standardizedFileURL.path == path,
              root.resolvingSymlinksInPath().standardizedFileURL.path == path
        else {
            throw PrimeLatinProposalPairCaptureError.invalidRoot(path)
        }
    }
}

private struct PrimeLatinGitSourceWireV3: Codable, Equatable, Sendable {
    let repository: String
    let commit: String
    let tree: String
}

private struct PrimeLatinPublishedDocumentWireV3:
    Codable,
    Equatable,
    Sendable
{
    let documentKind: String
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
}

private struct PrimeLatinProposalPairReceiptAuthorityWireV3:
    Codable,
    Equatable,
    Sendable
{
    let primeProposalPacket: String
    let primeTrialAuthorization: String
    let primeDecisionReceipt: String
    let candidateSelectionAuthorized: Bool
    let trialExecutionAuthorized: Bool
    let furtherTrainingAuthorized: Bool
    let promotionAuthorized: Bool
    let productUseAuthorized: Bool
    let publicationAuthorized: Bool

    var isExactlyAbsent: Bool {
        primeProposalPacket == "absent"
            && primeTrialAuthorization == "absent"
            && primeDecisionReceipt == "absent"
            && !candidateSelectionAuthorized
            && !trialExecutionAuthorized
            && !furtherTrainingAuthorized
            && !promotionAuthorized
            && !productUseAuthorized
            && !publicationAuthorized
    }
}

private struct PrimeLatinProposalPairReceiptWireV3:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let llmSource: PrimeLatinGitSourceWireV3
    let candidateCatalog: PrimeLatinPublishedDocumentWireV3
    let experimentManifest: PrimeLatinPublishedDocumentWireV3
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let publicationMechanicsStatus: String
    let authorityStatus: String
    let completionScope: String
    let referencedInputSnapshot: String
    let referencedArtifactBytes: String
    let independentReplayStatus: String
    let primeConsumerStatus: String
    let externalStateCommitAtomicity: String
    let publicationCoordination: String
    let authority: PrimeLatinProposalPairReceiptAuthorityWireV3

    enum CodingKeys: String, CodingKey {
        case schema
        case llmSource
        case candidateCatalog
        case experimentManifest
        case candidateDeclarationSetSHA256
        case candidateDeclarationSetByteCount
        case publicationMechanicsStatus
        case authorityStatus
        case completionScope
        case referencedInputSnapshot
        case referencedArtifactBytes
        case independentReplayStatus
        case primeConsumerStatus
        case externalStateCommitAtomicity
        case publicationCoordination
        case authority
    }
}
