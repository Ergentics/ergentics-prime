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
        XCTAssertTrue(
            package.contains(
                #".testTarget(name:"PrimeCoreTests",dependencies:["PrimeCore","PrimeNativeCorpusReplay","PrimeNativeCorpusReplayMechanics","PrimeNativeNeuralGateContract","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateReplayComposition","PrimeNativeNeuralGateCorrectedMechanics","PrimeNativeNeuralGateCorrectedEvaluationMechanics","PrimeNativeNeuralGateCorrectedFixtureAuthority","PrimeNativeNeuralGatePromptSolver","PrimeNativeNeuralGateLogitSidecarMechanics",])"#
            )
        )

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
                "mlx-swift-lm",
                "swift-numerics",
                "swift-syntax",
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
}
