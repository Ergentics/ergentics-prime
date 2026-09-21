import CryptoKit
import Darwin
import ErgenticsLLM
import ErgenticsTokenizer
import ErgenticsSentencePiece
import Foundation
import MLX
import MLXNN

private struct Request: Decodable {
    let profile: String
    let question: String
    let maximumNewTokens: Int
    let labRoot: String
    let appendAnswerPrefix: Bool
}
private enum Failure: String, Error { case request, metadata, tokenizer, emptyPrompt, logits, changedInput, deadline }
private func hash(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }
private func json(_ data: Data) throws -> [String: Any] {
    guard let value = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw Failure.metadata }
    return value
}
private func validateLabRoot(_ path: String) throws {
    guard path.hasPrefix("/"), !path.utf8.contains(0), path.utf8.count <= 4096 else { throw Failure.request }
    // sys/proc_info.h defines PROC_PIDPATHINFO_MAXSIZE as 4 * MAXPATHLEN;
    // that C expression macro is not imported by Swift (4 * 1024 bytes).
    var executable = [CChar](repeating: 0, count: 4096)
    guard proc_pidpath(getpid(), &executable, UInt32(executable.count)) > 0 else { throw Failure.request }
    let image = String(cString: executable)
    guard let separator = image.lastIndex(of: "/"),
          path == String(image[..<separator]) + "/model-lab",
          let resolved = realpath(path, nil) else { throw Failure.request }
    defer { free(resolved) }
    guard String(cString: resolved) == path else { throw Failure.request }
    let fd = open(path, O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
    guard fd >= 0 else { throw Failure.request }
    defer { close(fd) }
    var metadata = stat()
    guard fstat(fd, &metadata) == 0, metadata.st_mode & S_IFMT == S_IFDIR else { throw Failure.request }
}
private func file(_ path: String, cap: Int) throws -> Data {
    let fd = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY)
    guard fd >= 0 else { throw Failure.metadata }
    defer { close(fd) }
    var s = stat()
    guard fstat(fd, &s) == 0, s.st_mode & S_IFMT == S_IFREG, s.st_nlink == 1,
          s.st_size > 0, s.st_size <= cap else { throw Failure.metadata }
    var data = Data(count: Int(s.st_size))
    try data.withUnsafeMutableBytes { b in
        var offset = 0
        while offset < b.count {
            let n = pread(fd, b.baseAddress!.advanced(by: offset), b.count - offset, off_t(offset))
            guard n > 0 else { throw Failure.changedInput }
            offset += n
        }
    }
    var after = stat()
    guard fstat(fd, &after) == 0, after.st_ino == s.st_ino, after.st_size == s.st_size,
          after.st_mtimespec.tv_sec == s.st_mtimespec.tv_sec, after.st_mtimespec.tv_nsec == s.st_mtimespec.tv_nsec,
          after.st_ctimespec.tv_sec == s.st_ctimespec.tv_sec, after.st_ctimespec.tv_nsec == s.st_ctimespec.tv_nsec else {
        throw Failure.changedInput
    }
    return data
}
private func emit(_ object: [String: Any]) throws {
    var data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes])
    data.append(10); try FileHandle.standardOutput.write(contentsOf: data)
}

// Use the same original in-process SentencePiece bridge as PrimeNativeTokenizer.
// Only the trained tokenizer/model manifests are bound here; this experiment
// does not re-read or claim to re-admit any training corpus.
private final class LearnedTokenizer {
    let handle: ErgenticsSpmHandle
    init(path: String, expectedPadID: Int32) throws {
        var error = [CChar](repeating: 0, count: 512)
        guard let handle = ergentics_spm_load(path, &error, error.count) else { throw Failure.tokenizer }
        var unk: Int32 = -1, bos: Int32 = -1, eos: Int32 = -1, pad: Int32 = -1
        guard ergentics_spm_special_ids(handle, &unk, &bos, &eos, &pad, &error, error.count) == 0,
              [unk, bos, eos, pad] == [0, 1, 2, expectedPadID] else {
            ergentics_spm_release(handle); throw Failure.tokenizer
        }
        self.handle = handle
    }
    deinit { ergentics_spm_release(handle) }
    func encode(_ text: String) throws -> [Int] {
        var error = [CChar](repeating: 0, count: 512), ids: UnsafeMutablePointer<Int32>?
        var count: size_t = 0
        let result = text.withCString { ergentics_spm_encode(handle, $0, &ids, &count, &error, error.count) }
        guard result == 0, count > 0, count <= 512, let ids else { throw Failure.tokenizer }
        defer { ergentics_spm_free_ids(ids) }
        return (0..<Int(count)).map { Int(ids[$0]) }
    }
    func decode(_ ids: [Int]) throws -> String {
        var error = [CChar](repeating: 0, count: 512), output: UnsafeMutablePointer<CChar>?
        let values = ids.map(Int32.init)
        let result = values.withUnsafeBufferPointer { ergentics_spm_decode(handle, $0.baseAddress, $0.count, &output, &error, error.count) }
        guard result == 0, let output else { throw Failure.tokenizer }
        defer { ergentics_spm_free_string(output) }
        return String(cString: output)
    }
}
private func byteText(_ ids: [Int]) -> String {
    var result = "", bytes: [UInt8] = []
    func flush() {
        guard !bytes.isEmpty else { return }
        result += String(bytes: bytes, encoding: .utf8) ?? "⟦bytes:" + bytes.map { String(format: "%02x", $0) }.joined() + "⟧"
        bytes.removeAll(keepingCapacity: true)
    }
    for id in ids {
        if (256...511).contains(id) { bytes.append(UInt8(id - 256)); continue }
        flush()
        switch id {
        case 2: result += "ABSTAIN\n"
        case 3: result += "Result:"
        default: result += "⟦token:\(id)⟧"
        }
    }
    flush(); return result
}

alarm(120)
do {
    guard CommandLine.arguments.count == 3, CommandLine.arguments[1] == "--request" else { throw Failure.request }
    let request = try JSONDecoder().decode(Request.self, from: file(CommandLine.arguments[2], cap: 128 * 1024))
    guard ["latin", "compositional_v2", "pmhnp"].contains(request.profile), !request.question.isEmpty,
          request.question.utf8.count <= 4096, !request.question.utf8.contains(0),
          (1...32).contains(request.maximumNewTokens),
          request.profile == "compositional_v2" || !request.appendAnswerPrefix else { throw Failure.request }
    try validateLabRoot(request.labRoot)
    let start = DispatchTime.now().uptimeNanoseconds
    let profile: NativeLabTrainProfile = request.profile == "latin" ? .latinLabV1 :
        (request.profile == "pmhnp" ? .pmhnpLabV2 : .compositionalV2)
    let weightsURL = NativeLabCheckpoint.weightsURL(labRoot: request.labRoot, profile: profile)
    let manifestURL = NativeLabCheckpoint.manifestURL(labRoot: request.labRoot, profile: profile)
    let manifestData = try file(manifestURL.path, cap: 1024 * 1024), manifest = try json(manifestData)
    let vocab = request.profile == "latin" ? 16384 : (request.profile == "pmhnp" ? 8192 : 512)
    guard manifest["model_family_id"] as? String == profile.modelFamilyID,
          manifest["tokenizer_id"] as? String == profile.tokenizerID,
          manifest["d_model"] as? Int == 512, manifest["n_layers"] as? Int == 8,
          manifest["n_heads"] as? Int == 8, manifest["d_ff"] as? Int == 2048,
          manifest["vocab_size"] as? Int == vocab else { throw Failure.metadata }
    let weightsData = try file(weightsURL.path, cap: 160 * 1024 * 1024)
    let weightsSHA = hash(weightsData)
    if let expected = manifest["weights_sha256"] as? String, expected != weightsSHA { throw Failure.changedInput }
    let learned: LearnedTokenizer?
    var tokenizerBinding: [String: Any] = ["id": profile.tokenizerID]
    var tokenizerInputs: [(String, Data)] = []
    if request.profile != "compositional_v2" {
        let base = request.labRoot + "/tokenizer/" + profile.tokenizerID + "/"
        let tokenizerManifest = try file(base + "manifest.json", cap: 64 * 1024)
        let metadata = try json(tokenizerManifest), model = try file(base + "model.spm", cap: 1024 * 1024)
        let expectedModelSHA = request.profile == "pmhnp" ? manifest["spm_sha256"] : metadata["model_sha256"]
        guard metadata["vocab_size"] as? Int == vocab,
              metadata["tokenizer_id"] as? String == profile.tokenizerID,
              expectedModelSHA as? String == hash(model) else { throw Failure.metadata }
        tokenizerBinding["manifestSHA256"] = hash(tokenizerManifest); tokenizerBinding["modelSHA256"] = hash(model)
        // PMHNP's <pad> piece is a user symbol; its actual native pad ID is -1.
        let pad: Int32 = request.profile == "pmhnp" ? -1 : 3
        tokenizerBinding["specialTokenIDs"] = ["unk": 0, "bos": 1, "eos": 2, "pad": Int(pad)]
        learned = try LearnedTokenizer(path: base + "model.spm", expectedPadID: pad)
        tokenizerInputs = [(base + "manifest.json", tokenizerManifest), (base + "model.spm", model)]
    } else {
        learned = nil
        let path = request.labRoot + "/" + PrimeNativeByteTokenizer.relativeLabDir + "/manifest.json"
        let bytes = try file(path, cap: 64 * 1024), metadata = try json(bytes)
        let expectedSpecials = ["pad": PrimeNativeByteTokenizer.padTokenID,
            "beginning_of_sequence": PrimeNativeByteTokenizer.beginningOfSequenceTokenID,
            "completion_abstain": PrimeNativeByteTokenizer.completionAbstainTokenID,
            "completion_result": PrimeNativeByteTokenizer.completionResultTokenID,
            "end_of_sequence": PrimeNativeByteTokenizer.endOfSequenceTokenID]
        guard manifest["byte_tokenizer_manifest_sha256"] as? String == hash(bytes),
              metadata["tokenizer_id"] as? String == PrimeNativeByteTokenizer.tokenizerID,
              metadata["schema_version"] as? String == PrimeNativeByteTokenizer.schemaVersion,
              metadata["algorithm"] as? String == "nfc_utf8_byte_offset",
              metadata["unicode_normalization"] as? String == "NFC",
              metadata["token_space_size"] as? Int == vocab,
              metadata["bound_model_vocabulary_size"] as? Int == PrimeNativeByteTokenizer.boundModelVocabularySize,
              metadata["byte_token_base"] as? Int == PrimeNativeByteTokenizer.byteTokenBase,
              metadata["byte_token_count"] as? Int == 256,
              let range = metadata["byte_token_range"] as? [String: Int],
              range["lower_bound"] == PrimeNativeByteTokenizer.byteTokenRange.lowerBound,
              range["upper_bound"] == PrimeNativeByteTokenizer.byteTokenRange.upperBound,
              let symbols = metadata["special_tokens"] as? [[String: Any]],
              symbols.count == expectedSpecials.count,
              Set(symbols.compactMap { $0["name"] as? String }).count == expectedSpecials.count,
              symbols.allSatisfy({ symbol in
                  guard let name = symbol["name"] as? String, let id = symbol["token_id"] as? Int else { return false }
                  return expectedSpecials[name] == id
              }) else { throw Failure.tokenizer }
        tokenizerBinding["manifestSHA256"] = hash(bytes)
        tokenizerBinding["specialTokenIDs"] = expectedSpecials
        tokenizerBinding["byteTokenBase"] = PrimeNativeByteTokenizer.byteTokenBase
        tokenizerInputs = [(path, bytes)]
    }
    var effectivePrompt = request.question.precomposedStringWithCanonicalMapping
    if request.appendAnswerPrefix { effectivePrompt += "\nAnswer:\n" }
    var ids = try learned?.encode(effectivePrompt) ?? PrimeNativeByteTokenizer.encodePromptPrefix(effectivePrompt, maxSeqLen: 512)
    guard !ids.isEmpty, ids.count + request.maximumNewTokens <= 512,
          ids.allSatisfy({ (0..<vocab).contains($0) }),
          learned != nil || 1 + effectivePrompt.utf8.count == ids.count else { throw Failure.emptyPrompt }
    let promptIDs = ids
    let config = NativeLabCheckpoint.modelConfig(labRoot: request.labRoot, vocabSize: vocab, profile: profile)
    guard config.maxSeqLen == 512, config.vocabSize == vocab,
          config.dModel == 512, config.nLayers == 8, config.nHeads == 8, config.dFf == 2048 else { throw Failure.metadata }
    let model = NativeTinyDecoder(config: config)
    eval(model)
    try NativeLabCheckpoint.loadWeights(into: model, weightsURL: weightsURL)
    model.train(false)
    var generated: [Int] = [], output = "", stop = "tokenLimit"
    let eos = learned != nil ? 2 : PrimeNativeByteTokenizer.endOfSequenceTokenID
    for ordinal in 0..<request.maximumNewTokens {
        guard DispatchTime.now().uptimeNanoseconds - start < 110_000_000_000 else { throw Failure.deadline }
        let logits = model.forward(tokenIds: ids)
        eval(logits)
        let row = logits[0, ids.count - 1].asArray(Float.self)
        guard row.count == vocab, row.allSatisfy(\.isFinite) else { throw Failure.logits }
        var next = 0
        for i in 1..<row.count where row[i] > row[next] { next = i }
        generated.append(next)
        let payload = next == eos ? Array(generated.dropLast()) : generated
        output = try learned?.decode(payload) ?? byteText(payload)
        try emit(["type": "token", "ordinal": ordinal, "tokenID": next, "renderedOutput": output])
        if next == eos { stop = "endOfSequence"; break }
        ids.append(next)
    }
    guard try file(manifestURL.path, cap: 1024 * 1024) == manifestData,
          hash(try file(weightsURL.path, cap: 160 * 1024 * 1024)) == weightsSHA else { throw Failure.changedInput }
    for (path, bytes) in tokenizerInputs {
        guard try file(path, cap: 1024 * 1024) == bytes else { throw Failure.changedInput }
    }
    try validateLabRoot(request.labRoot)
    try emit(["type": "result", "schema": "prime_native_checkpoint_comparison_v1", "profile": request.profile,
        "modelFamilyID": profile.modelFamilyID, "weightsSHA256": weightsSHA,
        "trainManifestSHA256": hash(manifestData), "tokenizer": tokenizerBinding,
        "questionSHA256": hash(Data(request.question.utf8)), "effectivePromptSHA256": hash(Data(effectivePrompt.utf8)),
        "inputTransform": learned != nil ? "NFC_then_original_SentencePiece_no_added_BOS_or_EOS" :
            (request.appendAnswerPrefix ? "NFC_append_LF_Answer_colon_LF_then_BOS_byte512" : "NFC_then_BOS_byte512"),
        "promptTokenIDs": promptIDs, "generatedTokenIDs": generated, "renderedOutput": output,
        "stopReason": stop, "maximumNewTokens": request.maximumNewTokens,
        "corpusRead": false, "trainingPerformed": false,
        "scope": "retained_checkpoint_inference_experiment_not_corpus_or_product_admission"])
} catch {
    fputs("Native comparison failed: \(error)\n", stderr)
    exit(70)
}
