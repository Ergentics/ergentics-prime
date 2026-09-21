// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityError: Error, Equatable, Sendable {
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

/// An append-only, non-executing restoration record. It specifies a future
/// restore-only mutation and its broader-surface trigger without asserting
/// that the trigger or any mechanics outcome occurred. It creates no run,
/// mechanics, measurement, retry, or workflow invocation.
public struct PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityV1: Codable, Equatable, Sendable {
    public struct PathMode: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let path: String
        public let gitStatus: String
        public let gitMode: String
        public let role: String
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let authorityID: String
    public let authorityKind: String
    public let status: String
    public let predecessorAuthorityID: String
    public let predecessorCanonicalSHA256: String
    public let predecessorExactMainRun174Revision: String
    public let timingRepairMergeRevision: String
    public let targetReviewedMainTimeoutMinutes: Int
    public let nextRoadmapMutation: String
    public let broaderSurfaceTrigger: String
    public let existingFivePathModeContract: [PathMode]
    public let appendOnly: Bool
    public let restoreOnly: Bool
    public let mechanicsAttemptConsumed: Bool
    public let mechanicsAttemptCreated: Bool
    public let measurementOpportunityConsumed: Bool
    public let measurementOpportunityCreated: Bool
    public let mechanicsAuthorized: Bool
    public let measurementAuthorized: Bool
    public let retryOrRerunAuthorized: Bool
    public let executionPerformed: Bool

    public static let canonicalByteCount = 2_189
    public static let canonicalSHA256 =
        "9e7faed99306f34e483bf4ebdd42d6b7899a87aedadd69631f8257d6dd544cd4"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID: "prime_secure_child_validation_fixture_identity_measurement_v2_restore_only_authority_v1",
        authorityID: "ergentics_prime_secure_child_validation_fixture_identity_measurement_v2_restore_only_authority_v1",
        authorityKind: "append_only_exact_five_restore_only_timeout_restoration_authority",
        status: "RESTORE_ONLY_PRECONSUMPTION_NO_MECHANICS_MEASUREMENT_ATTEMPT_OR_EXECUTION",
        predecessorAuthorityID: "ergentics_prime_secure_child_validation_fixture_identity_measurement_v2_timing_repair_authority_v1",
        predecessorCanonicalSHA256: "b77598fda922e6f3a925a4948ff834286664cf7df7bf4edcff1dadd275b2961c",
        predecessorExactMainRun174Revision: "3f69d6e911ca48c39edc55508e93fed64fc48732",
        timingRepairMergeRevision: "a6f76bd3f246a443ef96e21fa4c769499a62b875",
        targetReviewedMainTimeoutMinutes: 90,
        nextRoadmapMutation: "append_only_exact_five_restore_only_reviewed_main_timeout_to_90_minutes",
        broaderSurfaceTrigger: "mechanics_is_abandoned_or_requires_broader_surface",
        existingFivePathModeContract: [
            .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitStatus: "M", gitMode: "100755", role: "restore_reviewed_main_timeout_to_90"),
            .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitStatus: "M", gitMode: "100644", role: "restore_reviewed_main_timeout_to_90"),
            .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitStatus: "M", gitMode: "100644", role: "bind_restore_only_source_identity"),
            .init(ordinal: 4, path: "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthority.swift", gitStatus: "A", gitMode: "100644", role: "pure_restore_only_authority"),
            .init(ordinal: 5, path: "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityTests.swift", gitStatus: "A", gitMode: "100644", role: "sole_exhaustive_restore_only_authority_test"),
        ],
        appendOnly: true,
        restoreOnly: true,
        mechanicsAttemptConsumed: false,
        mechanicsAttemptCreated: false,
        measurementOpportunityConsumed: false,
        measurementOpportunityCreated: false,
        mechanicsAuthorized: false,
        measurementAuthorized: false,
        retryOrRerunAuthorized: false,
        executionPerformed: false)

    public func canonicalData() throws -> Data {
        try validateExactV1()
        let data = try PrimeCanonicalJSON.encode(self)
        guard data.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: data) == Self.canonicalSHA256
        else { throw PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityError.contractDrift }
        return data
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 131_072 else { throw PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityError.oversizedEncoding }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else { throw PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityError.noncanonicalEncoding }
        return value
    }

    public func validate() throws { try validateExactV1() }

    public func validateExactV1() throws {
        guard schemaVersion == 1,
              schemaID == "prime_secure_child_validation_fixture_identity_measurement_v2_restore_only_authority_v1",
              authorityID == "ergentics_prime_secure_child_validation_fixture_identity_measurement_v2_restore_only_authority_v1",
              authorityKind == "append_only_exact_five_restore_only_timeout_restoration_authority",
              status == "RESTORE_ONLY_PRECONSUMPTION_NO_MECHANICS_MEASUREMENT_ATTEMPT_OR_EXECUTION",
              predecessorAuthorityID == "ergentics_prime_secure_child_validation_fixture_identity_measurement_v2_timing_repair_authority_v1",
              predecessorCanonicalSHA256 == "b77598fda922e6f3a925a4948ff834286664cf7df7bf4edcff1dadd275b2961c",
              predecessorExactMainRun174Revision == "3f69d6e911ca48c39edc55508e93fed64fc48732",
              timingRepairMergeRevision == "a6f76bd3f246a443ef96e21fa4c769499a62b875",
              targetReviewedMainTimeoutMinutes == 90,
              nextRoadmapMutation == "append_only_exact_five_restore_only_reviewed_main_timeout_to_90_minutes",
              broaderSurfaceTrigger == "mechanics_is_abandoned_or_requires_broader_surface",
              existingFivePathModeContract == Self.frozenV1.existingFivePathModeContract,
              appendOnly, restoreOnly,
              !mechanicsAttemptConsumed, !mechanicsAttemptCreated,
              !measurementOpportunityConsumed, !measurementOpportunityCreated,
              !mechanicsAuthorized, !measurementAuthorized,
              !retryOrRerunAuthorized, !executionPerformed,
              self == Self.frozenV1
        else { throw PrimeSecureChildValidationFixtureIdentityMeasurementV2RestoreOnlyAuthorityError.contractDrift }
    }
}
