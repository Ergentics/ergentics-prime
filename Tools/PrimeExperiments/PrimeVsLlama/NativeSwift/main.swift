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

private struct InputCase: Decodable {
    let id: String
    let inputTokenIDs: [Int]
    enum CodingKeys: String, CodingKey { case id, inputTokenIDs }
    init(from decoder: Decoder) throws {
        try exactKeys(decoder, ["id", "inputTokenIDs"])
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        inputTokenIDs = try c.decode([Int].self, forKey: .inputTokenIDs)
        guard !id.isEmpty, id.utf8.count <= 128,
              id.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) }),
              (1...64).contains(inputTokenIDs.count),
              inputTokenIDs.allSatisfy({ (0..<16_384).contains($0) }) else {
            throw Failure("invalid case identifier or token IDs")
        }
    }
}

private struct Request: Decodable {
    let schema: String
    let weightsPath: String
    let weightsSHA256: String
    let cases: [InputCase]
    enum CodingKeys: String, CodingKey { case schema, weightsPath, weightsSHA256, cases }
    init(from decoder: Decoder) throws {
        try exactKeys(decoder, ["schema", "weightsPath", "weightsSHA256", "cases"])
        let c = try decoder.container(keyedBy: CodingKeys.self)
        schema = try c.decode(String.self, forKey: .schema)
        weightsPath = try c.decode(String.self, forKey: .weightsPath)
        weightsSHA256 = try c.decode(String.self, forKey: .weightsSHA256)
        cases = try c.decode([InputCase].self, forKey: .cases)
        guard schema == "prime_10m_inference_request_v1",
              weightsSHA256.utf8.count == 64,
              weightsSHA256.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }),
              (1...128).contains(cases.count), Set(cases.map(\.id)).count == cases.count else {
            throw Failure("invalid request schema, SHA256 or cases")
        }
    }
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

private struct Result: Encodable {
    let schema = "prime_10m_inference_result_v1"
    let status = "completed"
    let requestSHA256: String
    let weightsPath: String
    let weightsBefore: Binding
    let weightsAfter: Binding
    let tensorCount = 74
    let parameterCount = 10_227_968
    let vocabularySize = 16_384
    let evaluationMode = true
    let inference = "single_forward_final_position_full_vocabulary_argmax_lowest_id_tie"
    let processID: Int32
    let device: String
    let startedAtUptimeNanoseconds: UInt64
    let elapsedNanoseconds: UInt64
    let cases: [CaseResult]
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

private func run(requestPath: String, output: Output) throws {
    let requestData = try readBounded(requestPath, maximum: 131_072)
    let request = try JSONDecoder().decode(Request.self, from: requestData)
    try output.write(requestData, leaf: "request.json")
    let weightsData = try readBounded(request.weightsPath, maximum: 67_108_864)
    let before = Binding(byteCount: weightsData.count, sha256: digest(weightsData))
    guard before.sha256 == request.weightsSHA256 else { throw Failure("weights SHA256 mismatch") }
    guard let device = MTLCreateSystemDefaultDevice() else { throw Failure("no Metal device available") }
    try checkpoint()
    // loadArrays(data:) uses the same native safetensors loader as loadArrays(url:),
    // while ensuring the model consumes the exact bytes whose hash was just checked.
    let loadedWeights = try loadArrays(data: weightsData)
    guard loadedWeights.count == 74,
          loadedWeights.values.allSatisfy({ $0.dtype == .float32 }),
          loadedWeights.values.reduce(0, { $0 + $1.size }) == 10_227_968 else {
        throw Failure("expected exactly 74 F32 tensors and 10227968 parameters")
    }
    let model = makeModel()
    try model.update(parameters: ModuleParameters.unflattened(loadedWeights), verify: .all)
    eval(model)
    guard model.parameters().flattened().count == 74,
          model.parameters().flattened().reduce(0, { $0 + $1.1.size }) == 10_227_968,
          !model.training else { throw Failure("model parameter/evaluation-mode mismatch") }
    var results = [CaseResult]()
    for (index, c) in request.cases.enumerated() {
        try checkpoint()
        let caseStart = DispatchTime.now().uptimeNanoseconds
        let input = MLXArray(c.inputTokenIDs.map(Int32.init)).reshaped([1, c.inputTokenIDs.count])
        let logits = model(input, cache: nil)[0..., -1, 0...]
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
        let leaf = String(format: "case-%03d-logits.f32le", index)
        try output.write(raw, leaf: leaf)
        let result = CaseResult(id: c.id, inputTokenIDs: c.inputTokenIDs,
            predictionTokenID: prediction, predictionProbability: probability,
            maximumLogit: values[prediction], logitsFinite: true,
            logits: LogitsBinding(path: leaf, content: Binding(byteCount: raw.count, sha256: digest(raw))),
            elapsedNanoseconds: DispatchTime.now().uptimeNanoseconds - caseStart)
        try checkpoint()
        try output.write(json(result), leaf: String(format: "case-%03d.json", index))
        results.append(result)
        FileHandle.standardOutput.write(try json(result))
    }
    let afterData = try readBounded(request.weightsPath, maximum: 67_108_864)
    let after = Binding(byteCount: afterData.count, sha256: digest(afterData))
    guard before == after else { throw Failure("weights changed during inference") }
    guard try readBounded(requestPath, maximum: 131_072) == requestData else { throw Failure("request changed during inference") }
    try checkpoint()
    let result = Result(requestSHA256: digest(requestData), weightsPath: request.weightsPath,
        weightsBefore: before, weightsAfter: after, processID: getpid(), device: device.name,
        startedAtUptimeNanoseconds: start,
        elapsedNanoseconds: DispatchTime.now().uptimeNanoseconds - start, cases: results)
    try output.write(json(result), leaf: "result.json")
}

@main private enum Main {
    static func main() {
        _ = start
        umask(0o077)
        alarm(120)
        var output: Output?
        do {
            let args = CommandLine.arguments
            guard args.count == 5, args[1] == "--request", args[3] == "--output-directory" else {
                throw Failure("usage: Prime10MInference --request ABS_JSON --output-directory ABS_FRESH_DIRECTORY")
            }
            output = try Output(args[4])
            try run(requestPath: args[2], output: output!)
            alarm(0)
        } catch {
            let message = "Prime10M inference failed: \(error)"
            if let output {
                struct ErrorRecord: Encodable { let status = "failed"; let error: String; let processID: Int32 }
                if let data = try? json(ErrorRecord(error: message, processID: getpid())) {
                    try? output.write(data, leaf: "error.json")
                }
            }
            FileHandle.standardError.write(Data((message + "\n").utf8))
            exit(70)
        }
    }
}
