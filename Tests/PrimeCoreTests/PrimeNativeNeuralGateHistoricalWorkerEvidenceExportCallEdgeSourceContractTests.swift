import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContractTests:
    XCTestCase
{
    private typealias Contract =
        PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContract

    private static let primaryWorkerRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalFixtureWorker.swift"
    private static let callEdgeRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalEvidenceExportCallEdge.swift"
    private static let projectionCallEdgeRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/PrimeNativeNeuralGateHistoricalWorkerSemanticArtifactProjectionCallEdge.swift"
    private static let fixtureResourceRelativePath =
        "Sources/PrimeNativeNeuralGateHistoricalFixtureWorker/HistoricalFixtureEvidence/Package.resolved"
    private static let sourceContractSHA256 =
        "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8"

    func testFrozenContractBindsExactSourcePackageDeltaAndAuthorityCeiling()
        throws
    {
        let contract = Contract.frozenV1

        XCTAssertNoThrow(try contract.validate())
        XCTAssertEqual(contract.schemaVersion, 1)
        XCTAssertEqual(
            contract.contractID,
            "prime_source_bound_historical_worker_evidence_export_call_edge_v14"
        )
        XCTAssertEqual(contract.rightsHolder, "Ergentics, LLC")
        XCTAssertEqual(
            contract.licenseExpression,
            "LicenseRef-Ergentics-Proprietary"
        )
        XCTAssertEqual(
            contract.preservedWorkerSourceContractID,
            "prime_source_bound_historical_fixture_worker_v11"
        )
        XCTAssertEqual(
            contract.preservedWorkerSourceContractSHA256,
            "64f0de29eed04145db6b598f2895bf9ee9d7804b03b35971f1ca77a72f76e9fb"
        )
        XCTAssertEqual(
            contract.preservedExporterSourceContractID,
            "prime_source_bound_historical_evidence_export_source_v13"
        )
        XCTAssertEqual(
            contract.preservedExporterSourceContractSHA256,
            "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e"
        )
        XCTAssertEqual(
            contract.preservedTopologyV13ID,
            "prime_stage_b_source_bound_historical_evidence_export_source_topology_v13"
        )
        XCTAssertEqual(
            contract.preservedTopologyV13SHA256,
            "b1564c277a50b8bc2b2ba325809130920dcb123f0d02297efba73e3bb3aec4ea"
        )

        XCTAssertEqual(
            contract.workerTargetName,
            "PrimeNativeNeuralGateHistoricalFixtureWorker"
        )
        XCTAssertEqual(
            contract.primaryWorkerSourceRelativePath,
            Self.primaryWorkerRelativePath
        )
        XCTAssertEqual(contract.primaryWorkerSourceByteCount, 2_298)
        XCTAssertEqual(
            contract.primaryWorkerSourceSHA256,
            "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
        )
        XCTAssertFalse(contract.primaryWorkerSourceChanged)
        XCTAssertEqual(
            contract.callEdgeSourceRelativePath,
            Self.callEdgeRelativePath
        )
        XCTAssertEqual(contract.callEdgeSourceByteCount, 1_512)
        XCTAssertEqual(
            contract.callEdgeSourceSHA256,
            "d3ac7fcddd43844e92b61764c458dfce6291471fd465b1bb52f5186814e10319"
        )
        XCTAssertEqual(
            contract.orderedWorkerSwiftSourceRelativePaths,
            [
                Self.callEdgeRelativePath,
                Self.primaryWorkerRelativePath,
            ]
        )
        XCTAssertEqual(contract.exactWorkerSwiftSourceFileCount, 2)

        XCTAssertEqual(
            contract.fixtureResourceRelativePath,
            Self.fixtureResourceRelativePath
        )
        XCTAssertEqual(contract.fixtureResourceByteCount, 1_949)
        XCTAssertEqual(
            contract.fixtureResourceSHA256,
            "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
        )
        XCTAssertFalse(contract.fixtureResourceChanged)

        XCTAssertEqual(
            contract.preservedWorkerDirectLocalDependencyNames,
            [
                "PrimeCore",
                "ErgenticsPrimeRuntime",
                "PrimeNativeNeuralGateHistoricalReplayMechanics",
                "PrimeNativeNeuralGateReplayTransport",
            ]
        )
        XCTAssertEqual(
            contract.workerDirectLocalDependencyNames,
            contract.preservedWorkerDirectLocalDependencyNames
                + [
                    "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
                ]
        )
        XCTAssertEqual(contract.exactAddedWorkerDependencyCount, 1)
        XCTAssertEqual(
            contract.addedWorkerDependencyTargetName,
            "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
        )
        XCTAssertTrue(contract.preservedDependenciesRemainExactPrefix)

        XCTAssertEqual(
            contract.callEdgeEnclosingTypeName,
            contract.workerTargetName
        )
        XCTAssertEqual(
            contract.callEdgeMethodName,
            "sourceBoundHistoricalEvidenceExportCallEdge"
        )
        XCTAssertEqual(
            contract.callEdgeNormalizedSignature,
            "private static func sourceBoundHistoricalEvidenceExportCallEdge() throws -> PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence"
        )
        XCTAssertEqual(contract.callEdgeAccessLevel, "private")
        XCTAssertFalse(contract.callEdgeDeclaredInMainSource)
        XCTAssertTrue(contract.callEdgeUsesBundleModule)
        XCTAssertEqual(contract.callEdgeResourceName, "Package")
        XCTAssertEqual(contract.callEdgeResourceExtension, "resolved")
        XCTAssertEqual(
            contract.callEdgeResourceSubdirectory,
            "HistoricalFixtureEvidence"
        )
        XCTAssertEqual(
            contract.callEdgeMaterializerTypeName,
            "EngineProposesNativeLanguageVerifyAbstainFixture"
        )
        XCTAssertEqual(
            contract.callEdgeExporterTypeName,
            "PrimeNativeNeuralGateHistoricalEvidenceExporter"
        )
        XCTAssertEqual(contract.callEdgeExporterMethodName, "export")
        XCTAssertEqual(
            contract.callEdgeExporterInputExpression,
            "fixture.materials"
        )
        XCTAssertEqual(
            contract.callEdgeOutputSwiftTypeName,
            "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence"
        )

        XCTAssertFalse(contract.mainSourceContainsExporterImportOrSymbol)
        XCTAssertTrue(contract.mainRemainsUnconditionalUnavailableExit)
        XCTAssertEqual(contract.unavailableExitStatus, 78)
        XCTAssertFalse(contract.mainCanReachCallEdge)
        XCTAssertFalse(contract.callEdgeSourceContainsMainDeclaration)
        XCTAssertFalse(contract.workerDeclaredAsProduct)
        XCTAssertTrue(contract.workerTargetRemainsExecutable)
        XCTAssertTrue(contract.packageGraphChanged)
        XCTAssertTrue(contract.workerSourceInventoryChanged)
        XCTAssertFalse(
            contract.exporterTargetSourceOrDependenciesChanged
        )
        XCTAssertFalse(contract.testsImportOrInvokeWorkerOrExporter)

        for nonclaim in [
            contract.workerSealed,
            contract.workerLaunched,
            contract.workerExecuted,
            contract.workerRequestHandlingEnabled,
            contract.fixtureMaterialized,
            contract.exporterInvoked,
            contract.modelExecutionObserved,
            contract.historicalGateExecuted,
            contract.historicalEvidenceObserved,
            contract.evidenceEncodedOrPublished,
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
            XCTAssertFalse(nonclaim)
        }
        XCTAssertEqual(
            contract.nextImplementationPrerequisite,
            "design_and_source_bind_the_historical_evidence_carrier_to_frozen_worker_semantic_artifact_projection_without_enabling_worker_request_handling_sealing_launch_execution_or_issuing_source_binding_v7"
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "Package compilation proves only the typed call edge."
            )
        )
        XCTAssertTrue(
            contract.authorityStatement.contains(
                "No worker request handling, sealing, launch"
            )
        )
    }

    func testCanonicalRoundTripAndFrozenHashAreExact()
        throws
    {
        let contract = Contract.frozenV1
        let encoded = try PrimeCanonicalJSON.encode(contract)

        XCTAssertEqual(
            try PrimeCanonicalJSON.decode(
                Contract.self,
                from: encoded
            ),
            contract
        )
        XCTAssertEqual(
            try contract.contentSHA256(),
            Self.sourceContractSHA256
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: encoded),
            Self.sourceContractSHA256
        )
    }

    func testCheckedInWorkerPreservesV14InventoryInsideExactV17Continuation()
        throws
    {
        let contract = Contract.frozenV1
        let workerDirectory = repositoryRoot
            .appendingPathComponent("Sources")
            .appendingPathComponent(contract.workerTargetName)

        let allWorkerFiles = try recursiveRegularFilePaths(
            in: workerDirectory
        )
        XCTAssertEqual(
            allWorkerFiles,
            [
                Self.fixtureResourceRelativePath,
                Self.callEdgeRelativePath,
                Self.primaryWorkerRelativePath,
                Self.projectionCallEdgeRelativePath,
            ]
        )
        XCTAssertEqual(
            allWorkerFiles.filter {
                contract.orderedWorkerSwiftSourceRelativePaths.contains($0)
            },
            contract.orderedWorkerSwiftSourceRelativePaths
        )
        XCTAssertEqual(
            contract.orderedWorkerSwiftSourceRelativePaths.count,
            contract.exactWorkerSwiftSourceFileCount
        )

        for (relativePath, byteCount, sha256) in [
            (
                Self.primaryWorkerRelativePath,
                contract.primaryWorkerSourceByteCount,
                contract.primaryWorkerSourceSHA256
            ),
            (
                Self.callEdgeRelativePath,
                contract.callEdgeSourceByteCount,
                contract.callEdgeSourceSHA256
            ),
            (
                Self.fixtureResourceRelativePath,
                contract.fixtureResourceByteCount,
                contract.fixtureResourceSHA256
            ),
        ] {
            let data = try checkedInData(relativePath)
            XCTAssertEqual(UInt64(data.count), byteCount, relativePath)
            XCTAssertEqual(
                PrimeSHA256.hexDigest(of: data),
                sha256,
                relativePath
            )
        }
    }

    func testPackagePreservesTheExactV14PrefixInsideTheV17WorkerDeclaration()
        throws
    {
        let contract = Contract.frozenV1
        let packageSource = try checkedInString("Package.swift")
        let package = compact(packageSource)
        let workerName = contract.workerTargetName

        XCTAssertTrue(
            package.contains(
                #".executableTarget(name:"PrimeNativeNeuralGateHistoricalFixtureWorker",dependencies:["PrimeCore","ErgenticsPrimeRuntime","PrimeNativeNeuralGateHistoricalReplayMechanics","PrimeNativeNeuralGateReplayTransport","PrimeNativeNeuralGateHistoricalEvidenceExportMechanics","PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",],resources:[.copy("HistoricalFixtureEvidence"),])"#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",dependencies:["ErgenticsPrimeRuntime","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateHistoricalReplayMechanics",])"#
            )
        )
        XCTAssertEqual(
            occurrenceCount(of: workerName, in: package),
            1,
            "the executable target must not also be declared as a product or another target"
        )
        let targetsStart = try XCTUnwrap(
            package.range(of: "targets:[")
        ).lowerBound
        XCTAssertFalse(package[..<targetsStart].contains(workerName))

        XCTAssertEqual(
            Array(
                contract.workerDirectLocalDependencyNames
                    .prefix(
                        contract.preservedWorkerDirectLocalDependencyNames
                            .count
                    )
            ),
            contract.preservedWorkerDirectLocalDependencyNames
        )
        XCTAssertEqual(
            Array(
                contract.workerDirectLocalDependencyNames.dropFirst(
                    contract.preservedWorkerDirectLocalDependencyNames
                        .count
                )
            ),
            [contract.addedWorkerDependencyTargetName]
        )

        let primeCoreTestsStart = try XCTUnwrap(
            package.range(
                of: #".testTarget(name:"PrimeCoreTests",dependencies:["#
            )
        ).lowerBound
        let followingDeclarationSearchStart = package.index(
            after: primeCoreTestsStart
        )
        let nextTestTargetStart = try XCTUnwrap(
            package.range(
                of: ".testTarget(",
                range:
                    followingDeclarationSearchStart..<package.endIndex
            )
        ).lowerBound
        let primeCoreTestsDeclaration =
            package[primeCoreTestsStart..<nextTestTargetStart]
        XCTAssertFalse(
            primeCoreTestsDeclaration.contains(workerName)
        )
        XCTAssertFalse(
            primeCoreTestsDeclaration.contains(
                contract.addedWorkerDependencyTargetName
            )
        )
    }

    func testCallEdgeSourceHasExactPrivateBundleMaterializeExportOrder()
        throws
    {
        let contract = Contract.frozenV1
        let source = try checkedInString(Self.callEdgeRelativePath)
        let code = compact(sourceWithoutLineComments(source))

        XCTAssertTrue(
            code.contains(
                "importPrimeNativeNeuralGateHistoricalEvidenceExportMechanics"
            )
        )
        XCTAssertTrue(
            code.contains(
                "importPrimeNativeNeuralGateHistoricalReplayMechanics"
            )
        )
        XCTAssertTrue(
            code.contains(
                "extension\(contract.callEdgeEnclosingTypeName){"
            )
        )
        XCTAssertTrue(
            code.contains(
                "privatestaticfunc\(contract.callEdgeMethodName)()throws->\(contract.callEdgeOutputSwiftTypeName){"
            )
        )
        XCTAssertEqual(
            occurrenceCount(
                of: contract.callEdgeMethodName,
                in: code
            ),
            1
        )

        assertTokensOccurInOrder(
            [
                "guardletpackageResolvedURL=Bundle.module.url(",
                "forResource:\"\(contract.callEdgeResourceName)\"",
                "withExtension:\"\(contract.callEdgeResourceExtension)\"",
                "subdirectory:\"\(contract.callEdgeResourceSubdirectory)\"",
                "letfixture=try\(contract.callEdgeMaterializerTypeName).materialize(packageResolvedURL:packageResolvedURL)",
                "returntry\(contract.callEdgeExporterTypeName).\(contract.callEdgeExporterMethodName)(\(contract.callEdgeExporterInputExpression))",
            ],
            in: code
        )
        XCTAssertEqual(
            occurrenceCount(of: "Bundle.module.url(", in: code),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of: "\(contract.callEdgeMaterializerTypeName).materialize(",
                in: code
            ),
            1
        )
        XCTAssertEqual(
            occurrenceCount(
                of: "\(contract.callEdgeExporterTypeName).\(contract.callEdgeExporterMethodName)(\(contract.callEdgeExporterInputExpression))",
                in: code
            ),
            1
        )
    }

    func testPrimaryMainRemainsByteExactUnavailableAndCannotNameCallEdge()
        throws
    {
        let contract = Contract.frozenV1
        let primaryData = try checkedInData(
            Self.primaryWorkerRelativePath
        )
        let primarySource = try XCTUnwrap(
            String(data: primaryData, encoding: .utf8)
        )
        let primaryCode = compact(
            sourceWithoutLineComments(primarySource)
        )

        XCTAssertEqual(primaryData.count, 2_298)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: primaryData),
            "9f62827d4c35e98fb01f9984b1c227cb681dd42ac4c26147a86e9429958545df"
        )
        XCTAssertTrue(primaryCode.contains("@main"))
        XCTAssertTrue(
            primaryCode.contains(
                "staticletunavailableExitStatus:Int32=78"
            )
        )
        let mainStart = try XCTUnwrap(
            primaryCode.range(of: "staticfuncmain(){")
        ).upperBound
        let mainEnd = try XCTUnwrap(
            primaryCode.range(
                of: "}",
                range: mainStart..<primaryCode.endIndex
            )
        ).lowerBound
        XCTAssertEqual(
            primaryCode[mainStart..<mainEnd],
            "Darwin.exit(unavailableExitStatus)"
        )
        XCTAssertFalse(
            primarySource.contains(
                contract.addedWorkerDependencyTargetName
            )
        )
        XCTAssertFalse(
            primarySource.contains(contract.callEdgeExporterTypeName)
        )
        XCTAssertFalse(
            primarySource.contains(contract.callEdgeMethodName)
        )
    }

    func testCallEdgeContainsNoMainProcessOutputEncodingOrAuthorityPath()
        throws
    {
        let source = try checkedInString(Self.callEdgeRelativePath)
        let code = compact(sourceWithoutLineComments(source))

        for forbiddenCodeSurface in [
            "@main",
            "staticfuncmain(",
            "CommandLine.",
            "Process(",
            "Darwin.",
            "exit(",
            "FileHandle.",
            "OutputStream",
            "JSONEncoder",
            "PropertyListEncoder",
            ".encode(",
            ".write(",
            "print(",
            "stdout",
            "stderr",
            "URLSession",
            "publish(",
            "seal(",
            "launch(",
            "Receipt",
            "receipt",
            "sourceBindingV7",
            "SourceBindingV7",
        ] {
            XCTAssertFalse(
                code.contains(forbiddenCodeSurface),
                forbiddenCodeSurface
            )
        }
    }

    func testTestsDoNotImportOrInvokeWorkerOrExporter()
        throws
    {
        let contract = Contract.frozenV1
        let permittedExporterImportRelativePaths: Set<String> = [
            "Tests/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionTests/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionTests.swift",
            "Tests/PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTests/PrimeNativeNeuralGateHistoricalSemanticArtifactDecoderTests.swift",
        ]
        let testsDirectory = repositoryRoot
            .appendingPathComponent("Tests")
        let swiftTestPaths = try recursiveRegularFilePaths(
            in: testsDirectory,
            skippingHiddenFiles: true
        ).filter { $0.hasSuffix(".swift") }
        let thisTestRelativePath = repositoryRelativePath(
            URL(fileURLWithPath: #filePath)
        )
        var projectionExporterImportCount = 0

        for path in swiftTestPaths {
            let source = try checkedInString(path)
            for line in source.split(
                separator: "\n",
                omittingEmptySubsequences: false
            ) {
                let trimmed = line.trimmingCharacters(
                    in: .whitespaces
                )
                XCTAssertNotEqual(
                    trimmed,
                    "import \(contract.workerTargetName)",
                    path
                )
                XCTAssertNotEqual(
                    trimmed,
                    "@testable import \(contract.workerTargetName)",
                    path
                )
                if trimmed
                    == "import \(contract.addedWorkerDependencyTargetName)"
                    || trimmed
                        == "@testable import \(contract.addedWorkerDependencyTargetName)"
                {
                    XCTAssertTrue(
                        permittedExporterImportRelativePaths.contains(path),
                        path
                    )
                    XCTAssertEqual(
                        trimmed,
                        "@testable import \(contract.addedWorkerDependencyTargetName)",
                        path
                    )
                    projectionExporterImportCount += 1
                }
            }
            guard path != thisTestRelativePath
            else {
                continue
            }
            XCTAssertFalse(
                source.contains(contract.callEdgeMethodName),
                path
            )
            XCTAssertFalse(
                compact(source).contains(
                    "\(contract.callEdgeExporterTypeName).\(contract.callEdgeExporterMethodName)("
                ),
                path
            )
        }
        XCTAssertEqual(
            projectionExporterImportCount,
            permittedExporterImportRelativePaths.count
        )
    }

    func testDecodedMutationsFailClosed()
        throws
    {
        let encoded = try PrimeCanonicalJSON.encode(
            Contract.frozenV1
        )
        let canonicalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded)
                as? [String: Any]
        )

        var dependencyOrderDrift = try XCTUnwrap(
            canonicalObject[
                "worker_direct_local_dependency_names"
            ] as? [String]
        )
        dependencyOrderDrift.swapAt(0, 1)
        let mutations: [(String, String, Any)] = [
            (
                "contract-id",
                "contract_id",
                "prime_source_bound_historical_worker_evidence_export_call_edge_v14_drift"
            ),
            (
                "call-edge-hash",
                "call_edge_source_sha256",
                String(repeating: "0", count: 64)
            ),
            (
                "dependency-order",
                "worker_direct_local_dependency_names",
                dependencyOrderDrift
            ),
            (
                "main-reachability",
                "main_can_reach_call_edge",
                true
            ),
            (
                "worker-execution",
                "worker_executed",
                true
            ),
            (
                "source-binding-authority",
                "source_binding_v7_issued",
                true
            ),
        ]

        for (label, key, value) in mutations {
            var object = canonicalObject
            object[key] = value
            let mutated = try JSONDecoder().decode(
                Contract.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try mutated.validate(),
                label
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContractError,
                    .invalidFrozenContract,
                    label
                )
            }
        }
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
        in directory: URL,
        skippingHiddenFiles: Bool = false
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
                options:
                    skippingHiddenFiles
                        ? [.skipsHiddenFiles]
                        : []
            )
        )
        let rootPath = repositoryRoot.standardizedFileURL.path
            + "/"
        var paths: [String] = []
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(
                forKeys: keys
            )
            let path = fileURL.standardizedFileURL.path
            guard path.hasPrefix(rootPath)
            else {
                XCTFail("inventory escaped repository root: \(path)")
                continue
            }
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

    private func sourceWithoutLineComments(
        _ source: String
    ) -> String {
        source.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map { line in
            guard let comment = line.range(of: "//")
            else {
                return String(line)
            }
            return String(line[..<comment.lowerBound])
        }.joined(separator: "\n")
    }

    private func assertTokensOccurInOrder(
        _ tokens: [String],
        in source: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var cursor = source.startIndex
        for token in tokens {
            guard let range = source.range(
                of: token,
                range: cursor..<source.endIndex
            ) else {
                XCTFail(
                    "missing ordered token: \(token)",
                    file: file,
                    line: line
                )
                return
            }
            cursor = range.upperBound
        }
    }

    private func occurrenceCount(
        of needle: String,
        in haystack: String
    ) -> Int {
        guard !needle.isEmpty
        else {
            return 0
        }
        var count = 0
        var cursor = haystack.startIndex
        while let range = haystack.range(
            of: needle,
            range: cursor..<haystack.endIndex
        ) {
            count += 1
            cursor = range.upperBound
        }
        return count
    }

    private func compact(_ source: String) -> String {
        String(source.filter { !$0.isWhitespace })
    }

    private func repositoryRelativePath(
        _ url: URL
    ) -> String {
        let rootPath = repositoryRoot.standardizedFileURL.path
            + "/"
        let path = url.standardizedFileURL.path
        XCTAssertTrue(path.hasPrefix(rootPath), path)
        guard path.hasPrefix(rootPath)
        else {
            return path
        }
        return String(path.dropFirst(rootPath.count))
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
