import AppKit
import Combine
import Darwin
import Foundation
import PrivateComputeCore

struct ArtifactRow: Identifiable, Sendable {
    let name: String
    let bytes: Int
    let sha256: String
    var id: String { name }
}

private struct NativePresentation: Sendable {
    var status = "Admission failed"
    var detail = "No verification result has been admitted."
    var mathematicalPass = false
    var persistencePass = false
    var runPath = ""
    var merkleRoot = ""
    var semanticRoot = ""
    var graphHash = ""
    var elapsedText = "Not measured"
    var environmentSummary = "Normal native application environment"
    var graphData: Data?
    var artifactRows: [ArtifactRow] = []
    var errorText: String?
}

@MainActor
final class ComputeModel: ObservableObject {
    @Published var status = "Preparing local workspace"
    @Published var detail = "A new offline, in-process static verification. No child processes."
    @Published var isRunning = false
    @Published var mathematicalPass = false
    @Published var persistencePass = false
    @Published var runPath = ""
    @Published var merkleRoot = ""
    @Published var semanticRoot = ""
    @Published var graphHash = ""
    @Published var elapsedText = "Not measured"
    @Published var environmentSummary = "Normal native application environment"
    @Published var graphData: Data?
    @Published var artifactRows: [ArtifactRow] = []
    @Published var errorText: String?
    private var started = false

    func start() async {
        guard !started else { return }
        started = true
        isRunning = true
        let result = await Task.detached(priority: .userInitiated) {
            NativeRun.perform()
        }.value
        status = result.status; detail = result.detail
        mathematicalPass = result.mathematicalPass
        persistencePass = result.persistencePass
        runPath = result.runPath; merkleRoot = result.merkleRoot
        semanticRoot = result.semanticRoot; graphHash = result.graphHash
        elapsedText = result.elapsedText; environmentSummary = result.environmentSummary
        graphData = result.graphData; artifactRows = result.artifactRows
        errorText = result.errorText
        isRunning = false
    }
}

private enum NativeRun {
    static let runID = "native-static-177403f-r1"
    static let scopeHash = "01eec8c9e0cd2ce613c349f6f9737075a4e88106b51d675ac02b77f1dd4acf58"
    static let rawLeaves = [
        "candidate-json.bin", "candidate-cbor.bin",
        "10-json-verifier.json", "11-json-graph.json", "12-json-roundtrip.json",
        "20-cbor-verifier.json", "21-cbor-graph.json", "22-cbor-roundtrip.json",
        "30-join-receipt.json", "31-authoritative-graph.json",
    ]

    static func perform() -> NativePresentation {
        var presentation = NativePresentation()
        var parentFD: Int32 = -1
        var runFD: Int32 = -1
        var consumed = false
        var creationAttempted = false
        var terminalAttempted = false
        var retained: [String: Data] = [:]
        var stage = "signed sandbox admission"
        defer {
            var ignored: Int32 = 0
            if runFD >= 0 { _ = epc_close_directory(runFD, &ignored) }
            if parentFD >= 0 { _ = epc_close_directory(parentFD, &ignored) }
        }
        do {
            var nativeError: Int32 = 0
            guard epc_sandbox_entitlements(&nativeError) == 1 else {
                throw PrivateComputeFailure("Signed sandbox/no-network entitlement admission failed; code=\(nativeError)")
            }
            guard Bundle.main.bundleIdentifier == "com.ergentics.PrivateCompute" else {
                throw PrivateComputeFailure("Unexpected application bundle identity")
            }
            stage = "app-private Application Support"
            let manager = FileManager.default
            let support = try manager.url(for: .applicationSupportDirectory,
                                          in: .userDomainMask, appropriateFor: nil, create: true)
            let privateRoot = support.appendingPathComponent("ErgenticsPrivateCompute", isDirectory: true)
            // Only a fresh private parent is created. Never chmod/repair an existing path.
            if !manager.fileExists(atPath: privateRoot.path) {
                try manager.createDirectory(at: privateRoot, withIntermediateDirectories: false,
                                            attributes: [.posixPermissions: NSNumber(value: 0o700)])
            }
            parentFD = privateRoot.path.withCString { epc_open_private_directory($0, &nativeError) }
            guard parentFD >= 0 else { throw nativeFailure(stage, nativeError) }
            presentation.runPath = privateRoot.appendingPathComponent(runID, isDirectory: true).path
            stage = "exclusive run admission"
            creationAttempted = true
            runFD = epc_create_run(parentFD, &nativeError)
            if runFD < 0 && nativeError == EEXIST {
                runFD = epc_open_run(parentFD, &nativeError)
                guard runFD >= 0 else { throw nativeFailure("retained run admission", nativeError) }
                let previous = try loadRetained(runFD, path: presentation.runPath)
                guard epc_revalidate_run(parentFD, runFD, &nativeError) == 0 else {
                    throw nativeFailure("retained replay root-name join", nativeError)
                }
                return previous
            }
            guard runFD >= 0 else { throw nativeFailure(stage, nativeError) }
            consumed = true
            let environment = ProcessInfo.processInfo.environment
            let hasEncodingKey = environment["__CF_USER_TEXT_ENCODING"] != nil
            presentation.environmentSummary = "\(environment.count) native environment entries · CF encoding key \(hasEncodingKey ? "present" : "absent") · values not collected"
            let startClock = epc_clock_sample()
            guard startClock.error == 0 else { throw nativeFailure("start clock", Int32(startClock.error)) }
            let startUTC = utc()
            stage = "start receipt"
            let start = try encode([
                "schema": "ergentics.private-compute.start.v1", "run_id": runID,
                "event": "NEW_LOCAL_STATIC_APP_RUN", "utc_start": startUTC,
                "clock_start": clockObject(startClock),
                "authority_vector": "00000000", "gate_e": "ABSTAIN",
                "environment_count": environment.count, "cf_encoding_key_present": hasEncodingKey,
                "environment_values_collected": false, "environment_is_empty_required": false,
                "signed_app_sandbox": true, "network_entitlements_absent_or_false": true,
                "predecessor_control_commit": "177403fb4a9e9cd726a53da1d85a6266c7a1604a",
                "scope_sha256_expected": scopeHash,
                "computation_mode": "IN_PROCESS_ALGORITHMIC_INDEPENDENCE_NOT_PROCESS_ISOLATION",
            ])
            try write(runFD, "00-start.json", start)
            retained["00-start.json"] = start

            stage = "bundled source scope and candidate admission"
            let scope = try bundled("native-app-scope.v1", extension: "json", cap: 65_536)
            guard PrivateComputeCore.sha256(scope) == scopeHash else {
                throw PrivateComputeFailure("Bundled scope hash mismatch")
            }
            let inputs = try PrivateComputeCore.admitCarriers(
                json: bundled("gate-e-static-bootstrap-json-input.v1", extension: "hex", cap: 8_193),
                cbor: bundled("gate-e-static-bootstrap-cbor-input.v1", extension: "hex", cap: 8_193))
            try write(runFD, "candidate-json.bin", inputs.json)
            retained["candidate-json.bin"] = inputs.json
            try write(runFD, "candidate-cbor.bin", inputs.cbor)
            retained["candidate-cbor.bin"] = inputs.cbor

            stage = "independent projections, reconstructions and graph join"
            let computation = try PrivateComputeCore.compute(inputs)
            presentation.mathematicalPass = true
            populate(&presentation, computation)
            stage = "raw result persistence"
            for leaf in rawLeaves where !leaf.hasPrefix("candidate-") {
                guard let bytes = computation.artifacts[leaf] else {
                    throw PrivateComputeFailure("Missing computed fixed leaf")
                }
                try write(runFD, leaf, bytes)
                retained[leaf] = bytes
            }
            let endClock = epc_clock_sample()
            guard endClock.error == 0, startClock.numerator == endClock.numerator,
                  startClock.denominator == endClock.denominator else {
                throw PrivateComputeFailure("End clock/timebase admission failed")
            }
            let exact = try PrivateComputeCore.exactNanoseconds(
                start: startClock.ticks, end: endClock.ticks,
                numerator: startClock.numerator, denominator: startClock.denominator)
            presentation.elapsedText = exact
            stage = "application image observation"
            guard let executable = Bundle.main.executableURL else {
                throw PrivateComputeFailure("Application executable URL unavailable")
            }
            let image = try boundedData(executable, cap: 32 * 1_024 * 1_024)
            stage = "terminal publication"
            guard epc_revalidate_run(parentFD, runFD, &nativeError) == 0 else {
                throw nativeFailure("preterminal root-name join", nativeError)
            }
            let terminal = try encode([
                "schema": "ergentics.private-compute.terminal.v1", "run_id": runID,
                "result": "STATIC_PASS_LOCAL", "mathematical_pass": true,
                "raw_leaves_written_readback_equal_and_synced": true,
                "authority_vector": "00000000", "projection_write_mask": "00000000",
                "gate_e": "ABSTAIN", "live_gate_e_roles_executed": false,
                "source_subject_commit": PrivateComputeCore.sourceCommit,
                "source_subject_tree": PrivateComputeCore.sourceTree,
                "source_subject_identity": PrivateComputeCore.sourceIdentity,
                "scope_sha256": scopeHash, "application_image_sha256": PrivateComputeCore.sha256(image),
                "image_observation_limit": "Named bundle image observation, not mapped-vnode bind",
                "graph_merkle_root": computation.merkleRoot, "semantic_root": computation.semanticRoot,
                "graph_frame_sha256": computation.graphHash,
                "utc_start": startUTC, "utc_end": utc(),
                "clock_start": clockObject(startClock), "clock_end": clockObject(endClock),
                "exact_elapsed_nanoseconds": exact,
                "timing_scope": "mach_absolute_time start through raw result persistence; system sleep, terminal publication and postflight excluded. Not CPU time or energy.",
                "energy_ergs": NSNull(), "energy_reason": "NOT_MEASURED",
                "artifacts": manifest(retained),
                "environment_summary": presentation.environmentSummary,
                "historical_bootstrap": "FAIL_RETAINED_CAUSE_UNIDENTIFIED_NO_RETRY",
                "retention_limit": "Local app-container retention, not remote archival backup or unconditional power-loss guarantee",
                "terminal_limit": "Terminal bytes precede final readback; whole-app success also requires postflight",
                "digest_rule": "No self digest; this terminal joins every earlier leaf by hash and byte count",
            ])
            terminalAttempted = true
            try write(runFD, "90-terminal.json", terminal)
            retained["90-terminal.json"] = terminal
            stage = "complete retained readback"
            for (leaf, expected) in retained {
                guard try read(runFD, leaf) == expected else {
                    throw PrivateComputeFailure("Postflight byte mismatch: " + leaf)
                }
            }
            guard epc_revalidate_run(parentFD, runFD, &nativeError) == 0 else {
                throw nativeFailure("postflight root-name join", nativeError)
            }
            presentation.persistencePass = true
            presentation.status = "Static verification passed"
            presentation.detail = "Independent JSON + CBOR reconstructions agree. All 12 raw leaves were saved and read back. Gate E remains ABSTAIN."
            presentation.artifactRows = rows(retained)
        } catch {
            presentation.status = presentation.mathematicalPass ? "Math passed · persistence incomplete" : "Stopped · result not admitted"
            presentation.detail = consumed ? "This app run is consumed. Its retained prefix will not be retried, repaired or removed." : (creationAttempted ? "Run admission stopped. Any existing or newly created prefix is retained unchanged; no retry." : "Admission stopped before run creation was attempted.")
            presentation.errorText = stage + ": " + String(describing: error)
            if consumed && !terminalAttempted && runFD >= 0 {
                terminalAttempted = true
                do {
                    let failure = try encode([
                        "schema": "ergentics.private-compute.terminal.v1", "run_id": runID,
                        "result": "FAIL_RETAINED_NO_RETRY", "stage": stage,
                        "error": String(String(describing: error).prefix(1_024)),
                        "mathematical_pass": presentation.mathematicalPass,
                        "authority_vector": "00000000", "gate_e": "ABSTAIN",
                        "utc_end": utc(), "artifacts": manifest(retained),
                    ])
                    try write(runFD, "90-terminal.json", failure)
                    retained["90-terminal.json"] = failure
                } catch {
                    presentation.errorText = (presentation.errorText ?? "") + " · terminal publication also failed: " + String(describing: error)
                }
            }
            presentation.artifactRows = rows(retained)
        }
        return presentation
    }

    private static func loadRetained(_ fd: Int32, path: String) throws -> NativePresentation {
        var result = NativePresentation()
        result.runPath = path
        let terminal = try read(fd, "90-terminal.json")
        guard let object = try JSONSerialization.jsonObject(with: terminal) as? [String: Any],
              object["schema"] as? String == "ergentics.private-compute.terminal.v1",
              object["run_id"] as? String == runID,
              object["authority_vector"] as? String == "00000000",
              object["gate_e"] as? String == "ABSTAIN",
              let entries = object["artifacts"] as? [[String: Any]]
        else { throw PrivateComputeFailure("Retained terminal framing does not match") }
        guard object["result"] as? String == "STATIC_PASS_LOCAL" else {
            result.status = "Prior run retained · no retry"
            result.detail = "An existing unsuccessful run prevents new computation."
            result.errorText = (object["stage"] as? String ?? "Unknown stage") + ": " + (object["error"] as? String ?? "Incomplete terminal")
            return result
        }
        guard entries.count == 11, object["scope_sha256"] as? String == scopeHash,
              object["projection_write_mask"] as? String == "00000000",
              object["mathematical_pass"] as? Bool == true,
              object["raw_leaves_written_readback_equal_and_synced"] as? Bool == true,
              object["live_gate_e_roles_executed"] as? Bool == false,
              object["source_subject_commit"] as? String == PrivateComputeCore.sourceCommit,
              object["source_subject_tree"] as? String == PrivateComputeCore.sourceTree,
              object["source_subject_identity"] as? String == PrivateComputeCore.sourceIdentity else {
            throw PrivateComputeFailure("Retained manifest identity/count mismatch")
        }
        var artifacts: [String: Data] = [:]
        for item in entries {
            guard let name = item["name"] as? String,
                  (rawLeaves + ["00-start.json"]).contains(name), artifacts[name] == nil,
                  let size = item["bytes"] as? Int, let hash = item["sha256"] as? String
            else { throw PrivateComputeFailure("Retained manifest entry invalid") }
            let data = try read(fd, name)
            guard data.count == size, PrivateComputeCore.sha256(data) == hash else {
                throw PrivateComputeFailure("Retained artifact hash mismatch: " + name)
            }
            artifacts[name] = data
        }
        let raw = artifacts.filter { $0.key != "00-start.json" }
        guard let startBytes = artifacts["00-start.json"],
              let start = try JSONSerialization.jsonObject(with: startBytes) as? [String: Any],
              start["schema"] as? String == "ergentics.private-compute.start.v1",
              start["run_id"] as? String == runID,
              start["scope_sha256_expected"] as? String == scopeHash,
              start["predecessor_control_commit"] as? String == "177403fb4a9e9cd726a53da1d85a6266c7a1604a",
              start["authority_vector"] as? String == "00000000",
              start["gate_e"] as? String == "ABSTAIN",
              let startClock = start["clock_start"] as? [String: Any],
              let terminalStart = object["clock_start"] as? [String: Any],
              let endClock = object["clock_end"] as? [String: Any],
              try encode(startClock) == encode(terminalStart),
              let startUTC = start["utc_start"] as? String,
              startUTC == object["utc_start"] as? String,
              startClock["raw_error"] as? Int == 0, endClock["raw_error"] as? Int == 0,
              let startTicks = (startClock["ticks"] as? String).flatMap(UInt64.init),
              let endTicks = (endClock["ticks"] as? String).flatMap(UInt64.init),
              let numerator = (startClock["numerator"] as? String).flatMap(UInt32.init),
              let denominator = (startClock["denominator"] as? String).flatMap(UInt32.init),
              endClock["numerator"] as? String == String(numerator),
              endClock["denominator"] as? String == String(denominator) else {
            throw PrivateComputeFailure("Retained start/terminal provenance or clock join failed")
        }
        let exactElapsed = try PrivateComputeCore.exactNanoseconds(
            start: startTicks, end: endTicks, numerator: numerator, denominator: denominator)
        guard object["exact_elapsed_nanoseconds"] as? String == exactElapsed else {
            throw PrivateComputeFailure("Retained duration does not equal raw rational clock delta")
        }
        let computation = try PrivateComputeCore.validateRetained(raw)
        guard computation.graphHash == object["graph_frame_sha256"] as? String,
              computation.semanticRoot == object["semantic_root"] as? String,
              computation.merkleRoot == object["graph_merkle_root"] as? String else {
            throw PrivateComputeFailure("Retained terminal graph binding mismatch")
        }
        populate(&result, computation)
        result.mathematicalPass = true; result.persistencePass = true
        result.status = "Retained static result · revalidated"
        result.detail = "Read-only manifest and independent-join replay. No new run or receipt was created. Gate E remains ABSTAIN."
        result.elapsedText = exactElapsed
        result.environmentSummary = object["environment_summary"] as? String ?? "Unobserved"
        artifacts["90-terminal.json"] = terminal
        result.artifactRows = rows(artifacts)
        return result
    }

    private static func populate(_ value: inout NativePresentation, _ result: StaticComputation) {
        value.graphData = result.artifacts["31-authoritative-graph.json"]
        value.merkleRoot = result.merkleRoot; value.semanticRoot = result.semanticRoot
        value.graphHash = result.graphHash
    }
    private static func utc() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }
    private static func clockObject(_ sample: EPCClockSample) -> [String: Any] {
        ["ticks": String(sample.ticks), "numerator": String(sample.numerator),
         "denominator": String(sample.denominator), "raw_error": sample.error]
    }
    private static func rows(_ artifacts: [String: Data]) -> [ArtifactRow] {
        artifacts.keys.sorted().map { name in
            let bytes = artifacts[name]!
            return ArtifactRow(name: name, bytes: bytes.count, sha256: PrivateComputeCore.sha256(bytes))
        }
    }
    private static func manifest(_ artifacts: [String: Data]) -> [[String: Any]] {
        rows(artifacts).map { ["name": $0.name, "bytes": $0.bytes, "sha256": $0.sha256] }
    }
    private static func encode(_ value: [String: Any]) throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .withoutEscapingSlashes])
        guard data.count < 1_048_576 else { throw PrivateComputeFailure("Outer receipt exceeds cap") }
        return data
    }
    private static func nativeFailure(_ stage: String, _ error: Int32) -> PrivateComputeFailure {
        PrivateComputeFailure(stage + " failed; native_code=\(error)")
    }
    private static func write(_ fd: Int32, _ leaf: String, _ bytes: Data) throws {
        var error: Int32 = 0
        let status = leaf.withCString { name in
            bytes.withUnsafeBytes { pointer in
                epc_write_leaf(fd, name, pointer.bindMemory(to: UInt8.self).baseAddress, bytes.count, &error)
            }
        }
        guard status == 0 else { throw nativeFailure("exclusive write/readback " + leaf, error) }
    }
    private static func read(_ fd: Int32, _ leaf: String) throws -> Data {
        var buffer = [UInt8](repeating: 0, count: 1_048_576)
        var error: Int32 = 0
        let count = leaf.withCString { name in
            buffer.withUnsafeMutableBufferPointer { pointer in
                epc_read_leaf(fd, name, pointer.baseAddress, pointer.count, &error)
            }
        }
        guard count >= 0 else { throw nativeFailure("retained read " + leaf, error) }
        return Data(buffer.prefix(Int(count)))
    }
    private static func bundled(_ name: String, extension ext: String, cap: Int) throws -> Data {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw PrivateComputeFailure("Missing bundled resource " + name)
        }
        return try boundedData(url, cap: cap)
    }
    private static func boundedData(_ url: URL, cap: Int) throws -> Data {
        let fd = url.path.withCString { Darwin.open($0, O_RDONLY | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK) }
        guard fd >= 0 else { throw nativeFailure("bundle open " + url.lastPathComponent, errno) }
        let handle = FileHandle(fileDescriptor: fd, closeOnDealloc: true)
        defer { try? handle.close() }
        var before = stat()
        guard fstat(fd, &before) == 0, (before.st_mode & S_IFMT) == S_IFREG,
              before.st_nlink == 1, before.st_size > 0, before.st_size <= cap else {
            throw PrivateComputeFailure("Bundle leaf is not an admitted bounded regular file")
        }
        let flags = fcntl(fd, F_GETFL)
        guard flags >= 0, fcntl(fd, F_SETFL, flags & ~O_NONBLOCK) == 0 else {
            throw nativeFailure("bundle descriptor flags", errno)
        }
        var data = Data()
        while let chunk = try handle.read(upToCount: min(65_536, cap + 1 - data.count)), !chunk.isEmpty {
            data.append(chunk)
            guard data.count <= cap else {
                throw PrivateComputeFailure("Bundle file exceeds cap: " + url.lastPathComponent)
            }
        }
        guard !data.isEmpty else {
            throw PrivateComputeFailure("Bundle file size outside cap: " + url.lastPathComponent)
        }
        var after = stat(), named = stat()
        guard fstat(fd, &after) == 0, lstat(url.path, &named) == 0,
              before.st_dev == after.st_dev, before.st_ino == after.st_ino,
              before.st_mode == after.st_mode, before.st_nlink == after.st_nlink,
              before.st_size == after.st_size, data.count == after.st_size,
              before.st_mtimespec.tv_sec == after.st_mtimespec.tv_sec,
              before.st_mtimespec.tv_nsec == after.st_mtimespec.tv_nsec,
              before.st_ctimespec.tv_sec == after.st_ctimespec.tv_sec,
              before.st_ctimespec.tv_nsec == after.st_ctimespec.tv_nsec,
              named.st_dev == after.st_dev, named.st_ino == after.st_ino else {
            throw PrivateComputeFailure("Bundle leaf changed during bounded read")
        }
        // Ancestors and mapped-image identity remain outside this named snapshot.
        return data
    }
}
