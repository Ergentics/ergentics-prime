import Foundation
import XCTest
@testable import PrimeCore

final class PrimeNativeContractMigrationTests:
    XCTestCase
{
    func testFrozenPlanExactlyReconcilesContinuityInventory()
        throws
    {
        let plan =
            PrimeNativeContractMigrationPlan.frozenV1
        let continuity =
            PrimeNativeArcContinuityPlan.frozenV1
        let companionInventory =
            continuity.artifacts.filter {
                $0.authorityOwner
                    == "Ergentics/pmhnp-companion-ergentics"
                    && $0.locatorScope
                        == .repositoryRelativeAtPinnedRevision
            }

        try plan.validate()
        XCTAssertEqual(
            plan.companionRevision,
            "163fc100710ece48119bc25954452d10f6a84f7f"
        )
        XCTAssertEqual(
            plan.companionTreeOID,
            "9009daa4f8a07fbd5897e00b9571cef44ec292db"
        )
        XCTAssertEqual(plan.companionObjectFormat, "sha1")
        XCTAssertEqual(plan.companionRawCommitByteCount, 1_240)
        XCTAssertEqual(
            plan.companionRawCommitSHA256,
            "c1087083018d8b964e67e9f1d0d93d689805459457cd58c8f0d46d54c81e0abe"
        )
        XCTAssertEqual(plan.expectedArtifactCount, 8)
        XCTAssertEqual(plan.artifacts.count, 8)
        XCTAssertEqual(plan.expectedTotalByteCount, 11_969_097)
        XCTAssertEqual(
            plan.artifacts.reduce(UInt64(0)) {
                $0 + $1.byteCount
            },
            11_969_097
        )

        XCTAssertEqual(
            plan.artifacts.map(\.artifactID),
            [
                "native_byte_tokenizer_manifest",
                "native_compositional_corpus_manifest",
                "native_10m_metal_mechanics_report",
                "native_schema4_profile_screen_archive",
                "native_schema6_profile_screen_audit",
                "native_schema6_truth_projection",
                "neuralkit_native_language_verify_abstain_receipt",
                "neuralkit_package_lock",
            ]
        )
        XCTAssertEqual(
            plan.artifacts.map(\.repositoryRelativePath),
            [
                "content-staging/prime-native-byte-tokenizer-manifest.v1.json",
                "content-staging/prime-native-text-corpus-manifest.v1.json",
                "content-staging/prime-native-metal-language-canary-report.latest.json",
                "content-staging/prime-native-language-schema4-profile-screen.v1.tar.xz",
                "content-staging/prime-native-language-schema6-profile-screen-audit.v1.json",
                "content-staging/prime-native-language-schema6-profile-screen-truth-projection.v1.json",
                "content-staging/prime-native-language-schema4-verify-abstain-receipt.v1.json",
                "neural-kit/Package.resolved",
            ]
        )
        XCTAssertEqual(
            plan.artifacts.map(\.gitBlobOID),
            [
                "c2661016dd5a3af21fd6a998f286184ebdd7a196",
                "a01344ad4105d755cfd97324092b15a1b31dc542",
                "e04a264634d5f785e73a4c64b773fd5a4329f896",
                "4b3027164c82af0db1feab8db9da95d3f9e8f9bd",
                "577a7ccbdddbc9c0d249b5fa1ec355c0319d0193",
                "e48445e10e8a39e96a21dcc84bd1d7d92ddfa33c",
                "afe0fde09285c1ad928d2e8f77dfd622b32e6b20",
                "18aef69512c82c3e6cdff192f3aa0a6ee13c702e",
            ]
        )
        XCTAssertEqual(
            plan.artifacts.map(\.byteCount),
            [
                4_790,
                44_803,
                40_833,
                11_830_112,
                38_760,
                2_090,
                5_760,
                1_949,
            ]
        )

        XCTAssertEqual(companionInventory.count, 8)
        XCTAssertEqual(
            companionInventory.map(\.artifactID),
            plan.artifacts.map(\.artifactID)
        )
        XCTAssertEqual(
            companionInventory.map(\.locator),
            plan.artifacts.map(\.repositoryRelativePath)
        )
        XCTAssertEqual(
            companionInventory.map(\.sha256),
            plan.artifacts.map(\.sha256)
        )
        XCTAssertTrue(
            companionInventory.allSatisfy {
                continuity.artifactRepositoryRevisions[
                    $0.artifactID
                ] == plan.companionRevision
            }
        )
    }

    func testStructuralPassReceiptValidates() throws {
        let receipt = makePassReceipt()

        try receipt.validate()
        XCTAssertEqual(receipt.outcome, .pass)
        XCTAssertEqual(
            receipt.claimScope,
            "frozen_companion_blob_resolution_only"
        )
        XCTAssertEqual(receipt.artifacts.count, 8)
        XCTAssertEqual(
            receipt.totalMaterializedByteCount,
            11_969_097
        )
        XCTAssertEqual(
            receipt.mutationSweep.map(\.mutation),
            PrimeNativeContractMigrationMutation.allCases
        )
        XCTAssertTrue(
            receipt.mutationSweep.allSatisfy {
                $0.detected
                    && $0.restored
                    && !$0
                        .independentScientificOracleClaimed
            }
        )
        XCTAssertTrue(
            receipt
                .declaredCompanionInventoryResolutionComplete
        )
        XCTAssertFalse(receipt.compatibilityReplayComplete)
        XCTAssertFalse(receipt.adapterImplementationComplete)
        XCTAssertFalse(receipt.archiveExpanded)
        XCTAssertFalse(receipt.donorExecutionPerformed)
        XCTAssertFalse(receipt.neuralKitExecutionPerformed)
        XCTAssertFalse(receipt.modelTrainingPerformed)
        XCTAssertFalse(receipt.productPromotionAuthorized)
        XCTAssertFalse(
            receipt.independentScientificOracleClaimed
        )
    }

    func testIdenticalTreeWrongRevisionIsRejected() {
        let plan =
            PrimeNativeContractMigrationPlan.frozenV1
        let wrongRevision =
            "71130d543262d0d7483eff3d264ea60ad3c0ded5"
        let observation = repositoryObservation(
            resolvedRevision: wrongRevision,
            treeOID: plan.companionTreeOID
        )

        assertMigrationError(
            .repositoryRevisionMismatch(
                expected: plan.companionRevision,
                observed: wrongRevision
            )
        ) {
            try PrimeNativeContractMigrationResolver
                .validateRepository(
                    observation,
                    plan: plan
                )
        }
    }

    func testIdenticalBlobAtWrongPathIsRejected()
        throws
    {
        let specification =
            try XCTUnwrap(
                PrimeNativeContractMigrationPlan
                    .frozenV1.artifacts.first {
                        $0.artifactID
                            == "neuralkit_package_lock"
                    }
            )
        let exactBlob = PrimeNativeMigrationResolvedGitBlob(
            artifactID: specification.artifactID,
            repositoryRelativePath:
                specification.repositoryRelativePath,
            mode: "100644",
            objectType: "blob",
            gitBlobOID: specification.gitBlobOID,
            data: try exactPackageLockData()
        )
        try PrimeNativeContractMigrationResolver.validate(
            exactBlob,
            against: specification
        )

        let wrongPathBlob =
            PrimeNativeMigrationResolvedGitBlob(
                artifactID: exactBlob.artifactID,
                repositoryRelativePath:
                    "prime-runtime/Package.resolved",
                mode: exactBlob.mode,
                objectType: exactBlob.objectType,
                gitBlobOID: exactBlob.gitBlobOID,
                data: exactBlob.data
            )
        assertMigrationError(
            .resolvedArtifactPathMismatch(
                specification.artifactID
            )
        ) {
            try PrimeNativeContractMigrationResolver.validate(
                wrongPathBlob,
                against: specification
            )
        }
    }

    func testMissingArtifactIsRejectedBeforeBlobAdmission() {
        let plan =
            PrimeNativeContractMigrationPlan.frozenV1
        var blobs = Dictionary(
            uniqueKeysWithValues:
                plan.artifacts.map { specification in
                    (
                        specification.artifactID,
                        PrimeNativeMigrationResolvedGitBlob(
                            artifactID:
                                specification.artifactID,
                            repositoryRelativePath:
                                specification
                                .repositoryRelativePath,
                            mode: "100644",
                            objectType: "blob",
                            gitBlobOID:
                                specification.gitBlobOID,
                            data: Data()
                        )
                    )
                }
        )
        blobs.removeValue(
            forKey: plan.artifacts[0].artifactID
        )
        let input = PrimeNativeMigrationResolvedInput(
            repository: repositoryObservation(),
            gitTool: gitToolBinding(),
            commandObservations: commandObservations(),
            blobsByArtifactID: blobs
        )

        assertMigrationError(.resolvedArtifactSetMismatch) {
            try PrimeNativeContractMigrationResolver
                .validate(input)
        }
    }

    func testChangedBlobBytesAreRejected()
        throws
    {
        let specification =
            try XCTUnwrap(
                PrimeNativeContractMigrationPlan
                    .frozenV1.artifacts.first {
                        $0.artifactID
                            == "neuralkit_package_lock"
                    }
            )
        let exactData = try exactPackageLockData()
        let exactBlob = PrimeNativeMigrationResolvedGitBlob(
            artifactID: specification.artifactID,
            repositoryRelativePath:
                specification.repositoryRelativePath,
            mode: "100644",
            objectType: "blob",
            gitBlobOID: specification.gitBlobOID,
            data: exactData
        )
        try PrimeNativeContractMigrationResolver.validate(
            exactBlob,
            against: specification
        )

        var changedData = exactData
        changedData[changedData.startIndex] ^= 0x01
        let changedBlob =
            PrimeNativeMigrationResolvedGitBlob(
                artifactID: exactBlob.artifactID,
                repositoryRelativePath:
                    exactBlob.repositoryRelativePath,
                mode: exactBlob.mode,
                objectType: exactBlob.objectType,
                gitBlobOID: exactBlob.gitBlobOID,
                data: changedData
            )
        assertMigrationError(
            .resolvedArtifactHashMismatch(
                artifactID: specification.artifactID,
                expected: specification.sha256,
                actual:
                    PrimeSHA256.hexDigest(
                        of: changedData
                    )
            )
        ) {
            try PrimeNativeContractMigrationResolver.validate(
                changedBlob,
                against: specification
            )
        }
    }

    func testAuthorityExpansionIsRejected() throws {
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(
                    PrimeNativeContractMigrationPlan.frozenV1
                )
            ) as? [String: Any]
        )
        object["compatibilityReplayComplete"] = true
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )
        let expanded = try JSONDecoder().decode(
            PrimeNativeContractMigrationPlan.self,
            from: data
        )

        XCTAssertTrue(expanded.compatibilityReplayComplete)
        assertMigrationError(.contractDrift) {
            try expanded.validate()
        }
    }

    func testTypedArgumentsAdmitOnlyCanonicalSeparatedRoots()
        throws
    {
        let base = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-native-resolver-arguments-\(UUID().uuidString)",
                isDirectory: true
            )
        let companion =
            base.appendingPathComponent(
                "companion",
                isDirectory: true
            )
        let prime =
            base.appendingPathComponent(
                "prime",
                isDirectory: true
            )
        let nestedArtifact =
            prime.appendingPathComponent(
                "artifacts/run",
                isDirectory: true
            )
        let externalArtifact =
            base.appendingPathComponent(
                "external-artifact",
                isDirectory: true
            )
        let unauthorizedPrimeOutput =
            prime.appendingPathComponent(
                "output/run",
                isDirectory: true
            )
        let companionChild =
            companion.appendingPathComponent(
                "child",
                isDirectory: true
            )
        for directory in [
            companion,
            prime,
            nestedArtifact,
            externalArtifact,
            unauthorizedPrimeOutput,
            companionChild,
        ] {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }
        defer {
            try? FileManager.default.removeItem(at: base)
        }

        let nested = try
            PrimeNativeContractResolutionArguments.parse([
                "resolver",
                "--companion-root",
                companion.path,
                "--prime-root",
                prime.path,
                "--artifact-root",
                nestedArtifact.path,
            ])
        XCTAssertEqual(nested.companionRoot, companion)
        XCTAssertEqual(nested.primeRoot, prime)
        XCTAssertEqual(nested.artifactRoot, nestedArtifact)

        let reordered = try
            PrimeNativeContractResolutionArguments.parse([
                "resolver",
                "--artifact-root",
                externalArtifact.path,
                "--companion-root",
                companion.path,
                "--prime-root",
                prime.path,
            ])
        XCTAssertEqual(
            reordered.artifactRoot,
            externalArtifact
        )
        XCTAssertEqual(
            try PrimeNativeContractResolutionVerifierArguments
                .parse([
                    "verifier",
                    "--artifact-root",
                    externalArtifact.path,
                ])
                .artifactRoot,
            externalArtifact
        )
        for invalidVerifier in [
            ["verifier"],
            [
                "verifier",
                "--prime-root",
                prime.path,
            ],
            [
                "verifier",
                "--artifact-root",
                "relative",
            ],
        ] {
            XCTAssertThrowsError(
                try PrimeNativeContractResolutionVerifierArguments
                    .parse(invalidVerifier)
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeNativeContractResolutionArgumentError,
                    .invalidVerifierArguments
                )
            }
        }

        let symlink =
            base.appendingPathComponent("companion-link")
        try FileManager.default.createSymbolicLink(
            at: symlink,
            withDestinationURL: companion
        )
        let normalizedPrime =
            prime.deletingLastPathComponent().path
            + "/prime/../prime"
        let invalidVectors: [[String]] = [
            ["resolver"],
            [
                "resolver",
                "--companion-root",
                "relative",
                "--prime-root",
                prime.path,
                "--artifact-root",
                externalArtifact.path,
            ],
            [
                "resolver",
                "--companion-root",
                symlink.path,
                "--prime-root",
                prime.path,
                "--artifact-root",
                externalArtifact.path,
            ],
            [
                "resolver",
                "--companion-root",
                companion.path,
                "--prime-root",
                normalizedPrime,
                "--artifact-root",
                externalArtifact.path,
            ],
            [
                "resolver",
                "--companion-root",
                companion.path,
                "--companion-root",
                companion.path,
                "--prime-root",
                prime.path,
                "--artifact-root",
                externalArtifact.path,
            ],
            [
                "resolver",
                "--unknown-root",
                companion.path,
                "--prime-root",
                prime.path,
                "--artifact-root",
                externalArtifact.path,
            ],
            [
                "resolver",
                "--companion-root",
                companion.path,
                "--prime-root",
                companionChild.path,
                "--artifact-root",
                externalArtifact.path,
            ],
            [
                "resolver",
                "--companion-root",
                companionChild.path,
                "--prime-root",
                companion.path,
                "--artifact-root",
                externalArtifact.path,
            ],
            [
                "resolver",
                "--companion-root",
                companion.path,
                "--prime-root",
                prime.path,
                "--artifact-root",
                companionChild.path,
            ],
            [
                "resolver",
                "--companion-root",
                companion.path,
                "--prime-root",
                prime.path,
                "--artifact-root",
                unauthorizedPrimeOutput.path,
            ],
            [
                "resolver",
                "--companion-root",
                companion.path,
                "--prime-root",
                prime.path,
                "--artifact-root",
                prime.path,
            ],
            [
                "resolver",
                "--companion-root",
                companion.path,
                "--prime-root",
                prime.path,
                "--artifact-root",
                base.path,
            ],
        ]
        for values in invalidVectors {
            XCTAssertThrowsError(
                try PrimeNativeContractResolutionArguments
                    .parse(values)
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeNativeContractResolutionArgumentError,
                    .invalidArguments
                )
            }
        }
    }

    func testReceiptRejectsExecutableCommandAndSourceMutations()
        throws
    {
        let receipt = makePassReceipt()
        try receipt.validate()

        let wrongExecutable = try mutate(receipt) {
            object in
            var executable = object[
                "resolverExecutable"
            ] as! [String: Any]
            executable["relativePath"] =
                "substituted-resolver"
            object["resolverExecutable"] = executable
        }
        XCTAssertThrowsError(
            try wrongExecutable.validate()
        )

        let substitutedArgv = try mutate(receipt) {
            object in
            var observations = object[
                "commandObservations"
            ] as! [[String: Any]]
            observations[0]["argv"] = [
                "--no-replace-objects",
                "-c",
                "core.fsmonitor=false",
                "-C",
                "<repository-root>",
                "status",
            ]
            object["commandObservations"] = observations
        }
        XCTAssertThrowsError(
            try substitutedArgv.validate()
        )

        let substitutedOutput = try mutate(receipt) {
            object in
            var observations = object[
                "commandObservations"
            ] as! [[String: Any]]
            observations[1]["stdoutSHA256"] =
                String(repeating: "c", count: 64)
            object["commandObservations"] = observations
        }
        XCTAssertThrowsError(
            try substitutedOutput.validate()
        )

        let substitutedSourceRevision = try mutate(
            receipt
        ) { object in
            object["resolverSourceRevision"] =
                String(repeating: "c", count: 40)
        }
        XCTAssertThrowsError(
            try substitutedSourceRevision.validate()
        )

        let substitutedSourceCommand = try mutate(
            receipt
        ) { object in
            var observations = object[
                "resolverSourceCommandObservations"
            ] as! [[String: Any]]
            observations.swapAt(0, 1)
            object[
                "resolverSourceCommandObservations"
            ] = observations
        }
        XCTAssertThrowsError(
            try substitutedSourceCommand.validate()
        )
    }

    private func makePassReceipt()
        -> PrimeNativeContractMigrationReceipt
    {
        let plan =
            PrimeNativeContractMigrationPlan.frozenV1
        let artifacts = plan.artifacts.map {
            specification in
            PrimeNativeMigrationMaterializedArtifact(
                artifactID: specification.artifactID,
                donorRelativePath:
                    specification.repositoryRelativePath,
                donorRevision: plan.companionRevision,
                mode: "100644",
                objectType: "blob",
                gitBlobOID: specification.gitBlobOID,
                expectedSHA256: specification.sha256,
                observedSHA256: specification.sha256,
                expectedByteCount: specification.byteCount,
                observedByteCount: specification.byteCount,
                role: specification.role,
                artifact: PrimeArtifactBinding(
                    relativePath:
                        specification
                        .materializedRelativePath,
                    sha256: specification.sha256,
                    byteCount: specification.byteCount,
                    purpose: .immutableData
                )
            )
        }
        let mutations =
            PrimeNativeContractMigrationMutation.allCases.map {
                mutation in
                PrimeNativeContractMigrationMutationRecord(
                    mutation: mutation,
                    detectorID: mutation.detectorID,
                    detected: true,
                    restored: true,
                    independentScientificOracleClaimed:
                        false
                )
            }
        return PrimeNativeContractMigrationReceipt(
            resolverSourceRemoteURL:
                plan.acceptedResolverRemoteURLs[0],
            resolverSourceRevision:
                String(repeating: "a", count: 40),
            resolverSourceTreeOID:
                String(repeating: "b", count: 40),
            resolverSourceTreeClean: true,
            resolverSourceCommandObservations:
                sourceCommandObservations(),
            resolverSourceSnapshot: PrimeArtifactBinding(
                relativePath:
                    PrimeNativeContractMigrationResolver
                    .resolverSourceSnapshotPath,
                sha256: hash("resolver-source-snapshot"),
                byteCount: 1,
                purpose: .immutableData
            ),
            resolverExecutable: PrimeArtifactBinding(
                relativePath:
                    PrimeNativeContractMigrationResolver
                    .resolverExecutablePath,
                sha256: hash("resolver-executable"),
                byteCount: 1,
                purpose: .executable
            ),
            gitTool: gitToolBinding(),
            repository: repositoryObservation(),
            commandObservations: commandObservations(),
            artifacts: artifacts,
            mutationSweep: mutations
        )
    }

    private func repositoryObservation(
        resolvedRevision: String? = nil,
        treeOID: String? = nil
    ) -> PrimeNativeMigrationRepositoryObservation {
        let plan =
            PrimeNativeContractMigrationPlan.frozenV1
        return PrimeNativeMigrationRepositoryObservation(
            observedRemoteURL: plan.acceptedRemoteURLs[0],
            requestedRevision: plan.companionRevision,
            resolvedRevision:
                resolvedRevision ?? plan.companionRevision,
            treeOID: treeOID ?? plan.companionTreeOID,
            objectFormat: plan.companionObjectFormat,
            rawCommitByteCount:
                plan.companionRawCommitByteCount,
            rawCommitSHA256:
                plan.companionRawCommitSHA256
        )
    }

    private func gitToolBinding()
        -> PrimeNativeMigrationGitToolBinding
    {
        PrimeNativeMigrationGitToolBinding(
            absolutePath: "/usr/bin/git",
            sha256: hash("git-executable"),
            byteCount: 1,
            deviceID: 1,
            inode: 1,
            version: "git version fixture",
            versionOutputSHA256:
                lineOutput(
                    "git version fixture"
                ).sha256,
            environmentPolicyID:
                "prime_git_read_only_empty_environment_v1"
        )
    }

    private func commandObservations()
        -> [PrimeNativeMigrationGitCommandObservation]
    {
        let plan =
            PrimeNativeContractMigrationPlan.frozenV1
        let expected =
            PrimeNativeContractMigrationResolver
                .expectedCommandObservations(plan: plan)
        return expected.enumerated().map {
            offset, expectation in
            let stdout: (byteCount: UInt64, sha256: String)
            switch expectation.operation {
            case "git_version":
                stdout = lineOutput(
                    "git version fixture"
                )
            case "remote_identity":
                stdout = lineOutput(
                    plan.acceptedRemoteURLs[0]
                )
            case "object_format":
                stdout = lineOutput(
                    plan.companionObjectFormat
                )
            case "resolved_revision",
                 "post_resolved_revision":
                stdout = lineOutput(
                    plan.companionRevision
                )
            case "resolved_tree",
                 "post_resolved_tree":
                stdout = lineOutput(
                    plan.companionTreeOID
                )
            case "raw_commit":
                stdout = (
                    plan.companionRawCommitByteCount,
                    plan.companionRawCommitSHA256
                )
            case "inventory_tree":
                let data =
                    PrimeNativeContractMigrationResolver
                    .expectedInventoryTreeOutput(plan: plan)
                stdout = (
                    UInt64(data.count),
                    PrimeSHA256.hexDigest(of: data)
                )
            default:
                let artifactID = String(
                    expectation.operation.dropFirst(
                        "blob:".count
                    )
                )
                let specification = plan.artifacts.first {
                    $0.artifactID == artifactID
                }!
                stdout = (
                    specification.byteCount,
                    specification.sha256
                )
            }
            return PrimeNativeMigrationGitCommandObservation(
                operation: expectation.operation,
                argv: expectation.argv,
                processIdentifier: Int32(offset + 1),
                terminationStatus: 0,
                terminationReason: "exit",
                stdoutByteCount: stdout.byteCount,
                stdoutSHA256: stdout.sha256,
                stderrByteCount: 0,
                stderrSHA256: hash(""),
                outputOverflowed: false
            )
        }
    }

    private func sourceCommandObservations()
        -> [PrimeNativeMigrationGitCommandObservation]
    {
        let plan =
            PrimeNativeContractMigrationPlan.frozenV1
        let revision = String(repeating: "a", count: 40)
        let treeOID = String(repeating: "b", count: 40)
        let remote = lineOutput(
            plan.acceptedResolverRemoteURLs[0]
        )
        let revisionOutput = lineOutput(revision)
        let treeOutput = lineOutput(treeOID)
        let cleanOutput = (UInt64(0), hash(""))
        let values: [
            String: (byteCount: UInt64, sha256: String)
        ] = [
            "resolver_source_pre_remote": remote,
            "resolver_source_pre_revision":
                revisionOutput,
            "resolver_source_pre_tree": treeOutput,
            "resolver_source_pre_status": cleanOutput,
            "resolver_source_post_remote": remote,
            "resolver_source_post_revision":
                revisionOutput,
            "resolver_source_post_tree": treeOutput,
            "resolver_source_post_status": cleanOutput,
        ]
        return PrimeNativeContractMigrationResolver
            .expectedResolverSourceCommandObservations()
            .enumerated()
            .map { offset, expectation in
                let output = values[
                    expectation.operation
                ]!
                return PrimeNativeMigrationGitCommandObservation(
                    operation: expectation.operation,
                    argv: expectation.argv,
                    processIdentifier:
                        Int32(offset + 100),
                    terminationStatus: 0,
                    terminationReason: "exit",
                    stdoutByteCount: output.byteCount,
                    stdoutSHA256: output.sha256,
                    stderrByteCount: 0,
                    stderrSHA256: hash(""),
                    outputOverflowed: false
                )
            }
    }

    private func exactPackageLockData() throws -> Data {
        let data = try XCTUnwrap(
            Data(
                base64Encoded: Self.packageLockBase64,
                options: [.ignoreUnknownCharacters]
            )
        )
        XCTAssertEqual(data.count, 1_949)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: data),
            "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
        )
        return data
    }

    private func assertMigrationError(
        _ expected: PrimeNativeContractMigrationError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () throws -> Void
    ) {
        XCTAssertThrowsError(
            try operation(),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as? PrimeNativeContractMigrationError,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func hash(_ value: String) -> String {
        PrimeSHA256.hexDigest(of: Data(value.utf8))
    }

    private func lineOutput(
        _ value: String
    ) -> (byteCount: UInt64, sha256: String) {
        let data = Data((value + "\n").utf8)
        return (
            UInt64(data.count),
            PrimeSHA256.hexDigest(of: data)
        )
    }

    private func mutate(
        _ receipt: PrimeNativeContractMigrationReceipt,
        _ mutation: (inout [String: Any]) -> Void
    ) throws -> PrimeNativeContractMigrationReceipt {
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(receipt)
            ) as? [String: Any]
        )
        mutation(&object)
        return try JSONDecoder().decode(
            PrimeNativeContractMigrationReceipt.self,
            from: JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]
            )
        )
    }

    private static let packageLockBase64 = """
    ewogICJwaW5zIiA6IFsKICAgIHsKICAgICAgImlkZW50aXR5IiA6ICJnemlwc3dpZnQiLAogICAgICAia2luZCIgOiAicmVtb3RlU291cmNlQ29udHJvbCIsCiAgICAgICJsb2NhdGlvbiIgOiAiaHR0cHM6Ly9naXRodWIuY29tLzEwMjRqcC9HemlwU3dpZnQiLAogICAgICAic3RhdGUiIDogewogICAgICAgICJyZXZpc2lvbiIgOiAiNzMxMDM3ZjZjYzJiZTJlYzAxNTYyZjY1OTdjMWQwYWEzZmU2ZmQwNSIsCiAgICAgICAgInZlcnNpb24iIDogIjYuMC4xIgogICAgICB9CiAgICB9LAogICAgewogICAgICAiaWRlbnRpdHkiIDogIm1seC1zd2lmdCIsCiAgICAgICJraW5kIiA6ICJyZW1vdGVTb3VyY2VDb250cm9sIiwKICAgICAgImxvY2F0aW9uIiA6ICJodHRwczovL2dpdGh1Yi5jb20vbWwtZXhwbG9yZS9tbHgtc3dpZnQiLAogICAgICAic3RhdGUiIDogewogICAgICAgICJyZXZpc2lvbiIgOiAiMDcyYjY4NGFjYWFlODBiNmE0NjNhYmFiM2ExMDM3MzJmMzM3NzRiZiIsCiAgICAgICAgInZlcnNpb24iIDogIjAuMjkuMSIKICAgICAgfQogICAgfSwKICAgIHsKICAgICAgImlkZW50aXR5IiA6ICJtbHgtc3dpZnQtZXhhbXBsZXMiLAogICAgICAia2luZCIgOiAicmVtb3RlU291cmNlQ29udHJvbCIsCiAgICAgICJsb2NhdGlvbiIgOiAiaHR0cHM6Ly9naXRodWIuY29tL21sLWV4cGxvcmUvbWx4LXN3aWZ0LWV4YW1wbGVzIiwKICAgICAgInN0YXRlIiA6IHsKICAgICAgICAicmV2aXNpb24iIDogIjliZmY5NWNhNWYwYjllOGMwMjFhY2M0ZDcxYTJiYmU0YTc0NDE2MzEiLAogICAgICAgICJ2ZXJzaW9uIiA6ICIyLjI5LjEiCiAgICAgIH0KICAgIH0sCiAgICB7CiAgICAgICJpZGVudGl0eSIgOiAic3dpZnQtY29sbGVjdGlvbnMiLAogICAgICAia2luZCIgOiAicmVtb3RlU291cmNlQ29udHJvbCIsCiAgICAgICJsb2NhdGlvbiIgOiAiaHR0cHM6Ly9naXRodWIuY29tL2FwcGxlL3N3aWZ0LWNvbGxlY3Rpb25zLmdpdCIsCiAgICAgICJzdGF0ZSIgOiB7CiAgICAgICAgInJldmlzaW9uIiA6ICJhMGNiMDk1NGVjYjIxZTRlMzFiMDA3MGU2ZWQ1Njc0ZTg1NTY2ODVhIiwKICAgICAgICAidmVyc2lvbiIgOiAiMS42LjAiCiAgICAgIH0KICAgIH0sCiAgICB7CiAgICAgICJpZGVudGl0eSIgOiAic3dpZnQtamluamEiLAogICAgICAia2luZCIgOiAicmVtb3RlU291cmNlQ29udHJvbCIsCiAgICAgICJsb2NhdGlvbiIgOiAiaHR0cHM6Ly9naXRodWIuY29tL2h1Z2dpbmdmYWNlL3N3aWZ0LWppbmphLmdpdCIsCiAgICAgICJzdGF0ZSIgOiB7CiAgICAgICAgInJldmlzaW9uIiA6ICI3ZDBiODg4MGVmOGU1NjdkZDRlMDA4OWY4Yjk5ZmIzNTQxMjkwMTdjIiwKICAgICAgICAidmVyc2lvbiIgOiAiMi40LjIiCiAgICAgIH0KICAgIH0sCiAgICB7CiAgICAgICJpZGVudGl0eSIgOiAic3dpZnQtbnVtZXJpY3MiLAogICAgICAia2luZCIgOiAicmVtb3RlU291cmNlQ29udHJvbCIsCiAgICAgICJsb2NhdGlvbiIgOiAiaHR0cHM6Ly9naXRodWIuY29tL2FwcGxlL3N3aWZ0LW51bWVyaWNzIiwKICAgICAgInN0YXRlIiA6IHsKICAgICAgICAicmV2aXNpb24iIDogIjBjMDI5MGZmNmIyNDk0MmRhZGI4M2E5MjlmZmFhYTE0ODFkZjA0YTIiLAogICAgICAgICJ2ZXJzaW9uIiA6ICIxLjEuMSIKICAgICAgfQogICAgfSwKICAgIHsKICAgICAgImlkZW50aXR5IiA6ICJzd2lmdC10cmFuc2Zvcm1lcnMiLAogICAgICAia2luZCIgOiAicmVtb3RlU291cmNlQ29udHJvbCIsCiAgICAgICJsb2NhdGlvbiIgOiAiaHR0cHM6Ly9naXRodWIuY29tL2h1Z2dpbmdmYWNlL3N3aWZ0LXRyYW5zZm9ybWVycyIsCiAgICAgICJzdGF0ZSIgOiB7CiAgICAgICAgInJldmlzaW9uIiA6ICJhMmUxODRkZGRiNDc1N2JjOTQzZTc3ZmJlOTlhYzY3ODZjNTNmMGIyIiwKICAgICAgICAidmVyc2lvbiIgOiAiMS4wLjAiCiAgICAgIH0KICAgIH0KICBdLAogICJ2ZXJzaW9uIiA6IDIKfQo=
    """
}
