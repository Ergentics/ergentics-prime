import Darwin
import Dispatch
import Foundation

public enum PrimeNativeNeuralGateSecureExternalChildCaptureError:
    Error,
    Equatable,
    Sendable
{
    case rejected(String)
}

extension PrimeNativeNeuralGateSecureExternalChildCaptureError:
    LocalizedError
{
    public var errorDescription: String? {
        switch self {
        case let .rejected(detail):
            "secure external-child capture rejected: \(detail)"
        }
    }
}

/// A closed result from the Prime-owned Darwin child-capture factory.
///
/// The public surface intentionally has no initializer. In particular,
/// callers cannot supply executable bytes, process evidence, a source
/// snapshot, or a trusted-capture capability.
public struct PrimeNativeNeuralGateSecureExternalChildCaptureResult:
    Sendable
{
    public let role:
        PrimeNativeNeuralGateReleaseProcessRole
    public let evidence:
        PrimeNativeNeuralGateExternalChildCaptureEvidence
    public let trustedCapture:
        PrimeNativeNeuralGateTrustedExternalChildCapture
    public let standardOutputData: Data
    public let standardErrorData: Data
    public let swiftPackageExecutableAbsolutePath:
        String
    public let mappedChildMainImageAbsolutePath:
        String
    public let workingDirectoryAbsolutePath:
        String
    public let processPathTelemetry: String?
    public let validatedPrimeSourceSnapshot:
        PrimeSwiftSourceSnapshot
    public let validatedPrimeSourceSnapshotBinding:
        PrimeArtifactBinding
    public let packageManifestSHA256: String
    public let packageManifestByteCount: UInt64
    public let workingDirectoryDeviceID: UInt64
    public let workingDirectoryInode: UInt64
    public let childProcessGroupIdentifier: Int32
    public let scratchNamespace:
        PrimeNativeNeuralGateScratchNamespaceObservation

    init(
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        evidence:
            PrimeNativeNeuralGateExternalChildCaptureEvidence,
        trustedCapture:
            PrimeNativeNeuralGateTrustedExternalChildCapture,
        standardOutputData: Data,
        standardErrorData: Data,
        swiftPackageExecutableAbsolutePath:
            String,
        mappedChildMainImageAbsolutePath:
            String,
        workingDirectoryAbsolutePath:
            String,
        processPathTelemetry: String?,
        validatedPrimeSourceSnapshot:
            PrimeSwiftSourceSnapshot,
        validatedPrimeSourceSnapshotBinding:
            PrimeArtifactBinding,
        packageManifestSHA256: String,
        packageManifestByteCount: UInt64,
        workingDirectoryDeviceID: UInt64,
        workingDirectoryInode: UInt64,
        childProcessGroupIdentifier: Int32,
        scratchNamespace:
            PrimeNativeNeuralGateScratchNamespaceObservation
    ) {
        self.role = role
        self.evidence = evidence
        self.trustedCapture = trustedCapture
        self.standardOutputData =
            standardOutputData
        self.standardErrorData =
            standardErrorData
        self.swiftPackageExecutableAbsolutePath =
            swiftPackageExecutableAbsolutePath
        self.mappedChildMainImageAbsolutePath =
            mappedChildMainImageAbsolutePath
        self.workingDirectoryAbsolutePath =
            workingDirectoryAbsolutePath
        self.processPathTelemetry =
            processPathTelemetry
        self.validatedPrimeSourceSnapshot =
            validatedPrimeSourceSnapshot
        self.validatedPrimeSourceSnapshotBinding =
            validatedPrimeSourceSnapshotBinding
        self.packageManifestSHA256 =
            packageManifestSHA256
        self.packageManifestByteCount =
            packageManifestByteCount
        self.workingDirectoryDeviceID =
            workingDirectoryDeviceID
        self.workingDirectoryInode =
            workingDirectoryInode
        self.childProcessGroupIdentifier =
            childProcessGroupIdentifier
        self.scratchNamespace =
            scratchNamespace
    }
}

/// PrimeCore's sole closed factory for the frozen `swift package describe`
/// external-child observation.
///
/// The executable, arguments, environment, file-descriptor policy, limits,
/// process-group policy, and signal state are not caller-selectable. The
/// source root is admitted only after the complete embedded Release source
/// identity is captured through `PrimeSwiftSourceProvenance`, joined to a
/// held no-symlink directory descriptor, and observed as the suspended
/// child's current-directory vnode.
public enum PrimeNativeNeuralGateSecureExternalChildCapture {
    private static let executableAbsolutePath =
        "/Applications/Xcode.app/Contents/Developer/" +
        "Toolchains/XcodeDefault.xctoolchain/usr/bin/" +
        "swift-package"
    private static let packageManifestRelativePath =
        "Package.swift"
    private static let requiredPrimeSourcePaths:
        Set<String> = [
            "Sources/PrimeCore/" +
                "PrimeNativeNeuralGateFixtureReplayPlan.swift",
            "Sources/PrimeCore/" +
                "PrimeNativeNeuralGateSecureExternalChildCapture.swift",
            "Sources/PrimeCore/" +
                "PrimeNativeNeuralGateHeldSourceClosure.swift",
            "Sources/PrimeCore/" +
                "PrimeNativeNeuralGateSecureChildLifecycle.swift",
            "Sources/PrimeCore/" +
                "PrimeNativeNeuralGateSecureScratchNamespace.swift",
        ]
    private static let regionQueryLimit = 65_536
    private static let ioChunkByteCount = 64 * 1024
    private static let signalGraceSeconds: UInt64 = 2
    private static let processPathBufferByteCount =
        4 * Int(MAXPATHLEN)

    /// Executes the frozen capture on a Darwin 26 host.
    ///
    /// `sourceRoot` is the only URL input. It does not become authority from
    /// its name: the complete sealed Release snapshot, held root descriptor,
    /// root-relative manifest bytes, and child cwd vnode must all join.
    @available(macOS 26.0, *)
    public static func capture(
        role:
            PrimeNativeNeuralGateReleaseProcessRole,
        sourceRoot: URL
    ) throws
        -> PrimeNativeNeuralGateSecureExternalChildCaptureResult
    {
        let sourceAdmissionStartedMonotonicNanoseconds =
            monotonicNanoseconds()
        let contract =
            PrimeNativeNeuralGateSourceExecutionBindingContract
            .frozenV3
        try contract.validate()
        try requireCalibratedDarwinConstants()

        let root = try HeldPrimeSourceRoot(
            sourceRoot: sourceRoot
        )
        defer {
            root.close()
        }

        let preSourceSnapshot =
            try PrimeSwiftSourceProvenance.capture(
                at: root.url,
                requiredRelativePaths:
                    requiredPrimeSourcePaths
            )
        let preManifest =
            try root.readRegularFile(
                relativePath:
                    packageManifestRelativePath
            )
        try requireManifestJoin(
            manifestData: preManifest,
            sourceSnapshot: preSourceSnapshot
        )
        try root.requireStablePathAndDescriptor()
        let heldSourceClosure =
            try PrimeNativeNeuralGateHeldSourceClosure(
                rootDescriptor:
                    root.descriptor,
                sourceSnapshot:
                    preSourceSnapshot,
                sourceAdmissionStartedMonotonicNanoseconds:
                    sourceAdmissionStartedMonotonicNanoseconds,
                sourceAdmissionMaximumSeconds:
                    contract
                    .swiftPackageDescribeSourceAdmissionMaximumSeconds
            )
        defer {
            heldSourceClosure.close()
        }
        let scratch =
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: role,
                sourceRootDescriptor:
                    root.descriptor
            )
        defer {
            scratch.close()
        }
        let scratchLaunch =
            try scratch.launchConfiguration

        let executable =
            try HeldExecutable(
                absolutePath:
                    executableAbsolutePath
            )
        defer {
            executable.close()
        }
        let descriptorOpenedMonotonicNanoseconds =
            monotonicNanoseconds()
        let preSpawnRead =
            try executable.readStableCheckpoint(
                contract: contract
            )
        let deadlineNanoseconds =
            try deadline(
                start:
                    descriptorOpenedMonotonicNanoseconds,
                maximumSeconds:
                    contract
                    .swiftPackageDescribeMaximumWallSeconds
            )

        let stdoutPipe = try RawPipe()
        let stderrPipe: RawPipe
        do {
            stderrPipe = try RawPipe()
        } catch {
            stdoutPipe.closeAll()
            throw error
        }

        let spawn: SpawnResult
        do {
            spawn = try spawnSuspendedChild(
                rootDescriptor:
                    root.descriptor,
                stdoutPipe: stdoutPipe,
                stderrPipe: stderrPipe,
                exactArguments:
                    scratchLaunch
                    .arguments,
                orderedEnvironment:
                    scratchLaunch
                    .orderedEnvironment
            )
        } catch {
            stdoutPipe.closeAll()
            stderrPipe.closeAll()
            throw error
        }

        stdoutPipe.closeWriteEnd()
        stderrPipe.closeWriteEnd()

        let stdoutDrain = RawBoundedDrain(
            descriptor:
                stdoutPipe.takeReadEnd(),
            maximumByteCount:
                contract
                .swiftPackageDescribeMaximumStandardOutputBytes,
            chunkByteCount: ioChunkByteCount
        )
        let stderrDrain = RawBoundedDrain(
            descriptor:
                stderrPipe.takeReadEnd(),
            maximumByteCount:
                contract
                .swiftPackageDescribeMaximumStandardErrorBytes,
            chunkByteCount: ioChunkByteCount
        )
        let drainGroup = DispatchGroup()
        stdoutDrain.start(group: drainGroup)
        stderrDrain.start(group: drainGroup)

        let child =
            PrimeNativeNeuralGateSecureChildLifecycle
            .liveDarwin(
            processIdentifier:
                spawn.processIdentifier
        )
        child.startDeathObservation()

        do {
            guard getsid(
                spawn.processIdentifier
            ) == spawn.processIdentifier,
            getpgid(
                spawn.processIdentifier
            ) == spawn.processIdentifier,
            child
                .establishIsolatedSessionAndDedicatedGroup()
            else {
                throw rejected(
                    "child_session_or_process_group"
                )
            }
            let childSessionAndProcessGroupObservedMonotonicNanoseconds =
                monotonicNanoseconds()
            let workingDirectoryObservation =
                try root.childCurrentDirectoryObservation(
                    processIdentifier:
                        spawn.processIdentifier
                )
            let workingDirectoryCapturedMonotonicNanoseconds =
                monotonicNanoseconds()

            let mappedTranscript =
                try captureMappedRegionTranscript(
                    processIdentifier:
                        spawn.processIdentifier,
                    executableSnapshot:
                        preSpawnRead.snapshot,
                    contract: contract
                )
            let mappedRegionCapturedMonotonicNanoseconds =
                monotonicNanoseconds()

            let processPathTelemetry =
                captureProcessPathTelemetry(
                    processIdentifier:
                        spawn.processIdentifier
                )

            let preResumeRead =
                try executable.readStableCheckpoint(
                    contract: contract
                )
            let descriptorRevalidatedBeforeResumeMonotonicNanoseconds =
                monotonicNanoseconds()
            guard preSpawnRead.snapshot
                    == preResumeRead.snapshot,
                  preSpawnRead.data
                    == preResumeRead.data
            else {
                throw rejected(
                    "executable_changed_before_resume"
                )
            }
            let sourcePreResumeValidationMonotonicNanoseconds =
                try heldSourceClosure
                .validateBeforeResume()
            let scratchPreResumeValidationMonotonicNanoseconds =
                try scratch
                .validateBeforeResume()
            guard monotonicNanoseconds()
                    < deadlineNanoseconds
            else {
                throw rejected(
                    "wall_deadline_before_resume"
                )
            }

            errno = 0
            let sigcontResult =
                Darwin.kill(
                    spawn.processIdentifier,
                    SIGCONT
                )
            guard sigcontResult == 0 else {
                throw rejected(
                    "sigcont_\(errno)"
                )
            }
            let sigcontDeliveredMonotonicNanoseconds =
                monotonicNanoseconds(
                    strictlyAfter:
                        descriptorRevalidatedBeforeResumeMonotonicNanoseconds
                )
            guard child.markResumed()
            else {
                throw rejected(
                    "child_resume_state"
                )
            }

            guard child.observeDeath(
                untilNanoseconds:
                    deadlineNanoseconds
            ) else {
                throw rejected("wall_deadline")
            }
            guard let childTerminationObservedMonotonicNanoseconds =
                    child
                    .deathObservedMonotonicNanoseconds()
            else {
                throw rejected(
                    "child_death_observation"
                )
            }
            guard childTerminationObservedMonotonicNanoseconds
                    <= deadlineNanoseconds
            else {
                throw rejected("wall_deadline")
            }
            guard drainGroup.wait(
                timeout:
                    DispatchTime(
                        uptimeNanoseconds:
                            deadlineNanoseconds
                    )
            ) == .success else {
                throw rejected("stream_deadline")
            }

            guard let preReapProcessGroupMemberIdentifiers =
                    child
                    .processGroupMemberIdentifiers(),
                  preReapProcessGroupMemberIdentifiers
                    == [
                        spawn.processIdentifier,
                    ]
            else {
                throw rejected(
                    "process_group_descendants_before_reap"
                )
            }
            let preReapProcessGroupMembersObservedMonotonicNanoseconds =
                monotonicNanoseconds()
            let wait:
                PrimeNativeNeuralGateExactPIDWaitObservation
            switch child.reapAfterObservedDeath() {
            case let .reaped(observation):
                wait = observation
            case let .mustFailStop(reason):
                failStop(reason)
            }
            let childReapedMonotonicNanoseconds =
                wait.returnedMonotonicNanoseconds
            let processGroupEmptyObservedMonotonicNanoseconds =
                monotonicNanoseconds()
            guard wait.rawWaitStatus == 0 else {
                throw rejected(
                    "child_wait_status_\(wait.rawWaitStatus)"
                )
            }

            let stdout = stdoutDrain.snapshot()
            let stderr = stderrDrain.snapshot()
            guard stdout.workerFinished,
                  stdout.reachedEOF,
                  stdout.readErrorNumber == 0,
                  !stdout.overflowed,
                  stderr.workerFinished,
                  stderr.reachedEOF,
                  stderr.readErrorNumber == 0,
                  !stderr.overflowed,
                  stderr.totalByteCount == 0,
                  stderr.data.isEmpty
            else {
                throw rejected("stream_capture")
            }

            let postReapRead =
                try executable.readStableCheckpoint(
                    contract: contract
                )
            let descriptorRevalidatedAfterReapMonotonicNanoseconds =
                monotonicNanoseconds()
            guard preSpawnRead.snapshot
                    == postReapRead.snapshot,
                  preSpawnRead.data
                    == postReapRead.data
            else {
                throw rejected(
                    "executable_changed_after_reap"
                )
            }
            guard descriptorRevalidatedAfterReapMonotonicNanoseconds
                    <= deadlineNanoseconds
            else {
                throw rejected("wall_deadline")
            }

            let postSourceSnapshot =
                try PrimeSwiftSourceProvenance.capture(
                    at: root.url,
                    requiredRelativePaths:
                        requiredPrimeSourcePaths
                )
            let postManifest =
                try root.readRegularFile(
                    relativePath:
                        packageManifestRelativePath
                )
            try requireManifestJoin(
                manifestData: postManifest,
                sourceSnapshot: postSourceSnapshot
            )
            try root.requireStablePathAndDescriptor()
            guard preSourceSnapshot
                    == postSourceSnapshot,
                  preManifest == postManifest
            else {
                throw rejected(
                    "prime_source_changed"
                )
            }
            let sourcePostReapValidationMonotonicNanoseconds =
                try heldSourceClosure
                .validateAfterReap()
            guard sourcePreResumeValidationMonotonicNanoseconds
                    <= scratchPreResumeValidationMonotonicNanoseconds,
                  scratchPreResumeValidationMonotonicNanoseconds
                    < sigcontDeliveredMonotonicNanoseconds,
                  descriptorRevalidatedAfterReapMonotonicNanoseconds
                    <= sourcePostReapValidationMonotonicNanoseconds,
                  sourcePostReapValidationMonotonicNanoseconds
                    <= deadlineNanoseconds
            else {
                throw rejected(
                    "source_checkpoint_timing"
                )
            }
            let sourceClosureMutationGuard =
                try heldSourceClosure
                .observation(
                    contract: contract
                )
            let scratchPostReapValidationMonotonicNanoseconds =
                try scratch
                .validateAfterReap(
                    outerDeadlineMonotonicNanoseconds:
                        deadlineNanoseconds
                )
            guard sourcePostReapValidationMonotonicNanoseconds
                    <= scratchPostReapValidationMonotonicNanoseconds,
                  scratchPostReapValidationMonotonicNanoseconds
                    <= deadlineNanoseconds
            else {
                throw rejected(
                    "scratch_checkpoint_timing"
                )
            }
            let scratchNamespace =
                try scratch.observation()
            let sourceSnapshotData =
                try PrimeCanonicalJSON.encode(
                    preSourceSnapshot
                )
            let sourceSnapshotBinding =
                PrimeArtifactBinding(
                    relativePath:
                        contract
                        .sourceSnapshotRelativePath,
                    sha256:
                        PrimeSHA256.hexDigest(
                            of: sourceSnapshotData
                        ),
                    byteCount:
                        UInt64(
                            sourceSnapshotData.count
                        ),
                    purpose: .immutableData
                )

            let launchObservation =
                PrimeNativeNeuralGateTrustedExternalChildLaunchObservation(
                    role: role,
                    exactArguments:
                        scratchLaunch
                        .arguments,
                    exactEnvironmentKeys:
                        scratchLaunch
                        .orderedEnvironment
                        .map(\.0),
                    exactEnvironment:
                        scratchLaunch
                        .orderedEnvironment
                        .map {
                            "\($0.0)=\($0.1)"
                        },
                    environmentPolicy:
                        contract
                        .swiftPackageDescribeEnvironmentPolicy,
                    scratchNamespace:
                        scratchNamespace,
                    directProcessWithoutShell:
                        true,
                    workingDirectoryAbsolutePath:
                        root.url.path,
                    workingDirectoryIsValidatedPrimeRoot:
                        true,
                    environmentKeyCount:
                        scratchLaunch
                        .orderedEnvironment.count,
                    standardInputPolicy:
                        "eof_v1",
                    maximumWallSeconds:
                        contract
                        .swiftPackageDescribeMaximumWallSeconds,
                    terminationControlPolicy:
                        contract
                        .swiftPackageDescribeTerminationEscalationPolicy
                )
            let streamObservation =
                PrimeNativeNeuralGateTrustedExternalChildStreamLifecycleObservation(
                    maximumStandardOutputBytes:
                        contract
                        .swiftPackageDescribeMaximumStandardOutputBytes,
                    standardOutputOverflowed:
                        stdout.overflowed,
                    standardOutputDrainCompleted:
                        stdout.workerFinished
                            && stdout.reachedEOF,
                    maximumStandardErrorBytes:
                        contract
                        .swiftPackageDescribeMaximumStandardErrorBytes,
                    standardErrorOverflowed:
                        stderr.overflowed,
                    standardErrorDrainCompleted:
                        stderr.workerFinished
                            && stderr.reachedEOF
                )
            let evidence =
                PrimeNativeNeuralGateExternalChildCaptureEvidence(
                    supervisorProcessIdentifier:
                        getpid(),
                    childProcessIdentifier:
                        spawn.processIdentifier,
                    role: role,
                    capabilityCalibrationPassed:
                        true,
                    posixSpawnStartSuspendedFlag:
                        UInt16(
                            POSIX_SPAWN_START_SUSPENDED
                        ),
                    posixSpawnCloseOnExecDefaultFlag:
                        UInt16(
                            POSIX_SPAWN_CLOEXEC_DEFAULT
                        ),
                    posixSpawnSetSessionFlag:
                        UInt16(
                            POSIX_SPAWN_SETSID
                        ),
                    posixSpawnSetSignalDefaultsFlag:
                        UInt16(
                            POSIX_SPAWN_SETSIGDEF
                        ),
                    posixSpawnSetSignalMaskFlag:
                        UInt16(
                            POSIX_SPAWN_SETSIGMASK
                        ),
                    appliedSpawnFlags:
                        spawn.appliedFlags,
                    observedChildSessionIdentifier:
                        spawn.processIdentifier,
                    observedChildProcessGroupIdentifier:
                        spawn.processIdentifier,
                    emptySignalMaskConfigured:
                        true,
                    defaultSignalDispositionsConfigured:
                        true,
                    terminationSignalsTargetProcessGroup:
                        true,
                    posixSpawnReturnCode:
                        spawn.returnCode,
                    procPIDRegionPathInfoFlavor:
                        Int32(
                            PROC_PIDREGIONPATHINFO
                        ),
                    procRegionWithPathInfoByteCount:
                        MemoryLayout<
                            proc_regionwithpathinfo
                        >.size,
                    descriptorOpenedMonotonicNanoseconds:
                        descriptorOpenedMonotonicNanoseconds,
                    spawnReturnedMonotonicNanoseconds:
                        spawn
                        .returnedMonotonicNanoseconds,
                    childSessionAndProcessGroupObservedMonotonicNanoseconds:
                        childSessionAndProcessGroupObservedMonotonicNanoseconds,
                    workingDirectoryCapturedMonotonicNanoseconds:
                        workingDirectoryCapturedMonotonicNanoseconds,
                    mappedRegionCapturedMonotonicNanoseconds:
                        mappedRegionCapturedMonotonicNanoseconds,
                    descriptorRevalidatedBeforeResumeMonotonicNanoseconds:
                        descriptorRevalidatedBeforeResumeMonotonicNanoseconds,
                    sigcontDeliveredMonotonicNanoseconds:
                        sigcontDeliveredMonotonicNanoseconds,
                    sigcontReturnCode:
                        sigcontResult,
                    childTerminationObservedMonotonicNanoseconds:
                        childTerminationObservedMonotonicNanoseconds,
                    preReapProcessGroupMemberIdentifiers:
                        preReapProcessGroupMemberIdentifiers,
                    preReapProcessGroupMembersObservedMonotonicNanoseconds:
                        preReapProcessGroupMembersObservedMonotonicNanoseconds,
                    childReapedMonotonicNanoseconds:
                        childReapedMonotonicNanoseconds,
                    processGroupEmptyObservedMonotonicNanoseconds:
                        processGroupEmptyObservedMonotonicNanoseconds,
                    descriptorRevalidatedAfterReapMonotonicNanoseconds:
                        descriptorRevalidatedAfterReapMonotonicNanoseconds,
                    sourceClosureMutationGuard:
                        sourceClosureMutationGuard,
                    scratchNamespace:
                        scratchNamespace,
                    workingDirectory:
                        workingDirectoryObservation,
                    preSpawnDescriptor:
                        preSpawnRead.snapshot,
                    preResumeDescriptor:
                        preResumeRead.snapshot,
                    postReapDescriptor:
                        postReapRead.snapshot,
                    allMappedRegionQueries:
                        mappedTranscript.queries,
                    terminalMappedRegionQueryAddress:
                        mappedTranscript
                        .terminalQueryAddress,
                    terminalMappedRegionQueryReturnByteCount:
                        mappedTranscript
                        .terminalReturnByteCount,
                    terminalMappedRegionQueryErrno:
                        mappedTranscript
                        .terminalErrno,
                    mappedRegionEnumerationCompleted:
                        true,
                    exactPIDWaitObservation:
                        wait,
                    deadlineExpired:
                        false,
                    sigtermDelivered:
                        false,
                    sigkillDelivered:
                        false,
                    processGroupEmptyAfterReap:
                        true,
                    procPIDPathUsedOnlyAsTelemetry:
                        true,
                    contract: contract
                )

            try evidence.validate(
                against: contract,
                expectedSupervisorProcessIdentifier:
                    getpid(),
                expectedChildProcessIdentifier:
                    spawn.processIdentifier
            )

            let trustedCapture =
                try PrimeNativeNeuralGateTrustedExternalChildCapture(
                    evidence: evidence,
                    swiftPackageExecutableAbsolutePath:
                        executableAbsolutePath,
                    mappedChildMainImageAbsolutePath:
                        mappedTranscript
                        .mappedExecutablePathTelemetry,
                    preSpawnDescriptorReadSnapshot:
                        preSpawnRead.snapshot,
                    preSpawnDescriptorReadData:
                        preSpawnRead.data,
                    preResumeDescriptorReadSnapshot:
                        preResumeRead.snapshot,
                    preResumeDescriptorReadData:
                        preResumeRead.data,
                    postReapDescriptorReadSnapshot:
                        postReapRead.snapshot,
                    postReapDescriptorReadData:
                        postReapRead.data,
                    validatedPrimeSourceSnapshot:
                        preSourceSnapshot,
                    standardOutputData:
                        stdout.data,
                    standardErrorData:
                        stderr.data,
                    launchObservation:
                        launchObservation,
                    streamLifecycleObservation:
                        streamObservation
                )
            try trustedCapture.validate(
                evidence: evidence,
                contract: contract,
                expectedSwiftPackageExecutableAbsolutePath:
                    executableAbsolutePath,
                expectedMappedChildMainImageAbsolutePath:
                    mappedTranscript
                    .mappedExecutablePathTelemetry,
                expectedPrimeSourceSnapshot:
                    sourceSnapshotBinding,
                standardOutputData:
                    stdout.data,
                captureLaunchObservation:
                    launchObservation,
                captureStreamLifecycleObservation:
                    streamObservation
            )

            return
                PrimeNativeNeuralGateSecureExternalChildCaptureResult(
                    role: role,
                    evidence: evidence,
                    trustedCapture:
                        trustedCapture,
                    standardOutputData:
                        stdout.data,
                    standardErrorData:
                        stderr.data,
                    swiftPackageExecutableAbsolutePath:
                        executableAbsolutePath,
                    mappedChildMainImageAbsolutePath:
                        mappedTranscript
                        .mappedExecutablePathTelemetry,
                    workingDirectoryAbsolutePath:
                        root.url.path,
                    processPathTelemetry:
                        processPathTelemetry,
                    validatedPrimeSourceSnapshot:
                        preSourceSnapshot,
                    validatedPrimeSourceSnapshotBinding:
                        sourceSnapshotBinding,
                    packageManifestSHA256:
                        PrimeSHA256.hexDigest(
                            of: preManifest
                        ),
                    packageManifestByteCount:
                        UInt64(
                            preManifest.count
                        ),
                    workingDirectoryDeviceID:
                        root.deviceID,
                    workingDirectoryInode:
                        root.inode,
                    childProcessGroupIdentifier:
                        spawn.processIdentifier,
                    scratchNamespace:
                        scratchNamespace
                )
        } catch {
            if !child.hasReaped {
                switch child
                    .cleanupRejectedCapture()
                {
                case .contained:
                    break
                case let .mustFailStop(reason):
                    failStop(reason)
                }
            }
            switch finishRejectedDrains(
                group: drainGroup,
                stdout: stdoutDrain,
                stderr: stderrDrain
            ) {
            case .contained:
                break
            case let .mustFailStop(reason):
                failStop(reason)
            }
            throw error
        }
    }

    private static func rejected(
        _ detail: String
    ) -> PrimeNativeNeuralGateSecureExternalChildCaptureError {
        .rejected(detail)
    }

    private static func failStop(
        _ reason:
            PrimeSecureChildContainmentFailureReason
    ) -> Never {
        withExtendedLifetime(reason) {}
        Darwin._exit(70)
    }

    private static func requireCalibratedDarwinConstants()
        throws
    {
        guard UInt16(
            POSIX_SPAWN_START_SUSPENDED
        ) == 0x0080,
        UInt16(
            POSIX_SPAWN_CLOEXEC_DEFAULT
        ) == 0x4000,
        UInt16(POSIX_SPAWN_SETSID)
            == 0x0400,
        UInt16(POSIX_SPAWN_SETSIGDEF)
            == 0x0004,
        UInt16(POSIX_SPAWN_SETSIGMASK)
            == 0x0008,
        PROC_PIDREGIONPATHINFO == 8,
        PROC_PIDVNODEPATHINFO == 9,
        MemoryLayout<
            proc_regionwithpathinfo
        >.size == 1_272,
        MemoryLayout<
            proc_vnodepathinfo
        >.size == 2_352,
        Int32(EINVAL) == 22,
        UInt32(VM_PROT_WRITE) == 0x2,
        UInt32(VM_PROT_EXECUTE) == 0x4
        else {
            throw rejected(
                "darwin_capability_calibration"
            )
        }
    }

    private static func requireManifestJoin(
        manifestData: Data,
        sourceSnapshot:
            PrimeSwiftSourceSnapshot
    ) throws {
        guard let manifest =
                sourceSnapshot.files.first(
                    where: {
                        $0.relativePath
                            == packageManifestRelativePath
                    }
                ),
              manifest.contents == manifestData,
              manifest.byteCount
                == UInt64(manifestData.count),
              manifest.sha256
                == PrimeSHA256.hexDigest(
                    of: manifestData
                )
        else {
            throw rejected(
                "package_manifest_descriptor_join"
            )
        }
    }

    private static func deadline(
        start: UInt64,
        maximumSeconds: UInt64
    ) throws -> UInt64 {
        let product =
            maximumSeconds
            .multipliedReportingOverflow(
                by: 1_000_000_000
            )
        let sum =
            start.addingReportingOverflow(
                product.partialValue
            )
        guard !product.overflow,
              !sum.overflow else {
            throw rejected("deadline_overflow")
        }
        return sum.partialValue
    }

    private static func monotonicNanoseconds(
        strictlyAfter prior: UInt64? = nil
    ) -> UInt64 {
        var observed =
            DispatchTime.now().uptimeNanoseconds
        if let prior {
            while observed <= prior {
                sched_yield()
                observed =
                    DispatchTime.now()
                    .uptimeNanoseconds
            }
        }
        return observed
    }

    @available(macOS 26.0, *)
    private static func spawnSuspendedChild(
        rootDescriptor: Int32,
        stdoutPipe: RawPipe,
        stderrPipe: RawPipe,
        exactArguments: [String],
        orderedEnvironment:
            [(String, String)]
    ) throws -> SpawnResult {
        var actions:
            posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(
            &actions
        ) == 0 else {
            throw rejected(
                "spawn_file_actions_init"
            )
        }
        defer {
            _ = posix_spawn_file_actions_destroy(
                &actions
            )
        }
        guard posix_spawnattr_init(
            &attributes
        ) == 0 else {
            throw rejected("spawn_attributes_init")
        }
        defer {
            _ = posix_spawnattr_destroy(
                &attributes
            )
        }

        try requireSpawnAction(
            posix_spawn_file_actions_addinherit_np(
                &actions,
                rootDescriptor
            ),
            "inherit_root"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addfchdir(
                &actions,
                rootDescriptor
            ),
            "fchdir_root"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                rootDescriptor
            ),
            "close_root"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addopen(
                &actions,
                STDIN_FILENO,
                "/dev/null",
                O_RDONLY,
                0
            ),
            "stdin_eof"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                stdoutPipe.readDescriptor
            ),
            "close_stdout_read"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_adddup2(
                &actions,
                stdoutPipe.writeDescriptor,
                STDOUT_FILENO
            ),
            "dup_stdout"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                stdoutPipe.writeDescriptor
            ),
            "close_stdout_write"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                stderrPipe.readDescriptor
            ),
            "close_stderr_read"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_adddup2(
                &actions,
                stderrPipe.writeDescriptor,
                STDERR_FILENO
            ),
            "dup_stderr"
        )
        try requireSpawnAction(
            posix_spawn_file_actions_addclose(
                &actions,
                stderrPipe.writeDescriptor
            ),
            "close_stderr_write"
        )

        var defaultSignals = sigset_t()
        guard sigemptyset(&defaultSignals) == 0
        else {
            throw rejected(
                "spawn_default_signals_empty"
            )
        }
        for signal in 1 ..< NSIG
        where signal != SIGKILL
            && signal != SIGSTOP
        {
            guard sigaddset(
                &defaultSignals,
                signal
            ) == 0 else {
                throw rejected(
                    "spawn_default_signal_\(signal)"
                )
            }
        }
        var emptyMask = sigset_t()
        guard sigemptyset(&emptyMask) == 0,
              posix_spawnattr_setsigdefault(
                  &attributes,
                  &defaultSignals
              ) == 0,
              posix_spawnattr_setsigmask(
                  &attributes,
                  &emptyMask
              ) == 0
        else {
            throw rejected(
                "spawn_signal_or_group_policy"
            )
        }

        let flags =
            UInt16(POSIX_SPAWN_START_SUSPENDED)
            | UInt16(
                POSIX_SPAWN_CLOEXEC_DEFAULT
            )
            | UInt16(POSIX_SPAWN_SETSID)
            | UInt16(POSIX_SPAWN_SETSIGDEF)
            | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard flags == 0x448c,
              posix_spawnattr_setflags(
                  &attributes,
                  Int16(bitPattern: flags)
              ) == 0
        else {
            throw rejected("spawn_flags")
        }

        let arguments =
            [executableAbsolutePath]
            + exactArguments
        let duplicatedArguments =
            try duplicateCStringArray(
                arguments
            )
        defer {
            freeCStringArray(
                duplicatedArguments
            )
        }
        var argv =
            duplicatedArguments.map {
                Optional($0)
            }
        argv.append(nil)
        let environmentStrings =
            orderedEnvironment.map {
                "\($0.0)=\($0.1)"
            }
        let duplicatedEnvironment =
            try duplicateCStringArray(
                environmentStrings
            )
        defer {
            freeCStringArray(
                duplicatedEnvironment
            )
        }
        var environment =
            duplicatedEnvironment.map {
                Optional($0)
            }
        environment.append(nil)
        var childPID: pid_t = 0
        let returnCode =
            argv.withUnsafeMutableBufferPointer {
                argvBuffer in
                environment
                    .withUnsafeMutableBufferPointer {
                        environmentBuffer in
                        posix_spawn(
                            &childPID,
                            executableAbsolutePath,
                            &actions,
                            &attributes,
                            argvBuffer.baseAddress,
                            environmentBuffer
                                .baseAddress
                        )
                    }
            }
        let returnedMonotonicNanoseconds =
            monotonicNanoseconds()
        guard returnCode == 0,
              childPID > 0 else {
            throw rejected(
                "posix_spawn_\(returnCode)"
            )
        }
        return SpawnResult(
            processIdentifier: childPID,
            appliedFlags: flags,
            returnCode: returnCode,
            returnedMonotonicNanoseconds:
                returnedMonotonicNanoseconds
        )
    }

    private static func requireSpawnAction(
        _ returnCode: Int32,
        _ label: String
    ) throws {
        guard returnCode == 0 else {
            throw rejected(
                "\(label)_\(returnCode)"
            )
        }
    }

    private static func duplicateCStringArray(
        _ strings: [String]
    ) throws -> [UnsafeMutablePointer<CChar>] {
        var result:
            [UnsafeMutablePointer<CChar>] = []
        result.reserveCapacity(strings.count)
        for string in strings {
            guard !string.contains("\0"),
                  let duplicated =
                    strdup(string) else {
                freeCStringArray(result)
                throw rejected(
                    "argument_encoding"
                )
            }
            result.append(duplicated)
        }
        return result
    }

    private static func freeCStringArray(
        _ strings:
            [UnsafeMutablePointer<CChar>]
    ) {
        for string in strings {
            free(string)
        }
    }

    private static func captureMappedRegionTranscript(
        processIdentifier: Int32,
        executableSnapshot:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract
    ) throws -> MappedRegionTranscript {
        let expectedSize =
            MemoryLayout<
                proc_regionwithpathinfo
            >.size
        return try evaluateMappedRegionTranscript(
            executableSnapshot:
                executableSnapshot,
            contract: contract,
            queryLimit: regionQueryLimit
        ) {
            queryAddress in
            var raw =
                proc_regionwithpathinfo()
            errno = 0
            let returned =
                withUnsafeMutablePointer(
                    to: &raw
                ) {
                    proc_pidinfo(
                        processIdentifier,
                        PROC_PIDREGIONPATHINFO,
                        queryAddress,
                        $0,
                        Int32(expectedSize)
                    )
                }
            let queryErrno = errno
            guard returned
                    == Int32(expectedSize)
            else {
                return MappedRegionQueryResult(
                    returnedByteCount:
                        returned,
                    queryErrno:
                        queryErrno,
                    region: nil,
                    mappedVnodePath: nil
                )
            }
            let status =
                raw.prp_vip.vip_vi.vi_stat
            return MappedRegionQueryResult(
                returnedByteCount:
                    returned,
                queryErrno: queryErrno,
                region:
                    PrimeNativeNeuralGateMappedExecutableRegionObservation(
                        address:
                            raw.prp_prinfo
                            .pri_address,
                        byteCount:
                            raw.prp_prinfo
                            .pri_size,
                        fileOffset:
                            raw.prp_prinfo
                            .pri_offset,
                        protection:
                            raw.prp_prinfo
                            .pri_protection,
                        deviceID:
                            UInt64(
                                bitPattern:
                                    Int64(
                                        status
                                        .vst_dev
                                    )
                            ),
                        inode:
                            status.vst_ino
                    ),
                mappedVnodePath:
                    boundedVnodePath(
                        raw.prp_vip
                        .vip_path
                    )
            )
        }
    }

    static func evaluateMappedRegionTranscript(
        executableSnapshot:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        queryLimit: Int,
        query:
            (UInt64) -> MappedRegionQueryResult
    ) throws -> MappedRegionTranscript {
        let expectedSize =
            MemoryLayout<
                proc_regionwithpathinfo
            >.size
        var queryAddress: UInt64 = 0
        var queries:
            [PrimeNativeNeuralGateMappedRegionQueryObservation] =
            []
        queries.reserveCapacity(
            min(256, max(0, queryLimit))
        )
        var matchingPathTelemetry =
            Set<String>()

        while queries.count < queryLimit {
            let result =
                query(queryAddress)
            let returned =
                result.returnedByteCount
            let queryErrno =
                result.queryErrno
            if returned == 0 {
                // libproc maps the XNU `EINVAL` returned when
                // `fill_procregioninfo` finds no next region to a zero byte
                // count. Because `EINVAL` can also describe a mapless task,
                // only a nonempty bounded transcript may treat it as the
                // terminal; the final clean lifecycle is validated later.
                // Clearing errno before each call preserves the exact
                // returned errno for this distinction.
                guard queryErrno
                        == contract
                        .swiftPackageDescribeMappedRegionTerminalErrno,
                      !queries.isEmpty else {
                    throw rejected(
                        "mapped_region_terminal_\(queryErrno)"
                    )
                }
                let matching =
                    queries
                    .map(\.region)
                    .filter {
                        $0.deviceID
                                == executableSnapshot
                                .deviceID
                            && $0.inode
                                == executableSnapshot
                                .inode
                    }
                let hasOffsetZeroExecutable =
                    matching.contains {
                        $0.fileOffset == 0
                            && ($0.protection
                            & UInt32(
                                VM_PROT_EXECUTE
                            )) != 0
                    }
                let hasWritableExecutable =
                    matching.contains {
                        ($0.protection
                            & UInt32(
                                VM_PROT_WRITE
                            )) != 0
                            && ($0.protection
                                & UInt32(
                                    VM_PROT_EXECUTE
                                )) != 0
                    }
                guard hasOffsetZeroExecutable,
                      !hasWritableExecutable,
                      matchingPathTelemetry.count
                        == 1,
                      let mappedPath =
                        matchingPathTelemetry
                        .first,
                      mappedPath
                        == executableAbsolutePath,
                      URL(
                          fileURLWithPath:
                            mappedPath
                      ).standardizedFileURL.path
                        == mappedPath
                else {
                    throw rejected(
                        "mapped_executable_join"
                    )
                }
                return MappedRegionTranscript(
                    queries: queries,
                    terminalQueryAddress:
                        queryAddress,
                    terminalReturnByteCount:
                        Int(returned),
                    terminalErrno:
                        queryErrno,
                    mappedExecutablePathTelemetry:
                        mappedPath
                )
            }
            guard returned
                    == Int32(expectedSize),
                  queryErrno == 0,
                  let region =
                    result.region
            else {
                throw rejected(
                    "mapped_region_query_\(returned)_\(queryErrno)"
                )
            }

            if region.deviceID
                    == executableSnapshot.deviceID,
               region.inode
                    == executableSnapshot.inode,
               let mappedPath =
                    result.mappedVnodePath
            {
                matchingPathTelemetry.insert(
                    mappedPath
                )
            }
            let end =
                region.address
                .addingReportingOverflow(
                    region.byteCount
                )
            guard region.address
                    >= queryAddress,
                  region.byteCount > 0,
                  !end.overflow,
                  end.partialValue
                    > region.address
            else {
                throw rejected(
                    "mapped_region_progress"
                )
            }
            queries.append(
                PrimeNativeNeuralGateMappedRegionQueryObservation(
                    queryAddress:
                        queryAddress,
                    returnedByteCount:
                        Int(returned),
                    region: region
                )
            )
            queryAddress = end.partialValue
        }
        throw rejected(
            "mapped_region_query_limit"
        )
    }

    private static func captureProcessPathTelemetry(
        processIdentifier: Int32
    ) -> String? {
        var buffer = [CChar](
            repeating: 0,
            count: processPathBufferByteCount
        )
        let returned =
            buffer.withUnsafeMutableBufferPointer {
                proc_pidpath(
                    processIdentifier,
                    $0.baseAddress,
                    UInt32($0.count)
                )
            }
        guard returned > 0 else {
            return nil
        }
        let upperBound =
            min(
                Int(returned) + 1,
                buffer.count
            )
        guard let terminator =
                buffer[
                    0 ..< upperBound
                ].firstIndex(of: 0),
              terminator > 0
        else {
            return nil
        }
        let bytes =
            buffer[
                0 ..< terminator
            ].map {
                UInt8(bitPattern: $0)
            }
        return String(
            bytes: bytes,
            encoding: .utf8
        )
    }

    private static func boundedVnodePath<Path>(
        _ pathStorage: Path
    ) -> String? {
        var mutableStorage = pathStorage
        return withUnsafeBytes(
            of: &mutableStorage
        ) {
            bytes in
            guard let terminator =
                    bytes.firstIndex(of: 0),
                  terminator > 0,
                  terminator
                    < bytes.count
            else {
                return nil
            }
            return String(
                bytes:
                    bytes[
                        0 ..< terminator
                    ],
                encoding: .utf8
            )
        }
    }

    @discardableResult
    private static func finishRejectedDrains(
        group: DispatchGroup,
        stdout: RawBoundedDrain,
        stderr: RawBoundedDrain
    ) -> PrimeSecureChildCleanupDisposition {
        if group.wait(
            timeout:
                .now()
                + .seconds(
                    Int(signalGraceSeconds)
                )
        ) == .success {
            return rejectedDrainDisposition(
                stdout: stdout.snapshot(),
                stderr: stderr.snapshot()
            )
        }
        stdout.requestStop()
        stderr.requestStop()
        let stopped =
            group.wait(
            timeout: .now() + .seconds(1)
        )
        guard stopped == .success
        else {
            return .mustFailStop(
                .streamDrainUncontained
            )
        }
        return rejectedDrainDisposition(
            stdout: stdout.snapshot(),
            stderr: stderr.snapshot()
        )
    }

    static func rejectedDrainDisposition(
        stdout: DrainSnapshot,
        stderr: DrainSnapshot
    ) -> PrimeSecureChildCleanupDisposition {
        stdout.workerFinished
            && stderr.workerFinished
        ? .contained
        : .mustFailStop(
            .streamDrainUncontained
        )
    }

    private struct SpawnResult {
        let processIdentifier: Int32
        let appliedFlags: UInt16
        let returnCode: Int32
        let returnedMonotonicNanoseconds:
            UInt64
    }

    struct MappedRegionQueryResult {
        let returnedByteCount: Int32
        let queryErrno: Int32
        let region:
            PrimeNativeNeuralGateMappedExecutableRegionObservation?
        let mappedVnodePath: String?
    }

    struct MappedRegionTranscript {
        let queries:
            [PrimeNativeNeuralGateMappedRegionQueryObservation]
        let terminalQueryAddress: UInt64
        let terminalReturnByteCount: Int
        let terminalErrno: Int32
        let mappedExecutablePathTelemetry:
            String
    }

    private final class HeldPrimeSourceRoot {
        let url: URL
        private(set) var descriptor: Int32
        private var initialStatus: stat

        var deviceID: UInt64 {
            UInt64(
                bitPattern:
                    Int64(initialStatus.st_dev)
            )
        }

        var inode: UInt64 {
            UInt64(initialStatus.st_ino)
        }

        init(sourceRoot: URL) throws {
            guard sourceRoot.isFileURL,
                  sourceRoot.path.hasPrefix("/"),
                  sourceRoot.path != "/",
                  !sourceRoot.path.contains("\0"),
                  sourceRoot.standardizedFileURL.path
                    == sourceRoot.path
            else {
                throw rejected("source_root_url")
            }
            url = sourceRoot
            descriptor = Darwin.open(
                sourceRoot.path,
                O_RDONLY
                    | O_DIRECTORY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
            )
            guard descriptor >= 0 else {
                throw rejected(
                    "source_root_open_\(errno)"
                )
            }
            if descriptor < 3 {
                let original =
                    descriptor
                let normalized =
                    fcntl(
                        original,
                        F_DUPFD_CLOEXEC,
                        3
                    )
                guard normalized >= 3 else {
                    let failure = errno
                    _ = Darwin.close(
                        original
                    )
                    descriptor = -1
                    throw rejected(
                        "source_root_normalization_\(failure)"
                    )
                }
                _ = Darwin.close(
                    original
                )
                descriptor = normalized
            }
            var status = stat()
            guard fstat(
                descriptor,
                &status
            ) == 0,
            status.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
            status.st_uid == geteuid(),
            status.st_mode & mode_t(0o022)
                == 0,
            status.st_ino > 0,
            fcntl(descriptor, F_GETFD)
                & FD_CLOEXEC != 0
            else {
                _ = Darwin.close(descriptor)
                descriptor = -1
                throw rejected(
                    "source_root_descriptor"
                )
            }
            initialStatus = status
            do {
                _ =
                    try PrimeNativeNeuralGateHeldSourceClosure
                    .requireLocalAPFS(
                        rootDescriptor:
                            descriptor
                    )
                var preparedStatus = stat()
                guard fstat(
                    descriptor,
                    &preparedStatus
                ) == 0,
                preparedStatus.st_mode
                    & mode_t(S_IFMT)
                    == mode_t(S_IFDIR),
                preparedStatus.st_uid
                    == geteuid(),
                preparedStatus.st_mode
                    & mode_t(0o022)
                    == 0,
                preparedStatus.st_ino > 0
                else {
                    throw rejected(
                        "source_root_after_build_preparation"
                    )
                }
                initialStatus =
                    preparedStatus
                try requireStablePathAndDescriptor()
            } catch {
                _ = Darwin.close(descriptor)
                descriptor = -1
                throw error
            }
        }

        func close() {
            guard descriptor >= 0 else {
                return
            }
            _ = Darwin.close(descriptor)
            descriptor = -1
        }

        func requireStablePathAndDescriptor()
            throws
        {
            var descriptorStatus = stat()
            var pathStatus = stat()
            guard descriptor >= 0,
                  fstat(
                      descriptor,
                      &descriptorStatus
                  ) == 0,
                  lstat(
                      url.path,
                      &pathStatus
                  ) == 0,
                  sameDirectoryIdentity(
                      initialStatus,
                      descriptorStatus
                  ),
                  sameDirectoryIdentity(
                      initialStatus,
                      pathStatus
                  ),
                  pathStatus.st_mode
                      & mode_t(S_IFMT)
                      == mode_t(S_IFDIR),
                  pathStatus.st_uid
                      == geteuid(),
                  pathStatus.st_mode
                      & mode_t(0o022)
                      == 0,
                  fcntl(descriptor, F_GETFD)
                      & FD_CLOEXEC != 0
            else {
                throw rejected(
                    "source_root_changed"
                )
            }
        }

        func childCurrentDirectoryObservation(
            processIdentifier: Int32
        ) throws
            -> PrimeNativeNeuralGateWorkingDirectoryObservation
        {
            var info =
                proc_vnodepathinfo()
            errno = 0
            let returned =
                withUnsafeMutablePointer(
                    to: &info
                ) {
                    proc_pidinfo(
                        processIdentifier,
                        PROC_PIDVNODEPATHINFO,
                        0,
                        $0,
                        Int32(
                            MemoryLayout<
                                proc_vnodepathinfo
                            >.size
                        )
                    )
                }
            let status =
                info.pvi_cdir
                .vip_vi.vi_stat
            guard returned
                    == Int32(
                        MemoryLayout<
                            proc_vnodepathinfo
                        >.size
                    ),
                  UInt64(
                      bitPattern:
                          Int64(status.vst_dev)
                  ) == deviceID,
                  status.vst_ino == inode,
                  status.vst_mode
                      & UInt16(S_IFMT)
                      == UInt16(S_IFDIR)
            else {
                throw rejected(
                    "child_cwd_descriptor_join_\(errno)"
                )
            }
            return
                PrimeNativeNeuralGateWorkingDirectoryObservation(
                    descriptorDeviceID:
                        deviceID,
                    descriptorInode:
                        inode,
                    descriptorOwnerUserID:
                        initialStatus.st_uid,
                    descriptorOwnerGroupID:
                        initialStatus.st_gid,
                    descriptorPermissionMode:
                        UInt16(
                            initialStatus
                            .st_mode
                                & mode_t(
                                    0o7777
                                )
                        ),
                    descriptorLinkCount:
                        UInt64(
                            initialStatus
                            .st_nlink
                        ),
                    descriptorIsDirectory:
                        true,
                    descriptorOpenedWithNoSymbolicLinksInPath:
                        true,
                    descriptorCloseOnExec:
                        true,
                    procPIDVnodePathInfoFlavor:
                        Int32(
                            PROC_PIDVNODEPATHINFO
                        ),
                    procVnodePathInfoByteCount:
                        MemoryLayout<
                            proc_vnodepathinfo
                        >.size,
                    suspendedChildCurrentDirectoryDeviceID:
                        UInt64(
                            bitPattern:
                                Int64(
                                    status.vst_dev
                                )
                        ),
                    suspendedChildCurrentDirectoryInode:
                        status.vst_ino,
                    descriptorJoinedToSuspendedChildCurrentDirectory:
                        true
                )
        }

        func readRegularFile(
            relativePath: String
        ) throws -> Data {
            guard !relativePath.isEmpty,
                  !relativePath.hasPrefix("/"),
                  !relativePath.contains("\0"),
                  !relativePath.contains("/")
            else {
                throw rejected(
                    "root_relative_file_path"
                )
            }
            let fileDescriptor =
                openat(
                    descriptor,
                    relativePath,
                    O_RDONLY
                        | O_NOFOLLOW
                        | O_CLOEXEC
                )
            guard fileDescriptor >= 0 else {
                throw rejected(
                    "root_relative_file_open_\(errno)"
                )
            }
            defer {
                _ = Darwin.close(
                    fileDescriptor
                )
            }
            var before = stat()
            guard fstat(
                fileDescriptor,
                &before
            ) == 0,
            before.st_mode
                & mode_t(S_IFMT)
                == mode_t(S_IFREG),
            before.st_nlink == 1,
            before.st_size >= 0,
            before.st_size <= 8 * 1024 * 1024,
            fcntl(
                fileDescriptor,
                F_GETFD
            ) & FD_CLOEXEC != 0
            else {
                throw rejected(
                    "root_relative_file_descriptor"
                )
            }
            let data =
                try readExactDescriptor(
                    fileDescriptor,
                    byteCount:
                        UInt64(before.st_size)
                )
            var after = stat()
            guard fstat(
                fileDescriptor,
                &after
            ) == 0,
            sameRegularFileIdentity(
                before,
                after
            ),
            data.count == Int(after.st_size)
            else {
                throw rejected(
                    "root_relative_file_changed"
                )
            }
            return data
        }

        private func sameDirectoryIdentity(
            _ lhs: stat,
            _ rhs: stat
        ) -> Bool {
            lhs.st_dev == rhs.st_dev
                && lhs.st_ino == rhs.st_ino
                && lhs.st_uid == rhs.st_uid
                && lhs.st_gid == rhs.st_gid
                && lhs.st_mode == rhs.st_mode
                && lhs.st_nlink == rhs.st_nlink
                && lhs.st_mtimespec.tv_sec
                    == rhs.st_mtimespec.tv_sec
                && lhs.st_mtimespec.tv_nsec
                    == rhs.st_mtimespec.tv_nsec
                && lhs.st_ctimespec.tv_sec
                    == rhs.st_ctimespec.tv_sec
                && lhs.st_ctimespec.tv_nsec
                    == rhs.st_ctimespec.tv_nsec
        }
    }

    private final class HeldExecutable {
        let absolutePath: String
        private(set) var descriptor: Int32

        init(
            absolutePath: String
        ) throws {
            self.absolutePath = absolutePath
            descriptor = Darwin.open(
                absolutePath,
                O_RDONLY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
            )
            guard descriptor >= 0 else {
                throw rejected(
                    "executable_open_\(errno)"
                )
            }
        }

        func close() {
            guard descriptor >= 0 else {
                return
            }
            _ = Darwin.close(descriptor)
            descriptor = -1
        }

        func readStableCheckpoint(
            contract:
                PrimeNativeNeuralGateSourceExecutionBindingContract
        ) throws -> DescriptorReadCheckpoint {
            var before = stat()
            guard descriptor >= 0,
                  fstat(
                      descriptor,
                      &before
                  ) == 0
            else {
                throw rejected(
                    "executable_fstat"
                )
            }
            let closeOnExec =
                fcntl(
                    descriptor,
                    F_GETFD
                ) & FD_CLOEXEC != 0
            let expectedCount =
                contract
                .swiftPackageDescribeExpectedExecutableByteCount
            guard before.st_size >= 0,
                  UInt64(before.st_size)
                    == expectedCount
            else {
                throw rejected(
                    "executable_size"
                )
            }
            let data =
                try readExactDescriptor(
                    descriptor,
                    byteCount:
                        expectedCount
                )
            var after = stat()
            guard fstat(
                descriptor,
                &after
            ) == 0,
            sameRegularFileIdentity(
                before,
                after
            )
            else {
                throw rejected(
                    "executable_changed_during_read"
                )
            }
            let snapshot =
                PrimeNativeNeuralGateExecutableDescriptorSnapshot(
                    deviceID:
                        UInt64(
                            bitPattern:
                                Int64(
                                    after.st_dev
                                )
                        ),
                    inode:
                        UInt64(
                            after.st_ino
                        ),
                    byteCount:
                        UInt64(
                            after.st_size
                        ),
                    sha256:
                        PrimeSHA256.hexDigest(
                            of: data
                        ),
                    ownerUserID:
                        after.st_uid,
                    ownerGroupID:
                        after.st_gid,
                    permissionMode:
                        UInt16(
                            after.st_mode
                                & mode_t(
                                    0o7777
                                )
                        ),
                    linkCount:
                        UInt64(
                            after.st_nlink
                        ),
                    modificationTimeSeconds:
                        Int64(
                            after
                            .st_mtimespec.tv_sec
                        ),
                    modificationTimeNanoseconds:
                        Int64(
                            after
                            .st_mtimespec.tv_nsec
                        ),
                    statusChangeTimeSeconds:
                        Int64(
                            after
                            .st_ctimespec.tv_sec
                        ),
                    statusChangeTimeNanoseconds:
                        Int64(
                            after
                            .st_ctimespec.tv_nsec
                        ),
                    regularFile:
                        after.st_mode
                            & mode_t(S_IFMT)
                            == mode_t(S_IFREG),
                    openedWithNoSymbolicLinksInPath:
                        true,
                    closeOnExec:
                        closeOnExec
                )
            try snapshot.validate(
                against: contract
            )
            return DescriptorReadCheckpoint(
                snapshot: snapshot,
                data: data
            )
        }
    }

    private struct DescriptorReadCheckpoint {
        let snapshot:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot
        let data: Data
    }

    private final class RawPipe {
        private(set) var readDescriptor:
            Int32
        private(set) var writeDescriptor:
            Int32

        init() throws {
            var descriptors: [Int32] = [
                -1,
                -1,
            ]
            guard pipe(&descriptors) == 0 else {
                throw rejected(
                    "pipe_\(errno)"
                )
            }
            let normalizedRead =
                fcntl(
                    descriptors[0],
                    F_DUPFD_CLOEXEC,
                    3
                )
            guard normalizedRead >= 3 else {
                let failure = errno
                _ = Darwin.close(
                    descriptors[0]
                )
                _ = Darwin.close(
                    descriptors[1]
                )
                throw rejected(
                    "pipe_read_normalization_\(failure)"
                )
            }
            let normalizedWrite =
                fcntl(
                    descriptors[1],
                    F_DUPFD_CLOEXEC,
                    3
                )
            guard normalizedWrite >= 3,
                  normalizedWrite
                    != normalizedRead else {
                let failure = errno
                _ = Darwin.close(
                    normalizedRead
                )
                _ = Darwin.close(
                    descriptors[0]
                )
                _ = Darwin.close(
                    descriptors[1]
                )
                throw rejected(
                    "pipe_write_normalization_\(failure)"
                )
            }
            _ = Darwin.close(
                descriptors[0]
            )
            _ = Darwin.close(
                descriptors[1]
            )
            readDescriptor =
                normalizedRead
            writeDescriptor =
                normalizedWrite
            do {
                try setCloseOnExec(
                    readDescriptor
                )
                try setCloseOnExec(
                    writeDescriptor
                )
                try setNonBlocking(
                    readDescriptor
                )
            } catch {
                closeAll()
                throw error
            }
        }

        func takeReadEnd() -> Int32 {
            let result = readDescriptor
            readDescriptor = -1
            return result
        }

        func closeWriteEnd() {
            guard writeDescriptor >= 0 else {
                return
            }
            _ = Darwin.close(
                writeDescriptor
            )
            writeDescriptor = -1
        }

        func closeAll() {
            if readDescriptor >= 0 {
                _ = Darwin.close(
                    readDescriptor
                )
                readDescriptor = -1
            }
            closeWriteEnd()
        }

        private func setCloseOnExec(
            _ descriptor: Int32
        ) throws {
            let existing =
                fcntl(
                    descriptor,
                    F_GETFD
                )
            guard existing >= 0,
                  fcntl(
                      descriptor,
                      F_SETFD,
                      existing | FD_CLOEXEC
                  ) == 0
            else {
                throw rejected(
                    "pipe_cloexec_\(errno)"
                )
            }
        }

        private func setNonBlocking(
            _ descriptor: Int32
        ) throws {
            let existing =
                fcntl(
                    descriptor,
                    F_GETFL
                )
            guard existing >= 0,
                  fcntl(
                      descriptor,
                      F_SETFL,
                      existing | O_NONBLOCK
                  ) == 0
            else {
                throw rejected(
                    "pipe_nonblocking_\(errno)"
                )
            }
        }
    }

    final class RawBoundedDrain:
        @unchecked Sendable
    {
        private let descriptor: Int32
        private let maximumByteCount:
            UInt64
        private let chunkByteCount: Int
        private let lock = NSLock()
        private var data = Data()
        private var totalByteCount: UInt64 = 0
        private var overflowed = false
        private var workerFinished = false
        private var reachedEOF = false
        private var readErrorNumber: Int32 = 0
        private var stopRequested = false

        init(
            descriptor: Int32,
            maximumByteCount: UInt64,
            chunkByteCount: Int
        ) {
            self.descriptor = descriptor
            self.maximumByteCount =
                maximumByteCount
            self.chunkByteCount =
                chunkByteCount
            data.reserveCapacity(
                Int(
                    min(
                        maximumByteCount,
                        UInt64(
                            256 * 1024
                        )
                    )
                )
            )
        }

        func start(group: DispatchGroup) {
            group.enter()
            DispatchQueue.global(
                qos: .utility
            ).async {
                self.drain()
                group.leave()
            }
        }

        func requestStop() {
            lock.lock()
            stopRequested = true
            lock.unlock()
        }

        func snapshot() -> DrainSnapshot {
            lock.lock()
            defer {
                lock.unlock()
            }
            return DrainSnapshot(
                data: data,
                totalByteCount:
                    totalByteCount,
                overflowed: overflowed,
                workerFinished:
                    workerFinished,
                reachedEOF:
                    reachedEOF,
                readErrorNumber:
                    readErrorNumber
            )
        }

        private func drain() {
            defer {
                lock.lock()
                workerFinished = true
                lock.unlock()
                _ = Darwin.close(
                    descriptor
                )
            }
            var buffer = [UInt8](
                repeating: 0,
                count: chunkByteCount
            )
            while true {
                if shouldStop() {
                    return
                }
                let count =
                    buffer
                    .withUnsafeMutableBytes {
                        Darwin.read(
                            descriptor,
                            $0.baseAddress,
                            $0.count
                        )
                    }
                if count > 0 {
                    consume(
                        buffer[0 ..< count]
                    )
                    continue
                }
                if count == 0 {
                    lock.lock()
                    reachedEOF = true
                    lock.unlock()
                    return
                }
                let readErrno = errno
                if readErrno == EINTR {
                    continue
                }
                if readErrno == EAGAIN
                    || readErrno == EWOULDBLOCK
                {
                    var event =
                        pollfd(
                            fd: descriptor,
                            events:
                                Int16(
                                    POLLIN
                                    | POLLHUP
                                    | POLLERR
                                ),
                            revents: 0
                        )
                    let pollResult =
                        Darwin.poll(
                            &event,
                            1,
                            100
                        )
                    if pollResult < 0,
                       errno != EINTR
                    {
                        recordReadError(
                            errno
                        )
                        return
                    }
                    continue
                }
                recordReadError(
                    readErrno
                )
                return
            }
        }

        private func shouldStop() -> Bool {
            lock.lock()
            defer {
                lock.unlock()
            }
            return stopRequested
        }

        private func consume(
            _ bytes:
                ArraySlice<UInt8>
        ) {
            lock.lock()
            defer {
                lock.unlock()
            }
            let next =
                totalByteCount
                .addingReportingOverflow(
                    UInt64(bytes.count)
                )
            if next.overflow {
                totalByteCount =
                    UInt64.max
                overflowed = true
            } else {
                totalByteCount =
                    next.partialValue
                if totalByteCount
                    > maximumByteCount
                {
                    overflowed = true
                }
            }
            let remaining =
                maximumByteCount
                    > UInt64(data.count)
                ? maximumByteCount
                    - UInt64(data.count)
                : 0
            if remaining > 0 {
                data.append(
                    contentsOf:
                        bytes.prefix(
                            Int(remaining)
                        )
                )
            }
        }

        private func recordReadError(
            _ errorNumber: Int32
        ) {
            lock.lock()
            readErrorNumber =
                errorNumber
            lock.unlock()
        }
    }

    struct DrainSnapshot {
        let data: Data
        let totalByteCount: UInt64
        let overflowed: Bool
        let workerFinished: Bool
        let reachedEOF: Bool
        let readErrorNumber: Int32
    }

    private static func readExactDescriptor(
        _ descriptor: Int32,
        byteCount: UInt64
    ) throws -> Data {
        guard byteCount
                <= UInt64(Int.max) else {
            throw rejected(
                "descriptor_size"
            )
        }
        var result = Data()
        result.reserveCapacity(
            Int(byteCount)
        )
        var buffer = [UInt8](
            repeating: 0,
            count: ioChunkByteCount
        )
        var offset: UInt64 = 0
        while offset < byteCount {
            let remaining =
                byteCount - offset
            let requested =
                Int(
                    min(
                        UInt64(buffer.count),
                        remaining
                    )
                )
            let readCount =
                buffer
                .withUnsafeMutableBytes {
                    pread(
                        descriptor,
                        $0.baseAddress,
                        requested,
                        off_t(offset)
                    )
                }
            if readCount < 0,
               errno == EINTR
            {
                continue
            }
            guard readCount > 0 else {
                throw rejected(
                    "descriptor_read_\(errno)"
                )
            }
            result.append(
                contentsOf:
                    buffer[0 ..< readCount]
            )
            offset += UInt64(readCount)
        }
        var trailingByte: UInt8 = 0
        let trailingRead =
            withUnsafeMutablePointer(
                to: &trailingByte
            ) {
                pread(
                    descriptor,
                    $0,
                    1,
                    off_t(byteCount)
                )
            }
        guard trailingRead == 0,
              result.count
                == Int(byteCount)
        else {
            throw rejected(
                "descriptor_trailing_bytes"
            )
        }
        return result
    }

    private static func sameRegularFileIdentity(
        _ lhs: stat,
        _ rhs: stat
    ) -> Bool {
        lhs.st_dev == rhs.st_dev
            && lhs.st_ino == rhs.st_ino
            && lhs.st_size == rhs.st_size
            && lhs.st_uid == rhs.st_uid
            && lhs.st_gid == rhs.st_gid
            && lhs.st_mode == rhs.st_mode
            && lhs.st_nlink == rhs.st_nlink
            && lhs.st_mtimespec.tv_sec
                == rhs.st_mtimespec.tv_sec
            && lhs.st_mtimespec.tv_nsec
                == rhs.st_mtimespec.tv_nsec
            && lhs.st_ctimespec.tv_sec
                == rhs.st_ctimespec.tv_sec
            && lhs.st_ctimespec.tv_nsec
                == rhs.st_ctimespec.tv_nsec
    }
}
