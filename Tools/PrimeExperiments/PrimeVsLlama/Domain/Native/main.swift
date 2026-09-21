import CryptoKit
import Darwin
import Foundation
import Metal
import MLX
import MLXLLM
import MLXNN

// Inference only. Configuration and final-position indexing are taken from
// PrimeNativeMetalSwiftCanary; no historical rows, labels or training code are used.
private struct Failure: Error, CustomStringConvertible {
    let description: String
    init(_ message: String) { description = message }
}

private struct AnyKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { return nil }
}

private func exactKeys(_ decoder: Decoder, _ names: Set<String>) throws {
    let keys = try decoder.container(keyedBy: AnyKey.self).allKeys.map(\.stringValue)
    guard Set(keys) == names else { throw Failure("request has missing or unsupported keys") }
}

private struct Binding: Codable, Equatable {
    let byteCount: Int
    let sha256: String
}

private struct LogitsBinding: Encodable {
    let path: String
    let dtype = "float32_little_endian"
    let shape = [16_384]
    let content: Binding
}

private struct CaseResult: Encodable {
    let id: String
    let inputTokenIDs: [Int]
    let predictionTokenID: Int
    let predictionProbability: Double
    let maximumLogit: Float
    let logitsFinite: Bool
    let logits: LogitsBinding
    let elapsedNanoseconds: UInt64
}

private func digest(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

private let start = DispatchTime.now().uptimeNanoseconds
private func checkpoint() throws {
    // Swift initializes this global lazily. Read it before sampling the later
    // time, otherwise the first subtraction can underflow and trap.
    let origin = start
    let now = DispatchTime.now().uptimeNanoseconds
    guard now >= origin, now - origin < 115_000_000_000 else {
        throw Failure("inference deadline exceeded; completed case files remain partial evidence")
    }
}

private func canonicalPath(_ path: String) throws -> String {
    guard path.hasPrefix("/"), !path.utf8.contains(0) else { throw Failure("absolute path required") }
    guard let resolved = realpath(path, nil) else { throw Failure("path cannot be resolved") }
    defer { free(resolved) }
    guard String(cString: resolved) == path else { throw Failure("canonical path required") }
    return path
}

private func readBounded(_ path: String, maximum: Int) throws -> Data {
    _ = try canonicalPath(path)
    let fd = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY)
    guard fd >= 0 else { throw Failure("input open failed: \(errno)") }
    defer { close(fd) }
    var info = stat()
    guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFREG,
          info.st_size > 0, info.st_size <= maximum else { throw Failure("invalid input file size/type") }
    var data = Data(count: Int(info.st_size))
    var offset = 0
    try data.withUnsafeMutableBytes { raw in
        while offset < raw.count {
            try checkpoint()
            let n = read(fd, raw.baseAddress!.advanced(by: offset), min(1_048_576, raw.count - offset))
            if n < 0 && errno == EINTR { continue }
            guard n > 0 else { throw Failure("input read failed or changed") }
            offset += n
        }
    }
    var after = stat()
    guard fstat(fd, &after) == 0, after.st_size == info.st_size,
          after.st_mtimespec.tv_sec == info.st_mtimespec.tv_sec,
          after.st_mtimespec.tv_nsec == info.st_mtimespec.tv_nsec,
          after.st_ctimespec.tv_sec == info.st_ctimespec.tv_sec,
          after.st_ctimespec.tv_nsec == info.st_ctimespec.tv_nsec else {
        throw Failure("input changed while reading")
    }
    return data
}

private func json<T: Encodable>(_ object: T) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    var data = try encoder.encode(object)
    data.append(10)
    return data
}

private final class Output {
    let fd: Int32
    init(_ path: String) throws {
        let url = URL(fileURLWithPath: path)
        guard path.hasPrefix("/"), !path.utf8.contains(0),
              url.lastPathComponent != ".", url.lastPathComponent != "..",
              !url.lastPathComponent.isEmpty else { throw Failure("invalid output directory") }
        let parent = try canonicalPath(url.deletingLastPathComponent().path)
        guard parent + "/" + url.lastPathComponent == path else { throw Failure("canonical fresh output path required") }
        guard mkdir(path, 0o700) == 0 else { throw Failure("fresh output directory required: \(errno)") }
        fd = open(path, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard fd >= 0 else { throw Failure("output directory open failed") }
    }
    deinit { close(fd) }
    func write(_ data: Data, leaf: String) throws {
        guard !leaf.contains("/"), leaf != ".", leaf != ".." else { throw Failure("invalid output leaf") }
        let child = openat(fd, leaf, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0o600)
        guard child >= 0 else { throw Failure("exclusive output creation failed: \(errno)") }
        defer { close(child) }
        try data.withUnsafeBytes { raw in
            var position = 0
            while position < raw.count {
                let n = Darwin.write(child, raw.baseAddress!.advanced(by: position), raw.count - position)
                if n < 0 && errno == EINTR { try checkpoint(); continue }
                guard n > 0 else { throw Failure("output write failed") }
                position += n
            }
        }
        guard fchmod(child, 0o444) == 0, fsync(child) == 0, fsync(fd) == 0 else {
            throw Failure("output persistence failed")
        }
    }
}

private func makeModel() -> LlamaModel {
    MLXRandom.seed(1729)
    let configuration = LlamaConfiguration(
        hiddenSize: 256, hiddenLayers: 8, intermediateSize: 640,
        attentionHeads: 4, headDimensions: 64, rmsNormEps: 1e-5,
        vocabularySize: 16_384, kvHeads: 4, maxPositionEmbeddings: 2_048,
        ropeTheta: 10_000, tieWordEmbeddings: true)
    let model = LlamaModel(configuration)
    model.train(false)
    return model
}


private struct FeedbackBinding: Codable {
    let inputOffset: Int
    let sourceJobIndex: Int
    enum CodingKeys: String, CodingKey { case inputOffset, sourceJobIndex }
    init(from decoder: Decoder) throws {
        try exactKeys(decoder, ["inputOffset", "sourceJobIndex"])
        let c = try decoder.container(keyedBy: CodingKeys.self)
        inputOffset = try c.decode(Int.self, forKey:.inputOffset)
        sourceJobIndex = try c.decode(Int.self, forKey:.sourceJobIndex)
    }
}
private struct InputJob: Codable {
    let inputTokenIDs: [Int]
    let feedbackBindings: [FeedbackBinding]
    enum CodingKeys: String, CodingKey { case inputTokenIDs, feedbackBindings }
    init(from decoder: Decoder) throws {
        try exactKeys(decoder, ["inputTokenIDs", "feedbackBindings"])
        let c = try decoder.container(keyedBy: CodingKeys.self)
        inputTokenIDs = try c.decode([Int].self, forKey:.inputTokenIDs)
        feedbackBindings = try c.decode([FeedbackBinding].self, forKey:.feedbackBindings)
        guard (1...64).contains(inputTokenIDs.count), inputTokenIDs.allSatisfy({ (0..<16384).contains($0) }),
              feedbackBindings.count <= 2,
              Set(feedbackBindings.map(\.inputOffset)).count == feedbackBindings.count,
              feedbackBindings.allSatisfy({ inputTokenIDs.indices.contains($0.inputOffset) && inputTokenIDs[$0.inputOffset] == 0 }) else {
            throw Failure("invalid job or distinct zero feedback placeholders")
        }
    }
}
private struct InputCase: Decodable {
    let id: String
    let allowedValueMinimum: Int
    let allowedValueCount: Int
    let jobs: [InputJob]
    enum CodingKeys: String, CodingKey { case id, allowedValueMinimum, allowedValueCount, jobs }
    init(from decoder: Decoder) throws {
        try exactKeys(decoder, ["id", "allowedValueMinimum", "allowedValueCount", "jobs"])
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey:.id)
        allowedValueMinimum = try c.decode(Int.self, forKey:.allowedValueMinimum)
        allowedValueCount = try c.decode(Int.self, forKey:.allowedValueCount)
        jobs = try c.decode([InputJob].self, forKey:.jobs)
        let policy = (allowedValueMinimum == 0 && allowedValueCount == 16384) ||
            ([16,64].contains(allowedValueMinimum) && allowedValueCount == 8)
        guard !id.isEmpty, id.utf8.count <= 128,
              id.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) }),
              policy, (1...5).contains(jobs.count),
              jobs.enumerated().allSatisfy({ index, job in job.feedbackBindings.allSatisfy({ (0..<index).contains($0.sourceJobIndex) }) }) else {
            throw Failure("invalid case, feedback policy or source order")
        }
    }
}
private struct Request: Decodable {
    let schema: String
    let execution: String
    let weightsPath: String
    let weightsSHA256: String
    let cases: [InputCase]
    enum CodingKeys: String, CodingKey { case schema, execution, weightsPath, weightsSHA256, cases }
    init(from decoder: Decoder) throws {
        try exactKeys(decoder, ["schema", "execution", "weightsPath", "weightsSHA256", "cases"])
        let c = try decoder.container(keyedBy: CodingKeys.self)
        schema = try c.decode(String.self, forKey:.schema)
        execution = try c.decode(String.self, forKey:.execution)
        weightsPath = try c.decode(String.self, forKey:.weightsPath)
        weightsSHA256 = try c.decode(String.self, forKey:.weightsSHA256)
        cases = try c.decode([InputCase].self, forKey:.cases)
        guard schema == "prime_10m_feedback_inference_request_v2", ["host","guest"].contains(execution), weightsSHA256.utf8.count == 64,
              weightsSHA256.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }),
              (1...16).contains(cases.count), Set(cases.map(\.id)).count == cases.count else {
            throw Failure("invalid request schema, SHA256 or cases")
        }
    }
}

private struct Admission: Encodable {
    let identifier: String
    let team: String
    let observations: [String: Int64]
    let hostProcessContainment = "user_level_process_not_App_Sandbox"
    init(_ r: PrimeInferenceAdmissionResult) {
        var identifier = r.inspected_identifier, team = r.inspected_team
        self.identifier = withUnsafeBytes(of: &identifier) { String(cString: $0.bindMemory(to: CChar.self).baseAddress!) }
        self.team = withUnsafeBytes(of: &team) { String(cString: $0.bindMemory(to: CChar.self).baseAddress!) }
        observations = ["status":Int64(r.status), "reason":Int64(r.reason), "securityStatus":Int64(r.security_status),
            "effectiveEntitlementError":r.effective_entitlement_error,"signatureFlags":Int64(r.signature_flags),
            "identityMatches":Int64(r.identity_matches),"teamMatches":Int64(r.team_matches),
            "hardenedRuntime":Int64(r.hardened_runtime),"adHoc":Int64(r.ad_hoc),
            "entitlementCount":Int64(r.entitlement_count),"unexpectedEntitlementCount":Int64(r.unexpected_entitlement_count),
            "hypervisorEntitlementTrue":Int64(r.hypervisor_entitlement_true),"getTaskAllowPresent":Int64(r.get_task_allow_present),
            "appSandboxPresent":Int64(r.app_sandbox_present),"entitlementSetExact":Int64(r.entitlement_set_exact),
            "signatureValid":Int64(r.signature_valid),"effectiveHypervisorTrue":Int64(r.effective_hypervisor_true)]
    }
}

private struct GuestReceipt: Encodable {
    let observations: [String: Int64]
    let ownerThreadID: UInt64
    let elapsedNanoseconds: UInt64
    let guestCommittedPredictions: [UInt32]
    let observedInputTokenIDs: [[UInt32]]
    let exits: [[String: UInt64]]
    init(_ r: EPRPrimeGuestResult) {
        observations = ["status":Int64(r.status), "stage":Int64(r.stage), "failureCode":Int64(r.failureCode),
            "allowedMin":Int64(r.allowedMin),"allowedCount":Int64(r.allowedCount),
            "requestedCount":Int64(r.requestedCount),"completedCount":Int64(r.completedCount),
            "runCount":Int64(r.runCount),"exceptionCount":Int64(r.exceptionCount),
            "inferenceRequestCount":Int64(r.inferenceRequestCount),"inferenceReturnCount":Int64(r.inferenceReturnCount),
            "callbackCount":Int64(r.callbackCount),"completionHVCCount":Int64(r.completionHVCCount),
            "codeByteCount":Int64(r.codeByteCount),"codeImmutableValidated":Int64(r.codeImmutableValidated),
            "dataGuardValidated":Int64(r.dataGuardValidated),"registerChecksPassed":Int64(r.registerChecksPassed),
            "guestInputChecksPassed":Int64(r.guestInputChecksPassed),"vmCreateStatus":Int64(r.vmCreateStatus),
            "codeMapStatus":Int64(r.codeMapStatus),"dataMapStatus":Int64(r.dataMapStatus),
            "vcpuCreateStatus":Int64(r.vcpuCreateStatus),"codeProtectStatus":Int64(r.codeProtectStatus),
            "dataProtectStatus":Int64(r.dataProtectStatus),"watchdogCreateStatus":Int64(r.watchdogCreateStatus),
            "watchdogJoinStatus":Int64(r.watchdogJoinStatus),"watchdogWaitStatus":Int64(r.watchdogWaitStatus),
            "watchdogFired":Int64(r.watchdogFired),"watchdogExitCalls":Int64(r.watchdogExitCalls),
            "watchdogExitStatus":Int64(r.watchdogExitStatus),"vcpuDestroyStatus":Int64(r.vcpuDestroyStatus),
            "codeUnmapStatus":Int64(r.codeUnmapStatus),"dataUnmapStatus":Int64(r.dataUnmapStatus),
            "vmDestroyStatus":Int64(r.vmDestroyStatus),"codeMunmapStatus":Int64(r.codeMunmapStatus),
            "dataMunmapStatus":Int64(r.dataMunmapStatus),"cleanupComplete":Int64(r.cleanupComplete)]
        ownerThreadID = r.ownerThreadID; elapsedNanoseconds = r.elapsedNanoseconds
        var predictions = r.predictions
        guestCommittedPredictions = withUnsafeBytes(of: &predictions) { Array($0.bindMemory(to: UInt32.self).prefix(Int(min(r.completedCount, 5)))) }
        var jobs = r.observedJobs
        observedInputTokenIDs = withUnsafeBytes(of: &jobs) { raw in
            raw.bindMemory(to: EPRPrimeGuestJob.self).prefix(Int(min(r.callbackCount, 5))).map { j in
                var tokens = j.inputTokenIDs
                return withUnsafeBytes(of: &tokens) { Array($0.bindMemory(to: UInt32.self).prefix(Int(min(j.inputCount, 64)))) }
            }
        }
        var recordedExits = r.exits
        exits = withUnsafeBytes(of: &recordedExits) { raw in
            raw.bindMemory(to: EPRPrimeGuestExit.self).prefix(Int(min(r.runCount, 6))).map { e in
                ["runStatusBits":UInt64(UInt32(bitPattern:e.runStatus)),"reason":UInt64(e.reason),"pc":e.pc,
                 "cpsr":e.cpsr,"syndrome":e.syndrome,"virtualAddress":e.virtualAddress,"physicalAddress":e.physicalAddress,
                 "x0":e.x0,"x1":e.x1,"x2":e.x2,"x3":e.x3,
                 "x11":e.x11,"x12":e.x12,"x13":e.x13,"x28":e.x28,"x20":e.x20,"x21":e.x21,"x22":e.x22,"x23":e.x23,"x24":e.x24,"sctlr":e.sctlr,"validated":UInt64(e.validated)]
            }
        }
    }
}

private final class InferenceContext {
    let model: LlamaModel
    let output: Output
    let input: InputCase
    let caseIndex: Int
    var predictions = [CaseResult]()
    var failure: String?
    init(model: LlamaModel, output: Output, input: InputCase, caseIndex: Int) {
        self.model = model; self.output = output; self.input = input; self.caseIndex = caseIndex
    }
    func predict(_ inputTokenIDs: [Int]) throws -> UInt32 {
        try checkpoint()
        let jobIndex = predictions.count
        guard jobIndex < input.jobs.count else { throw Failure("extra guest inference request") }
        var expected = input.jobs[jobIndex].inputTokenIDs
        for binding in input.jobs[jobIndex].feedbackBindings {
            guard predictions.indices.contains(binding.sourceJobIndex) else { throw Failure("feedback source has not executed") }
            expected[binding.inputOffset] = predictions[binding.sourceJobIndex].predictionTokenID
        }
        // Guest mode checks IDs read from the stopped guest page; host mode checks its baseline materialization.
        guard expected == inputTokenIDs else { throw Failure("request does not bind actual source predictions") }
        let caseStart = DispatchTime.now().uptimeNanoseconds
        let array = MLXArray(inputTokenIDs.map(Int32.init)).reshaped([1, inputTokenIDs.count])
        let logits = model(array, cache: nil)[0..., -1, 0...]
        eval(logits)
        guard logits.shape == [1, 16_384] else { throw Failure("unexpected logits shape") }
        let values = logits.asType(.float32).asArray(Float.self)
        guard values.count == 16_384, values.allSatisfy(\.isFinite) else { throw Failure("non-finite logits") }
        var prediction = 0
        for i in 1..<values.count where values[i] > values[prediction] { prediction = i }
        let maximum = Double(values[prediction])
        let denominator = values.reduce(0.0) { $0 + exp(Double($1) - maximum) }
        let probability = 1.0 / denominator
        guard probability.isFinite, probability > 0, probability <= 1 else { throw Failure("non-finite probability") }
        var words = values.map { $0.bitPattern.littleEndian }
        let raw = words.withUnsafeMutableBytes { Data($0) }
        let prefix = String(format: "case-%03d-job-%02d", caseIndex, jobIndex)
        let leaf = prefix + "-logits.f32le"
        try output.write(raw, leaf: leaf)
        let result = CaseResult(id:input.id,inputTokenIDs:inputTokenIDs,
            predictionTokenID:prediction,predictionProbability:probability,maximumLogit:values[prediction],logitsFinite:true,
            logits:LogitsBinding(path:leaf,content:Binding(byteCount:raw.count,sha256:digest(raw))),
            elapsedNanoseconds:DispatchTime.now().uptimeNanoseconds-caseStart)
        try output.write(json(result),leaf:prefix+".json")
        predictions.append(result)
        FileHandle.standardOutput.write(try json(result))
        return UInt32(prediction)
    }
}

private func inferenceCallback(_ pointer: UnsafeMutableRawPointer?, _ tokens: UnsafePointer<UInt32>?,
                               _ count: UInt32, _ prediction: UnsafeMutablePointer<UInt32>?) -> Int32 {
    guard let pointer, let tokens, let prediction, count > 0, count <= 64 else { return -1 }
    let context = Unmanaged<InferenceContext>.fromOpaque(pointer).takeUnretainedValue()
    do {
        prediction.pointee = try context.predict(UnsafeBufferPointer(start:tokens,count:Int(count)).map(Int.init))
        return 0
    } catch {
        context.failure = String(describing:error)
        return -2
    }
}

private struct CaseGroup: Encodable {
    let id: String
    let status: String
    let guest: GuestReceipt?
    let predictions: [CaseResult]
    let callbackError: String?
}

private struct Result: Encodable {
    let schema = "prime_10m_feedback_inference_result_v2"
    let status = "completed"
    let execution: String
    let compute = "native_Swift_host_Metal"
    let requestSHA256: String
    let weightsPath: String
    let weightsBefore: Binding
    let weightsAfter: Binding
    let tensorCount = 74
    let parameterCount = 10_227_968
    let trainingPerformed = false
    let modelWeightsInGuest = false
    let admission: Admission
    let processID: Int32
    let device: String
    let elapsedNanoseconds: UInt64
    let cases: [CaseGroup]
}

private func run(requestPath: String, output: Output) throws {
    let requestData = try readBounded(requestPath, maximum:131_072)
    let request = try JSONDecoder().decode(Request.self,from:requestData)
    try output.write(requestData,leaf:"request.json")
    let rawAdmission = prime_inference_inspect_admission()
    let admission = Admission(rawAdmission)
    try output.write(json(admission),leaf:"admission.json")
    guard rawAdmission.status == 1 else { throw Failure("dedicated helper identity/entitlement admission failed") }
    let weightsData = try readBounded(request.weightsPath,maximum:67_108_864)
    let before = Binding(byteCount:weightsData.count,sha256:digest(weightsData))
    guard before.sha256 == request.weightsSHA256 else { throw Failure("weights SHA256 mismatch") }
    guard let device = MTLCreateSystemDefaultDevice() else { throw Failure("no Metal device available") }
    let loadedWeights = try loadArrays(data:weightsData)
    guard loadedWeights.count == 74, loadedWeights.values.allSatisfy({ $0.dtype == .float32 }),
          loadedWeights.values.reduce(0,{ $0 + $1.size }) == 10_227_968 else { throw Failure("expected original74 F32 tensors") }
    let model = makeModel()
    try model.update(parameters:ModuleParameters.unflattened(loadedWeights),verify:.all)
    eval(model)
    guard !model.training else { throw Failure("expected evaluation mode") }
    var groups = [CaseGroup]()
    for (index,c) in request.cases.enumerated() {
        try checkpoint()
        let context = InferenceContext(model:model,output:output,input:c,caseIndex:index)
        var guest: GuestReceipt? = nil
        var status: Int32 = 0
        if request.execution == "guest" {
            let jobs = c.jobs.map { job -> EPRPrimeGuestJob in
                var result = EPRPrimeGuestJob()
                result.inputCount = UInt32(job.inputTokenIDs.count)
                result.feedbackCount = UInt32(job.feedbackBindings.count)
                withUnsafeMutableBytes(of:&result.bindings) { raw in
                    let buffer = raw.bindMemory(to:EPRPrimeGuestFeedbackBinding.self)
                    for (i,binding) in job.feedbackBindings.enumerated() {
                        buffer[i].inputOffset = UInt32(binding.inputOffset)
                        buffer[i].sourceJobIndex = UInt32(binding.sourceJobIndex)
                    }
                }
                withUnsafeMutableBytes(of:&result.inputTokenIDs) { raw in
                    let buffer = raw.bindMemory(to:UInt32.self)
                    for (i,token) in job.inputTokenIDs.enumerated() { buffer[i] = UInt32(token) }
                }
                return result
            }
            var rawGuest = EPRPrimeGuestResult()
            status = jobs.withUnsafeBufferPointer { buffer in
                epr_prime_guest_run(buffer.baseAddress,UInt32(jobs.count),UInt32(c.allowedValueMinimum),UInt32(c.allowedValueCount),
                                    inferenceCallback,Unmanaged.passUnretained(context).toOpaque(),&rawGuest)
            }
            guest = GuestReceipt(rawGuest)
            let group = CaseGroup(id:c.id,status:status == 0 ? "completed" : status == 7 ? "stopped_invalid_feedback" : "failed",
                                  guest:guest,predictions:context.predictions,callbackError:context.failure)
            try output.write(json(group),leaf:String(format:"case-%03d-guest.json",index))
            guard status == 0 || status == 7, rawGuest.cleanupComplete == 1, context.failure == nil,
                  Int(rawGuest.callbackCount) == context.predictions.count,
                  guest!.guestCommittedPredictions.map(Int.init) == context.predictions.map(\.predictionTokenID) else {
                throw Failure("guest failed: status\(status), stage\(rawGuest.stage), code\(rawGuest.failureCode)")
            }
        } else {
            for job in c.jobs {
                var ids = job.inputTokenIDs
                var invalid = false
                for binding in job.feedbackBindings {
                    let value = context.predictions[binding.sourceJobIndex].predictionTokenID
                    if !(c.allowedValueMinimum..<(c.allowedValueMinimum+c.allowedValueCount)).contains(value) { invalid = true; break }
                    ids[binding.inputOffset] = value
                }
                if invalid { status = 7; break }
                _ = try context.predict(ids)
            }
        }
        let group = CaseGroup(id:c.id,status:status == 0 ? "completed" : "stopped_invalid_feedback",
                              guest:guest,predictions:context.predictions,callbackError:context.failure)
        groups.append(group)
    }
    let afterData = try readBounded(request.weightsPath,maximum:67_108_864)
    let after = Binding(byteCount:afterData.count,sha256:digest(afterData))
    guard before == after, try readBounded(requestPath,maximum:131_072) == requestData else { throw Failure("weights or request changed") }
    let result = Result(execution:request.execution,requestSHA256:digest(requestData),weightsPath:request.weightsPath,weightsBefore:before,weightsAfter:after,
                        admission:admission,processID:getpid(),device:device.name,
                        elapsedNanoseconds:DispatchTime.now().uptimeNanoseconds-start,cases:groups)
    try output.write(json(result),leaf:"result.json")
}

@main private enum Main {
    static func main() {
        _ = start; umask(0o077); alarm(120)
        var output: Output?
        do {
            let args = CommandLine.arguments
            guard args.count == 5, args[1] == "--request", args[3] == "--output-directory" else {
                throw Failure("usage: PrimeVCPUInference --request ABS_JSON --output-directory ABS_FRESH_DIRECTORY")
            }
            output = try Output(args[4])
            try run(requestPath:args[2],output:output!)
            alarm(0)
        } catch {
            let message = "Prime vCPU inference failed: \(error)"
            if let output {
                struct ErrorRecord: Encodable { let status = "failed"; let error:String; let processID:Int32 }
                if let data = try? json(ErrorRecord(error:message,processID:getpid())) { try? output.write(data,leaf:"error.json") }
            }
            FileHandle.standardError.write(Data((message+"\n").utf8)); exit(70)
        }
    }
}
