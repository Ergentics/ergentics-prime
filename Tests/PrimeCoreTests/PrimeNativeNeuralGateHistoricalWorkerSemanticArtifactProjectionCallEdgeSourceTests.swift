// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdgeSourceTests:
    XCTestCase
{
    private static let workerTargetName =
        "PrimeNativeNeuralGateHistoricalFixtureWorker"
    private static let primaryWorkerRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift"
    private static let exporterCallEdgeRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift"
    private static let projectionCallEdgeRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift"
    private static let decoderCallEdgeRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactDecoderCallEdge.swift"
    private static let fixtureRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved"
    private static let projectionCallEdgeByteCount: UInt64 = 1_227
    private static let projectionCallEdgeSHA256 =
        "dce631bd4749a05d8f04323b51c4da37e5ef67df14b950f1e5eee1d1565e0964"

    func testProjectionCallEdgeIsTheExactPrivateTypedExpression()
        throws
    {
        let bytes = try checkedInData(
            Self.projectionCallEdgeRelativePath
        )
        XCTAssertEqual(
            UInt64(bytes.count),
            Self.projectionCallEdgeByteCount
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: bytes),
            Self.projectionCallEdgeSHA256
        )

        let source = try checkedInString(
            Self.projectionCallEdgeRelativePath
        )
        let importLines = source.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter {
            $0.hasPrefix("import ")
        }
        XCTAssertEqual(
            importLines,
            [
                "import PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                "import PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            ]
        )

        let code = source.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter {
            !$0.isEmpty && !$0.hasPrefix("//")
        }.joined().filter { !$0.isWhitespace }
        let methodName =
            "sourceBoundHistoricalEvidenceSemanticArtifactProjectionCallEdge"
        let projectorType =
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
        let expected = [
            "importPrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            "importPrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            "extensionPrimeNativeNeuralGateHistoricalFixtureWorker{",
            "privatestaticfunc",
            methodName,
            "(evidence:PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence,",
            "context:PrimeNativeNeuralGateHistoricalProjectionContext)",
            "throws->PrimeNativeNeuralGateHistoricalProjectedArtifactSet{",
            "try",
            projectorType,
            ".pro" + "ject(evidence:evidence,context:context)",
            "}}",
        ].joined()
        XCTAssertEqual(code, expected)
        XCTAssertEqual(
            occurrenceCount(
                of: projectorType + ".pro" + "ject(",
                in: code
            ),
            1
        )

        for forbidden in [
            "importFoundation",
            "importDarwin",
            "importPrimeCore",
            "importErgenticsPrimeRuntime",
            "importPrimeNativeNeuralGateHistoricalReplayMechanics",
            "importPrimeNativeNeuralGateReplayTransport",
            "importPrimeNativeNeuralGateReplayArtifactContracts",
            "importPrimeNativeNeuralGateReplayMechanics",
            "importPrimeNativeNeuralGateSemanticRecordContracts",
            "importMLX",
            "importMetal",
            "importNetwork",
            "Bundle.",
            "FileManager",
            "FileHandle",
            "Data(",
            "String(contentsOf:",
            "Process(",
            "posix_spawn",
            "execve(",
            "system(",
            "popen(",
            "CommandLine",
            "Darwin.exit",
            "JSONEncoder",
            "JSONDecoder",
            "PropertyListEncoder",
            "PropertyListDecoder",
            "URLSession",
            "NWConnection",
            "Task{",
            "DispatchQueue",
            "print(",
            "debugPrint(",
            "fatalError(",
            "precondition(",
            "try!",
            ".materialize(",
            ".export(",
            ".observe(",
            "ReplayTransport",
            ".encode(",
            ".decode(",
            ".write(",
            ".publish(",
            ".seal(",
            ".launch(",
            "Receipt",
            "sourceBindingV7",
            "PrimeNativeNeuralGateHistoricalProjectionContext(",
            ".map(",
            ".reduce(",
            ".sorted(",
        ] {
            XCTAssertFalse(code.contains(forbidden), forbidden)
        }
    }

    func testWorkerInventoryPreservesFrozenV17InputsAndAddsOnlyTheV19Source()
        throws
    {
        let expected: [(String, UInt64, String)] = [
            (
                Self.primaryWorkerRelativePath,
                2_298,
                "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
            ),
            (
                Self.exporterCallEdgeRelativePath,
                1_512,
                "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319"
            ),
            (
                Self.projectionCallEdgeRelativePath,
                Self.projectionCallEdgeByteCount,
                Self.projectionCallEdgeSHA256
            ),
            (
                Self.fixtureRelativePath,
                1_949,
                "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
            ),
        ]
        for (relativePath, byteCount, sha256) in expected {
            let data = try checkedInData(relativePath)
            XCTAssertEqual(UInt64(data.count), byteCount, relativePath)
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: data),
                sha256,
                relativePath
            )
        }

        let workerDirectory = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(Self.workerTargetName)
        XCTAssertEqual(
            try recursiveRegularFilePaths(in: workerDirectory),
            [
                Self.fixtureRelativePath,
                Self.exporterCallEdgeRelativePath,
                Self.primaryWorkerRelativePath,
                Self.decoderCallEdgeRelativePath,
                Self.projectionCallEdgeRelativePath,
            ]
        )
    }

    func testPriorWorkerSourcesCannotNameLaterPrivateMembers()
        throws
    {
        let main = try checkedInString(
            Self.primaryWorkerRelativePath
        )
        let exporterEdge = try checkedInString(
            Self.exporterCallEdgeRelativePath
        )
        let projectionEdge = try checkedInString(
            Self.projectionCallEdgeRelativePath
        )
        let methodName =
            "sourceBoundHistoricalEvidenceSemanticArtifactProjectionCallEdge"
        let projectorType =
            "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
        let decoderMethodName =
            "sourceBoundHistoricalSemanticArtifactDecoderCallEdge"

        XCTAssertFalse(main.contains(methodName))
        XCTAssertFalse(main.contains(projectorType))
        XCTAssertFalse(exporterEdge.contains(methodName))
        XCTAssertFalse(exporterEdge.contains(projectorType))
        XCTAssertFalse(main.contains(decoderMethodName))
        XCTAssertFalse(exporterEdge.contains(decoderMethodName))
        XCTAssertFalse(projectionEdge.contains(decoderMethodName))
        XCTAssertFalse(main.contains("CommandLine.arguments"))
        let compactMain = main.filter { !$0.isWhitespace }
        XCTAssertTrue(
            compactMain.contains(
                "staticfuncmain(){Darwin.exit(unavailableExitStatus)}"
            )
        )
        XCTAssertEqual(
            occurrenceCount(of: "staticfuncmain()", in: compactMain),
            1
        )
    }

    func testPackagePreservesTheV17PrefixAndAppendsOnlyTheV19Dependency()
        throws
    {
        let package = try checkedInString("Package.swift")
            .filter { !$0.isWhitespace }
        XCTAssertTrue(
            package.contains(
                #".executableTarget(name:"PrimeNativeNeuralGateHistoricalFixtureWorker",dependencies:["PrimeCore","ErgenticsPrimeRuntime","PrimeNativeNeuralGateHistoricalReplayMechanics","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection","PrimeNativeNeuralGateHistoricalSemanticArtifactDecoder",],resources:[.copy("HistoricalFixtureEvidence"),])"#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",dependencies:["PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateReplayArtifactContracts","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateSemanticRecordContracts",])"#
            )
        )
        let targetsStart = try XCTUnwrap(
            package.range(of: "targets:[")
        ).lowerBound
        XCTAssertFalse(
            package[..<targetsStart].contains(Self.workerTargetName)
        )
        XCTAssertFalse(
            package[..<targetsStart].contains(
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection"
            )
        )
    }

    private func occurrenceCount(
        of needle: String,
        in haystack: String
    ) -> Int {
        guard !needle.isEmpty else { return 0 }
        var count = 0
        var searchStart = haystack.startIndex
        while let range = haystack.range(
            of: needle,
            range: searchStart ..< haystack.endIndex
        ) {
            count += 1
            searchStart = range.upperBound
        }
        return count
    }

    private func checkedInData(
        _ relativePath: String
    ) throws -> Data {
        try Data(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    relativePath
                )
        )
    }

    private func checkedInString(
        _ relativePath: String
    ) throws -> String {
        try String(
            contentsOf:
                repositoryRoot.appendingPathComponent(
                    relativePath
                ),
            encoding: .utf8
        )
    }

    private func recursiveRegularFilePaths(
        in directory: URL
    ) throws -> [String] {
        let keys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isRegularFileKey,
            .isSymbolicLinkKey,
        ]
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: directory,
                includingPropertiesForKeys: Array(keys),
                options: []
            )
        )
        let rootPath = repositoryRoot.standardizedFileURL.path + "/"
        var paths: [String] = []
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(
                forKeys: keys
            )
            let path = fileURL.standardizedFileURL.path
            XCTAssertTrue(path.hasPrefix(rootPath), path)
            guard path.hasPrefix(rootPath) else { continue }
            let relativePath = String(
                path.dropFirst(rootPath.count)
            )
            if values.isSymbolicLink == true {
                throw InventoryError.symbolicLink(relativePath)
            }
            if values.isRegularFile == true {
                paths.append(relativePath)
                continue
            }
            if values.isDirectory == true {
                continue
            }
            throw InventoryError.unsupportedNode(relativePath)
        }
        return paths.sorted()
    }

    private enum InventoryError: Error, Equatable {
        case symbolicLink(String)
        case unsupportedNode(String)
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
