import Foundation

/// The only optimizer configuration admitted by the first native optimizer
/// restore feasibility gate.
///
/// This is intentionally a stock maintained `MLXOptimizers.AdamW`
/// configuration. Prime does not reproduce AdamW update math and does not
/// permit an implementation-detail state mutation to masquerade as supported
/// optimizer restore.
public struct PrimeOptimizerRestorePlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let gateID: String
    public let implementationLanguage:
        PrimeExecutionLanguage
    public let orchestrationLanguage:
        PrimeExecutionLanguage
    public let pythonExecutionAuthorized: Bool
    public let shellScientificAuthorityAuthorized: Bool
    public let mlxSwiftRepository: String
    public let mlxSwiftVersion: String
    public let mlxSwiftRevision: String
    public let optimizerImplementation: String
    public let learningRate: Double
    public let beta1: Double
    public let beta2: Double
    public let epsilon: Double
    public let weightDecay: Double
    public let biasCorrectionApplied: Bool
    public let checkpointFormat: String
    public let modelImplementation: String
    public let precision: PrimeNumericPrecision
    public let inputFeatures: Int
    public let outputFeatures: Int
    public let includesBias: Bool
    public let deviceType: String
    public let optimizerSteps: Int
    public let distinctWriterVerifierRequired: Bool
    public let supportedTypedRestoreRequired: Bool
    public let implementationDetailMutationAuthorized: Bool

    public static let frozenAdamW0313 = Self(
        schemaVersion: 1,
        gateID:
            "swift_exact_optimizer_state_restore_feasibility_v1",
        implementationLanguage: .swift,
        orchestrationLanguage: .swift,
        pythonExecutionAuthorized: false,
        shellScientificAuthorityAuthorized: false,
        mlxSwiftRepository:
            "https://github.com/ml-explore/mlx-swift",
        mlxSwiftVersion: "0.31.3",
        mlxSwiftRevision:
            "61b9e011e09a62b489f6bd647958f1555bdf2896",
        optimizerImplementation:
            "MLXOptimizers.AdamW",
        learningRate: 0.0001,
        beta1: 0.9,
        beta2: 0.999,
        epsilon: 1e-8,
        weightDecay: 0.01,
        biasCorrectionApplied: false,
        checkpointFormat: "safetensors",
        modelImplementation: "MLXNN.Linear",
        precision: .float32,
        inputFeatures: 2,
        outputFeatures: 2,
        includesBias: true,
        deviceType: "cpu",
        optimizerSteps: 1,
        distinctWriterVerifierRequired: true,
        supportedTypedRestoreRequired: true,
        implementationDetailMutationAuthorized: false
    )

    public init(
        schemaVersion: Int,
        gateID: String,
        implementationLanguage:
            PrimeExecutionLanguage,
        orchestrationLanguage:
            PrimeExecutionLanguage,
        pythonExecutionAuthorized: Bool,
        shellScientificAuthorityAuthorized: Bool,
        mlxSwiftRepository: String,
        mlxSwiftVersion: String,
        mlxSwiftRevision: String,
        optimizerImplementation: String,
        learningRate: Double,
        beta1: Double,
        beta2: Double,
        epsilon: Double,
        weightDecay: Double,
        biasCorrectionApplied: Bool,
        checkpointFormat: String,
        modelImplementation: String,
        precision: PrimeNumericPrecision,
        inputFeatures: Int,
        outputFeatures: Int,
        includesBias: Bool,
        deviceType: String,
        optimizerSteps: Int,
        distinctWriterVerifierRequired: Bool,
        supportedTypedRestoreRequired: Bool,
        implementationDetailMutationAuthorized: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.gateID = gateID
        self.implementationLanguage =
            implementationLanguage
        self.orchestrationLanguage =
            orchestrationLanguage
        self.pythonExecutionAuthorized =
            pythonExecutionAuthorized
        self.shellScientificAuthorityAuthorized =
            shellScientificAuthorityAuthorized
        self.mlxSwiftRepository = mlxSwiftRepository
        self.mlxSwiftVersion = mlxSwiftVersion
        self.mlxSwiftRevision = mlxSwiftRevision
        self.optimizerImplementation =
            optimizerImplementation
        self.learningRate = learningRate
        self.beta1 = beta1
        self.beta2 = beta2
        self.epsilon = epsilon
        self.weightDecay = weightDecay
        self.biasCorrectionApplied =
            biasCorrectionApplied
        self.checkpointFormat = checkpointFormat
        self.modelImplementation = modelImplementation
        self.precision = precision
        self.inputFeatures = inputFeatures
        self.outputFeatures = outputFeatures
        self.includesBias = includesBias
        self.deviceType = deviceType
        self.optimizerSteps = optimizerSteps
        self.distinctWriterVerifierRequired =
            distinctWriterVerifierRequired
        self.supportedTypedRestoreRequired =
            supportedTypedRestoreRequired
        self.implementationDetailMutationAuthorized =
            implementationDetailMutationAuthorized
    }

    public func validate() throws {
        guard self == .frozenAdamW0313 else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore must use the frozen stock mlx-swift 0.31.3 AdamW plan"
                )
        }
    }
}

/// One exact source file and the public API claims extracted from it.
///
/// `repositoryRelativePath` identifies the reviewed upstream source. The
/// immutable artifact binds the exact reviewed bytes copied into the evidence
/// package. API declarations are frozen strings rather than inferred claims.
public struct PrimeOptimizerRestoreSourceAPIBinding:
    Codable,
    Equatable,
    Sendable
{
    public let repositoryRelativePath: String
    public let apiDeclarations: [String]
    public let sourceArtifact: PrimeArtifactBinding

    public init(
        repositoryRelativePath: String,
        apiDeclarations: [String],
        sourceArtifact: PrimeArtifactBinding
    ) {
        self.repositoryRelativePath =
            repositoryRelativePath
        self.apiDeclarations = apiDeclarations
        self.sourceArtifact = sourceArtifact
    }

    fileprivate func validateDeclaration() throws {
        guard !repositoryRelativePath.isEmpty,
              !apiDeclarations.isEmpty,
              apiDeclarations.allSatisfy({
                  !$0.trimmingCharacters(
                      in: .whitespacesAndNewlines
                  ).isEmpty
              }),
              Set(apiDeclarations).count
                == apiDeclarations.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "source/API evidence must bind one path to unique nonempty API declarations"
                )
        }
        try sourceArtifact.validateDeclaration()
        guard sourceArtifact.purpose == .immutableData else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "source/API evidence must be immutable data"
                )
        }
    }
}

/// Exact pinned dependency and source/API evidence reviewed for the gate.
public struct PrimeOptimizerRestoreSourceEvidence:
    Codable,
    Equatable,
    Sendable
{
    public let dependencyResolution:
        PrimeArtifactBinding
    public let licenseArtifact: PrimeArtifactBinding
    public let optimizer:
        PrimeOptimizerRestoreSourceAPIBinding
    public let updatableProtocol:
        PrimeOptimizerRestoreSourceAPIBinding
    public let arrayMutation:
        PrimeOptimizerRestoreSourceAPIBinding
    public let nestedStructure:
        PrimeOptimizerRestoreSourceAPIBinding
    public let tensorIO:
        PrimeOptimizerRestoreSourceAPIBinding
    public let moduleRestore:
        PrimeOptimizerRestoreSourceAPIBinding
    public let typedOptimizerRestoreAPIDeclared: Bool
    public let implementationDetailMutationWarning: String

    public static let frozenMLXSwift0313 = Self(
        dependencyResolution: PrimeArtifactBinding(
            relativePath: "evidence/Package.resolved",
            sha256:
                "d72903be067037dc9611efe2d4104071ddff39d2c697d7b7837d25d175fedbba",
            byteCount: 1_202,
            purpose: .immutableData
        ),
        licenseArtifact: PrimeArtifactBinding(
            relativePath: "evidence/mlx-swift/LICENSE",
            sha256:
                "44326a4ea062241ae6fc26ee2ec90bdc81af7eb7b9d3966181b733fa69d42057",
            byteCount: 1_067,
            purpose: .immutableData
        ),
        optimizer: PrimeOptimizerRestoreSourceAPIBinding(
            repositoryRelativePath:
                "Source/MLXOptimizers/Optimizers.swift",
            apiDeclarations: [
                "OptimizerBase.innerState() -> [MLXArray]",
                "OptimizerBase.update(model:gradients:)",
                "AdamW.init(learningRate:betas:eps:weightDecay:)",
            ],
            sourceArtifact: PrimeArtifactBinding(
                relativePath:
                    "evidence/mlx-swift/Source/MLXOptimizers/Optimizers.swift",
                sha256:
                    "f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d",
                byteCount: 24_109,
                purpose: .immutableData
            )
        ),
        updatableProtocol:
            PrimeOptimizerRestoreSourceAPIBinding(
                repositoryRelativePath:
                    "Source/MLX/Protocols.swift",
                apiDeclarations: [
                    "Updatable.innerState() -> [MLXArray]",
                    "MLXArray._updateInternal(_:) is an implementation detail for MLX and must not be depended on by outside callers",
                ],
                sourceArtifact: PrimeArtifactBinding(
                    relativePath:
                        "evidence/mlx-swift/Source/MLX/Protocols.swift",
                    sha256:
                        "1695559788cb24750c215ec0a3dd403464fb32d1a3ac3a35385fdba8bdc8823c",
                    byteCount: 1_079,
                    purpose: .immutableData
                )
            ),
        arrayMutation:
            PrimeOptimizerRestoreSourceAPIBinding(
                repositoryRelativePath:
                    "Source/MLX/MLXArray.swift",
                apiDeclarations: [
                    "MLXArray._updateInternal(_:)",
                ],
                sourceArtifact: PrimeArtifactBinding(
                    relativePath:
                        "evidence/mlx-swift/Source/MLX/MLXArray.swift",
                    sha256:
                        "0cd516b95d5d75840978e265d3069709a8f557de96264df8605f246d91b0126c",
                    byteCount: 19_676,
                    purpose: .immutableData
                )
            ),
        nestedStructure:
            PrimeOptimizerRestoreSourceAPIBinding(
                repositoryRelativePath:
                    "Source/MLX/Nested.swift",
                apiDeclarations: [
                    "NestedDictionary.flattened(prefix:)",
                    "NestedDictionary.flattenedValues()",
                ],
                sourceArtifact: PrimeArtifactBinding(
                    relativePath:
                        "evidence/mlx-swift/Source/MLX/Nested.swift",
                    sha256:
                        "29523d272fb85b6c535045fab0444c899acff508c9989dba6eea110e7ec69e22",
                    byteCount: 37_630,
                    purpose: .immutableData
                )
            ),
        tensorIO: PrimeOptimizerRestoreSourceAPIBinding(
            repositoryRelativePath: "Source/MLX/IO.swift",
            apiDeclarations: [
                "save(arrays:metadata:url:stream:)",
                "loadArraysAndMetadata(url:stream:)",
            ],
            sourceArtifact: PrimeArtifactBinding(
                relativePath:
                    "evidence/mlx-swift/Source/MLX/IO.swift",
                sha256:
                    "2ebd6414fd168b9457b8d359cf4df8525dafc3328c23d753740f264b7610975d",
                byteCount: 10_514,
                purpose: .immutableData
            )
        ),
        moduleRestore:
            PrimeOptimizerRestoreSourceAPIBinding(
                repositoryRelativePath:
                    "Source/MLXNN/Module.swift",
                apiDeclarations: [
                    "Module.update(parameters:verify:path:modulePath:)",
                    "Module.VerifyUpdate.all",
                ],
                sourceArtifact: PrimeArtifactBinding(
                    relativePath:
                        "evidence/mlx-swift/Source/MLXNN/Module.swift",
                    sha256:
                        "bf3dd13a385f91cb808a9f21d5c84c6faac7e68ec922c45ea22ed2728374ae3b",
                    byteCount: 61_198,
                    purpose: .immutableData
                )
            ),
        typedOptimizerRestoreAPIDeclared: false,
        implementationDetailMutationWarning:
            "Updatable.innerState arrays can be mutated with MLXArray._updateInternal(_:), but mlx-swift documents that mechanism as an implementation detail that outside callers must not depend on."
    )

    public init(
        dependencyResolution:
            PrimeArtifactBinding,
        licenseArtifact: PrimeArtifactBinding,
        optimizer:
            PrimeOptimizerRestoreSourceAPIBinding,
        updatableProtocol:
            PrimeOptimizerRestoreSourceAPIBinding,
        arrayMutation:
            PrimeOptimizerRestoreSourceAPIBinding,
        nestedStructure:
            PrimeOptimizerRestoreSourceAPIBinding,
        tensorIO:
            PrimeOptimizerRestoreSourceAPIBinding,
        moduleRestore:
            PrimeOptimizerRestoreSourceAPIBinding,
        typedOptimizerRestoreAPIDeclared: Bool,
        implementationDetailMutationWarning: String
    ) {
        self.dependencyResolution =
            dependencyResolution
        self.licenseArtifact = licenseArtifact
        self.optimizer = optimizer
        self.updatableProtocol = updatableProtocol
        self.arrayMutation = arrayMutation
        self.nestedStructure = nestedStructure
        self.tensorIO = tensorIO
        self.moduleRestore = moduleRestore
        self.typedOptimizerRestoreAPIDeclared =
            typedOptimizerRestoreAPIDeclared
        self.implementationDetailMutationWarning =
            implementationDetailMutationWarning
    }

    public func validate() throws {
        try dependencyResolution.validateDeclaration()
        try licenseArtifact.validateDeclaration()
        try optimizer.validateDeclaration()
        try updatableProtocol.validateDeclaration()
        try arrayMutation.validateDeclaration()
        try nestedStructure.validateDeclaration()
        try tensorIO.validateDeclaration()
        try moduleRestore.validateDeclaration()
        guard self == .frozenMLXSwift0313,
              dependencyResolution.purpose
                == .immutableData,
              licenseArtifact.purpose
                == .immutableData else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore source/API evidence diverges from the exact reviewed mlx-swift 0.31.3 sources"
                )
        }
    }

    fileprivate var artifacts: [PrimeArtifactBinding] {
        [
            dependencyResolution,
            licenseArtifact,
            optimizer.sourceArtifact,
            updatableProtocol.sourceArtifact,
            arrayMutation.sourceArtifact,
            nestedStructure.sourceArtifact,
            tensorIO.sourceArtifact,
            moduleRestore.sourceArtifact,
        ]
    }
}

public enum PrimeOptimizerTensorRole:
    String,
    Codable,
    CaseIterable,
    Hashable,
    Sendable
{
    case modelParameter = "model_parameter"
    case adamFirstMoment = "adam_first_moment"
    case adamSecondMoment = "adam_second_moment"

    fileprivate var sortOrder: Int {
        switch self {
        case .modelParameter:
            0
        case .adamFirstMoment:
            1
        case .adamSecondMoment:
            2
        }
    }
}

/// Logical tensor identity independent of safetensors header ordering.
public struct PrimeOptimizerTensorCatalogEntry:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeOptimizerTensorRole
    public let key: String
    public let dtype: String
    public let shape: [Int]
    public let nbytes: UInt64
    public let logicalSHA256: String

    public init(
        role: PrimeOptimizerTensorRole,
        key: String,
        dtype: String,
        shape: [Int],
        nbytes: UInt64,
        logicalSHA256: String
    ) {
        self.role = role
        self.key = key
        self.dtype = dtype
        self.shape = shape
        self.nbytes = nbytes
        self.logicalSHA256 = logicalSHA256
    }

    fileprivate func validate() throws {
        let keyParts = key.split(
            separator: ".",
            omittingEmptySubsequences: false
        )
        guard !keyParts.isEmpty,
              keyParts.allSatisfy({ !$0.isEmpty }),
              key.utf8.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              }),
              dtype == "float32",
              shape.allSatisfy({ $0 > 0 }),
              Self.isLowercaseSHA256(logicalSHA256) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer tensor catalog entry has an invalid key, dtype, shape, or logical SHA-256"
                )
        }

        var elementCount: UInt64 = 1
        for dimension in shape {
            let multiplication =
                elementCount.multipliedReportingOverflow(
                    by: UInt64(dimension)
                )
            guard !multiplication.overflow else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "optimizer tensor shape overflows its logical byte count"
                    )
            }
            elementCount = multiplication.partialValue
        }
        let bytes =
            elementCount.multipliedReportingOverflow(by: 4)
        guard !bytes.overflow,
              nbytes == bytes.partialValue else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer tensor nbytes does not equal its FP32 shape"
                )
        }
    }

    private static func isLowercaseSHA256(
        _ value: String
    ) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy({
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            })
    }
}

public struct PrimeOptimizerRestoreCPUExecutionObservations:
    Codable,
    Equatable,
    Sendable
{
    public let defaultDeviceType:
        PrimeObservation<String>
    public let defaultStreamDescription:
        PrimeObservation<String>
    public let defaultStreamWasCPU:
        PrimeBooleanObservation

    public init(
        defaultDeviceType:
            PrimeObservation<String>,
        defaultStreamDescription:
            PrimeObservation<String>,
        defaultStreamWasCPU:
            PrimeBooleanObservation
    ) {
        self.defaultDeviceType = defaultDeviceType
        self.defaultStreamDescription =
            defaultStreamDescription
        self.defaultStreamWasCPU =
            defaultStreamWasCPU
    }

    public func validate() throws {
        try defaultDeviceType.validate(
            "optimizer restore default device type"
        )
        try defaultStreamDescription.validate(
            "optimizer restore default stream description"
        )
        try defaultStreamWasCPU.validate(
            "optimizer restore default stream CPU observation"
        )
        guard defaultDeviceType == .observed("cpu"),
              let stream =
                defaultStreamDescription.value,
              !stream.trimmingCharacters(
                  in: .whitespacesAndNewlines
              ).isEmpty,
              stream.lowercased().contains("cpu"),
              defaultStreamDescription
                .observationAvailable,
              defaultStreamWasCPU
                == .observed(true) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore child execution must durably observe the CPU default device and CPU default stream"
                )
        }
    }
}

public struct PrimeOptimizerRestoreWriterRecord:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let processIdentifier: Int32
    public let executable: PrimeArtifactBinding
    public let cpuExecution:
        PrimeOptimizerRestoreCPUExecutionObservations
    public let modelCheckpoint: PrimeArtifactBinding
    public let optimizerStateCheckpoint:
        PrimeArtifactBinding
    public let tensorCatalog:
        [PrimeOptimizerTensorCatalogEntry]

    public init(
        schemaVersion: Int = 1,
        processIdentifier: Int32,
        executable: PrimeArtifactBinding,
        cpuExecution:
            PrimeOptimizerRestoreCPUExecutionObservations,
        modelCheckpoint: PrimeArtifactBinding,
        optimizerStateCheckpoint:
            PrimeArtifactBinding,
        tensorCatalog:
            [PrimeOptimizerTensorCatalogEntry]
    ) {
        self.schemaVersion = schemaVersion
        artifactKind =
            "prime_optimizer_restore_writer_record"
        self.processIdentifier = processIdentifier
        self.executable = executable
        self.cpuExecution = cpuExecution
        self.modelCheckpoint = modelCheckpoint
        self.optimizerStateCheckpoint =
            optimizerStateCheckpoint
        self.tensorCatalog = tensorCatalog
    }

    public func validate() throws {
        try executable.validateDeclaration()
        try modelCheckpoint.validateDeclaration()
        try optimizerStateCheckpoint
            .validateDeclaration()
        try cpuExecution.validate()
        try PrimeOptimizerRestoreReceipt
            .validateTensorCatalog(tensorCatalog)
        guard schemaVersion == 1,
              artifactKind
                == "prime_optimizer_restore_writer_record",
              processIdentifier > 0,
              executable.purpose == .executable,
              executable.relativePath
                == PrimeMLXRuntimeImageLayout
                    .optimizerRestoreProbe
                    .stagedExecutableRelativePath,
              modelCheckpoint.purpose
                == .immutableData,
              optimizerStateCheckpoint.purpose
                == .immutableData else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore writer record has invalid process, executable, checkpoint, or CPU execution evidence"
                )
        }
    }
}

public struct PrimeOptimizerRestoreVerifierRecord:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let writerRecord: PrimeArtifactBinding
    public let writerProcessIdentifier: Int32
    public let verifierProcessIdentifier: Int32
    public let executable: PrimeArtifactBinding
    public let cpuExecution:
        PrimeOptimizerRestoreCPUExecutionObservations
    public let modelCheckpoint: PrimeArtifactBinding
    public let optimizerStateCheckpoint:
        PrimeArtifactBinding
    public let modelSupportedTypedRestoreExact:
        PrimeBooleanObservation
    public let optimizerStateSafetensorsRoundTripExact:
        PrimeBooleanObservation

    public init(
        schemaVersion: Int = 1,
        writerRecord: PrimeArtifactBinding,
        writerProcessIdentifier: Int32,
        verifierProcessIdentifier: Int32,
        executable: PrimeArtifactBinding,
        cpuExecution:
            PrimeOptimizerRestoreCPUExecutionObservations,
        modelCheckpoint: PrimeArtifactBinding,
        optimizerStateCheckpoint:
            PrimeArtifactBinding,
        modelSupportedTypedRestoreExact:
            PrimeBooleanObservation,
        optimizerStateSafetensorsRoundTripExact:
            PrimeBooleanObservation
    ) {
        self.schemaVersion = schemaVersion
        artifactKind =
            "prime_optimizer_restore_verifier_record"
        self.writerRecord = writerRecord
        self.writerProcessIdentifier =
            writerProcessIdentifier
        self.verifierProcessIdentifier =
            verifierProcessIdentifier
        self.executable = executable
        self.cpuExecution = cpuExecution
        self.modelCheckpoint = modelCheckpoint
        self.optimizerStateCheckpoint =
            optimizerStateCheckpoint
        self.modelSupportedTypedRestoreExact =
            modelSupportedTypedRestoreExact
        self.optimizerStateSafetensorsRoundTripExact =
            optimizerStateSafetensorsRoundTripExact
    }

    public func validate() throws {
        try writerRecord.validateDeclaration()
        try executable.validateDeclaration()
        try modelCheckpoint.validateDeclaration()
        try optimizerStateCheckpoint
            .validateDeclaration()
        try cpuExecution.validate()
        try modelSupportedTypedRestoreExact.validate(
            "optimizer restore verifier model restore"
        )
        try optimizerStateSafetensorsRoundTripExact
            .validate(
                "optimizer restore verifier optimizer-state safetensors round trip"
            )
        guard schemaVersion == 1,
              artifactKind
                == "prime_optimizer_restore_verifier_record",
              writerRecord.purpose == .immutableData,
              writerProcessIdentifier > 0,
              verifierProcessIdentifier > 0,
              writerProcessIdentifier
                != verifierProcessIdentifier,
              executable.purpose == .executable,
              executable.relativePath
                == PrimeMLXRuntimeImageLayout
                    .optimizerRestoreProbe
                    .stagedExecutableRelativePath,
              modelCheckpoint.purpose
                == .immutableData,
              optimizerStateCheckpoint.purpose
                == .immutableData,
              modelSupportedTypedRestoreExact
                == .observed(true),
              optimizerStateSafetensorsRoundTripExact
                == .observed(true) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore verifier record has invalid process, executable, checkpoint, CPU execution, or exact-restore evidence"
                )
        }
    }
}

public struct PrimeOptimizerRestoreArtifactBindings:
    Codable,
    Equatable,
    Sendable
{
    public let executable: PrimeArtifactBinding
    public let dependencyAPIEvidence:
        PrimeArtifactBinding
    public let primeSourceSnapshot:
        PrimeArtifactBinding
    public let modelCheckpoint: PrimeArtifactBinding
    public let optimizerStateCheckpoint:
        PrimeArtifactBinding
    public let mlxDefaultMetallib:
        PrimePinnedMLXMetallibBinding
    public let writerRecord: PrimeArtifactBinding
    public let verifierRecord: PrimeArtifactBinding
    public let executionTranscript:
        PrimeArtifactBinding

    public init(
        executable: PrimeArtifactBinding,
        dependencyAPIEvidence:
            PrimeArtifactBinding,
        primeSourceSnapshot:
            PrimeArtifactBinding,
        modelCheckpoint: PrimeArtifactBinding,
        optimizerStateCheckpoint:
            PrimeArtifactBinding,
        mlxDefaultMetallib:
            PrimePinnedMLXMetallibBinding,
        writerRecord: PrimeArtifactBinding,
        verifierRecord: PrimeArtifactBinding,
        executionTranscript:
            PrimeArtifactBinding
    ) {
        self.executable = executable
        self.dependencyAPIEvidence =
            dependencyAPIEvidence
        self.primeSourceSnapshot =
            primeSourceSnapshot
        self.modelCheckpoint = modelCheckpoint
        self.optimizerStateCheckpoint =
            optimizerStateCheckpoint
        self.mlxDefaultMetallib =
            mlxDefaultMetallib
        self.writerRecord = writerRecord
        self.verifierRecord = verifierRecord
        self.executionTranscript =
            executionTranscript
    }

    fileprivate func validate() throws {
        let bindings = [
            executable,
            dependencyAPIEvidence,
            primeSourceSnapshot,
            modelCheckpoint,
            optimizerStateCheckpoint,
            writerRecord,
            verifierRecord,
            executionTranscript,
        ]
        for binding in bindings {
            try binding.validateDeclaration()
        }
        try mlxDefaultMetallib
            .validateDeclaration()
        try PrimeMLXRuntimeImageLayout.require(
            mlxDefaultMetallib.runtimeImageLayout,
            for: .optimizerRestoreProbe
        )
        guard executable.purpose == .executable,
              bindings.dropFirst().allSatisfy({
                  $0.purpose == .immutableData
              }),
              executable.relativePath
                == PrimeMLXRuntimeImageLayout
                    .optimizerRestoreProbe
                    .stagedExecutableRelativePath,
              Set(bindings.map(\.relativePath)).count
                == bindings.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore artifacts require one executable and unique immutable source/model/state artifacts"
                )
        }
    }

    fileprivate var all: [PrimeArtifactBinding] {
        [
            executable,
            dependencyAPIEvidence,
            primeSourceSnapshot,
            modelCheckpoint,
            optimizerStateCheckpoint,
            writerRecord,
            verifierRecord,
            executionTranscript,
            mlxDefaultMetallib.artifact,
            mlxDefaultMetallib.infoPlistArtifact,
        ]
    }
}

/// Typed facts from the feasibility probe.
///
/// `.unavailable` means a fact was not measured. `.observed(false)` means it
/// was measured and was false. These states are never interchangeable.
public struct PrimeOptimizerRestoreObservations:
    Codable,
    Equatable,
    Sendable
{
    public let modelSafetensorsSave:
        PrimeBooleanObservation
    public let modelSupportedTypedRestore:
        PrimeBooleanObservation
    public let optimizerStateSafetensorsRoundTrip:
        PrimeBooleanObservation
    public let supportedTypedOptimizerRestoreAPI:
        PrimeBooleanObservation
    public let implementationDetailMutationUsed:
        PrimeBooleanObservation
    public let exactTrajectoryContinuation:
        PrimeBooleanObservation
    public let freshProcessOptimizerContinuationExact:
        PrimeBooleanObservation
    public let checkpointWriterExitedCleanly:
        PrimeBooleanObservation
    public let restoreVerifierWasFreshProcess:
        PrimeBooleanObservation

    public init(
        modelSafetensorsSave:
            PrimeBooleanObservation,
        modelSupportedTypedRestore:
            PrimeBooleanObservation,
        optimizerStateSafetensorsRoundTrip:
            PrimeBooleanObservation,
        supportedTypedOptimizerRestoreAPI:
            PrimeBooleanObservation,
        implementationDetailMutationUsed:
            PrimeBooleanObservation,
        exactTrajectoryContinuation:
            PrimeBooleanObservation,
        freshProcessOptimizerContinuationExact:
            PrimeBooleanObservation,
        checkpointWriterExitedCleanly:
            PrimeBooleanObservation,
        restoreVerifierWasFreshProcess:
            PrimeBooleanObservation
    ) {
        self.modelSafetensorsSave =
            modelSafetensorsSave
        self.modelSupportedTypedRestore =
            modelSupportedTypedRestore
        self.optimizerStateSafetensorsRoundTrip =
            optimizerStateSafetensorsRoundTrip
        self.supportedTypedOptimizerRestoreAPI =
            supportedTypedOptimizerRestoreAPI
        self.implementationDetailMutationUsed =
            implementationDetailMutationUsed
        self.exactTrajectoryContinuation =
            exactTrajectoryContinuation
        self.freshProcessOptimizerContinuationExact =
            freshProcessOptimizerContinuationExact
        self.checkpointWriterExitedCleanly =
            checkpointWriterExitedCleanly
        self.restoreVerifierWasFreshProcess =
            restoreVerifierWasFreshProcess
    }

    public static let pinnedAPILimit = Self(
        modelSafetensorsSave: .observed(true),
        modelSupportedTypedRestore: .observed(true),
        optimizerStateSafetensorsRoundTrip:
            .observed(true),
        supportedTypedOptimizerRestoreAPI:
            .observed(false),
        implementationDetailMutationUsed:
            .observed(false),
        exactTrajectoryContinuation: .unavailable,
        freshProcessOptimizerContinuationExact:
            .unavailable,
        checkpointWriterExitedCleanly:
            .observed(true),
        restoreVerifierWasFreshProcess:
            .observed(true)
    )

    fileprivate func validate() throws {
        let observations: [
            (String, PrimeBooleanObservation)
        ] = [
            (
                "model safetensors save",
                modelSafetensorsSave
            ),
            (
                "model supported typed restore",
                modelSupportedTypedRestore
            ),
            (
                "optimizer-state safetensors round trip",
                optimizerStateSafetensorsRoundTrip
            ),
            (
                "supported typed optimizer restore API",
                supportedTypedOptimizerRestoreAPI
            ),
            (
                "implementation-detail mutation use",
                implementationDetailMutationUsed
            ),
            (
                "exact trajectory continuation",
                exactTrajectoryContinuation
            ),
            (
                "fresh-process optimizer continuation",
                freshProcessOptimizerContinuationExact
            ),
            (
                "checkpoint-writer clean exit",
                checkpointWriterExitedCleanly
            ),
            (
                "fresh restore-verifier process",
                restoreVerifierWasFreshProcess
            ),
        ]
        for (label, observation) in observations {
            try observation.validate(label)
        }

        guard modelSafetensorsSave
                == .observed(true),
              modelSupportedTypedRestore
                == .observed(true),
              optimizerStateSafetensorsRoundTrip
                == .observed(true),
              supportedTypedOptimizerRestoreAPI
                == .observed(false),
              implementationDetailMutationUsed
                == .observed(false) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "the pinned API audit must record no supported typed optimizer restore and no implementation-detail mutation"
                )
        }

        let blockedContinuation = [
            exactTrajectoryContinuation,
            freshProcessOptimizerContinuationExact,
        ]
        guard blockedContinuation.allSatisfy({
                  !$0.observationAvailable
                      && $0.value == nil
              }),
              checkpointWriterExitedCleanly
                == .observed(true),
              restoreVerifierWasFreshProcess
                == .observed(true) else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "the writer and fresh verifier process boundary must be observed even though optimizer trajectory continuation remains unavailable"
                )
        }
    }
}

/// Canonical child-process evidence that backs the process-boundary
/// observations in the public receipt.
public struct PrimeOptimizerRestoreExecutionTranscript:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let writerPID: Int32
    public let verifierPID: Int32
    public let writerExecutable: PrimeArtifactBinding
    public let verifierExecutable: PrimeArtifactBinding
    public let modelCheckpoint: PrimeArtifactBinding
    public let optimizerStateCheckpoint:
        PrimeArtifactBinding
    public let mlxDefaultMetallib:
        PrimePinnedMLXMetallibBinding
    public let writerRecord: PrimeArtifactBinding
    public let verifierRecord: PrimeArtifactBinding
    public let tensorCatalog:
        [PrimeOptimizerTensorCatalogEntry]
    public let observations:
        PrimeOptimizerRestoreObservations

    public init(
        schemaVersion: Int = 1,
        writerPID: Int32,
        verifierPID: Int32,
        writerExecutable: PrimeArtifactBinding,
        verifierExecutable: PrimeArtifactBinding,
        modelCheckpoint: PrimeArtifactBinding,
        optimizerStateCheckpoint:
            PrimeArtifactBinding,
        mlxDefaultMetallib:
            PrimePinnedMLXMetallibBinding,
        writerRecord: PrimeArtifactBinding,
        verifierRecord: PrimeArtifactBinding,
        tensorCatalog:
            [PrimeOptimizerTensorCatalogEntry],
        observations:
            PrimeOptimizerRestoreObservations
    ) {
        self.schemaVersion = schemaVersion
        artifactKind =
            "prime_optimizer_restore_execution_transcript"
        self.writerPID = writerPID
        self.verifierPID = verifierPID
        self.writerExecutable = writerExecutable
        self.verifierExecutable = verifierExecutable
        self.modelCheckpoint = modelCheckpoint
        self.optimizerStateCheckpoint =
            optimizerStateCheckpoint
        self.mlxDefaultMetallib =
            mlxDefaultMetallib
        self.writerRecord = writerRecord
        self.verifierRecord = verifierRecord
        self.tensorCatalog = tensorCatalog
        self.observations = observations
    }

    public func validate() throws {
        try writerExecutable.validateDeclaration()
        try verifierExecutable.validateDeclaration()
        try modelCheckpoint.validateDeclaration()
        try optimizerStateCheckpoint
            .validateDeclaration()
        try mlxDefaultMetallib
            .validateDeclaration()
        try writerRecord.validateDeclaration()
        try verifierRecord.validateDeclaration()
        try PrimeMLXRuntimeImageLayout.require(
            mlxDefaultMetallib.runtimeImageLayout,
            for: .optimizerRestoreProbe
        )
        try observations.validate()
        try PrimeOptimizerRestoreReceipt
            .validateTensorCatalog(tensorCatalog)
        guard schemaVersion == 1,
              artifactKind
                == "prime_optimizer_restore_execution_transcript",
              writerPID > 0,
              verifierPID > 0,
              writerPID != verifierPID,
              writerExecutable == verifierExecutable,
              writerExecutable.purpose == .executable,
              writerExecutable.relativePath
                == mlxDefaultMetallib
                    .runtimeImageLayout
                    .stagedExecutableRelativePath,
              modelCheckpoint.purpose
                == .immutableData,
              optimizerStateCheckpoint.purpose
                == .immutableData,
              writerRecord.purpose == .immutableData,
              verifierRecord.purpose
                == .immutableData else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore transcript requires distinct positive child PIDs and the same exact executable/checkpoints as the receipt"
                )
        }
    }
}

public enum PrimeOptimizerRestoreOutcome:
    String,
    Codable,
    Sendable
{
    case grounded = "GROUNDED"
    case abstain = "ABSTAIN"
}

/// Fail-closed receipt for the pinned Swift optimizer-state restore gate.
///
/// The reviewed mlx-swift version exposes safetensors I/O and typed model
/// parameter update, but no supported typed optimizer state restore API.
/// Therefore this schema can truthfully publish only `ABSTAIN`. A later
/// supported API requires a new frozen plan and schema, not mutation of this
/// receipt.
public struct PrimeOptimizerRestoreReceipt:
    Codable,
    Equatable,
    Sendable
{
    public static let frozenClaimScope =
        "mlx_swift_0_31_3_adamw_supported_typed_optimizer_restore_feasibility"
    public static let frozenNextAction =
        "await_supported_typed_optimizer_state_restore_api_before_resumable_training"
    public static let requiredPrimeSourceRelativePaths:
        Set<String> = [
            "Sources/PrimeCore/PrimeOptimizerRestoreGate.swift",
            "Sources/PrimeOptimizerRestoreProbe/PrimeOptimizerRestoreProbeMain.swift",
        ]

    public let schemaVersion: Int
    public let artifactKind: String
    public let outcome: PrimeOptimizerRestoreOutcome
    public let recordedAtUTC: String
    public let claimScope: String
    public let plan: PrimeOptimizerRestorePlan
    public let sourceEvidence:
        PrimeOptimizerRestoreSourceEvidence
    public let artifacts:
        PrimeOptimizerRestoreArtifactBindings
    public let tensorCatalog:
        [PrimeOptimizerTensorCatalogEntry]
    public let observations:
        PrimeOptimizerRestoreObservations
    public let longTrainingAuthorized: Bool
    public let nextAction: String

    public init(
        schemaVersion: Int = 1,
        outcome: PrimeOptimizerRestoreOutcome,
        recordedAtUTC: String,
        claimScope: String = Self.frozenClaimScope,
        plan: PrimeOptimizerRestorePlan =
            .frozenAdamW0313,
        sourceEvidence:
            PrimeOptimizerRestoreSourceEvidence =
                .frozenMLXSwift0313,
        artifacts:
            PrimeOptimizerRestoreArtifactBindings,
        tensorCatalog:
            [PrimeOptimizerTensorCatalogEntry],
        observations:
            PrimeOptimizerRestoreObservations,
        longTrainingAuthorized: Bool = false,
        nextAction: String = Self.frozenNextAction
    ) {
        self.schemaVersion = schemaVersion
        artifactKind =
            "prime_optimizer_restore_feasibility_receipt"
        self.outcome = outcome
        self.recordedAtUTC = recordedAtUTC
        self.claimScope = claimScope
        self.plan = plan
        self.sourceEvidence = sourceEvidence
        self.artifacts = artifacts
        self.tensorCatalog = tensorCatalog
        self.observations = observations
        self.longTrainingAuthorized =
            longTrainingAuthorized
        self.nextAction = nextAction
    }

    fileprivate func validateStructure() throws {
        guard schemaVersion == 1,
              artifactKind
                == "prime_optimizer_restore_feasibility_receipt",
              outcome == .abstain,
              !recordedAtUTC.trimmingCharacters(
                  in: .whitespacesAndNewlines
              ).isEmpty,
              claimScope == Self.frozenClaimScope,
              nextAction == Self.frozenNextAction,
              !longTrainingAuthorized else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "the pinned optimizer restore receipt must remain an explicit ABSTAIN with long training unauthorized"
                )
        }

        try plan.validate()
        try sourceEvidence.validate()
        try artifacts.validate()
        try observations.validate()
        try Self.validateTensorCatalog(tensorCatalog)

        let allBindings =
            artifacts.all + sourceEvidence.artifacts
        guard Set(allBindings.map(\.relativePath)).count
                == allBindings.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore evidence artifact paths must be globally unique"
                )
        }
    }

    public func validate(
        in artifactRoot: PrimeArtifactRoot
    ) throws {
        try validateArtifacts(
            in: artifactRoot
        ) { snapshot in
            try PrimeSwiftSourceProvenance.validate(
                snapshot,
                requiredRelativePaths:
                    Self.requiredPrimeSourceRelativePaths
            )
        }
    }

    func validate(
        in artifactRoot: PrimeArtifactRoot,
        sourceProvenanceExpectation:
            PrimeSwiftSourceProvenanceExpectation
    ) throws {
        try validateArtifacts(
            in: artifactRoot
        ) { snapshot in
            try PrimeSwiftSourceProvenance.validate(
                snapshot,
                requiredRelativePaths:
                    Self.requiredPrimeSourceRelativePaths,
                expectation:
                    sourceProvenanceExpectation
            )
        }
    }

    private func validateArtifacts(
        in artifactRoot: PrimeArtifactRoot,
        validatePrimeSource:
            (PrimeSwiftSourceSnapshot) throws -> Void
    ) throws {
        try validateStructure()
        for binding in
            artifacts.all + sourceEvidence.artifacts
        {
            _ = try artifactRoot.verify(binding)
        }

        let sourceManifestData =
            try artifactRoot.readVerified(
                artifacts.dependencyAPIEvidence
            )
        let sourceManifest =
            try PrimeCanonicalJSON.decode(
                PrimeOptimizerRestoreSourceEvidence
                    .self,
                from: sourceManifestData,
                artifact:
                    artifacts.dependencyAPIEvidence
                        .relativePath
            )
        try sourceManifest.validate()
        guard sourceManifest == sourceEvidence else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "canonical optimizer source/API evidence manifest does not match the receipt"
                )
        }

        let primeSourceSnapshot =
            try artifactRoot.decodeVerified(
                PrimeSwiftSourceSnapshot.self,
                binding:
                    artifacts.primeSourceSnapshot,
                maximumByteCount:
                    64 * 1024 * 1024
            )
        try validatePrimeSource(
            primeSourceSnapshot
        )

        let writerRecord = try artifactRoot
            .decodeVerified(
                PrimeOptimizerRestoreWriterRecord.self,
                binding: artifacts.writerRecord
            )
        let verifierRecord = try artifactRoot
            .decodeVerified(
                PrimeOptimizerRestoreVerifierRecord.self,
                binding: artifacts.verifierRecord
            )
        let transcriptData =
            try artifactRoot.readVerified(
                artifacts.executionTranscript
            )
        let transcript = try PrimeCanonicalJSON.decode(
            PrimeOptimizerRestoreExecutionTranscript
                .self,
            from: transcriptData,
            artifact:
                artifacts.executionTranscript
                    .relativePath
        )
        try validateEvidence(
            sourceManifest: sourceManifest,
            executionTranscript: transcript,
            writerRecord: writerRecord,
            verifierRecord: verifierRecord
        )
    }

    fileprivate func validateEvidence(
        sourceManifest:
            PrimeOptimizerRestoreSourceEvidence,
        executionTranscript:
            PrimeOptimizerRestoreExecutionTranscript,
        writerRecord:
            PrimeOptimizerRestoreWriterRecord,
        verifierRecord:
            PrimeOptimizerRestoreVerifierRecord
    ) throws {
        try validateStructure()
        try sourceManifest.validate()
        try executionTranscript.validate()
        try writerRecord.validate()
        try verifierRecord.validate()
        guard executionTranscript.writerExecutable
                == artifacts.executable,
              executionTranscript.verifierExecutable
                == artifacts.executable,
              executionTranscript.modelCheckpoint
                == artifacts.modelCheckpoint,
              executionTranscript
                .optimizerStateCheckpoint
                == artifacts
                    .optimizerStateCheckpoint,
              executionTranscript
                .mlxDefaultMetallib
                == artifacts.mlxDefaultMetallib,
              executionTranscript.writerRecord
                == artifacts.writerRecord,
              executionTranscript.verifierRecord
                == artifacts.verifierRecord,
              executionTranscript.tensorCatalog
                == tensorCatalog,
              executionTranscript.observations
                == observations,
              sourceManifest == sourceEvidence,
              writerRecord.processIdentifier
                == executionTranscript.writerPID,
              writerRecord.executable
                == artifacts.executable,
              writerRecord.modelCheckpoint
                == artifacts.modelCheckpoint,
              writerRecord.optimizerStateCheckpoint
                == artifacts
                    .optimizerStateCheckpoint,
              writerRecord.tensorCatalog
                == tensorCatalog,
              verifierRecord.writerRecord
                == artifacts.writerRecord,
              verifierRecord.writerProcessIdentifier
                == writerRecord.processIdentifier,
              verifierRecord.verifierProcessIdentifier
                == executionTranscript.verifierPID,
              verifierRecord.executable
                == artifacts.executable,
              verifierRecord.modelCheckpoint
                == artifacts.modelCheckpoint,
              verifierRecord.optimizerStateCheckpoint
                == artifacts
                    .optimizerStateCheckpoint,
              verifierRecord
                .modelSupportedTypedRestoreExact
                == observations
                    .modelSupportedTypedRestore,
              verifierRecord
                .optimizerStateSafetensorsRoundTripExact
                == observations
                    .optimizerStateSafetensorsRoundTrip else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore child records and execution transcript do not match the receipt bindings, catalog, process identities, and observations"
                )
        }
    }

    fileprivate static func validateTensorCatalog(
        _ catalog: [PrimeOptimizerTensorCatalogEntry]
    ) throws {
        guard catalog.count == 6 else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore tensor catalog must contain exactly six tensors for Linear(2,2,bias:true) model/m/v state"
                )
        }
        for entry in catalog {
            try entry.validate()
        }

        let sorted = catalog.sorted {
            if $0.key != $1.key {
                return $0.key < $1.key
            }
            return $0.role.sortOrder
                < $1.role.sortOrder
        }
        guard catalog == sorted else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore tensor catalog must use canonical key-and-role order"
                )
        }

        struct Identity: Hashable {
            let key: String
            let role: PrimeOptimizerTensorRole
        }
        let identities = catalog.map {
            Identity(key: $0.key, role: $0.role)
        }
        guard Set(identities).count == identities.count else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore tensor catalog contains a duplicate key and role"
                )
        }

        let grouped = Dictionary(
            grouping: catalog,
            by: \.key
        )
        guard Set(grouped.keys) == ["bias", "weight"]
        else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "optimizer restore tensor catalog keys must be exactly bias and weight"
                )
        }
        let requiredRoles =
            Set(PrimeOptimizerTensorRole.allCases)
        for (key, entries) in grouped {
            let expectedShape =
                key == "bias" ? [2] : [2, 2]
            let expectedBytes: UInt64 =
                key == "bias" ? 8 : 16
            guard Set(entries.map(\.role))
                    == requiredRoles,
                  entries.count == requiredRoles.count,
                  Set(entries.map(\.dtype)).count == 1,
                  Set(entries.map(\.shape)).count == 1,
                  Set(entries.map(\.nbytes)).count == 1,
                  entries.allSatisfy({
                      $0.shape == expectedShape
                          && $0.nbytes == expectedBytes
                  }) else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "every model tensor must have shape-identical model, Adam first-moment, and Adam second-moment catalog entries"
                    )
            }
        }
    }
}
