// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts

/// Durable data only. Decoding never creates process or inventory authority.
package struct PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1: Codable {
    package let schemaVersion: Int
    package let predecessorBuildBinding: PrimeArtifactBinding
    package let predecessorSupervisorPID: Int32
    package let children: [PrimeValidationDriverV2InventoryChildObservation]
    package let terminalBinding: PrimeArtifactBinding
    package let receipt: PrimeValidationInventoryReceiptV2

    package func validate(
        intent: PrimeValidationRunIntentV2,
        expectedSupervisorPID: Int32,
        build: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1,
        expectedBuildBinding: PrimeArtifactBinding
    ) throws {
        try build.validate(intent: intent, expectedSupervisorPID: expectedSupervisorPID,
            expectedPredecessorRawTerminalSHA256: build.predecessorRawTerminalSHA256)
        let buildData = try PrimeCanonicalJSON.encode(build)
        guard schemaVersion == 1, predecessorSupervisorPID == expectedSupervisorPID,
              predecessorBuildBinding == expectedBuildBinding else { throw rejected }
        try Self.validateArtifact(predecessorBuildBinding, path: "binding.json", data: buildData)
        try Self.validateChildren(children, intent: intent, build: build,
                                  supervisorPID: expectedSupervisorPID)
        let expected = try Self.makeReceipt(intent: intent, build: build.receipt,
            children: children, xctestData: receipt.xctestListData,
            swiftTestingData: receipt.swiftTestingListData, supervisorPID: expectedSupervisorPID)
        guard receipt == expected else { throw rejected }
        try receipt.validate(intent: intent, buildReceipt: build.receipt)
        try Self.validateJournalBinding(terminalBinding, path: "terminal.json",
            type: PrimeValidationDriverV2InventorySequenceTerminalV1.self, object: [
            "schema": "prime_driver_v2_gate_g_inventory_terminal_v1",
            "runID": intent.runID,
            "predecessorBuildBindingSHA256": predecessorBuildBinding.sha256,
            "orderedChildTerminalSHA256Values": children.map { $0.terminalBinding.sha256 },
        ])
    }

    private var rejected: PrimeValidationDriverV2Error { .invalidInventoryReceipt }

    private static func validateChildren(
        _ children: [PrimeValidationDriverV2InventoryChildObservation],
        intent: PrimeValidationRunIntentV2,
        build: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1,
        supervisorPID: Int32
    ) throws {
        let invocations = try PrimeValidationInvocationFactoryV2.inventory(intent: intent)
        guard children.count == 2,
              children.map(\.role) == ["list_xctest", "list_swift_testing"],
              Set(children.map { $0.process.processIdentifier }).count == 2,
              children.allSatisfy({ $0.process.processIdentifier != build.process.processIdentifier })
        else { throw PrimeValidationDriverV2Error.invalidInventoryReceipt }
        let first = children[0].process
        guard first.deadlineStartedAtUptimeNanoseconds >= build.artifacts.captureCompletedAtUptimeNanoseconds,
              first.deadlineStartedAtUptimeNanoseconds < build.process.deadlineExpiresAtUptimeNanoseconds,
              children[1].process.deadlineStartedAtUptimeNanoseconds == first.deadlineStartedAtUptimeNanoseconds,
              children[1].process.deadlineExpiresAtUptimeNanoseconds == first.deadlineExpiresAtUptimeNanoseconds,
              children[1].process.spawnReturnedUptimeNanoseconds >= first.waitReturnedUptimeNanoseconds
        else { throw PrimeValidationDriverV2Error.invalidInventoryReceipt }
        let streams = children.flatMap { [$0.process.standardOutput, $0.process.standardError] }
        let keys = streams.map { "\($0.outputDeviceID):\($0.outputInode)" }
        let previousKeys = [build.process.standardOutput, build.process.standardError].map {
            "\($0.outputDeviceID):\($0.outputInode)"
        }
        guard Set(keys).count == 4, Set(keys).isDisjoint(with: previousKeys) else {
            throw PrimeValidationDriverV2Error.invalidInventoryReceipt
        }
        var predecessorHash = PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(build))
        for (index, child) in children.enumerated() {
            let p = child.process
            try validateNativeProcess(p, supervisorPID: supervisorPID)
            guard p.workingDirectoryDeviceID == intent.roots.repositoryRoot.deviceID,
                  p.workingDirectoryInode == intent.roots.repositoryRoot.inode,
                  p.executableDeviceID == build.toolchain.swiftPackageExecutable.deviceID,
                  p.executableInode == build.toolchain.swiftPackageExecutable.inode,
                  p.standardOutput.outputDeviceID == intent.roots.evidenceRoot.deviceID,
                  p.standardError.outputDeviceID == intent.roots.evidenceRoot.deviceID,
                  p.orderedEnvironment.allSatisfy({ $0.count == 2 }) else {
                throw PrimeValidationDriverV2Error.invalidInventoryReceipt
            }
            let logical = invocations[index]
            let launch = PrimeValidationSwiftPackageAdmissionLaunchV2(
                role: logical.role, logicalInvocation: logical,
                physicalExecutable: .init(absolutePath: p.executableAbsolutePath,
                    content: try content(p.executableByteCount, p.executableSHA256)),
                argumentZero: p.logicalArgumentZero, physicalArguments: p.arguments,
                orderedCompleteReplacementEnvironment: p.orderedEnvironment.map {
                    .init(key: $0[0], value: $0[1])
                }, physicalWorkingDirectoryAbsolutePath: p.workingDirectoryAbsolutePath)
            try launch.validate(intent: intent, toolchain: build.toolchain)
            let prefix = index == 0 ? "01-xctest" : "02-swift-testing"
            let streamPrefix = index == 0 ? "xctest-list" : "swift-testing-list"
            try validateStreamBinding(child.standardOutputBinding,
                stream: p.standardOutput, path: streamPrefix + ".stdout.log")
            try validateStreamBinding(child.standardErrorBinding,
                stream: p.standardError, path: streamPrefix + ".stderr.log")
            try validateJournalBinding(child.prestartBinding, path: prefix + "-prestart.json",
                type: PrimeValidationDriverV2InventoryPrestartV1.self, object: [
                "schema": "prime_driver_v2_gate_g_inventory_prestart_v1", "runID": intent.runID,
                "ordinal": index + 1, "role": child.role, "predecessorSHA256": predecessorHash,
                "deadlineStartedAtUptimeNanoseconds": p.deadlineStartedAtUptimeNanoseconds,
                "deadlineExpiresAtUptimeNanoseconds": p.deadlineExpiresAtUptimeNanoseconds,
                "executableAbsolutePath": p.executableAbsolutePath, "executableSHA256": p.executableSHA256,
                "logicalArgumentZero": p.logicalArgumentZero, "arguments": p.arguments,
                "orderedEnvironment": p.orderedEnvironment,
                "workingDirectoryAbsolutePath": p.workingDirectoryAbsolutePath,
            ])
            try validateJournalBinding(child.startBinding, path: prefix + "-start.json",
                type: PrimeValidationDriverV2InventoryStartV1.self, object: [
                "schema": "prime_driver_v2_gate_g_inventory_start_v1", "role": child.role,
                "prestartSHA256": child.prestartBinding.sha256,
                "processIdentifier": p.processIdentifier, "sessionIdentifier": p.sessionIdentifier,
                "processGroupIdentifier": p.processGroupIdentifier, "appliedSpawnFlags": p.appliedSpawnFlags,
                "spawnReturnedUptimeNanoseconds": p.spawnReturnedUptimeNanoseconds,
                "mappedExecutablePathTelemetry": p.executableAbsolutePath,
                "exactSuspendedWorkingDirectoryJoin": p.exactSuspendedWorkingDirectoryJoin,
            ])
            try validateJournalBinding(child.terminalBinding, path: prefix + "-terminal.json",
                type: PrimeValidationDriverV2InventoryTerminalV1.self, object: [
                "schema": "prime_driver_v2_gate_g_inventory_child_terminal_v1", "role": child.role,
                "startSHA256": child.startBinding.sha256,
                "process": JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(p)),
            ])
            predecessorHash = child.terminalBinding.sha256
        }
    }

    /// Shared native lifecycle checks; pure validation of recorded facts only.
    static func validateNativeProcess(
        _ p: PrimeValidationDriverV2BuildProcessObservation, supervisorPID: Int32
    ) throws {
        let flags = UInt16(POSIX_SPAWN_START_SUSPENDED) | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
            | UInt16(POSIX_SPAWN_SETPGROUP) | UInt16(POSIX_SPAWN_SETSIGDEF) | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard supervisorPID > 0, p.processIdentifier > 0, p.processIdentifier != supervisorPID,
              p.sessionIdentifier == supervisorPID, p.parentProcessIdentifier == supervisorPID,
              p.processGroupIdentifier == p.processIdentifier,
              p.mappedImageJoined, p.exactSuspendedWorkingDirectoryJoin,
              p.appliedSpawnFlags == flags, p.spawnReturnCode == 0,
              p.deadlineStartedAtUptimeNanoseconds > 0,
              p.deadlineExpiresAtUptimeNanoseconds > p.deadlineStartedAtUptimeNanoseconds,
              p.deadlineExpiresAtUptimeNanoseconds - p.deadlineStartedAtUptimeNanoseconds == 300_000_000_000,
              p.spawnReturnedUptimeNanoseconds >= p.deadlineStartedAtUptimeNanoseconds,
              p.resumedAtUptimeNanoseconds >= p.spawnReturnedUptimeNanoseconds,
              p.deathObservedUptimeNanoseconds >= p.resumedAtUptimeNanoseconds,
              p.waitReturnedUptimeNanoseconds >= p.deathObservedUptimeNanoseconds,
              p.waitReturnedUptimeNanoseconds < p.deadlineExpiresAtUptimeNanoseconds,
              p.preReapProcessGroupMemberIdentifiers == [p.processIdentifier],
              p.requestedWaitProcessIdentifier == p.processIdentifier,
              p.returnedWaitProcessIdentifier == p.processIdentifier,
              p.exactReapCount == 1, !p.cleanupInitiated,
              p.waitOptions == 0, p.rawWaitStatus == 0, p.exitedNormally,
              p.exitStatus == 0, p.terminationSignal == 0, !p.coreDumped,
              p.processGroupEmptyAfterReap else { throw PrimeValidationDriverV2Error.invalidInventoryReceipt }
        try validateStream(p.standardOutput)
        try validateStream(p.standardError)
    }

    static func validateStream(_ s: PrimeValidationDriverV2BuildStreamObservation) throws {
        try PrimeValidationDriverV2Validation.requireSHA256(s.outputSHA256)
        guard s.reachedEOF, !s.overflowed, s.workerFinished, s.descriptorsClosed,
              s.readErrorNumber == 0, s.writeErrorNumber == 0,
              s.finalizationErrorNumber == 0, s.closeErrorNumber == 0,
              s.outputMetadataObserved, s.outputPermissionMode == 0o444,
              s.outputDeviceID > 0, s.outputInode > 0,
              s.totalByteCount == s.capturedByteCount, s.capturedByteCount == s.outputByteCount,
              s.outputByteCount <= 16 * 1024 * 1024, s.terminalReason == "end_of_file"
        else { throw PrimeValidationDriverV2Error.invalidInventoryReceipt }
    }

    static func validateArtifact(_ binding: PrimeArtifactBinding, path: String, data: Data) throws {
        guard binding.relativePath == path, binding.purpose == .immutableData, binding.byteCount == data.count,
              binding.sha256 == PrimeSHA256.hexDigest(of: data) else {
            throw PrimeValidationDriverV2Error.invalidInventoryReceipt
        }
    }

    static func validateJournalBinding<Value: Codable>(
        _ binding: PrimeArtifactBinding, path: String, type: Value.Type, object: [String: Any]
    ) throws {
        let fields = try JSONSerialization.data(withJSONObject: object)
        let value = try JSONDecoder().decode(type, from: fields)
        try validateArtifact(binding, path: path, data: PrimeCanonicalJSON.encode(value))
    }

    private static func validateStreamBinding(_ binding: PrimeArtifactBinding,
        stream: PrimeValidationDriverV2BuildStreamObservation, path: String) throws {
        guard binding.relativePath == path, binding.purpose == .immutableData, binding.byteCount == stream.outputByteCount,
              binding.sha256 == stream.outputSHA256 else { throw PrimeValidationDriverV2Error.invalidInventoryReceipt }
    }

    static func makeChild(
        invocation: PrimeValidationInvocationV2,
        process p: PrimeValidationDriverV2BuildProcessObservation,
        intervalStartedAt: UInt64, matchedCount: Int, supervisorPID: Int32
    ) throws -> PrimeValidationObservedChildReceiptV2 {
        // Partition the one shared G interval at each exact wait. This includes
        // inter-child admission time once, rather than counting the first child twice.
        guard p.waitReturnedUptimeNanoseconds > intervalStartedAt,
              intervalStartedAt >= p.deadlineStartedAtUptimeNanoseconds,
              matchedCount >= 0 else { throw PrimeValidationDriverV2Error.invalidInventoryReceipt }
        func stream(_ s: PrimeValidationDriverV2BuildStreamObservation) -> PrimeValidationStreamAuditV2 {
            .init(eofObserved: s.reachedEOF, totalByteCount: s.totalByteCount,
                capturedByteCount: s.capturedByteCount, overflowObserved: s.overflowed,
                readErrorNumber: s.readErrorNumber, writeErrorNumber: s.writeErrorNumber)
        }
        return .init(invocation: invocation, primaryResult: .standardOutput,
            standardOutputArtifact: .init(name: "standard_output", relativePath: invocation.standardOutputRelativePath,
                content: try content(p.standardOutput.outputByteCount, p.standardOutput.outputSHA256)),
            standardErrorArtifact: .init(name: "standard_error", relativePath: invocation.standardErrorRelativePath,
                content: try content(p.standardError.outputByteCount, p.standardError.outputSHA256)),
            process: .init(processIdentifier: p.processIdentifier, sessionIdentifier: p.sessionIdentifier,
                processGroupIdentifier: p.processGroupIdentifier, deadlineDisposition: .completed,
                sigtermDelivery: .notAttempted, sigkillDelivery: .notAttempted,
                preReapProcessGroupMembers: p.preReapProcessGroupMemberIdentifiers,
                exactReturnedProcessIdentifier: p.returnedWaitProcessIdentifier, rawWaitStatus: p.rawWaitStatus,
                waitTermination: .exited(p.exitStatus), processGroupEmptyAfterReap: p.processGroupEmptyAfterReap,
                standardOutput: stream(p.standardOutput), standardError: stream(p.standardError),
                matchedTestCount: matchedCount, supervisorSessionIdentifier: supervisorPID),
            activeNanoseconds: p.waitReturnedUptimeNanoseconds - intervalStartedAt)
    }

    fileprivate static func makeReceipt(intent: PrimeValidationRunIntentV2,
        build: PrimeValidationBuildReceiptV2, children: [PrimeValidationDriverV2InventoryChildObservation],
        xctestData: Data, swiftTestingData: Data, supervisorPID: Int32) throws -> PrimeValidationInventoryReceiptV2 {
        guard children.count == 2, xctestData.count <= 16 * 1024 * 1024,
              swiftTestingData.count <= 16 * 1024 * 1024 else { throw PrimeValidationDriverV2Error.invalidInventoryReceipt }
        try validateArtifact(children[0].standardOutputBinding, path: "xctest-list.stdout.log", data: xctestData)
        try validateArtifact(children[1].standardOutputBinding, path: "swift-testing-list.stdout.log", data: swiftTestingData)
        let inventory = try PrimeValidationInventory.parse(xctestList: xctestData, swiftTestingList: swiftTestingData)
        let invocations = try PrimeValidationInvocationFactoryV2.inventory(intent: intent)
        let counts = [inventory.xctestIDs.count, inventory.swiftTestingIDs.count]
        var intervalStart = children[0].process.deadlineStartedAtUptimeNanoseconds
        var receipts: [PrimeValidationObservedChildReceiptV2] = []
        for index in children.indices {
            receipts.append(try makeChild(invocation: invocations[index], process: children[index].process,
                intervalStartedAt: intervalStart, matchedCount: counts[index], supervisorPID: supervisorPID))
            intervalStart = children[index].process.waitReturnedUptimeNanoseconds
        }
        return .init(runID: intent.runID, intentSHA256: try intent.identitySHA256(),
            buildReceiptSHA256: try build.identitySHA256(against: intent),
            invocations: invocations, observedChildren: receipts,
            xctestListArtifact: .init(name: "xctest_list", relativePath: invocations[0].standardOutputRelativePath,
                content: .init(data: xctestData)),
            swiftTestingListArtifact: .init(name: "swift_testing_list", relativePath: invocations[1].standardOutputRelativePath,
                content: .init(data: swiftTestingData)),
            xctestListData: xctestData, swiftTestingListData: swiftTestingData, inventory: inventory,
            activeNanoseconds: try PrimeValidationDriverV2Validation.checkedSum(receipts.map(\.activeNanoseconds)))
    }

    private static func content(_ count: UInt64, _ hash: String) throws -> PrimeValidationContentBinding {
        struct Fields: Encodable { let byteCount: UInt64; let sha256: String }
        let value = try PrimeCanonicalJSON.decode(PrimeValidationContentBinding.self,
            from: PrimeCanonicalJSON.encode(Fields(byteCount: count, sha256: hash)))
        try value.validate(); return value
    }
}

/// The only authority is the consumed, retained native lifetime.
package final class PrimeValidationDriverV2InventoryBinding: @unchecked Sendable {
    package let envelope: PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1
    private let lifetime: PrimeValidationDriverV2InventoryBoundLifetime

    package init(raw: PrimeValidationDriverV2InventoryRawCapability, intent: PrimeValidationRunIntentV2,
                 predecessor: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1) throws {
        var transferred = false
        defer { if !transferred { raw.rejectValidatedBindingLifetime() } }
        let observed = raw.observation
        let receipt = try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.makeReceipt(
            intent: intent, build: predecessor.receipt, children: observed.children,
            xctestData: observed.xctestListData, swiftTestingData: observed.swiftTestingListData,
            supervisorPID: predecessor.predecessorSupervisorPID)
        let envelope = PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1(schemaVersion: 1,
            predecessorBuildBinding: observed.predecessorBuildBinding,
            predecessorSupervisorPID: predecessor.predecessorSupervisorPID,
            children: observed.children, terminalBinding: observed.terminalBinding, receipt: receipt)
        try envelope.validate(intent: intent, expectedSupervisorPID: predecessor.predecessorSupervisorPID,
            build: predecessor, expectedBuildBinding: observed.predecessorBuildBinding)
        let bytes = try PrimeCanonicalJSON.encode(envelope)
        self.envelope = envelope
        lifetime = try raw.consumeValidatedBindingLifetime(bindingData: bytes)
        transferred = true
    }

    package func revalidate() throws { try lifetime.revalidateContinuity() }
}
