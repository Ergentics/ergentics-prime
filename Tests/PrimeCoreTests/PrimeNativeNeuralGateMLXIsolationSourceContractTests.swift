import Foundation
import XCTest

final class
    PrimeNativeNeuralGateMLXIsolationSourceContractTests:
    XCTestCase
{
    func testMainTestBundleRemainsMLXFreeAndValidationPackageIsPinned()
        throws
    {
        let package =
            withoutWhitespace(
                try source("Package.swift")
            )
        XCTAssertTrue(
            package.contains(
                #".library(name:"PrimeNativeNeuralGateMLXValidationMechanics",targets:["PrimeNativeCorpusReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics","PrimeNativeNeuralGateCorrectedEvaluationMechanics","PrimeNativeNeuralGateCorrectedFixtureAuthority","PrimeNativeNeuralGatePromptSolver","PrimeNativeNeuralGateLogitSidecarMechanics","PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",])"#
            )
        )
        let mainTestTarget = try targetDeclaration(
            kind: "testTarget",
            name: "PrimeCoreTests",
            in: package
        )
        XCTAssertFalse(
            mainTestTarget.contains(".product("),
            "main XCTest target must not link an external package product"
        )
        XCTAssertEqual(
            try directTargetDependencies(
                in: mainTestTarget
            ),
            Set([
                "PrimeCore",
                "PrimeNativeCorpusReplay",
                "PrimeNativeCorpusReplayMechanics",
                "PrimeNativeNeuralGateContract",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayTransport",
                "PrimeNativeNeuralGateReplayComposition",
                "PrimeNativeNeuralGateReplaySourceBinding",
                "PrimeNativeNeuralGateReplaySourceComposition",
                "PrimeNativeNeuralGateReplayCaptureInventory",
                "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
                "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
                "PrimeNativeNeuralGateCorrectedMechanics",
                "PrimeNativeNeuralGateCorrectedEvaluationMechanics",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
                "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
                "PrimeNativeNeuralGateSemanticRecordContracts",
                "PrimeNativeNeuralGateCorrectedMutationProducer",
                "PrimeNativeNeuralGateCorrectedMutationDetector",
                "PrimeNativeNeuralGateHistoricalSourceDerivation",
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
                "PrimeNativeNeuralGateCorrectedFixtureAuthority",
                "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
                "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
                "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
                "PrimeNativeNeuralGateRoleArtifactReferenceContracts",
                "PrimeNativeNeuralGateRoleArtifactReferenceAuthority",
                "PrimeNativeNeuralGatePromptSolver",
                "PrimeNativeNeuralGateLogitSidecarMechanics",
            ]),
            "main XCTest target dependency closure changed without an MLX-isolation audit"
        )
        for mlxLinkedTarget in [
            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputation",
            "PrimeTypedOptimizerRestoreMechanics",
        ] {
            XCTAssertFalse(
                mainTestTarget.contains(
                    #""\#(mlxLinkedTarget)""#
                ),
                "main XCTest target links MLX authority: \(mlxLinkedTarget)"
            )
        }
        for auditedSwiftOnlyTarget in [
            "PrimeNativeNeuralGateReplaySourceBinding",
            "PrimeNativeNeuralGateReplaySourceComposition",
            "PrimeNativeNeuralGateReplayCaptureInventory",
            "PrimeNativeNeuralGatePromptTargetCrosswalkAuthority",
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryContracts",
            "PrimeNativeNeuralGateTargetFreeScheduleDeliveryAuthority",
            "PrimeNativeNeuralGateCorrectedProcessOwnershipContracts",
            "PrimeNativeNeuralGateCorrectedEvaluationOwnershipContracts",
            "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            "PrimeNativeNeuralGateCorrectedMutationRecordContracts",
            "PrimeNativeNeuralGateSemanticRecordContracts",
            "PrimeNativeNeuralGateCorrectedMutationProducer",
            "PrimeNativeNeuralGateCorrectedMutationDetector",
            "PrimeNativeNeuralGateHistoricalSourceDerivation",
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            "PrimeNativeNeuralGateTerminalReceiptOwnershipContracts",
            "PrimeNativeNeuralGateRoleArtifactReferenceContracts",
            "PrimeNativeNeuralGateRoleArtifactReferenceAuthority",
        ] {
            XCTAssertEqual(
                occurrences(
                    of: #""\#(auditedSwiftOnlyTarget)""#,
                    in: mainTestTarget
                ),
                1,
                "audited Swift-only test dependency is missing: \(auditedSwiftOnlyTarget)"
            )
        }

        let validationPackage =
            withoutWhitespace(
                try source(
                    "Tests/PrimeNativeNeuralGateMLXValidation/Package.swift"
                )
            )
        XCTAssertTrue(
            validationPackage.contains(
                #".package(path:"../..")"#
            )
        )
        XCTAssertTrue(
            validationPackage.contains(
                #".product(name:"PrimeNativeNeuralGateMLXValidationMechanics",package:"ergentics-prime")"#
            )
        )
        XCTAssertEqual(
            occurrences(
                of: ".package(",
                in: validationPackage
            ),
            1
        )

        let rootMirror =
            try data(
                ".swiftpm/configuration/mirrors.json"
            )
        let validationMirror =
            try data(
                "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration/mirrors.json"
            )
        XCTAssertEqual(
            validationMirror,
            rootMirror
        )

        let resolvedObject =
            try XCTUnwrap(
                try JSONSerialization.jsonObject(
                    with:
                        data(
                            "Tests/PrimeNativeNeuralGateMLXValidation/Package.resolved"
                        )
                ) as? [String: Any]
            )
        let pins =
            try XCTUnwrap(
                resolvedObject["pins"]
                    as? [[String: Any]]
            )
        XCTAssertEqual(
            pins.compactMap {
                $0["identity"] as? String
            },
            [
                "ergentics-mlx-swift",
                "swift-numerics",
            ]
        )
        let mlxPin =
            try XCTUnwrap(
                pins.first {
                    $0["identity"] as? String
                        == "ergentics-mlx-swift"
                }
            )
        let state =
            try XCTUnwrap(
                mlxPin["state"]
                    as? [String: Any]
            )
        XCTAssertEqual(
            state["revision"] as? String,
            "d37885a278f1c37484a94d0f401a418735e66519"
        )
    }

    func testNoMainBundleTestSourceImportsMLXLinkedModules()
        throws
    {
        let directory =
            repositoryRoot.appendingPathComponent(
                "Tests/PrimeCoreTests",
                isDirectory: true
            )
        let enumerator =
            try XCTUnwrap(
                FileManager.default.enumerator(
                    at: directory,
                    includingPropertiesForKeys:
                        nil
                )
            )
        let forbiddenImports = [
            "import MLX\n",
            "import MLXNN\n",
            "import MLXOptimizers\n",
            "import MLXLLM\n",
            "import PrimeNativeNeuralGateMLXLogSoftmaxRecomputation\n",
        ]
        var swiftFileCount = 0
        for case let url as URL in enumerator
        where url.pathExtension == "swift" {
            swiftFileCount += 1
            let contents =
                try String(
                    contentsOf: url,
                    encoding: .utf8
                )
            for forbidden in forbiddenImports {
                XCTAssertFalse(
                    contents.contains(forbidden),
                    "main XCTest source imports MLX-linked authority: \(url.lastPathComponent)"
                )
            }
        }
        XCTAssertGreaterThan(swiftFileCount, 0)
        for movedName in [
            "PrimeNativeNeuralGateMLXLogSoftmaxRecomputationTests.swift",
            "PrimeNativeNeuralGateLogitSidecarExhaustiveIntegrationTests.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(
                    atPath:
                        directory
                        .appendingPathComponent(
                            movedName
                        ).path
                )
            )
            XCTAssertTrue(
                FileManager.default.fileExists(
                    atPath:
                        repositoryRoot
                        .appendingPathComponent(
                            "Tests/PrimeNativeNeuralGateMLXValidation/Tests/PrimeNativeNeuralGateMLXValidationTests/\(movedName)"
                        ).path
                )
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

    private func data(
        _ relativePath: String
    ) throws -> Data {
        try Data(
            contentsOf:
                repositoryRoot
                .appendingPathComponent(
                    relativePath
                )
        )
    }

    private func source(
        _ relativePath: String
    ) throws -> String {
        guard let value =
            String(
                data:
                    try data(relativePath),
                encoding: .utf8
            )
        else {
            throw CocoaError(
                .fileReadInapplicableStringEncoding
            )
        }
        return value
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
        let prefix = #".\#(kind)(name:"\#(name)",dependencies:["#
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

    private func directTargetDependencies(
        in targetDeclaration: String
    ) throws -> Set<String> {
        let prefix = "dependencies:["
        let start = try XCTUnwrap(
            targetDeclaration.range(of: prefix)
        )
        let end = try XCTUnwrap(
            targetDeclaration.range(
                of: "])",
                options: .backwards
            )
        )
        let list = targetDeclaration[
            start.upperBound ..< end.lowerBound
        ]
        var dependencies = Set<String>()
        for token in list.split(
            separator: ",",
            omittingEmptySubsequences: true
        ) {
            guard token.count >= 2,
                  token.hasPrefix("\""),
                  token.hasSuffix("\"")
            else {
                throw CocoaError(
                    .fileReadCorruptFile
                )
            }
            let name = String(
                token.dropFirst().dropLast()
            )
            guard !name.isEmpty,
                  dependencies.insert(name).inserted
            else {
                throw CocoaError(
                    .fileReadCorruptFile
                )
            }
        }
        return dependencies
    }
}
