import Darwin
import Dispatch
import Foundation
import XCTest
@testable import PrimeCore

final class PrimeNativeNeuralGateSecureExternalChildCaptureTests:
    XCTestCase
{
    private static let failStopRoleEnvironmentKey =
        "PRIME_SECURE_CHILD_FAIL_STOP_TEST_ROLE"
    private static let failStopReportDescriptorEnvironmentKey =
        "PRIME_SECURE_CHILD_FAIL_STOP_REPORT_DESCRIPTOR"
    private static let failStopReportDescriptor: Int32 = 198
    private static let failStopTestSelector =
        "PrimeNativeNeuralGateSecureExternalChildCaptureTests/" +
        "testAbandonedLiveChildObligationFailStopsAfterContainment"
    private static let authorityRelativePath =
        "Sources/PrimeCore/" +
        "PrimeNativeNeuralGateSecureExternalChildCapture.swift"
    private static let lifecycleRelativePath =
        "Sources/PrimeCore/" +
        "PrimeSecureChildLifecycle.swift"
    private static let scratchRelativePath =
        "Sources/PrimeCore/" +
        "PrimeNativeNeuralGateSecureScratchNamespace.swift"
    private static let darwinSubstrateRelativePath =
        "Sources/PrimeCore/" +
        "PrimeSecureChildDarwinSubstrate.swift"
    private static let processProofRelativePath =
        "Sources/PrimeCore/" +
        "PrimeSecureChildDarwinProcessProof.swift"
    private static let deadlineRelativePath =
        "Sources/PrimeCore/" +
        "PrimeSecureChildDeadline.swift"
    private static let drainsRelativePath =
        "Sources/PrimeCore/" +
        "PrimeSecureChildDrains.swift"
    private static let supervisionRelativePath =
        "Sources/PrimeCore/" +
        "PrimeSecureChildSupervision.swift"
    private static let processPlanRelativePath =
        "Sources/PrimeCore/" +
        "PrimeSecureChildProcessPlan.swift"
    private static let trustedCaptureRelativePath =
        "Sources/PrimeCore/" +
        "PrimeTrustedSecureChildProcessCapture.swift"
    private static let executionKernelRelativePath =
        "Sources/PrimeCore/" +
        "PrimeSecureChildExecutionKernel.swift"
    private static let fixtureKernelRelativePath =
        "Sources/PrimeCore/" +
        "PrimeSecureChildKernel.swift"
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
        let root = try packageRoot()
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
        let darwinSubstrateSource = try String(
            contentsOfFile:
                root.appendingPathComponent(
                    Self.darwinSubstrateRelativePath
                ).path,
            encoding: .utf8
        )
        let processProofSource = try String(
            contentsOfFile:
                root.appendingPathComponent(
                    Self.processProofRelativePath
                ).path,
            encoding: .utf8
        )
        let deadlineSource = try String(
            contentsOfFile:
                root.appendingPathComponent(
                    Self.deadlineRelativePath
                ).path,
            encoding: .utf8
        )
        let drainsSource = try String(
            contentsOfFile:
                root.appendingPathComponent(
                    Self.drainsRelativePath
                ).path,
            encoding: .utf8
        )
        let supervisionSource = try String(
            contentsOfFile:
                root.appendingPathComponent(
                    Self.supervisionRelativePath
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
            + "\n"
            + darwinSubstrateSource
            + "\n"
            + processProofSource
            + "\n"
            + deadlineSource
            + "\n"
            + drainsSource
            + "\n"
            + supervisionSource

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
        XCTAssertFalse(
            processProofSource.contains("public ")
        )
        XCTAssertFalse(
            deadlineSource.contains("public ")
        )
        XCTAssertFalse(
            supervisionSource.contains("public ")
        )
        for forbiddenSchemaMechanic in [
            "Codable",
            "CodingKeys",
            "schemaVersion",
        ] {
            XCTAssertFalse(
                supervisionSource.contains(
                    forbiddenSchemaMechanic
                )
            )
        }
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
            darwinSubstrateSource.contains(
                "posix_spawn("
            )
        )
        XCTAssertFalse(source.contains("posix_spawn("))
        XCTAssertTrue(
            source.contains(
                "PrimeSecureChildDarwinSubstrate.swift"
            ),
            "the neutral spawn substrate must remain inside the held source closure"
        )
        XCTAssertTrue(
            source.contains(
                "PrimeSecureChildDarwinProcessProof.swift"
            )
        )
        XCTAssertTrue(
            source.contains(
                "PrimeSecureChildDeadline.swift"
            )
        )
        XCTAssertTrue(
            source.contains(
                "PrimeSecureChildSupervision.swift"
            )
        )
        XCTAssertTrue(
            processProofSource.contains(
                "captureSuspendedWorkingDirectory("
            )
        )
        XCTAssertTrue(
            processProofSource.contains(
                "captureMappedExecutable("
            )
        )
        XCTAssertFalse(
            source.contains(
                "UInt64.max :"
            ),
            "the phase deadline must not saturate overflow"
        )
        XCTAssertFalse(
            package.contains(
                "PrimeNativeNeuralGateSecureExternalChildCapture"
            ),
            "the capture slice added a helper target or product"
        )
        XCTAssertFalse(
            package.contains(
                "PrimeSecureChildSupervision"
            )
        )

        assertAppearsInOrder(
            [
                "let preSourceSnapshot =",
                "let preManifest =",
                "let heldSourceClosure =",
                "let scratch =",
                "let scratchLaunch =",
                "let executable =",
                "let phaseDeadline =",
                "let preSpawnRead =",
                "wall_deadline_before_spawn",
                "let supervision:",
                "let spawn = try spawnSuspendedSecureChild(",
                ".adoptMemory(",
                ".establishIsolatedSessionAndDedicatedGroup()",
                "let childSessionAndProcessGroupObservedMonotonicNanoseconds =",
                "let workingDirectoryObservation =",
                "let mappedTranscript =",
                "let preResumeRead =",
                ".validateBeforeResume()",
                "let scratchPreResumeValidationMonotonicNanoseconds =",
                "wall_deadline_before_resume",
                "resumeDisposition =",
                "try supervision.resume(",
                "switch resumeDisposition",
                "try supervision.observeDeath()",
                ".waitForPhaseDrainCompletion(",
                ".reapAfterObservedDeath()",
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
            in: darwinSubstrateSource
        )
        for requiredCleanup in [
            ".cleanupRejectedCapture()",
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
            "boundedNonblockingReap(",
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
        XCTAssertEqual(
            occurrences(
                of: "requestStop()",
                in: supervisionSource
            ),
            4
        )
        XCTAssertEqual(
            occurrences(
                of: "cleanupTimeline()",
                in: supervisionSource
            ),
            1
        )
        assertAppearsInOrder(
            [
                "func resume(",
                ".authorizesNewWork(",
                "return .deadlineExpired",
                "SIGCONT",
                "return .signalFailed(errno)",
                "lifecycle.markResumed()",
                "return .stateRejected",
                ".authorizesNewWork(",
                "return .resumed(",
            ],
            in: supervisionSource
        )
        assertAppearsInOrder(
            [
                "timeline = try lifecycle",
                ".cleanupRejectedCapture(",
                "case let .memory(",
                ".containmentDeadline",
                "standardOutput.requestStop()",
                "standardError.requestStop()",
                ".drainDeadline",
                "case let .fileBacked(",
                ".drainDeadline",
            ],
            in: supervisionSource
        )

        try assertSecureChildKernelFacadeRemainsClosedAndSwiftNative()
        try assertSecureChildFileBackedBoundedDrainPersistsPrefixAndDrainsThroughEOF()
        try assertSecureChildCaptureBindingRejectsSameNameReplacement()
        try assertSecureChildFixtureResultBindingRejectsSameNameReplacement()
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
            try packageRoot()
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
        // August 3's 63_214/9901... tuple remains named in the helper below.
        // This separate current-package profile binds all bytes after exactly
        // three schema-specific root substitutions. Each original path must
        // equal this capture's descriptor-proven sourceRoot (plus fixed suffix).
        try PrimeCurrentPackageDescribeCanaryFixture.validate(
            probe.standardOutputData, sourceRoot: sourceRoot.path)
        try PrimeCurrentPackageDescribeCanaryFixture.validate(
            verifier.standardOutputData, sourceRoot: sourceRoot.path)

        let actual = probe.standardOutputData
        XCTAssertThrowsError(try PrimeCurrentPackageDescribeCanaryFixture.validate(
            actual, sourceRoot: sourceRoot.path + "-wrong"))
        for suffix in [Data([0x0a]), Data("diagnostic\n".utf8), Data([0x20])] {
            XCTAssertThrowsError(try PrimeCurrentPackageDescribeCanaryFixture.validate(
                actual + suffix, sourceRoot: sourceRoot.path))
        }
        // Same-length byte edits preserve formatting and every path offset.
        // Requiring normalization to succeed proves these reach the full-output
        // digest check instead of failing only at an earlier offset/schema check.
        func replacingOnce(_ needle: String, with replacement: String) throws -> Data {
            let before = Data(needle.utf8)
            let after = Data(replacement.utf8)
            XCTAssertEqual(before.count, after.count)
            let range = try XCTUnwrap(actual.range(of: before))
            XCTAssertNil(actual.range(of: before, options: [], in: range.upperBound ..< actual.count))
            var changed = actual
            changed.replaceSubrange(range, with: after)
            XCTAssertEqual(changed.count, actual.count)
            return changed
        }
        for changed in [
            try replacingOnce("  \"name\" : \"ErgenticsPrime\",", with: "  \"name\" : \"ErgenticsPrimx\","),
            try replacingOnce("\"PrimeDurableArtifacts.swift\"", with: "\"PrimeDurableArtifactx.swift\""),
            try replacingOnce("d37885a278f1c37484a94d0f401a418735e66519", with: "e37885a278f1c37484a94d0f401a418735e66519"),
        ] {
            let normalized = try PrimeCurrentPackageDescribeCanaryFixture.normalize(changed, sourceRoot: sourceRoot.path)
            XCTAssertEqual(normalized.count, PrimeCurrentPackageDescribeCanaryFixture.normalizedByteCount)
            XCTAssertNotEqual(PrimeSHA256.hexDigest(of: normalized), PrimeCurrentPackageDescribeCanaryFixture.normalizedSHA256)
            XCTAssertThrowsError(try PrimeCurrentPackageDescribeCanaryFixture.validate(changed, sourceRoot: sourceRoot.path)) { error in
                guard let rejection = error as? PrimeCurrentPackageDescribeCanaryFixture.Rejection,
                      case .digest = rejection else {
                    return XCTFail("content mutation did not reach the digest check: \(error)")
                }
            }
        }
        let damagedResource = try replacingOnce("/HistoricalFixtureEvidence\"", with: "/HistoricalFixtureEvidencx\"")
        XCTAssertThrowsError(try PrimeCurrentPackageDescribeCanaryFixture.validate(damagedResource, sourceRoot: sourceRoot.path))
        let missingRootField = try replacingOnce("\n  \"path\" : \"", with: "\n  \"pazh\" : \"")
        XCTAssertThrowsError(try PrimeCurrentPackageDescribeCanaryFixture.validate(missingRootField, sourceRoot: sourceRoot.path))
        for wrongOffset in [-1, 385, Int.max] {
            XCTAssertThrowsError(try PrimeCurrentPackageDescribeCanaryFixture.replacePathToken(actual,
                valueOffset: wrongOffset, actualValue: sourceRoot.path,
                replacementValue: PrimeCurrentPackageDescribeCanaryFixture.placeholder))
        }
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

    private func assertSecureChildFileBackedBoundedDrainPersistsPrefixAndDrainsThroughEOF()
        throws
    {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-secure-child-drain-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700]
        )
        defer { try? FileManager.default.removeItem(at: directory) }

        let outputURL = directory.appendingPathComponent("prefix.bin")
        let output = Darwin.open(
            outputURL.path,
            O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC,
            mode_t(0o600)
        )
        XCTAssertGreaterThanOrEqual(output, 0)
        var pipeDescriptors: [Int32] = [-1, -1]
        XCTAssertEqual(pipe(&pipeDescriptors), 0)
        let readFlags = fcntl(pipeDescriptors[0], F_GETFL)
        XCTAssertGreaterThanOrEqual(readFlags, 0)
        XCTAssertEqual(
            fcntl(
                pipeDescriptors[0],
                F_SETFL,
                readFlags | O_NONBLOCK
            ),
            0
        )

        let drain = PrimeSecureChildFileBackedBoundedDrain(
            inputDescriptor: pipeDescriptors[0],
            outputDescriptor: output,
            maximumByteCount: 32
        )
        let group = DispatchGroup()
        drain.start(group: group)

        let bytes = [UInt8](0 ..< 128)
        try writeSecureChildBytes(
            bytes,
            descriptor: pipeDescriptors[1]
        )
        XCTAssertEqual(Darwin.close(pipeDescriptors[1]), 0)
        XCTAssertEqual(
            group.wait(timeout: .now() + .seconds(3)),
            .success
        )

        let snapshot = drain.snapshot()
        XCTAssertEqual(snapshot.totalByteCount, 128)
        XCTAssertEqual(snapshot.capturedByteCount, 32)
        XCTAssertTrue(snapshot.overflowed)
        XCTAssertTrue(snapshot.workerFinished)
        XCTAssertEqual(
            snapshot.terminalReason,
            .endOfFile
        )
        XCTAssertTrue(snapshot.descriptorsClosed)
        XCTAssertTrue(snapshot.reachedEOF)
        XCTAssertEqual(snapshot.readErrorNumber, 0)
        XCTAssertEqual(snapshot.writeErrorNumber, 0)
        XCTAssertEqual(snapshot.finalizationErrorNumber, 0)
        XCTAssertEqual(snapshot.closeErrorNumber, 0)
        XCTAssertTrue(snapshot.outputMetadataObserved)
        XCTAssertGreaterThan(snapshot.outputDeviceID, 0)
        XCTAssertGreaterThan(snapshot.outputInode, 0)
        XCTAssertEqual(snapshot.outputByteCount, 32)
        XCTAssertEqual(snapshot.outputPermissionMode, 0o444)
        XCTAssertEqual(
            snapshot.outputSHA256,
            PrimeSHA256.hexDigest(of: Data(bytes.prefix(32)))
        )
        XCTAssertEqual(
            try Data(contentsOf: outputURL),
            Data(bytes.prefix(32))
        )
        let attributes = try FileManager.default.attributesOfItem(
            atPath: outputURL.path
        )
        XCTAssertEqual(
            (attributes[.posixPermissions] as? NSNumber)?.intValue,
            0o444
        )
    }

    private func assertSecureChildCaptureBindingRejectsSameNameReplacement()
        throws
    {
        let created = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-secure-child-replacement-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: created,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700]
        )
        var canonicalBuffer = [CChar](
            repeating: 0,
            count: Int(PATH_MAX)
        )
        XCTAssertNotNil(
            created.path.withCString { input in
                canonicalBuffer.withUnsafeMutableBufferPointer {
                    realpath(input, $0.baseAddress)
                }
            }
        )
        let directory = URL(
            fileURLWithPath: String(cString: canonicalBuffer),
            isDirectory: true
        )
        XCTAssertEqual(chmod(directory.path, mode_t(0o700)), 0)
        defer { try? FileManager.default.removeItem(at: directory) }

        let held = try PrimeSecureChildHeldDirectory(
            url: directory,
            label: "replacement_test",
            permitsControlledEntryMutations: true
        )
        let leaf = "captured.bin"
        let output = try held.createEmptyCaptureFile(leaf: leaf)
        var pipeDescriptors: [Int32] = [-1, -1]
        XCTAssertEqual(pipe(&pipeDescriptors), 0)
        let drain = PrimeSecureChildFileBackedBoundedDrain(
            inputDescriptor: pipeDescriptors[0],
            outputDescriptor: output,
            maximumByteCount: 32
        )
        let group = DispatchGroup()
        drain.start(group: group)
        let bytes = [UInt8](0 ..< 64)
        try writeSecureChildBytes(
            bytes,
            descriptor: pipeDescriptors[1]
        )
        XCTAssertEqual(Darwin.close(pipeDescriptors[1]), 0)
        XCTAssertEqual(
            group.wait(timeout: .now() + .seconds(3)),
            .success
        )
        let snapshot = drain.snapshot()
        try held.requireImmutableCapture(
            leaf: leaf,
            snapshot: snapshot
        )

        let path = directory.appendingPathComponent(leaf).path
        XCTAssertEqual(Darwin.unlink(path), 0)
        let replacement = Darwin.open(
            path,
            O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            mode_t(0o600)
        )
        XCTAssertGreaterThanOrEqual(replacement, 0)
        try writeSecureChildBytes(
            Array(bytes.prefix(32)),
            descriptor: replacement
        )
        XCTAssertEqual(fchmod(replacement, mode_t(0o444)), 0)
        XCTAssertEqual(fsync(replacement), 0)
        XCTAssertEqual(fcntl(replacement, F_FULLFSYNC), 0)
        XCTAssertEqual(Darwin.close(replacement), 0)

        XCTAssertThrowsError(
            try held.requireImmutableCapture(
                leaf: leaf,
                snapshot: snapshot
            )
        )
    }

    private func assertSecureChildFixtureResultBindingRejectsSameNameReplacement()
        throws
    {
        let directory = try makeCanonicalPrivateSecureChildDirectory(
            prefix: "prime-secure-child-result-replacement"
        )
        defer { try? FileManager.default.removeItem(at: directory) }
        let held = try PrimeSecureChildHeldDirectory(
            url: directory,
            label: "result_replacement_test",
            permitsControlledEntryMutations: true
        )
        let resultPath = directory.appendingPathComponent(
            PrimeSecureChildFixtureInvocation.resultLeaf
        ).path
        let plan = try PrimeSecureChildProcessPlanV1
            .validationWorkflowFixture(mode: .pass)
        let invocation = try PrimeSecureChildFixtureInvocation(
            plan: plan,
            resultAbsolutePath: resultPath
        )
        let expected = try XCTUnwrap(invocation.expectedResultData)
        let original = Darwin.open(
            resultPath,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            mode_t(0o600)
        )
        XCTAssertGreaterThanOrEqual(original, 0)
        try writeSecureChildBytes(Array(expected), descriptor: original)
        XCTAssertEqual(fsync(original), 0)
        XCTAssertEqual(fcntl(original, F_FULLFSYNC), 0)
        XCTAssertEqual(Darwin.close(original), 0)
        try held.admitExpectedFixtureResult(expectsResult: true)

        XCTAssertEqual(Darwin.unlink(resultPath), 0)
        let replacement = Darwin.open(
            resultPath,
            O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            mode_t(0o600)
        )
        XCTAssertGreaterThanOrEqual(replacement, 0)
        try writeSecureChildBytes(Array(expected), descriptor: replacement)
        XCTAssertEqual(fsync(replacement), 0)
        XCTAssertEqual(fcntl(replacement, F_FULLFSYNC), 0)
        XCTAssertEqual(Darwin.close(replacement), 0)

        XCTAssertThrowsError(
            try held.readAndFreezeFixtureResult(
                invocation: invocation
            )
        )
    }

    private func assertSecureChildKernelFacadeRemainsClosedAndSwiftNative()
        throws
    {
        let root = try packageRoot()
        let source = try String(
            contentsOf: root.appendingPathComponent(
                Self.fixtureKernelRelativePath
            ),
            encoding: .utf8
        )
        let planSource = try String(
            contentsOf: root.appendingPathComponent(
                Self.processPlanRelativePath
            ),
            encoding: .utf8
        )
        let trustedCaptureSource = try String(
            contentsOf: root.appendingPathComponent(
                Self.trustedCaptureRelativePath
            ),
            encoding: .utf8
        )
        let executionKernelSource = try String(
            contentsOf: root.appendingPathComponent(
                Self.executionKernelRelativePath
            ),
            encoding: .utf8
        )
        let executionTopologySource =
            executionKernelSource + "\n" + source
        let spawnAdapterSource = try String(
            contentsOf: root.appendingPathComponent(
                "Sources/PrimeCore/PrimeNativeNeuralGateSecureExternalChildCapture.swift"
            ),
            encoding: .utf8
        )
        let darwinSubstrateSource = try String(
            contentsOf: root.appendingPathComponent(
                Self.darwinSubstrateRelativePath
            ),
            encoding: .utf8
        )
        let processProofSource = try String(
            contentsOf: root.appendingPathComponent(
                Self.processProofRelativePath
            ),
            encoding: .utf8
        )

        XCTAssertEqual(
            PrimeValidationWorkflowFixtureChildMode.allCases.count,
            9
        )
        try assertAllFixtureModesMapThroughClosedProcessPlan()
        XCTAssertNoThrow(
            try PrimeSecureChildDarwinSubstrate
                .requireArgumentZero("swift-build")
        )
        XCTAssertNoThrow(
            try PrimeNativeNeuralGateSecureExternalChildCapture
                .requireSecureChildArgumentZero("swift-build")
        )
        XCTAssertNoThrow(
            try PrimeSecureChildDarwinSubstrate
                .requireArgumentZero(
                    "/private/tmp/Prime Builds/Fixture-π"
                )
        )
        for rejectedArgumentZero in [
            "",
            "swift\0build",
            String(repeating: "a", count: 4_097),
        ] {
            XCTAssertThrowsError(
                try PrimeSecureChildDarwinSubstrate
                    .requireArgumentZero(
                        rejectedArgumentZero
                    )
            )
            XCTAssertThrowsError(
                try PrimeNativeNeuralGateSecureExternalChildCapture
                    .requireSecureChildArgumentZero(
                        rejectedArgumentZero
                    )
            )
        }
        XCTAssertEqual(
            PrimeSecureChildFixtureBinaryPin.byteCount,
            89_632
        )
        XCTAssertEqual(
            PrimeSecureChildFixtureBinaryPin.sha256,
            "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd"
        )
        XCTAssertTrue(
            source.contains(
                "private init(\n        prepared: PrimeSecureChildPreparedFixture,"
            )
        )
        let compactFixtureKernel = withoutWhitespace(source)
        XCTAssertTrue(
            compactFixtureKernel.contains(
                "publicstaticfuncprepare(executableURL:URL,privateWorkingDirectoryURL:URL,privateResultDirectoryURL:URL,mode:PrimeValidationWorkflowFixtureChildMode)throws->Self"
            )
        )
        XCTAssertTrue(
            compactFixtureKernel.contains(
                "publicfuncexecute()throws->PrimeValidationWorkflowFixtureChildResult"
            )
        )
        XCTAssertEqual(
            occurrences(
                of: "public static func prepare(",
                in: source
            ),
            1
        )
        XCTAssertEqual(
            occurrences(
                of: "public func execute() throws",
                in: source
            ),
            1
        )
        XCTAssertFalse(source.contains("public init("))
        XCTAssertFalse(source.contains("Foundation.Process"))
        XCTAssertFalse(source.contains("/bin/sh"))
        XCTAssertFalse(source.lowercased().contains("python"))
        XCTAssertFalse(darwinSubstrateSource.contains("public "))
        XCTAssertTrue(
            darwinSubstrateSource.contains(
                "final class PrimeSecureChildSpawnHandle"
            )
        )
        XCTAssertFalse(
            darwinSubstrateSource.contains(
                "struct PrimeSecureChildSpawnHandle"
            )
        )
        XCTAssertTrue(
            darwinSubstrateSource.contains(
                "func takeStreamReadDescriptors()"
            )
        )
        XCTAssertTrue(
            darwinSubstrateSource.contains(
                "final class PrimeSecureChildStreamReadDescriptorOwner"
            )
        )
        XCTAssertTrue(darwinSubstrateSource.contains("private let lock = NSLock()"))
        XCTAssertTrue(darwinSubstrateSource.contains("func takeIfAvailable()"))
        XCTAssertTrue(darwinSubstrateSource.contains("deinit {"))
        XCTAssertTrue(darwinSubstrateSource.contains("POSIX_SPAWN"))
        XCTAssertTrue(
            spawnAdapterSource.contains(
                "PrimeSecureChildDarwinSubstrate\n                .spawnSuspended("
            )
        )
        XCTAssertTrue(
            source.contains(
                "PrimeSecureChildDarwinSubstrate\n                .spawnSuspended("
            )
        )
        XCTAssertFalse(
            executionKernelSource.contains(
                "PrimeSecureChildDarwinSubstrate"
            )
        )
        XCTAssertFalse(
            executionKernelSource.contains("Darwin.")
        )
        XCTAssertFalse(
            executionKernelSource.contains("public ")
        )
        XCTAssertTrue(
            executionKernelSource.contains("struct RawOutcome")
        )
        XCTAssertTrue(
            executionKernelSource.contains(
                "private let executionClaim:"
            )
        )
        XCTAssertFalse(
            source.contains(
                "struct PrimeSecureChildFixtureKernelResult"
            )
        )
        XCTAssertTrue(
            source.contains(
                "PrimeSecureChildDiagnosticProjection"
            )
        )
        XCTAssertTrue(
            executionKernelSource.contains(
                "let diagnosticCanonicalData: Data"
            )
        )
        XCTAssertTrue(
            source.contains(
                "operationalFailureCode:\n                    \"stream_capture\""
            )
        )
        XCTAssertFalse(
            planSource.contains("public ")
        )
        XCTAssertFalse(
            trustedCaptureSource.contains("public ")
        )
        for forbiddenExecutionSurface in [
            "Foundation.Process",
            "NSTask",
            "posix_spawn",
            "execve(",
            "execl(",
            "system(",
            "popen(",
            "/bin/sh",
            "/bin/zsh",
            "/bin/bash",
            "python",
        ] {
            XCTAssertFalse(
                executionKernelSource
                    .localizedCaseInsensitiveContains(
                        forbiddenExecutionSurface
                    )
            )
        }
        XCTAssertTrue(
            spawnAdapterSource.contains(
                ".adoptMemory("
            )
        )
        XCTAssertTrue(
            source.contains(
                ".adoptFileBacked("
            )
        )
        XCTAssertFalse(
            spawnAdapterSource.contains(
                "let stdoutDrain ="
            )
        )
        XCTAssertFalse(
            source.contains(
                "let stdoutDrain ="
            )
        )
        XCTAssertTrue(
            darwinSubstrateSource.contains(
                "[argumentZero] + exactArguments"
            )
        )
        XCTAssertFalse(
            darwinSubstrateSource.contains(
                "[exactExecutableAbsolutePath]\n            + exactArguments"
            )
        )
        XCTAssertTrue(
            darwinSubstrateSource.contains(
                "posix_spawn(\n                            &childPID,\n                            exactExecutableAbsolutePath,"
            )
        )
        XCTAssertTrue(
            source.contains(
                "case swiftBuildCanary"
            )
        )
        XCTAssertTrue(
            source.contains(
                "static let swiftBuildCanaryValue =\n        \"swift-build\""
            )
        )
        XCTAssertFalse(
            source.contains(
                "public enum PrimeSecureChildArgumentZeroPolicy"
            )
        )
        XCTAssertTrue(source.contains("O_NOFOLLOW_ANY"))
        XCTAssertTrue(source.contains("static let expectedByteCount"))
        XCTAssertTrue(source.contains("static let expectedSHA256"))
        XCTAssertTrue(source.contains("digest == expectedSHA256"))
        XCTAssertTrue(
            source.contains("fixture_binary_pin_unconfigured_abstain")
        )
        XCTAssertTrue(
            source.contains("mappedExecutableJoin(")
        )
        XCTAssertTrue(
            processProofSource.contains(
                "captureMappedExecutable("
            )
        )
        XCTAssertTrue(
            source.contains("cleanupRejectedCapture(")
        )
        XCTAssertTrue(source.contains("exactPIDWaitObservation"))
        XCTAssertTrue(
            processProofSource.contains(
                "PrimeSecureChildPath.canonicalPath(path)"
            )
        )
        XCTAssertFalse(
            processProofSource.contains(
                "standardizedFileURL"
            )
        )

        assertAppearsInOrder(
            [
                "let plan = try PrimeSecureChildProcessPlanV1",
                "let prepared =",
                "PrimeTrustedSecureChildProcessCapture(",
                "consumption = try capture.consume()",
                "PrimeSecureChildExecutionKernel",
                ".fixtureResult",
            ],
            in: source
        )
        assertAppearsInOrder(
            [
                "claim = try consumption.claimForExecution()",
                "claim.retainsClosedContext(prepared)",
                "claim.plan",
                ".validationWorkflowFixtureMode",
                "PrimeSecureChildKernel",
                ".execute(",
                "claim: claim",
            ],
            in: executionTopologySource
        )
        XCTAssertEqual(
            occurrences(
                of: "PrimeSecureChildKernel\n            .execute(",
                in: source
            ),
            1
        )
        XCTAssertEqual(
            occurrences(
                of: "claimForExecution()",
                in: executionTopologySource
            ),
            1
        )
        XCTAssertFalse(
            executionTopologySource.contains("consumption.plan")
        )
        XCTAssertTrue(
            source.contains("private enum PrimeSecureChildKernel")
        )
        XCTAssertTrue(
            source.contains(
                "let plan = claim.plan"
            )
        )
        XCTAssertFalse(
            executionTopologySource.contains("plan: claim.plan")
        )

        try assertSpawnHandleTransfersOrClosesBothDescriptors()
    }

    private func assertAllFixtureModesMapThroughClosedProcessPlan()
        throws
    {
        let resultPath =
            "/private/tmp/prime-secure-child-pure-mapping/"
            + PrimeSecureChildFixtureInvocation.resultLeaf
        let physicalExecutable =
            "/private/tmp/PrimeValidationWorkflowFixtureChild"
        for mode in PrimeValidationWorkflowFixtureChildMode.allCases {
            let expectedFixtureValues:
                (stdout: Int, stderr: Int, exit: Int32, result: Bool)
            switch mode {
            case .pass, .logicalArgumentZero:
                expectedFixtureValues = (0, 0, 0, true)
            case .nonzeroExit:
                expectedFixtureValues = (0, 0, 23, true)
            case .boundedStreams:
                expectedFixtureValues = (4_096, 2_048, 0, true)
            case .overflow:
                expectedFixtureValues = (131_072, 131_072, 0, true)
            case .hang, .selfSignal, .descendantRetainsStreams:
                expectedFixtureValues = (0, 0, 0, true)
            case .exitWithoutResult:
                expectedFixtureValues = (0, 0, 0, false)
            }
            var expectedArguments = ["--mode", mode.rawValue]
            if expectedFixtureValues.result {
                expectedArguments += [
                    "--result-path",
                    resultPath,
                ]
            }
            if mode == .nonzeroExit {
                expectedArguments += ["--exit-code", "23"]
            }
            if mode == .boundedStreams || mode == .overflow {
                expectedArguments += [
                    "--stdout-bytes",
                    String(expectedFixtureValues.stdout),
                    "--stderr-bytes",
                    String(expectedFixtureValues.stderr),
                ]
            }
            let plan = try PrimeSecureChildProcessPlanV1
                .validationWorkflowFixture(
                    mode: mode
                )
            let invocation = try PrimeSecureChildFixtureInvocation(
                plan: plan,
                resultAbsolutePath: resultPath
            )
            XCTAssertEqual(
                plan.validationWorkflowFixtureMode,
                mode
            )
            XCTAssertEqual(invocation.mode, mode)
            XCTAssertEqual(
                invocation.configuredPayloadStandardOutputBytes,
                expectedFixtureValues.stdout
            )
            XCTAssertEqual(
                invocation.configuredPayloadStandardErrorBytes,
                expectedFixtureValues.stderr
            )
            XCTAssertEqual(
                invocation.configuredExitCode,
                expectedFixtureValues.exit
            )
            XCTAssertEqual(
                invocation.expectsResult,
                expectedFixtureValues.result
            )
            XCTAssertEqual(
                invocation.maximumWallNanoseconds,
                mode == .hang
                    || mode == .descendantRetainsStreams
                    ? 1_000_000_000
                    : 10_000_000_000
            )
            XCTAssertEqual(
                plan.standardOutputMaximumByteCount,
                PrimeSecureChildFixtureInvocation
                    .streamPrefixLimit
            )
            XCTAssertEqual(
                plan.standardErrorMaximumByteCount,
                PrimeSecureChildFixtureInvocation
                    .streamPrefixLimit
            )
            XCTAssertTrue(plan.orderedEnvironment.isEmpty)
            XCTAssertEqual(
                try plan.argumentZero(
                    physicalExecutableAbsolutePath:
                        physicalExecutable
                ),
                mode == .logicalArgumentZero
                    ? PrimeSecureChildArgumentZeroPolicy
                        .swiftBuildCanaryValue
                    : physicalExecutable
            )
            XCTAssertEqual(
                try plan.exactArguments(
                    resultAbsolutePath:
                        expectedFixtureValues.result
                        ? resultPath
                        : ""
                ),
                expectedArguments
            )
            XCTAssertEqual(invocation.arguments, expectedArguments)
        }
    }

    private func assertSpawnHandleTransfersOrClosesBothDescriptors()
        throws
    {
        func makePipe() throws -> (read: Int32, write: Int32) {
            var descriptors = [Int32](repeating: -1, count: 2)
            guard Darwin.pipe(&descriptors) == 0 else {
                throw POSIXError(
                    POSIXErrorCode(rawValue: errno) ?? .EIO
                )
            }
            return (descriptors[0], descriptors[1])
        }

        let transferredOutput = try makePipe()
        let transferredError = try makePipe()
        XCTAssertEqual(Darwin.close(transferredOutput.write), 0)
        XCTAssertEqual(Darwin.close(transferredError.write), 0)
        let transferredOwner = PrimeSecureChildSpawnHandle(
            processIdentifier: 1,
            appliedFlags: 0x448c,
            spawnReturnCode: 0,
            spawnReturnedMonotonicNanoseconds: 1,
            standardOutputReadDescriptor: transferredOutput.read,
            standardErrorReadDescriptor: transferredError.read,
            ownsLiveChildObligation: false
        )
        let transferred = transferredOwner.takeStreamReadDescriptors()
        XCTAssertEqual(transferred.standardOutput, transferredOutput.read)
        XCTAssertEqual(transferred.standardError, transferredError.read)
        XCTAssertEqual(Darwin.close(transferred.standardOutput), 0)
        XCTAssertEqual(Darwin.close(transferred.standardError), 0)

        let abandonedOutput = try makePipe()
        let abandonedError = try makePipe()
        XCTAssertEqual(Darwin.close(abandonedOutput.write), 0)
        XCTAssertEqual(Darwin.close(abandonedError.write), 0)
        var abandonedOwner: PrimeSecureChildSpawnHandle? =
            PrimeSecureChildSpawnHandle(
                processIdentifier: 1,
                appliedFlags: 0x448c,
                spawnReturnCode: 0,
                spawnReturnedMonotonicNanoseconds: 1,
                standardOutputReadDescriptor: abandonedOutput.read,
                standardErrorReadDescriptor: abandonedError.read,
                ownsLiveChildObligation: false
            )
        XCTAssertNotNil(abandonedOwner)
        abandonedOwner = nil
        errno = 0
        XCTAssertEqual(fcntl(abandonedOutput.read, F_GETFD), -1)
        XCTAssertEqual(errno, EBADF)
        errno = 0
        XCTAssertEqual(fcntl(abandonedError.read, F_GETFD), -1)
        XCTAssertEqual(errno, EBADF)

        let concurrentOutput = try makePipe()
        let concurrentError = try makePipe()
        XCTAssertEqual(Darwin.close(concurrentOutput.write), 0)
        XCTAssertEqual(Darwin.close(concurrentError.write), 0)
        let concurrentOwner =
            PrimeSecureChildStreamReadDescriptorOwner(
                standardOutputReadDescriptor: concurrentOutput.read,
                standardErrorReadDescriptor: concurrentError.read
            )
        let resultLock = NSLock()
        var acquired:
            [(standardOutput: Int32, standardError: Int32)] = []
        var unavailableCount = 0
        DispatchQueue.concurrentPerform(iterations: 2) { _ in
            let candidate = concurrentOwner.takeIfAvailable()
            resultLock.lock()
            if let candidate {
                acquired.append(candidate)
            } else {
                unavailableCount += 1
            }
            resultLock.unlock()
        }
        XCTAssertEqual(acquired.count, 1)
        XCTAssertEqual(unavailableCount, 1)
        let concurrentDescriptors = try XCTUnwrap(acquired.first)
        XCTAssertEqual(
            concurrentDescriptors.standardOutput,
            concurrentOutput.read
        )
        XCTAssertEqual(
            concurrentDescriptors.standardError,
            concurrentError.read
        )
        XCTAssertEqual(
            Darwin.close(concurrentDescriptors.standardOutput),
            0
        )
        XCTAssertEqual(
            Darwin.close(concurrentDescriptors.standardError),
            0
        )
    }

    func testAbandonedLiveChildObligationFailStopsAfterContainment()
        throws
    {
        let environment =
            ProcessInfo.processInfo.environment
        if environment[
            Self.failStopRoleEnvironmentKey
        ] == "1" {
            guard environment[
                Self.failStopReportDescriptorEnvironmentKey
            ] == String(
                Self.failStopReportDescriptor
            ) else {
                Darwin._exit(71)
            }
            if #available(macOS 26.0, *) {
                try runFailStopRole()
            }
            Darwin._exit(72)
        }

        guard #available(macOS 26.0, *) else {
            throw XCTSkip(
                "secure-child Darwin substrate requires macOS 26"
            )
        }
        errno = 0
        XCTAssertEqual(
            fcntl(
                Self.failStopReportDescriptor,
                F_GETFD
            ),
            -1
        )
        XCTAssertEqual(errno, EBADF)

        var reportPipe = [Int32](repeating: -1, count: 2)
        guard Darwin.pipe(&reportPipe) == 0 else {
            throw currentPOSIXError()
        }
        var reportReadDescriptorOpen = true
        var reportWriteDescriptorOpen = true
        defer {
            if reportReadDescriptorOpen {
                _ = Darwin.close(reportPipe[0])
            }
            if reportWriteDescriptorOpen {
                _ = Darwin.close(reportPipe[1])
            }
        }

        let supervisorIdentifier = try spawnFailStopRole(
            reportReadDescriptor: reportPipe[0],
            reportWriteDescriptor: reportPipe[1]
        )
        XCTAssertGreaterThan(supervisorIdentifier, 0)
        _ = Darwin.close(reportPipe[1])
        reportWriteDescriptorOpen = false

        var supervisorWasReaped = false
        var childIdentifier: Int32 = -1
        defer {
            if !supervisorWasReaped {
                _ = Darwin.kill(
                    -supervisorIdentifier,
                    SIGKILL
                )
                _ = Darwin.kill(
                    supervisorIdentifier,
                    SIGKILL
                )
                _ = waitForExactProcessExit(
                    supervisorIdentifier,
                    timeoutNanoseconds:
                        2_000_000_000
                )
            }
            if childIdentifier > 0 {
                _ = Darwin.kill(
                    -childIdentifier,
                    SIGKILL
                )
                _ = Darwin.kill(
                    childIdentifier,
                    SIGKILL
                )
            }
        }

        childIdentifier = try XCTUnwrap(
            readReportedProcessIdentifier(
                from: reportPipe[0],
                timeoutNanoseconds:
                    10_000_000_000
            ),
            "fail-stop role did not report its suspended child"
        )
        _ = Darwin.close(reportPipe[0])
        reportReadDescriptorOpen = false
        XCTAssertGreaterThan(childIdentifier, 0)

        let supervisorStatus = try XCTUnwrap(
            waitForExactProcessExit(
                supervisorIdentifier,
                timeoutNanoseconds:
                    10_000_000_000
            ),
            "fail-stop role did not exit within its retained deadline"
        )
        supervisorWasReaped = true
        XCTAssertEqual(supervisorStatus & 0x7f, 0)
        XCTAssertEqual((supervisorStatus >> 8) & 0xff, 70)
        errno = 0
        XCTAssertEqual(Darwin.kill(childIdentifier, 0), -1)
        XCTAssertEqual(errno, ESRCH)
    }

    @available(macOS 26.0, *)
    private func runFailStopRole() throws {
        let rootDescriptor = Darwin.open(
            "/",
            O_RDONLY | O_DIRECTORY | O_CLOEXEC
        )
        guard rootDescriptor >= 0 else {
            throw currentPOSIXError()
        }
        defer {
            _ = Darwin.close(rootDescriptor)
        }

        var owner: PrimeSecureChildSpawnHandle? =
            try PrimeSecureChildDarwinSubstrate
            .spawnSuspended(
                executableAbsolutePath:
                    "/usr/bin/true",
                argumentZero:
                    "prime-secure-child-fail-stop",
                workingDirectoryDescriptor:
                    rootDescriptor,
                exactArguments: [],
                orderedEnvironment: [
                    ("PATH", "/usr/bin:/bin"),
                ]
            )
        var childIdentifier = try XCTUnwrap(owner)
            .processIdentifier
        let written = withUnsafeBytes(
            of: &childIdentifier
        ) {
            Darwin.write(
                Self.failStopReportDescriptor,
                $0.baseAddress,
                $0.count
            )
        }
        guard written == MemoryLayout<Int32>.size
        else {
            Darwin._exit(73)
        }
        _ = Darwin.close(
            Self.failStopReportDescriptor
        )

        withExtendedLifetime(owner) {}
        owner = nil
        Darwin._exit(74)
    }

    private func spawnFailStopRole(
        reportReadDescriptor: Int32,
        reportWriteDescriptor: Int32
    ) throws -> pid_t {
        var actions:
            posix_spawn_file_actions_t?
        var attributes:
            posix_spawnattr_t?
        try requireSpawnSuccess(
            posix_spawn_file_actions_init(
                &actions
            )
        )
        defer {
            _ = posix_spawn_file_actions_destroy(
                &actions
            )
        }
        try requireSpawnSuccess(
            posix_spawnattr_init(&attributes)
        )
        defer {
            _ = posix_spawnattr_destroy(
                &attributes
            )
        }
        try requireSpawnSuccess(
            posix_spawn_file_actions_addclose(
                &actions,
                reportReadDescriptor
            )
        )
        try requireSpawnSuccess(
            posix_spawn_file_actions_adddup2(
                &actions,
                reportWriteDescriptor,
                Self.failStopReportDescriptor
            )
        )
        try requireSpawnSuccess(
            posix_spawn_file_actions_addclose(
                &actions,
                reportWriteDescriptor
            )
        )
        let flags =
            UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
            | UInt16(POSIX_SPAWN_SETSID)
        try requireSpawnSuccess(
            posix_spawnattr_setflags(
                &attributes,
                Int16(bitPattern: flags)
            )
        )

        let executableAbsolutePath =
            CommandLine.arguments[0]
        guard executableAbsolutePath
                .hasSuffix("/xctest")
        else {
            throw POSIXError(.ENOEXEC)
        }
        let arguments = [
            executableAbsolutePath,
            "-XCTest",
            Self.failStopTestSelector,
            Bundle(
                for:
                    PrimeNativeNeuralGateSecureExternalChildCaptureTests
                    .self
            ).bundlePath,
        ]
        var environment =
            ProcessInfo.processInfo.environment
        environment[
            Self.failStopRoleEnvironmentKey
        ] = "1"
        environment[
            Self.failStopReportDescriptorEnvironmentKey
        ] = String(
            Self.failStopReportDescriptor
        )
        let environmentStrings =
            environment.keys.sorted().map {
                "\($0)=\(environment[$0]!)"
            }
        let duplicatedArguments =
            try duplicateCStringArray(arguments)
        defer {
            freeCStringArray(duplicatedArguments)
        }
        let duplicatedEnvironment =
            try duplicateCStringArray(
                environmentStrings
            )
        defer {
            freeCStringArray(duplicatedEnvironment)
        }
        var argv = duplicatedArguments.map {
            Optional($0)
        }
        argv.append(nil)
        var environmentPointers =
            duplicatedEnvironment.map {
                Optional($0)
            }
        environmentPointers.append(nil)

        var processIdentifier: pid_t = 0
        let returnCode =
            argv.withUnsafeMutableBufferPointer {
                argumentsBuffer in
                environmentPointers
                    .withUnsafeMutableBufferPointer {
                        environmentBuffer in
                        posix_spawn(
                            &processIdentifier,
                            executableAbsolutePath,
                            &actions,
                            &attributes,
                            argumentsBuffer.baseAddress,
                            environmentBuffer.baseAddress
                        )
                    }
            }
        try requireSpawnSuccess(returnCode)
        guard processIdentifier > 0 else {
            throw POSIXError(.ECHILD)
        }
        return processIdentifier
    }

    private func readReportedProcessIdentifier(
        from descriptor: Int32,
        timeoutNanoseconds: UInt64
    ) -> Int32? {
        guard let deadline = monotonicDeadline(
            after: timeoutNanoseconds
        ) else {
            return nil
        }
        var pollDescriptor = pollfd(
            fd: descriptor,
            events: Int16(POLLIN | POLLHUP),
            revents: 0
        )
        while true {
            guard let timeoutMilliseconds =
                    remainingPollMilliseconds(
                        until: deadline
                    )
            else {
                return nil
            }
            errno = 0
            let ready = Darwin.poll(
                &pollDescriptor,
                1,
                timeoutMilliseconds
            )
            if ready < 0, errno == EINTR {
                continue
            }
            guard ready == 1,
                  pollDescriptor.revents
                    & Int16(POLLIN | POLLHUP)
                    != 0
            else {
                return nil
            }
            var processIdentifier: Int32 = -1
            errno = 0
            let count = withUnsafeMutableBytes(
                of: &processIdentifier
            ) {
                Darwin.read(
                    descriptor,
                    $0.baseAddress,
                    $0.count
                )
            }
            if count < 0, errno == EINTR {
                continue
            }
            return count == MemoryLayout<Int32>.size
                ? processIdentifier
                : nil
        }
    }

    private func waitForExactProcessExit(
        _ processIdentifier: pid_t,
        timeoutNanoseconds: UInt64
    ) -> Int32? {
        guard let deadline = monotonicDeadline(
            after: timeoutNanoseconds
        ) else {
            return nil
        }
        while DispatchTime.now().uptimeNanoseconds
            <= deadline
        {
            var status: Int32 = 0
            errno = 0
            let returned = Darwin.waitpid(
                processIdentifier,
                &status,
                WNOHANG
            )
            if returned == processIdentifier {
                return status
            }
            if returned < 0, errno == EINTR {
                continue
            }
            guard returned == 0 else {
                return nil
            }
            _ = Darwin.poll(nil, 0, 10)
        }
        return nil
    }

    private func monotonicDeadline(
        after nanoseconds: UInt64
    ) -> UInt64? {
        let (deadline, overflow) =
            DispatchTime.now()
            .uptimeNanoseconds
            .addingReportingOverflow(nanoseconds)
        return overflow ? nil : deadline
    }

    private func remainingPollMilliseconds(
        until deadline: UInt64
    ) -> Int32? {
        let now =
            DispatchTime.now().uptimeNanoseconds
        guard now < deadline else {
            return nil
        }
        let remaining = deadline - now
        let rounded =
            (remaining / 1_000_000)
            + (remaining % 1_000_000 == 0 ? 0 : 1)
        return Int32(
            min(rounded, UInt64(Int32.max))
        )
    }

    private func duplicateCStringArray(
        _ strings: [String]
    ) throws -> [UnsafeMutablePointer<CChar>] {
        var result:
            [UnsafeMutablePointer<CChar>] = []
        result.reserveCapacity(strings.count)
        for string in strings {
            guard !string.contains("\0"),
                  let duplicated = strdup(string)
            else {
                freeCStringArray(result)
                throw POSIXError(.EINVAL)
            }
            result.append(duplicated)
        }
        return result
    }

    private func freeCStringArray(
        _ strings: [UnsafeMutablePointer<CChar>]
    ) {
        for string in strings {
            free(string)
        }
    }

    private func requireSpawnSuccess(
        _ returnCode: Int32
    ) throws {
        guard returnCode == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: returnCode)
                    ?? .EIO
            )
        }
    }

    private func currentPOSIXError() -> POSIXError {
        POSIXError(
            POSIXErrorCode(rawValue: errno)
                ?? .EIO
        )
    }

    private func writeSecureChildBytes(
        _ bytes: [UInt8],
        descriptor: Int32
    ) throws {
        var offset = 0
        while offset < bytes.count {
            let count = bytes.withUnsafeBytes {
                Darwin.write(
                    descriptor,
                    $0.baseAddress!.advanced(by: offset),
                    $0.count - offset
                )
            }
            if count < 0, errno == EINTR { continue }
            guard count > 0 else {
                throw POSIXError(
                    POSIXErrorCode(rawValue: errno) ?? .EIO
                )
            }
            offset += count
        }
    }

    private func makeCanonicalPrivateSecureChildDirectory(
        prefix: String
    ) throws -> URL {
        let created = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "\(prefix)-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: created,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700]
        )
        var canonicalBuffer = [CChar](
            repeating: 0,
            count: Int(PATH_MAX)
        )
        guard created.path.withCString({ input in
            canonicalBuffer.withUnsafeMutableBufferPointer {
                realpath(input, $0.baseAddress)
            }
        }) != nil else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno) ?? .EIO
            )
        }
        let result = URL(
            fileURLWithPath: String(cString: canonicalBuffer),
            isDirectory: true
        )
        guard chmod(result.path, mode_t(0o700)) == 0 else {
            throw POSIXError(
                POSIXErrorCode(rawValue: errno) ?? .EIO
            )
        }
        return result
    }

    private func packageRoot() throws -> URL {
        let path = "/" + #filePath.split(separator: "/").dropLast(3).joined(separator: "/")
        guard try PrimeSecureChildPath.canonicalPath(path) == path else {
            throw PrimeNativeNeuralGateSecureExternalChildCaptureError.rejected("test_source_path")
        }
        return URL(fileURLWithPath: path, isDirectory: true)
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

// Reviewed current-package canary profile, calibrated from two actual closed
// Release captures at source seal 6e0c939f on 2026-09-08. The complete raw and
// normalized JSON is retained in the task's calibration evidence. This pins
// package-description bytes; native capture still validates the live complete
// source closure, held tool image, cwd and child lifecycle independently.
private enum PrimeCurrentPackageDescribeCanaryFixture {
    // Historical actual-package checkpoint remains unchanged and named.
    // Its original raw bytes were not recovered; this is not a replay claim.
    static let historicalAugust3ByteCount = 63_214
    static let historicalAugust3SHA256 =
        "9901d983ed76f6ffa26f3c59142c6a71ec4453be2d38156001d10f0beb5d9bb5"
    static let historicalCommit = "4be3bdb9eb768e0617851cf22c2d67f677025001"
    static let normalizedByteCount = 86_930
    static let normalizedSHA256 =
        "3a6c0c5a9b38cde86e2ec58609e8a043a0dfcbcbe61b2b70db3cf56330b15561"
    static let placeholder = "__PRIME_CURRENT_PACKAGE_SOURCE_ROOT__"
    static let resourceTargets = [
        "PrimeNativeNeuralGateHistoricalSourceDerivation",
        "PrimeNativeNeuralGateHistoricalFixtureWorker",
    ]
    static let resourceNames = [
        "HistoricalEvidenceExportSource",
        "HistoricalFixtureEvidence",
    ]
    // Offsets are measured sequentially, after each prior replacement. This
    // removes dependence on the length of a freshly admitted physical root.
    static let valueOffsets = [384, 26_715, 30_759]
    enum Rejection: Error { case schema, rootCoordinate, digest }

    static func normalize(_ actual: Data, sourceRoot: String) throws -> Data {
        guard !actual.isEmpty, actual.count <= 16_777_216,
              sourceRoot.hasPrefix("/"), !sourceRoot.contains("\0"),
              let object = try JSONSerialization.jsonObject(with: actual) as? [String: Any],
              object["path"] as? String == sourceRoot,
              let targets = object["targets"] as? [[String: Any]] else { throw Rejection.schema }
        var suffixes = [""]
        for index in resourceTargets.indices {
            let matching = targets.filter { $0["name"] as? String == resourceTargets[index] }
            let suffix = "/Sources/" + resourceTargets[index] + "/" + resourceNames[index]
            guard matching.count == 1,
                  let resources = matching[0]["resources"] as? [[String: Any]], resources.count == 1,
                  Set(resources[0].keys) == Set(["path", "rule"]),
                  resources[0]["path"] as? String == sourceRoot + suffix,
                  let rule = resources[0]["rule"] as? [String: Any], Set(rule.keys) == Set(["copy"]),
                  let copy = rule["copy"] as? [String: Any], copy.isEmpty else { throw Rejection.schema }
            suffixes.append(suffix)
        }
        var rootValues: [String] = []
        func collect(_ value: Any) {
            if let value = value as? String {
                if value.hasPrefix(sourceRoot) { rootValues.append(value) }
            } else if let value = value as? [String: Any] {
                for child in value.values { collect(child) }
            } else if let value = value as? [Any] {
                for child in value { collect(child) }
            }
        }
        collect(object)
        guard rootValues.sorted() == suffixes.map({ sourceRoot + $0 }).sorted() else { throw Rejection.schema }
        var normalized = actual
        for index in suffixes.indices {
            normalized = try replacePathToken(normalized, valueOffset: valueOffsets[index],
                actualValue: sourceRoot + suffixes[index], replacementValue: placeholder + suffixes[index])
        }
        return normalized
    }

    // One exact JSON string token at one reviewed byte coordinate. The pinned
    // tool emits unescaped slashes. There is no parse/reserialization of the
    // output and no global path replacement, target filtering or byte dropping.
    static func replacePathToken(_ data: Data, valueOffset: Int,
                                 actualValue: String, replacementValue: String) throws -> Data {
        guard valueOffset >= 0, valueOffset <= data.count else { throw Rejection.rootCoordinate }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        let token = try encoder.encode(actualValue)
        guard token.count <= data.count - valueOffset,
              data.subdata(in: valueOffset ..< valueOffset + token.count) == token,
              data.range(of: token) == (valueOffset ..< valueOffset + token.count),
              data.range(of: token, options: [], in: valueOffset + token.count ..< data.count) == nil,
              let prefixText = String(data: data.prefix(valueOffset), encoding: .utf8),
              prefixText.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("\"path\" :") else {
            throw Rejection.rootCoordinate
        }
        var result = Data(data.prefix(valueOffset))
        result.append(try encoder.encode(replacementValue))
        result.append(data.suffix(from: valueOffset + token.count))
        return result
    }

    static func validate(_ actual: Data, sourceRoot: String) throws {
        let normalized = try normalize(actual, sourceRoot: sourceRoot)
        guard normalized.count == normalizedByteCount,
              PrimeSHA256.hexDigest(of: normalized) == normalizedSHA256 else { throw Rejection.digest }
    }
}
