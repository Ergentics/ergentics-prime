import Foundation
@testable import PrimeCore
@testable import PrimeNativeNeuralGateHistoricalReplayMechanics
import PrimeNativeNeuralGateHistoricalSourceDerivation
import XCTest

final class PrimeNativeNeuralGateHistoricalReplayMechanicsTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalReplayMechanicsContract
    private typealias Gate =
        PrimeNeuralNativeLanguageVerifyAbstainGate

    private enum DonorGatePolicyError:
        Error,
        Equatable
    {
        case invalidRequirementValue(String)
        case requiredRootMissing
    }

    private enum GitObservationError:
        Error,
        Equatable
    {
        case launchFailed
        case nonzeroExit(Int32)
        case invalidUTF8
        case oversizedOutput
    }

    private static let donorRootEnvironmentKey =
        "PRIME_PMHNP_COMPANION_ROOT"
    private static let donorRequirementEnvironmentKey =
        "PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE"

    func testFrozenContractBindsExactClosureAndAuthorityCeiling()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_replay_mechanics_contract_v1"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            "6bd51cb07b0f6bf72eb9cba6dec1fd9686377dab838fd6468497c34d6704debe"
        )
        XCTAssertEqual(
            contract.targetBindings.map(\.targetName),
            [
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
            ]
        )
        XCTAssertEqual(
            contract.targetBindings.last?
                .directLocalDependencyNames,
            [
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateReplayMechanics",
            ]
        )
        XCTAssertEqual(
            contract.sourcePins.map(\.ordinal),
            Array(1 ... 11)
        )
        XCTAssertEqual(
            contract.sourcePins.filter {
                $0.sourceKind == .byteExactDonor
            }.count,
            8
        )
        XCTAssertEqual(
            contract.sourcePins.filter {
                $0.sourceKind == .derivedDonor
            }.count,
            1
        )
        XCTAssertEqual(
            contract.sourcePins.filter {
                $0.sourceKind == .primeAuthored
            }.count,
            1
        )
        XCTAssertEqual(
            contract.sourcePins.filter {
                $0.sourceKind == .existingPrimeSource
            }.count,
            1
        )
        XCTAssertEqual(
            contract.exactRuntimeSourceByteCount,
            691_319
        )
        XCTAssertEqual(
            contract.exactHistoricalTargetSourceByteCount,
            396_633
        )
        XCTAssertEqual(
            contract.exactTransitiveSourceByteCount,
            1_147_892
        )
        XCTAssertTrue(contract.sourceClosureContractBound)
        XCTAssertTrue(
            contract.historicalGateContainsTrapSites
        )
        XCTAssertTrue(
            contract
                .sealedFreshProcessRequiredBeforeExecutionEvidence
        )
        for unauthorized in [
            contract.pmhnpPackageDependencyPresent,
            contract.runtimeManifestMaySupplyExpectedValues,
            contract.artifactURLsAcceptedByObservationSeam,
            contract.phaseTelemetryIncludedInCanonicalObservation,
            contract.privateInvariantRecordsExposed,
            contract.perMutationFingerprintsExposed,
            contract.observedFailedLegSetsExposed,
            contract.workerMaterialized,
            contract.historicalGateExecuted,
            contract.modelExecutionObserved,
            contract.durablePublicationObserved,
            contract.independentDetectionEstablished,
            contract.distinctImplementationFamiliesEstablished,
            contract.agentContractKitFourTierAuditPerformed,
            contract.mechanicsPassAuthorized,
            contract.terminalReceiptAuthorized,
            contract.sourceBindingV7Issued,
            contract.scientificAuthorityAuthorized,
            contract.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(unauthorized)
        }
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(
                    PrimeNativeNeuralGateAdaptationProofContract
                        .frozenV3
                )
            ),
            contract.adaptationProofV3SHA256
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateHistoricalSourceMaterialContract
                .frozenV1.contentSHA256(),
            contract.sourceMaterialContractSHA256
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalObservationSeam
                .sourceClosureContractID,
            contract.contractID
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalObservationSeam
                .adaptationProofV3ID,
            contract.adaptationProofV3ID
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalObservationSeam
                .sourceMaterialContractID,
            contract.sourceMaterialContractID
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalObservationSeam
                .gateSourceSHA256,
            contract.sourcePins[7].checkedInSHA256
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalObservationSeam
                .carrierSourceSHA256,
            contract.sourcePins[8].checkedInSHA256
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateHistoricalObservationSeam
                .mutationMaterialSHA256,
            PrimeNativeNeuralGateHistoricalSourceMaterialContract
                .frozenV1.mutationMaterialDerivation
                .expectedOutputSHA256
        )
    }

    func testCheckedInSourceInventoryAndPinnedBytesAreExact()
        throws
    {
        let contract = Contract.frozenV1
        var observedByteCount: UInt64 = 0

        for pin in contract.sourcePins {
            let data = try Data(
                contentsOf:
                    repositoryRoot.appendingPathComponent(
                        pin.primeRelativePath
                    )
            )
            XCTAssertEqual(
                UInt64(data.count),
                pin.checkedInByteCount,
                pin.primeRelativePath
            )
            XCTAssertEqual(
                digest(data),
                pin.checkedInSHA256,
                pin.primeRelativePath
            )
            observedByteCount += UInt64(data.count)
        }
        XCTAssertEqual(
            observedByteCount,
            contract.exactTransitiveSourceByteCount
        )

        for target in contract.targetBindings {
            let directory = repositoryRoot
                .appendingPathComponent("Sources")
                .appendingPathComponent(target.targetName)
            let actual = try recursiveSwiftSourcePaths(
                in: directory
            )
            XCTAssertEqual(
                actual,
                target.orderedSourceRelativePaths.sorted(),
                target.targetName
            )
        }
    }

    func testObservationProjectionIsDeterministicTimingIndependentAndNonAuthorizing()
        throws
    {
        let first = try
            PrimeNativeNeuralGateHistoricalObservationSeam
            .project(
                assessment(
                    phaseDurationsSeconds: [
                        "baseline": 0.001,
                        "mutation": 20.0,
                    ]
                )
            )
        let second = try
            PrimeNativeNeuralGateHistoricalObservationSeam
            .project(
                assessment(
                    phaseDurationsSeconds: [
                        "baseline": 99.0,
                        "mutation": 0.0,
                        "new_phase": 1_000.0,
                    ]
                )
            )

        XCTAssertEqual(first, second)
        XCTAssertNoThrow(try first.validate())
        XCTAssertEqual(first.historicalOutcome, "GROUNDED")
        XCTAssertEqual(
            first.historicalTriadicLabel,
            "independentThreePlus(10)"
        )
        XCTAssertEqual(first.primeAdmissionDisposition, "ABSTAIN")
        XCTAssertTrue(first.historicalPayloadOnly)
        XCTAssertEqual(
            first.invariantRecordsAvailability,
            .notExposedByPinnedGatePublicAPI
        )
        XCTAssertEqual(
            first.perMutationFingerprintsAvailability,
            .notExposedByPinnedGatePublicAPI
        )
        XCTAssertEqual(
            first.observedFailedLegSetsAvailability,
            .notExposedByPinnedGatePublicAPI
        )
        XCTAssertEqual(
            first.phaseTelemetryAvailability,
            .notObservedByObservationSeam
        )
        for unauthorized in [
            first.candidateDeclaredPayloadAuthoritative,
            first.compiledSourceClosureObserved,
            first.gateExecutionEvidenceBound,
            first.modelExecutionEvidenceBound,
            first.durablePublicationObserved,
            first.independentDetectionEstablished,
            first.distinctImplementationFamiliesEstablished,
            first.agentContractKitFourTierAuditPerformed,
            first.mechanicsPassAuthorized,
            first.terminalReceiptAuthorized,
            first.sourceBindingV7Issued,
            first.scientificAuthorityAuthorized,
            first.productAuthorityAuthorized,
        ] {
            XCTAssertFalse(unauthorized)
        }
        let firstBytes = try
            PrimeNativeNeuralGateHistoricalObservationSeam
            .canonicalBytes(of: first)
        let secondBytes = try
            PrimeNativeNeuralGateHistoricalObservationSeam
            .canonicalBytes(of: second)
        XCTAssertEqual(firstBytes, secondBytes)
        XCTAssertFalse(
            String(decoding: firstBytes, as: UTF8.self)
                .contains("phase_durations")
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .canonicalSHA256(of: first),
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .canonicalSHA256(of: second)
        )
        XCTAssertEqual(firstBytes.count, 15_578)
        XCTAssertEqual(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .canonicalSHA256(of: first),
            "a89e60bc8c0bb24f366e815f73fd9916c7becfc9d5db67105b97251b3e2d153a"
        )

        let abstain = try
            PrimeNativeNeuralGateHistoricalObservationSeam
            .project(
                assessment(
                    includeMutationSweep: false,
                    mutationLegPassed: false,
                    failedCriticalLegIndices: [0],
                    materialReloadComponentPasses:
                        materialReloadComponents(
                            failing: "provenance_artifacts"
                        )
                )
            )
        XCTAssertEqual(abstain.historicalOutcome, "ABSTAIN")
        XCTAssertEqual(abstain.primeAdmissionDisposition, "ABSTAIN")
        XCTAssertNil(abstain.mutationSweep)
        XCTAssertNoThrow(try abstain.validate())
    }

    func testObservationProjectionRejectsInconsistentHistoricalPayload()
        throws
    {
        var oneFailed = successfulMutationResults()
        let first = oneFailed[0]
        oneFailed[0] = .init(
            mutation: first.mutation,
            expectedFailedLeg: first.expectedFailedLeg,
            detected: false,
            fingerprintDiverged: true,
            restored: true,
            restoredFingerprintExact: true
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(
                        mutationResults: oneFailed,
                        mutationSweepOutcome: "GROUNDED",
                        mutationSweepTriadicLabel:
                            "independentThreePlus(46)",
                        mutationLegPassed: true
                    )
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidHistoricalOutcome
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(
                        includeMutationSweep: false,
                        mutationLegPassed: true
                    )
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidMutationSweep
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(
                        failedCriticalLegIndices: [2]
                    )
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidMutationSweep
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(includeFingerprint: false)
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidFingerprint
            )
        }

        let invalidFingerprint = Gate.FiniteFieldFingerprint(
            prime: 2_147_483_647,
            evaluationPoints: [257, 65_537, 1_000_003],
            residues: [0, 1, 2_147_483_647],
            recordCount: 59_497
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(fingerprint: invalidFingerprint)
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidFingerprint
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(
                        nextAction: "bad\0action"
                    )
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidNextAction
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(
                        materialReloadComponentPasses: [
                            "Invalid-Component": true,
                        ]
                    )
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidComponent(
                    "exact_historical_component_set_or_nl1_binding"
                )
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(
                        includeMutationSweep: false,
                        mutationLegPassed: false,
                        failedCriticalLegIndices: [0],
                        materialReloadComponentPasses:
                            materialReloadComponents()
                    )
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidComponent(
                    "exact_historical_component_set_or_nl1_binding"
                )
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(
                        mutationResults: oneFailed,
                        mutationSweepOutcome: "ABSTAIN",
                        mutationSweepTriadicLabel:
                            "independentThreePlus(46)",
                        mutationLegPassed: false
                    )
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidTriadicLabel
            )
        }

        var reordered = successfulMutationResults()
        reordered.swapAt(0, 1)
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(mutationResults: reordered)
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidMutationSweep
            )
        }

        var wrongLeg = successfulMutationResults()
        let result = wrongLeg[0]
        wrongLeg[0] = .init(
            mutation: result.mutation,
            expectedFailedLeg:
                "NL2_finite_field_sz_pool_expansion",
            detected: result.detected,
            fingerprintDiverged:
                result.fingerprintDiverged,
            restored: result.restored,
            restoredFingerprintExact:
                result.restoredFingerprintExact
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateHistoricalObservationSeam
                .project(
                    assessment(mutationResults: wrongLeg)
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateHistoricalObservationSeamError,
                .invalidMutationSweep
            )
        }
    }

    func testContractMutationCannotAcquireAuthority() throws {
        let data = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )
        object["mechanics_pass_authorized"] = true
        let mutated = try JSONDecoder().decode(
            Contract.self,
            from: JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]
            )
        )
        XCTAssertThrowsError(try mutated.validate())
    }

    func testPackageKeepsHistoricalClosureInternalAndUnconsumed()
        throws
    {
        let package = compact(
            try String(
                contentsOf:
                    repositoryRoot.appendingPathComponent(
                        "Package.swift"
                    ),
                encoding: .utf8
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"ErgenticsPrimeRuntime")"#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateHistoricalReplayMechanics",dependencies:["ErgenticsPrimeRuntime","PrimeNativeNeuralGateReplayMechanics",])"#
            )
        )
        let productsStart = try XCTUnwrap(
            package.range(of: "products:[")
        ).upperBound
        let productsEnd = try XCTUnwrap(
            package.range(
                of: "],dependencies:[",
                range: productsStart..<package.endIndex
            )
        ).lowerBound
        let products = package[productsStart..<productsEnd]
        for target in [
            "ErgenticsPrimeRuntime",
            "PrimeNativeNeuralGateHistoricalReplayMechanics",
        ] {
            XCTAssertFalse(products.contains(target), target)
            XCTAssertFalse(
                package.contains(
                    #".executableTarget(name:"\#(target)""#
                ),
                target
            )
        }
        let firstTestTarget = try XCTUnwrap(
            package.range(of: ".testTarget(")
        ).lowerBound
        let productionTargets = String(
            package[..<firstTestTarget]
        )
        XCTAssertEqual(
            productionTargets.components(
                separatedBy: "ErgenticsPrimeRuntime"
            ).count - 1,
            2
        )
        XCTAssertEqual(
            productionTargets.components(
                separatedBy:
                    "PrimeNativeNeuralGateHistoricalReplayMechanics"
            ).count - 1,
            1
        )
        XCTAssertFalse(
            package.lowercased().contains(
                "pmhnp-companion"
            )
        )
    }

    func testObservationSeamHasNoFilesystemOrRuntimeInputSurface()
        throws
    {
        let seam = try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/PrimeNativeNeuralGateHistoricalObservationSeam.swift"
                ),
            encoding: .utf8
        )
        XCTAssertTrue(
            seam.contains("public static func observe(")
        )
        XCTAssertTrue(
            seam.contains(
                "PrimeNeuralNativeLanguageVerifyAbstainGate"
            )
        )
        XCTAssertTrue(seam.contains(".Materials"))
        for forbidden in [
            "ArtifactURLs",
            "Data(contentsOf:",
            "String(contentsOf:",
            "FileManager",
            "ProcessInfo",
            "systemUptime",
            "MLX",
            "." + "load(",
            "Codable",
            "Decodable",
            "getenv",
            "PMHNP",
        ] {
            XCTAssertFalse(seam.contains(forbidden), forbidden)
        }
    }

    func testV10TestsNeverInvokeHistoricalAdmissionPath()
        throws
    {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath),
            encoding: .utf8
        )
        for forbiddenCall in [
            "." + "observe(",
            "." + "load(",
            "." + "dispose(",
        ] {
            XCTAssertFalse(
                source.contains(forbiddenCall),
                forbiddenCall
            )
        }
    }

    func testPinnedDonorClosureWhenCompanionRootIsProvided()
        throws
    {
        guard let root = try pinnedCompanionRoot(
            from: ProcessInfo.processInfo.environment
        ) else {
            throw XCTSkip(
                "standalone mode: set PRIME_PMHNP_COMPANION_ROOT to run the V10 pinned donor closure gate"
            )
        }
        let contract = Contract.frozenV1
        let rootURL = URL(
            fileURLWithPath: root,
            isDirectory: true
        ).standardizedFileURL

        XCTAssertEqual(
            try gitObservation(
                ["rev-parse", "HEAD"],
                root: rootURL
            ),
            contract.companionRevision
        )
        XCTAssertEqual(
            try gitObservation(
                ["rev-parse", "HEAD^{tree}"],
                root: rootURL
            ),
            contract.companionTreeOID
        )

        for pin in contract.sourcePins
        where pin.sourceKind == .byteExactDonor
            || pin.sourceKind == .derivedDonor
        {
            let donorPath = try XCTUnwrap(
                pin.originRepositoryRelativePath
            )
            let donor = try Data(
                contentsOf: rootURL.appendingPathComponent(
                    donorPath
                )
            )
            XCTAssertEqual(
                UInt64(donor.count),
                pin.originByteCount,
                donorPath
            )
            XCTAssertEqual(
                digest(donor),
                pin.originSHA256,
                donorPath
            )
            XCTAssertEqual(
                try gitObservation(
                    ["rev-parse", "HEAD:\(donorPath)"],
                    root: rootURL
                ),
                pin.originGitBlobOID,
                donorPath
            )
            if pin.sourceKind == .byteExactDonor {
                XCTAssertEqual(
                    donor,
                    try Data(
                        contentsOf:
                            repositoryRoot.appendingPathComponent(
                                pin.primeRelativePath
                            )
                    ),
                    donorPath
                )
            }
        }

        let gatePin = try XCTUnwrap(
            contract.sourcePins.first { $0.ordinal == 8 }
        )
        let carrierPin = try XCTUnwrap(
            contract.sourcePins.first { $0.ordinal == 9 }
        )
        let gate = try Data(
            contentsOf: rootURL.appendingPathComponent(
                try XCTUnwrap(
                    gatePin.originRepositoryRelativePath
                )
            )
        )
        let carrier = try Data(
            contentsOf: rootURL.appendingPathComponent(
                try XCTUnwrap(
                    carrierPin.originRepositoryRelativePath
                )
            )
        )
        let first = try
            PrimeNativeNeuralGateHistoricalSourceDerivation
            .derive(
                nativeLanguageGateSource: gate,
                verdictCarrierSource: carrier
            )
        let second = try
            PrimeNativeNeuralGateHistoricalSourceDerivation
            .derive(
                nativeLanguageGateSource: gate,
                verdictCarrierSource: carrier
            )
        XCTAssertEqual(first, second)
        XCTAssertEqual(
            first.carrierMaterial.bytes,
            try Data(
                contentsOf:
                    repositoryRoot.appendingPathComponent(
                        carrierPin.primeRelativePath
                    )
            )
        )
        XCTAssertEqual(
            first.aggregateMaterialSHA256,
            contract.sourceMaterialAggregateSHA256
        )
    }

    func testDonorRequirementPolicyFailsClosed() throws {
        XCTAssertNil(try pinnedCompanionRoot(from: [:]))
        XCTAssertEqual(
            try pinnedCompanionRoot(
                from: [
                    Self.donorRootEnvironmentKey:
                        "/pinned/companion",
                ]
            ),
            "/pinned/companion"
        )
        XCTAssertEqual(
            try pinnedCompanionRoot(
                from: [
                    Self.donorRequirementEnvironmentKey: "1",
                    Self.donorRootEnvironmentKey:
                        "/pinned/companion",
                ]
            ),
            "/pinned/companion"
        )
        XCTAssertThrowsError(
            try pinnedCompanionRoot(
                from: [
                    Self.donorRequirementEnvironmentKey: "true",
                ]
            )
        ) {
            XCTAssertEqual(
                $0 as? DonorGatePolicyError,
                .invalidRequirementValue("true")
            )
        }
        for environment in [
            [Self.donorRequirementEnvironmentKey: "1"],
            [
                Self.donorRequirementEnvironmentKey: "1",
                Self.donorRootEnvironmentKey: "",
            ],
        ] {
            XCTAssertThrowsError(
                try pinnedCompanionRoot(
                    from: environment
                )
            ) {
                XCTAssertEqual(
                    $0 as? DonorGatePolicyError,
                    .requiredRootMissing
                )
            }
        }
    }

    private func assessment(
        mutationResults: [Gate.MutationResult]? = nil,
        mutationSweepOutcome: String? = nil,
        mutationSweepTriadicLabel: String? = nil,
        includeMutationSweep: Bool = true,
        mutationLegPassed: Bool? = nil,
        fingerprint: Gate.FiniteFieldFingerprint? = nil,
        includeFingerprint: Bool = true,
        failedCriticalLegIndices: Set<Int> = [],
        nextAction: String = "historical_payload_only",
        materialReloadComponentPasses: [String: Bool]? = nil,
        phaseDurationsSeconds: [String: Double] = [:]
    ) -> Gate.Assessment {
        let suppliedResults = mutationResults
            ?? successfulMutationResults()
        let sweep: Gate.MutationSweep?
        if includeMutationSweep {
            let allPass = suppliedResults.allSatisfy {
                $0.detected
                    && $0.fingerprintDiverged
                    && $0.restored
                    && $0.restoredFingerprintExact
            }
            let detectedCount = suppliedResults
                .filter(\.detected).count
            sweep = .init(
                outcome: mutationSweepOutcome
                    ?? (allPass ? "GROUNDED" : "ABSTAIN"),
                triadicVerdict: mutationSweepTriadicLabel
                    ?? (allPass
                        ? "independentThreePlus(\(suppliedResults.count))"
                        : "oracleDerived(\(detectedCount))"),
                results: suppliedResults
            )
        } else {
            sweep = nil
        }
        let mutationPass = mutationLegPassed
            ?? (sweep?.outcome == "GROUNDED")
        var witnesses = Gate.criticalLegIDs
            .enumerated().map {
            PrimeNeuralVerifyAbstainGate.Witness(
                leg: $0.element,
                pass: !failedCriticalLegIndices
                    .contains($0.offset),
                detail: "historical payload",
                independent: true
            )
        }
        witnesses[witnesses.count - 1] =
            PrimeNeuralVerifyAbstainGate.Witness(
                leg: witnesses.last?.leg ?? "",
                pass: mutationPass,
                detail: "historical mutation payload",
                independent: true
            )
        let allCriticalPass = witnesses.allSatisfy(\.pass)
        return Gate.Assessment(
            verdict: PrimeNeuralVerifyAbstainGate.Verdict(
                witnesses: witnesses,
                outcome: allCriticalPass
                    ? .grounded : .verifyAbstain
            ),
            nextAction: nextAction,
            fingerprint: includeFingerprint
                ? (fingerprint ?? validFingerprint)
                : nil,
            mutationSweep: sweep,
            materialReloadComponentPasses:
                materialReloadComponentPasses
                    ?? materialReloadComponents(),
            phaseDurationsSeconds: phaseDurationsSeconds
        )
    }

    private func materialReloadComponents(
        failing failedName: String? = nil
    ) -> [String: Bool] {
        Dictionary(
            uniqueKeysWithValues: [
                "authority_n1_n5",
                "corpus_report_binding",
                "evaluation_shards",
                "probe_token_manifests",
                "provenance_artifacts",
                "report_codable_replay",
                "report_sha_recommendation_binding",
                "schema_and_material_presence",
                "tokenizer_corpus_verify",
            ].map {
                ($0, $0 != failedName)
            }
        )
    }

    private func successfulMutationResults()
        -> [Gate.MutationResult]
    {
        Gate.Mutation.allCases.map {
            .init(
                mutation: $0,
                expectedFailedLeg: $0.expectedFailedLeg,
                detected: true,
                fingerprintDiverged: true,
                restored: true,
                restoredFingerprintExact: true
            )
        }
    }

    private var validFingerprint: Gate.FiniteFieldFingerprint {
        .init(
            prime: 2_147_483_647,
            evaluationPoints: [257, 65_537, 1_000_003],
            residues: [1, 2, 3],
            recordCount: 59_497
        )
    }

    private func pinnedCompanionRoot(
        from environment: [String: String]
    ) throws -> String? {
        let requirement = environment[
            Self.donorRequirementEnvironmentKey
        ]
        if let requirement, requirement != "1" {
            throw DonorGatePolicyError
                .invalidRequirementValue(requirement)
        }
        let root = environment[
            Self.donorRootEnvironmentKey
        ].flatMap {
            $0.isEmpty ? nil : $0
        }
        if requirement == "1", root == nil {
            throw DonorGatePolicyError.requiredRootMissing
        }
        return root
    }

    private func gitObservation(
        _ arguments: [String],
        root: URL
    ) throws -> String {
        let process = Process()
        let output = Pipe()
        let errors = Pipe()
        process.executableURL = URL(
            fileURLWithPath: "/usr/bin/git"
        )
        process.arguments = ["-C", root.path] + arguments
        process.environment = ProcessInfo.processInfo
            .environment.filter {
                !$0.key.hasPrefix("GIT_")
            }
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = output
        process.standardError = errors
        do {
            try process.run()
        } catch {
            throw GitObservationError.launchFailed
        }
        process.waitUntilExit()
        let outputData = output.fileHandleForReading
            .readDataToEndOfFile()
        let errorData = errors.fileHandleForReading
            .readDataToEndOfFile()
        guard outputData.count <= 4_096,
              errorData.count <= 4_096
        else {
            throw GitObservationError.oversizedOutput
        }
        guard process.terminationStatus == 0 else {
            throw GitObservationError.nonzeroExit(
                process.terminationStatus
            )
        }
        guard let value = String(
            data: outputData,
            encoding: .utf8
        ) else {
            throw GitObservationError.invalidUTF8
        }
        return value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private func digest(_ data: Data) -> String {
        PrimeSHA256.hexDigest(of: data)
    }

    private func recursiveSwiftSourcePaths(
        in directory: URL
    ) throws -> [String] {
        let keys: [URLResourceKey] = [
            .isRegularFileKey,
            .isSymbolicLinkKey,
        ]
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: keys,
                options: [.skipsHiddenFiles]
            )
        )
        let rootPath = repositoryRoot
            .standardizedFileURL.path + "/"
        var paths: [String] = []
        for case let fileURL as URL in enumerator
        where fileURL.pathExtension == "swift" {
            let values = try fileURL.resourceValues(
                forKeys: Set(keys)
            )
            XCTAssertEqual(values.isRegularFile, true)
            XCTAssertNotEqual(values.isSymbolicLink, true)
            let path = fileURL.standardizedFileURL.path
            XCTAssertTrue(path.hasPrefix(rootPath), path)
            guard path.hasPrefix(rootPath),
                  values.isRegularFile == true,
                  values.isSymbolicLink != true
            else {
                continue
            }
            paths.append(String(path.dropFirst(rootPath.count)))
        }
        return paths.sorted()
    }

    private func compact(_ source: String) -> String {
        String(source.filter { !$0.isWhitespace })
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
