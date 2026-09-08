// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
import PrimeCore
import PrimeNativeDecoderRuntime
import PrimeNativeDecoderTraining

typealias Science = PrimeNativeDecoderCurrentLocalNative300MExecution

private func emit(_ text: String) {
    let data = Data((text + "\n").utf8)
    data.withUnsafeBytes { bytes in _ = Darwin.write(STDERR_FILENO, bytes.baseAddress, bytes.count) }
}

private func publish(_ data: Data, root: PrimeArtifactRoot, path: String) throws -> PrimeArtifactBinding {
    guard data.count <= Science.maximumResultByteCount else { throw Local300MError.rejected("result_size") }
    return try root.publishGeneratedFile(at: path, purpose: .immutableData, maximumByteCount: UInt64(data.count)) { descriptor in
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let count = Darwin.write(descriptor, bytes.baseAddress!.advanced(by: offset), bytes.count - offset)
                if count < 0 && errno == EINTR { continue }
                guard count > 0 else { throw Local300MError.rejected("result_write_\(errno)") }
                offset += count
            }
        }
    }
}

private struct WorkerBinding: Codable {
    let schema = "prime_current_local_native300m_worker_binding_v1"
    let role: PrimeCurrentLocalNative300MRole
    let launchSHA256: String
    let processIdentifier: Int32
    let parentProcessIdentifier: Int32
    let runtimeEvidence: PrimeArtifactBinding
    let scienceResult: PrimeArtifactBinding
    let inputResult: PrimeArtifactBinding?
    let completedAtUptimeNanoseconds: UInt64
}

@available(macOS 26.0, *)
private func worker(role: PrimeCurrentLocalNative300MRole, launchURL: URL) throws {
    let workerStartedAt = DispatchTime.now().uptimeNanoseconds
    let (launch, ticket) = try PrimeCurrentLocalNative300MProcessControl.admitWorker(launchURL: launchURL, role: role)
    // A dead controller cannot leave a GPU worker running until its next
    // scientific callback. This timer owns no process and grants no successor.
    let watchdog = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInitiated))
    watchdog.schedule(deadline: .now(), repeating: .milliseconds(200))
    watchdog.setEventHandler {
        if getppid() != ticket.supervisorPID || DispatchTime.now().uptimeNanoseconds >= ticket.workerDeadlineNanoseconds {
            emit("current_local_native300m_worker_parent_or_deadline_lost")
            Darwin._exit(124)
        }
    }
    watchdog.resume()
    defer { watchdog.cancel() }
    let output = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath: launch.runRoot))
    let artifacts = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath: launch.runRoot + "/artifacts"))
    let prefix = "control/" + role.rawValue
    var progressCount = 0
    try output.ensurePrivateDirectory(at: prefix + "-progress")
    func progress(_ data: Data) throws {
        guard data.count <= 64 * 1024, progressCount < 512,
              DispatchTime.now().uptimeNanoseconds < ticket.workerDeadlineNanoseconds
        else { throw Local300MError.rejected("progress_or_science_deadline") }
        progressCount += 1
        _ = try publish(data, root: output, path: prefix + "-progress/" + String(format: "%04d.json", progressCount))
        FileHandle.standardOutput.write(data); FileHandle.standardOutput.write(Data([10]))
    }
    emit("current_local_native300m role=\(role.rawValue) pid=\(getpid()) runtime_preflight_started")
    let leaseURL = URL(fileURLWithPath: launch.runRoot + "/synchronization/metal.lock")
    let runtime = try PrimeNativeDecoderRuntime.initializeCurrentProcess(metallibExpectation: launch.metallib, metalLeaseURL: leaseURL)
    try runtime.validate()
    let runtimeBinding = try publish(PrimeCanonicalJSON.encode(runtime), root: output, path: prefix + "-runtime.json")
    emit("current_local_native300m role=\(role.rawValue) runtime_preflight_passed")
    // The initializer's lease ends on return. This separately held strict lease
    // protects all model, optimizer, checkpoint and reload operations below.
    let lease = try PrimeMetalDeviceLease.acquire(at: leaseURL)
    defer { lease.release() }
    let result: Data
    let path: String
    let input: PrimeArtifactBinding?
    switch role {
    case .baseline:
        guard ticket.inputResult == nil else { throw Local300MError.rejected("baseline_input_binding") }; input = nil; path = Science.baselineResultFileName
        result = try Science.runStage7Baseline(artifactRoot: artifacts, lease: lease, workerEpochNanoseconds: ticket.sharedPhaseEpochNanoseconds, recordProgress: progress)
    case .resume:
        guard let binding = ticket.inputResult, binding.relativePath == Science.baselineResultFileName else { throw Local300MError.rejected("resume_input_binding") }
        input = binding; path = Science.stage7ResultFileName
        let bytes = try output.readVerified(binding)
        result = try Science.runStage7Resume(artifactRoot: artifacts, intermediateResult: bytes, lease: lease, workerEpochNanoseconds: workerStartedAt, recordProgress: progress)
        _ = try output.verify(binding)
    case .verify:
        guard let binding = ticket.inputResult, binding.relativePath == Science.stage7ResultFileName else { throw Local300MError.rejected("verify_input_binding") }
        input = binding; path = Science.stage8ResultFileName
        let bytes = try output.readVerified(binding)
        result = try Science.verifyRetainedStage7(artifactRoot: artifacts, stage7Result: bytes, lease: lease, workerEpochNanoseconds: workerStartedAt, recordProgress: progress)
        _ = try output.verify(binding)
    }
    guard lease.isHeld, DispatchTime.now().uptimeNanoseconds < ticket.workerDeadlineNanoseconds else { throw Local300MError.rejected("worker_completion_deadline_or_lease") }
    let resultBinding = try publish(result, root: output, path: path)
    _ = try output.publishCanonicalExclusively(WorkerBinding(role: role, launchSHA256: ticket.launchSHA256, processIdentifier: getpid(), parentProcessIdentifier: getppid(), runtimeEvidence: runtimeBinding, scienceResult: resultBinding, inputResult: input, completedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds), at: prefix + "-binding.json")
    emit("current_local_native300m role=\(role.rawValue) result_retained sha256=\(resultBinding.sha256)")
}

@available(macOS 26.0, *)
private func supervise(launchURL: URL) throws {
    let originalParent = getppid()
    guard originalParent > 1 else { throw Local300MError.rejected("supervisor_parent_absent") }
    if getsid(0) != getpid() { guard setsid() == getpid() else { throw Local300MError.rejected("supervisor_setsid_\(errno)") } }
    guard getpgrp() == getpid() else { throw Local300MError.rejected("supervisor_group") }
    let controller = try PrimeCurrentLocalNative300MProcessControl(launchURL: launchURL)
    guard getppid() == originalParent else { throw Local300MError.rejected("supervisor_parent_changed_during_preflight") }
    signal(SIGTERM, SIG_IGN); signal(SIGINT, SIG_IGN)
    let signals = [SIGTERM, SIGINT].map { number -> DispatchSourceSignal in
        let source = DispatchSource.makeSignalSource(signal: number, queue: DispatchQueue.global())
        source.setEventHandler { controller.requestStop() }
        source.resume(); return source
    }
    defer { for source in signals { source.cancel() } }
    let parentWatch = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
    parentWatch.schedule(deadline: .now(), repeating: .milliseconds(200))
    parentWatch.setEventHandler { if getppid() != originalParent { controller.requestStop() } }
    parentWatch.resume()
    defer { parentWatch.cancel() }
    var accepted: [WorkerBinding] = []
    do {
        for role in PrimeCurrentLocalNative300MRole.allCases {
            emit("current_local_native300m starting=\(role.rawValue)")
            try controller.execute(role, inputResult: accepted.last?.scienceResult)
            let path = "control/" + role.rawValue + "-binding.json"
            let bytes = try PrimeCurrentLocalNative300MProcessControl.readBounded(URL(fileURLWithPath: controller.launch.runRoot + "/" + path), maximum: 64 * 1024)
            let binding = try PrimeCanonicalJSON.decode(WorkerBinding.self, from: bytes)
            let startBytes = try PrimeCurrentLocalNative300MProcessControl.readBounded(URL(fileURLWithPath: controller.launch.runRoot + "/control/" + role.rawValue + "-start.json"), maximum: 64 * 1024)
            let ticket = try PrimeCanonicalJSON.decode(PrimeCurrentLocalNative300MWorkerTicket.self, from: startBytes)
            guard binding.role == role, binding.launchSHA256 == controller.launchSHA256,
                  binding.processIdentifier == ticket.workerPID, binding.parentProcessIdentifier == getpid(),
                  binding.completedAtUptimeNanoseconds < ticket.workerDeadlineNanoseconds,
                  binding.inputResult == accepted.last?.scienceResult
            else { throw Local300MError.rejected("worker_result_handoff") }
            let runtimeData = try controller.output.readVerified(binding.runtimeEvidence)
            let runtime = try PrimeCanonicalJSON.decode(PrimeNativeDecoderMaintainedRuntimeInitializationEvidenceV1.self, from: runtimeData)
            try runtime.validate()
            guard runtime.metallibExpectation == controller.launch.metallib,
                  runtime.executable.sha256 == controller.launch.executableSHA256,
                  runtime.executable.byteCount == controller.launch.executableByteCount
            else { throw Local300MError.rejected("runtime_image_or_library_handoff") }
            let result = try controller.output.readVerified(binding.scienceResult)
            switch role {
            case .baseline: guard try Science.baselineStatus(in: result) == "UNINTERRUPTED_RETAINED" else { throw Local300MError.rejected("baseline_not_retained") }
            case .resume:
                guard try Science.stage7Status(in: result) == "PASS_EXACT" else { throw Local300MError.rejected("stage7_measured_mismatch") }
            case .verify: guard try Science.stage8Status(in: result) == "PASS_RETAINED_RELOAD_EXACT" else { throw Local300MError.rejected("stage8_reload_not_verified") }
            }
            accepted.append(binding)
            _ = try controller.output.publishCanonicalExclusively(binding, at: "control/" + role.rawValue + "-accepted.json")
            emit("current_local_native300m accepted=\(role.rawValue)")
        }
        struct Complete: Codable {
            let schema = "prime_current_local_native300m_complete_v1"
            let status = "VERIFIED_STAGE7_EXACT_AND_STAGE8_RETAINED_RELOAD"
            let launchSHA256: String
            let workers: [WorkerBinding]
            let retainedArtifacts: [PrimeArtifactBinding]
            let applicationModelIntegrationClaimed = false
            let trainedLanguageQualityClaimed = false
        }
        let artifacts = try PrimeArtifactRoot(directoryURL: URL(fileURLWithPath: controller.launch.runRoot + "/artifacts"))
        let stage7Data = try controller.output.readVerified(accepted[1].scienceResult)
        let retained = try Science.retainedArtifactBindings(in: stage7Data)
        guard retained.map(\.relativePath).sorted() == Science.requiredArtifactPaths.sorted() else { throw Local300MError.rejected("retained_exact12") }
        for binding in retained { _ = try artifacts.verify(binding) }
        for binding in accepted { _ = try controller.output.verify(binding.scienceResult); _ = try controller.output.verify(binding.runtimeEvidence) }
        try controller.validateFinalBoundary()
        _ = try controller.output.publishCanonicalExclusively(Complete(launchSHA256: controller.launchSHA256, workers: accepted, retainedArtifacts: retained), at: "complete.json")
        emit("VERIFIED_STAGE7_EXACT_AND_STAGE8_RETAINED_RELOAD")
    } catch {
        struct Failure: Codable { let schema = "prime_current_local_native300m_failed_v1"; let error: String; let acceptedRoles: [String]; let observedAtUptimeNanoseconds: UInt64 }
        _ = try? controller.output.publishCanonicalExclusively(Failure(error: String(reflecting: error), acceptedRoles: accepted.map { $0.role.rawValue }, observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds), at: "failure.json")
        throw error
    }
}

if #available(macOS 26.0, *) {
    do {
        let args = CommandLine.arguments
        if args.count == 2, args[1] == "--pure-contract" {
            try PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.validatePureContractV1()
            try Science.validatePureContractV1()
            emit("PASS_CURRENT_LOCAL_AND_HISTORICAL_PURE_CONTRACTS_NO_MODEL")
        } else if args.count == 3, args[1] == "--supervise" {
            try supervise(launchURL: URL(fileURLWithPath: args[2]))
        } else if args.count == 4, args[1] == "--worker", let role = PrimeCurrentLocalNative300MRole(rawValue: args[2]) {
            try worker(role: role, launchURL: URL(fileURLWithPath: args[3]))
        } else { throw Local300MError.rejected("usage: --supervise /absolute/launch.json") }
    } catch {
        emit("current_local_native300m_failed: " + String(reflecting: error))
        Darwin.exit(71)
    }
} else {
    emit("current_local_native300m_requires_macos26")
    Darwin.exit(64)
}
