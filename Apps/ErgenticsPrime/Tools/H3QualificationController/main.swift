import Darwin

#if EPR_H3_QUALIFICATION
import Foundation
import Security

private enum H3QualificationControllerMain {
    #if DEBUG
    static let configuration: H3QualificationConfiguration = .debug
    static let configurationName = "DEBUG"
    static let configurationLeaf = "debug"
    static let productDirectory = "/private/tmp/ergentics-h3q-debug-v1/Build/Products/Debug"
    #else
    static let configuration: H3QualificationConfiguration = .release
    static let configurationName = "RELEASE"
    static let configurationLeaf = "release"
    static let productDirectory = "/private/tmp/ergentics-h3q-release-v1/Build/Products/Release"
    #endif

    static func run(_ argv: [String]) throws -> Int32 {
        let invocation = try H3QualificationControllerInvocation(arguments: argv, configuration: configuration)
        let mode = invocation.mode
        let verifying = invocation.verifying
        let rootPath = invocation.campaignRoot
        #if !arch(arm64)
        throw H3QualificationControllerFailure.rejected("architecture")
        #endif
        let controllerPath = productDirectory + "/ErgenticsProvenanceH3QualificationController"
        let controller = try H3QualificationExecutable(path: controllerPath, codePath: controllerPath)
        let controllerClaim = try H3QualificationSigning.selfAdmission(executable: controller)
        let loader = H3QualificationCampaignLoader()
        if verifying {
            let bundle = try loader.load(rootPath: rootPath, mode: mode)
            let bytes = try H3QualificationCampaignVerifier.verify(bundle: bundle, verifierClaim: controllerClaim)
            let checkpoint = try H3QualificationCanonicalJSON.decode(bytes, maximumBytes: 262144)
            try H3QualificationWire.validate(checkpoint, schema: "campaign_checkpoint_v1")
            guard let root = loader.campaign else { throw H3QualificationControllerFailure.rejected("held campaign") }
            let result = try checkpoint.h3Field("result").h3String()
            guard result == (mode == .admissionOnly ? "PASS_ADMISSION_CAMPAIGN" : "PASS_H3_GUEST_CAMPAIGN") ||
                  (mode == .guest && result == "FAIL_H3_GUEST_CAMPAIGN") else {
                throw H3QualificationControllerFailure.rejected("checkpoint result")
            }
            let name = mode == .admissionOnly ? "admission-campaign-checkpoint.json" : "guest-campaign-checkpoint.json"
            try root.identityJoin()
            _ = try root.writeLeaf(name, bytes: bytes, maximum: 262144)
            try root.syncDirectory()
            try loader.close()
            try controller.descriptor.close()
            return result == "FAIL_H3_GUEST_CAMPAIGN" ? 65 : 0
        }
        let result = try runApplication(mode: mode, rootPath: rootPath, loader: loader, controllerClaim: controllerClaim)
        try loader.close()
        try controller.descriptor.close()
        return result
    }

    private static func runApplication(mode: H3QualificationMode, rootPath: String,
                                       loader: H3QualificationCampaignLoader,
                                       controllerClaim: H3QValue) throws -> Int32 {
        let selection = try H3QualificationPrelaunchSelection(mode: mode, configuration: configuration,
                                                              runRoot: rootPath + "/" + configurationLeaf)
        try loader.admit(rootPath: rootPath, mode: mode, running: configuration)
        guard let campaign = loader.campaign,
              let root = configuration == .debug ? loader.debug : loader.release,
              root.path == selection.runRoot else {
            throw H3QualificationControllerFailure.rejected("run directories")
        }
        let provider = try H3QualificationPrelaunchProvider(campaign: campaign, selection: selection)
        var transaction = H3QualificationPrelaunchTransaction(selection: selection, owner: campaign.admitted)
        let prelaunch = try transaction.run(controllerClaim: controllerClaim, operations: provider.operations)
        let expected = prelaunch.expectedApplication
        let bundlePath = productDirectory + "/Ergentics Provenance.app"
        let executablePath = bundlePath + "/Contents/MacOS/Ergentics Provenance"
        let application = try H3QualificationExecutable(path: executablePath, codePath: bundlePath)
        let preStatic = try H3QualificationSigning.staticApplication(application)
        guard try H3QualificationProtocol.sameCodeIdentity(preStatic, expected) else { throw H3QualificationControllerFailure.rejected("prelaunch product identity") }
        try root.identityJoin()
        // The first exclusive create is the irreversible attempt boundary. There is
        // no retry, repair, replacement, fresh nonce, or same-root reuse below it.
        let stdoutWriter = try root.createLeaf("inner-application-report.frame", readWrite: true)
        let stdoutRead = try H3QualificationDescriptor(Darwin.openat(root.descriptor.value,
            "inner-application-report.frame", H3QualificationStorage.readFlags))
        let stdoutInitial = try H3QualificationStorage.snapshot(stdoutWriter.value)
        guard try H3QualificationStorage.snapshot(stdoutRead.value) == stdoutInitial else {
            throw H3QualificationControllerFailure.rejected("stdout reader identity")
        }
        let stderrWriter = try root.createLeaf("application-stderr.bin")
        let process = try H3QualificationApplicationProcess(application: application, expectedClaim: expected,
                                                           stdoutWriter: stdoutWriter)
        var nonceBytes = [UInt8](repeating: 0, count: 32)
        let randomReturn = SecRandomCopyBytes(kSecRandomDefault, nonceBytes.count, &nonceBytes)
        guard randomReturn == errSecSuccess else {
            throw H3QualificationControllerFailure.system("nonce draw", randomReturn)
        }
        let nonce = nonceBytes.map { String(format: "%02x", $0) }.joined()
        let runID = try H3QualificationProtocol.runID(mode: mode, configuration: configuration, nonce: nonce)
        let gate = try H3QualificationProtocol.gateFrame(mode: mode, nonce: nonce)
        var cancel = Data("EPRH3C01".utf8); cancel.append(contentsOf: nonceBytes)
        let appArgv = [mode == .admissionOnly ? "--h3-qualification-admission-once" : "--h3-qualification-guest-once", nonce]
        let observation = try process.run(argv: appArgv, gate: gate, cancellation: cancel)
        let run: H3QValue = .object(["configuration": .string(configurationName),
            "mode": .string(mode == .admissionOnly ? "ADMISSION_ONLY" : "GUEST"),
            "nonce": .string(nonce), "run_id": .string(runID)])
        if observation.spawnReturn == 0 && observation.waitStatus == nil {
            _ = try root.finishLeaf("application-stderr.bin", writer: stderrWriter,
                                    bytes: observation.stderrBytes, maximum: 65536)
            try stdoutRead.close()
            try writeIncident(observation, run: run, root: root)
            try application.descriptor.close()
            return 70
        }
        if observation.spawnReturn != 0 {
            try H3QualificationStorage.sync(stdoutWriter.value)
            try stdoutWriter.close()
        }
        let stdoutCapture = try H3QualificationStorage.read(stdoutRead.value, maximum: 65552, device: root.admitted.device)
        guard stdoutCapture.snapshot.sameIdentity(as: stdoutInitial) else {
            throw H3QualificationControllerFailure.rejected("stdout terminal identity")
        }
        try stdoutRead.close()
        try root.identityOnlyLeaf("inner-application-report.frame", expected: stdoutCapture.snapshot)
        let stderrCapture = try root.finishLeaf("application-stderr.bin", writer: stderrWriter,
                                                bytes: observation.stderrBytes, maximum: 65536)
        let terminalApplication = try application.terminalObservation()
        let applicationClaim: H3QValue
        if observation.spawnReturn != 0 {
            guard observation.spawnReturn > 0, stdoutCapture.bytes.isEmpty else {
                throw H3QualificationControllerFailure.rejected("no-child evidence")
            }
            applicationClaim = .object([
                "held_before_spawn": application.original.wire, "held_terminal": terminalApplication.held.wire,
                "named_before_spawn": application.original.wire, "named_terminal": terminalApplication.named.wire,
                "pre_static": preStatic
            ])
        } else {
            guard let dynamic = observation.dynamicClaim, let path = observation.dynamicPath,
                  let heldGate = observation.heldBeforeGate, let namedGate = observation.namedBeforeGate else {
                throw H3QualificationControllerFailure.rejected("post-spawn identity rejection")
            }
            let postStatic = try H3QualificationSigning.staticApplication(application)
            guard try H3QualificationPathIdentityPolicy.terminal(original: application.original,
                heldGate: heldGate, namedGate: namedGate, heldTerminal: terminalApplication.held,
                namedTerminal: terminalApplication.named, preStatic: preStatic, dynamic: dynamic,
                postStatic: postStatic, processPath: path, executablePath: application.path) else {
                throw H3QualificationControllerFailure.rejected("terminal signing identity")
            }
            applicationClaim = .object([
                "dynamic": dynamic, "held_after_reap": terminalApplication.held.wire,
                "held_before_gate": heldGate.wire, "held_before_spawn": application.original.wire,
                "named_after_reap": terminalApplication.named.wire, "named_before_gate": namedGate.wire,
                "named_before_spawn": application.original.wire, "post_static": postStatic,
                "pre_static": preStatic, "proc_pidpath": .string(path)
            ])
        }
        var inner: H3QValue?
        if !stdoutCapture.bytes.isEmpty {
            if let decoded = try? H3QualificationProtocol.decodeFrame(stdoutCapture.bytes),
               (try? H3QualificationWire.validate(decoded, schema: "inner_report_v1")) != nil {
                inner = decoded
            }
        }
        // A missing/malformed inner frame cannot manufacture known application effect
        // counts. The closed receipt schema has no UNKNOWN taxonomy variant; retain
        // that incomplete prefix without inventing a normal receipt.
        guard observation.spawnReturn != 0 || inner != nil else {
            throw H3QualificationControllerFailure.rejected("missing valid inner evidence")
        }
        try root.identityJoin(); try campaign.identityJoin()
        let host = try hostClaim()
        let terminalTick = mach_continuous_time()
        guard terminalTick >= observation.spawnTick, terminalTick <= observation.terminalHorizon,
              observation.stderrEOF, !observation.observationFailure else {
            throw H3QualificationControllerFailure.rejected("terminal horizon or observation")
        }
        var receipt = try receiptValue(observation, run: run, application: applicationClaim,
                                      controller: controllerClaim, host: host, inner: inner,
                                      stdout: stdoutCapture, stderr: stderrCapture, root: root,
                                      manifestHash: prelaunch.manifestSHA256,
                                      auditHash: prelaunch.productAuditSHA256, gate: gate, cancel: cancel,
                                      terminal: terminalTick)
        let failed = try H3QualificationPredicateEvaluator.evaluate(receipt: receipt, inner: inner)
        let classification = observation.spawnReturn != 0 ? "NO_CHILD_FAILURE" :
            (failed.isEmpty ? "RUN_CANDIDATE_PASS" : "RETAINED_NONPASS")
        var fields = try receipt.h3Object()
        fields["classification"] = .object(["failed_predicates": .array(failed.map(H3QValue.string)),
                                            "result": .string(classification)])
        receipt = .object(fields)
        try H3QualificationWire.validate(receipt, schema: "outer_receipt_v1")
        let receiptBytes = try H3QualificationCanonicalJSON.encode(receipt, maximumBytes: 131072)
        let receiptCapture = try root.writeLeaf("outer-observer-receipt.json", bytes: receiptBytes, maximum: 131072)
        let files: [(String, H3QualificationStorage.Capture)] = [
            ("inner-application-report.frame", stdoutCapture), ("application-stderr.bin", stderrCapture),
            ("outer-observer-receipt.json", receiptCapture)
        ]
        let manifest: H3QValue = .object([
            "configuration": .string(configurationName),
            "files": .array(files.map { name, capture in .object([
                "byte_count": .integer(Int64(capture.bytes.count)), "mode": .integer(384),
                "path": .string(name), "sha256": .string(capture.sha256)]) }),
            "mode": .string(mode == .admissionOnly ? "ADMISSION_ONLY" : "GUEST"), "run_id": .string(runID),
            "schema": .string("com.ergentics.provenance.h3-qualification-manifest.v1"), "version": .integer(1)
        ])
        try H3QualificationWire.validate(manifest, schema: "manifest_v1")
        _ = try root.writeLeaf("manifest.json", bytes: H3QualificationCanonicalJSON.encode(manifest, maximumBytes: 65536), maximum: 65536)
        try root.requireInventory(["application-stderr.bin", "inner-application-report.frame", "manifest.json", "outer-observer-receipt.json"], maximum: 5)
        try root.syncDirectory()
        let exitCode: Int32
        if classification == "RUN_CANDIDATE_PASS" { exitCode = 0 }
        else if let inner, try H3QualificationPredicateEvaluator.validTerminalNonpass(receipt: receipt, inner: inner) { exitCode = 65 }
        else { exitCode = 70 }
        try application.descriptor.close()
        return exitCode
    }

    private static func hostClaim() throws -> H3QValue {
        func text(_ name: String) throws -> String {
            var buffer = [UInt8](repeating: 0, count: 257), length = 257
            guard sysctlbyname(name, &buffer, &length, nil, 0) == 0,
                  length > 1, length <= 257, buffer[length - 1] == 0,
                  !buffer[..<(length - 1)].contains(0),
                  let value = String(bytes: buffer[..<(length - 1)], encoding: .utf8) else {
                throw H3QualificationControllerFailure.rejected("host version")
            }
            return value
        }
        return .object(["architecture": .string("arm64"), "macos_build": .string(try text("kern.osversion")),
                        "macos_version": .string(try text("kern.osproductversion"))])
    }

    private static func receiptValue(_ observed: H3QualificationProcessResult, run: H3QValue,
        application: H3QValue, controller: H3QValue, host: H3QValue, inner: H3QValue?,
        stdout: H3QualificationStorage.Capture, stderr: H3QualificationStorage.Capture,
        root: H3QualificationDirectory, manifestHash: String, auditHash: String,
        gate: Data, cancel: Data, terminal: UInt64) throws -> H3QValue {
        let noChild = observed.spawnReturn != 0
        let signing = try inner?.h3Field("signing").h3Field("status").h3String() ?? "NOT_ENTERED"
        let admitted = signing == "ADMITTED"
        let entered = try inner?.h3Field("effects").h3Field("guest_entered_count") ?? .integer(0)
        let created = try inner?.h3Field("effects").h3Field("hv_vm_created_count") ?? .integer(0)
        let support: String
        if noChild || inner == nil { support = "NOT_ENTERED" }
        else if try run.h3Field("mode").h3String() == "ADMISSION_ONLY" { support = "NOT_QUERIED" }
        else if try inner!.h3Field("native").h3Field("disposition").h3String() == "NOT_ENTERED" { support = "NOT_ENTERED" }
        else {
            let native = try inner!.h3Field("native")
            let source = try native.h3Field("source").h3Field("vm_create_status").h3Integer()
            let target = try native.h3Field("target").h3Field("vm_create_status").h3Integer()
            support = source == 0 || target == 0 ? "NATIVE_ENTRY_SUCCEEDED" :
                (source != Int64(Int32.min) || target != Int64(Int32.min) ? "NATIVE_ENTRY_FAILED" : "NOT_ENTERED")
        }
        let child: H3QValue
        if noChild {
            child = .object(["disposition": .string("NOT_CREATED"), "exit": .string("NOT_APPLICABLE"),
                "pid": .integer(0), "reap": .string("NOT_APPLICABLE"), "signal": .string("NOT_APPLICABLE"),
                "wait_status": .string("NOT_APPLICABLE")])
        } else {
            guard let status = observed.waitStatus else { throw H3QualificationControllerFailure.containmentUnproven }
            guard let terminal = H3QualificationTerminalWaitStatus(rawValue: status) else {
                throw H3QualificationControllerFailure.containmentUnproven
            }
            let exitValue: H3QValue
            let signalValue: H3QValue
            switch terminal {
            case .exited(let code):
                exitValue = .integer(Int64(code)); signalValue = .string("NOT_APPLICABLE")
            case .signaled(let signal, _):
                exitValue = .string("NOT_APPLICABLE"); signalValue = .integer(Int64(signal))
            }
            child = .object(["disposition": .string("REAPED"),
                "exit": exitValue,
                "pid": .integer(Int64(observed.pid)), "reap": .string("EXACT_PID_REAPED"),
                "signal": signalValue,
                "wait_status": .integer(Int64(status))])
        }
        let argv: [H3QValue] = [.string(try run.h3Field("mode").h3String() == "ADMISSION_ONLY" ?
            "--h3-qualification-admission-once" : "--h3-qualification-guest-once"), try run.h3Field("nonce")]
        return .object([
            "application": application, "child": child,
            "classification": .object(["failed_predicates": .array([]), "result": .string("RETAINED_NONPASS")]),
            "controller_claim": controller, "deadlines": observed.deadlines(terminal: terminal),
            "evidence": .object([
                "build_source_manifest_sha256": .string(manifestHash),
                "effective_entitlements_sha256": .string(admitted ? "f754d498901c39fbbc8f6a5cfb35cf5661174a201d24c6c37a22a3f50708336b" : String(repeating: "0", count: 64)),
                "effective_hypervisor_value": .string(admitted ? "TRUE" : "NOT_OBSERVED"),
                "hypervisor_support": .string(support), "inner_byte_count": .integer(Int64(stdout.bytes.count)),
                "inner_eof": .bool(true), "inner_sha256": .string(stdout.sha256), "inner_valid": .bool(inner != nil),
                "product_audit_sha256": .string(auditHash), "root_identity": root.admitted.wire,
                "stdout_identity_terminal": stdout.snapshot.wire]),
            "gate": .object([
                "cancel_errno": .integer(Int64(observed.cancelErrno)), "cancel_frame_sha256": .string(h3qHash(cancel)),
                "cancel_return": .integer(Int64(observed.cancelReturn)), "cancel_writes": .integer(Int64(observed.cancelWrites)),
                "gate_errno": .integer(Int64(observed.gateErrno)), "gate_frame_sha256": .string(h3qHash(gate)),
                "gate_return": .integer(Int64(observed.gateReturn)), "gate_writes": .integer(Int64(observed.gateWrites))]),
            "host": host,
            "kill": .object(["attempted": .bool(observed.killAttempted), "errno": .integer(Int64(observed.killErrno)),
                             "pid": .integer(Int64(observed.pid)), "return": .integer(Int64(observed.killReturn))]),
            "run": run, "schema": .string("com.ergentics.provenance.h3-qualification-outer-receipt.v1"),
            "spawn": .object(["argv": .array(argv), "attributes": .string("CLOEXEC_DEFAULT_EMPTY_MASK_DEFAULT_CATCHABLE_SIGNALS"),
                "cwd": .string("/private/var/empty"), "environment_count": .integer(0),
                "fd_map": .string("0=devnull-ro,1=regular-rw-0600,2=pipe,3=gate-ro,4=cancel-ro"),
                "spawn_return": .integer(Int64(observed.spawnReturn))]),
            "stderr": .object(["eof": .bool(observed.stderrEOF), "overflow": .bool(observed.stderrOverflow),
                "retained_byte_count": .integer(Int64(stderr.bytes.count)), "retained_sha256": .string(stderr.sha256),
                "total_byte_count": .integer(Int64(observed.stderrTotal))]),
            "taxonomy": .object(["app_launched": .bool(!noChild), "authority_effect": .string("NONE"),
                "guest_entered_count": entered, "helper_processes": .integer(0), "hv_vm_created_count": created,
                "runner_location": .string("EVALUATED_MAC_EXTERNAL_CONTROLLER"), "signals": .integer(observed.killAttempted ? 1 : 0),
                "signing_state": .string(signing), "sqlite_opened": .bool(false),
                "subject_location": .string("EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION")]),
            "version": .integer(1)
        ])
    }

    private static func writeIncident(_ observed: H3QualificationProcessResult, run: H3QValue,
                                      root: H3QualificationDirectory) throws {
        let terminal = mach_continuous_time()
        guard terminal >= observed.terminalHorizon else {
            throw H3QualificationControllerFailure.containmentUnproven
        }
        let incident: H3QValue = .object([
            "child_pid": .integer(Int64(observed.pid)), "classification": .string("CONTAINMENT_UNPROVEN"),
            "configuration": try run.h3Field("configuration"), "kill_attempted": .bool(observed.killAttempted),
            "kill_deadline_tick": .string(String(observed.killDeadline)), "kill_errno": .integer(Int64(observed.killErrno)),
            "kill_return": .integer(Int64(observed.killReturn)), "last_wait_errno": .integer(Int64(observed.lastWaitErrno)),
            "last_wait_return": .integer(Int64(observed.lastWaitReturn)), "mode": try run.h3Field("mode"),
            "nonce": try run.h3Field("nonce"), "operation_deadline_tick": .string(String(observed.operationDeadline)),
            "run_id": try run.h3Field("run_id"), "schema": .string("com.ergentics.provenance.h3-qualification-containment-incident.v1"),
            "spawn_tick": .string(String(observed.spawnTick)),
            "taxonomy": .object(["app_launched": .bool(true), "authority_effect": .string("NONE"),
                "guest_entered_count": .string("UNKNOWN"), "helper_processes": .integer(0),
                "hv_vm_created_count": .string("UNKNOWN"), "runner_location": .string("EVALUATED_MAC_EXTERNAL_CONTROLLER"),
                "signals": .integer(observed.killAttempted ? 1 : 0), "signing_state": .string("UNKNOWN"),
                "sqlite_opened": .string("UNKNOWN"), "subject_location": .string("EVALUATED_MAC_SIGNED_PRODUCT_APPLICATION")]),
            "terminal_horizon_tick": .string(String(observed.terminalHorizon)), "terminal_tick": .string(String(terminal)),
            "timebase_denominator": .integer(Int64(observed.clock.denominator)),
            "timebase_numerator": .integer(Int64(observed.clock.numerator)), "version": .integer(1)
        ])
        try H3QualificationWire.validate(incident, schema: "containment_incident_v1")
        _ = try root.writeLeaf("containment-incident.json",
            bytes: H3QualificationCanonicalJSON.encode(incident, maximumBytes: 65536), maximum: 65536)
    }
}

let h3QualificationExit: Int32
do {
    h3QualificationExit = try H3QualificationControllerMain.run(Array(CommandLine.arguments.dropFirst()))
} catch H3QualificationControllerFailure.invalidArguments {
    h3QualificationExit = 64
} catch H3QualificationControllerFailure.durability {
    h3QualificationExit = 74
} catch {
    // Fixed, bounded failure text carries no paths, credentials, input bytes, or claims.
    let message = Array("H3 qualification controller incomplete.\n".utf8)
    _ = message.withUnsafeBytes { Darwin.write(2, $0.baseAddress!, message.count) }
    h3QualificationExit = 70
}
Darwin._exit(h3QualificationExit)
#else
// The incidental ordinary-compatibility controller has no qualification grammar,
// signing, filesystem, subprocess, randomness, signal, or Hypervisor path.
Darwin._exit(64)
#endif
