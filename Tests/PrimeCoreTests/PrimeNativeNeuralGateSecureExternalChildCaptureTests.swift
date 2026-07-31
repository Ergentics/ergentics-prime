import Darwin
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeNativeNeuralGateSecureExternalChildCaptureTests:
    XCTestCase
{
    private static let authorityRelativePath =
        "Sources/PrimeCore/" +
        "PrimeNativeNeuralGateSecureExternalChildCapture.swift"
    private static let lifecycleRelativePath =
        "Sources/PrimeCore/" +
        "PrimeNativeNeuralGateSecureChildLifecycle.swift"
    private static let scratchRelativePath =
        "Sources/PrimeCore/" +
        "PrimeNativeNeuralGateSecureScratchNamespace.swift"
    private static let swiftPackageExecutableAbsolutePath =
        "/Applications/Xcode.app/Contents/Developer/" +
        "Toolchains/XcodeDefault.xctoolchain/usr/bin/" +
        "swift-package"
    private static let mappedRegionResultByteCount =
        Int32(
            MemoryLayout<
                proc_regionwithpathinfo
            >.size
        )

    func testFactorySourceAndPublicAPIStayClosedAndOrdered()
        throws
    {
        let root = packageRoot()
        let source = try String(
            contentsOfFile:
                root.appendingPathComponent(
                    Self.authorityRelativePath
                ).path,
            encoding: .utf8
        )
        let lifecycleSource = try String(
            contentsOfFile:
                root.appendingPathComponent(
                    Self.lifecycleRelativePath
                ).path,
            encoding: .utf8
        )
        let scratchSource = try String(
            contentsOfFile:
                root.appendingPathComponent(
                    Self.scratchRelativePath
                ).path,
            encoding: .utf8
        )
        let package = try String(
            contentsOfFile:
                root.appendingPathComponent(
                    "Package.swift"
                ).path,
            encoding: .utf8
        )
        let executionSources =
            source
            + "\n"
            + lifecycleSource
            + "\n"
            + scratchSource

        let processConstructor =
            try NSRegularExpression(
                pattern:
                    #"\b(?:Foundation\.)?Process\s*\("#
            )
        XCTAssertEqual(
            processConstructor.numberOfMatches(
                in: executionSources,
                range: NSRange(
                    executionSources.startIndex...,
                    in: executionSources
                )
            ),
            0,
            "the capture authority must use its typed Darwin lifecycle, not Foundation Process"
        )
        for forbidden in [
            "NSTask",
            "posix_spawnp",
            "execve(",
            "execl(",
            "execlp(",
            "system(",
            "popen(",
            "/usr/bin/python",
            "/bin/python",
            "\"python3\"",
            "/bin/sh",
            "/bin/zsh",
            "/bin/bash",
            "/usr/bin/env",
        ] {
            XCTAssertFalse(
                executionSources
                    .contains(forbidden),
                "secure capture admits a forbidden execution route: \(forbidden)"
            )
        }

        let captureSignature =
            try publicCaptureSignature(
                in: source
            )
        XCTAssertEqual(
            withoutWhitespace(captureSignature),
            "publicstaticfunccapture(role:PrimeNativeNeuralGateReleaseProcessRole,sourceRoot:URL)throws->PrimeNativeNeuralGateSecureExternalChildCaptureResult"
        )
        for forbiddenControl in [
            "executable",
            "argument",
            "environment",
            "command",
            "shell",
            "timeout",
            "deadline",
            "limit",
            "maximum",
            "signal",
            "processGroup",
            "expected",
            "sha256",
            "byteCount",
            "contract",
            "calibration",
            "overflow",
            "drain",
            "wait",
            "pid",
        ] {
            XCTAssertFalse(
                captureSignature.localizedCaseInsensitiveContains(
                    forbiddenControl
                ),
                "public capture exposes a caller-selectable authority control: \(forbiddenControl)"
            )
        }
        XCTAssertEqual(
            occurrences(
                of: "public static func capture(",
                in: source
            ),
            1
        )
        XCTAssertFalse(
            source.contains("public init("),
            "the result or trusted mechanics gained a public constructor"
        )
        let publicLifecycleDeclaration =
            try NSRegularExpression(
                pattern: #"(?m)^\s*public\s"#
            )
        XCTAssertEqual(
            publicLifecycleDeclaration
                .numberOfMatches(
                    in: lifecycleSource,
                    range: NSRange(
                        lifecycleSource
                            .startIndex...,
                        in: lifecycleSource
                    )
                ),
            0,
            "the lifecycle seam must remain PrimeCore-internal"
        )
        XCTAssertTrue(
            source.contains(
                "private static let executableAbsolutePath"
            )
        )
        XCTAssertTrue(
            source.contains(
                "exactArguments:\n                    scratchLaunch\n                    .arguments"
            )
        )
        XCTAssertTrue(
            source.contains(
                "orderedEnvironment:\n                    scratchLaunch\n                    .orderedEnvironment"
            )
        )
        XCTAssertFalse(
            source.contains("emptyEnvironment")
        )
        XCTAssertFalse(
            source.contains(".build")
        )
        XCTAssertFalse(
            scratchSource.contains(".build")
        )
        XCTAssertFalse(
            executionSources.contains(
                "--disable-sandbox"
            )
        )
        XCTAssertFalse(
            executionSources.contains(
                "--skip-update"
            )
        )
        XCTAssertTrue(
            source.contains(
                "swiftPackageDescribeMaximumWallSeconds"
            )
        )
        XCTAssertTrue(
            source.contains(
                "swiftPackageDescribeMaximumStandardOutputBytes"
            )
        )
        XCTAssertTrue(
            source.contains(
                "swiftPackageDescribeMaximumStandardErrorBytes"
            )
        )
        XCTAssertTrue(
            source.contains(
                "posix_spawn("
            )
        )
        XCTAssertFalse(
            package.contains(
                "PrimeNativeNeuralGateSecureExternalChildCapture"
            ),
            "the capture slice added a helper target or product"
        )

        assertAppearsInOrder(
            [
                "let preSourceSnapshot =",
                "let preManifest =",
                "let heldSourceClosure =",
                "let scratch =",
                "let scratchLaunch =",
                "let executable =",
                "let preSpawnRead =",
                "spawn = try spawnSuspendedChild(",
                "child.startDeathObservation()",
                ".establishIsolatedSessionAndDedicatedGroup()",
                "let childSessionAndProcessGroupObservedMonotonicNanoseconds =",
                "let workingDirectoryObservation =",
                "let mappedTranscript =",
                "let preResumeRead =",
                ".validateBeforeResume()",
                "let scratchPreResumeValidationMonotonicNanoseconds =",
                "wall_deadline_before_resume",
                "let sigcontResult =",
                "child.markResumed()",
                "guard child.observeDeath(",
                "switch child.reapAfterObservedDeath()",
                "let postReapRead =",
                "let postSourceSnapshot =",
                "guard preSourceSnapshot",
                ".validateAfterReap()",
                "let scratchPostReapValidationMonotonicNanoseconds =",
                "let scratchNamespace =",
                "let evidence =",
                "try evidence.validate(",
                "let trustedCapture =",
                "try trustedCapture.validate(",
                "PrimeNativeNeuralGateSecureExternalChildCaptureResult(",
            ],
            in: source
        )
        assertAppearsInOrder(
            [
                "posix_spawn_file_actions_addinherit_np(",
                "posix_spawn_file_actions_addfchdir(",
                "posix_spawn_file_actions_addclose(",
                "posix_spawn_file_actions_addopen(",
                "posix_spawn_file_actions_adddup2(",
                "posix_spawnattr_setsigdefault(",
                "posix_spawnattr_setsigmask(",
                "posix_spawnattr_setflags(",
                "posix_spawn(",
            ],
            in: source
        )
        for requiredCleanup in [
            "cleanupRejectedCapture()",
            "finishRejectedDrains(",
            "failStop(reason)",
        ] {
            XCTAssertTrue(
                source.contains(requiredCleanup),
                "spawned rejection lacks mandatory cleanup: \(requiredCleanup)"
            )
        }
        for requiredLifecycle in [
            "case directPIDOnly",
            "case isolatedSessionAndDedicatedGroup",
            "case nonblockingContainmentProbe",
            "boundedNonblockingReap()",
            "maximumContainmentPollCount",
            "guard !hasReaped",
        ] {
            XCTAssertTrue(
                lifecycleSource
                    .contains(
                        requiredLifecycle
                    ),
                "typed lifecycle is missing: \(requiredLifecycle)"
            )
        }
        XCTAssertTrue(
            source.contains("Darwin._exit(70)"),
            "an uncontained child or drain must not fall through as an ordinary thrown rejection"
        )
    }

    func testMappedRegionEnumeratorAcceptsTerminalEINVALAfterExactMatch()
        throws
    {
        let snapshot =
            mappedExecutableSnapshot()
        var results = [
            mappedRegionResult(
                address: 0x1_000,
                byteCount: 0x1_000,
                fileOffset: 0x20_000,
                protection: 1,
                deviceID: 101,
                inode: 103,
                mappedVnodePath:
                    "/usr/lib/dyld"
            ),
            mappedRegionResult(
                address: 0x3_000,
                byteCount: 0x2_000,
                fileOffset: 0,
                protection:
                    UInt32(
                        VM_PROT_READ
                        | VM_PROT_EXECUTE
                    ),
                deviceID:
                    snapshot.deviceID,
                inode: snapshot.inode,
                mappedVnodePath:
                    Self
                    .swiftPackageExecutableAbsolutePath
            ),
            terminalMappedRegionResult(
                queryErrno: EINVAL
            ),
        ]
        var observedQueryAddresses:
            [UInt64] = []

        let transcript =
            try PrimeNativeNeuralGateSecureExternalChildCapture
            .evaluateMappedRegionTranscript(
                executableSnapshot:
                    snapshot,
                contract: .frozenV6,
                queryLimit: 8
            ) {
                queryAddress in
                observedQueryAddresses
                    .append(queryAddress)
                return results.removeFirst()
            }

        XCTAssertEqual(
            observedQueryAddresses,
            [0, 0x2_000, 0x5_000]
        )
        XCTAssertEqual(
            transcript.queries.count,
            2
        )
        XCTAssertEqual(
            transcript.terminalQueryAddress,
            0x5_000
        )
        XCTAssertEqual(
            transcript.terminalReturnByteCount,
            0
        )
        XCTAssertEqual(
            transcript.terminalErrno,
            EINVAL
        )
        XCTAssertEqual(
            transcript
                .mappedExecutablePathTelemetry,
            Self
                .swiftPackageExecutableAbsolutePath
        )
        XCTAssertEqual(
            transcript.queries
                .map(\.region)
                .filter {
                    $0.deviceID
                            == snapshot.deviceID
                        && $0.inode
                            == snapshot.inode
                },
            [
                transcript.queries[1].region,
            ]
        )
    }

    func testMappedRegionEnumeratorRejectsEarlyTerminalEINVAL()
    {
        assertMappedRegionEnumerationRejects(
            [
                terminalMappedRegionResult(
                    queryErrno: EINVAL
                ),
            ],
            expectedDetail:
                "mapped_region_terminal_\(EINVAL)",
            expectedQueryAddresses: [0]
        )
    }

    func testMappedRegionEnumeratorRejectsUnexpectedTerminalErrno()
    {
        for unexpectedErrno in [
            Int32(0),
            Int32(ESRCH),
        ] {
            assertMappedRegionEnumerationRejects(
                [
                    exactMatchedMappedRegionResult(),
                    terminalMappedRegionResult(
                        queryErrno:
                            unexpectedErrno
                    ),
                ],
                expectedDetail:
                    "mapped_region_terminal_\(unexpectedErrno)",
                expectedQueryAddresses:
                    [0, 0x2_000]
            )
        }
    }

    func testMappedRegionEnumeratorRejectsSuccessRowWithNonzeroErrno()
    {
        assertMappedRegionEnumerationRejects(
            [
                mappedRegionResult(
                    queryErrno: EIO,
                    address: 0x1_000,
                    byteCount: 0x1_000,
                    fileOffset: 0,
                    protection:
                        UInt32(
                            VM_PROT_READ
                            | VM_PROT_EXECUTE
                        ),
                    deviceID: 7,
                    inode: 11,
                    mappedVnodePath:
                        Self
                        .swiftPackageExecutableAbsolutePath
                ),
            ],
            expectedDetail:
                "mapped_region_query_\(Self.mappedRegionResultByteCount)_\(EIO)",
            expectedQueryAddresses: [0]
        )
    }

    func testMappedRegionEnumeratorRejectsNonprogressAndZeroSize()
    {
        assertMappedRegionEnumerationRejects(
            [
                exactMatchedMappedRegionResult(),
                mappedRegionResult(
                    address: 0x1_fff,
                    byteCount: 0x1_000,
                    fileOffset: 0x1_000,
                    protection: 1,
                    deviceID: 101,
                    inode: 103,
                    mappedVnodePath: nil
                ),
            ],
            expectedDetail:
                "mapped_region_progress",
            expectedQueryAddresses:
                [0, 0x2_000]
        )
        assertMappedRegionEnumerationRejects(
            [
                mappedRegionResult(
                    address: 0x1_000,
                    byteCount: 0,
                    fileOffset: 0,
                    protection: 5,
                    deviceID: 7,
                    inode: 11,
                    mappedVnodePath:
                        Self
                        .swiftPackageExecutableAbsolutePath
                ),
            ],
            expectedDetail:
                "mapped_region_progress",
            expectedQueryAddresses: [0]
        )
    }

    func testMappedRegionEnumeratorRejectsAddressPlusSizeOverflow()
    {
        assertMappedRegionEnumerationRejects(
            [
                mappedRegionResult(
                    address:
                        UInt64.max
                        - 0xfff,
                    byteCount: 0x1_000,
                    fileOffset: 0,
                    protection: 5,
                    deviceID: 7,
                    inode: 11,
                    mappedVnodePath:
                        Self
                        .swiftPackageExecutableAbsolutePath
                ),
            ],
            expectedDetail:
                "mapped_region_progress",
            expectedQueryAddresses: [0]
        )
    }

    func testMappedRegionEnumeratorRejectsExecutableJoinMutations()
    {
        let exactPath =
            Self
            .swiftPackageExecutableAbsolutePath
        let cases:
            [(
                name: String,
                rows:
                    [PrimeNativeNeuralGateSecureExternalChildCapture.MappedRegionQueryResult]
            )] = [
                (
                    "path without descriptor vnode",
                    [
                        mappedRegionResult(
                            address: 0x1_000,
                            byteCount: 0x1_000,
                            fileOffset: 0,
                            protection: 5,
                            deviceID: 101,
                            inode: 103,
                            mappedVnodePath:
                                exactPath
                        ),
                    ]
                ),
                (
                    "descriptor vnode executable begins at nonzero file offset",
                    [
                        mappedRegionResult(
                            address: 0x1_000,
                            byteCount: 0x1_000,
                            fileOffset: 0x1_000,
                            protection: 5,
                            deviceID: 7,
                            inode: 11,
                            mappedVnodePath:
                                exactPath
                        ),
                    ]
                ),
                (
                    "descriptor vnode offset zero is not executable",
                    [
                        mappedRegionResult(
                            address: 0x1_000,
                            byteCount: 0x1_000,
                            fileOffset: 0,
                            protection: 1,
                            deviceID: 7,
                            inode: 11,
                            mappedVnodePath:
                                exactPath
                        ),
                    ]
                ),
                (
                    "descriptor vnode has writable executable region",
                    [
                        mappedRegionResult(
                            address: 0x1_000,
                            byteCount: 0x1_000,
                            fileOffset: 0,
                            protection:
                                UInt32(
                                    VM_PROT_READ
                                    | VM_PROT_WRITE
                                    | VM_PROT_EXECUTE
                                ),
                            deviceID: 7,
                            inode: 11,
                            mappedVnodePath:
                                exactPath
                        ),
                    ]
                ),
                (
                    "descriptor vnode path differs from pinned executable",
                    [
                        mappedRegionResult(
                            address: 0x1_000,
                            byteCount: 0x1_000,
                            fileOffset: 0,
                            protection: 5,
                            deviceID: 7,
                            inode: 11,
                            mappedVnodePath:
                                "/tmp/swift-package"
                        ),
                    ]
                ),
                (
                    "descriptor vnode reports two paths",
                    [
                        exactMatchedMappedRegionResult(),
                        mappedRegionResult(
                            address: 0x2_000,
                            byteCount: 0x1_000,
                            fileOffset: 0x1_000,
                            protection: 1,
                            deviceID: 7,
                            inode: 11,
                            mappedVnodePath:
                                "/tmp/swift-package"
                        ),
                    ]
                ),
            ]

        for item in cases {
            var results =
                item.rows
            let terminalAddress =
                item.rows.reduce(
                    UInt64(0)
                ) {
                    _, result in
                    guard let region =
                            result.region
                    else {
                        return 0
                    }
                    return region.address
                        + region.byteCount
                }
            results.append(
                terminalMappedRegionResult(
                    queryErrno: EINVAL
                )
            )
            var observedQueryAddresses:
                [UInt64] = []
            XCTAssertThrowsError(
                try PrimeNativeNeuralGateSecureExternalChildCapture
                    .evaluateMappedRegionTranscript(
                        executableSnapshot:
                            mappedExecutableSnapshot(),
                        contract: .frozenV6,
                        queryLimit: 8
                    ) {
                        queryAddress in
                        observedQueryAddresses
                            .append(
                                queryAddress
                            )
                        return results
                            .removeFirst()
                    },
                item.name
            ) {
                error in
                XCTAssertEqual(
                    error
                        as? PrimeNativeNeuralGateSecureExternalChildCaptureError,
                    .rejected(
                        "mapped_executable_join"
                    ),
                    item.name
                )
            }
            XCTAssertEqual(
                observedQueryAddresses.last,
                terminalAddress,
                item.name
            )
        }
    }

    func testMappedRegionEnumeratorRejectsInjectedQueryLimit()
    {
        var invocationCount = 0
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateSecureExternalChildCapture
                .evaluateMappedRegionTranscript(
                    executableSnapshot:
                        mappedExecutableSnapshot(),
                    contract: .frozenV6,
                    queryLimit: 1
                ) {
                    queryAddress in
                    invocationCount += 1
                    XCTAssertEqual(
                        queryAddress,
                        0
                    )
                    return
                        self
                        .exactMatchedMappedRegionResult()
                }
        ) {
            error in
            XCTAssertEqual(
                error
                    as? PrimeNativeNeuralGateSecureExternalChildCaptureError,
                .rejected(
                    "mapped_region_query_limit"
                )
            )
        }
        XCTAssertEqual(
            invocationCount,
            1
        )
    }

    func testReleasePinnedTwoRoleFactoryCanary()
        throws
    {
        #if DEBUG
            throw XCTSkip(
                "real secure-child execution is a Release-only pinned-host canary"
            )
        #else
            try runReleasePinnedTwoRoleFactoryCanary()
        #endif
    }

    private func runReleasePinnedTwoRoleFactoryCanary()
        throws
    {
        guard #available(macOS 26.0, *)
        else {
            throw XCTSkip(
                "the frozen external-child ABI requires macOS 26"
            )
        }
        let sourceRoot =
            packageRoot()
        let probe =
            try PrimeNativeNeuralGateSecureExternalChildCapture
            .capture(
                role: .probe,
                sourceRoot: sourceRoot
            )
        let verifier =
            try PrimeNativeNeuralGateSecureExternalChildCapture
            .capture(
                role: .verifier,
                sourceRoot: sourceRoot
            )

        try assertLiveCapture(
            probe,
            role: .probe,
            sourceRoot: sourceRoot
        )
        try assertLiveCapture(
            verifier,
            role: .verifier,
            sourceRoot: sourceRoot
        )
        XCTAssertEqual(
            probe.standardOutputData,
            verifier.standardOutputData
        )
        // Intentionally resealed only from the live Release canary after the
        // final compiled source-file set is frozen.
        XCTAssertEqual(
            probe.standardOutputData.count,
            26_090
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: probe.standardOutputData
            ),
            "53ace0b68b1f8f2cf6534be886cb93241b08a36e0ddf0e9da7f8eee33f37cb40"
        )
        XCTAssertEqual(
            probe.validatedPrimeSourceSnapshot,
            verifier.validatedPrimeSourceSnapshot
        )
        XCTAssertEqual(
            probe.validatedPrimeSourceSnapshotBinding,
            verifier.validatedPrimeSourceSnapshotBinding
        )
        XCTAssertEqual(
            probe.packageManifestSHA256,
            verifier.packageManifestSHA256
        )
        XCTAssertEqual(
            probe.packageManifestByteCount,
            verifier.packageManifestByteCount
        )
        XCTAssertNotEqual(
            probe.evidence.childProcessIdentifier,
            verifier.evidence.childProcessIdentifier
        )
        XCTAssertNotEqual(
            probe.childProcessGroupIdentifier,
            verifier.childProcessGroupIdentifier
        )
        XCTAssertNotEqual(
            probe.scratchNamespace
                .runRootAbsolutePath,
            verifier.scratchNamespace
                .runRootAbsolutePath
        )
        XCTAssertEqual(
            probe.evidence.supervisorProcessIdentifier,
            verifier.evidence.supervisorProcessIdentifier
        )
        XCTAssertEqual(
            probe.evidence.supervisorProcessIdentifier,
            getpid()
        )
    }

    private func packageRoot() -> URL {
        URL(
            fileURLWithPath: #filePath,
            isDirectory: false
        )
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .standardizedFileURL
    }

    private func assertLiveCapture(
        _ capture:
            PrimeNativeNeuralGateSecureExternalChildCaptureResult,
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        sourceRoot: URL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let contract =
            PrimeNativeNeuralGateSourceExecutionBindingContract
            .frozenV6
        let evidence = capture.evidence
        let wait = evidence.exactPIDWaitObservation
        let workingDirectory =
            evidence.workingDirectory
        let matching =
            evidence.matchingMappedRegions
        let execute = UInt32(VM_PROT_EXECUTE)
        let write = UInt32(VM_PROT_WRITE)

        XCTAssertEqual(
            capture.role,
            role,
            file: file,
            line: line
        )
        XCTAssertEqual(
            capture.scratchNamespace,
            evidence.scratchNamespace,
            file: file,
            line: line
        )
        XCTAssertEqual(
            capture.scratchNamespace.role,
            role,
            file: file,
            line: line
        )
        XCTAssertTrue(
            evidence
                .sourceClosureMutationGuard
                .repositoryBuildDirectoryUnused,
            file: file,
            line: line
        )
        XCTAssertEqual(
            capture.workingDirectoryAbsolutePath,
            sourceRoot.path,
            file: file,
            line: line
        )
        XCTAssertFalse(
            capture.standardOutputData.isEmpty,
            file: file,
            line: line
        )
        XCTAssertLessThanOrEqual(
            UInt64(capture.standardOutputData.count),
            contract
                .swiftPackageDescribeMaximumStandardOutputBytes,
            file: file,
            line: line
        )
        XCTAssertTrue(
            capture.standardErrorData.isEmpty,
            file: file,
            line: line
        )
        XCTAssertNotNil(
            try JSONSerialization.jsonObject(
                with: capture.standardOutputData
            ) as? [String: Any],
            file: file,
            line: line
        )

        XCTAssertEqual(
            evidence.childProcessIdentifier,
            capture.childProcessGroupIdentifier,
            file: file,
            line: line
        )
        XCTAssertEqual(
            evidence
                .observedChildProcessGroupIdentifier,
            evidence.childProcessIdentifier,
            file: file,
            line: line
        )
        XCTAssertEqual(
            evidence.observedChildSessionIdentifier,
            evidence.childProcessIdentifier,
            file: file,
            line: line
        )
        XCTAssertEqual(
            evidence
                .preReapProcessGroupMemberIdentifiers,
            [
                evidence.childProcessIdentifier,
            ],
            file: file,
            line: line
        )
        XCTAssertTrue(
            evidence.processGroupEmptyAfterReap,
            file: file,
            line: line
        )
        XCTAssertFalse(
            evidence.deadlineExpired,
            file: file,
            line: line
        )
        XCTAssertFalse(
            evidence.sigtermDelivered,
            file: file,
            line: line
        )
        XCTAssertFalse(
            evidence.sigkillDelivered,
            file: file,
            line: line
        )

        XCTAssertFalse(
            matching.isEmpty,
            file: file,
            line: line
        )
        XCTAssertTrue(
            matching.contains {
                $0.fileOffset == 0
                    && ($0.protection & execute)
                        != 0
            },
            "the descriptor-vnode map lacks one combined offset-zero executable region",
            file: file,
            line: line
        )
        XCTAssertFalse(
            matching.contains {
                ($0.protection & write) != 0
                    && ($0.protection & execute)
                        != 0
            },
            "the descriptor-vnode map contains a writable executable region",
            file: file,
            line: line
        )
        XCTAssertTrue(
            matching.allSatisfy {
                $0.deviceID
                        == evidence
                        .preSpawnDescriptor
                        .deviceID
                    && $0.inode
                        == evidence
                        .preSpawnDescriptor
                        .inode
            },
            file: file,
            line: line
        )
        XCTAssertTrue(
            evidence.mappedRegionEnumerationCompleted,
            file: file,
            line: line
        )
        XCTAssertEqual(
            evidence
                .terminalMappedRegionQueryReturnByteCount,
            0,
            file: file,
            line: line
        )
        XCTAssertEqual(
            evidence.terminalMappedRegionQueryErrno,
            Int32(EINVAL),
            file: file,
            line: line
        )

        XCTAssertTrue(
            workingDirectory
                .descriptorJoinedToSuspendedChildCurrentDirectory,
            file: file,
            line: line
        )
        XCTAssertEqual(
            workingDirectory.descriptorDeviceID,
            workingDirectory
                .suspendedChildCurrentDirectoryDeviceID,
            file: file,
            line: line
        )
        XCTAssertEqual(
            workingDirectory.descriptorInode,
            workingDirectory
                .suspendedChildCurrentDirectoryInode,
            file: file,
            line: line
        )
        XCTAssertEqual(
            capture.workingDirectoryDeviceID,
            workingDirectory.descriptorDeviceID,
            file: file,
            line: line
        )
        XCTAssertEqual(
            capture.workingDirectoryInode,
            workingDirectory.descriptorInode,
            file: file,
            line: line
        )

        XCTAssertEqual(
            wait.requestedProcessIdentifier,
            evidence.childProcessIdentifier,
            file: file,
            line: line
        )
        XCTAssertEqual(
            wait.returnedProcessIdentifier,
            evidence.childProcessIdentifier,
            file: file,
            line: line
        )
        XCTAssertEqual(
            wait.waitOptions,
            0,
            file: file,
            line: line
        )
        XCTAssertEqual(
            wait.rawWaitStatus,
            0,
            file: file,
            line: line
        )
        XCTAssertTrue(
            wait.exitedNormally,
            file: file,
            line: line
        )
        XCTAssertEqual(
            wait.exitStatus,
            0,
            file: file,
            line: line
        )
        XCTAssertEqual(
            wait.terminationSignal,
            0,
            file: file,
            line: line
        )
        XCTAssertFalse(
            wait.coreDumped,
            file: file,
            line: line
        )
        XCTAssertTrue(
            wait.childTerminationObserved,
            file: file,
            line: line
        )
        XCTAssertTrue(
            wait.childReaped,
            file: file,
            line: line
        )

        XCTAssertEqual(
            evidence.preSpawnDescriptor,
            evidence.preResumeDescriptor,
            file: file,
            line: line
        )
        XCTAssertEqual(
            evidence.preSpawnDescriptor,
            evidence.postReapDescriptor,
            file: file,
            line: line
        )
        let snapshotData =
            try PrimeCanonicalJSON.encode(
                capture.validatedPrimeSourceSnapshot
            )
        XCTAssertEqual(
            capture
                .validatedPrimeSourceSnapshotBinding
                .sha256,
            PrimeSHA256.hexDigest(
                of: snapshotData
            ),
            file: file,
            line: line
        )
        XCTAssertEqual(
            capture
                .validatedPrimeSourceSnapshotBinding
                .byteCount,
            UInt64(snapshotData.count),
            file: file,
            line: line
        )
        let manifest = try XCTUnwrap(
            capture
                .validatedPrimeSourceSnapshot
                .files
                .first {
                    $0.relativePath
                        == "Package.swift"
                },
            file: file,
            line: line
        )
        XCTAssertEqual(
            capture.packageManifestSHA256,
            manifest.sha256,
            file: file,
            line: line
        )
        XCTAssertEqual(
            capture.packageManifestByteCount,
            manifest.byteCount,
            file: file,
            line: line
        )
    }

    private func mappedExecutableSnapshot(
        deviceID: UInt64 = 7,
        inode: UInt64 = 11
    )
        -> PrimeNativeNeuralGateExecutableDescriptorSnapshot
    {
        let contract =
            PrimeNativeNeuralGateSourceExecutionBindingContract
            .frozenV6
        return
            PrimeNativeNeuralGateExecutableDescriptorSnapshot(
                deviceID: deviceID,
                inode: inode,
                byteCount:
                    contract
                    .swiftPackageDescribeExpectedExecutableByteCount,
                sha256:
                    contract
                    .swiftPackageDescribeExpectedExecutableSHA256,
                ownerUserID:
                    contract
                    .swiftPackageDescribeExpectedExecutableOwnerUserID,
                ownerGroupID:
                    contract
                    .swiftPackageDescribeExpectedExecutableOwnerGroupID,
                permissionMode:
                    contract
                    .swiftPackageDescribeExpectedExecutablePermissionMode,
                linkCount:
                    contract
                    .swiftPackageDescribeExpectedExecutableLinkCount,
                modificationTimeSeconds: 100,
                modificationTimeNanoseconds: 200,
                statusChangeTimeSeconds: 300,
                statusChangeTimeNanoseconds: 400,
                regularFile: true,
                openedWithNoSymbolicLinksInPath:
                    true,
                closeOnExec: true
            )
    }

    private func mappedRegionResult(
        returnedByteCount:
            Int32 =
            PrimeNativeNeuralGateSecureExternalChildCaptureTests
            .mappedRegionResultByteCount,
        queryErrno: Int32 = 0,
        address: UInt64,
        byteCount: UInt64,
        fileOffset: UInt64,
        protection: UInt32,
        deviceID: UInt64,
        inode: UInt64,
        mappedVnodePath: String?
    )
        -> PrimeNativeNeuralGateSecureExternalChildCapture.MappedRegionQueryResult
    {
        PrimeNativeNeuralGateSecureExternalChildCapture
            .MappedRegionQueryResult(
                returnedByteCount:
                    returnedByteCount,
                queryErrno: queryErrno,
                region:
                    PrimeNativeNeuralGateMappedExecutableRegionObservation(
                        address: address,
                        byteCount: byteCount,
                        fileOffset:
                            fileOffset,
                        protection:
                            protection,
                        deviceID: deviceID,
                        inode: inode
                    ),
                mappedVnodePath:
                    mappedVnodePath
            )
    }

    private func exactMatchedMappedRegionResult()
        -> PrimeNativeNeuralGateSecureExternalChildCapture.MappedRegionQueryResult
    {
        mappedRegionResult(
            address: 0x1_000,
            byteCount: 0x1_000,
            fileOffset: 0,
            protection:
                UInt32(
                    VM_PROT_READ
                    | VM_PROT_EXECUTE
                ),
            deviceID: 7,
            inode: 11,
            mappedVnodePath:
                Self
                .swiftPackageExecutableAbsolutePath
        )
    }

    private func terminalMappedRegionResult(
        queryErrno: Int32
    )
        -> PrimeNativeNeuralGateSecureExternalChildCapture.MappedRegionQueryResult
    {
        PrimeNativeNeuralGateSecureExternalChildCapture
            .MappedRegionQueryResult(
                returnedByteCount: 0,
                queryErrno: queryErrno,
                region: nil,
                mappedVnodePath: nil
            )
    }

    private func assertMappedRegionEnumerationRejects(
        _ scriptedResults:
            [PrimeNativeNeuralGateSecureExternalChildCapture.MappedRegionQueryResult],
        expectedDetail: String,
        expectedQueryAddresses:
            [UInt64],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var results =
            scriptedResults
        var observedQueryAddresses:
            [UInt64] = []
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateSecureExternalChildCapture
                .evaluateMappedRegionTranscript(
                    executableSnapshot:
                        mappedExecutableSnapshot(),
                    contract: .frozenV6,
                    queryLimit: 8
                ) {
                    queryAddress in
                    observedQueryAddresses
                        .append(queryAddress)
                    return results.removeFirst()
                },
            file: file,
            line: line
        ) {
            error in
            XCTAssertEqual(
                error
                    as? PrimeNativeNeuralGateSecureExternalChildCaptureError,
                .rejected(expectedDetail),
                file: file,
                line: line
            )
        }
        XCTAssertEqual(
            observedQueryAddresses,
            expectedQueryAddresses,
            file: file,
            line: line
        )
    }

    private func publicCaptureSignature(
        in source: String
    ) throws -> String {
        let marker =
            "public static func capture("
        guard let start =
                source.range(of: marker),
              let openingBrace =
                source[
                    start.lowerBound...
                ].firstIndex(of: "{")
        else {
            throw TestFailure.missing(
                "public capture signature"
            )
        }
        return String(
            source[
                start.lowerBound
                    ..< openingBrace
            ]
        )
    }

    private func assertAppearsInOrder(
        _ fragments: [String],
        in source: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var cursor = source.startIndex
        for fragment in fragments {
            guard let range =
                    source.range(
                        of: fragment,
                        range: cursor
                            ..< source.endIndex
                    )
            else {
                return XCTFail(
                    "missing or out-of-order source fragment: \(fragment)",
                    file: file,
                    line: line
                )
            }
            cursor = range.upperBound
        }
    }

    private func occurrences(
        of needle: String,
        in haystack: String
    ) -> Int {
        guard !needle.isEmpty else {
            return 0
        }
        var count = 0
        var cursor = haystack.startIndex
        while let range = haystack.range(
            of: needle,
            range: cursor ..< haystack.endIndex
        ) {
            count += 1
            cursor = range.upperBound
        }
        return count
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

    private enum TestFailure: Error {
        case missing(String)
    }
}
