// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts

/// Durable data only. Decoding does not restore build or inventory authority.
package struct PrimeValidationDriverV2BuildDurableBindingEnvelopeV1: Codable {
    package let schemaVersion: Int
    package let predecessorRawTerminalSHA256: String
    package let predecessorSupervisorPID: Int32
    package let receipt: PrimeValidationBuildReceiptV2
    package let toolchain: PrimeValidationToolchainAdmissionReceiptV2
    package let process: PrimeValidationDriverV2BuildProcessObservation
    package let artifacts: PrimeValidationDriverV2BuildArtifactsObservation

    package func validate(
        intent: PrimeValidationRunIntentV2,
        expectedSupervisorPID: Int32,
        expectedPredecessorRawTerminalSHA256: String
    ) throws {
        try PrimeValidationDriverV2Validation.requireSHA256(predecessorRawTerminalSHA256)
        guard schemaVersion == 1,
              predecessorSupervisorPID == expectedSupervisorPID,
              predecessorRawTerminalSHA256 == expectedPredecessorRawTerminalSHA256
        else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
        try toolchain.validate()
        try receipt.validate(against: intent)
        try Self.validateProcess(process, intent: intent, toolchain: toolchain,
                                 supervisorPID: expectedSupervisorPID)
        try Self.validateArtifacts(artifacts, intent: intent, process: process)
        let expected = try Self.makeReceipt(
            intent: intent, process: process, artifacts: artifacts,
            source: receipt.sourceSnapshotAfterBuild,
            lock: receipt.packageLockAfterBuild,
            supervisorPID: expectedSupervisorPID
        )
        guard receipt == expected else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
    }

    fileprivate static func validateProcess(
        _ p: PrimeValidationDriverV2BuildProcessObservation,
        intent: PrimeValidationRunIntentV2,
        toolchain: PrimeValidationToolchainAdmissionReceiptV2,
        supervisorPID: Int32
    ) throws {
        let logical = try PrimeValidationInvocationFactoryV2.build(intent: intent)
        guard toolchain.swiftExecutable.requestedAbsolutePath == intent.swiftExecutable.absolutePath,
              toolchain.swiftExecutable.content == intent.swiftExecutable.content,
              p.orderedEnvironment.allSatisfy({ $0.count == 2 }) else {
            throw PrimeValidationDriverV2Error.invalidBuildReceipt
        }
        let launch = PrimeValidationSwiftPackageAdmissionLaunchV2(
            role: .build, logicalInvocation: logical,
            physicalExecutable: .init(
                absolutePath: p.executableAbsolutePath,
                content: try content(p.executableByteCount, p.executableSHA256)),
            argumentZero: p.logicalArgumentZero,
            physicalArguments: p.arguments,
            orderedCompleteReplacementEnvironment: p.orderedEnvironment.map {
                .init(key: $0[0], value: $0[1])
            },
            physicalWorkingDirectoryAbsolutePath: p.workingDirectoryAbsolutePath
        )
        try launch.validate(intent: intent, toolchain: toolchain)
        let flags = UInt16(POSIX_SPAWN_START_SUSPENDED)
            | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
            | UInt16(POSIX_SPAWN_SETPGROUP)
            | UInt16(POSIX_SPAWN_SETSIGDEF)
            | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard supervisorPID > 0, p.processIdentifier > 0,
              p.processIdentifier != supervisorPID,
              p.sessionIdentifier == supervisorPID,
              p.parentProcessIdentifier == supervisorPID,
              p.processGroupIdentifier == p.processIdentifier,
              p.workingDirectoryDeviceID == intent.roots.repositoryRoot.deviceID,
              p.workingDirectoryInode == intent.roots.repositoryRoot.inode,
              p.executableDeviceID == toolchain.swiftPackageExecutable.deviceID,
              p.executableInode == toolchain.swiftPackageExecutable.inode,
              p.mappedImageJoined, p.exactSuspendedWorkingDirectoryJoin,
              p.appliedSpawnFlags == flags, p.spawnReturnCode == 0,
              p.deadlineStartedAtUptimeNanoseconds > 0,
              p.deadlineExpiresAtUptimeNanoseconds > p.deadlineStartedAtUptimeNanoseconds,
              p.deadlineExpiresAtUptimeNanoseconds - p.deadlineStartedAtUptimeNanoseconds
                == 900_000_000_000,
              p.spawnReturnedUptimeNanoseconds >= p.deadlineStartedAtUptimeNanoseconds,
              p.resumedAtUptimeNanoseconds >= p.spawnReturnedUptimeNanoseconds,
              p.deathObservedUptimeNanoseconds >= p.resumedAtUptimeNanoseconds,
              p.waitReturnedUptimeNanoseconds >= p.deathObservedUptimeNanoseconds,
              p.waitReturnedUptimeNanoseconds < p.deadlineExpiresAtUptimeNanoseconds,
              p.preReapProcessGroupMemberIdentifiers == [p.processIdentifier],
              p.requestedWaitProcessIdentifier == p.processIdentifier,
              p.returnedWaitProcessIdentifier == p.processIdentifier,
              p.exactReapCount == 1, !p.cleanupInitiated,
              p.waitOptions == 0, p.rawWaitStatus == 0,
              p.exitedNormally, p.exitStatus == 0,
              p.terminationSignal == 0, !p.coreDumped,
              p.processGroupEmptyAfterReap
        else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
        try validateStream(p.standardOutput)
        try validateStream(p.standardError)
        guard p.standardOutput.outputDeviceID == intent.roots.evidenceRoot.deviceID,
              p.standardError.outputDeviceID == intent.roots.evidenceRoot.deviceID,
              p.standardOutput.outputInode != p.standardError.outputInode
        else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
    }

    fileprivate static func validateStream(
        _ value: PrimeValidationDriverV2BuildStreamObservation
    ) throws {
        try PrimeValidationDriverV2Validation.requireSHA256(value.outputSHA256)
        guard value.reachedEOF, !value.overflowed, value.workerFinished,
              value.descriptorsClosed, value.readErrorNumber == 0,
              value.writeErrorNumber == 0, value.finalizationErrorNumber == 0,
              value.closeErrorNumber == 0, value.outputMetadataObserved,
              value.outputPermissionMode == 0o444,
              value.outputDeviceID > 0, value.outputInode > 0,
              value.totalByteCount == value.capturedByteCount,
              value.capturedByteCount == value.outputByteCount,
              value.outputByteCount <= 16 * 1024 * 1024,
              value.terminalReason == "end_of_file"
        else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
    }

    fileprivate static func validateArtifacts(
        _ value: PrimeValidationDriverV2BuildArtifactsObservation,
        intent: PrimeValidationRunIntentV2,
        process: PrimeValidationDriverV2BuildProcessObservation
    ) throws {
        let prefix = intent.roots.scratchRelativePath + "/arm64-apple-macosx/release/"
        guard value.testBundleRelativePath == prefix + "ErgenticsPrimePackageTests.xctest",
              value.capturedBundleRelativePath == "test-bundle",
              value.metallibRelativePath == intent.requiredPinnedMetallib.relativePath,
              value.metallibByteCount == intent.requiredPinnedMetallib.content.byteCount,
              value.metallibSHA256 == intent.requiredPinnedMetallib.content.sha256,
              value.capturedMetallib.relativePath == "default.metallib",
              value.capturedMetallib.byteCount == value.metallibByteCount,
              value.capturedMetallib.sha256 == value.metallibSHA256,
              value.capturedMetallib.purpose == .immutableData,
              value.exclusivePublicationObserved, value.durableSynchronizationObserved,
              value.sourceNamesAndDescriptorsRejoined,
              value.captureStartedAtUptimeNanoseconds >= process.waitReturnedUptimeNanoseconds,
              value.captureCompletedAtUptimeNanoseconds > value.captureStartedAtUptimeNanoseconds,
              value.captureCompletedAtUptimeNanoseconds < process.deadlineExpiresAtUptimeNanoseconds,
              value.artifactRootIdentity.deviceID == intent.roots.evidenceRoot.deviceID,
              value.artifactRootIdentity.inode > 0,
              value.artifactRootIdentity.ownerUserID == intent.roots.evidenceRoot.ownerUserID,
              value.artifactRootIdentity.actualMode == 0o700,
              value.artifactRootIdentity.linkCount > 0,
              !value.bundleEntries.isEmpty,
              value.bundleEntries.count <= 16_384,
              value.bundleEntries.map(\.relativePath)
                == value.bundleEntries.map(\.relativePath).sorted(),
              Set(value.bundleEntries.map(\.relativePath)).count == value.bundleEntries.count
        else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
        let tree = try bundle(value)
        try tree.validate()
        guard tree.entries.contains(where: {
            $0.relativePath == "Contents/MacOS/ErgenticsPrimePackageTests"
                && $0.kind == .executable
        }) else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
        var expectedBindings = [value.capturedMetallib]
        for entry in value.bundleEntries {
            let metadata = entry.sourceMetadata
            guard metadata.deviceID == intent.roots.workspaceRoot.deviceID,
                  metadata.inode > 0,
                  metadata.ownerUserID == intent.roots.workspaceRoot.ownerUserID,
                  metadata.linkCount > 0,
                  metadata.mode & 0o022 == 0
            else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
            if entry.kind == "directory" {
                guard entry.mode == 0o700,
                      metadata.mode & UInt32(S_IFMT) == UInt32(S_IFDIR)
                else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
            } else {
                guard let count = entry.byteCount, let hash = entry.sha256,
                      count > 0, count <= 1 << 30,
                      metadata.byteCount >= 0, UInt64(metadata.byteCount) == count,
                      metadata.linkCount == 1,
                      metadata.mode & UInt32(S_IFMT) == UInt32(S_IFREG),
                      entry.mode == (entry.kind == "executable" ? 0o555 : 0o444)
                else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
                expectedBindings.append(.init(
                    relativePath: "test-bundle/" + entry.relativePath,
                    sha256: hash, byteCount: count,
                    purpose: entry.kind == "executable" ? .executable : .immutableData
                ))
            }
        }
        guard value.immutableArtifactBindings
                == expectedBindings.sorted(by: { $0.relativePath < $1.relativePath }),
              tree.aggregateFileByteCount <= 8 << 30
        else { throw PrimeValidationDriverV2Error.invalidBuildReceipt }
    }

    fileprivate static func makeReceipt(
        intent: PrimeValidationRunIntentV2,
        process p: PrimeValidationDriverV2BuildProcessObservation,
        artifacts: PrimeValidationDriverV2BuildArtifactsObservation,
        source: PrimeValidationContentBinding,
        lock: PrimeValidationContentBinding,
        supervisorPID: Int32
    ) throws -> PrimeValidationBuildReceiptV2 {
        let invocation = try PrimeValidationInvocationFactoryV2.build(intent: intent)
        let active = artifacts.captureCompletedAtUptimeNanoseconds
            - p.deadlineStartedAtUptimeNanoseconds
        func stream(_ value: PrimeValidationDriverV2BuildStreamObservation)
            -> PrimeValidationStreamAuditV2 {
            .init(eofObserved: value.reachedEOF,
                  totalByteCount: value.totalByteCount, capturedByteCount: value.capturedByteCount,
                  overflowObserved: value.overflowed,
                  readErrorNumber: value.readErrorNumber, writeErrorNumber: value.writeErrorNumber)
        }
        let audit = PrimeValidationProcessAuditV2(
            processIdentifier: p.processIdentifier, sessionIdentifier: p.sessionIdentifier,
            processGroupIdentifier: p.processGroupIdentifier, deadlineDisposition: .completed,
            sigtermDelivery: .notAttempted, sigkillDelivery: .notAttempted,
            preReapProcessGroupMembers: p.preReapProcessGroupMemberIdentifiers,
            exactReturnedProcessIdentifier: p.returnedWaitProcessIdentifier,
            rawWaitStatus: p.rawWaitStatus, waitTermination: .exited(p.exitStatus),
            processGroupEmptyAfterReap: p.processGroupEmptyAfterReap,
            standardOutput: stream(p.standardOutput), standardError: stream(p.standardError),
            matchedTestCount: 0, supervisorSessionIdentifier: supervisorPID
        )
        let child = PrimeValidationObservedChildReceiptV2(
            invocation: invocation, primaryResult: .none,
            standardOutputArtifact: .init(
                name: "standard_output", relativePath: invocation.standardOutputRelativePath,
                content: try content(p.standardOutput.outputByteCount, p.standardOutput.outputSHA256)),
            standardErrorArtifact: .init(
                name: "standard_error", relativePath: invocation.standardErrorRelativePath,
                content: try content(p.standardError.outputByteCount, p.standardError.outputSHA256)),
            process: audit, activeNanoseconds: active
        )
        return .init(
            runID: intent.runID, intentSHA256: try intent.identitySHA256(),
            invocation: invocation, observedChild: child,
            sourceSnapshotAfterBuild: source, packageLockAfterBuild: lock,
            pinnedMetallibAfterBuild: .init(
                relativePath: artifacts.metallibRelativePath,
                content: try content(artifacts.metallibByteCount, artifacts.metallibSHA256)),
            testBundle: try bundle(artifacts), activeNanoseconds: active
        )
    }

    private static func bundle(_ value: PrimeValidationDriverV2BuildArtifactsObservation)
        throws -> PrimeValidationBundleTreeBindingV2 {
        try .make(entries: value.bundleEntries.map { entry in
            guard let kind = PrimeValidationBundleTreeNodeKindV2(rawValue: entry.kind) else {
                throw PrimeValidationDriverV2Error.invalidBuildReceipt
            }
            let binding: PrimeValidationContentBinding?
            if kind == .directory {
                guard entry.byteCount == nil, entry.sha256 == nil else {
                    throw PrimeValidationDriverV2Error.invalidBuildReceipt
                }
                binding = nil
            } else {
                guard let count = entry.byteCount, let hash = entry.sha256 else {
                    throw PrimeValidationDriverV2Error.invalidBuildReceipt
                }
                binding = try content(count, hash)
            }
            return .init(relativePath: entry.relativePath, kind: kind, mode: entry.mode, content: binding)
        })
    }

    fileprivate static func content(_ count: UInt64, _ hash: String)
        throws -> PrimeValidationContentBinding {
        struct Fields: Encodable { let byteCount: UInt64; let sha256: String }
        let result = try PrimeCanonicalJSON.decode(
            PrimeValidationContentBinding.self,
            from: PrimeCanonicalJSON.encode(Fields(byteCount: count, sha256: hash)))
        try result.validate()
        return result
    }
}

/// Retains the one-shot native lifetime; the durable envelope carries no owner.
package final class PrimeValidationDriverV2BuildBinding: @unchecked Sendable {
    package let envelope: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1
    private let lifetime: PrimeValidationDriverV2BuildBoundLifetime

    package init(
        raw: PrimeValidationDriverV2BuildRawCapability,
        intent: PrimeValidationRunIntentV2,
        predecessorSupervisorPID: Int32,
        predecessorRawTerminalSHA256: String,
        partialToolchain: PrimeValidationDriverV2PartialToolchainProbeBinding
    ) throws {
        var transferred = false
        defer { if !transferred { raw.rejectValidatedBindingLifetime() } }
        let observation = raw.observation
        let toolchain = try partialToolchain.completeToolchain(buildObservation: observation)
        typealias Envelope = PrimeValidationDriverV2BuildDurableBindingEnvelopeV1
        try Envelope.validateProcess(observation.process, intent: intent,
                                     toolchain: toolchain, supervisorPID: predecessorSupervisorPID)
        try Envelope.validateArtifacts(observation.artifacts, intent: intent, process: observation.process)
        let receipt = try Envelope.makeReceipt(
            intent: intent, process: observation.process, artifacts: observation.artifacts,
            source: .init(data: observation.sourceSnapshot),
            lock: Envelope.content(observation.packageResolvedBinding.byteCount,
                                   observation.packageResolvedBinding.sha256),
            supervisorPID: predecessorSupervisorPID)
        let envelope = Envelope(
            schemaVersion: 1, predecessorRawTerminalSHA256: predecessorRawTerminalSHA256,
            predecessorSupervisorPID: predecessorSupervisorPID,
            receipt: receipt, toolchain: toolchain,
            process: observation.process, artifacts: observation.artifacts)
        try envelope.validate(intent: intent, expectedSupervisorPID: predecessorSupervisorPID,
                              expectedPredecessorRawTerminalSHA256: predecessorRawTerminalSHA256)
        let bytes = try PrimeCanonicalJSON.encode(envelope)
        self.envelope = envelope
        lifetime = try raw.consumeValidatedBindingLifetime(bindingData: bytes)
        transferred = true
    }

    package func revalidate() throws { try lifetime.revalidateContinuity() }
}
