import Foundation

public enum PrimeLatinProposalInputArtifactScopeV3:
    String,
    Equatable,
    Sendable
{
    case ergenticsLLMRepository = "ergentics_llm_repository"
    case ergenticsMLXLab = "ergentics_mlx_lab"
}

public struct PrimeLatinProposalInputArtifactObservationV3:
    Equatable,
    Sendable
{
    public let scope: PrimeLatinProposalInputArtifactScopeV3
    public let relativePath: String
    public let sha256: String
    public let byteCount: UInt64
    public let roles: [String]
    public let actualMode: UInt16

    fileprivate init(
        expectation: PrimeLatinProposalInputArtifactExpectationV3,
        read: PrimeLatinVerifiedPublicationRead
    ) {
        scope = expectation.scope
        relativePath = expectation.relativePath
        sha256 = expectation.sha256
        byteCount = expectation.byteCount
        roles = [expectation.role]
        actualMode = read.artifact.actualMode
    }
}

public struct PrimeLatinProposalInputSnapshotAuthorityBoundaryV3:
    Equatable,
    Sendable
{
    public let disposition: String
    public let stablePairRootBoundCaptureComplete: Bool
    public let stableLLMRepositoryRootBoundCaptureComplete: Bool
    public let stableLabRootBoundCaptureComplete: Bool
    public let artifactPathRoleHashCountBindingsVerified: Bool
    public let outputNamespaceAbsenceVerified: Bool
    public let pairCaptureAndRecaptureComplete: Bool
    public let referencedInputSnapshotAvailable: Bool
    public let referencedArtifactBytesAvailable: Bool
    public let durableInputSnapshotPublished: Bool
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
            "abstain_snapshot_mechanics_only_requires_live_producer_revalidation_git_observation_and_independent_replay"
        stablePairRootBoundCaptureComplete = true
        stableLLMRepositoryRootBoundCaptureComplete = true
        stableLabRootBoundCaptureComplete = true
        artifactPathRoleHashCountBindingsVerified = true
        outputNamespaceAbsenceVerified = true
        pairCaptureAndRecaptureComplete = true
        referencedInputSnapshotAvailable = true
        referencedArtifactBytesAvailable = true
        durableInputSnapshotPublished = false
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

public struct PrimeLatinProposalInputSnapshotObservationV3:
    Equatable,
    Sendable
{
    public let schema: String
    public let outcome: String
    public let verificationScope: String
    public let pairReceiptSHA256: String
    public let llmSource: PrimeLatinProposalInputsV3SourceObservation
    public let artifactCount: UInt64
    public let artifacts: [PrimeLatinProposalInputArtifactObservationV3]
    public let outputNamespace: String
    public let authority: PrimeLatinProposalInputSnapshotAuthorityBoundaryV3

    fileprivate init(
        pairObservation: PrimeLatinProposalPairObservationV3,
        artifacts: [PrimeLatinProposalInputArtifactObservationV3],
        outputNamespace: String
    ) {
        schema =
            "ergentics_prime_latin_proposal_input_snapshot_v3_observation"
        outcome = "abstain"
        verificationScope =
            "descriptor_safe_exact_v3_original_bound_input_snapshot_only_non_authorizing"
        pairReceiptSHA256 = pairObservation.pairReceiptSHA256
        llmSource = pairObservation.llmSource
        artifactCount = UInt64(artifacts.count)
        self.artifacts = artifacts
        self.outputNamespace = outputNamespace
        authority = PrimeLatinProposalInputSnapshotAuthorityBoundaryV3()
    }
}

public enum PrimeLatinProposalInputSnapshotError:
    Error,
    Equatable,
    Sendable
{
    case invalidSnapshot(String)
    case outputNamespacePresent(String)
    case captureChanged
}

/// A process-local, read-only snapshot of the exact external bytes referenced
/// by one final V3 proposal pair. The captured bytes are retained privately;
/// this type publishes nothing and grants no execution or decision authority.
public final class PrimeLatinProposalInputSnapshotCaptureV3:
    @unchecked Sendable
{
    public let observation: PrimeLatinProposalInputSnapshotObservationV3

    private let labRoot: PrimeLatinArtifactRoot
    private let llmRepositoryRoot: PrimeLatinArtifactRoot
    private let pairCapture: PrimeLatinProposalPairCaptureV3
    private let plan: PrimeLatinProposalInputSnapshotPlanV3
    private let snapshot: PrimeLatinProposalInputSnapshotStateV3

    private init(
        labRoot: PrimeLatinArtifactRoot,
        llmRepositoryRoot: PrimeLatinArtifactRoot,
        pairCapture: PrimeLatinProposalPairCaptureV3,
        plan: PrimeLatinProposalInputSnapshotPlanV3,
        snapshot: PrimeLatinProposalInputSnapshotStateV3
    ) {
        self.labRoot = labRoot
        self.llmRepositoryRoot = llmRepositoryRoot
        self.pairCapture = pairCapture
        self.plan = plan
        self.snapshot = snapshot
        observation = snapshot.observation
    }

    public static func capture(
        labRoot: URL,
        llmRepositoryRoot: URL,
        pairSHA256: String
    ) throws -> PrimeLatinProposalInputSnapshotCaptureV3 {
        try capture(
            labRootURL: labRoot,
            llmRepositoryRootURL: llmRepositoryRoot,
            pairSHA256: pairSHA256,
            injectedExpectations: nil,
            injectedOutputNamespace: nil,
            inventoryPolicy: .finalHandoff,
            beforeFinalRecapture: {})
    }

    @discardableResult
    public func recaptureAndValidateUnchanged() throws
        -> PrimeLatinProposalInputSnapshotObservationV3
    {
        do {
            let current = try PrimeLatinProposalInputSnapshotLoaderV3.load(
                labRoot: labRoot,
                llmRepositoryRoot: llmRepositoryRoot,
                pairCapture: pairCapture,
                plan: plan,
                beforeFinalRecapture: {})
            guard current == snapshot else {
                throw PrimeLatinProposalInputSnapshotError.captureChanged
            }
            return current.observation
        } catch {
            throw PrimeLatinProposalInputSnapshotError.captureChanged
        }
    }

    package func retainedInputSnapshotForIndependentReplayV1() throws
        -> PrimeLatinProposalIndependentReplayRetainedMaterialV1
    {
        _ = try recaptureAndValidateUnchanged()
        guard plan.expectations.count == snapshot.reads.count,
              snapshot.observation.artifacts.count == snapshot.reads.count
        else {
            throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                "retained_independent_replay_inventory")
        }
        var originals = [PrimeLatinProposalIndependentReplayOriginalInputV1]()
        originals.reserveCapacity(snapshot.reads.count)
        for index in snapshot.reads.indices {
            let expectation = plan.expectations[index]
            let observation = snapshot.observation.artifacts[index]
            let read = snapshot.reads[index]
            guard observation.roles == [expectation.role],
                  observation.scope == expectation.scope,
                  observation.relativePath == expectation.relativePath,
                  observation.sha256 == expectation.sha256,
                  observation.byteCount == expectation.byteCount,
                  read.artifact.binding.relativePath
                    == expectation.relativePath,
                  read.artifact.binding.sha256 == expectation.sha256,
                  read.artifact.binding.byteCount == expectation.byteCount
            else {
                throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                    "retained_independent_replay_binding")
            }
            originals.append(
                PrimeLatinProposalIndependentReplayOriginalInputV1(
                    role: expectation.role,
                    scope: expectation.scope,
                    relativePath: expectation.relativePath,
                    sha256: expectation.sha256,
                    byteCount: expectation.byteCount,
                    data: read.data))
        }
        return PrimeLatinProposalIndependentReplayRetainedMaterialV1(
            originalInputs:
                PrimeLatinProposalIndependentReplayOriginalInputsV1(
                    artifacts: originals),
            references:
                PrimeLatinProposalIndependentReplayReferenceMaterialV1(
                    pair: pairCapture
                        .retainedByteViewForIndependentReplayV1(),
                    snapshotObservation: snapshot.observation))
    }

    static func captureForTesting(
        labRoot: URL,
        llmRepositoryRoot: URL,
        pairSHA256: String,
        expectations: [PrimeLatinProposalInputArtifactExpectationV3],
        outputNamespace: String,
        beforeFinalRecapture: () throws -> Void
    ) throws -> PrimeLatinProposalInputSnapshotCaptureV3 {
        try capture(
            labRootURL: labRoot,
            llmRepositoryRootURL: llmRepositoryRoot,
            pairSHA256: pairSHA256,
            injectedExpectations: expectations,
            injectedOutputNamespace: outputNamespace,
            inventoryPolicy: .syntheticTest,
            beforeFinalRecapture: beforeFinalRecapture)
    }

    private static func capture(
        labRootURL: URL,
        llmRepositoryRootURL: URL,
        pairSHA256: String,
        injectedExpectations:
            [PrimeLatinProposalInputArtifactExpectationV3]?,
        injectedOutputNamespace: String?,
        inventoryPolicy: PrimeLatinProposalInputSnapshotInventoryPolicyV3,
        beforeFinalRecapture: () throws -> Void
    ) throws -> PrimeLatinProposalInputSnapshotCaptureV3 {
        do {
            try PrimeLatinProposalPairContractV3.requireCanonicalRoot(
                labRootURL)
            try PrimeLatinProposalPairContractV3.requireCanonicalRoot(
                llmRepositoryRootURL)
            try PrimeLatinProposalInputSnapshotContractV3.requireDisjointRoots(
                labRootURL,
                llmRepositoryRootURL)
            let labRoot = try PrimeLatinArtifactRoot(
                directoryURL: labRootURL)
            let llmRepositoryRoot = try PrimeLatinArtifactRoot(
                directoryURL: llmRepositoryRootURL)
            let pairCapture = try PrimeLatinProposalPairCaptureV3.capture(
                root: labRoot,
                pairSHA256: pairSHA256)
            let pairMaterial = pairCapture.inputSnapshotMaterial()
            let inputMaterial = try PrimeLatinProposalInputsV3
                .inputSnapshotMaterial(
                    candidateCatalogData: pairMaterial.catalogData,
                    experimentManifestData: pairMaterial.experimentData)
            guard inputMaterial.inputsObservation.llmSource
                    == pairMaterial.observation.llmSource,
                  inputMaterial.inputsObservation.outputNamespace
                    == pairMaterial.observation.outputNamespace else {
                throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                    "proposal_pair_input_cross_binding")
            }
            let plan = PrimeLatinProposalInputSnapshotPlanV3(
                expectations:
                    injectedExpectations ?? inputMaterial.expectations,
                outputNamespace:
                    injectedOutputNamespace ?? inputMaterial.outputNamespace,
                inventoryPolicy: inventoryPolicy)
            let snapshot = try PrimeLatinProposalInputSnapshotLoaderV3.load(
                labRoot: labRoot,
                llmRepositoryRoot: llmRepositoryRoot,
                pairCapture: pairCapture,
                plan: plan,
                beforeFinalRecapture: beforeFinalRecapture)
            return PrimeLatinProposalInputSnapshotCaptureV3(
                labRoot: labRoot,
                llmRepositoryRoot: llmRepositoryRoot,
                pairCapture: pairCapture,
                plan: plan,
                snapshot: snapshot)
        } catch let error as PrimeLatinProposalInputSnapshotError {
            throw error
        } catch let error as PrimeLatinArtifactReadError {
            if case .pathPresent(let path) = error {
                throw PrimeLatinProposalInputSnapshotError
                    .outputNamespacePresent(path)
            }
            throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                "descriptor_safe_input_snapshot")
        } catch {
            throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                "proposal_input_snapshot_v3")
        }
    }
}

/// One exact original input retained by the descriptor-bound snapshot. This
/// package-scoped value has no filesystem capability and is passed to the
/// independent reconstructor without any catalog, experiment, or receipt
/// reference bytes.
package struct PrimeLatinProposalIndependentReplayOriginalInputV1:
    Equatable,
    Sendable
{
    package let role: String
    package let scope: PrimeLatinProposalInputArtifactScopeV3
    package let relativePath: String
    package let sha256: String
    package let byteCount: UInt64
    package let data: Data

    package init(
        role: String,
        scope: PrimeLatinProposalInputArtifactScopeV3,
        relativePath: String,
        sha256: String,
        byteCount: UInt64,
        data: Data
    ) {
        self.role = role
        self.scope = scope
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
        self.data = data
    }
}

package struct PrimeLatinProposalIndependentReplayOriginalInputsV1:
    Equatable,
    Sendable
{
    package let artifacts:
        [PrimeLatinProposalIndependentReplayOriginalInputV1]

    package init(
        artifacts: [PrimeLatinProposalIndependentReplayOriginalInputV1]
    ) {
        self.artifacts = artifacts
    }
}

/// Reference bytes are deliberately separate from `originalInputs` so the
/// pure reconstruction function cannot consult producer catalog, experiment,
/// or receipt output while rebuilding them.
package struct PrimeLatinProposalIndependentReplayReferenceMaterialV1:
    Equatable,
    Sendable
{
    package let pair: PrimeLatinProposalPairRetainedByteViewV3
    package let snapshotObservation:
        PrimeLatinProposalInputSnapshotObservationV3

    package init(
        pair: PrimeLatinProposalPairRetainedByteViewV3,
        snapshotObservation:
            PrimeLatinProposalInputSnapshotObservationV3
    ) {
        self.pair = pair
        self.snapshotObservation = snapshotObservation
    }
}

package struct PrimeLatinProposalIndependentReplayRetainedMaterialV1:
    Equatable,
    Sendable
{
    package let originalInputs:
        PrimeLatinProposalIndependentReplayOriginalInputsV1
    package let references:
        PrimeLatinProposalIndependentReplayReferenceMaterialV1

    package init(
        originalInputs:
            PrimeLatinProposalIndependentReplayOriginalInputsV1,
        references:
            PrimeLatinProposalIndependentReplayReferenceMaterialV1
    ) {
        self.originalInputs = originalInputs
        self.references = references
    }
}

struct PrimeLatinProposalInputArtifactExpectationV3:
    Equatable,
    Sendable
{
    let role: String
    let scope: PrimeLatinProposalInputArtifactScopeV3
    let relativePath: String
    let sha256: String
    let byteCount: UInt64

    init(
        role: String,
        scope: PrimeLatinProposalInputArtifactScopeV3,
        relativePath: String,
        sha256: String,
        byteCount: UInt64
    ) {
        self.role = role
        self.scope = scope
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
    }
}

struct PrimeLatinProposalInputsV3SnapshotMaterial: Equatable, Sendable {
    let inputsObservation: PrimeLatinProposalInputsV3Observation
    let expectations: [PrimeLatinProposalInputArtifactExpectationV3]
    let outputNamespace: String
}

private enum PrimeLatinProposalInputSnapshotInventoryPolicyV3:
    Equatable,
    Sendable
{
    case finalHandoff
    case syntheticTest
}

private struct PrimeLatinProposalInputSnapshotPlanV3:
    Equatable,
    Sendable
{
    let expectations: [PrimeLatinProposalInputArtifactExpectationV3]
    let outputNamespace: String
    let inventoryPolicy: PrimeLatinProposalInputSnapshotInventoryPolicyV3
}

private struct PrimeLatinProposalInputSnapshotStateV3: Equatable {
    let pairRootIdentity: PrimeLatinArtifactRootIdentity
    let labRootIdentity: PrimeLatinArtifactRootIdentity
    let llmRepositoryRootIdentity: PrimeLatinArtifactRootIdentity
    let reads: [PrimeLatinVerifiedPublicationRead]
    let observation: PrimeLatinProposalInputSnapshotObservationV3
}

private enum PrimeLatinProposalInputSnapshotLoaderV3 {
    static func load(
        labRoot: PrimeLatinArtifactRoot,
        llmRepositoryRoot: PrimeLatinArtifactRoot,
        pairCapture: PrimeLatinProposalPairCaptureV3,
        plan: PrimeLatinProposalInputSnapshotPlanV3,
        beforeFinalRecapture: () throws -> Void
    ) throws -> PrimeLatinProposalInputSnapshotStateV3 {
        try PrimeLatinProposalInputSnapshotContractV3.validate(plan)
        let pairMaterial = pairCapture.inputSnapshotMaterial()
        let initialLabIdentity = try labRoot.verifiedRootIdentity()
        let initialLLMIdentity = try llmRepositoryRoot.verifiedRootIdentity()
        guard pairMaterial.rootIdentity == initialLabIdentity,
              !PrimeLatinProposalInputSnapshotContractV3.sameDirectory(
                initialLabIdentity,
                initialLLMIdentity) else {
            throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                "input_snapshot_root_identity")
        }

        let finalReads = try {
            let stableReads = try {
                let first = try read(
                    plan.expectations,
                    labRoot: labRoot,
                    llmRepositoryRoot: llmRepositoryRoot)
                let second = try read(
                    plan.expectations,
                    labRoot: labRoot,
                    llmRepositoryRoot: llmRepositoryRoot)
                guard first == second else {
                    throw PrimeLatinProposalInputSnapshotError.captureChanged
                }
                try PrimeLatinProposalInputSnapshotContractV3
                    .requireUniqueInodes(second)
                return second
            }()
            try requireOutputAbsent(
                plan.outputNamespace,
                labRoot: labRoot)

            do {
                try beforeFinalRecapture()
            } catch {
                throw PrimeLatinProposalInputSnapshotError.captureChanged
            }

            let finalReads = try read(
                plan.expectations,
                labRoot: labRoot,
                llmRepositoryRoot: llmRepositoryRoot)
            guard finalReads == stableReads else {
                throw PrimeLatinProposalInputSnapshotError.captureChanged
            }
            try requireOutputAbsent(
                plan.outputNamespace,
                labRoot: labRoot)
            return finalReads
        }()
        let finalLLMIdentity = try llmRepositoryRoot.verifiedRootIdentity()
        let finalLabIdentity = try labRoot.verifiedRootIdentity()
        guard finalLLMIdentity == initialLLMIdentity,
              finalLabIdentity == initialLabIdentity else {
            throw PrimeLatinProposalInputSnapshotError.captureChanged
        }

        let finalPairObservation = try pairCapture
            .recaptureAndValidateUnchanged()
        guard finalPairObservation == pairMaterial.observation else {
            throw PrimeLatinProposalInputSnapshotError.captureChanged
        }

        let artifacts = zip(plan.expectations, finalReads).map {
            PrimeLatinProposalInputArtifactObservationV3(
                expectation: $0.0,
                read: $0.1)
        }
        let observation = PrimeLatinProposalInputSnapshotObservationV3(
            pairObservation: finalPairObservation,
            artifacts: artifacts,
            outputNamespace: plan.outputNamespace)
        return PrimeLatinProposalInputSnapshotStateV3(
            pairRootIdentity: pairMaterial.rootIdentity,
            labRootIdentity: finalLabIdentity,
            llmRepositoryRootIdentity: finalLLMIdentity,
            reads: finalReads,
            observation: observation)
    }

    private static func read(
        _ expectations: [PrimeLatinProposalInputArtifactExpectationV3],
        labRoot: PrimeLatinArtifactRoot,
        llmRepositoryRoot: PrimeLatinArtifactRoot
    ) throws -> [PrimeLatinVerifiedPublicationRead] {
        try expectations.map { expectation in
            let root: PrimeLatinArtifactRoot
            switch expectation.scope {
            case .ergenticsLLMRepository:
                root = llmRepositoryRoot
            case .ergenticsMLXLab:
                root = labRoot
            }
            let binding = PrimeLatinCapturedArtifactBinding(
                relativePath: expectation.relativePath,
                sha256: expectation.sha256,
                byteCount: expectation.byteCount,
                purpose: .boundInput)
            do {
                return try root.readVerifiedArtifact(
                    binding,
                    maximumByteCount:
                        PrimeLatinProposalInputSnapshotContractV3
                            .maximumArtifactBytes)
            } catch {
                throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                    "bound_input_\(expectation.role)")
            }
        }
    }

    private static func requireOutputAbsent(
        _ outputNamespace: String,
        labRoot: PrimeLatinArtifactRoot
    ) throws {
        do {
            try labRoot.requireAbsent(at: outputNamespace)
        } catch PrimeLatinArtifactReadError.pathPresent(let path) {
            throw PrimeLatinProposalInputSnapshotError
                .outputNamespacePresent(path)
        }
    }
}

private enum PrimeLatinProposalInputSnapshotContractV3 {
    static let maximumArtifactBytes: UInt64 = 8_388_608
    static let maximumAggregateArtifactBytes: UInt64 = 67_108_864
    static let roles = [
        "root_package_manifest",
        "root_dependency_lock",
        "declaration_package_manifest",
        "declaration_production_source",
        "candidate_architecture",
        "candidate_parameter_count_derivation",
        "evaluation_contract",
        "tokenizer_manifest",
        "tokenizer_sentencepiece_model",
        "tokenizer_vocabulary",
        "tokenizer_recommendation",
        "tokenizer_approval",
        "tokenizer_staged_training_input",
        "tokenizer_corpus_manifest",
        "tokenizer_admitted_corpus_input",
        "initialization_contract",
        "prospective_corpus_manifest",
        "training_split",
        "validation_split",
        "selection_split",
        "selection_observation_declaration",
    ]
    static let repositoryRoleCount = 7
    static let labRoleCount = 14
    static let tokenizerDuplicateRoles: Set<String> = [
        "tokenizer_staged_training_input",
        "tokenizer_admitted_corpus_input",
    ]
    static let tokenizerDuplicateSHA256 =
        "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76"
    static let tokenizerDuplicateByteCount: UInt64 = 3_743_426

    static func validate(
        _ plan: PrimeLatinProposalInputSnapshotPlanV3
    ) throws {
        let expectations = plan.expectations
        guard expectations.count == roles.count,
              expectations.map(\.role) == roles,
              expectations.prefix(repositoryRoleCount).allSatisfy({
                  $0.scope == .ergenticsLLMRepository
              }),
              expectations.suffix(labRoleCount).allSatisfy({
                  $0.scope == .ergenticsMLXLab
              }) else {
            throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                "bound_input_role_inventory")
        }

        var locations = Set<String>()
        var bySHA256 = [String: [PrimeLatinProposalInputArtifactExpectationV3]]()
        var aggregateByteCount: UInt64 = 0
        for expectation in expectations {
            _ = try PrimeLatinArtifactRoot.components(
                of: expectation.relativePath)
            guard isSHA256(expectation.sha256),
                  expectation.byteCount > 0,
                  expectation.byteCount <= maximumArtifactBytes else {
                throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                    "bound_input_binding_\(expectation.role)")
            }
            let nextAggregate = aggregateByteCount.addingReportingOverflow(
                expectation.byteCount)
            guard !nextAggregate.overflow,
                  nextAggregate.partialValue <= maximumAggregateArtifactBytes
            else {
                throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                    "bound_input_aggregate_byte_count")
            }
            aggregateByteCount = nextAggregate.partialValue
            let location = expectation.scope.rawValue + "\u{0}"
                + expectation.relativePath.lowercased()
            guard locations.insert(location).inserted else {
                throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                    "bound_input_location_alias")
            }
            bySHA256[expectation.sha256, default: []].append(expectation)
            if expectation.scope == .ergenticsMLXLab,
               pathsOverlap(
                    expectation.relativePath,
                    plan.outputNamespace) {
                throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                    "bound_input_output_overlap")
            }
        }
        _ = try PrimeLatinArtifactRoot.components(of: plan.outputNamespace)

        let duplicateGroups = bySHA256.values.filter { $0.count > 1 }
        guard duplicateGroups.count <= 1 else {
            throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                "bound_input_hash_alias")
        }
        if let duplicate = duplicateGroups.first {
            guard duplicate.count == 2,
                  Set(duplicate.map(\.role)) == tokenizerDuplicateRoles,
                  Set(duplicate.map(\.byteCount)).count == 1 else {
                throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                    "bound_input_hash_alias")
            }
            if plan.inventoryPolicy == .finalHandoff {
                guard duplicate[0].sha256 == tokenizerDuplicateSHA256,
                      duplicate[0].byteCount
                        == tokenizerDuplicateByteCount else {
                    throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                        "final_tokenizer_input_alias")
                }
            }
        } else if plan.inventoryPolicy == .finalHandoff {
            throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                "missing_final_tokenizer_input_alias")
        }
    }

    static func requireUniqueInodes(
        _ reads: [PrimeLatinVerifiedPublicationRead]
    ) throws {
        let identities = reads.map {
            "\($0.artifact.deviceID):\($0.artifact.inode)"
        }
        guard Set(identities).count == reads.count else {
            throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                "bound_input_inode_alias")
        }
    }

    static func requireDisjointRoots(
        _ first: URL,
        _ second: URL
    ) throws {
        let firstPath = first.path.lowercased()
        let secondPath = second.path.lowercased()
        guard !pathsOverlap(firstPath, secondPath) else {
            throw PrimeLatinProposalInputSnapshotError.invalidSnapshot(
                "overlapping_input_roots")
        }
    }

    static func sameDirectory(
        _ first: PrimeLatinArtifactRootIdentity,
        _ second: PrimeLatinArtifactRootIdentity
    ) -> Bool {
        first.deviceID == second.deviceID && first.inode == second.inode
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    private static func pathsOverlap(_ first: String, _ second: String) -> Bool {
        let firstComponents = first.lowercased().split(separator: "/")
        let secondComponents = second.lowercased().split(separator: "/")
        let sharedCount = min(firstComponents.count, secondComponents.count)
        return firstComponents.prefix(sharedCount)
            == secondComponents.prefix(sharedCount)
    }
}
