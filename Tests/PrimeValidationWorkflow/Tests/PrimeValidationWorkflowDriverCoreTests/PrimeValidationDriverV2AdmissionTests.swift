// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import PrimeValidationWorkflowContracts
@testable import PrimeValidationWorkflowDriverCore
import XCTest

final class PrimeValidationDriverV2AdmissionTests: XCTestCase {
    private struct SourceFixture {
        let snapshot: PrimeSwiftSourceSnapshot
        let data: Data
        let packageLock: PrimeSwiftSourceFileSnapshot
    }

    private static let sourceFixtureResult: Result<SourceFixture, Error> =
        Result {
            var root = URL(fileURLWithPath: #filePath)
            for _ in 0 ..< 5 {
                root.deleteLastPathComponent()
            }
            let required: Set<String> = [
                "Package.resolved",
                "Sources/PrimeCore/" +
                    "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                "Sources/PrimeCore/" +
                    "PrimeValidationDriverV2TrackedTreeHeldEntry.swift",
                "Tests/PrimeValidationWorkflow/Sources/" +
                    "PrimeValidationWorkflowDriverCore/" +
                    "PrimeValidationDriverV2TrackedTreeManifest.swift",
            ]
            let releaseSnapshot = try PrimeSwiftSourceProvenance.capture(
                at: root,
                requiredRelativePaths: required,
                expectation: PrimeSwiftSourceProvenanceExpectation(
                    sourceIdentitySHA256:
                        PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
                    buildConfiguration: "release"
                )
            )
            try PrimeSwiftSourceProvenance.validateReleaseEvidence(
                releaseSnapshot,
                requiredRelativePaths: required
            )
            guard let packageLock = releaseSnapshot.files.first(where: {
                $0.relativePath == "Package.resolved"
            }) else {
                throw PrimeValidationDriverV2Error.invalidBinding(
                    "package_lock"
                )
            }
            return SourceFixture(
                snapshot: releaseSnapshot,
                data: try PrimeCanonicalJSON.encode(releaseSnapshot),
                packageLock: packageLock
            )
        }

    func testAdmissionReceiptIsCanonicalButCannotRestoreCapability() throws {
        let fixture = try makeFixture()
        let receipt = try fixture.receipt()
        try receipt.validate()
        XCTAssertEqual(try receipt.identitySHA256().count, 64)
        XCTAssertEqual(receipt.processExecutionObservation, .unobserved)
        XCTAssertEqual(receipt.buildExecutionObservation, .unobserved)
        XCTAssertEqual(receipt.inventoryExecutionObservation, .unobserved)
        XCTAssertEqual(receipt.shardCompletionObservation, .unobserved)

        let data = try PrimeCanonicalJSON.encode(receipt)
        let decoded = try PrimeCanonicalJSON.decode(
            PrimeValidationExecutorAdmissionReceiptV2.self,
            from: data
        )
        try decoded.validate()
        XCTAssertThrowsError(
            try PrimeValidationPreparedExecutorAdmissionV2.restore(
                from: decoded
            )
        ) { error in
            XCTAssertEqual(
                error as? PrimeValidationDriverV2Error,
                .authorityViolation
            )
        }
    }

    func testCanonicalAliasAndDuplicateDirectoryIdentityAreRejected() throws {
        let aliased = directory(
            role: .workspace,
            path: "/tmp/prime-workspace",
            canonicalPath: "/private/tmp/prime-workspace",
            deviceID: 1,
            inode: 3,
            mode: 0o700
        )
        XCTAssertThrowsError(try aliased.validate())
        let missingFilesystemIdentity = directory(
            role: .workspace,
            path: "/prime/no-fsid",
            deviceID: 1,
            inode: 40,
            mode: 0o700,
            filesystemIDWord0: 0,
            filesystemIDWord1: 0
        )
        XCTAssertThrowsError(try missingFilesystemIdentity.validate())
        let invalidTimestamp = directory(
            role: .workspace,
            path: "/prime/bad-time",
            deviceID: 1,
            inode: 41,
            mode: 0o700,
            modificationTimeNanoseconds: 1_000_000_000
        )
        XCTAssertThrowsError(try invalidTimestamp.validate())

        let fixture = try makeFixture()
        var directories = fixture.staging.workspaceDirectories
        let first = directories[0]
        let duplicateIdentity = directory(
            role: .workspaceSubdirectory,
            path: directories[1].directory.canonicalAbsolutePath,
            deviceID: first.directory.deviceID,
            inode: first.directory.inode,
            mode: 0o700
        )
        directories[1] = .init(
            name: directories[1].name,
            relativePath: directories[1].relativePath,
            directory: duplicateIdentity
        )
        let mutated = PrimeValidationStagingLayoutReceiptV2(
            workspaceRoot: fixture.staging.workspaceRoot,
            evidenceRoot: fixture.staging.evidenceRoot,
            workspaceDirectories: directories,
            evidenceRunDirectory: fixture.staging.evidenceRunDirectory,
            exclusiveLeaseHeld: true,
            initiallyEmptyObserved: true,
            durableDirectorySynchronizationObserved: true
        )
        XCTAssertThrowsError(try mutated.validate(intent: fixture.intent))
    }

    func testFilesystemIDWordsPreserveUnsignedHighBitsThroughCanonicalJSON()
        throws
    {
        let observation = directory(
            role: .workspace,
            path: "/prime/high-bit-fsid",
            deviceID: 1,
            inode: 42,
            mode: 0o700,
            filesystemIDWord0: 0x8000_0000,
            filesystemIDWord1: 0xffff_ffff
        )
        try observation.validate()

        let data = try PrimeCanonicalJSON.encode(observation)
        let decoded = try PrimeCanonicalJSON.decode(
            PrimeValidationCanonicalDirectoryObservationV2.self,
            from: data
        )

        XCTAssertEqual(decoded.filesystemIDWord0, 0x8000_0000)
        XCTAssertEqual(decoded.filesystemIDWord1, 0xffff_ffff)
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), data)
    }

    func testToolchainRawParsedDisagreementAndEnvironmentDriftAreRejected()
        throws
    {
        let fixture = try makeFixture()
        let rawDisagreement = toolchain(
            intent: fixture.intent,
            declaredXcodeVersion: "26.7",
            rawXcodeVersion: "26.6"
        )
        XCTAssertThrowsError(try rawDisagreement.validate())

        let drifted = toolchain(
            intent: fixture.intent,
            extraEnvironment: [
                .init(key: "PATH", value: "/usr/bin"),
            ]
        )
        XCTAssertThrowsError(try drifted.validate())

        let escapedRuntime = toolchain(
            intent: fixture.intent,
            runtimeResourcePathOverride: "/private/tmp/shadow-swift-runtime"
        )
        XCTAssertThrowsError(try escapedRuntime.validate())
    }

    func testAdmissionChainAndIntentHashDriftAreRejected() throws {
        let fixture = try makeFixture()
        let valid = try fixture.receipt()
        var chain = valid.chain
        chain[1] = .init(
            kind: chain[1].kind,
            predecessorSHA256: String(repeating: "f", count: 64),
            receiptSHA256: chain[1].receiptSHA256
        )
        let chainDrift = copy(valid, chain: chain)
        XCTAssertThrowsError(try chainDrift.validate())

        let intentDrift = copy(
            valid,
            intentSHA256: String(repeating: "e", count: 64)
        )
        XCTAssertThrowsError(try intentDrift.validate())
    }

    func testObservedFalseCannotSubstituteForUnobservedExecution() throws {
        let fixture = try makeFixture()
        let valid = try fixture.receipt()
        let mutated = copy(
            valid,
            processExecutionObservation: .observedFalse
        )
        XCTAssertThrowsError(try mutated.validate()) { error in
            XCTAssertEqual(
                error as? PrimeValidationDriverV2Error,
                .authorityViolation
            )
        }
    }

    func testPhysicalSwiftPackageTransformationAndFrozenPolicyRejectDrift()
        throws
    {
        let fixture = try makeFixture()
        let valid = try fixture.receipt()
        var launches = valid.launchPlan.launches
        let build = launches[0]
        XCTAssertEqual(
            build.orderedCompleteReplacementEnvironment.map(\.key),
            [
                "CFFIXED_USER_HOME",
                "CLANG_MODULE_CACHE_PATH",
                "DEVELOPER_DIR",
                "HOME",
                "LANG",
                "LC_ALL",
                "PATH",
                "PRIME_PMHNP_COMPANION_ROOT",
                "PRIME_REQUIRE_V10_HISTORICAL_REPLAY_SOURCE_GATE",
                "PRIME_REQUIRE_V11_HISTORICAL_FIXTURE_SOURCE_GATE",
                "PRIME_REQUIRE_V12_HISTORICAL_EVIDENCE_EXPORT_SOURCE_GATE",
                "PRIME_REQUIRE_V9_PINNED_DONOR_GATE",
                "PRIME_TEST_PINNED_MLX_METALLIB",
                "SDKROOT",
                "SOURCE_DATE_EPOCH",
                "SWIFTPM_MODULECACHE_OVERRIDE",
                "TERM",
                "TMPDIR",
                "TZ",
            ]
        )
        XCTAssertEqual(
            build.physicalWorkingDirectoryAbsolutePath,
            fixture.repository.repositoryRoot.canonicalAbsolutePath
        )
        launches[0] = .init(
            role: build.role,
            logicalInvocation: build.logicalInvocation,
            physicalExecutable: build.physicalExecutable,
            argumentZero: build.argumentZero,
            physicalArguments: Array(build.physicalArguments.dropLast()),
            orderedCompleteReplacementEnvironment:
                build.orderedCompleteReplacementEnvironment,
            physicalWorkingDirectoryAbsolutePath:
                build.physicalWorkingDirectoryAbsolutePath
        )
        let launchDrift = copy(
            valid,
            launchPlan: .init(launches: launches)
        )
        XCTAssertThrowsError(try launchDrift.validate())

        var environment = build.orderedCompleteReplacementEnvironment
        environment.append(
            .init(key: "DYLD_LIBRARY_PATH", value: "/private/tmp/shadow")
        )
        launches = valid.launchPlan.launches
        launches[0] = .init(
            role: build.role,
            logicalInvocation: build.logicalInvocation,
            physicalExecutable: build.physicalExecutable,
            argumentZero: build.argumentZero,
            physicalArguments: build.physicalArguments,
            orderedCompleteReplacementEnvironment: environment,
            physicalWorkingDirectoryAbsolutePath:
                build.physicalWorkingDirectoryAbsolutePath
        )
        XCTAssertThrowsError(
            try copy(
                valid,
                launchPlan: .init(launches: launches)
            ).validate()
        )

        launches = valid.launchPlan.launches
        launches[0] = .init(
            role: build.role,
            logicalInvocation: build.logicalInvocation,
            physicalExecutable: build.physicalExecutable,
            argumentZero: build.argumentZero,
            physicalArguments: build.physicalArguments,
            orderedCompleteReplacementEnvironment:
                build.orderedCompleteReplacementEnvironment,
            physicalWorkingDirectoryAbsolutePath: "/private/tmp/shadow"
        )
        XCTAssertThrowsError(
            try copy(
                valid,
                launchPlan: .init(launches: launches)
            ).validate()
        )

        var budgets = valid.policy.phaseBudgets
        budgets[0] = .init(
            phase: budgets[0].phase,
            maximumActiveNanoseconds:
                budgets[0].maximumActiveNanoseconds + 1
        )
        let policyDrift = PrimeValidationExecutorAdmissionPolicyV2(
            scratchRelativePath: valid.policy.scratchRelativePath,
            cacheRelativePath: valid.policy.cacheRelativePath,
            configRelativePath: valid.policy.configRelativePath,
            securityRelativePath: valid.policy.securityRelativePath,
            clangModuleCacheRelativePath:
                valid.policy.clangModuleCacheRelativePath,
            homeRelativePath: valid.policy.homeRelativePath,
            swiftPMModuleCacheRelativePath:
                valid.policy.swiftPMModuleCacheRelativePath,
            temporaryRelativePath: valid.policy.temporaryRelativePath,
            outputRelativePath: valid.policy.outputRelativePath,
            phaseBudgets: budgets
        )
        XCTAssertThrowsError(
            try copy(valid, policy: policyDrift).validate()
        )
    }

    func testHeldExecutableAndRegularFileMetadataDriftAreRejected() throws {
        let fixture = try makeFixture()
        let executable = fixture.supervisor
        let wrongExecutableSize = PrimeValidationHeldExecutableObservationV2(
            requestedAbsolutePath: executable.requestedAbsolutePath,
            canonicalAbsolutePath: executable.canonicalAbsolutePath,
            requestedSymlinkTarget: executable.requestedSymlinkTarget,
            content: executable.content,
            deviceID: executable.deviceID,
            inode: executable.inode,
            ownerUserID: executable.ownerUserID,
            ownerGroupID: executable.ownerGroupID,
            mode: executable.mode,
            linkCount: executable.linkCount,
            fileByteCount: executable.fileByteCount + 1,
            modificationTimeSeconds: executable.modificationTimeSeconds,
            modificationTimeNanoseconds:
                executable.modificationTimeNanoseconds,
            statusChangeTimeSeconds: executable.statusChangeTimeSeconds,
            statusChangeTimeNanoseconds:
                executable.statusChangeTimeNanoseconds,
            mappedExecutableAbsolutePath:
                executable.mappedExecutableAbsolutePath,
            descriptorJoined: executable.descriptorJoined,
            pathIdentityJoined: executable.pathIdentityJoined,
            mappedExecutableJoined: executable.mappedExecutableJoined
        )
        XCTAssertThrowsError(try wrongExecutableSize.validate())

        let packageLock = fixture.repository.packageLockFile
        let wrongFileTimestamp = PrimeValidationHeldRegularFileObservationV2(
            role: packageLock.role,
            absolutePath: packageLock.absolutePath,
            content: packageLock.content,
            deviceID: packageLock.deviceID,
            inode: packageLock.inode,
            ownerUserID: packageLock.ownerUserID,
            ownerGroupID: packageLock.ownerGroupID,
            mode: packageLock.mode,
            linkCount: packageLock.linkCount,
            fileByteCount: packageLock.fileByteCount,
            modificationTimeSeconds: packageLock.modificationTimeSeconds,
            modificationTimeNanoseconds: 1_000_000_000,
            statusChangeTimeSeconds: packageLock.statusChangeTimeSeconds,
            statusChangeTimeNanoseconds:
                packageLock.statusChangeTimeNanoseconds,
            descriptorJoined: packageLock.descriptorJoined,
            pathIdentityJoined: packageLock.pathIdentityJoined,
            noSymlinkComponentsObserved:
                packageLock.noSymlinkComponentsObserved,
            retainedDescriptorClosureHeld:
                packageLock.retainedDescriptorClosureHeld
        )
        XCTAssertThrowsError(try wrongFileTimestamp.validate())
    }

    func testPackageLockRootJoinAndPostAdmissionMutationAreRejected() throws {
        let fixture = try makeFixture()
        let wrongDevice = try repository(
            intent: fixture.intent,
            packageLockDeviceID: 9
        )
        XCTAssertThrowsError(
            try wrongDevice.validate(intent: fixture.intent)
        )
        let wrongOwner = try repository(
            intent: fixture.intent,
            packageLockOwnerUserID: 502,
            packageLockOwnerGroupID: 21
        )
        XCTAssertThrowsError(
            try wrongOwner.validate(intent: fixture.intent)
        )

        let replacedAfterAdmission = try repository(
            intent: fixture.intent,
            postAdmissionPackageLockInode: 203
        )
        XCTAssertThrowsError(
            try replacedAfterAdmission.validate(intent: fixture.intent)
        )
    }

    func testIncompleteReleaseSourceSnapshotIsRejected() throws {
        let fixture = try sourceFixture()
        let incomplete = PrimeSwiftSourceSnapshot(
            sourceIdentitySHA256: fixture.snapshot.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                fixture.snapshot.embeddedSourceIdentitySHA256,
            buildConfiguration: "release",
            files: []
        )
        XCTAssertThrowsError(
            try PrimeSwiftSourceProvenance.validateReleaseEvidence(
                incomplete,
                requiredRelativePaths: [
                    "Package.resolved",
                    "Sources/PrimeCore/" +
                        "PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                    "Sources/PrimeCore/" +
                        "PrimeValidationDriverV2TrackedTreeHeldEntry.swift",
                    "Tests/PrimeValidationWorkflow/Sources/" +
                        "PrimeValidationWorkflowDriverCore/" +
                        "PrimeValidationDriverV2TrackedTreeManifest.swift",
                ]
            )
        )
    }

    func testGateDGoldenRegularAndExecutableManifestIsCanonical() throws {
        let trackedTrees = try gateDCanonicalTrackedTrees()
        let artifact = trackedTrees.repository

        try artifact.validate()
        XCTAssertEqual(artifact.byteCount, 975)
        XCTAssertEqual(
            artifact.sha256,
            "9372e53a7d6b704fd0c40ffdc63d8aecdc10589f108212694afa9a740a33fd5c"
        )
        XCTAssertEqual(artifact.manifest.rawTree.byteCount, 131)
        XCTAssertEqual(
            artifact.manifest.rawTree.sha256,
            "c39e939477b4417019298b4637206ec700aae744786ee8083a8978e467a87a6e"
        )
        XCTAssertEqual(artifact.manifest.rootRole, .repository)
        XCTAssertEqual(
            artifact.manifest.entries.map(\.gitMode),
            ["100644", "100755"]
        )
        XCTAssertEqual(
            artifact.manifest.entries.map(\.heldKind),
            [.regularFile, .regularFile]
        )
        XCTAssertEqual(
            artifact.canonicalBytes,
            try PrimeCanonicalJSON.encode(
                gateDManifestEncoding(
                    role: .repository,
                    rawTree: trackedTrees.repositoryRawTree,
                    entries: zip(
                        ["100644", "100755"],
                        trackedTrees.repositoryHeldEntries
                    ).map { ($0.0, $0.1) }
                )
            )
        )
        XCTAssertEqual(
            artifact.sha256,
            PrimeSHA256.hexDigest(of: artifact.canonicalBytes)
        )
        XCTAssertEqual(
            try artifact.manifest.canonicalBytes(),
            artifact.canonicalBytes
        )
    }

    func testGateDRawPathBytesPreserveInvalidUTF8AndControls() throws {
        let rawPath = Data([
            0x61, 0x09, 0x0a, 0x0d, 0x5c, 0xc3, 0x28, 0xff,
        ])
        let held = try gateDHeldEntry(
            rawPath: rawPath,
            contents: Data("raw bytes\n".utf8),
            inode: 8_001
        )
        let rawTree = gateDTree([
            gateDRecord(mode: "100644", held: held),
        ])
        let artifact = try PrimeValidationTrackedTreeManifestBuilderV2
            .repository(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: rawTree,
                heldEntries: [held]
            )

        XCTAssertEqual(artifact.manifest.entries[0].rawPathBytes, rawPath)
        let decoded = try PrimeValidationTrackedTreeManifestV2
            .decodeCanonical(artifact.canonicalBytes)
        XCTAssertEqual(decoded, artifact.manifest)
        XCTAssertEqual(try decoded.canonicalBytes(), artifact.canonicalBytes)
    }

    func testGateDRejectsPrefixesFramingObjectFormatModeTypeAndObjectID()
        throws
    {
        let held = try gateDHeldEntry(
            rawPath: Data("a".utf8),
            contents: Data("a\n".utf8),
            inode: 8_010
        )
        let valid = gateDRecord(mode: "100644", held: held)

        for prefixCount in 0 ..< valid.count {
            assertGateDRepositoryRejects(
                rawTree: Data(valid.prefix(prefixCount)),
                heldEntries: [held]
            )
        }
        var emptyTrailingRecord = valid
        emptyTrailingRecord.append(0)
        assertGateDRepositoryRejects(
            rawTree: emptyTrailingRecord,
            heldEntries: [held]
        )
        for objectFormat in [
            Data("sha1".utf8),
            Data("sha1\r\n".utf8),
            Data("sha1\n\n".utf8),
            Data("sha256\n".utf8),
        ] {
            assertGateDRepositoryRejects(
                objectFormat: objectFormat,
                rawTree: valid,
                heldEntries: [held]
            )
        }
        for mode in ["040000", "160000", "100664", "10064"] {
            assertGateDRepositoryRejects(
                rawTree: gateDRecord(
                    mode: mode,
                    objectID: held.gitBlobSHA1,
                    path: held.rawPathBytes
                ),
                heldEntries: [held]
            )
        }
        for objectType in ["tree", "commit", "Blob", "blob "] {
            assertGateDRepositoryRejects(
                rawTree: gateDRecord(
                    mode: "100644",
                    objectType: objectType,
                    objectID: held.gitBlobSHA1,
                    path: held.rawPathBytes
                ),
                heldEntries: [held]
            )
        }
        for objectID in [
            String(repeating: "0", count: 40),
            String(repeating: "A", count: 40),
            String(repeating: "a", count: 39),
            String(repeating: "a", count: 41),
            String(repeating: "g", count: 40),
        ] {
            assertGateDRepositoryRejects(
                rawTree: gateDRecord(
                    mode: "100644",
                    objectID: objectID,
                    path: held.rawPathBytes
                ),
                heldEntries: [held]
            )
        }
        var wrongSpace = valid
        wrongSpace[6] = 0x09
        assertGateDRepositoryRejects(
            rawTree: wrongSpace,
            heldEntries: [held]
        )
        var wrongTab = valid
        wrongTab[52] = 0x20
        assertGateDRepositoryRejects(
            rawTree: wrongTab,
            heldEntries: [held]
        )
        var wrongSecondSpace = valid
        wrongSecondSpace[11] = 0x09
        assertGateDRepositoryRejects(
            rawTree: wrongSecondSpace,
            heldEntries: [held]
        )
    }

    func testGateDRejectsUnsafeDuplicateUnorderedAndAncestorPaths() throws {
        let held = try gateDHeldEntry(
            rawPath: Data("held".utf8),
            contents: Data("held\n".utf8),
            inode: 8_020
        )
        let unsafePaths: [Data] = [
            Data("/a".utf8),
            Data("a/".utf8),
            Data("a//b".utf8),
            Data(".".utf8),
            Data("..".utf8),
            Data("a/./b".utf8),
            Data("a/../b".utf8),
            Data(".git".utf8),
            Data(".git/config".utf8),
            Data(repeating: 0x61, count: 1_024),
            Data(repeating: 0x61, count: 256),
            Data(
                Array(
                    repeating: "a",
                    count: 33
                ).joined(separator: "/").utf8
            ),
        ]
        for path in unsafePaths {
            assertGateDRepositoryRejects(
                rawTree: gateDRecord(
                    mode: "100644",
                    objectID: held.gitBlobSHA1,
                    path: path
                ),
                heldEntries: [held]
            )
        }

        let a = gateDRecord(
            mode: "100644",
            objectID: held.gitBlobSHA1,
            path: Data("a".utf8)
        )
        let ab = gateDRecord(
            mode: "100644",
            objectID: held.gitBlobSHA1,
            path: Data("a/b".utf8)
        )
        let b = gateDRecord(
            mode: "100644",
            objectID: held.gitBlobSHA1,
            path: Data("b".utf8)
        )
        for tree in [gateDTree([a, a]), gateDTree([b, a]), gateDTree([a, ab])] {
            assertGateDRepositoryRejects(
                rawTree: tree,
                heldEntries: [held, held]
            )
        }
    }

    func testGateDRejectsHeldSetHashCountAndFixedCapDrift() throws {
        let held = try gateDHeldEntry(
            rawPath: Data("a".utf8),
            contents: Data("a\n".utf8),
            inode: 8_030
        )
        let valid = gateDRecord(mode: "100644", held: held)
        assertGateDRepositoryRejects(rawTree: valid, heldEntries: [])
        assertGateDRepositoryRejects(
            rawTree: valid,
            heldEntries: [held, held]
        )
        let renamed = try gateDHeldEntry(
            rawPath: Data("b".utf8),
            contents: held.contents,
            inode: 8_031
        )
        assertGateDRepositoryRejects(
            rawTree: valid,
            heldEntries: [renamed]
        )
        let canonical = try gateDCanonicalTrackedTrees()
        assertGateDRepositoryRejects(
            rawTree: canonical.repositoryRawTree,
            heldEntries: Array(canonical.repositoryHeldEntries.reversed())
        )
        assertGateDRepositoryRejects(
            rawTree: gateDRecord(mode: "100755", held: held),
            heldEntries: [held]
        )
        let executable = try gateDHeldEntry(
            rawPath: held.rawPathBytes,
            contents: held.contents,
            executable: true,
            inode: 8_032
        )
        assertGateDRepositoryRejects(
            rawTree: gateDRecord(mode: "100644", held: executable),
            heldEntries: [executable]
        )
        let ownerExecutable = try gateDHeldEntry(
            rawPath: Data("owner-executable".utf8),
            contents: held.contents,
            permissionMode: 0o744,
            inode: 8_035
        )
        XCTAssertNoThrow(
            try PrimeValidationTrackedTreeManifestBuilderV2.repository(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: gateDRecord(
                    mode: "100755",
                    held: ownerExecutable
                ),
                heldEntries: [ownerExecutable]
            )
        )
        let nonOwnerExecute = try gateDHeldEntry(
            rawPath: Data("group-executable".utf8),
            contents: held.contents,
            permissionMode: 0o655,
            inode: 8_036
        )
        XCTAssertNoThrow(
            try PrimeValidationTrackedTreeManifestBuilderV2.repository(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: gateDRecord(
                    mode: "100644",
                    held: nonOwnerExecute
                ),
                heldEntries: [nonOwnerExecute]
            )
        )
        let symbolicLink = try gateDHeldEntry(
            rawPath: held.rawPathBytes,
            contents: held.contents,
            kind: .symbolicLink,
            inode: 8_033
        )
        assertGateDRepositoryRejects(
            rawTree: gateDRecord(mode: "100644", held: symbolicLink),
            heldEntries: [symbolicLink]
        )
        assertGateDRepositoryRejects(
            rawTree: gateDRecord(
                mode: "100644",
                objectID: String(repeating: "1", count: 40),
                path: held.rawPathBytes
            ),
            heldEntries: [held]
        )

        let tooLargeContents = Data(
            repeating: 0x61,
            count: 8 * 1024 * 1024 + 1
        )
        let tooLarge = try gateDHeldEntry(
            rawPath: Data("large".utf8),
            contents: tooLargeContents,
            inode: 8_034
        )
        assertGateDRepositoryRejects(
            rawTree: gateDRecord(mode: "100644", held: tooLarge),
            heldEntries: [tooLarge]
        )

        var excessiveCount = Data()
        for index in 0 ... 4_096 {
            excessiveCount.append(
                gateDRecord(
                    mode: "100644",
                    objectID: held.gitBlobSHA1,
                    path: Data(String(format: "p%04d", index).utf8)
                )
            )
        }
        assertGateDRepositoryRejects(
            rawTree: excessiveCount,
            heldEntries: []
        )

        var aggregateTree = Data()
        var aggregateEntries: [GateDManifestEntryEncoding] = []
        for index in 0 ..< 9 {
            let path = Data(String(format: "p%02d", index).utf8)
            aggregateTree.append(
                gateDRecord(
                    mode: "100644",
                    objectID: held.gitBlobSHA1,
                    path: path
                )
            )
            aggregateEntries.append(
                gateDManifestEntryEncoding(
                    mode: "100644",
                    objectID: held.gitBlobSHA1,
                    rawPath: path,
                    byteCount: 64 * 1024 * 1024,
                    sha256: String(repeating: "a", count: 64)
                )
            )
        }
        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestV2.decodeCanonical(
                PrimeCanonicalJSON.encode(
                    GateDManifestEncoding(
                        artifactKind:
                            PrimeValidationTrackedTreeManifestV2.artifactKind,
                        schemaVersion:
                            PrimeValidationTrackedTreeManifestV2.schemaVersion,
                        rootRole: .companion,
                        objectFormat:
                            PrimeValidationTrackedTreeManifestV2.objectFormat,
                        rawTree: gateDRawTreeEncoding(aggregateTree),
                        entries: aggregateEntries
                    )
                )
            )
        )

        let invalidSHA256 = gateDManifestEncoding(
            role: .repository,
            rawTree: valid,
            entries: [("100644", held)],
            entrySHA256Override: String(repeating: "g", count: 64)
        )
        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestV2.decodeCanonical(
                PrimeCanonicalJSON.encode(invalidSHA256)
            )
        )

        let companionPerFileCap = GateDManifestEncoding(
            artifactKind:
                PrimeValidationTrackedTreeManifestV2.artifactKind,
            schemaVersion:
                PrimeValidationTrackedTreeManifestV2.schemaVersion,
            rootRole: .companion,
            objectFormat:
                PrimeValidationTrackedTreeManifestV2.objectFormat,
            rawTree: gateDRawTreeEncoding(valid),
            entries: [
                gateDManifestEntryEncoding(
                    mode: "100644",
                    objectID: held.gitBlobSHA1,
                    rawPath: held.rawPathBytes,
                    byteCount: 64 * 1024 * 1024 + 1,
                    sha256: held.sha256
                ),
            ]
        )
        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestV2.decodeCanonical(
                PrimeCanonicalJSON.encode(companionPerFileCap)
            )
        )
    }

    func testGateDRejectsSameBytesNewInodeAndIdentityReboundDrift() throws {
        let contents = Data("same bytes\n".utf8)
        let opened = gateDIdentity(
            contents: contents,
            inode: 8_040,
            kind: .regularFile
        )
        let rebound = gateDIdentity(
            contents: contents,
            inode: 8_041,
            kind: .regularFile
        )
        XCTAssertThrowsError(
            try PrimeValidationDriverV2TrackedTreeHeldEntry(
                validatingRawPathBytes: Data("a".utf8),
                kind: .regularFile,
                openedIdentity: opened,
                postReadDescriptorIdentity: opened,
                namedPathReboundIdentity: rebound,
                contents: contents
            )
        )

        let descriptorDrift = gateDIdentity(
            contents: contents,
            inode: 8_040,
            kind: .regularFile,
            deviceID: 9
        )
        XCTAssertThrowsError(
            try PrimeValidationDriverV2TrackedTreeHeldEntry(
                validatingRawPathBytes: Data("a".utf8),
                kind: .regularFile,
                openedIdentity: opened,
                postReadDescriptorIdentity: descriptorDrift,
                namedPathReboundIdentity: opened,
                contents: contents
            )
        )
    }

    func testGateDSymlinkMechanicsAreConditionalAndGitlinksReject() throws {
        let heldLink = try gateDHeldEntry(
            rawPath: Data("dir/link".utf8),
            contents: Data("../target".utf8),
            kind: .symbolicLink,
            inode: 8_050
        )
        let linkTree = gateDRecord(mode: "120000", held: heldLink)
        let artifact = try PrimeValidationTrackedTreeManifestBuilderV2
            .repository(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: linkTree,
                heldEntries: [heldLink]
            )
        XCTAssertEqual(artifact.manifest.entries[0].heldKind, .symbolicLink)

        let heldRegular = try gateDHeldEntry(
            rawPath: heldLink.rawPathBytes,
            contents: heldLink.contents,
            inode: 8_051
        )
        assertGateDRepositoryRejects(
            rawTree: linkTree,
            heldEntries: [heldRegular]
        )
        assertGateDRepositoryRejects(
            rawTree: gateDRecord(
                mode: "160000",
                objectType: "commit",
                objectID: String(repeating: "1", count: 40),
                path: Data("submodule".utf8)
            ),
            heldEntries: []
        )
        XCTAssertThrowsError(
            try gateDHeldEntry(
                rawPath: Data("empty-link".utf8),
                contents: Data(),
                kind: .symbolicLink,
                inode: 8_052
            )
        )
        for (rawPath, target, inode) in [
            ("link", "../target", UInt64(8_053)),
            ("link", "/absolute", UInt64(8_054)),
            ("link", ".git/config", UInt64(8_055)),
            ("dir/link", "../.git/config", UInt64(8_056)),
        ] {
            XCTAssertThrowsError(
                try gateDHeldEntry(
                    rawPath: Data(rawPath.utf8),
                    contents: Data(target.utf8),
                    kind: .symbolicLink,
                    inode: inode
                ),
                "\(rawPath) -> \(target)"
            )
        }
        let longParent = [
            String(repeating: "a", count: 255),
            String(repeating: "b", count: 255),
            String(repeating: "c", count: 255),
            "link",
        ].joined(separator: "/")
        let overflowingTarget = [
            String(repeating: "d", count: 128),
            String(repeating: "e", count: 128),
        ].joined(separator: "/")
        XCTAssertThrowsError(
            try gateDHeldEntry(
                rawPath: Data(longParent.utf8),
                contents: Data(overflowingTarget.utf8),
                kind: .symbolicLink,
                inode: 8_057
            )
        )
    }

    func testGateDCanonicalDecodeReceiptBindingAndSourceSurfaceAreClosed()
        throws
    {
        let fixture = try makeFixture()
        let trackedTrees = try gateDCanonicalTrackedTrees()
        let repository = fixture.repository
        let binding = try repository.bindingTrackedTreeManifests(
            intent: fixture.intent,
            repositoryManifest: trackedTrees.repository,
            companionManifest: trackedTrees.companion
        )
        try binding.validate(receipt: repository, intent: fixture.intent)
        XCTAssertEqual(
            binding.repositoryReceiptIdentitySHA256,
            try repository.identitySHA256(intent: fixture.intent)
        )
        let alternateReceipt = try self.repository(
            intent: fixture.intent,
            repositoryCommit: String(repeating: "d", count: 40)
        )
        try alternateReceipt.validate(intent: fixture.intent)
        XCTAssertEqual(
            alternateReceipt.repositoryTrackedTreeSHA256,
            repository.repositoryTrackedTreeSHA256
        )
        XCTAssertEqual(
            alternateReceipt.companionTrackedTreeSHA256,
            repository.companionTrackedTreeSHA256
        )
        XCTAssertThrowsError(
            try binding.validate(
                receipt: alternateReceipt,
                intent: fixture.intent
            )
        )

        let decoded = try PrimeValidationTrackedTreeManifestV2
            .decodeCanonical(trackedTrees.repository.canonicalBytes)
        XCTAssertEqual(decoded, trackedTrees.repository.manifest)
        XCTAssertEqual(
            try decoded.canonicalBytes(),
            trackedTrees.repository.canonicalBytes
        )
        let canonicalString = String(
            decoding: trackedTrees.repository.canonicalBytes,
            as: UTF8.self
        )
        var reordered = canonicalString.replacingOccurrences(
            of: "{\"artifact_kind\":",
            with: "{\"schema_version\":1,\"artifact_kind\":"
        )
        reordered = reordered.replacingOccurrences(
            of: ",\"schema_version\":1}",
            with: "}"
        )
        let noncanonicalCases = [
            Data((" " + canonicalString).utf8),
            Data((canonicalString + "\n").utf8),
            Data(
                ("{\"aaa_unknown\":true," +
                    String(canonicalString.dropFirst())).utf8
            ),
            Data(
                ("{\"artifact_kind\":\"" +
                    PrimeValidationTrackedTreeManifestV2.artifactKind +
                    "\"," + String(canonicalString.dropFirst())).utf8
            ),
            Data(reordered.utf8),
        ]
        for noncanonical in noncanonicalCases {
            XCTAssertThrowsError(
                try PrimeValidationTrackedTreeManifestV2.decodeCanonical(
                    noncanonical
                )
            )
        }
        XCTAssertNil(
            trackedTrees.repository.canonicalBytes.range(
                of: Data(trackedTrees.repository.sha256.utf8)
            )
        )

        let arbitrary = try self.repository(
            intent: fixture.intent,
            repositoryTrackedTreeSHA256: String(repeating: "b", count: 64),
            companionTrackedTreeSHA256: String(repeating: "c", count: 64)
        )
        try arbitrary.validate(intent: fixture.intent)
        XCTAssertThrowsError(
            try arbitrary.bindingTrackedTreeManifests(
                intent: fixture.intent,
                repositoryManifest: trackedTrees.repository,
                companionManifest: trackedTrees.companion
            )
        )
        XCTAssertThrowsError(
            try repository.bindingTrackedTreeManifests(
                intent: fixture.intent,
                repositoryManifest: trackedTrees.companion,
                companionManifest: trackedTrees.repository
            )
        )

        let source = try sourceFixture().snapshot
        let heldOwner = try XCTUnwrap(source.files.first(where: {
            $0.relativePath ==
                "Sources/PrimeCore/" +
                "PrimeValidationDriverV2TrackedTreeHeldEntry.swift"
        }))
        let manifestOwner = try XCTUnwrap(source.files.first(where: {
            $0.relativePath ==
                "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverCore/" +
                "PrimeValidationDriverV2TrackedTreeManifest.swift"
        }))
        let heldSource = String(decoding: heldOwner.contents, as: UTF8.self)
        let manifestSource = String(
            decoding: manifestOwner.contents,
            as: UTF8.self
        )
        for forbidden in [
            "public init(", "init(from", "encode(to", "FileHandle",
            "FileManager", "URL(fileURLWithPath:",
        ] {
            XCTAssertFalse(heldSource.contains(forbidden), forbidden)
        }
        for forbidden in [
            "Process()", "posix_spawn", "CommandLine", "FileHandle",
            "FileManager", "/usr/bin/git", "swift-package",
        ] {
            XCTAssertFalse(manifestSource.contains(forbidden), forbidden)
        }
    }

    func testGateEPrimeScopeAndFixedPolicyAreExact() throws {
        let executor = try gateEProductionSource(
            "Sources/PrimeCore/" +
                "PrimeValidationDriverV2FixedProbeExecutor.swift"
        )
        let facade = try gateEProductionSource(
            "Sources/PrimeCore/PrimeValidationDriverV2RoleFacade.swift"
        )
        let binding = try gateEProductionSource(
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverCore/" +
                "PrimeValidationDriverV2FixedProbeBinding.swift"
        )

        let roles = [
            "prime_head_pre", "prime_object_format", "prime_status_pre",
            "prime_tree_discovery", "prime_tree_replay",
            "prime_status_post", "prime_head_post",
            "companion_head_pre", "companion_object_format",
            "companion_status_pre", "companion_tree_discovery",
            "companion_tree_replay", "companion_status_post",
            "companion_head_post", "swift_version", "swift_target_info",
        ]
        let roleOffsets = roles.compactMap {
            executor.range(of: "\"\($0)\"")?.lowerBound
        }
        XCTAssertEqual(roleOffsets.count, roles.count)
        XCTAssertEqual(roleOffsets, roleOffsets.sorted())
        XCTAssertEqual(roles.count, 16)

        let pathspecs = [
            ".gitignore", ".swiftpm/configuration/mirrors.json", "LICENSE",
            "Package.resolved", "Package.swift", "README.md", "Sources",
            "THIRD_PARTY_NOTICES.md", "Tests", "docs",
        ]
        for value in pathspecs {
            XCTAssertTrue(executor.contains("\"\(value)\""), value)
            XCTAssertTrue(binding.contains("\"\(value)\""), value)
        }
        for value in [
            "--no-pager", "--no-optional-locks", "--no-replace-objects",
            "--no-lazy-fetch", "--literal-pathspecs", "--git-dir=.git",
            "--work-tree=.", "core.fsmonitor=false",
            "core.untrackedCache=false", "submodule.recurse=false",
            "core.hooksPath=/dev/null",
        ] {
            XCTAssertTrue(executor.contains("\"\(value)\""), value)
            XCTAssertTrue(binding.contains("\"\(value)\""), value)
        }
        for value in [
            "dedicated_group_within_supervisor_session",
            "static let requiredSpawnFlags: UInt16 = 0x408e",
            "spawnDriverV2FixedProbeSuspended",
            "establishDriverV2DedicatedGroupWithinSupervisorSession",
            "prime_driver_v2_gate_e_fixed_policy_v2",
            "prime_driver_v2_gate_e_prestart_v2",
            "prime_driver_v2_gate_e_child_start_v2",
            "prime_driver_v2_gate_e_child_terminal_v2",
            "prime_driver_v2_gate_e_raw_terminal_v2",
            "static let deadlineNanoseconds: UInt64 = 30_000_000_000",
            "standardErrorMaximumByteCount: UInt64 = 64 * 1024",
            "drainChunkByteCount = 64 * 1024",
            "treeOrStatusMaximumByteCount: UInt64 = 16 * 1024 * 1024",
            "(\"LANG\", \"C\")", "(\"LC_ALL\", \"C\")",
            "(\"TERM\", \"dumb\")",
        ] {
            XCTAssertTrue(executor.contains(value), value)
        }
        XCTAssertFalse(executor.contains("spawnSuspended("))
        XCTAssertFalse(
            executor.contains(
                "establishIsolatedSessionAndDedicatedGroup"
            )
        )
        for value in [
            "raw.supervisorSessionIdentifier",
            "processIdentifierDiffersFromSupervisor",
            "processIdentifierUnique",
            "processGroupIdentifierUnique",
            "value.appliedSpawnFlags == 0x408e",
        ] {
            XCTAssertTrue(binding.contains(value), value)
        }
        XCTAssertTrue(executor.contains("(\"DEVELOPER_DIR\", toolchain."))
        XCTAssertTrue(executor.contains("(\"SDKROOT\", toolchain."))

        let publicTransition = try XCTUnwrap(
            facade.range(of: "public func observeFixedGitAndSwiftProbes()")
        )
        let transitionTail = facade[publicTransition.lowerBound...]
        XCTAssertTrue(transitionTail.hasPrefix(
            "public func observeFixedGitAndSwiftProbes() throws"
        ))
        XCTAssertEqual(
            facade.components(
                separatedBy: "public func observeFixedGitAndSwiftProbes()"
            ).count - 1,
            1
        )
        XCTAssertTrue(executor.contains("sourceSnapshot.files"))
        XCTAssertTrue(executor.contains("fixedProbePrimeHeldEntries()"))
        XCTAssertTrue(executor.contains("fixedProbeCompanionHeldEntries()"))
        XCTAssertTrue(binding.contains("exactMissingAuthorities"))
        for missing in [
            ".swiftPMBuildExecution", ".artifactStaging",
            ".xctestInventoryExecution", ".swiftTestingInventoryExecution",
        ] {
            XCTAssertTrue(binding.contains(missing), missing)
        }
        for frozenRole in [".build", ".listXCTest", ".listSwiftTesting"] {
            XCTAssertTrue(facade.contains(frozenRole), frozenRole)
        }
    }

    func testGateERawParsersAndPartialBindingsAreClosed() throws {
        let fixture = try makeFixture()
        try fixture.toolchain.validate()
        try fixture.repository.validate(intent: fixture.intent)

        let parsedTarget = try PrimeValidationSwiftTargetInfoObservationV2
            .parse(fixture.toolchain.swiftTargetInfoOutput.data)
        XCTAssertEqual(parsedTarget, fixture.toolchain.targetInfo)
        var truncated = fixture.toolchain.swiftTargetInfoOutput.data
        truncated.removeLast()
        XCTAssertThrowsError(
            try PrimeValidationSwiftTargetInfoObservationV2.parse(truncated)
        )

        let tracked = try gateDCanonicalTrackedTrees()
        let heldBinding = try fixture.repository.bindingTrackedTreeManifests(
            intent: fixture.intent,
            repositoryManifest: tracked.repository,
            companionManifest: tracked.companion
        )
        try heldBinding.validate(receipt: fixture.repository, intent: fixture.intent)
        XCTAssertEqual(
            PrimeValidationDriverV2FixedProbeBinding.exactMissingAuthorities,
            [
                .swiftPMBuildExecution,
                .artifactStaging,
                .xctestInventoryExecution,
                .swiftTestingInventoryExecution,
            ]
        )

        let source = try gateEProductionSource(
            "Tests/PrimeValidationWorkflow/Sources/" +
                "PrimeValidationWorkflowDriverCore/" +
                "PrimeValidationDriverV2FixedProbeBinding.swift"
        )
        for exactPath in [
            "admission/repository_head.bin",
            "admission/repository_status.bin",
            "admission/companion_head.bin",
            "admission/companion_status.bin",
            "admission/xcode_version.bin", "admission/sdk_path.bin",
            "admission/sdk_version.bin", "admission/swift_version.bin",
            "admission/swift_target_info.bin",
        ] {
            XCTAssertTrue(source.contains("\"\(exactPath)\""), exactPath)
        }
        XCTAssertTrue(source.contains(
            "package struct PrimeValidationDriverV2PartialToolchainProbeBinding"
        ))
        XCTAssertTrue(source.contains("swiftPackageMappedExecutableJoined: false"))
        XCTAssertFalse(source.contains("PrimeValidationToolchainAdmissionReceiptV2("))
        XCTAssertTrue(source.contains("private let consumedFacade:"))
        XCTAssertTrue(source.contains("private let boundLifetime:"))
        XCTAssertTrue(source.contains("semanticBindingIdentitySHA256"))
        XCTAssertFalse(source.contains("extension PrimeValidationDriverV2FixedProbeBinding: Codable"))
        XCTAssertFalse(source.contains("extension PrimeValidationDriverV2PartialToolchainProbeBinding: Codable"))
    }

    func testGateERejectsEveryRawProcessAndRepositoryMutation() throws {
        let fixture = try makeFixture()
        let tracked = try gateDCanonicalTrackedTrees()

        assertGateDRepositoryRejects(
            objectFormat: Data("sha256\n".utf8),
            rawTree: tracked.repositoryRawTree,
            heldEntries: tracked.repositoryHeldEntries
        )
        var truncated = tracked.repositoryRawTree
        truncated.removeLast()
        assertGateDRepositoryRejects(
            rawTree: truncated,
            heldEntries: tracked.repositoryHeldEntries
        )
        let arbitrary = try repository(
            intent: fixture.intent,
            repositoryTrackedTreeSHA256: String(repeating: "b", count: 64),
            companionTrackedTreeSHA256: String(repeating: "c", count: 64)
        )
        try arbitrary.validate(intent: fixture.intent)
        XCTAssertThrowsError(
            try arbitrary.bindingTrackedTreeManifests(
                intent: fixture.intent,
                repositoryManifest: tracked.repository,
                companionManifest: tracked.companion
            )
        )

        for (fact, receipt) in [
            (
                "repository_head",
                try repository(
                    intent: fixture.intent,
                    repositoryHEADOutputData:
                        Data((String(repeating: "0", count: 40) + "\n").utf8)
                )
            ),
            (
                "companion_head",
                try repository(
                    intent: fixture.intent,
                    companionHEADOutputData:
                        Data((String(repeating: "0", count: 40) + "\n").utf8)
                )
            ),
            (
                "repository_status",
                try repository(
                    intent: fixture.intent,
                    repositoryStatusOutputData: Data("1 .M N... dirty\0".utf8)
                )
            ),
            (
                "companion_status",
                try repository(
                    intent: fixture.intent,
                    companionStatusOutputData: Data("? dirty\0".utf8)
                )
            ),
            (
                "companion_pinned_head",
                try repository(
                    intent: fixture.intent,
                    companionCommit: String(repeating: "0", count: 40)
                )
            ),
        ] {
            XCTAssertThrowsError(
                try receipt.validate(intent: fixture.intent),
                fact
            )
        }

        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestBuilderV2.companion(
                objectFormatOutput: Data("sha256\n".utf8),
                rawTreeOutput: tracked.companionRawTree,
                heldEntries: tracked.companionHeldEntries
            )
        )
        var truncatedCompanion = tracked.companionRawTree
        truncatedCompanion.removeLast()
        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestBuilderV2.companion(
                objectFormatOutput: Data("sha1\n".utf8),
                rawTreeOutput: truncatedCompanion,
                heldEntries: tracked.companionHeldEntries
            )
        )

        for malformed in [
            Data(), Data("{}".utf8), Data("{\"target\":null}".utf8),
            Data("{\"target\":{}}\ntrailing".utf8),
        ] {
            XCTAssertThrowsError(
                try PrimeValidationSwiftTargetInfoObservationV2.parse(malformed)
            )
        }

        for (fact, receipt) in [
            (
                "swift_version",
                toolchain(
                    intent: fixture.intent,
                    swiftVersionOutputData: Data("mutated swift\n".utf8)
                )
            ),
            (
                "swift_target_info",
                toolchain(
                    intent: fixture.intent,
                    swiftTargetInfoOutputData: Data("{}".utf8)
                )
            ),
        ] {
            XCTAssertThrowsError(try receipt.validate(), fact)
        }

        let expectedProcessFacts = [
            "ordered_role", "role", "ordinal", "logical_argument_zero",
            "arguments", "ordered_environment", "working_directory",
            "executable_image", "standard_output_cap",
            "standard_error_empty", "process_identifier",
            "process_identifier_differs_from_supervisor",
            "process_identifier_unique", "spawn_flags",
            "spawn_return_code", "spawn_after_deadline_start",
            "spawn_after_predecessor_terminal",
            "spawn_before_start_publication", "session_identifier",
            "process_group_identifier", "process_group_identifier_unique",
            "suspended_working_directory_device",
            "suspended_working_directory_inode",
            "exact_suspended_working_directory_join", "death_observed",
            "death_after_resume", "pre_reap_process_group_members",
            "start_after_spawn", "start_before_resume",
            "pre_resume_checkpoint_after_start_publication",
            "pre_resume_checkpoint_before_resume",
            "pre_resume_checkpoint_within_deadline",
            "resume_after_deadline_start", "resume_before_deadline_expiry",
            "start_durable_before_resume", "mapped_image_joined",
            "requested_wait_process_identifier",
            "returned_wait_process_identifier", "wait_options",
            "raw_wait_status", "wait_after_death",
            "wait_before_deadline_expiry", "wait_before_executor_terminal",
            "exited_normally", "exit_status", "termination_signal",
            "core_dumped",
            "standard_output_reached_eof",
            "standard_output_total_byte_count",
            "standard_output_terminal_reason", "standard_output_overflowed",
            "standard_output_worker_finished",
            "standard_output_read_error_number",
            "standard_output_write_error_number",
            "standard_output_finalization_error_number",
            "standard_output_close_error_number",
            "standard_output_descriptors_closed",
            "standard_error_reached_eof",
            "standard_error_total_byte_count",
            "standard_error_terminal_reason", "standard_error_overflowed",
            "standard_error_worker_finished",
            "standard_error_read_error_number",
            "standard_error_write_error_number",
            "standard_error_finalization_error_number",
            "standard_error_close_error_number",
            "standard_error_descriptors_closed",
            "process_group_empty_after_reap", "terminal_after_wait",
            "terminal_before_deadline_expiry",
        ]
        let processMatrix = try
            PrimeValidationDriverV2FixedProbeSemanticTestSeam
                .processMutationMatrix()
        XCTAssertEqual(processMatrix.map(\.fact), expectedProcessFacts)
        for mutation in processMatrix {
            XCTAssertTrue(mutation.rejected, mutation.fact)
        }
    }

    private func gateEProductionSource(_ relativePath: String) throws
        -> String
    {
        var root = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 5 { root.deleteLastPathComponent() }
        let data = try Data(contentsOf: root.appendingPathComponent(relativePath))
        return String(decoding: data, as: UTF8.self)
    }

    private struct Fixture {
        let intent: PrimeValidationRunIntentV2
        let toolchain: PrimeValidationToolchainAdmissionReceiptV2
        let supervisor: PrimeValidationHeldExecutableObservationV2
        let repository: PrimeValidationRepositoryAdmissionReceiptV2
        let staging: PrimeValidationStagingLayoutReceiptV2

        func receipt() throws -> PrimeValidationExecutorAdmissionReceiptV2 {
            try .make(
                intent: intent,
                toolchain: toolchain,
                supervisorExecutable: supervisor,
                repository: repository,
                staging: staging
            )
        }
    }

    private func makeFixture() throws -> Fixture {
        let intent = try makeIntent()
        let staging = makeStaging(intent: intent)
        return Fixture(
            intent: intent,
            toolchain: toolchain(intent: intent),
            supervisor: heldExecutable(
                requestedPath: intent.driverExecutable.absolutePath,
                canonicalPath: intent.driverExecutable.absolutePath,
                symlinkTarget: nil,
                content: intent.driverExecutable.content,
                inode: 201
            ),
            repository: try repository(intent: intent),
            staging: staging
        )
    }

    private func makeIntent() throws -> PrimeValidationRunIntentV2 {
        let sourceFixture = try sourceFixture()
        let source = PrimeValidationContentBinding(data: sourceFixture.data)
        let lock = PrimeValidationContentBinding(
            data: sourceFixture.packageLock.contents
        )
        let metallib = PrimeValidationRequiredMetallibV2(
            relativePath:
                "root-release-build/arm64-apple-macosx/release/"
                + "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
            content: content("metallib")
        )
        let roots = PrimeValidationDriverRootLayoutV2(
            repositoryRoot: root(path: "/prime/repository", inode: 1),
            companionRoot: root(path: "/prime/companion", inode: 2),
            workspaceRoot: root(
                path: "/prime/workspace",
                inode: 3,
                mode: 0o700
            ),
            evidenceRoot: root(
                path: "/prime/evidence",
                inode: 4,
                mode: 0o700
            ),
            scratchRelativePath: "root-release-build",
            cacheRelativePath: "cache",
            configRelativePath: "config",
            securityRelativePath: "security",
            clangModuleCacheRelativePath: "clang-module-cache",
            homeRelativePath: "home",
            swiftPMModuleCacheRelativePath: "swiftpm-module-cache",
            temporaryRelativePath: "temporary",
            outputRelativePath: "output"
        )
        let swift = PrimeValidationExecutableBindingV2(
            absolutePath:
                "/Applications/Xcode.app/Contents/Developer/Toolchains/"
                + "XcodeDefault.xctoolchain/usr/bin/swift",
            content: content("swift-frontend")
        )
        return PrimeValidationRunIntentV2(
            runID: "run-admission",
            roots: roots,
            sourceSnapshot: source,
            packageLock: lock,
            driverExecutable: .init(
                absolutePath: "/prime/bin/admission-driver",
                content: content("driver")
            ),
            swiftExecutable: swift,
            companionCommit:
                PrimeValidationRunIntentV2.requiredCompanionCommit,
            requiredPinnedMetallib: metallib,
            baseline: .init(),
            phaseBudgets:
                PrimeValidationExecutorAdmissionPolicyV2.frozenV1
                .phaseBudgets,
            environmentPolicy: .make(
                roots: roots,
                pinnedMetallib: metallib
            ),
            optionalSkipPolicySHA256:
                try PrimeValidationOptionalSkipPolicy.identitySHA256()
        )
    }

    private func toolchain(
        intent: PrimeValidationRunIntentV2,
        declaredXcodeVersion: String = "26.6",
        rawXcodeVersion: String = "26.6",
        runtimeResourcePathOverride: String? = nil,
        extraEnvironment: [PrimeValidationEnvironmentEntry] = [],
        swiftVersionOutputData: Data? = nil,
        swiftTargetInfoOutputData: Data? = nil
    ) -> PrimeValidationToolchainAdmissionReceiptV2 {
        let developer =
            "/Applications/Xcode.app/Contents/Developer"
        let sdk = developer
            + "/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
        let frontend = developer
            + "/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-frontend"
        let runtimeResourcePath = runtimeResourcePathOverride
            ?? developer
                + "/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift"
        let target = PrimeValidationSwiftTargetInfoObservationV2(
            compilerVersion:
                "Apple Swift version 6.3.3 "
                + "(swiftlang-6.3.3.1.3 clang-2100.1.1.101)",
            swiftCompilerTag: "swiftlang-6.3.3.1.3",
            triple: "arm64-apple-macosx26.0",
            unversionedTriple: "arm64-apple-macosx",
            moduleTriple: "arm64-apple-macos",
            platform: "macosx",
            architecture: "arm64",
            pointerWidthInBits: 64,
            runtimeLibraryPaths: [
                developer
                    + "/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx",
                "/usr/lib/swift",
            ],
            runtimeLibraryImportPaths: [
                developer
                    + "/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx",
            ],
            runtimeResourcePath: runtimeResourcePath
        )
        let targetJSON = Data(
            """
            {"compilerVersion":"Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)","swiftCompilerTag":"swiftlang-6.3.3.1.3","target":{"triple":"arm64-apple-macosx26.0","unversionedTriple":"arm64-apple-macosx","moduleTriple":"arm64-apple-macos","platform":"macosx","arch":"arm64","pointerWidthInBits":64},"paths":{"runtimeLibraryPaths":["\(developer)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx","/usr/lib/swift"],"runtimeLibraryImportPaths":["\(developer)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx"],"runtimeResourcePath":"\(runtimeResourcePath)"}}
            """.utf8
        )
        let executableContent = intent.swiftExecutable.content
        let swift = heldExecutable(
            requestedPath: intent.swiftExecutable.absolutePath,
            canonicalPath: frontend,
            symlinkTarget: "swift-frontend",
            content: executableContent,
            inode: 100
        )
        let swiftc = heldExecutable(
            requestedPath:
                developer
                + "/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc",
            canonicalPath: frontend,
            symlinkTarget: "swift-frontend",
            content: executableContent,
            inode: 100
        )
        let toolchainBin = developer
            + "/Toolchains/XcodeDefault.xctoolchain/usr/bin"
        let swiftPackagePath = toolchainBin + "/swift-package"
        let swiftPackage = heldExecutable(
            requestedPath: swiftPackagePath,
            canonicalPath: swiftPackagePath,
            symlinkTarget: nil,
            content: content("swift-package"),
            inode: 103
        )
        let swiftPackagePersonalities =
            PrimeValidationSwiftPackagePersonalityRoleV2.allCases
            .enumerated().map { index, role in
                PrimeValidationSwiftPackagePersonalityV2(
                    role: role,
                    requestedAbsolutePath:
                        toolchainBin + "/"
                        + (role == .build ? "swift-build" : "swift-test"),
                    requestedSymlinkTarget: "swift-package",
                    symlinkDeviceID: 2,
                    symlinkInode: UInt64(104 + index),
                    symlinkOwnerUserID: 0,
                    symlinkOwnerGroupID: 0,
                    symlinkMode: 0o777,
                    symlinkLinkCount: 1,
                    resolvedExecutableAbsolutePath: swiftPackagePath,
                    argumentZero:
                        role == .build ? "swift-build" : "swift-test",
                    noFollowMetadataObserved: true,
                    readlinkTargetObserved: true,
                    resolvedExecutableJoined: true
                )
            }
        return PrimeValidationToolchainAdmissionReceiptV2(
            developerDirectory: directory(
                role: .developerDirectory,
                path: developer,
                deviceID: 2,
                inode: 101,
                ownerUserID: 0,
                ownerGroupID: 0,
                mode: 0o755
            ),
            sdkRoot: directory(
                role: .sdkRoot,
                path: sdk,
                deviceID: 2,
                inode: 102,
                ownerUserID: 0,
                ownerGroupID: 0,
                mode: 0o755
            ),
            swiftExecutable: swift,
            swiftCompilerExecutable: swiftc,
            swiftPackageExecutable: swiftPackage,
            swiftPackagePersonalities: swiftPackagePersonalities,
            xcodeVersionOutput: bound(
                name: "xcode_version",
                data: Data(
                    "Xcode \(rawXcodeVersion)\nBuild version 17F113\n".utf8
                )
            ),
            sdkPathOutput: bound(
                name: "sdk_path",
                data: Data((sdk + "\n").utf8)
            ),
            sdkVersionOutput: bound(
                name: "sdk_version",
                data: Data("26.5\n".utf8)
            ),
            swiftVersionOutput: bound(
                name: "swift_version",
                data: swiftVersionOutputData ?? Data(
                    (
                        "swift-driver version: 1.148.6 "
                            + target.compilerVersion
                            + "\nTarget: arm64-apple-macosx26.0\n"
                    ).utf8
                )
            ),
            swiftTargetInfoOutput: bound(
                name: "swift_target_info",
                data: swiftTargetInfoOutputData ?? targetJSON
            ),
            xcodeVersion: declaredXcodeVersion,
            xcodeBuildVersion: "17F113",
            sdkVersion: "26.5",
            swiftDriverVersion: "1.148.6",
            targetInfo: target,
            orderedProbeEnvironment:
                PrimeValidationToolchainAdmissionReceiptV2.probeEnvironment(
                    developerDirectory: developer,
                    sdkRoot: sdk
                ) + extraEnvironment
        )
    }

    private func repository(
        intent: PrimeValidationRunIntentV2,
        repositoryCommit: String = String(repeating: "e", count: 40),
        companionCommit: String? = nil,
        repositoryHEADOutputData: Data? = nil,
        repositoryStatusOutputData: Data? = nil,
        companionHEADOutputData: Data? = nil,
        companionStatusOutputData: Data? = nil,
        packageLockDeviceID: UInt64 = 1,
        packageLockOwnerUserID: UInt32 = 501,
        packageLockOwnerGroupID: UInt32 = 20,
        postAdmissionPackageLockInode: UInt64 = 202,
        repositoryTrackedTreeSHA256: String? = nil,
        companionTrackedTreeSHA256: String? = nil
    ) throws -> PrimeValidationRepositoryAdmissionReceiptV2 {
        let companionCommit = companionCommit ?? intent.companionCommit
        let sourceFixture = try sourceFixture()
        let trackedTrees = try gateDCanonicalTrackedTrees()
        let packageLockFile = heldRegularFile(
            role: .packageLock,
            path: intent.roots.repositoryRoot.absolutePath
                + "/Package.resolved",
            content: intent.packageLock,
            deviceID: packageLockDeviceID,
            ownerUserID: packageLockOwnerUserID,
            ownerGroupID: packageLockOwnerGroupID,
            inode: 202,
            mode: 0o644
        )
        let packageLockFileAfterAdmission = heldRegularFile(
            role: .packageLock,
            path: intent.roots.repositoryRoot.absolutePath
                + "/Package.resolved",
            content: intent.packageLock,
            deviceID: packageLockDeviceID,
            ownerUserID: packageLockOwnerUserID,
            ownerGroupID: packageLockOwnerGroupID,
            inode: postAdmissionPackageLockInode,
            mode: 0o644
        )
        return .init(
            repositoryRoot: directory(
                role: .repository,
                path: intent.roots.repositoryRoot.absolutePath,
                deviceID: intent.roots.repositoryRoot.deviceID,
                inode: intent.roots.repositoryRoot.inode,
                mode: intent.roots.repositoryRoot.mode
            ),
            companionRoot: directory(
                role: .companion,
                path: intent.roots.companionRoot.absolutePath,
                deviceID: intent.roots.companionRoot.deviceID,
                inode: intent.roots.companionRoot.inode,
                mode: intent.roots.companionRoot.mode
            ),
            gitExecutable: heldExecutable(
                requestedPath:
                    "/Applications/Xcode.app/Contents/Developer/usr/bin/git",
                canonicalPath:
                    "/Applications/Xcode.app/Contents/Developer/usr/bin/git",
                symlinkTarget: nil,
                content: content("git"),
                inode: 200
            ),
            sourceSnapshotArtifact: .init(
                name: "source_snapshot",
                relativePath: "admission/source-snapshot.json",
                data: sourceFixture.data
            ),
            sourceIdentitySHA256:
                sourceFixture.snapshot.sourceIdentitySHA256,
            embeddedSourceIdentitySHA256:
                sourceFixture.snapshot.embeddedSourceIdentitySHA256,
            packageLockArtifact: .init(
                name: "package_lock",
                relativePath: "admission/Package.resolved",
                data: sourceFixture.packageLock.contents
            ),
            packageLockFile: packageLockFile,
            packageLockFileAfterAdmission:
                packageLockFileAfterAdmission,
            repositoryHEADOutput: bound(
                name: "repository_head",
                data: repositoryHEADOutputData
                    ?? Data((repositoryCommit + "\n").utf8)
            ),
            repositoryCommit: repositoryCommit,
            repositoryStatusOutput: bound(
                name: "repository_status",
                data: repositoryStatusOutputData ?? Data()
            ),
            repositoryTrackedTreeSHA256:
                repositoryTrackedTreeSHA256
                    ?? trackedTrees.repository.sha256,
            companionHEADOutput: bound(
                name: "companion_head",
                data: companionHEADOutputData
                    ?? Data((companionCommit + "\n").utf8)
            ),
            companionCommit: companionCommit,
            companionStatusOutput: bound(
                name: "companion_status",
                data: companionStatusOutputData ?? Data()
            ),
            companionTrackedTreeSHA256:
                companionTrackedTreeSHA256
                    ?? trackedTrees.companion.sha256,
            repositoryDescriptorClosureHeld: true,
            companionDescriptorClosureHeld: true,
            vnodeWatchersArmed: true,
            initialPendingVnodeEventCount: 0
        )
    }

    private func makeStaging(
        intent: PrimeValidationRunIntentV2
    ) -> PrimeValidationStagingLayoutReceiptV2 {
        let workspace = directory(
            role: .workspace,
            path: intent.roots.workspaceRoot.absolutePath,
            deviceID: intent.roots.workspaceRoot.deviceID,
            inode: intent.roots.workspaceRoot.inode,
            mode: 0o700
        )
        let evidence = directory(
            role: .evidence,
            path: intent.roots.evidenceRoot.absolutePath,
            deviceID: intent.roots.evidenceRoot.deviceID,
            inode: intent.roots.evidenceRoot.inode,
            mode: 0o700
        )
        let values = [
            ("cache", intent.roots.cacheRelativePath),
            ("clang_module_cache", intent.roots.clangModuleCacheRelativePath),
            ("config", intent.roots.configRelativePath),
            ("home", intent.roots.homeRelativePath),
            ("output", intent.roots.outputRelativePath),
            ("scratch", intent.roots.scratchRelativePath),
            ("security", intent.roots.securityRelativePath),
            ("swiftpm_module_cache", intent.roots.swiftPMModuleCacheRelativePath),
            ("temporary", intent.roots.temporaryRelativePath),
        ]
        let directories = values.enumerated().map { index, value in
            PrimeValidationStagingDirectoryObservationV2(
                name: value.0,
                relativePath: value.1,
                directory: directory(
                    role: .workspaceSubdirectory,
                    path: workspace.canonicalAbsolutePath + "/" + value.1,
                    deviceID: 1,
                    inode: UInt64(10 + index),
                    mode: 0o700
                )
            )
        }
        return .init(
            workspaceRoot: workspace,
            evidenceRoot: evidence,
            workspaceDirectories: directories,
            evidenceRunDirectory: directory(
                role: .evidenceRunDirectory,
                path: evidence.canonicalAbsolutePath + "/" + intent.runID,
                deviceID: 1,
                inode: 30,
                mode: 0o700
            ),
            exclusiveLeaseHeld: true,
            initiallyEmptyObserved: true,
            durableDirectorySynchronizationObserved: true
        )
    }

    private func copy(
        _ value: PrimeValidationExecutorAdmissionReceiptV2,
        intentSHA256: String? = nil,
        chain: [PrimeValidationAdmissionChainLinkV2]? = nil,
        policy: PrimeValidationExecutorAdmissionPolicyV2? = nil,
        launchPlan: PrimeValidationSwiftPackageAdmissionLaunchPlanV2? = nil,
        processExecutionObservation:
            PrimeValidationAdmissionObservationStateV2? = nil
    ) -> PrimeValidationExecutorAdmissionReceiptV2 {
        .init(
            intent: value.intent,
            intentSHA256: intentSHA256 ?? value.intentSHA256,
            authority: value.authority,
            policy: policy ?? value.policy,
            toolchain: value.toolchain,
            supervisorExecutable: value.supervisorExecutable,
            repository: value.repository,
            staging: value.staging,
            launchPlan: launchPlan ?? value.launchPlan,
            chain: chain ?? value.chain,
            processExecutionObservation:
                processExecutionObservation
                    ?? value.processExecutionObservation,
            buildExecutionObservation: value.buildExecutionObservation,
            inventoryExecutionObservation:
                value.inventoryExecutionObservation,
            shardCompletionObservation:
                value.shardCompletionObservation,
            statement: value.statement
        )
    }

    private func root(
        path: String,
        inode: UInt64,
        mode: UInt16 = 0o755
    ) -> PrimeValidationDirectoryBindingV2 {
        .init(
            absolutePath: path,
            deviceID: 1,
            inode: inode,
            ownerUserID: 501,
            mode: mode
        )
    }

    private func directory(
        role: PrimeValidationAdmissionDirectoryRoleV2,
        path: String,
        canonicalPath: String? = nil,
        deviceID: UInt64,
        inode: UInt64,
        ownerUserID: UInt32 = 501,
        ownerGroupID: UInt32 = 20,
        mode: UInt16,
        filesystemIDWord0: UInt32 = 10,
        filesystemIDWord1: UInt32 = 20,
        modificationTimeNanoseconds: Int64 = 0
    ) -> PrimeValidationCanonicalDirectoryObservationV2 {
        .init(
            role: role,
            requestedAbsolutePath: path,
            canonicalAbsolutePath: canonicalPath ?? path,
            deviceID: deviceID,
            inode: inode,
            ownerUserID: ownerUserID,
            ownerGroupID: ownerGroupID,
            mode: mode,
            linkCount: 1,
            filesystemType: "apfs",
            filesystemIDWord0: filesystemIDWord0,
            filesystemIDWord1: filesystemIDWord1,
            modificationTimeSeconds: 1,
            modificationTimeNanoseconds: modificationTimeNanoseconds,
            statusChangeTimeSeconds: 1,
            statusChangeTimeNanoseconds: 0,
            localFilesystemObserved: true,
            descriptorJoined: true,
            pathIdentityJoined: true,
            noSymlinkComponentsObserved: true
        )
    }

    private func heldExecutable(
        requestedPath: String,
        canonicalPath: String,
        symlinkTarget: String?,
        content: PrimeValidationContentBinding,
        inode: UInt64
    ) -> PrimeValidationHeldExecutableObservationV2 {
        .init(
            requestedAbsolutePath: requestedPath,
            canonicalAbsolutePath: canonicalPath,
            requestedSymlinkTarget: symlinkTarget,
            content: content,
            deviceID: 2,
            inode: inode,
            ownerUserID: 0,
            ownerGroupID: 0,
            mode: 0o755,
            linkCount: 1,
            fileByteCount: content.byteCount,
            modificationTimeSeconds: 1,
            modificationTimeNanoseconds: 0,
            statusChangeTimeSeconds: 1,
            statusChangeTimeNanoseconds: 0,
            mappedExecutableAbsolutePath: canonicalPath,
            descriptorJoined: true,
            pathIdentityJoined: true,
            mappedExecutableJoined: true
        )
    }

    private func heldRegularFile(
        role: PrimeValidationAdmissionRegularFileRoleV2,
        path: String,
        content: PrimeValidationContentBinding,
        deviceID: UInt64 = 1,
        ownerUserID: UInt32 = 501,
        ownerGroupID: UInt32 = 20,
        inode: UInt64,
        mode: UInt16
    ) -> PrimeValidationHeldRegularFileObservationV2 {
        .init(
            role: role,
            absolutePath: path,
            content: content,
            deviceID: deviceID,
            inode: inode,
            ownerUserID: ownerUserID,
            ownerGroupID: ownerGroupID,
            mode: mode,
            linkCount: 1,
            fileByteCount: content.byteCount,
            modificationTimeSeconds: 1,
            modificationTimeNanoseconds: 0,
            statusChangeTimeSeconds: 1,
            statusChangeTimeNanoseconds: 0,
            descriptorJoined: true,
            pathIdentityJoined: true,
            noSymlinkComponentsObserved: true,
            retainedDescriptorClosureHeld: true
        )
    }

    private func bound(
        name: String,
        data: Data
    ) -> PrimeValidationAdmissionBoundDataV2 {
        .init(
            name: name,
            relativePath: "admission/" + name + ".bin",
            data: data
        )
    }

    private func content(_ value: String) -> PrimeValidationContentBinding {
        .init(data: Data(value.utf8))
    }

    private struct GateDCanonicalTrackedTrees {
        let repository:
            PrimeValidationTrackedTreeManifestArtifactV2
        let companion:
            PrimeValidationTrackedTreeManifestArtifactV2
        let repositoryRawTree: Data
        let companionRawTree: Data
        let repositoryHeldEntries:
            [PrimeValidationDriverV2TrackedTreeHeldEntry]
        let companionHeldEntries:
            [PrimeValidationDriverV2TrackedTreeHeldEntry]
    }

    private struct GateDManifestEncoding: Codable {
        let artifactKind: String
        let schemaVersion: Int
        let rootRole: PrimeValidationTrackedTreeRootRoleV2
        let objectFormat: String
        let rawTree: GateDRawTreeEncoding
        let entries: [GateDManifestEntryEncoding]

        private enum CodingKeys: String, CodingKey {
            case artifactKind = "artifact_kind"
            case schemaVersion = "schema_version"
            case rootRole = "root_role"
            case objectFormat = "object_format"
            case rawTree = "raw_tree"
            case entries
        }
    }

    private struct GateDRawTreeEncoding: Codable {
        let bytes: Data
        let byteCount: UInt64
        let sha256: String

        private enum CodingKeys: String, CodingKey {
            case bytes
            case byteCount = "byte_count"
            case sha256
        }
    }

    private struct GateDManifestEntryEncoding: Codable {
        let rawPathBytes: Data
        let gitMode: String
        let gitObjectType: String
        let gitObjectID: String
        let heldKind: PrimeValidationTrackedTreeManifestHeldKindV2
        let byteCount: UInt64
        let sha256: String

        private enum CodingKeys: String, CodingKey {
            case rawPathBytes = "raw_path_bytes"
            case gitMode = "git_mode"
            case gitObjectType = "git_object_type"
            case gitObjectID = "git_object_id"
            case heldKind = "held_kind"
            case byteCount = "byte_count"
            case sha256
        }
    }

    private func gateDCanonicalTrackedTrees() throws
        -> GateDCanonicalTrackedTrees
    {
        let repositoryHeldEntries = [
            try gateDHeldEntry(
                rawPath: Data("Sources/A.swift".utf8),
                contents: Data("let a = 1\n".utf8),
                inode: 9_001
            ),
            try gateDHeldEntry(
                rawPath: Data("bin/tool".utf8),
                contents: Data("#!/bin/false\n".utf8),
                executable: true,
                inode: 9_002
            ),
        ]
        let repositoryRawTree = gateDTree([
            gateDRecord(
                mode: "100644",
                held: repositoryHeldEntries[0]
            ),
            gateDRecord(
                mode: "100755",
                held: repositoryHeldEntries[1]
            ),
        ])
        let companionHeldEntries = [
            try gateDHeldEntry(
                rawPath: Data("Package.swift".utf8),
                contents: Data("// companion fixture\n".utf8),
                inode: 9_101
            ),
        ]
        let companionRawTree = gateDRecord(
            mode: "100644",
            held: companionHeldEntries[0]
        )
        return GateDCanonicalTrackedTrees(
            repository:
                try PrimeValidationTrackedTreeManifestBuilderV2
                    .repository(
                        objectFormatOutput: Data("sha1\n".utf8),
                        rawTreeOutput: repositoryRawTree,
                        heldEntries: repositoryHeldEntries
                    ),
            companion:
                try PrimeValidationTrackedTreeManifestBuilderV2
                    .companion(
                        objectFormatOutput: Data("sha1\n".utf8),
                        rawTreeOutput: companionRawTree,
                        heldEntries: companionHeldEntries
                    ),
            repositoryRawTree: repositoryRawTree,
            companionRawTree: companionRawTree,
            repositoryHeldEntries: repositoryHeldEntries,
            companionHeldEntries: companionHeldEntries
        )
    }

    private func gateDHeldEntry(
        rawPath: Data,
        contents: Data,
        executable: Bool = false,
        permissionMode: UInt16? = nil,
        kind: PrimeValidationDriverV2TrackedTreeHeldKind = .regularFile,
        inode: UInt64
    ) throws -> PrimeValidationDriverV2TrackedTreeHeldEntry {
        let identity = gateDIdentity(
            contents: contents,
            inode: inode,
            kind: kind == .regularFile ? .regularFile : .symbolicLink,
            permissionMode:
                permissionMode
                    ?? (kind == .symbolicLink
                        ? 0o777 : (executable ? 0o755 : 0o644))
        )
        return try PrimeValidationDriverV2TrackedTreeHeldEntry(
            validatingRawPathBytes: rawPath,
            kind: kind,
            openedIdentity: identity,
            postReadDescriptorIdentity: identity,
            namedPathReboundIdentity: identity,
            contents: contents
        )
    }

    private func gateDIdentity(
        contents: Data,
        inode: UInt64,
        kind: PrimeValidationDriverV2TrackedTreePOSIXFileType,
        deviceID: UInt64 = 7,
        permissionMode: UInt16 = 0o644
    ) -> PrimeValidationDriverV2TrackedTreeHeldIdentity {
        PrimeValidationDriverV2TrackedTreeHeldIdentity(
            deviceID: deviceID,
            inode: inode,
            ownerUserID: 501,
            ownerGroupID: 20,
            permissionMode: permissionMode,
            linkCount: 1,
            byteCount: UInt64(contents.count),
            posixFileType: kind
        )
    }

    private func gateDRecord(
        mode: String,
        held: PrimeValidationDriverV2TrackedTreeHeldEntry
    ) -> Data {
        gateDRecord(
            mode: mode,
            objectID: held.gitBlobSHA1,
            path: held.rawPathBytes
        )
    }

    private func gateDRecord(
        mode: String,
        objectType: String = "blob",
        objectID: String,
        path: Data
    ) -> Data {
        var record = Data(
            (mode + " " + objectType + " " + objectID + "\t").utf8
        )
        record.append(path)
        record.append(0)
        return record
    }

    private func gateDTree(_ records: [Data]) -> Data {
        records.reduce(into: Data()) { $0.append($1) }
    }

    private func gateDRawTreeEncoding(
        _ rawTree: Data
    ) -> GateDRawTreeEncoding {
        GateDRawTreeEncoding(
            bytes: rawTree,
            byteCount: UInt64(rawTree.count),
            sha256: PrimeSHA256.hexDigest(of: rawTree)
        )
    }

    private func gateDManifestEntryEncoding(
        mode: String,
        objectID: String,
        rawPath: Data,
        byteCount: UInt64,
        sha256: String
    ) -> GateDManifestEntryEncoding {
        GateDManifestEntryEncoding(
            rawPathBytes: rawPath,
            gitMode: mode,
            gitObjectType: "blob",
            gitObjectID: objectID,
            heldKind: mode == "120000" ? .symbolicLink : .regularFile,
            byteCount: byteCount,
            sha256: sha256
        )
    }

    private func gateDManifestEncoding(
        role: PrimeValidationTrackedTreeRootRoleV2,
        rawTree: Data,
        entries: [
            (String, PrimeValidationDriverV2TrackedTreeHeldEntry)
        ],
        entrySHA256Override: String? = nil
    ) -> GateDManifestEncoding {
        GateDManifestEncoding(
            artifactKind:
                PrimeValidationTrackedTreeManifestV2.artifactKind,
            schemaVersion:
                PrimeValidationTrackedTreeManifestV2.schemaVersion,
            rootRole: role,
            objectFormat:
                PrimeValidationTrackedTreeManifestV2.objectFormat,
            rawTree: gateDRawTreeEncoding(rawTree),
            entries: entries.map { mode, held in
                gateDManifestEntryEncoding(
                    mode: mode,
                    objectID: held.gitBlobSHA1,
                    rawPath: held.rawPathBytes,
                    byteCount: held.byteCount,
                    sha256: entrySHA256Override ?? held.sha256
                )
            }
        )
    }

    private func assertGateDRepositoryRejects(
        objectFormat: Data = Data("sha1\n".utf8),
        rawTree: Data,
        heldEntries: [PrimeValidationDriverV2TrackedTreeHeldEntry],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeValidationTrackedTreeManifestBuilderV2.repository(
                objectFormatOutput: objectFormat,
                rawTreeOutput: rawTree,
                heldEntries: heldEntries
            ),
            file: file,
            line: line
        )
    }

    private func sourceFixture() throws -> SourceFixture {
        try Self.sourceFixtureResult.get()
    }
}
