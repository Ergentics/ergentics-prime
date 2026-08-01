import Foundation

/// Durable evidence that one frozen FP32 profile trial ended without a
/// capability report.
///
/// A failure envelope is not profile-quality evidence. It binds the exact
/// staged run authority and process termination so the scale Engine can
/// ABSTAIN and choose a diagnostic next action without inventing loss,
/// throughput, memory, or OOM observations.
public enum ErgenticsNativeLanguageProfileTrialFailure {
    public static let schemaVersion = "1"
    public static let profileTrialMaximumWallSeconds = 1_800.0
    public static let internalTimeoutExitStatus = 124
    public static let externalAlarmExitStatus = 142
    public static let externalAlarmSignal = 14

    public enum Classification:
        String, Codable, CaseIterable, Sendable
    {
        case internalExecutorWallTimeout =
            "internal_executor_wall_timeout"
        case externalHardWallTimeout =
            "external_hard_wall_timeout"
        case unattributedProcessTermination =
            "unattributed_process_termination"
        case executorFailure = "executor_failure"
        case missingReportAfterSuccessfulExit =
            "missing_report_after_successful_exit"

        public var routesToBFloat16Challenger: Bool {
            switch self {
            case .internalExecutorWallTimeout,
                 .externalHardWallTimeout:
                true
            case .unattributedProcessTermination,
                 .executorFailure,
                 .missingReportAfterSuccessfulExit:
                false
            }
        }
    }

    public struct TrialKey: Hashable, Sendable {
        public let profileID: String
        public let probePurposeID: String
        public let seed: Int
        public let learningRate: Double

        public init(
            profileID: String,
            probePurposeID: String,
            seed: Int,
            learningRate: Double
        ) {
            self.profileID = profileID
            self.probePurposeID = probePurposeID
            self.seed = seed
            self.learningRate = learningRate
        }
    }

    public struct Evidence: Codable, Equatable, Sendable {
        public let schemaVersion: String
        public let familyID: String
        public let mode: ErgenticsNativeLanguageCanary.Mode
        public let buildConfiguration: String
        public let precision: String
        public let phase: String
        public let profileID: String
        public let probePurposeID: String
        public let seed: Int
        public let learningRate: Double
        public let declaredMaximumExecutorWallSeconds: Double
        public let observedRunnerWallSeconds: Double
        public let executorExitStatus: Int
        public let executorTerminationSignal: Int?
        public let classification: Classification
        public let reportEmitted: Bool
        public let reportArtifactSHA256: String?
        public let configurationArtifactFileName: String
        public let configurationArtifactSHA256: String
        public let tokenizerArtifactSHA256: String
        public let corpusArtifactSHA256: String
        public let packageResolvedSHA256: String
        public let executorArtifactSHA256: String
        public let recommenderArtifactSHA256: String
        public let metalLibraryArtifactSHA256: String
        public let metalLibraryArtifactByteCount: Int64
        public let metalLibrarySourceMLXSwiftRevision: String

        public var trialKey: TrialKey {
            TrialKey(
                profileID: profileID,
                probePurposeID: probePurposeID,
                seed: seed,
                learningRate: learningRate
            )
        }

        /// A physically emitted report contradicts a clean trial result. It
        /// remains diagnostic even when the process status itself denotes a
        /// wall timeout.
        public var routesToBFloat16Challenger: Bool {
            !reportEmitted
                && classification.routesToBFloat16Challenger
        }

        public init(
            configuration:
                ErgenticsNativeLanguageRunConfiguration.Configuration,
            configurationArtifactSHA256: String,
            observedRunnerWallSeconds: Double,
            executorExitStatus: Int,
            executorTerminationSignal: Int?,
            reportEmitted: Bool = false,
            reportArtifactSHA256: String? = nil
        ) throws {
            guard let phase = configuration.phase,
                  let probePurposeID =
                    configuration.probePurposeID else {
                throw ValidationError.invalidProfileTrialBinding
            }
            self.schemaVersion =
                ErgenticsNativeLanguageProfileTrialFailure
                    .schemaVersion
            self.familyID =
                ErgenticsNativeLanguageCanary.familyID
            self.mode = configuration.mode
            self.buildConfiguration =
                configuration.buildConfiguration
            self.precision = configuration.precision
            self.phase = phase
            self.profileID = configuration.profileID
            self.probePurposeID = probePurposeID
            self.seed = configuration.seed
            self.learningRate = configuration.learningRate
            self.declaredMaximumExecutorWallSeconds =
                configuration.maximumExecutorWallSeconds
            self.observedRunnerWallSeconds =
                observedRunnerWallSeconds
            self.executorExitStatus = executorExitStatus
            self.executorTerminationSignal =
                executorTerminationSignal
            self.classification = try
                ErgenticsNativeLanguageProfileTrialFailure
                    .classify(
                        executorExitStatus: executorExitStatus,
                        executorTerminationSignal:
                            executorTerminationSignal
                    )
            self.reportEmitted = reportEmitted
            self.reportArtifactSHA256 =
                reportArtifactSHA256
            self.configurationArtifactFileName =
                ErgenticsNativeLanguageCanary
                    .configurationArtifactFileName
            self.configurationArtifactSHA256 =
                configurationArtifactSHA256
            self.tokenizerArtifactSHA256 =
                configuration.tokenizerArtifactSHA256
            self.corpusArtifactSHA256 =
                configuration.corpusArtifactSHA256
            self.packageResolvedSHA256 =
                configuration.packageResolvedSHA256
            self.executorArtifactSHA256 =
                configuration.executorSHA256
            self.recommenderArtifactSHA256 =
                configuration.recommenderSHA256
            self.metalLibraryArtifactSHA256 =
                configuration.metalLibraryArtifactSHA256
            self.metalLibraryArtifactByteCount =
                configuration.metalLibraryArtifactByteCount
            self.metalLibrarySourceMLXSwiftRevision =
                configuration.metalLibrarySourceMLXSwiftRevision
            try ErgenticsNativeLanguageProfileTrialFailure
                .validate(self)
        }

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case familyID = "family_id"
            case mode
            case buildConfiguration = "build_configuration"
            case precision
            case phase
            case profileID = "profile_id"
            case probePurposeID = "probe_purpose_id"
            case seed
            case learningRate = "learning_rate"
            case declaredMaximumExecutorWallSeconds =
                "declared_maximum_executor_wall_seconds"
            case observedRunnerWallSeconds =
                "observed_runner_wall_seconds"
            case executorExitStatus = "executor_exit_status"
            case executorTerminationSignal =
                "executor_termination_signal"
            case classification
            case reportEmitted = "report_emitted"
            case reportArtifactSHA256 =
                "report_artifact_sha256"
            case configurationArtifactFileName =
                "configuration_artifact_file_name"
            case configurationArtifactSHA256 =
                "configuration_artifact_sha256"
            case tokenizerArtifactSHA256 =
                "tokenizer_artifact_sha256"
            case corpusArtifactSHA256 =
                "corpus_artifact_sha256"
            case packageResolvedSHA256 =
                "package_resolved_sha256"
            case executorArtifactSHA256 =
                "executor_artifact_sha256"
            case recommenderArtifactSHA256 =
                "recommender_artifact_sha256"
            case metalLibraryArtifactSHA256 =
                "metal_library_artifact_sha256"
            case metalLibraryArtifactByteCount =
                "metal_library_artifact_byte_count"
            case metalLibrarySourceMLXSwiftRevision =
                "metal_library_source_mlx_swift_revision"
        }
    }

    public enum ValidationError: Error, Equatable, Sendable {
        case invalidExitStatus
        case invalidTerminationSignal
        case inconsistentExitStatusAndSignal
        case invalidSchema
        case invalidProfileTrialBinding
        case invalidWallEvidence
        case invalidReportBinding
        case invalidArtifactBinding
        case classificationMismatch
        case configurationMismatch
    }

    public static func classify(
        executorExitStatus: Int,
        executorTerminationSignal: Int?
    ) throws -> Classification {
        guard (0 ... 255).contains(executorExitStatus) else {
            throw ValidationError.invalidExitStatus
        }
        if let signal = executorTerminationSignal {
            guard (1 ... 127).contains(signal) else {
                throw ValidationError.invalidTerminationSignal
            }
            guard executorExitStatus == 128 + signal else {
                throw ValidationError
                    .inconsistentExitStatusAndSignal
            }
            return signal == externalAlarmSignal
                && executorExitStatus == externalAlarmExitStatus
                ? .externalHardWallTimeout
                : .unattributedProcessTermination
        }
        if executorExitStatus == 0 {
            return .missingReportAfterSuccessfulExit
        }
        return executorExitStatus == internalTimeoutExitStatus
            ? .internalExecutorWallTimeout
            : .executorFailure
    }

    public static func validate(
        _ evidence: Evidence
    ) throws {
        let derivedClassification = try classify(
            executorExitStatus: evidence.executorExitStatus,
            executorTerminationSignal:
                evidence.executorTerminationSignal
        )
        guard evidence.schemaVersion == schemaVersion,
              evidence.familyID
                == ErgenticsNativeLanguageCanary.familyID else {
            throw ValidationError.invalidSchema
        }
        let purposeAndPhaseBound =
            (
                evidence.probePurposeID
                    == ErgenticsNativeLanguageRunConfiguration
                        .discoveryPurposeID
                    && evidence.phase == "discovery"
            )
            || (
                evidence.probePurposeID
                    == ErgenticsNativeLanguageRunConfiguration
                        .confirmationPurposeID
                    && evidence.phase == "confirmation"
            )
        guard evidence.mode == .profileProbe,
              evidence.buildConfiguration
                == ErgenticsNativeLanguageCanary
                    .requiredBuildConfiguration,
              evidence.precision
                == ErgenticsNativeLanguageCanary.requiredPrecision,
              purposeAndPhaseBound,
              !evidence.profileID.isEmpty,
              evidence.seed > 0,
              evidence.learningRate.isFinite,
              evidence.learningRate > 0 else {
            throw ValidationError.invalidProfileTrialBinding
        }
        guard evidence.declaredMaximumExecutorWallSeconds
                == profileTrialMaximumWallSeconds,
              evidence.observedRunnerWallSeconds.isFinite,
              evidence.observedRunnerWallSeconds > 0,
              !(
                  derivedClassification
                    .routesToBFloat16Challenger
                    && !evidence.reportEmitted
              )
                || evidence.observedRunnerWallSeconds
                    >= evidence
                        .declaredMaximumExecutorWallSeconds else {
            throw ValidationError.invalidWallEvidence
        }
        let reportBindingGrounded =
            evidence.reportEmitted
            ? (
                evidence.executorExitStatus != 0
                    && isSHA256(
                        evidence.reportArtifactSHA256 ?? ""
                    )
            )
            : evidence.reportArtifactSHA256 == nil
        guard reportBindingGrounded else {
            throw ValidationError.invalidReportBinding
        }
        guard evidence.configurationArtifactFileName
                == ErgenticsNativeLanguageCanary
                    .configurationArtifactFileName,
              isSHA256(evidence.configurationArtifactSHA256),
              isSHA256(evidence.tokenizerArtifactSHA256),
              isSHA256(evidence.corpusArtifactSHA256),
              isSHA256(evidence.packageResolvedSHA256),
              isSHA256(evidence.executorArtifactSHA256),
              isSHA256(evidence.recommenderArtifactSHA256),
              isSHA256(evidence.metalLibraryArtifactSHA256),
              evidence.metalLibraryArtifactByteCount > 0,
              isGitRevision(
                  evidence.metalLibrarySourceMLXSwiftRevision
              ) else {
            throw ValidationError.invalidArtifactBinding
        }
        guard evidence.classification == derivedClassification else {
            throw ValidationError.classificationMismatch
        }
    }

    public static func validate(
        _ evidence: Evidence,
        against configuration:
            ErgenticsNativeLanguageRunConfiguration.Configuration,
        configurationArtifactSHA256: String
    ) throws {
        try validate(evidence)
        guard evidence.mode == configuration.mode,
              evidence.buildConfiguration
                == configuration.buildConfiguration,
              evidence.precision == configuration.precision,
              evidence.phase == configuration.phase,
              evidence.probePurposeID
                == configuration.probePurposeID,
              evidence.profileID == configuration.profileID,
              evidence.seed == configuration.seed,
              evidence.learningRate.bitPattern
                == configuration.learningRate.bitPattern,
              evidence.declaredMaximumExecutorWallSeconds
                .bitPattern
                == configuration.maximumExecutorWallSeconds
                    .bitPattern,
              evidence.configurationArtifactSHA256
                == configurationArtifactSHA256,
              evidence.tokenizerArtifactSHA256
                == configuration.tokenizerArtifactSHA256,
              evidence.corpusArtifactSHA256
                == configuration.corpusArtifactSHA256,
              evidence.packageResolvedSHA256
                == configuration.packageResolvedSHA256,
              evidence.executorArtifactSHA256
                == configuration.executorSHA256,
              evidence.recommenderArtifactSHA256
                == configuration.recommenderSHA256,
              evidence.metalLibraryArtifactSHA256
                == configuration.metalLibraryArtifactSHA256,
              evidence.metalLibraryArtifactByteCount
                == configuration.metalLibraryArtifactByteCount,
              evidence.metalLibrarySourceMLXSwiftRevision
                == configuration
                    .metalLibrarySourceMLXSwiftRevision else {
            throw ValidationError.configurationMismatch
        }
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.count == 64
            && value.allSatisfy {
                "0123456789abcdef".contains($0)
            }
    }

    private static func isGitRevision(_ value: String) -> Bool {
        value.count == 40
            && value.allSatisfy {
                "0123456789abcdef".contains($0)
            }
    }
}
