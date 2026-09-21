import CryptoKit
import Darwin
import Foundation
import Security

struct PrimeComputeReport: Sendable {
    let title: String
    let detail: String
    let device: String
    let elapsedSeconds: Double
    let session: URL
    let rawResult: Data
}

enum PrimeComputeBackend {
    struct Asset: Decodable { let seed: String; let relativePath: String; let sha256: String; let byteCount: Int }
    struct Helper: Decodable { let name: String; let identifier: String; let relativePath: String; let sha256: String; let byteCount: Int }
    struct Manifest: Decodable { let schemaVersion: Int; let models: [Asset]; let helpers: [Helper] }

    static func model(input: PrimeStudyInput, seed: String, execution: String,
                      cancellation: PrimeRuntimeCancellation) throws -> PrimeComputeReport {
        let (bundle, manifest) = try assets()
        guard ["1618", "2718", "3141"].contains(seed), ["host", "guest"].contains(execution),
              let asset = manifest.models.first(where: { $0.seed == seed }),
              asset.relativePath == "PrimeCompute/seed-\(seed).safetensors" else { throw failure("Unknown Prime checkpoint or route.") }
        let weights = bundle.appendingPathComponent("Contents/Resources/" + asset.relativePath)
        try verifyBytes(weights, count: asset.byteCount, sha: asset.sha256)
        let request = try input.request(weightsPath: weights.path, weightsSHA256: asset.sha256, execution: execution)
        return try run(name: "PrimeModelService", bundle: bundle, manifest: manifest,
                       request: request, cancellation: cancellation) { data, processID in
            let decoded = try modelResult(data, request: request, processID: processID)
            let names = ["Direct prediction", "Left summary", "Right summary", "Prediction using both summaries"]
            let detail = zip(names, decoded.ids).map { "\($0.0): \(PrimeStudyInput.label(for: $0.1))" }.joined(separator: "\n")
            return ("Prime · seed \(seed) · \(execution == "guest" ? "Guest → Metal" : "Host → Metal")", detail, decoded.device)
        }
    }

    static func geometry(pointsText: String, nodesText: String, sigma: Double, execution: String,
                         cancellation: PrimeRuntimeCancellation) throws -> PrimeComputeReport {
        let request = try geometryRequest(pointsText: pointsText, nodesText: nodesText, sigma: sigma, execution: execution)
        let (bundle, manifest) = try assets()
        return try run(name: "PrimeGeometryService", bundle: bundle, manifest: manifest,
                       request: request, cancellation: cancellation) { data, processID in
            let decoded = try geometryResult(data, request: request, processID: processID)
            let potential = decoded.potential, gradient = decoded.gradient
            let lines = potential.indices.map { i in
                "Point \(i + 1): potential \(potential[i]); gradient (\(gradient[2*i]), \(gradient[2*i+1]))"
            }
            return ("Geometry · \(execution == "guest" ? "Guest → Metal" : "Host → Metal")", lines.joined(separator: "\n"), decoded.device)
        }
    }

    static func geometryRequest(pointsText: String, nodesText: String, sigma: Double, execution: String) throws -> Data {
        guard pointsText.utf8.count <= 32768, nodesText.utf8.count <= 32768,
              sigma.isFinite, sigma > 0, ["host", "guest"].contains(execution) else {
            throw failure("Use a positive finite width and a supported execution route.")
        }
        let points = try JSONDecoder().decode([[Double]].self, from: Data(pointsText.utf8))
        let nodes = try JSONDecoder().decode([[Double]].self, from: Data(nodesText.utf8))
        guard (1...200).contains(points.count), (1...64).contains(nodes.count),
              points.allSatisfy({ $0.count == 2 && $0.allSatisfy { $0.isFinite && Float($0).isFinite } }),
              nodes.allSatisfy({ $0.count == 3 && $0.allSatisfy { $0.isFinite && Float($0).isFinite } }), validSigma(sigma) else {
            throw failure("Enter 1–200 [x,y] points and 1–64 [x,y,weight] nodes, all finite numbers.")
        }
        return try JSONSerialization.data(withJSONObject: ["points":points, "nodes":nodes.map { ["x":$0[0], "y":$0[1], "weight":$0[2]] }, "sigma":sigma, "execution":execution], options:[.sortedKeys])
    }

    struct ModelResult { let ids: [Int]; let device: String }
    struct GeometryResult { let potential: [Double]; let gradient: [Double]; let device: String }

    // Pure result decoders are also exercised with altered receipts in tests.
    // The signed helper owns inference; these joins prevent displaying a result
    // for a different request, process, candidate or returned feedback chain.
    static func modelResult(_ data: Data, request: Data, processID: Int32) throws -> ModelResult {
        let r = try boundResult(data, request: request, processID: processID), q = try object(request)
        guard r["schema"] as? String == "prime_10m_feedback_inference_result_v2",
              r["trainingPerformed"] as? Bool == false, r["modelWeightsInGuest"] as? Bool == false,
              integer(r["parameterCount"]) == 10227968, integer(r["tensorCount"]) == 74,
              let expectedSHA = q["weightsSHA256"] as? String,
              (r["weightsBefore"] as? [String: Any])?["sha256"] as? String == expectedSHA,
              (r["weightsAfter"] as? [String: Any])?["sha256"] as? String == expectedSHA,
              let requested = q["cases"] as? [[String: Any]], requested.count == 1,
              let cases = r["cases"] as? [[String: Any]], cases.count == 1,
              cases[0]["id"] as? String == requested[0]["id"] as? String,
              cases[0]["status"] as? String == "completed",
              let jobs = requested[0]["jobs"] as? [[String: Any]], jobs.count == 4,
              let rows = cases[0]["predictions"] as? [[String: Any]], rows.count == 4,
              let device = r["device"] as? String, !device.isEmpty else {
            throw failure("Prime returned an incomplete model result.")
        }
        let ids = rows.compactMap { integer($0["predictionTokenID"]) }
        guard ids.count == 4, ids.allSatisfy({ (0..<16384).contains($0) }) else {
            throw failure("Prime returned a token outside its vocabulary.")
        }
        var inputs = [[Int]]()
        for j in 0..<4 {
            guard var expected = integers(jobs[j]["inputTokenIDs"]),
                  let bindings = jobs[j]["feedbackBindings"] as? [[String: Any]],
                  bindings.count == (j == 3 ? 2 : 0),
                  rows[j]["id"] as? String == requested[0]["id"] as? String,
                  rows[j]["logitsFinite"] as? Bool == true else { throw failure("Prime's model jobs did not match this request.") }
            for (i, b) in bindings.enumerated() {
                guard let source = integer(b["sourceJobIndex"]), source == i + 1, source < j,
                      let offset = integer(b["inputOffset"]), expected.indices.contains(offset), expected[offset] == 0 else {
                    throw failure("Prime's summary feedback binding is invalid.")
                }
                expected[offset] = ids[source]
            }
            guard integers(rows[j]["inputTokenIDs"]) == expected else { throw failure("Prime did not use the current candidate and summary values.") }
            inputs.append(expected)
        }
        if q["execution"] as? String == "guest" {
            guard let guest = cases[0]["guest"] as? [String: Any],
                  integers(guest["guestCommittedPredictions"]) == ids,
                  let observed = guest["observedInputTokenIDs"] as? [Any], observed.count == 4,
                  zip(observed, inputs).allSatisfy({ integers($0.0) == $0.1 }),
                  let o = guest["observations"] as? [String: Any], integer(o["status"]) == 0,
                  ["cleanupComplete", "guestInputChecksPassed", "registerChecksPassed", "codeImmutableValidated", "dataGuardValidated", "completionHVCCount"].allSatisfy({ integer(o[$0]) == 1 }),
                  ["callbackCount", "completedCount", "inferenceRequestCount", "inferenceReturnCount"].allSatisfy({ integer(o[$0]) == 4 }),
                  integer(o["runCount"]) == 5 else { throw failure("Prime's guest did not confirm this inference and its cleanup.") }
        }
        return ModelResult(ids: ids, device: device)
    }

    static func geometryResult(_ data: Data, request: Data, processID: Int32) throws -> GeometryResult {
        let r = try boundResult(data, request: request, processID: processID), q = try object(request)
        guard r["schema"] as? String == "prime_app_geometry_result_v1",
              r["learnedModelInvoked"] as? Bool == false, r["trainingPerformed"] as? Bool == false, r["CPUFallback"] as? Bool == false,
              let points = q["points"] as? [[Double]], let nodes = q["nodes"] as? [[String: Double]],
              let returnedPoints = r["points"] as? [[Double]], returnedPoints.count == points.count,
              zip(returnedPoints, points).allSatisfy({ floatWords($0.0) == floatWords($0.1) }),
              let returnedNodes = r["nodes"] as? [[String: Double]], returnedNodes.count == nodes.count,
              zip(returnedNodes, nodes).allSatisfy({ pair in ["x", "y", "weight"].allSatisfy { k in
                  guard let a = pair.0[k], let b = pair.1[k] else { return false }; return Float(a).bitPattern == Float(b).bitPattern
              } }),
              let sigma = q["sigma"] as? Double, let returnedSigma = r["sigma"] as? Double,
              Float(sigma).bitPattern == Float(returnedSigma).bitPattern,
              let potential = r["potential"] as? [Double], potential.count == points.count,
              let gradient = r["gradientXY"] as? [Double], gradient.count == points.count * 2,
              let words = floatWords(potential + gradient),
              integer(r["valueCount"]) == words.count,
              let validation = r["validation"] as? [String: Any], validation["CPUComparisonPassed"] as? Bool == true,
              validation["oneActualMetalDispatch"] as? Bool == true,
              let device = r["device"] as? String, !device.isEmpty else { throw failure("Prime returned an incomplete or mismatched geometry result.") }
        var littleEndian = words.map(\.littleEndian)
        let output = littleEndian.withUnsafeMutableBytes { Data($0) }
        guard r["outputSHA256"] as? String == sha(output) else { throw failure("Prime's numeric output binding does not match its values.") }
        if q["execution"] as? String == "guest" {
            let checksum = words.reduce(UInt64(0xcbf29ce484222325)) { ($0 ^ UInt64($1)) &* 0x100000001b3 }
            guard let g = r["guest"] as? [String: Any], integer(g["status"]) == 0,
                  ["cleanupComplete", "checksumMatched", "inputValidated", "replyValidated", "callbackCount", "completionHVCCount"].allSatisfy({ integer(g[$0]) == 1 }),
                  integer(g["runCount"]) == 2, integer(g["guestReadCount"]) == words.count,
                  unsigned(g["guestChecksum"]) == checksum, unsigned(g["hostExpectedChecksum"]) == checksum,
                  unsigned(r["guestChecksum"]) == checksum,
                  let observed = g["observedInput"] as? [String: Any], integer(observed["pointCount"]) == points.count,
                  integer(observed["nodeCount"]) == nodes.count,
                  let xy = observed["pointsXY"] as? [Double], xy.count == 400,
                  floatWords(Array(xy.prefix(points.count * 2))) == floatWords(points.flatMap { $0 }),
                  let nodeWords = observed["nodesXYWeight"] as? [Double], nodeWords.count == 192,
                  floatWords(Array(nodeWords.prefix(nodes.count * 3))) == floatWords(nodes.flatMap { [$0["x"]!, $0["y"]!, $0["weight"]!] }),
                  let observedSigma = observed["sigma"] as? Double, Float(observedSigma).bitPattern == Float(sigma).bitPattern,
                  let reply = g["observedReply"] as? [String: Any], integer(reply["valueCount"]) == words.count,
                  let values = reply["values"] as? [Double], values.count == 600,
                  floatWords(Array(values.prefix(words.count))) == words else { throw failure("Prime's guest did not confirm the actual geometry inputs, output and cleanup.") }
        }
        return GeometryResult(potential: potential, gradient: gradient, device: device)
    }

    private static func boundResult(_ data: Data, request: Data, processID: Int32) throws -> [String: Any] {
        let r = try object(data), q = try object(request)
        guard processID > 1, integer(r["processID"]) == Int(processID),
              r["requestSHA256"] as? String == sha(request), r["status"] as? String == "completed",
              let execution = q["execution"] as? String, ["host", "guest"].contains(execution),
              r["execution"] as? String == execution else { throw failure("Prime's result does not belong to this request and process.") }
        return r
    }
    private static func integer(_ value: Any?) -> Int? {
        guard let number = value as? NSNumber, CFGetTypeID(number) != CFBooleanGetTypeID() else { return nil }
        return Int(number.stringValue)
    }
    private static func unsigned(_ value: Any?) -> UInt64? {
        guard let number = value as? NSNumber, CFGetTypeID(number) != CFBooleanGetTypeID() else { return nil }
        return UInt64(number.stringValue)
    }
    private static func integers(_ value: Any?) -> [Int]? {
        guard let values = value as? [Any] else { return nil }
        let result = values.compactMap(integer); return result.count == values.count ? result : nil
    }
    private static func floatWords(_ values: [Double]) -> [UInt32]? {
        guard values.allSatisfy({ $0.isFinite && Float($0).isFinite }) else { return nil }
        return values.map { Float($0).bitPattern }
    }
    private static func validSigma(_ value: Double) -> Bool {
        let f = Float(value), squared = f * f
        return value.isFinite && f.isFinite && f > 0 && squared.isFinite && squared > 0 && (2 * squared).isFinite && (1 / squared).isFinite
    }

    private static func assets() throws -> (URL, Manifest) {
        let bundle = Bundle.main.bundleURL.resolvingSymlinksInPath()
        try verifySignature(bundle, identifier: "com.ergentics.provenance")
        let data = try Data(contentsOf: bundle.appendingPathComponent("Contents/Resources/PrimeComputeAssets.json"))
        guard data.count <= 32768 else { throw failure("Prime asset manifest is too large.") }
        let manifest = try JSONDecoder().decode(Manifest.self, from: data)
        guard manifest.schemaVersion == 1, Set(manifest.models.map(\.seed)) == ["1618","2718","3141"],
              manifest.models.count == 3, manifest.helpers.count == 2 else { throw failure("Prime assets are incomplete.") }
        return (bundle, manifest)
    }

    private static func run(name: String, bundle: URL, manifest: Manifest, request: Data,
                            cancellation: PrimeRuntimeCancellation,
                            decode: (Data, Int32) throws -> (String, String, String)) throws -> PrimeComputeReport {
        if cancellation.isCancelled { throw CancellationError() }
        let identifier = name == "PrimeModelService" ? "com.ergentics.provenance.prime-model-service" : "com.ergentics.provenance.prime-geometry-service"
        guard let row = manifest.helpers.first(where: { $0.name == name }), row.identifier == identifier,
              row.relativePath == "Contents/Helpers/PrimeCompute/\(name)" else { throw failure("Prime service is missing.") }
        let helper = bundle.appendingPathComponent(row.relativePath)
        try verifyBytes(helper, count: row.byteCount, sha: row.sha256)
        try verifySignature(helper, identifier: identifier)
        let support = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).resolvingSymlinksInPath()
        let sessions = support.appendingPathComponent("PrimeComputeSessions")
        try directory(sessions, fresh: false)
        let root = sessions.appendingPathComponent(UUID().uuidString)
        try directory(root, fresh: true)
        let requestURL = root.appendingPathComponent("request.json")
        try request.write(to: requestURL, options: .withoutOverwriting)
        guard chmod(requestURL.path, 0o600) == 0 else { throw failure("Could not retain the private request.") }
        let output = root.appendingPathComponent("native")
        let process = try PrimeRuntimeBackend.execute(helper: helper,
            arguments:["--request", requestURL.path, "--output-directory", output.path],
            root:root, cancellation:cancellation, timeoutSeconds:120, outputLimit:4*1024*1024)
        try process.standardOutput.write(to:root.appendingPathComponent("stdout.jsonl"), options:.withoutOverwriting)
        let result = try Data(contentsOf: output.appendingPathComponent("result.json"))
        guard result.count <= 2*1024*1024 else { throw failure("Prime result exceeds its bound.") }
        let (title, detail, device) = try decode(result, process.processIdentifier)
        let receipt: [String:Any] = ["helper":name,"processIdentifier":process.processIdentifier,"elapsedSeconds":process.elapsedSeconds,"requestSHA256":sha(request),"resultSHA256":sha(result),"executionCompleted":true,"trainingPerformed":false]
        try JSONSerialization.data(withJSONObject:receipt, options:.sortedKeys).write(to:root.appendingPathComponent("session.json"), options:.withoutOverwriting)
        return .init(title:title, detail:detail, device:device, elapsedSeconds:process.elapsedSeconds, session:root, rawResult:result)
    }

    private static func directory(_ url:URL, fresh:Bool) throws {
        let made = mkdir(url.path, 0o700)
        guard made == 0 || (!fresh && errno == EEXIST) else { throw failure("Could not create private Prime session storage.") }
        var s = stat()
        guard lstat(url.path,&s) == 0, s.st_mode & S_IFMT == S_IFDIR, s.st_uid == geteuid(), s.st_mode & 0o7777 == 0o700 else { throw failure("Unexpected Prime session directory.") }
    }
    private static func verifySignature(_ url:URL, identifier:String) throws {
        var code:SecStaticCode?, requirement:SecRequirement?
        let rule = "anchor apple generic and identifier \"\(identifier)\" and certificate leaf[subject.OU] = \"ZCQ435U8JP\""
        guard SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess, let code,
              SecRequirementCreateWithString(rule as CFString, [], &requirement) == errSecSuccess, let requirement,
              SecStaticCodeCheckValidity(code, SecCSFlags(rawValue:kSecCSStrictValidate|kSecCSCheckAllArchitectures).union(.noNetworkAccess), requirement) == errSecSuccess else { throw failure("Prime service or app signature could not be verified.") }
    }
    private static func verifyBytes(_ url:URL, count:Int, sha expected:String) throws {
        guard count > 0, count <= 67108864 else { throw failure("Invalid Prime asset size.") }
        let data = try Data(contentsOf:url, options:.mappedIfSafe)
        guard data.count == count, sha(data) == expected else { throw failure("Prime asset bytes do not match the saved build.") }
    }
    private static func sha(_ data:Data) -> String { SHA256.hash(data:data).map { String(format:"%02x",$0) }.joined() }
    private static func object(_ data:Data) throws -> [String:Any] {
        guard let value = try JSONSerialization.jsonObject(with:data) as? [String:Any] else { throw failure("Invalid Prime JSON result.") };return value
    }
    private static func failure(_ message:String) -> PrimeRuntimeFailure { .init(message:message) }
}
