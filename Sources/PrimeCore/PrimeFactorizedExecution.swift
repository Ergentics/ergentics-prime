import Foundation

public enum PrimeFactorizedExecutionError:
    Error,
    Equatable,
    Sendable
{
    case invalidProvenance(String)
    case rootSeedAliasForbidden(PrimeSeedDomain)
    case seedDomainMismatch(
        expected: PrimeSeedDomain,
        observed: PrimeSeedDomain
    )
    case reusedSeedProvenance
    case unsupportedProfile(String)
    case unsupportedParameterCount(Int64)
    case unsupportedPrecision(PrimeNumericPrecision)
    case missingAuthorityLocus(PrimeAuthorityLocus)
    case duplicateAuthorityLocus(PrimeAuthorityLocus)
    case nonSwiftAuthority(
        locus: PrimeAuthorityLocus,
        language: PrimeImplementationLanguage
    )
    case pythonExecutionForbidden
    case shellScientificAuthorityForbidden
    case missingExclusionReason
    case invalidCalibrationObservation(String)
    case invalidCurriculumBlockPositions(Int?)
    case invalidOptimizerStepsPerBlock(Int?)
    case unalignedCurriculumBlock
    case invalidActiveWallCalibration
    case invalidConvergenceCalibration(String)
    case invalidProgress(String)
    case activeWallRegressed
    case progressRegressed
}

public enum PrimeHistoricalProvenanceKind:
    String,
    Codable,
    Equatable,
    Sendable
{
    case historicalArtifactField = "historical_artifact_field"
    case rootSeedAlias = "root_seed_alias"
}

public struct PrimeHistoricalFieldProvenance:
    Codable,
    Equatable,
    Sendable
{
    public let kind: PrimeHistoricalProvenanceKind
    public let artifactPath: String
    public let artifactSHA256: String
    public let fieldPath: String

    public init(
        kind: PrimeHistoricalProvenanceKind,
        artifactPath: String,
        artifactSHA256: String,
        fieldPath: String
    ) {
        self.kind = kind
        self.artifactPath = artifactPath
        self.artifactSHA256 = artifactSHA256
        self.fieldPath = fieldPath
    }

    fileprivate var identity: String {
        [
            artifactSHA256.lowercased(),
            artifactPath,
            fieldPath,
        ].joined(separator: "\u{1f}")
    }

    fileprivate func validate() throws {
        guard !artifactPath.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            throw PrimeFactorizedExecutionError
                .invalidProvenance("artifact_path_missing")
        }
        guard !fieldPath.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            throw PrimeFactorizedExecutionError
                .invalidProvenance("field_path_missing")
        }
        let hash = artifactSHA256.lowercased()
        let hexadecimal = CharacterSet(
            charactersIn: "0123456789abcdef"
        )
        guard hash.count == 64,
              hash.unicodeScalars.allSatisfy(
                  hexadecimal.contains
              )
        else {
            throw PrimeFactorizedExecutionError
                .invalidProvenance("artifact_sha256_invalid")
        }
    }
}

public enum PrimeSeedDomain:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case initialization
    case trainingSchedule = "training_schedule"
    case evaluation
}

public enum PrimeRandomnessLocus:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case parameterInitialization = "parameter_initialization"
    case curriculumOrdering = "curriculum_ordering"
    case evaluationOrdering = "evaluation_ordering"

    public var requiredSeedDomain: PrimeSeedDomain {
        switch self {
        case .parameterInitialization:
            return .initialization
        case .curriculumOrdering:
            return .trainingSchedule
        case .evaluationOrdering:
            return .evaluation
        }
    }
}

public struct PrimeHistoricalSeedRecord:
    Codable,
    Equatable,
    Sendable
{
    public let domain: PrimeSeedDomain
    public let value: UInt64
    public let provenance: PrimeHistoricalFieldProvenance

    public init(
        domain: PrimeSeedDomain,
        value: UInt64,
        provenance: PrimeHistoricalFieldProvenance
    ) {
        self.domain = domain
        self.value = value
        self.provenance = provenance
    }

    fileprivate func validate(
        expectedDomain: PrimeSeedDomain
    ) throws {
        guard domain == expectedDomain else {
            throw PrimeFactorizedExecutionError
                .seedDomainMismatch(
                    expected: expectedDomain,
                    observed: domain
                )
        }
        try provenance.validate()
        guard provenance.kind == .historicalArtifactField else {
            throw PrimeFactorizedExecutionError
                .rootSeedAliasForbidden(domain)
        }
    }
}

public struct PrimeSeedRoutingWitness:
    Codable,
    Equatable,
    Sendable
{
    public let locus: PrimeRandomnessLocus
    public let domain: PrimeSeedDomain
    public let routedValue: UInt64
    public let provenance: PrimeHistoricalFieldProvenance

    fileprivate init(
        locus: PrimeRandomnessLocus,
        record: PrimeHistoricalSeedRecord
    ) {
        self.locus = locus
        self.domain = record.domain
        self.routedValue = record.value
        self.provenance = record.provenance
    }
}

/// An explicit seed triple. Values are routed without hashing, namespacing, or a
/// shared root. Each value must be bound to a distinct historical artifact
/// field so that provenance cannot silently collapse the three controls.
public struct PrimeExecutionSeeds:
    Codable,
    Equatable,
    Sendable
{
    public let initialization: PrimeHistoricalSeedRecord
    public let trainingSchedule: PrimeHistoricalSeedRecord
    public let evaluation: PrimeHistoricalSeedRecord

    public init(
        initialization: PrimeHistoricalSeedRecord,
        trainingSchedule: PrimeHistoricalSeedRecord,
        evaluation: PrimeHistoricalSeedRecord
    ) throws {
        try initialization.validate(
            expectedDomain: .initialization
        )
        try trainingSchedule.validate(
            expectedDomain: .trainingSchedule
        )
        try evaluation.validate(
            expectedDomain: .evaluation
        )

        let records = [
            initialization,
            trainingSchedule,
            evaluation,
        ]
        guard Set(
            records.map(\.provenance.identity)
        ).count == records.count else {
            throw PrimeFactorizedExecutionError
                .reusedSeedProvenance
        }

        self.initialization = initialization
        self.trainingSchedule = trainingSchedule
        self.evaluation = evaluation
    }

    public func witness(
        for locus: PrimeRandomnessLocus
    ) -> PrimeSeedRoutingWitness {
        let record: PrimeHistoricalSeedRecord
        switch locus {
        case .parameterInitialization:
            record = initialization
        case .curriculumOrdering:
            record = trainingSchedule
        case .evaluationOrdering:
            record = evaluation
        }
        return PrimeSeedRoutingWitness(
            locus: locus,
            record: record
        )
    }

    public func initializationWitness()
        -> PrimeSeedRoutingWitness
    {
        witness(for: .parameterInitialization)
    }

    public func trainingScheduleWitness()
        -> PrimeSeedRoutingWitness
    {
        witness(for: .curriculumOrdering)
    }

    public func evaluationWitness()
        -> PrimeSeedRoutingWitness
    {
        witness(for: .evaluationOrdering)
    }

    /// The first explicitly factorized calibration triple.
    ///
    /// Each domain is bound to its own staged historical record and is routed
    /// directly. This is a new three-control assignment for future
    /// calibration; it never reinterprets a historical root-seed trial as
    /// though that trial had independently controlled these loci.
    public static func initialFactorizedCalibrationTriple()
        throws -> Self
    {
        try Self(
            initialization: PrimeHistoricalSeedRecord(
                domain: .initialization,
                value: 1_618,
                provenance: PrimeHistoricalFieldProvenance(
                    kind: .historicalArtifactField,
                    artifactPath:
                        "content-staging/" +
                        "prime-domain-trace-shadow-seed1618-" +
                        "recommend.v1.json",
                    artifactSHA256:
                        "640bfa9f4172f715c1a94e98358b6202" +
                        "2793b5d83051451e151fc7e1263d7329",
                    fieldPath: "seed"
                )
            ),
            trainingSchedule: PrimeHistoricalSeedRecord(
                domain: .trainingSchedule,
                value: 2_718,
                provenance: PrimeHistoricalFieldProvenance(
                    kind: .historicalArtifactField,
                    artifactPath:
                        "content-staging/" +
                        "prime-domain-trace-shadow-seed2718-" +
                        "recommend.v1.json",
                    artifactSHA256:
                        "a55b494d9c0ba08a170fbb02edba132d" +
                        "ac3f4fef2789de8d85eb9b772e46d31e",
                    fieldPath: "seed"
                )
            ),
            evaluation: PrimeHistoricalSeedRecord(
                domain: .evaluation,
                value: 3_141,
                provenance: PrimeHistoricalFieldProvenance(
                    kind: .historicalArtifactField,
                    artifactPath:
                        "content-staging/" +
                        "prime-domain-trace-shadow-seed3141-" +
                        "recommend.v1.json",
                    artifactSHA256:
                        "03c7c1abc110202e758b826d44005c327" +
                        "a7d2afa135afd70218794aaac103da5",
                    fieldPath: "seed"
                )
            )
        )
    }

    private enum CodingKeys: String, CodingKey {
        case initialization
        case trainingSchedule = "training_schedule"
        case evaluation
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(
            keyedBy: CodingKeys.self
        )
        try self.init(
            initialization: values.decode(
                PrimeHistoricalSeedRecord.self,
                forKey: .initialization
            ),
            trainingSchedule: values.decode(
                PrimeHistoricalSeedRecord.self,
                forKey: .trainingSchedule
            ),
            evaluation: values.decode(
                PrimeHistoricalSeedRecord.self,
                forKey: .evaluation
            )
        )
    }
}

public enum PrimeNumericPrecision:
    String,
    Codable,
    Equatable,
    Sendable
{
    case float32
    case bfloat16
}

public struct PrimeExecutionTarget:
    Codable,
    Equatable,
    Sendable
{
    public let profileID: String
    public let parameterCount: Int64
    public let precision: PrimeNumericPrecision

    public init(
        profileID: String,
        parameterCount: Int64,
        precision: PrimeNumericPrecision
    ) {
        self.profileID = profileID
        self.parameterCount = parameterCount
        self.precision = precision
    }

    public static var exactNative3BFP32: Self {
        let profile = PrimeNativeProfiles.exact3B
        return Self(
            profileID: profile.profileID,
            parameterCount: profile.parameterCount,
            precision: .float32
        )
    }

    fileprivate func validate() throws {
        let expected = PrimeNativeProfiles.exact3B
        guard profileID == expected.profileID else {
            throw PrimeFactorizedExecutionError
                .unsupportedProfile(profileID)
        }
        guard parameterCount == expected.parameterCount else {
            throw PrimeFactorizedExecutionError
                .unsupportedParameterCount(parameterCount)
        }
        guard precision == .float32 else {
            throw PrimeFactorizedExecutionError
                .unsupportedPrecision(precision)
        }
    }
}

public enum PrimeImplementationLanguage:
    String,
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    case swift
    case python
    case shell
}

public enum PrimeAuthorityLocus:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case modelImplementation = "model_implementation"
    case experimentOrchestration = "experiment_orchestration"
    case seedRouting = "seed_routing"
    case mutationSynthesis = "mutation_synthesis"
    case statistics
    case truthGate = "truth_gate"
    case artifactPublication = "artifact_publication"
}

public struct PrimeAuthorityBinding:
    Codable,
    Equatable,
    Sendable
{
    public let locus: PrimeAuthorityLocus
    public let language: PrimeImplementationLanguage

    public init(
        locus: PrimeAuthorityLocus,
        language: PrimeImplementationLanguage
    ) {
        self.locus = locus
        self.language = language
    }
}

public struct PrimeSwiftExecutionBoundary:
    Codable,
    Equatable,
    Sendable
{
    public static let strictExclusionReason =
        "Python and shell hold no scientific authority over model " +
        "implementation, experiment orchestration, seed routing, " +
        "mutation synthesis, statistics, truth gates, or artifact " +
        "publication; one compiled Swift authority owns those loci. " +
        "The pinned MLX dependency contains a CPU-JIT " +
        "shell capability whose invocation is not asserted by this " +
        "GPU mechanics receipt."

    public let authorities: [PrimeAuthorityBinding]
    public let pythonExecutionAuthorized: Bool
    public let shellScientificAuthorityAuthorized: Bool
    public let exclusionReason: String

    public init(
        authorities: [PrimeAuthorityBinding],
        pythonExecutionAuthorized: Bool,
        shellScientificAuthorityAuthorized: Bool,
        exclusionReason: String
    ) {
        self.authorities = authorities
        self.pythonExecutionAuthorized =
            pythonExecutionAuthorized
        self.shellScientificAuthorityAuthorized =
            shellScientificAuthorityAuthorized
        self.exclusionReason = exclusionReason
    }

    public static var strictSwiftOnly: Self {
        Self(
            authorities: PrimeAuthorityLocus.allCases.map {
                PrimeAuthorityBinding(
                    locus: $0,
                    language: .swift
                )
            },
            pythonExecutionAuthorized: false,
            shellScientificAuthorityAuthorized: false,
            exclusionReason: strictExclusionReason
        )
    }

    fileprivate func validate() throws {
        var observed = Set<PrimeAuthorityLocus>()
        for binding in authorities {
            guard observed.insert(binding.locus).inserted else {
                throw PrimeFactorizedExecutionError
                    .duplicateAuthorityLocus(binding.locus)
            }
            guard binding.language == .swift else {
                throw PrimeFactorizedExecutionError
                    .nonSwiftAuthority(
                        locus: binding.locus,
                        language: binding.language
                    )
            }
        }
        for locus in PrimeAuthorityLocus.allCases
        where !observed.contains(locus) {
            throw PrimeFactorizedExecutionError
                .missingAuthorityLocus(locus)
        }
        guard !pythonExecutionAuthorized else {
            throw PrimeFactorizedExecutionError
                .pythonExecutionForbidden
        }
        guard !shellScientificAuthorityAuthorized else {
            throw PrimeFactorizedExecutionError
                .shellScientificAuthorityForbidden
        }
        let normalizedReason = exclusionReason.lowercased()
        guard normalizedReason.contains("python"),
              normalizedReason.contains("shell"),
              normalizedReason.contains("swift")
        else {
            throw PrimeFactorizedExecutionError
                .missingExclusionReason
        }
    }
}

public struct PrimeCalibrationObservation<Value>:
    Codable,
    Equatable,
    Sendable
where Value: Codable & Equatable & Sendable {
    public let value: Value?
    public let provenance: PrimeHistoricalFieldProvenance?

    public init(
        value: Value?,
        provenance: PrimeHistoricalFieldProvenance?
    ) {
        self.value = value
        self.provenance = provenance
    }

    public static var unobserved: Self {
        Self(value: nil, provenance: nil)
    }

    fileprivate func validate(
        name: String
    ) throws {
        guard (value == nil) == (provenance == nil) else {
            throw PrimeFactorizedExecutionError
                .invalidCalibrationObservation(
                    "\(name)_value_provenance_mismatch"
                )
        }
        if let provenance {
            try provenance.validate()
            guard provenance.kind == .historicalArtifactField else {
                throw PrimeFactorizedExecutionError
                    .invalidCalibrationObservation(
                        "\(name)_not_historical"
                    )
            }
        }
    }
}

public struct PrimeExecutionCalibration:
    Codable,
    Equatable,
    Sendable
{
    public static let historicalBlockPositions = 147_456
    public static let historicalOptimizerStepsPerBlock = 36
    public static let historicalPositionsPerOptimizerStep = 4_096

    public let curriculumBlockPositions:
        PrimeCalibrationObservation<Int>
    public let optimizerStepsPerBlock:
        PrimeCalibrationObservation<Int>
    public let matchedActiveWallSeconds:
        PrimeCalibrationObservation<Double>
    public let convergenceMaximumCurriculumBlocks:
        PrimeCalibrationObservation<Int>
    public let convergencePatienceCurriculumBlocks:
        PrimeCalibrationObservation<Int>
    public let convergenceMinimumLossImprovement:
        PrimeCalibrationObservation<Double>

    public init(
        curriculumBlockPositions:
            PrimeCalibrationObservation<Int>,
        optimizerStepsPerBlock:
            PrimeCalibrationObservation<Int>,
        matchedActiveWallSeconds:
            PrimeCalibrationObservation<Double>,
        convergenceMaximumCurriculumBlocks:
            PrimeCalibrationObservation<Int>,
        convergencePatienceCurriculumBlocks:
            PrimeCalibrationObservation<Int>,
        convergenceMinimumLossImprovement:
            PrimeCalibrationObservation<Double>
    ) throws {
        self.curriculumBlockPositions =
            curriculumBlockPositions
        self.optimizerStepsPerBlock = optimizerStepsPerBlock
        self.matchedActiveWallSeconds =
            matchedActiveWallSeconds
        self.convergenceMaximumCurriculumBlocks =
            convergenceMaximumCurriculumBlocks
        self.convergencePatienceCurriculumBlocks =
            convergencePatienceCurriculumBlocks
        self.convergenceMinimumLossImprovement =
            convergenceMinimumLossImprovement
        try validate()
    }

    private func validate() throws {
        try curriculumBlockPositions.validate(
            name: "curriculum_block_positions"
        )
        try optimizerStepsPerBlock.validate(
            name: "optimizer_steps_per_block"
        )
        try matchedActiveWallSeconds.validate(
            name: "matched_active_wall_seconds"
        )
        try convergenceMaximumCurriculumBlocks.validate(
            name: "convergence_maximum_curriculum_blocks"
        )
        try convergencePatienceCurriculumBlocks.validate(
            name: "convergence_patience_curriculum_blocks"
        )
        try convergenceMinimumLossImprovement.validate(
            name: "convergence_minimum_loss_improvement"
        )

        guard curriculumBlockPositions.value ==
            Self.historicalBlockPositions
        else {
            throw PrimeFactorizedExecutionError
                .invalidCurriculumBlockPositions(
                    curriculumBlockPositions.value
                )
        }
        guard optimizerStepsPerBlock.value ==
            Self.historicalOptimizerStepsPerBlock
        else {
            throw PrimeFactorizedExecutionError
                .invalidOptimizerStepsPerBlock(
                    optimizerStepsPerBlock.value
                )
        }
        guard Self.historicalBlockPositions %
            Self.historicalOptimizerStepsPerBlock == 0,
              Self.historicalBlockPositions /
              Self.historicalOptimizerStepsPerBlock ==
              Self.historicalPositionsPerOptimizerStep
        else {
            throw PrimeFactorizedExecutionError
                .unalignedCurriculumBlock
        }

        if let seconds = matchedActiveWallSeconds.value {
            guard seconds.isFinite, seconds > 0 else {
                throw PrimeFactorizedExecutionError
                    .invalidActiveWallCalibration
            }
        }

        if let maximum =
            convergenceMaximumCurriculumBlocks.value
        {
            guard maximum > 0,
                  maximum <= Int.max /
                    Self.historicalBlockPositions,
                  maximum <= Int.max /
                    Self.historicalOptimizerStepsPerBlock
            else {
                throw PrimeFactorizedExecutionError
                    .invalidConvergenceCalibration(
                        "maximum_blocks_invalid"
                    )
            }
        }
        if let patience =
            convergencePatienceCurriculumBlocks.value
        {
            guard patience > 0 else {
                throw PrimeFactorizedExecutionError
                    .invalidConvergenceCalibration(
                        "patience_not_positive"
                    )
            }
            if let maximum =
                convergenceMaximumCurriculumBlocks.value,
               patience > maximum
            {
                throw PrimeFactorizedExecutionError
                    .invalidConvergenceCalibration(
                        "patience_exceeds_maximum_blocks"
                    )
            }
        }
        if let improvement =
            convergenceMinimumLossImprovement.value
        {
            guard improvement.isFinite, improvement >= 0 else {
                throw PrimeFactorizedExecutionError
                    .invalidConvergenceCalibration(
                        "minimum_improvement_invalid"
                    )
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case curriculumBlockPositions =
            "curriculum_block_positions"
        case optimizerStepsPerBlock =
            "optimizer_steps_per_block"
        case matchedActiveWallSeconds =
            "matched_active_wall_seconds"
        case convergenceMaximumCurriculumBlocks =
            "convergence_maximum_curriculum_blocks"
        case convergencePatienceCurriculumBlocks =
            "convergence_patience_curriculum_blocks"
        case convergenceMinimumLossImprovement =
            "convergence_minimum_loss_improvement"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(
            keyedBy: CodingKeys.self
        )
        try self.init(
            curriculumBlockPositions: values.decode(
                PrimeCalibrationObservation<Int>.self,
                forKey: .curriculumBlockPositions
            ),
            optimizerStepsPerBlock: values.decode(
                PrimeCalibrationObservation<Int>.self,
                forKey: .optimizerStepsPerBlock
            ),
            matchedActiveWallSeconds: values.decode(
                PrimeCalibrationObservation<Double>.self,
                forKey: .matchedActiveWallSeconds
            ),
            convergenceMaximumCurriculumBlocks:
                values.decode(
                    PrimeCalibrationObservation<Int>.self,
                    forKey:
                        .convergenceMaximumCurriculumBlocks
                ),
            convergencePatienceCurriculumBlocks:
                values.decode(
                    PrimeCalibrationObservation<Int>.self,
                    forKey:
                        .convergencePatienceCurriculumBlocks
                ),
            convergenceMinimumLossImprovement:
                values.decode(
                    PrimeCalibrationObservation<Double>.self,
                    forKey:
                        .convergenceMinimumLossImprovement
                )
        )
    }
}

public enum PrimeFidelityArm:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case fixedToken = "fixed_token"
    case matchedActiveWall = "matched_active_wall"
    case convergenceCapped = "convergence_capped"
}

public struct PrimeFidelityBudgetWitness:
    Codable,
    Equatable,
    Sendable
{
    public let arm: PrimeFidelityArm
    public let curriculumBlockPositions: Int
    public let optimizerStepsPerBlock: Int
    public let fixedPaddedPositionCap: Int?
    public let matchedActiveWallCapSeconds: Double?
    public let convergenceMaximumCurriculumBlocks: Int?
    public let convergenceMaximumPaddedPositions: Int?
    public let convergenceMaximumOptimizerSteps: Int?
    public let convergencePatienceCurriculumBlocks: Int?
    public let convergenceMinimumLossImprovement: Double?
    public let calibrationProvenance:
        [PrimeHistoricalFieldProvenance]
}

public struct PrimeExecutionProgress:
    Codable,
    Equatable,
    Sendable
{
    public let completedOptimizerSteps: Int
    public let processedPaddedPositions: Int
    public let activeMonotonicWallSeconds: Double?
    public let validationLossByCompletedBlock: [Double]?

    public init(
        completedOptimizerSteps: Int,
        processedPaddedPositions: Int,
        activeMonotonicWallSeconds: Double?,
        validationLossByCompletedBlock: [Double]?
    ) {
        self.completedOptimizerSteps =
            completedOptimizerSteps
        self.processedPaddedPositions =
            processedPaddedPositions
        self.activeMonotonicWallSeconds =
            activeMonotonicWallSeconds
        self.validationLossByCompletedBlock =
            validationLossByCompletedBlock
    }

    public var completedCurriculumBlocks: Int {
        completedOptimizerSteps /
            PrimeExecutionCalibration
                .historicalOptimizerStepsPerBlock
    }
}

public enum PrimeUnavailableMeasurement:
    String,
    Codable,
    Equatable,
    Sendable
{
    case matchedActiveWallCalibration =
        "matched_active_wall_calibration"
    case activeMonotonicWallObservation =
        "active_monotonic_wall_observation"
    case convergenceMaximumBlocksCalibration =
        "convergence_maximum_blocks_calibration"
    case convergencePatienceCalibration =
        "convergence_patience_calibration"
    case convergenceMinimumImprovementCalibration =
        "convergence_minimum_improvement_calibration"
    case validationLossHistory =
        "validation_loss_history"
}

public enum PrimeStopReason:
    String,
    Codable,
    Equatable,
    Sendable
{
    case fixedTokenCapReached =
        "fixed_token_cap_reached"
    case activeWallCapReached =
        "active_wall_cap_reached"
    case convergencePatienceExhausted =
        "convergence_patience_exhausted"
    case convergenceMaximumBlocksReached =
        "convergence_maximum_blocks_reached"
}

public enum PrimeArmDecision:
    Codable,
    Equatable,
    Sendable
{
    case continueRun
    case stop(PrimeStopReason)
    case unavailable([PrimeUnavailableMeasurement])
}

/// Pure controller logic. It owns no clock, process, device, optimizer, or
/// filesystem state. Callers supply completed-step observations; the
/// controller only validates them and decides whether an arm should continue.
public struct PrimeMultiFidelityController:
    Codable,
    Equatable,
    Sendable
{
    public let calibration: PrimeExecutionCalibration

    public init(
        calibration: PrimeExecutionCalibration
    ) {
        self.calibration = calibration
    }

    public func budgetWitness(
        for arm: PrimeFidelityArm
    ) -> PrimeFidelityBudgetWitness {
        let positions =
            PrimeExecutionCalibration
                .historicalBlockPositions
        let steps =
            PrimeExecutionCalibration
                .historicalOptimizerStepsPerBlock
        var provenance: [PrimeHistoricalFieldProvenance] = [
            calibration.curriculumBlockPositions.provenance,
            calibration.optimizerStepsPerBlock.provenance,
        ].compactMap { $0 }

        switch arm {
        case .fixedToken:
            return PrimeFidelityBudgetWitness(
                arm: arm,
                curriculumBlockPositions: positions,
                optimizerStepsPerBlock: steps,
                fixedPaddedPositionCap: positions,
                matchedActiveWallCapSeconds: nil,
                convergenceMaximumCurriculumBlocks: nil,
                convergenceMaximumPaddedPositions: nil,
                convergenceMaximumOptimizerSteps: nil,
                convergencePatienceCurriculumBlocks: nil,
                convergenceMinimumLossImprovement: nil,
                calibrationProvenance: provenance
            )
        case .matchedActiveWall:
            if let source =
                calibration.matchedActiveWallSeconds.provenance
            {
                provenance.append(source)
            }
            return PrimeFidelityBudgetWitness(
                arm: arm,
                curriculumBlockPositions: positions,
                optimizerStepsPerBlock: steps,
                fixedPaddedPositionCap: nil,
                matchedActiveWallCapSeconds:
                    calibration.matchedActiveWallSeconds.value,
                convergenceMaximumCurriculumBlocks: nil,
                convergenceMaximumPaddedPositions: nil,
                convergenceMaximumOptimizerSteps: nil,
                convergencePatienceCurriculumBlocks: nil,
                convergenceMinimumLossImprovement: nil,
                calibrationProvenance: provenance
            )
        case .convergenceCapped:
            let maximum = calibration
                .convergenceMaximumCurriculumBlocks.value
            [
                calibration
                    .convergenceMaximumCurriculumBlocks
                    .provenance,
                calibration
                    .convergencePatienceCurriculumBlocks
                    .provenance,
                calibration
                    .convergenceMinimumLossImprovement
                    .provenance,
            ].compactMap { $0 }.forEach {
                provenance.append($0)
            }
            return PrimeFidelityBudgetWitness(
                arm: arm,
                curriculumBlockPositions: positions,
                optimizerStepsPerBlock: steps,
                fixedPaddedPositionCap: nil,
                matchedActiveWallCapSeconds: nil,
                convergenceMaximumCurriculumBlocks: maximum,
                convergenceMaximumPaddedPositions:
                    maximum.map { $0 * positions },
                convergenceMaximumOptimizerSteps:
                    maximum.map { $0 * steps },
                convergencePatienceCurriculumBlocks:
                    calibration
                        .convergencePatienceCurriculumBlocks
                        .value,
                convergenceMinimumLossImprovement:
                    calibration
                        .convergenceMinimumLossImprovement
                        .value,
                calibrationProvenance: provenance
            )
        }
    }

    public func decision(
        for arm: PrimeFidelityArm,
        previous: PrimeExecutionProgress? = nil,
        current: PrimeExecutionProgress
    ) throws -> PrimeArmDecision {
        try validate(progress: current)
        if let previous {
            try validate(progress: previous)
            guard current.completedOptimizerSteps >=
                    previous.completedOptimizerSteps,
                  current.processedPaddedPositions >=
                    previous.processedPaddedPositions
            else {
                throw PrimeFactorizedExecutionError
                    .progressRegressed
            }
            if let before =
                previous.activeMonotonicWallSeconds,
               let after =
                current.activeMonotonicWallSeconds,
               after < before
            {
                throw PrimeFactorizedExecutionError
                    .activeWallRegressed
            }
            if let before =
                previous.validationLossByCompletedBlock,
               let after =
                current.validationLossByCompletedBlock,
               !after.starts(with: before)
            {
                throw PrimeFactorizedExecutionError
                    .progressRegressed
            }
        }

        switch arm {
        case .fixedToken:
            if current.processedPaddedPositions >=
                PrimeExecutionCalibration
                    .historicalBlockPositions
            {
                return .stop(.fixedTokenCapReached)
            }
            return .continueRun

        case .matchedActiveWall:
            guard let cap =
                calibration.matchedActiveWallSeconds.value
            else {
                return .unavailable([
                    .matchedActiveWallCalibration,
                ])
            }
            guard let elapsed =
                current.activeMonotonicWallSeconds
            else {
                return .unavailable([
                    .activeMonotonicWallObservation,
                ])
            }
            return elapsed >= cap
                ? .stop(.activeWallCapReached)
                : .continueRun

        case .convergenceCapped:
            var missing: [PrimeUnavailableMeasurement] = []
            let maximum = calibration
                .convergenceMaximumCurriculumBlocks.value
            let patience = calibration
                .convergencePatienceCurriculumBlocks.value
            let minimumImprovement = calibration
                .convergenceMinimumLossImprovement.value
            if maximum == nil {
                missing.append(
                    .convergenceMaximumBlocksCalibration
                )
            }
            if patience == nil {
                missing.append(
                    .convergencePatienceCalibration
                )
            }
            if minimumImprovement == nil {
                missing.append(
                    .convergenceMinimumImprovementCalibration
                )
            }
            guard missing.isEmpty,
                  let maximum,
                  let patience,
                  let minimumImprovement
            else {
                return .unavailable(missing)
            }
            guard let losses =
                current.validationLossByCompletedBlock,
                  losses.count ==
                    current.completedCurriculumBlocks
            else {
                return .unavailable([
                    .validationLossHistory,
                ])
            }
            if current.completedCurriculumBlocks >= maximum {
                return .stop(
                    .convergenceMaximumBlocksReached
                )
            }
            if hasExhaustedPatience(
                losses: losses,
                patience: patience,
                minimumImprovement: minimumImprovement
            ) {
                return .stop(
                    .convergencePatienceExhausted
                )
            }
            return .continueRun
        }
    }

    private func validate(
        progress: PrimeExecutionProgress
    ) throws {
        guard progress.completedOptimizerSteps >= 0,
              progress.processedPaddedPositions >= 0
        else {
            throw PrimeFactorizedExecutionError
                .invalidProgress("negative_counter")
        }
        let positionProduct =
            progress.completedOptimizerSteps
                .multipliedReportingOverflow(
                    by: PrimeExecutionCalibration
                        .historicalPositionsPerOptimizerStep
                )
        guard !positionProduct.overflow else {
            throw PrimeFactorizedExecutionError
                .invalidProgress("position_counter_overflow")
        }
        let expectedPositions = positionProduct.partialValue
        guard progress.processedPaddedPositions ==
            expectedPositions
        else {
            throw PrimeFactorizedExecutionError
                .invalidProgress(
                    "optimizer_position_alignment"
                )
        }
        if let elapsed =
            progress.activeMonotonicWallSeconds
        {
            guard elapsed.isFinite, elapsed >= 0 else {
                throw PrimeFactorizedExecutionError
                    .invalidProgress(
                        "active_wall_not_finite_nonnegative"
                    )
            }
        }
        if let losses =
            progress.validationLossByCompletedBlock
        {
            guard losses.count <=
                progress.completedCurriculumBlocks
            else {
                throw PrimeFactorizedExecutionError
                    .invalidProgress(
                        "loss_count_exceeds_completed_blocks"
                    )
            }
            guard losses.allSatisfy({
                $0.isFinite && $0 >= 0
            }) else {
                throw PrimeFactorizedExecutionError
                    .invalidProgress(
                        "validation_loss_invalid"
                    )
            }
        }
    }

    private func hasExhaustedPatience(
        losses: [Double],
        patience: Int,
        minimumImprovement: Double
    ) -> Bool {
        guard let first = losses.first else {
            return false
        }
        var best = first
        var staleBlocks = 0
        for loss in losses.dropFirst() {
            let improvement = best - loss
            if improvement > 0,
               improvement >= minimumImprovement
            {
                best = loss
                staleBlocks = 0
            } else {
                staleBlocks += 1
            }
        }
        return staleBlocks >= patience
    }
}

public struct PrimeFactorizedExecutionContract:
    Codable,
    Equatable,
    Sendable
{
    public let target: PrimeExecutionTarget
    public let seeds: PrimeExecutionSeeds
    public let boundary: PrimeSwiftExecutionBoundary
    public let calibration: PrimeExecutionCalibration

    public init(
        target: PrimeExecutionTarget,
        seeds: PrimeExecutionSeeds,
        boundary: PrimeSwiftExecutionBoundary,
        calibration: PrimeExecutionCalibration
    ) throws {
        try target.validate()
        try boundary.validate()
        self.target = target
        self.seeds = seeds
        self.boundary = boundary
        self.calibration = calibration
    }

    public var controller: PrimeMultiFidelityController {
        PrimeMultiFidelityController(
            calibration: calibration
        )
    }

    private enum CodingKeys: String, CodingKey {
        case target
        case seeds
        case boundary
        case calibration
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(
            keyedBy: CodingKeys.self
        )
        try self.init(
            target: values.decode(
                PrimeExecutionTarget.self,
                forKey: .target
            ),
            seeds: values.decode(
                PrimeExecutionSeeds.self,
                forKey: .seeds
            ),
            boundary: values.decode(
                PrimeSwiftExecutionBoundary.self,
                forKey: .boundary
            ),
            calibration: values.decode(
                PrimeExecutionCalibration.self,
                forKey: .calibration
            )
        )
    }
}
