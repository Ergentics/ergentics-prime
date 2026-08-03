// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import XCTest
@testable import PrimeCore

final class PrimeNativeDecoderAuthorityTests:
    XCTestCase
{
    func testSupersedingAuthorityValidates() throws {
        try PrimeNativeDecoderAuthorityPlan.frozenV1
            .validate()
    }

    func testHistoricalLlamaBindingCannotSelectFutureDecoder()
        throws
    {
        let authority =
            PrimeNativeDecoderAuthorityPlan.frozenV1
        let historical =
            PrimeNativeArcContinuityPlan.frozenV1

        XCTAssertEqual(
            authority.historicalMechanicsImplementation,
            historical.continuationModelImplementation
        )
        XCTAssertTrue(
            authority.historicalMechanicsReceiptsRemainValid
        )
        XCTAssertFalse(
            authority.historicalMechanicsReceiptMutationAuthorized
        )
        XCTAssertFalse(
            authority.historicalMechanicsMaySelectFutureDecoder
        )
        XCTAssertFalse(
            authority.thirdPartyDecoderImplementationAuthorized
        )
        XCTAssertEqual(
            authority.historicalMLXLLMTargetAllowlist,
            [
                "PrimeGPUCalibration",
                "PrimeNative3BMetalContinuationProbe",
            ]
        )
        XCTAssertNotEqual(
            authority.authoritativeImplementationID,
            authority.historicalMechanicsImplementation
        )
    }

    func testPinnedLogicDonorIsReferenceOnlyAndCannotExecutePython()
        throws
    {
        let authority =
            PrimeNativeDecoderAuthorityPlan.frozenV1

        XCTAssertEqual(
            authority.sourceDonorRepository,
            "Ergentics/ergentics-logic"
        )
        XCTAssertEqual(
            authority.sourceDonorRevision,
            "97be84b2790b79ce79558d6bade846a532226540"
        )
        XCTAssertEqual(
            authority.sourceDonorPath,
            "Sources/ModelKit/model.py"
        )
        XCTAssertEqual(
            authority.sourceDonorGitBlob,
            "fcc471205780bf742fb7d70f5d4fdb073b90f216"
        )
        XCTAssertEqual(authority.sourceDonorGitMode, "100644")
        XCTAssertEqual(authority.sourceDonorByteCount, 7_189)
        XCTAssertEqual(
            authority.sourceDonorSHA256,
            "8e28d1e19b5aea4504af62d5ff11b8d318d77c3e232670b9d8751b0996e264a2"
        )
        XCTAssertEqual(
            authority.sourceDonorRightsHolder,
            "Ergentics, LLC"
        )
        XCTAssertEqual(
            authority.sourceDonorLicenseID,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(authority.ownershipEvidencePath, "SEED.md")
        XCTAssertEqual(
            authority.ownershipEvidenceGitBlob,
            "3ed6e27813bf61ca76e3919848ac14f14d4c4c4f"
        )
        XCTAssertEqual(
            authority.ownershipEvidenceGitMode,
            "100644"
        )
        XCTAssertEqual(
            authority.ownershipEvidenceByteCount,
            23_250
        )
        XCTAssertEqual(
            authority.ownershipEvidenceSHA256,
            "e85812acc482d37643c135fd6db8dbfc0007dd5add712ed4407b7076ab978d54"
        )
        XCTAssertFalse(
            authority.sourceDonorRuntimeDependencyAuthorized
        )
        XCTAssertFalse(
            authority.sourceDonorPythonExecutionAuthorized
        )
        XCTAssertFalse(authority.pythonInterpreterAuthorized)
        XCTAssertFalse(
            authority.pythonReferenceParityRunAuthorized
        )
        XCTAssertFalse(
            authority.shellScientificAuthorityAuthorized
        )
    }

    func testOnlySwiftMechanicalPortIsAuthorized()
        throws
    {
        let authority =
            PrimeNativeDecoderAuthorityPlan.frozenV1

        XCTAssertEqual(
            authority.authoritativeImplementationLanguage,
            "Swift"
        )
        XCTAssertEqual(
            authority.authoritativeTarget,
            "PrimeNativeDecoder"
        )
        XCTAssertEqual(
            authority.authoritativeTargetDependencies,
            ["PrimeCore", "MLX", "MLXNN"]
        )
        XCTAssertEqual(
            authority.authoritativePrimitiveModules,
            ["MLX", "MLXNN"]
        )
        XCTAssertEqual(
            authority.trainerOptimizerModule,
            "MLXOptimizers"
        )
        XCTAssertEqual(
            authority.deviceExecutionSubstrate,
            "Metal"
        )
        XCTAssertTrue(
            authority.mechanicalPortOfPinnedArchitectureAuthorized
        )
        XCTAssertFalse(
            authority.newArchitectureFamilyAuthorized
        )
        XCTAssertFalse(authority.adaptationByteExact)
        XCTAssertFalse(authority.donorWeightsImported)
        XCTAssertFalse(authority.donorTokenizerImported)
        XCTAssertFalse(authority.donorCorpusImported)
        XCTAssertFalse(
            authority.historicalCheckpointCompatibilityClaimed
        )
        XCTAssertFalse(
            authority.historicalReceiptSchemaMayAdmitNewEvidence
        )
        XCTAssertTrue(authority.newEvidenceSchemaRequired)
        XCTAssertFalse(
            authority.thirdPartyPretrainedWeightsAuthorized
        )
        XCTAssertFalse(authority.functionalTrainingAuthorized)
        XCTAssertFalse(authority.longTrainingAuthorized)
        XCTAssertFalse(authority.profilePromotionAuthorized)
        XCTAssertFalse(authority.quantizationAuthorized)
        XCTAssertFalse(authority.productPromotionAuthorized)
        XCTAssertEqual(
            authority.gqaExtensionStatus,
            "ABSTAIN_requires_explicit_derived_delta"
        )
        XCTAssertEqual(
            authority.initialExecutableProfileScope,
            "pinned_logic_10m_conformance_only"
        )
        XCTAssertEqual(
            authority.deferredProfileInventoryScope,
            "pinned_logic_phase1_300m_configuration_inventoried_execution_not_authorized"
        )
        XCTAssertEqual(
            authority.mlxLLMRootDependencyDisposition,
            "remove_before_authoritative_decoder_implementation_or_isolate_uncompiled_historical_package"
        )
    }

    func testFutureAuthoritativeTargetFailsClosedUntilQuarantine()
        throws
    {
        let authority =
            PrimeNativeDecoderAuthorityPlan.frozenV1
        let package = withoutWhitespace(
            try source("Package.swift")
        )
        let targetMarker =
            #".target(name:"PrimeNativeDecoder",dependencies:["#
        let targetDirectory = repositoryRoot
            .appendingPathComponent(
                "Sources/PrimeNativeDecoder",
                isDirectory: true
            )

        guard package.contains(authority.authoritativeTarget)
        else {
            XCTAssertFalse(
                FileManager.default.fileExists(
                    atPath: targetDirectory.path
                ),
                "authoritative decoder source appeared before its admitted target"
            )
            return
        }

        XCTAssertTrue(
            package.contains(targetMarker),
            "PrimeNativeDecoder appeared without the one canonical target declaration"
        )

        XCTAssertTrue(
            authority
                .rootMLXLLMDependencyMustBeAbsentBeforeTarget
        )
        for forbiddenRootDependency in [
            "mlx-swift-lm",
            "MLXLLM",
            "MLXLMCommon",
        ] {
            XCTAssertFalse(
                package.contains(forbiddenRootDependency),
                "root dependency was not quarantined: \(forbiddenRootDependency)"
            )
        }
        let exactTarget =
            #".target(name:"PrimeNativeDecoder",dependencies:["PrimeCore",.product(name:"MLX",package:"ergentics-mlx-swift"),.product(name:"MLXNN",package:"ergentics-mlx-swift"),])"#
        XCTAssertTrue(
            package.contains(exactTarget),
            "authoritative decoder target dependency closure drifted"
        )

        var isDirectory: ObjCBool = false
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: targetDirectory.path,
                isDirectory: &isDirectory
            )
        )
        XCTAssertTrue(isDirectory.boolValue)
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: targetDirectory,
                includingPropertiesForKeys: [
                    .isRegularFileKey,
                    .isSymbolicLinkKey,
                ]
            )
        )
        var sourceFileCount = 0
        for case let url as URL in enumerator {
            let values = try url.resourceValues(
                forKeys: [
                    .isRegularFileKey,
                    .isSymbolicLinkKey,
                ]
            )
            XCTAssertFalse(values.isSymbolicLink ?? false)
            guard values.isRegularFile == true else {
                continue
            }
            XCTAssertTrue(
                authority
                    .authoritativeTargetAllowedFileExtensions
                    .contains(url.pathExtension),
                "non-Swift decoder resource admitted: \(url.lastPathComponent)"
            )
            sourceFileCount += 1
            let contents = try String(
                contentsOf: url,
                encoding: .utf8
            )
            for forbidden in
                authority.authoritativeTargetForbiddenTokens
            {
                XCTAssertFalse(
                    contents.contains(forbidden),
                    "decoder source admitted forbidden token \(forbidden): \(url.lastPathComponent)"
                )
            }
        }
        XCTAssertGreaterThan(sourceFileCount, 0)
    }

    func testCriticalAuthorityMutationsFailClosed()
        throws
    {
        let authority =
            PrimeNativeDecoderAuthorityPlan.frozenV1
        let encoded = try JSONEncoder().encode(authority)
        let object = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: encoded)
                as? [String: Any]
        )
        let mutations: [(String, Any)] = [
            ("historicalMechanicsMaySelectFutureDecoder", true),
            ("historicalMechanicsReceiptMutationAuthorized", true),
            ("sourceDonorRuntimeDependencyAuthorized", true),
            ("sourceDonorPythonExecutionAuthorized", true),
            ("pythonInterpreterAuthorized", true),
            ("sourceDonorRightsHolder", "unknown"),
            ("ownershipEvidenceSHA256", String(repeating: "0", count: 64)),
            ("rootMLXLLMDependencyMustBeAbsentBeforeTarget", false),
            ("thirdPartyPretrainedWeightsAuthorized", true),
            ("thirdPartyDecoderImplementationAuthorized", true),
            ("functionalTrainingAuthorized", true),
            ("longTrainingAuthorized", true),
            ("quantizationAuthorized", true),
            ("authoritativeImplementationID", "MLXLLM.LlamaModel"),
            (
                "initialExecutableProfileScope",
                "historical_exact_3b_gqa"
            ),
        ]

        for (key, value) in mutations {
            var mutated = object
            mutated[key] = value
            let data = try JSONSerialization.data(
                withJSONObject: mutated,
                options: [.sortedKeys]
            )
            let decoded = try JSONDecoder().decode(
                PrimeNativeDecoderAuthorityPlan.self,
                from: data
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "authority mutation was admitted: \(key)"
            )
        }
    }

    func testMLXLLMIsQuarantinedToHistoricalTargets()
        throws
    {
        let authority =
            PrimeNativeDecoderAuthorityPlan.frozenV1
        let package = withoutWhitespace(
            try source("Package.swift")
        )
        let mlxLLMProduct =
            #".product(name:"MLXLLM",package:"mlx-swift-lm")"#
        XCTAssertEqual(
            occurrences(of: mlxLLMProduct, in: package),
            authority.historicalMLXLLMTargetAllowlist.count
        )
        XCTAssertEqual(
            occurrences(of: "MLXLLM", in: package),
            authority.historicalMLXLLMTargetAllowlist.count,
            "Package.swift contains an unclassified MLXLLM token"
        )
        for target in
            authority.historicalMLXLLMTargetAllowlist
        {
            let declaration = try targetDeclaration(
                kind: "executableTarget",
                name: target,
                in: package
            )
            XCTAssertEqual(
                occurrences(
                    of: mlxLLMProduct,
                    in: declaration
                ),
                1,
                "historical MLXLLM binding moved: \(target)"
            )
        }

        let sources = repositoryRoot.appendingPathComponent(
            "Sources",
            isDirectory: true
        )
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: sources,
                includingPropertiesForKeys: nil
            )
        )
        let importTokenPattern = try NSRegularExpression(
            pattern: #"\bimport\b"#
        )
        var importingTargets = Set<String>()
        var referencePaths = Set<String>()
        for case let url as URL in enumerator
        where url.pathExtension == "swift" {
            let contents = try String(
                contentsOf: url,
                encoding: .utf8
            )
            let relative = url.path.dropFirst(
                repositoryRoot.path.count + 1
            )
            if contents.contains("MLXLLM") {
                referencePaths.insert(String(relative))
            }
            let sourceRange = NSRange(
                contents.startIndex...,
                in: contents
            )
            if let expectedImportTokenCount =
                authority
                    .historicalMLXLLMNonImportReferenceImportTokenCounts[
                        String(relative)
                    ]
            {
                XCTAssertEqual(
                    importTokenPattern.numberOfMatches(
                        in: contents,
                        range: sourceRange
                    ),
                    expectedImportTokenCount,
                    "non-import historical reference changed its import-token count: \(relative)"
                )
            }
            let mlxLLMImportCount =
                try mlxLLMImportCount(in: contents)
            guard mlxLLMImportCount > 0 else {
                continue
            }
            XCTAssertEqual(
                mlxLLMImportCount,
                1,
                "source contains multiple MLXLLM import declarations: \(relative)"
            )
            let targetRelative = url.path.dropFirst(
                sources.path.count + 1
            )
            let target = try XCTUnwrap(
                targetRelative.split(separator: "/").first
            )
            importingTargets.insert(String(target))
        }
        XCTAssertEqual(
            importingTargets,
            Set(authority.historicalMLXLLMTargetAllowlist)
        )
        XCTAssertEqual(
            referencePaths,
            Set(
                authority
                    .historicalMLXLLMSourceReferenceAllowlist
            ),
            "Sources contain an unclassified MLXLLM reference"
        )
    }

    func testMLXLLMImportScannerHandlesValidSwiftForms()
        throws
    {
        for source in [
            "import MLXLLM\n",
            "import\nMLXLLM\n",
            "@_implementationOnly import MLXLLM\n",
            "import struct MLXLLM.LlamaModel\n",
        ] {
            XCTAssertEqual(
                try mlxLLMImportCount(in: source),
                1,
                "valid Swift import form escaped quarantine: \(source)"
            )
        }
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .standardizedFileURL
    }

    private func source(_ relativePath: String)
        throws -> String
    {
        try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    relativePath
                ),
            encoding: .utf8
        )
    }

    private func withoutWhitespace(
        _ value: String
    ) -> String {
        String(
            value.unicodeScalars.filter {
                !CharacterSet.whitespacesAndNewlines
                    .contains($0)
            }
        )
    }

    private func occurrences(
        of needle: String,
        in value: String
    ) -> Int {
        value.components(
            separatedBy: needle
        ).count - 1
    }

    private func targetDeclaration(
        kind: String,
        name: String,
        in compactPackage: String
    ) throws -> String {
        let prefix =
            #".\#(kind)(name:"\#(name)",dependencies:["#
        let start = try XCTUnwrap(
            compactPackage.range(of: prefix)
        )
        let suffix = compactPackage[start.lowerBound...]
        let end = try XCTUnwrap(
            suffix.range(of: "])")
        )
        return String(
            compactPackage[
                start.lowerBound ..< end.upperBound
            ]
        )
    }

    private func mlxLLMImportCount(
        in source: String
    ) throws -> Int {
        let pattern = try NSRegularExpression(
            pattern:
                #"\bimport\s+(?:(?:typealias|struct|class|enum|protocol|let|var|func)\s+)?MLXLLM\b"#
        )
        return pattern.numberOfMatches(
            in: source,
            range: NSRange(source.startIndex..., in: source)
        )
    }
}
