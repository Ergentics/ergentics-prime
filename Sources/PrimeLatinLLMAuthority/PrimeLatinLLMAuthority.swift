import CryptoKit
import Foundation

public enum PrimeLatinLLMAuthorityError: Error, Equatable, Sendable {
    case invalidSchema(String)
    case invalidIdentifier(String)
    case invalidGitOID(String)
    case invalidSHA256(String)
    case invalidRelativePath(String)
    case invalidByteCount
    case forbiddenDependencyContext(String)
    case invalidArtifactSet
    case invalidCandidateSet
    case invalidTrialBudget
    case historicalOutputNamespace
    case noncanonicalJSON
    case packetDigestMismatch
    case oversizedPacket
}

public enum PrimeLatinAuthoritySchema {
    public static let proposalMaterial =
        "prime_latin_trial_proposal_material_v1"
    public static let proposalPacket =
        "prime_latin_trial_proposal_packet_v1"
    public static let trialAuthorization =
        "prime_latin_trial_authorization_v1"
    public static let laneID = "latin_primary_prospective_v1"
    public static let ergenticsLLMRepository =
        "Ergentics/ergentics-llm"
}

public struct PrimeLatinGitSourceBinding:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let commit: String
    public let tree: String

    public init(
        repository: String,
        commit: String,
        tree: String
    ) throws {
        guard repository == PrimeLatinAuthoritySchema.ergenticsLLMRepository
        else {
            throw PrimeLatinLLMAuthorityError.invalidIdentifier(repository)
        }
        try PrimeLatinValidation.gitOID(commit)
        try PrimeLatinValidation.gitOID(tree)
        self.repository = repository
        self.commit = commit
        self.tree = tree
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            repository: values.decode(String.self, forKey: .repository),
            commit: values.decode(String.self, forKey: .commit),
            tree: values.decode(String.self, forKey: .tree))
    }
}

public enum PrimeLatinArtifactRole: String, Codable, CaseIterable, Sendable {
    case candidateCatalog = "candidate_catalog"
    case corpusManifest = "corpus_manifest"
    case dependencyLock = "dependency_lock"
    case evaluationContract = "evaluation_contract"
    case experimentManifest = "experiment_manifest"
    case initializationContract = "initialization_contract"
    case tokenizerManifest = "tokenizer_manifest"
}

public enum PrimeLatinArtifactScope: String, Codable, Sendable {
    case ergenticsLLMRepository = "ergentics_llm_repository"
    case ergenticsMLXLab = "ergentics_mlx_lab"
}

public struct PrimeLatinArtifactBinding:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeLatinArtifactRole
    public let scope: PrimeLatinArtifactScope
    public let relativePath: String
    public let sha256: String
    public let byteCount: UInt64

    public init(
        role: PrimeLatinArtifactRole,
        scope: PrimeLatinArtifactScope,
        relativePath: String,
        sha256: String,
        byteCount: UInt64
    ) throws {
        try PrimeLatinValidation.relativePath(relativePath)
        try PrimeLatinValidation.sha256(sha256)
        guard byteCount > 0 else {
            throw PrimeLatinLLMAuthorityError.invalidByteCount
        }
        try PrimeLatinValidation.noForbiddenContext(relativePath)
        self.role = role
        self.scope = scope
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            role: values.decode(PrimeLatinArtifactRole.self, forKey: .role),
            scope: values.decode(PrimeLatinArtifactScope.self, forKey: .scope),
            relativePath: values.decode(String.self, forKey: .relativePath),
            sha256: values.decode(String.self, forKey: .sha256),
            byteCount: values.decode(UInt64.self, forKey: .byteCount))
    }
}

public enum PrimeLatinCandidateSourceKind: String, Codable, Sendable {
    case contributorDeclared = "contributor_declared"
}

public struct PrimeLatinCandidateReference:
    Codable,
    Equatable,
    Sendable
{
    public let candidateID: String
    public let declarationSHA256: String
    public let sourceKind: PrimeLatinCandidateSourceKind
    public let sourceAttribution: String

    public init(
        candidateID: String,
        declarationSHA256: String,
        sourceKind: PrimeLatinCandidateSourceKind = .contributorDeclared,
        sourceAttribution: String
    ) throws {
        try PrimeLatinValidation.identifier(candidateID)
        try PrimeLatinValidation.sha256(declarationSHA256)
        try PrimeLatinValidation.identifier(sourceAttribution)
        try PrimeLatinValidation.noForbiddenContext(candidateID)
        try PrimeLatinValidation.noForbiddenContext(sourceAttribution)
        self.candidateID = candidateID
        self.declarationSHA256 = declarationSHA256
        self.sourceKind = sourceKind
        self.sourceAttribution = sourceAttribution
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            candidateID: values.decode(String.self, forKey: .candidateID),
            declarationSHA256: values.decode(String.self, forKey: .declarationSHA256),
            sourceKind: values.decode(PrimeLatinCandidateSourceKind.self, forKey: .sourceKind),
            sourceAttribution: values.decode(String.self, forKey: .sourceAttribution))
    }
}

public struct PrimeLatinTrialBudget:
    Codable,
    Equatable,
    Sendable
{
    public let optimizerSteps: UInt64
    public let trainingTokens: UInt64
    public let wallClockSeconds: UInt64

    public init(
        optimizerSteps: UInt64,
        trainingTokens: UInt64,
        wallClockSeconds: UInt64
    ) throws {
        guard optimizerSteps > 0,
              trainingTokens > 0,
              wallClockSeconds > 0
        else {
            throw PrimeLatinLLMAuthorityError.invalidTrialBudget
        }
        self.optimizerSteps = optimizerSteps
        self.trainingTokens = trainingTokens
        self.wallClockSeconds = wallClockSeconds
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            optimizerSteps: values.decode(UInt64.self, forKey: .optimizerSteps),
            trainingTokens: values.decode(UInt64.self, forKey: .trainingTokens),
            wallClockSeconds: values.decode(UInt64.self, forKey: .wallClockSeconds))
    }
}

public enum PrimeLatinEvaluationDataStatus: String, Codable, Sendable {
    case prospectiveUnobserved = "prospective_unobserved"
}

public struct PrimeLatinTrialProposalMaterial:
    Codable,
    Equatable,
    Sendable
{
    public let schema: String
    public let laneID: String
    public let llmSource: PrimeLatinGitSourceBinding
    public let artifacts: [PrimeLatinArtifactBinding]
    public let candidates: [PrimeLatinCandidateReference]
    public let trialBudget: PrimeLatinTrialBudget
    public let evaluationDataStatus: PrimeLatinEvaluationDataStatus
    public let outputNamespace: String

    public init(
        schema: String = PrimeLatinAuthoritySchema.proposalMaterial,
        laneID: String = PrimeLatinAuthoritySchema.laneID,
        llmSource: PrimeLatinGitSourceBinding,
        artifacts: [PrimeLatinArtifactBinding],
        candidates: [PrimeLatinCandidateReference],
        trialBudget: PrimeLatinTrialBudget,
        evaluationDataStatus: PrimeLatinEvaluationDataStatus,
        outputNamespace: String
    ) throws {
        guard schema == PrimeLatinAuthoritySchema.proposalMaterial else {
            throw PrimeLatinLLMAuthorityError.invalidSchema(schema)
        }
        guard laneID == PrimeLatinAuthoritySchema.laneID else {
            throw PrimeLatinLLMAuthorityError.invalidIdentifier(laneID)
        }
        try PrimeLatinValidation.artifacts(artifacts)
        try PrimeLatinValidation.candidates(candidates)
        try PrimeLatinValidation.relativePath(outputNamespace)
        try PrimeLatinValidation.noForbiddenContext(outputNamespace)
        guard !outputNamespace.lowercased().contains(
            "ergentics_latin_primary_v1")
        else {
            throw PrimeLatinLLMAuthorityError.historicalOutputNamespace
        }
        self.schema = schema
        self.laneID = laneID
        self.llmSource = llmSource
        self.artifacts = artifacts
        self.candidates = candidates
        self.trialBudget = trialBudget
        self.evaluationDataStatus = evaluationDataStatus
        self.outputNamespace = outputNamespace
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            schema: values.decode(String.self, forKey: .schema),
            laneID: values.decode(String.self, forKey: .laneID),
            llmSource: values.decode(PrimeLatinGitSourceBinding.self, forKey: .llmSource),
            artifacts: values.decode([PrimeLatinArtifactBinding].self, forKey: .artifacts),
            candidates: values.decode([PrimeLatinCandidateReference].self, forKey: .candidates),
            trialBudget: values.decode(PrimeLatinTrialBudget.self, forKey: .trialBudget),
            evaluationDataStatus: values.decode(PrimeLatinEvaluationDataStatus.self, forKey: .evaluationDataStatus),
            outputNamespace: values.decode(String.self, forKey: .outputNamespace))
    }
}

public struct PrimeLatinTrialProposalPacket:
    Codable,
    Equatable,
    Sendable
{
    public let schema: String
    public let material: PrimeLatinTrialProposalMaterial
    public let materialSHA256: String

    fileprivate init(
        material: PrimeLatinTrialProposalMaterial,
        materialSHA256: String
    ) {
        self.schema = PrimeLatinAuthoritySchema.proposalPacket
        self.material = material
        self.materialSHA256 = materialSHA256
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let schema = try values.decode(String.self, forKey: .schema)
        guard schema == PrimeLatinAuthoritySchema.proposalPacket else {
            throw PrimeLatinLLMAuthorityError.invalidSchema(schema)
        }
        let material = try values.decode(
            PrimeLatinTrialProposalMaterial.self,
            forKey: .material)
        let digest = try values.decode(String.self, forKey: .materialSHA256)
        try PrimeLatinValidation.sha256(digest)
        self.init(material: material, materialSHA256: digest)
    }
}

public enum PrimeLatinTrialAuthorizationDisposition:
    String,
    Codable,
    Sendable
{
    case abstain
}

public enum PrimeLatinTrialAuthorizationReason:
    String,
    Codable,
    Sendable
{
    case primeSelectionPolicyNotInstalled =
        "prime_selection_policy_not_installed"
}

public struct PrimeLatinTrialAuthorizationReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schema: String
    public let proposalMaterialSHA256: String
    public let disposition: PrimeLatinTrialAuthorizationDisposition
    public let reasons: [PrimeLatinTrialAuthorizationReason]
    public let trialExecutionAuthorized: Bool
    public let furtherTrainingAuthorized: Bool
    public let promotionAuthorized: Bool
    public let productUseAuthorized: Bool

    fileprivate init(proposalMaterialSHA256: String) {
        self.schema = PrimeLatinAuthoritySchema.trialAuthorization
        self.proposalMaterialSHA256 = proposalMaterialSHA256
        self.disposition = .abstain
        self.reasons = [.primeSelectionPolicyNotInstalled]
        self.trialExecutionAuthorized = false
        self.furtherTrainingAuthorized = false
        self.promotionAuthorized = false
        self.productUseAuthorized = false
    }
}

public enum PrimeLatinLLMAuthority {
    public static let maximumCanonicalPacketBytes = 1_048_576

    public static func makeProposalPacket(
        material: PrimeLatinTrialProposalMaterial
    ) throws -> PrimeLatinTrialProposalPacket {
        let materialData = try canonicalData(material)
        return PrimeLatinTrialProposalPacket(
            material: material,
            materialSHA256: sha256(materialData))
    }

    public static func canonicalData<Value: Encodable>(
        _ value: Value
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return try encoder.encode(value)
    }

    public static func decodeCanonicalProposalPacket(
        _ data: Data
    ) throws -> PrimeLatinTrialProposalPacket {
        guard data.count <= maximumCanonicalPacketBytes else {
            throw PrimeLatinLLMAuthorityError.oversizedPacket
        }
        let packet = try JSONDecoder().decode(
            PrimeLatinTrialProposalPacket.self,
            from: data)
        guard try canonicalData(packet) == data else {
            throw PrimeLatinLLMAuthorityError.noncanonicalJSON
        }
        let observed = sha256(try canonicalData(packet.material))
        guard observed == packet.materialSHA256 else {
            throw PrimeLatinLLMAuthorityError.packetDigestMismatch
        }
        return packet
    }

    public static func foundationAuthorization(
        for packet: PrimeLatinTrialProposalPacket
    ) throws -> PrimeLatinTrialAuthorizationReceipt {
        let observed = sha256(try canonicalData(packet.material))
        guard observed == packet.materialSHA256 else {
            throw PrimeLatinLLMAuthorityError.packetDigestMismatch
        }
        return PrimeLatinTrialAuthorizationReceipt(
            proposalMaterialSHA256: packet.materialSHA256)
    }

    public static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

private enum PrimeLatinValidation {
    private static let forbiddenContext = [
        "llama",
        "mlxllm",
        "mlx-swift-lm",
        "mlx_swift_lm",
    ]

    static func identifier(_ value: String) throws {
        guard !value.isEmpty,
              value.utf8.count <= 128,
              value.utf8.allSatisfy({ byte in
                  (byte >= 97 && byte <= 122)
                      || (byte >= 48 && byte <= 57)
                      || byte == 45
                      || byte == 46
                      || byte == 95
              })
        else {
            throw PrimeLatinLLMAuthorityError.invalidIdentifier(value)
        }
    }

    static func gitOID(_ value: String) throws {
        guard value.utf8.count == 40,
              value.utf8.allSatisfy(isLowercaseHex)
        else {
            throw PrimeLatinLLMAuthorityError.invalidGitOID(value)
        }
    }

    static func sha256(_ value: String) throws {
        guard value.utf8.count == 64,
              value.utf8.allSatisfy(isLowercaseHex)
        else {
            throw PrimeLatinLLMAuthorityError.invalidSHA256(value)
        }
    }

    static func relativePath(_ value: String) throws {
        guard !value.isEmpty,
              value.utf8.count <= 1_024,
              !value.hasPrefix("/"),
              !value.hasSuffix("/"),
              !value.contains("\\"),
              value.split(separator: "/", omittingEmptySubsequences: false)
                .allSatisfy({ component in
                    !component.isEmpty
                        && component != "."
                        && component != ".."
                        && component.utf8.allSatisfy({ byte in
                            (byte >= 65 && byte <= 90)
                                || (byte >= 97 && byte <= 122)
                                || (byte >= 48 && byte <= 57)
                                || byte == 45
                                || byte == 46
                                || byte == 95
                        })
                })
        else {
            throw PrimeLatinLLMAuthorityError.invalidRelativePath(value)
        }
    }

    static func noForbiddenContext(_ value: String) throws {
        let normalized = value.lowercased()
        if forbiddenContext.contains(where: normalized.contains) {
            throw PrimeLatinLLMAuthorityError.forbiddenDependencyContext(value)
        }
    }

    static func artifacts(_ values: [PrimeLatinArtifactBinding]) throws {
        let expected = PrimeLatinArtifactRole.allCases.sorted {
            $0.rawValue < $1.rawValue
        }
        guard values.map(\.role) == expected,
              Set(values.map(\.role)).count == expected.count,
              Set(values.map(\.relativePath)).count == values.count
        else {
            throw PrimeLatinLLMAuthorityError.invalidArtifactSet
        }
    }

    static func candidates(_ values: [PrimeLatinCandidateReference]) throws {
        guard !values.isEmpty,
              values.count <= 64,
              values.map(\.candidateID) == values.map(\.candidateID).sorted(),
              Set(values.map(\.candidateID)).count == values.count,
              Set(values.map(\.declarationSHA256)).count == values.count
        else {
            throw PrimeLatinLLMAuthorityError.invalidCandidateSet
        }
    }

    private static func isLowercaseHex(_ byte: UInt8) -> Bool {
        (byte >= 48 && byte <= 57) || (byte >= 97 && byte <= 102)
    }
}
