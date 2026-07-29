import Foundation

/// The two deliberately small model topologies used by the schema-v2 restore
/// feasibility gate.
///
/// The nested fixture contains same-shaped siblings so that a path swap cannot
/// pass merely because shape and dtype agree.
public enum PrimeTypedOptimizerFixture:
    String,
    Codable,
    CaseIterable,
    Comparable,
    Hashable,
    Sendable
{
    case flat
    case nestedSameShape = "nested_same_shape"

    public static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var trainablePaths: [String] {
        switch self {
        case .flat:
            ["bias", "weight"]
        case .nestedSameShape:
            [
                "layers.0.bias",
                "layers.0.weight",
                "layers.1.bias",
                "layers.1.weight",
            ]
        }
    }
}

public enum PrimeTypedOptimizerWorkerRole:
    String,
    Codable,
    Equatable,
    Sendable
{
    case control
    case writer
    case restorer
}

public enum PrimeTypedOptimizerMissingGradientPolicy:
    String,
    Codable,
    Equatable,
    Sendable
{
    case reject
}

public struct PrimeTypedOptimizerConfiguration:
    Codable,
    Equatable,
    Sendable
{
    public let implementation: String
    public let learningRate: Float
    public let beta1: Float
    public let beta2: Float
    public let epsilon: Float
    public let weightDecay: Float
    public let biasCorrectionApplied: Bool

    public static let frozenAdamW = Self(
        implementation: "MLXOptimizers.AdamW",
        learningRate: 0.0001,
        beta1: 0.9,
        beta2: 0.999,
        epsilon: 1e-8,
        weightDecay: 0.01,
        biasCorrectionApplied: false
    )

    public init(
        implementation: String,
        learningRate: Float,
        beta1: Float,
        beta2: Float,
        epsilon: Float,
        weightDecay: Float,
        biasCorrectionApplied: Bool
    ) {
        self.implementation = implementation
        self.learningRate = learningRate
        self.beta1 = beta1
        self.beta2 = beta2
        self.epsilon = epsilon
        self.weightDecay = weightDecay
        self.biasCorrectionApplied =
            biasCorrectionApplied
    }
}

/// Frozen scope for a tiny first-party R&D feasibility experiment.
///
/// This declaration authorizes neither long training nor scientific, product,
/// safety, or policy authority. It binds the maintained AdamW implementation to
/// the minimal public typed-state transport patch under evaluation.
public struct PrimeTypedOptimizerRestorePlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let gateID: String
    public let researchAndDevelopmentOnly: Bool
    public let scientificAuthorityClaimAuthorized: Bool
    public let productPromotionAuthorized: Bool
    public let longTrainingAuthorized: Bool
    public let implementationLanguage:
        PrimeExecutionLanguage
    public let orchestrationLanguage:
        PrimeExecutionLanguage
    public let pythonExecutionAuthorized: Bool
    public let shellScientificAuthorityAuthorized: Bool
    public let upstreamRepository: String
    public let upstreamVersion: String
    public let upstreamBaseRevision: String
    public let firstPartyForkRepository: String
    public let firstPartyForkRevision: String
    public let packageResolvedCanonicalLocation: String
    public let mirrorConfigurationPath: String
    public let mirrorOriginalRepository: String
    public let mirrorTargetRepository: String
    public let typedStateSourcePath: String
    public let typedStateSourceSHA256: String
    public let optimizerSourcePath: String
    public let optimizerSourceSHA256: String
    public let dependencyLicenseSHA256: String
    public let configuration:
        PrimeTypedOptimizerConfiguration
    public let deviceType: String
    public let precision: PrimeNumericPrecision
    public let completedSteps: Int
    public let scheduleID: String
    public let firstBatchID: String
    public let secondBatchID: String
    public let initializationSeedDomain: String
    public let scheduleSeedDomain: String
    public let evaluationSeedDomain: String
    public let randomSamplingUsed: Bool
    public let missingGradientPolicy:
        PrimeTypedOptimizerMissingGradientPolicy
    public let frozenParameterPaths: [String]
    public let implementationDetailMutationAuthorized: Bool
    public let dummyOptimizerStepAuthorized: Bool
    public let reflectionAuthorized: Bool
    public let remoteReachabilityRequiredForLocalRAndD: Bool
    public let firstPartyForkRemoteStatus: String

    public static let frozenSchemaV2 = Self(
        schemaVersion: 2,
        gateID:
            "swift_typed_optimizer_restore_feasibility_v2",
        researchAndDevelopmentOnly: true,
        scientificAuthorityClaimAuthorized: false,
        productPromotionAuthorized: false,
        longTrainingAuthorized: false,
        implementationLanguage: .swift,
        orchestrationLanguage: .swift,
        pythonExecutionAuthorized: false,
        shellScientificAuthorityAuthorized: false,
        upstreamRepository:
            "https://github.com/ml-explore/mlx-swift",
        upstreamVersion: "0.31.3",
        upstreamBaseRevision:
            "61b9e011e09a62b489f6bd647958f1555bdf2896",
        firstPartyForkRepository:
            "https://github.com/Ergentics/ergentics-mlx-swift",
        firstPartyForkRevision:
            "68904d54b72871f26968261ae05d4fbb7c5e3142",
        packageResolvedCanonicalLocation:
            "https://github.com/ml-explore/mlx-swift",
        mirrorConfigurationPath:
            ".swiftpm/configuration/mirrors.json",
        mirrorOriginalRepository:
            "https://github.com/ml-explore/mlx-swift",
        mirrorTargetRepository:
            "https://github.com/Ergentics/ergentics-mlx-swift",
        typedStateSourcePath:
            "Source/MLXOptimizers/AdamOptimizerState.swift",
        typedStateSourceSHA256:
            "3ee01b6d2b84606258bbd6e1e913a6fbc09acec66e0a8bcb38fcc1f964868676",
        optimizerSourcePath:
            "Source/MLXOptimizers/Optimizers.swift",
        optimizerSourceSHA256:
            "f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d",
        dependencyLicenseSHA256:
            "44326a4ea062241ae6fc26ee2ec90bdc81af7eb7b9d3966181b733fa69d42057",
        configuration: .frozenAdamW,
        deviceType: "cpu",
        precision: .float32,
        completedSteps: 2,
        scheduleID: "constant_lr_0.0001_two_steps_v2",
        firstBatchID: "controlled_batch_alpha_v2",
        secondBatchID: "controlled_batch_beta_v2",
        initializationSeedDomain:
            "fixed_literal_initialization_v2",
        scheduleSeedDomain:
            "fixed_literal_schedule_v2",
        evaluationSeedDomain:
            "fixed_literal_evaluation_v2",
        randomSamplingUsed: false,
        missingGradientPolicy: .reject,
        frozenParameterPaths: [],
        implementationDetailMutationAuthorized: false,
        dummyOptimizerStepAuthorized: false,
        reflectionAuthorized: false,
        remoteReachabilityRequiredForLocalRAndD: false,
        firstPartyForkRemoteStatus:
            "private_remote_authenticated_fresh_clone_observed"
    )

    public init(
        schemaVersion: Int,
        gateID: String,
        researchAndDevelopmentOnly: Bool,
        scientificAuthorityClaimAuthorized: Bool,
        productPromotionAuthorized: Bool,
        longTrainingAuthorized: Bool,
        implementationLanguage:
            PrimeExecutionLanguage,
        orchestrationLanguage:
            PrimeExecutionLanguage,
        pythonExecutionAuthorized: Bool,
        shellScientificAuthorityAuthorized: Bool,
        upstreamRepository: String,
        upstreamVersion: String,
        upstreamBaseRevision: String,
        firstPartyForkRepository: String,
        firstPartyForkRevision: String,
        packageResolvedCanonicalLocation: String,
        mirrorConfigurationPath: String,
        mirrorOriginalRepository: String,
        mirrorTargetRepository: String,
        typedStateSourcePath: String,
        typedStateSourceSHA256: String,
        optimizerSourcePath: String,
        optimizerSourceSHA256: String,
        dependencyLicenseSHA256: String,
        configuration:
            PrimeTypedOptimizerConfiguration,
        deviceType: String,
        precision: PrimeNumericPrecision,
        completedSteps: Int,
        scheduleID: String,
        firstBatchID: String,
        secondBatchID: String,
        initializationSeedDomain: String,
        scheduleSeedDomain: String,
        evaluationSeedDomain: String,
        randomSamplingUsed: Bool,
        missingGradientPolicy:
            PrimeTypedOptimizerMissingGradientPolicy,
        frozenParameterPaths: [String],
        implementationDetailMutationAuthorized: Bool,
        dummyOptimizerStepAuthorized: Bool,
        reflectionAuthorized: Bool,
        remoteReachabilityRequiredForLocalRAndD: Bool,
        firstPartyForkRemoteStatus: String
    ) {
        self.schemaVersion = schemaVersion
        self.gateID = gateID
        self.researchAndDevelopmentOnly =
            researchAndDevelopmentOnly
        self.scientificAuthorityClaimAuthorized =
            scientificAuthorityClaimAuthorized
        self.productPromotionAuthorized =
            productPromotionAuthorized
        self.longTrainingAuthorized =
            longTrainingAuthorized
        self.implementationLanguage =
            implementationLanguage
        self.orchestrationLanguage =
            orchestrationLanguage
        self.pythonExecutionAuthorized =
            pythonExecutionAuthorized
        self.shellScientificAuthorityAuthorized =
            shellScientificAuthorityAuthorized
        self.upstreamRepository = upstreamRepository
        self.upstreamVersion = upstreamVersion
        self.upstreamBaseRevision =
            upstreamBaseRevision
        self.firstPartyForkRepository =
            firstPartyForkRepository
        self.firstPartyForkRevision =
            firstPartyForkRevision
        self.packageResolvedCanonicalLocation =
            packageResolvedCanonicalLocation
        self.mirrorConfigurationPath =
            mirrorConfigurationPath
        self.mirrorOriginalRepository =
            mirrorOriginalRepository
        self.mirrorTargetRepository =
            mirrorTargetRepository
        self.typedStateSourcePath =
            typedStateSourcePath
        self.typedStateSourceSHA256 =
            typedStateSourceSHA256
        self.optimizerSourcePath =
            optimizerSourcePath
        self.optimizerSourceSHA256 =
            optimizerSourceSHA256
        self.dependencyLicenseSHA256 =
            dependencyLicenseSHA256
        self.configuration = configuration
        self.deviceType = deviceType
        self.precision = precision
        self.completedSteps = completedSteps
        self.scheduleID = scheduleID
        self.firstBatchID = firstBatchID
        self.secondBatchID = secondBatchID
        self.initializationSeedDomain =
            initializationSeedDomain
        self.scheduleSeedDomain =
            scheduleSeedDomain
        self.evaluationSeedDomain =
            evaluationSeedDomain
        self.randomSamplingUsed = randomSamplingUsed
        self.missingGradientPolicy =
            missingGradientPolicy
        self.frozenParameterPaths =
            frozenParameterPaths
        self.implementationDetailMutationAuthorized =
            implementationDetailMutationAuthorized
        self.dummyOptimizerStepAuthorized =
            dummyOptimizerStepAuthorized
        self.reflectionAuthorized =
            reflectionAuthorized
        self.remoteReachabilityRequiredForLocalRAndD =
            remoteReachabilityRequiredForLocalRAndD
        self.firstPartyForkRemoteStatus =
            firstPartyForkRemoteStatus
    }

    public func validate() throws {
        guard self == .frozenSchemaV2 else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer restore must use the frozen schema-v2 first-party R&D plan"
                )
        }
    }

}

public enum PrimeTypedOptimizerTensorRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case loss
    case output
    case gradient
    case modelParameter = "model_parameter"
    case firstMoment = "first_moment"
    case secondMoment = "second_moment"

    fileprivate var order: Int {
        switch self {
        case .loss: 0
        case .output: 1
        case .gradient: 2
        case .modelParameter: 3
        case .firstMoment: 4
        case .secondMoment: 5
        }
    }

    fileprivate var isCheckpointTensor: Bool {
        switch self {
        case .modelParameter, .firstMoment, .secondMoment:
            true
        case .loss, .output, .gradient:
            false
        }
    }
}

/// One tensor identity plus the hash of its evaluated CPU FP32 logical bytes.
public struct PrimeTypedOptimizerTensorEntry:
    Codable,
    Equatable,
    Sendable
{
    public let fixture: PrimeTypedOptimizerFixture
    public let stepIndex: Int
    public let role: PrimeTypedOptimizerTensorRole
    public let path: String
    public let storageKey: String?
    public let dtype: String
    public let shape: [Int]
    public let byteCount: UInt64
    public let logicalSHA256: String

    public init(
        fixture: PrimeTypedOptimizerFixture,
        stepIndex: Int,
        role: PrimeTypedOptimizerTensorRole,
        path: String,
        storageKey: String?,
        dtype: String,
        shape: [Int],
        byteCount: UInt64,
        logicalSHA256: String
    ) {
        self.fixture = fixture
        self.stepIndex = stepIndex
        self.role = role
        self.path = path
        self.storageKey = storageKey
        self.dtype = dtype
        self.shape = shape
        self.byteCount = byteCount
        self.logicalSHA256 = logicalSHA256
    }

    fileprivate var identity: String {
        [
            fixture.rawValue,
            String(stepIndex),
            String(role.order),
            path,
        ].joined(separator: "\u{1f}")
    }

    fileprivate func validate() throws {
        guard stepIndex == 1 || stepIndex == 2,
              !path.isEmpty,
              path.utf8.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              }),
              dtype == "float32",
              shape.allSatisfy({ $0 > 0 }),
              Self.isSHA256(logicalSHA256)
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer tensor identity, dtype, shape, or hash is invalid"
                )
        }
        if role.isCheckpointTensor {
            guard let storageKey,
                  !storageKey.isEmpty else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "checkpoint tensor is missing a storage key"
                    )
            }
        } else {
            guard storageKey == nil else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "non-checkpoint evidence cannot claim a storage key"
                    )
            }
        }
        var elementCount: UInt64 = 1
        for dimension in shape {
            let product =
                elementCount.multipliedReportingOverflow(
                    by: UInt64(dimension)
                )
            guard !product.overflow else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "typed optimizer tensor shape overflows"
                    )
            }
            elementCount = product.partialValue
        }
        let bytes =
            elementCount.multipliedReportingOverflow(by: 4)
        guard !bytes.overflow,
              bytes.partialValue == byteCount else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer tensor byte count does not equal its FP32 shape"
                )
        }
    }

    private static func isSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy({
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            })
    }
}

public struct PrimeTypedOptimizerSemanticObservations:
    Codable,
    Equatable,
    Sendable
{
    public let cpuFP32Observed: Bool
    public let lossOutputAndGradientsFinite: Bool
    public let gradientPathsComplete: Bool
    public let everyGradientTensorContainsNonzero: Bool
    public let everyStepChangedModel: Bool
    public let everyStepChangedFirstMoment: Bool
    public let everyStepChangedSecondMoment: Bool

    public static let confirmed = Self(
        cpuFP32Observed: true,
        lossOutputAndGradientsFinite: true,
        gradientPathsComplete: true,
        everyGradientTensorContainsNonzero: true,
        everyStepChangedModel: true,
        everyStepChangedFirstMoment: true,
        everyStepChangedSecondMoment: true
    )

    public init(
        cpuFP32Observed: Bool,
        lossOutputAndGradientsFinite: Bool,
        gradientPathsComplete: Bool,
        everyGradientTensorContainsNonzero: Bool,
        everyStepChangedModel: Bool,
        everyStepChangedFirstMoment: Bool,
        everyStepChangedSecondMoment: Bool
    ) {
        self.cpuFP32Observed = cpuFP32Observed
        self.lossOutputAndGradientsFinite =
            lossOutputAndGradientsFinite
        self.gradientPathsComplete =
            gradientPathsComplete
        self.everyGradientTensorContainsNonzero =
            everyGradientTensorContainsNonzero
        self.everyStepChangedModel =
            everyStepChangedModel
        self.everyStepChangedFirstMoment =
            everyStepChangedFirstMoment
        self.everyStepChangedSecondMoment =
            everyStepChangedSecondMoment
    }
}

/// Canonically ordered evidence emitted by one fresh worker for one fixture.
///
/// Duplicate identities and duplicate checkpoint storage keys are rejected
/// while this value is still an ordered list, before a dictionary can erase
/// either defect.
public struct PrimeTypedOptimizerExecutionManifest:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let workerRole:
        PrimeTypedOptimizerWorkerRole
    public let fixture: PrimeTypedOptimizerFixture
    public let trainablePaths: [String]
    public let frozenPaths: [String]
    public let missingGradientPolicy:
        PrimeTypedOptimizerMissingGradientPolicy
    public let semanticObservations:
        PrimeTypedOptimizerSemanticObservations
    public let entries:
        [PrimeTypedOptimizerTensorEntry]

    public init(
        workerRole:
            PrimeTypedOptimizerWorkerRole,
        fixture: PrimeTypedOptimizerFixture,
        trainablePaths: [String],
        frozenPaths: [String],
        missingGradientPolicy:
            PrimeTypedOptimizerMissingGradientPolicy,
        semanticObservations:
            PrimeTypedOptimizerSemanticObservations,
        entries:
            [PrimeTypedOptimizerTensorEntry]
    ) {
        schemaVersion = 2
        artifactKind =
            "prime_typed_optimizer_execution_manifest"
        self.workerRole = workerRole
        self.fixture = fixture
        self.trainablePaths = trainablePaths
        self.frozenPaths = frozenPaths
        self.missingGradientPolicy =
            missingGradientPolicy
        self.semanticObservations =
            semanticObservations
        self.entries = entries
    }

    public func validate() throws {
        guard schemaVersion == 2,
              artifactKind
                == "prime_typed_optimizer_execution_manifest",
              trainablePaths
                == fixture.trainablePaths,
              frozenPaths.isEmpty,
              missingGradientPolicy == .reject,
              semanticObservations == .confirmed,
              !entries.isEmpty else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer manifest scope or trainable policy is invalid"
                )
        }

        var identities = Set<String>()
        var storageKeys = Set<String>()
        for entry in entries {
            try entry.validate()
            guard entry.fixture == fixture,
                  identities.insert(entry.identity)
                    .inserted else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "typed optimizer manifest contains a duplicate or cross-fixture tensor identity"
                    )
            }
            if let storageKey = entry.storageKey {
                let scoped =
                    "\(entry.stepIndex)\u{1f}\(storageKey)"
                guard storageKeys.insert(scoped)
                    .inserted else {
                    throw PrimeDurableArtifactError
                        .invalidSemantics(
                            "typed optimizer manifest contains a duplicate checkpoint storage key"
                        )
                }
            }
        }
        guard entries == entries.sorted(by: {
            $0.identity < $1.identity
        }) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer manifest is not canonically ordered"
                )
        }

        let expectedSteps: Set<Int>
        switch workerRole {
        case .control:
            expectedSteps = [1, 2]
        case .writer:
            expectedSteps = [1]
        case .restorer:
            expectedSteps = [1, 2]
        }
        guard Set(entries.map(\.stepIndex))
                == expectedSteps else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer worker emitted the wrong step set"
                )
        }

        let paths = Set(fixture.trainablePaths)
        for step in expectedSteps {
            let stepEntries = entries.filter {
                $0.stepIndex == step
            }
            let requiredRoles:
                Set<PrimeTypedOptimizerTensorRole>
            if workerRole == .restorer && step == 1 {
                requiredRoles = [
                    .modelParameter,
                    .firstMoment,
                    .secondMoment,
                ]
            } else {
                requiredRoles = Set(
                    PrimeTypedOptimizerTensorRole
                        .allCases
                )
            }
            guard Set(stepEntries.map(\.role))
                    == requiredRoles else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "typed optimizer step evidence is incomplete"
                    )
            }
            for role in requiredRoles {
                let rolePaths = Set(
                    stepEntries
                        .filter { $0.role == role }
                        .map(\.path)
                )
                switch role {
                case .loss:
                    guard rolePaths == ["loss"] else {
                        throw PrimeDurableArtifactError
                            .invalidSemantics(
                                "typed optimizer loss evidence is incomplete"
                            )
                    }
                case .output:
                    guard rolePaths == ["output"] else {
                        throw PrimeDurableArtifactError
                            .invalidSemantics(
                                "typed optimizer output evidence is incomplete"
                            )
                    }
                case .gradient, .modelParameter,
                        .firstMoment, .secondMoment:
                    guard rolePaths == paths else {
                        throw PrimeDurableArtifactError
                            .invalidSemantics(
                                "typed optimizer per-parameter evidence is incomplete"
                            )
                    }
                }
            }
        }
    }

}

public struct PrimeTypedOptimizerCheckpointBindings:
    Codable,
    Equatable,
    Sendable
{
    public let fixture: PrimeTypedOptimizerFixture
    public let model: PrimeArtifactBinding
    public let optimizerState: PrimeArtifactBinding

    public init(
        fixture: PrimeTypedOptimizerFixture,
        model: PrimeArtifactBinding,
        optimizerState: PrimeArtifactBinding
    ) {
        self.fixture = fixture
        self.model = model
        self.optimizerState = optimizerState
    }

    fileprivate func validate() throws {
        try model.validateDeclaration()
        try optimizerState.validateDeclaration()
        guard model.purpose == .immutableData,
              optimizerState.purpose
                == .immutableData else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer checkpoints must be immutable data"
                )
        }
    }
}

public struct PrimeTypedOptimizerSourceEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let packageManifest: PrimeArtifactBinding
    public let packageResolution: PrimeArtifactBinding
    public let mirrorConfiguration: PrimeArtifactBinding
    public let dependencyTreeManifest:
        PrimeArtifactBinding
    public let license: PrimeArtifactBinding
    public let typedStateSource: PrimeArtifactBinding
    public let optimizerSource: PrimeArtifactBinding

    public init(
        packageManifest: PrimeArtifactBinding,
        packageResolution: PrimeArtifactBinding,
        mirrorConfiguration: PrimeArtifactBinding,
        dependencyTreeManifest:
            PrimeArtifactBinding,
        license: PrimeArtifactBinding,
        typedStateSource: PrimeArtifactBinding,
        optimizerSource: PrimeArtifactBinding
    ) {
        self.packageManifest = packageManifest
        self.packageResolution = packageResolution
        self.mirrorConfiguration =
            mirrorConfiguration
        self.dependencyTreeManifest =
            dependencyTreeManifest
        self.license = license
        self.typedStateSource = typedStateSource
        self.optimizerSource = optimizerSource
    }

    public func validate() throws {
        let artifacts = [
            packageManifest,
            packageResolution,
            mirrorConfiguration,
            dependencyTreeManifest,
            license,
            typedStateSource,
            optimizerSource,
        ]
        for artifact in artifacts {
            try artifact.validateDeclaration()
        }
        guard artifacts.allSatisfy({
            $0.purpose == .immutableData
        }),
            packageManifest.relativePath
                == "content-staging/evidence/Package.swift",
            packageResolution.relativePath
                == "content-staging/evidence/Package.resolved",
            mirrorConfiguration.relativePath
                == "content-staging/evidence/mirrors.json",
            dependencyTreeManifest.relativePath
                == "content-staging/evidence/mlx-swift/dependency-source-tree.v1.json",
            license.relativePath
                == "content-staging/evidence/mlx-swift/LICENSE",
            typedStateSource.relativePath
                == "content-staging/evidence/mlx-swift/AdamOptimizerState.swift",
            optimizerSource.relativePath
                == "content-staging/evidence/mlx-swift/Optimizers.swift",
            license.sha256
                == PrimeTypedOptimizerRestorePlan
                    .frozenSchemaV2
                    .dependencyLicenseSHA256,
            typedStateSource.sha256
                == PrimeTypedOptimizerRestorePlan
                    .frozenSchemaV2
                    .typedStateSourceSHA256,
            optimizerSource.sha256
                == PrimeTypedOptimizerRestorePlan
                    .frozenSchemaV2
                    .optimizerSourceSHA256
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer dependency evidence path, purpose, or reviewed source hash is invalid"
                )
        }
    }

    fileprivate var artifacts:
        [PrimeArtifactBinding]
    {
        [
            packageManifest,
            packageResolution,
            mirrorConfiguration,
            dependencyTreeManifest,
            license,
            typedStateSource,
            optimizerSource,
        ]
    }
}

public struct PrimeTypedOptimizerWorkerRecord:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let role: PrimeTypedOptimizerWorkerRole
    public let processIdentifier: Int32
    public let executable: PrimeArtifactBinding
    public let plan: PrimeTypedOptimizerRestorePlan
    public let sourceEvidence:
        PrimeTypedOptimizerSourceEvidence
    public let manifests:
        [PrimeTypedOptimizerExecutionManifest]
    public let checkpoints:
        [PrimeTypedOptimizerCheckpointBindings]
    public let writerRecord: PrimeArtifactBinding?
    public let publicTypedRestoreAPIUsed: Bool
    public let implementationDetailMutationUsed: Bool
    public let dummyOptimizerStepUsed: Bool
    public let reflectionUsed: Bool

    public init(
        role: PrimeTypedOptimizerWorkerRole,
        processIdentifier: Int32,
        executable: PrimeArtifactBinding,
        sourceEvidence:
            PrimeTypedOptimizerSourceEvidence,
        manifests:
            [PrimeTypedOptimizerExecutionManifest],
        checkpoints:
            [PrimeTypedOptimizerCheckpointBindings] = [],
        writerRecord: PrimeArtifactBinding? = nil,
        publicTypedRestoreAPIUsed: Bool
    ) {
        schemaVersion = 2
        artifactKind =
            "prime_typed_optimizer_worker_record"
        self.role = role
        self.processIdentifier = processIdentifier
        self.executable = executable
        plan = .frozenSchemaV2
        self.sourceEvidence = sourceEvidence
        self.manifests = manifests
        self.checkpoints = checkpoints
        self.writerRecord = writerRecord
        self.publicTypedRestoreAPIUsed =
            publicTypedRestoreAPIUsed
        implementationDetailMutationUsed = false
        dummyOptimizerStepUsed = false
        reflectionUsed = false
    }

    public func validate() throws {
        guard schemaVersion == 2,
              artifactKind
                == "prime_typed_optimizer_worker_record",
              processIdentifier > 0,
              !implementationDetailMutationUsed,
              !dummyOptimizerStepUsed,
              !reflectionUsed else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer worker record contains invalid mechanics"
                )
        }
        try executable.validateDeclaration()
        guard executable.purpose == .executable else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer worker must bind its executable"
                )
        }
        try plan.validate()
        try sourceEvidence.validate()
        guard manifests.map(\.fixture)
                == PrimeTypedOptimizerFixture.allCases
                    .sorted(),
              manifests.allSatisfy({
                  $0.workerRole == role
              }) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer worker must contain both canonical fixtures"
                )
        }
        for manifest in manifests {
            try manifest.validate()
        }
        for checkpoint in checkpoints {
            try checkpoint.validate()
        }
        switch role {
        case .control:
            guard checkpoints.isEmpty,
                  writerRecord == nil,
                  !publicTypedRestoreAPIUsed else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "control worker claimed restore-only mechanics"
                    )
            }
        case .writer:
            guard checkpoints.map(\.fixture)
                    == PrimeTypedOptimizerFixture
                        .allCases.sorted(),
                  writerRecord == nil,
                  !publicTypedRestoreAPIUsed else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "writer worker checkpoint contract is invalid"
                    )
            }
        case .restorer:
            guard checkpoints.isEmpty,
                  let writerRecord,
                  writerRecord.purpose
                    == .immutableData,
                  publicTypedRestoreAPIUsed else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "restorer must bind the writer and use the public typed restore API"
                    )
            }
            try writerRecord.validateDeclaration()
        }
    }
}

/// EnginePropose/Derive/Dispose cases for structural state-transport defects.
///
/// These are adversarial contract cases, not independent scientific oracles.
public enum PrimeTypedOptimizerRestoreMutation:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case missingEntry = "missing_entry"
    case extraEntry = "extra_entry"
    case duplicateEntry = "duplicate_entry"
    case momentsSwapped = "moments_swapped"
    case sameShapePathSwap = "same_shape_path_swap"
    case shapeMismatch = "shape_mismatch"
    case dtypeMismatch = "dtype_mismatch"
    case optimizerConfigurationMismatch =
        "optimizer_configuration_mismatch"
    case forkRevisionMismatch = "fork_revision_mismatch"
    case stepMismatch = "step_mismatch"
    case scheduleMismatch = "schedule_mismatch"
    case batchMismatch = "batch_mismatch"
    case seedDomainMismatch =
        "seed_domain_mismatch"
    case orderPermutation = "order_permutation"
    case byteTamper = "byte_tamper"
    case aliasing = "aliasing"
    case trainablePolicyMismatch =
        "trainable_policy_mismatch"
    case frozenPolicyMismatch =
        "frozen_policy_mismatch"
    case missingGradientPolicyMismatch =
        "missing_gradient_policy_mismatch"

    public var detectorID: String {
        switch self {
        case .missingEntry, .extraEntry,
                .shapeMismatch, .dtypeMismatch:
            "public_typed_import_rejection"
        case .momentsSwapped,
                .sameShapePathSwap:
            "exact_continuation_divergence"
        case .duplicateEntry,
                .orderPermutation,
                .trainablePolicyMismatch,
                .frozenPolicyMismatch,
                .missingGradientPolicyMismatch:
            "ordered_manifest_rejection"
        case .optimizerConfigurationMismatch,
                .forkRevisionMismatch,
                .stepMismatch,
                .scheduleMismatch,
                .batchMismatch,
                .seedDomainMismatch:
            "frozen_plan_rejection"
        case .byteTamper:
            "checkpoint_logical_hash_rejection"
        case .aliasing:
            "public_state_alias_isolation"
        }
    }
}

public struct PrimeTypedOptimizerMutationDisposition:
    Codable,
    Equatable,
    Sendable
{
    public let mutation:
        PrimeTypedOptimizerRestoreMutation
    public let detectorID: String
    public let proposedEvidenceSHA256: String
    public let detectorEvidenceSHA256: String
    public let proposalMaterialized: Bool
    public let detectorExecuted: Bool
    public let independentScientificOracleClaimed:
        Bool
    public let disposed: Bool
    public let reason: String

    public init(
        mutation:
            PrimeTypedOptimizerRestoreMutation,
        detectorID: String,
        proposedEvidenceSHA256: String,
        detectorEvidenceSHA256: String,
        proposalMaterialized: Bool,
        detectorExecuted: Bool,
        independentScientificOracleClaimed:
            Bool,
        disposed: Bool,
        reason: String
    ) {
        self.mutation = mutation
        self.detectorID = detectorID
        self.proposedEvidenceSHA256 =
            proposedEvidenceSHA256
        self.detectorEvidenceSHA256 =
            detectorEvidenceSHA256
        self.proposalMaterialized =
            proposalMaterialized
        self.detectorExecuted =
            detectorExecuted
        self.independentScientificOracleClaimed =
            independentScientificOracleClaimed
        self.disposed = disposed
        self.reason = reason
    }
}

private struct PrimeTypedOptimizerResolvedFile:
    Decodable
{
    struct Pin: Decodable {
        struct State: Decodable {
            let revision: String
        }

        let identity: String
        let kind: String
        let location: String
        let state: State
    }

    let pins: [Pin]
}

private struct PrimeTypedOptimizerMirrorFile:
    Decodable,
    Equatable
{
    struct Entry: Decodable, Equatable {
        let mirror: String
        let original: String
    }

    let object: [Entry]
    let version: Int
}

public enum PrimeTypedOptimizerRestoreOutcome:
    String,
    Codable,
    Equatable,
    Sendable
{
    case exactTypedRestore = "exact_typed_restore"
    case abstain
}

public enum PrimeTypedOptimizerFailureStage:
    String,
    Codable,
    Sendable
{
    case preflight
    case staging
    case control
    case writer
    case restorer
    case mutationSweep = "mutation_sweep"
    case finalValidation = "final_validation"
}

/// Durable failure truth is deliberately separate from the exact-success
/// receipt. It records no raw error text and cannot be interpreted as a
/// partially grounded restore result.
public struct PrimeTypedOptimizerRestoreFailureReceipt:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome:
        PrimeTypedOptimizerRestoreOutcome
    public let recordedAtUTC: String
    public let plan: PrimeTypedOptimizerRestorePlan
    public let stage:
        PrimeTypedOptimizerFailureStage
    public let reasonCode: String
    public let failureDetailSHA256: String
    public let availableArtifacts:
        [PrimeArtifactBinding]
    public let scientificAuthorityClaimed: Bool
    public let productPromotionClaimed: Bool
    public let longTrainingPerformed: Bool

    public init(
        recordedAtUTC: String,
        stage: PrimeTypedOptimizerFailureStage,
        reasonCode: String,
        failureDetailSHA256: String,
        availableArtifacts:
            [PrimeArtifactBinding]
    ) {
        schemaVersion = 2
        artifactKind =
            "prime_typed_optimizer_restore_failure_receipt"
        outcome = .abstain
        self.recordedAtUTC = recordedAtUTC
        plan = .frozenSchemaV2
        self.stage = stage
        self.reasonCode = reasonCode
        self.failureDetailSHA256 =
            failureDetailSHA256
        self.availableArtifacts =
            availableArtifacts
        scientificAuthorityClaimed = false
        productPromotionClaimed = false
        longTrainingPerformed = false
    }

    func validateStructure() throws {
        guard schemaVersion == 2,
              artifactKind
                == "prime_typed_optimizer_restore_failure_receipt",
              outcome == .abstain,
              ISO8601DateFormatter()
                .date(from: recordedAtUTC) != nil,
              !reasonCode.isEmpty,
              reasonCode.utf8.count <= 128,
              reasonCode.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57)
                      || ($0 >= 65 && $0 <= 90)
                      || ($0 >= 97 && $0 <= 122)
                      || $0 == 45 || $0 == 46
                      || $0 == 95
              }),
              failureDetailSHA256.utf8.count
                == 64,
              failureDetailSHA256.utf8
                .allSatisfy({
                    ($0 >= 48 && $0 <= 57)
                        || ($0 >= 97 && $0 <= 102)
                }),
              availableArtifacts.map(
                  \.relativePath
              ) == availableArtifacts.map(
                  \.relativePath
              ).sorted(),
              Set(
                  availableArtifacts.map(
                      \.relativePath
                  )
              ).count == availableArtifacts.count,
              !scientificAuthorityClaimed,
              !productPromotionClaimed,
              !longTrainingPerformed else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer failure receipt is invalid"
                )
        }
        try plan.validate()
        for artifact in availableArtifacts {
            try artifact.validateDeclaration()
        }
    }

    public func validate(
        in root: PrimeArtifactRoot
    ) throws {
        try validateStructure()
        for artifact in availableArtifacts {
            _ = try root.verify(artifact)
        }
    }
}

public struct PrimeTypedOptimizerBoundedOutputObservation:
    Codable,
    Equatable,
    Sendable
{
    public static let frozenMaximumBytesPerStream:
        UInt64 = 65_536

    public let maximumBytesPerStream: UInt64
    public let standardOutputByteCount: UInt64
    public let standardOutputSHA256: String
    public let standardErrorByteCount: UInt64
    public let standardErrorSHA256: String
    public let overflowed: Bool
    public let drainCompleted: Bool

    public init(
        maximumBytesPerStream: UInt64,
        standardOutputByteCount: UInt64,
        standardOutputSHA256: String,
        standardErrorByteCount: UInt64,
        standardErrorSHA256: String,
        overflowed: Bool,
        drainCompleted: Bool
    ) {
        self.maximumBytesPerStream =
            maximumBytesPerStream
        self.standardOutputByteCount =
            standardOutputByteCount
        self.standardOutputSHA256 =
            standardOutputSHA256
        self.standardErrorByteCount =
            standardErrorByteCount
        self.standardErrorSHA256 =
            standardErrorSHA256
        self.overflowed = overflowed
        self.drainCompleted = drainCompleted
    }

    public static let emptySuccess = Self(
        maximumBytesPerStream:
            frozenMaximumBytesPerStream,
        standardOutputByteCount: 0,
        standardOutputSHA256:
            PrimeSHA256.hexDigest(of: Data()),
        standardErrorByteCount: 0,
        standardErrorSHA256:
            PrimeSHA256.hexDigest(of: Data()),
        overflowed: false,
        drainCompleted: true
    )

    fileprivate func validateSuccess()
        throws
    {
        guard self == .emptySuccess else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer worker output was not empty, bounded, and completely drained"
                )
        }
    }
}

public struct PrimeTypedOptimizerProcessObservation:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeTypedOptimizerWorkerRole
    public let processIdentifier: Int32
    public let terminationReason: String
    public let terminationStatus: Int32
    public let workerEnvironmentKeyCount: Int
    public let standardInputClosed: Bool
    public let boundedOutput:
        PrimeTypedOptimizerBoundedOutputObservation
    public let record: PrimeArtifactBinding

    public init(
        role: PrimeTypedOptimizerWorkerRole,
        processIdentifier: Int32,
        terminationReason: String,
        terminationStatus: Int32,
        workerEnvironmentKeyCount: Int,
        standardInputClosed: Bool,
        boundedOutput:
            PrimeTypedOptimizerBoundedOutputObservation,
        record: PrimeArtifactBinding
    ) {
        self.role = role
        self.processIdentifier = processIdentifier
        self.terminationReason = terminationReason
        self.terminationStatus = terminationStatus
        self.workerEnvironmentKeyCount =
            workerEnvironmentKeyCount
        self.standardInputClosed =
            standardInputClosed
        self.boundedOutput = boundedOutput
        self.record = record
    }

    fileprivate func validate() throws {
        try record.validateDeclaration()
        try boundedOutput.validateSuccess()
        guard processIdentifier > 0,
              terminationReason == "exit",
              terminationStatus == 0,
              workerEnvironmentKeyCount == 0,
              standardInputClosed,
              record.purpose == .immutableData else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer supervisor did not observe one clean worker exit"
                )
        }
    }
}

public struct PrimeTypedOptimizerRestoreReceipt:
    Codable,
    Equatable,
    Sendable
{
    public static let requiredPrimeSourceRelativePaths:
        Set<String> = [
            "Sources/PrimeCore/PrimeTypedOptimizerDependencyTree.swift",
            "Sources/PrimeCore/PrimeTypedOptimizerRestoreContract.swift",
            "Sources/PrimeTypedOptimizerRestoreMechanics/PrimeTypedOptimizerRestoreMechanics.swift",
            "Sources/PrimeTypedOptimizerRestoreProbe/PrimeTypedOptimizerRestoreProbeMain.swift",
        ]

    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome:
        PrimeTypedOptimizerRestoreOutcome
    public let recordedAtUTC: String
    public let plan: PrimeTypedOptimizerRestorePlan
    public let primeSourceSnapshot: PrimeArtifactBinding
    public let runtimeImage:
        PrimePinnedMLXMetallibBinding
    public let controlRecord: PrimeArtifactBinding
    public let writerRecord: PrimeArtifactBinding
    public let restorerRecord: PrimeArtifactBinding
    public let workers:
        [PrimeTypedOptimizerWorkerRecord]
    public let processTranscript:
        [PrimeTypedOptimizerProcessObservation]
    public let mutationSweep:
        [PrimeTypedOptimizerMutationDisposition]
    public let scientificAuthorityClaimed: Bool
    public let productPromotionClaimed: Bool
    public let longTrainingPerformed: Bool

    public init(
        outcome:
            PrimeTypedOptimizerRestoreOutcome,
        recordedAtUTC: String,
        primeSourceSnapshot: PrimeArtifactBinding,
        runtimeImage:
            PrimePinnedMLXMetallibBinding,
        controlRecord: PrimeArtifactBinding,
        writerRecord: PrimeArtifactBinding,
        restorerRecord: PrimeArtifactBinding,
        workers:
            [PrimeTypedOptimizerWorkerRecord],
        processTranscript:
            [PrimeTypedOptimizerProcessObservation],
        mutationSweep:
            [PrimeTypedOptimizerMutationDisposition]
    ) {
        schemaVersion = 2
        artifactKind =
            "prime_typed_optimizer_restore_receipt"
        self.outcome = outcome
        self.recordedAtUTC = recordedAtUTC
        plan = .frozenSchemaV2
        self.primeSourceSnapshot =
            primeSourceSnapshot
        self.runtimeImage = runtimeImage
        self.controlRecord = controlRecord
        self.writerRecord = writerRecord
        self.restorerRecord = restorerRecord
        self.workers = workers
        self.processTranscript =
            processTranscript
        self.mutationSweep = mutationSweep
        scientificAuthorityClaimed = false
        productPromotionClaimed = false
        longTrainingPerformed = false
    }

    func validateStructure() throws {
        guard schemaVersion == 2,
              artifactKind
                == "prime_typed_optimizer_restore_receipt",
              outcome == .exactTypedRestore,
              ISO8601DateFormatter()
                .date(from: recordedAtUTC) != nil,
              !scientificAuthorityClaimed,
              !productPromotionClaimed,
              !longTrainingPerformed else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer receipt scope or outcome is invalid"
                )
        }
        try plan.validate()
        try primeSourceSnapshot.validateDeclaration()
        try runtimeImage.validateDeclaration()
        try PrimeMLXRuntimeImageLayout.require(
            runtimeImage.runtimeImageLayout,
            for: .typedOptimizerRestoreProbe
        )
        try controlRecord.validateDeclaration()
        try writerRecord.validateDeclaration()
        try restorerRecord.validateDeclaration()
        guard [controlRecord, writerRecord, restorerRecord]
                .allSatisfy({
                    $0.purpose == .immutableData
                }),
              workers.map(\.role)
                == [.control, .writer, .restorer] else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer receipt worker order is invalid"
                )
        }
        for worker in workers {
            try worker.validate()
        }
        guard processTranscript.map(\.role)
                == [.control, .writer, .restorer]
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer process transcript role order is invalid"
                )
        }
        for observation in processTranscript {
            try observation.validate()
        }
        guard processTranscript.map(
            \.processIdentifier
        ) == workers.map(\.processIdentifier),
            processTranscript.map(\.record)
                == [
                    controlRecord,
                    writerRecord,
                    restorerRecord,
                ]
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer process transcript does not bind the worker records"
                )
        }
        guard Set(workers.map(\.processIdentifier))
                .count == workers.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer workers were not fresh processes"
                )
        }

        let control = workers[0]
        let writer = workers[1]
        let restorer = workers[2]
        guard restorer.writerRecord == writerRecord,
              primeSourceSnapshot.purpose
                == .immutableData,
              control.executable == writer.executable,
              writer.executable == restorer.executable,
              control.sourceEvidence
                == writer.sourceEvidence,
              writer.sourceEvidence
                == restorer.sourceEvidence
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer worker provenance diverged"
                )
        }
        for fixture in
            PrimeTypedOptimizerFixture.allCases
        {
            let controlManifest =
                control.manifests.first {
                    $0.fixture == fixture
                }!
            let writerManifest =
                writer.manifests.first {
                    $0.fixture == fixture
                }!
            let restorerManifest =
                restorer.manifests.first {
                    $0.fixture == fixture
                }!

            let controlN = controlManifest.entries
                .filter { $0.stepIndex == 1 }
            guard controlN
                    == writerManifest.entries else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "writer trajectory differs from the fresh control at N"
                    )
            }
            let controlNState = controlN.filter {
                $0.role == .modelParameter
                    || $0.role == .firstMoment
                    || $0.role == .secondMoment
            }
            let restoredN = restorerManifest.entries
                .filter { $0.stepIndex == 1 }
            guard controlNState == restoredN else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "typed optimizer import differs from the control at N"
                    )
            }
            let controlNPlusOne =
                controlManifest.entries.filter {
                    $0.stepIndex == 2
                }
            let restoredNPlusOne =
                restorerManifest.entries.filter {
                    $0.stepIndex == 2
                }
            guard controlNPlusOne
                    == restoredNPlusOne else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "typed optimizer continuation differs from the control at N+1"
                    )
            }
            try Self.requireNondegenerateTrajectory(
                controlManifest
            )
            try Self.requireNondegenerateTrajectory(
                restorerManifest
            )
        }

        guard mutationSweep.map(\.mutation)
                == PrimeTypedOptimizerRestoreMutation
                    .allCases,
              mutationSweep.allSatisfy({
                  $0.proposalMaterialized
                      && $0.detectorExecuted
                      && !$0
                        .independentScientificOracleClaimed
                      && $0.disposed
                      && $0.detectorID
                        == $0.mutation.detectorID
                      && Self.isSHA256(
                          $0.proposedEvidenceSHA256
                      )
                      && Self.isSHA256(
                          $0.detectorEvidenceSHA256
                      )
                      && $0.proposedEvidenceSHA256
                        != $0.detectorEvidenceSHA256
                      && !$0.reason.isEmpty
              }),
              Set(
                  mutationSweep.map(
                      \.proposedEvidenceSHA256
                  )
              ).count == mutationSweep.count,
              Set(
                  mutationSweep.map(
                      \.detectorEvidenceSHA256
                  )
              ).count == mutationSweep.count
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer mutation sweep did not dispose every declared case"
                )
        }

    }

    /// Authoritative exact-success validation. A root is mandatory so a
    /// structurally plausible receipt can never promote itself without live
    /// reads of every artifact bound by this receipt.
    public func validate(
        in root: PrimeArtifactRoot
    ) throws {
        try validateStructure()

        let decoded = [
            try root.decodeVerified(
                PrimeTypedOptimizerWorkerRecord.self,
                binding: controlRecord
            ),
            try root.decodeVerified(
                PrimeTypedOptimizerWorkerRecord.self,
                binding: writerRecord
            ),
            try root.decodeVerified(
                PrimeTypedOptimizerWorkerRecord.self,
                binding: restorerRecord
            ),
        ]
        guard decoded == workers else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer worker artifacts differ from the receipt"
                )
        }

        _ = try root.verify(primeSourceSnapshot)
        let snapshot = try root.decodeVerified(
            PrimeSwiftSourceSnapshot.self,
            binding: primeSourceSnapshot,
            maximumByteCount: 128 * 1024 * 1024
        )
        try PrimeSwiftSourceProvenance.validate(
            snapshot,
            requiredRelativePaths:
                Self.requiredPrimeSourceRelativePaths
        )
        let sourceFiles = Dictionary(
            uniqueKeysWithValues:
                snapshot.files.map {
                    ($0.relativePath, $0)
                }
        )

        _ = try root.verify(runtimeImage.artifact)
        _ = try root.verify(
            runtimeImage.infoPlistArtifact
        )
        _ = try root.verify(workers[0].executable)

        let sourceEvidence =
            workers[0].sourceEvidence
        for binding in sourceEvidence.artifacts {
            _ = try root.verify(binding)
        }
        for (relativePath, binding) in [
            (
                "Package.swift",
                sourceEvidence.packageManifest
            ),
            (
                "Package.resolved",
                sourceEvidence.packageResolution
            ),
            (
                PrimeTypedOptimizerRestorePlan
                    .frozenSchemaV2
                    .mirrorConfigurationPath,
                sourceEvidence.mirrorConfiguration
            ),
        ] {
            guard let sourceFile =
                    sourceFiles[relativePath],
                  sourceFile.sha256
                    == binding.sha256,
                  sourceFile.byteCount
                    == binding.byteCount else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "typed optimizer source evidence differs from the bound Prime source snapshot at \(relativePath)"
                    )
            }
        }
        try Self.validateDependencySemantics(
            sourceEvidence,
            in: root
        )

        let checkpoints =
            workers[1].checkpoints
        let checkpointArtifacts =
            checkpoints.flatMap {
                [$0.model, $0.optimizerState]
            }
        guard Set(
            checkpointArtifacts.map(\.relativePath)
        ).count == checkpointArtifacts.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer checkpoint paths are not unique"
                )
        }
        for binding in checkpointArtifacts {
            _ = try root.verify(binding)
        }
    }

    private static func validateDependencySemantics(
        _ evidence:
            PrimeTypedOptimizerSourceEvidence,
        in root: PrimeArtifactRoot
    ) throws {
        let plan =
            PrimeTypedOptimizerRestorePlan
                .frozenSchemaV2
        let packageData = try root.readVerified(
            evidence.packageManifest,
            maximumByteCount: 1024 * 1024
        )
        guard let packageText = String(
            data: packageData,
            encoding: .utf8
        ),
            occurrences(
                of: plan.firstPartyForkRepository,
                in: packageText
            ) == 1,
            occurrences(
                of: plan.firstPartyForkRevision,
                in: packageText
            ) == 1
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "Package.swift does not bind the exact first-party fork URL and revision once"
                )
        }

        let resolved = try JSONDecoder().decode(
            PrimeTypedOptimizerResolvedFile.self,
            from: root.readVerified(
                evidence.packageResolution,
                maximumByteCount: 1024 * 1024
            )
        )
        let matchingPins = resolved.pins.filter {
            $0.identity
                == PrimeTypedOptimizerDependencyTree
                .swiftPackageIdentity
        }
        guard matchingPins.count == 1,
              matchingPins[0].kind
                == "remoteSourceControl",
              matchingPins[0].location
                == plan
                .packageResolvedCanonicalLocation,
              matchingPins[0].state.revision
                == plan.firstPartyForkRevision else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "Package.resolved does not bind the frozen Swift package identity to the first-party revision"
                )
        }

        let mirror = try JSONDecoder().decode(
            PrimeTypedOptimizerMirrorFile.self,
            from: root.readVerified(
                evidence.mirrorConfiguration,
                maximumByteCount: 1024 * 1024
            )
        )
        let expectedMirror =
            PrimeTypedOptimizerMirrorFile(
                object: [
                    .init(
                        mirror:
                            plan.mirrorTargetRepository,
                        original:
                            plan.mirrorOriginalRepository
                    ),
                ],
                version: 1
            )
        guard mirror == expectedMirror else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "SwiftPM mirror configuration does not exactly route upstream mlx-swift to the first-party fork"
                )
        }

        let dependencyTree =
            try root.decodeVerified(
                PrimeTypedOptimizerDependencyTreeEvidence
                    .self,
                binding:
                    evidence
                    .dependencyTreeManifest,
                maximumByteCount:
                    4 * 1024 * 1024
            )
        try PrimeTypedOptimizerDependencyTree
            .validateFrozen(dependencyTree)
    }

    private static func occurrences(
        of needle: String,
        in haystack: String
    ) -> Int {
        guard !needle.isEmpty else {
            return 0
        }
        return haystack.components(
            separatedBy: needle
        ).count - 1
    }

    private static func isSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy({
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            })
    }

    private static func requireNondegenerateTrajectory(
        _ manifest:
            PrimeTypedOptimizerExecutionManifest
    ) throws {
        let first = manifest.entries.filter {
            $0.stepIndex == 1
        }
        let second = manifest.entries.filter {
            $0.stepIndex == 2
        }
        guard !first.isEmpty,
              !second.isEmpty,
              Set(manifest.entries.map(\.logicalSHA256))
                .count > 3 else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer trajectory contains degenerate evidence"
                )
        }
        for role:
            PrimeTypedOptimizerTensorRole in [
                .modelParameter,
                .firstMoment,
                .secondMoment,
            ]
        {
            let firstHashes = Dictionary(
                uniqueKeysWithValues: first
                    .filter { $0.role == role }
                    .map {
                        ($0.path, $0.logicalSHA256)
                    }
            )
            let secondHashes = Dictionary(
                uniqueKeysWithValues: second
                    .filter { $0.role == role }
                    .map {
                        ($0.path, $0.logicalSHA256)
                    }
            )
            guard Set(firstHashes.keys)
                    == Set(secondHashes.keys),
                  firstHashes.keys.allSatisfy({
                      firstHashes[$0]
                        != secondHashes[$0]
                  }) else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "typed optimizer model or moment state did not change across N and N+1"
                )
            }
        }
        // A restorer has no authority to recreate the already-observed N
        // loss/output/gradient values after loading N state. Those values are
        // independently exact between control and writer; the restorer proves
        // state at N and the complete step at N+1.
        if manifest.workerRole == .restorer {
            return
        }
        for role:
            PrimeTypedOptimizerTensorRole in [
                .loss,
                .output,
            ]
        {
            let firstHash = first.first {
                $0.role == role
            }?.logicalSHA256
            let secondHash = second.first {
                $0.role == role
            }?.logicalSHA256
            guard let firstHash,
                  let secondHash,
                  firstHash != secondHash else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "typed optimizer loss or output evidence did not change across batches"
                    )
            }
        }
        let firstGradients = first.filter {
            $0.role == .gradient
        }
        let secondGradients = second.filter {
            $0.role == .gradient
        }
        let secondByPath = Dictionary(
            uniqueKeysWithValues:
                secondGradients.map {
                    ($0.path, $0.logicalSHA256)
                }
        )
        guard firstGradients.contains(where: {
            secondByPath[$0.path]
                != $0.logicalSHA256
        }) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "typed optimizer gradients did not change across batches"
                )
        }
    }
}
