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
                "PrimeSecureChildLifecycle.swift",
            "Sources/PrimeCore/" +
                "PrimeNativeNeuralGateSecureScratchNamespace.swift",
            "Sources/PrimeCore/" +
                "PrimeSecureChildDarwinSubstrate.swift",
            "Sources/PrimeCore/" +
                "PrimeSecureChildDarwinProcessProof.swift",
            "Sources/PrimeCore/" +
                "PrimeSecureChildDeadline.swift",
            "Sources/PrimeCore/" +
                "PrimeSecureChildDrains.swift",
            "Sources/PrimeCore/" +
                "PrimeSecureChildSupervision.swift",
        ]
    private static let regionQueryLimit = 65_536
    private static let ioChunkByteCount = 64 * 1024
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
            .frozenV6
        try contract.validate()
        try requireCalibratedDarwinConstants()
        guard ioChunkByteCount > 0 else {
            throw rejected(
                "stream_chunk_configuration"
            )
        }

        let root = try HeldPrimeSourceRoot(
            sourceRoot: sourceRoot
        )
        defer {
            root.close()
        }
        let heldWorkingDirectory:
            PrimeSecureChildDarwinProcessProof
            .HeldDirectorySnapshot
        do {
            heldWorkingDirectory =
                try PrimeSecureChildDarwinProcessProof
                .snapshotHeldDirectory(
                    descriptor: root.descriptor,
                    openedWithNoSymbolicLinksInPath:
                        true,
                    context: .neuralSourceRoot
                )
        } catch let error as
            PrimeSecureChildDarwinProcessProof.Rejection
        {
            throw rejected(error.detail)
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
        let phaseDeadline =
            try phaseDeadline(
                start:
                    descriptorOpenedMonotonicNanoseconds,
                maximumSeconds:
                    contract
                    .swiftPackageDescribeMaximumWallSeconds
            )
        let preSpawnRead =
            try executable.readStableCheckpoint(
                contract: contract
            )
        guard try phaseDeadline.authorizesNewWork(
            observedAtUptimeNanoseconds:
                monotonicNanoseconds(),
            notBeforeUptimeNanoseconds:
                descriptorOpenedMonotonicNanoseconds
        ) else {
            throw rejected(
                "wall_deadline_before_spawn"
            )
        }

        let supervision:
            PrimeSecureChildSupervisionCapability
        do {
            let spawn = try spawnSuspendedSecureChild(
                executableAbsolutePath:
                    executableAbsolutePath,
                argumentZero:
                    executableAbsolutePath,
                workingDirectoryDescriptor:
                    root.descriptor,
                exactArguments:
                    scratchLaunch
                    .arguments,
                orderedEnvironment:
                    scratchLaunch
                    .orderedEnvironment
            )
            supervision =
                PrimeSecureChildSupervisionCapability
                .adoptMemory(
                    spawn: spawn,
                    phaseDeadline:
                        phaseDeadline,
                    standardOutputMaximumByteCount:
                        contract
                        .swiftPackageDescribeMaximumStandardOutputBytes,
                    standardErrorMaximumByteCount:
                        contract
                        .swiftPackageDescribeMaximumStandardErrorBytes,
                    chunkByteCount:
                        ioChunkByteCount
                )
        } catch {
            throw error
        }

        do {
            guard supervision
                .establishIsolatedSessionAndDedicatedGroup()
            else {
                throw rejected(
                    "child_session_or_process_group"
                )
            }
            let childSessionAndProcessGroupObservedMonotonicNanoseconds =
                monotonicNanoseconds()
            let workingDirectoryObservation =
                try suspendedWorkingDirectoryObservation(
                    processIdentifier:
                        supervision
                        .processIdentifier,
                    heldDirectory:
                        heldWorkingDirectory
                )
            let workingDirectoryCapturedMonotonicNanoseconds =
                monotonicNanoseconds()

            let mappedTranscript =
                try mappedExecutableTranscript(
                    processIdentifier:
                        supervision
                        .processIdentifier,
                    executableSnapshot:
                        preSpawnRead.snapshot,
                    expectedExecutableAbsolutePath:
                        executableAbsolutePath
                )
            let mappedRegionCapturedMonotonicNanoseconds =
                monotonicNanoseconds()

            let processPathTelemetry =
                captureProcessPathTelemetry(
                    processIdentifier:
                        supervision
                        .processIdentifier
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
            guard try phaseDeadline.authorizesNewWork(
                observedAtUptimeNanoseconds:
                    monotonicNanoseconds(),
                notBeforeUptimeNanoseconds:
                    descriptorRevalidatedBeforeResumeMonotonicNanoseconds
            )
            else {
                throw rejected(
                    "wall_deadline_before_resume"
                )
            }

            let resumeDisposition:
                PrimeSecureChildResumeDisposition
            do {
                resumeDisposition =
                    try supervision.resume(
                        notBeforeUptimeNanoseconds:
                            scratchPreResumeValidationMonotonicNanoseconds
                    )
            } catch {
                throw rejected(
                    "wall_deadline_before_resume"
                )
            }
            let sigcontDeliveredMonotonicNanoseconds:
                UInt64
            switch resumeDisposition {
            case let .resumed(deliveredAt):
                sigcontDeliveredMonotonicNanoseconds =
                    deliveredAt
            case .deadlineExpired:
                throw rejected(
                    "wall_deadline_before_resume"
                )
            case let .signalFailed(errorNumber):
                throw rejected(
                    "sigcont_\(errorNumber)"
                )
            case .stateRejected:
                throw rejected(
                    "child_resume_state"
                )
            }
            let sigcontResult: Int32 = 0

            let deathObservation:
                PrimeSecureChildDeathObservationDisposition
            do {
                deathObservation =
                    try supervision.observeDeath()
            } catch {
                throw rejected(
                    "wall_deadline_authority"
                )
            }
            switch deathObservation {
            case .observed:
                break
            case .deadlineExpired:
                throw rejected("wall_deadline")
            case .stateRejected:
                throw rejected(
                    "child_death_observation_state"
                )
            }
            guard let childTerminationObservedMonotonicNanoseconds =
                    supervision
                    .deathObservedMonotonicNanoseconds()
            else {
                throw rejected(
                    "child_death_observation"
                )
            }
            guard try phaseDeadline.acceptsCompletion(
                observedAtUptimeNanoseconds:
                    childTerminationObservedMonotonicNanoseconds,
                notBeforeUptimeNanoseconds:
                    sigcontDeliveredMonotonicNanoseconds
            )
            else {
                throw rejected("wall_deadline")
            }
            let drainEvidence:
                PrimeSecureChildDrainEvidence
            let phaseDrainDisposition:
                PrimeSecureChildPhaseDrainDisposition
            do {
                phaseDrainDisposition =
                    try supervision
                    .waitForPhaseDrainCompletion(
                        notBeforeUptimeNanoseconds:
                            childTerminationObservedMonotonicNanoseconds
                    )
            } catch {
                throw rejected(
                    "stream_deadline_authority"
                )
            }
            switch phaseDrainDisposition {
            case let .completed(evidence):
                drainEvidence = evidence
            case .deadlineExpired:
                throw rejected("stream_deadline")
            case .stateRejected:
                throw rejected(
                    "stream_capture_state"
                )
            }

            guard let preReapProcessGroupMemberIdentifiers =
                    supervision
                    .processGroupMemberIdentifiers(),
                  preReapProcessGroupMemberIdentifiers
                    == [
                        supervision
                        .processIdentifier,
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
            switch supervision
                .reapAfterObservedDeath()
            {
            case let .reaped(observation):
                wait =
                    PrimeNativeNeuralGateExactPIDWaitObservation(
                        secureChildObservation:
                            observation
                    )
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

            let stdout: DrainSnapshot
            let stderr: DrainSnapshot
            switch drainEvidence {
            case let .memory(
                standardOutput,
                standardError
            ):
                stdout = standardOutput
                stderr = standardError
            case .fileBacked:
                failStop(
                    .invalidLifecycleTransition
                )
            }
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
            guard try phaseDeadline.acceptsCompletion(
                observedAtUptimeNanoseconds:
                    descriptorRevalidatedAfterReapMonotonicNanoseconds,
                notBeforeUptimeNanoseconds:
                    childReapedMonotonicNanoseconds
            )
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
                  try phaseDeadline.acceptsCompletion(
                      observedAtUptimeNanoseconds:
                          sourcePostReapValidationMonotonicNanoseconds,
                      notBeforeUptimeNanoseconds:
                          descriptorRevalidatedAfterReapMonotonicNanoseconds
                  )
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
                        phaseDeadline
                        .expiresAtUptimeNanoseconds
                )
            guard sourcePostReapValidationMonotonicNanoseconds
                    <= scratchPostReapValidationMonotonicNanoseconds,
                  try phaseDeadline.acceptsCompletion(
                      observedAtUptimeNanoseconds:
                          scratchPostReapValidationMonotonicNanoseconds,
                      notBeforeUptimeNanoseconds:
                          sourcePostReapValidationMonotonicNanoseconds
                  )
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
                        supervision
                        .processIdentifier,
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
                        supervision.appliedFlags,
                    observedChildSessionIdentifier:
                        supervision
                        .processIdentifier,
                    observedChildProcessGroupIdentifier:
                        supervision
                        .processIdentifier,
                    emptySignalMaskConfigured:
                        true,
                    defaultSignalDispositionsConfigured:
                        true,
                    terminationSignalsTargetProcessGroup:
                        true,
                    posixSpawnReturnCode:
                        supervision.spawnReturnCode,
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
                        supervision
                        .spawnReturnedMonotonicNanoseconds,
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
                    supervision
                    .processIdentifier
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
                        supervision
                        .processIdentifier,
                    scratchNamespace:
                        scratchNamespace
                )
        } catch {
            switch supervision
                .cleanupRejectedCapture()
            {
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

    private static func phaseDeadline(
        start: UInt64,
        maximumSeconds: UInt64
    ) throws -> PrimeSecureChildPhaseDeadline {
        do {
            return try PrimeSecureChildPhaseDeadline(
                startUptimeNanoseconds: start,
                durationSeconds: maximumSeconds
            )
        } catch {
            throw rejected("deadline_overflow")
        }
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

    /// Narrow PrimeCore-internal adapter over the frozen neural capture's
    /// closed authority and the neutral Darwin spawn substrate. The caller
    /// must already hold and admit the executable and working-directory
    /// capabilities; this adapter adds no public command surface.
    @available(macOS 26.0, *)
    static func spawnSuspendedSecureChild(
        executableAbsolutePath: String,
        argumentZero: String,
        workingDirectoryDescriptor: Int32,
        exactArguments: [String],
        orderedEnvironment: [(String, String)]
    ) throws -> PrimeSecureChildSpawnHandle {
        do {
            return try PrimeSecureChildDarwinSubstrate
                .spawnSuspended(
                executableAbsolutePath:
                    executableAbsolutePath,
                argumentZero: argumentZero,
                workingDirectoryDescriptor:
                    workingDirectoryDescriptor,
                exactArguments: exactArguments,
                orderedEnvironment:
                    orderedEnvironment
            )
        } catch let error as
            PrimeSecureChildDarwinSubstrate.Rejection
        {
            throw rejected(error.detail)
        }
    }

    /// Validates only the C `argv[0]` transport invariant. Closed callers
    /// remain responsible for selecting the exact logical personality; this
    /// primitive cannot turn an arbitrary string into execution authority.
    static func requireSecureChildArgumentZero(
        _ argumentZero: String
    ) throws {
        do {
            try PrimeSecureChildDarwinSubstrate
                .requireArgumentZero(argumentZero)
        } catch let error as
            PrimeSecureChildDarwinSubstrate.Rejection
        {
            throw rejected(error.detail)
        }
    }

    private static func suspendedWorkingDirectoryObservation(
        processIdentifier: Int32,
        heldDirectory:
            PrimeSecureChildDarwinProcessProof
            .HeldDirectorySnapshot
    ) throws
        -> PrimeNativeNeuralGateWorkingDirectoryObservation
    {
        do {
            let proof =
                try PrimeSecureChildDarwinProcessProof
                .captureSuspendedWorkingDirectory(
                    processIdentifier:
                        processIdentifier,
                    heldDirectory: heldDirectory
                )
            return PrimeNativeNeuralGateWorkingDirectoryObservation(
                descriptorDeviceID:
                    proof.descriptorDeviceID,
                descriptorInode:
                    proof.descriptorInode,
                descriptorOwnerUserID:
                    proof.descriptorOwnerUserID,
                descriptorOwnerGroupID:
                    proof.descriptorOwnerGroupID,
                descriptorPermissionMode:
                    proof.descriptorPermissionMode,
                descriptorLinkCount:
                    proof.descriptorLinkCount,
                descriptorIsDirectory:
                    proof.descriptorIsDirectory,
                descriptorOpenedWithNoSymbolicLinksInPath:
                    proof
                    .descriptorOpenedWithNoSymbolicLinksInPath,
                descriptorCloseOnExec:
                    proof.descriptorCloseOnExec,
                procPIDVnodePathInfoFlavor:
                    proof.procPIDVnodePathInfoFlavor,
                procVnodePathInfoByteCount:
                    proof.procVnodePathInfoByteCount,
                suspendedChildCurrentDirectoryDeviceID:
                    proof
                    .suspendedChildCurrentDirectoryDeviceID,
                suspendedChildCurrentDirectoryInode:
                    proof
                    .suspendedChildCurrentDirectoryInode,
                descriptorJoinedToSuspendedChildCurrentDirectory:
                    proof.exactDescriptorJoinObserved
            )
        } catch let error as
            PrimeSecureChildDarwinProcessProof.Rejection
        {
            throw rejected(error.detail)
        }
    }

    private static func mappedExecutableTranscript(
        processIdentifier: Int32,
        executableSnapshot:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        expectedExecutableAbsolutePath: String
    ) throws -> MappedRegionTranscript {
        do {
            let proof =
                try PrimeSecureChildDarwinProcessProof
                .captureMappedExecutable(
                    processIdentifier:
                        processIdentifier,
                    heldExecutable:
                        .init(
                            deviceID:
                                executableSnapshot
                                .deviceID,
                            inode:
                                executableSnapshot.inode,
                            expectedCanonicalAbsolutePath:
                                expectedExecutableAbsolutePath
                        )
                )
            return MappedRegionTranscript(
                queries: proof.queries.map {
                    PrimeNativeNeuralGateMappedRegionQueryObservation(
                        queryAddress:
                            $0.queryAddress,
                        returnedByteCount:
                            $0.returnedByteCount,
                        region:
                            PrimeNativeNeuralGateMappedExecutableRegionObservation(
                                address:
                                    $0.region.address,
                                byteCount:
                                    $0.region.byteCount,
                                fileOffset:
                                    $0.region.fileOffset,
                                protection:
                                    $0.region.protection,
                                deviceID:
                                    $0.region.deviceID,
                                inode:
                                    $0.region.inode
                            )
                    )
                },
                terminalQueryAddress:
                    proof.terminalQueryAddress,
                terminalReturnByteCount:
                    proof.terminalReturnByteCount,
                terminalErrno:
                    proof.terminalErrno,
                mappedExecutablePathTelemetry:
                    proof
                    .mappedExecutablePathTelemetry
            )
        } catch let error as
            PrimeSecureChildDarwinProcessProof.Rejection
        {
            throw rejected(error.detail)
        }
    }

    static func evaluateMappedRegionTranscript(
        executableSnapshot:
            PrimeNativeNeuralGateExecutableDescriptorSnapshot,
        contract:
            PrimeNativeNeuralGateSourceExecutionBindingContract,
        queryLimit: Int,
        expectedExecutableAbsolutePath:
            String? = nil,
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
                        == (expectedExecutableAbsolutePath
                            ?? executableAbsolutePath),
                      (try? PrimeSecureChildPath
                          .canonicalPath(mappedPath))
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

    static func rejectedDrainDisposition(
        stdout: DrainSnapshot,
        stderr: DrainSnapshot
    ) -> PrimeSecureChildCleanupDisposition {
        PrimeSecureChildSupervisionCapability
            .memoryDrainContainmentDisposition(
                standardOutput: stdout,
                standardError: stderr
            )
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

    typealias RawBoundedDrain =
        PrimeSecureChildMemoryBoundedDrain
    typealias DrainSnapshot =
        PrimeSecureChildMemoryDrainSnapshot

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
