import Foundation

let disposalZeroSpan = DisposalJSONSpan(lowerBound: 0, upperBound: 0)

func disposalResourceData(_ name: String, extension extensionName: String) throws -> Data {
    try DisposalProjectionEmbeddedResources.data(name, extension: extensionName)
}

func disposalID(_ domain: String, _ components: [String]) -> String {
    var bytes = Data(domain.utf8)
    for component in components {
        bytes.append(0)
        bytes.append(contentsOf: component.utf8)
    }
    return disposalSHA256(bytes)
}

func disposalLengthFramedID(_ domain: String, _ components: [String]) -> String {
    var bytes = Data("ERGENTICS_DISPOSAL_LENGTH_FRAMED_ID_V1".utf8)
    disposalAppendUInt64BE(UInt64(domain.utf8.count), to: &bytes)
    bytes.append(contentsOf: domain.utf8)
    disposalAppendUInt64BE(UInt64(components.count), to: &bytes)
    for component in components {
        disposalAppendUInt64BE(UInt64(component.utf8.count), to: &bytes)
        bytes.append(contentsOf: component.utf8)
    }
    return disposalSHA256(bytes)
}

func disposalTargetID(
    invocationID: String,
    role: String,
    label: String,
    pid: Int,
    uniqueID: UInt64?,
    idVersion: UInt64?
) -> String {
    disposalID(
        "disposal-target-v1",
        [
            invocationID,
            role,
            label,
            String(pid),
            uniqueID.map(String.init) ?? "NULL",
            idVersion.map(String.init) ?? "NULL",
        ])
}

private func disposalAppendUInt64BE(_ value: UInt64, to data: inout Data) {
    var encoded = value.bigEndian
    withUnsafeBytes(of: &encoded) { data.append(contentsOf: $0) }
}

func disposalIsLowerHex(_ value: String, count: Int) -> Bool {
    value.utf8.count == count && value.utf8.allSatisfy {
        (0x30...0x39).contains($0) || (0x61...0x66).contains($0)
    }
}

func disposalRequireProjection(
    _ condition: @autoclosure () throws -> Bool,
    _ code: String,
    frameOrdinal: Int? = nil,
    detail: String = ""
) throws {
    guard try condition() else {
        throw DisposalProjectionRejection(
            code: code,
            frameOrdinal: frameOrdinal,
            detail: detail)
    }
}

extension DisposalDecodedFrame {
    func node(at pointer: String) -> DisposalJSONNode? {
        nodes.first { $0.jsonPointer == pointer }
    }

    func requiredString(at pointer: String) throws -> String {
        guard let node = node(at: pointer), case .string(let value) = node.scalar else {
            throw DisposalProjectionRejection(
                code: "FRAME_REQUIRED_STRING",
                frameOrdinal: ordinal,
                detail: pointer)
        }
        return value
    }

    func optionalString(at pointer: String) throws -> String? {
        guard let node = node(at: pointer) else { return nil }
        if case .null = node.scalar { return nil }
        guard case .string(let value) = node.scalar else {
            throw DisposalProjectionRejection(
                code: "FRAME_OPTIONAL_STRING",
                frameOrdinal: ordinal,
                detail: pointer)
        }
        return value
    }

    func requiredUInt64(at pointer: String) throws -> UInt64 {
        guard let node = node(at: pointer),
              case .numberLexeme(let lexeme) = node.scalar,
              let value = UInt64(lexeme),
              String(value) == lexeme
        else {
            throw DisposalProjectionRejection(
                code: "FRAME_REQUIRED_UINT64",
                frameOrdinal: ordinal,
                detail: pointer)
        }
        return value
    }

    func optionalUInt64(at pointer: String) throws -> UInt64? {
        guard let node = node(at: pointer) else { return nil }
        if case .null = node.scalar { return nil }
        guard case .numberLexeme(let lexeme) = node.scalar,
              let value = UInt64(lexeme),
              String(value) == lexeme
        else {
            throw DisposalProjectionRejection(
                code: "FRAME_OPTIONAL_UINT64",
                frameOrdinal: ordinal,
                detail: pointer)
        }
        return value
    }

    func requiredInt(at pointer: String) throws -> Int {
        guard let node = node(at: pointer),
              case .numberLexeme(let lexeme) = node.scalar,
              let value = Int(lexeme),
              String(value) == lexeme
        else {
            throw DisposalProjectionRejection(
                code: "FRAME_REQUIRED_INT",
                frameOrdinal: ordinal,
                detail: pointer)
        }
        return value
    }

    func requiredBoolean(at pointer: String) throws -> Bool {
        guard let node = node(at: pointer), case .boolean(let value) = node.scalar else {
            throw DisposalProjectionRejection(
                code: "FRAME_REQUIRED_BOOLEAN",
                frameOrdinal: ordinal,
                detail: pointer)
        }
        return value
    }

    func payloadValue() throws -> DisposalJSONValue {
        var parser = DisposalCanonicalJSONParser(
            data: payload,
            frameOrdinal: ordinal,
            journalByteOffset: journalByteOffset)
        return try parser.parse()
    }
}

func disposalDecodedText(_ scalar: DisposalJSONScalar?) -> String? {
    guard let scalar else { return nil }
    switch scalar {
    case .string(let value), .numberLexeme(let value): return value
    case .boolean(let value): return value ? "true" : "false"
    case .null: return nil
    }
}

func disposalCanonicalObject(_ members: [String: DisposalJSONValue]) -> Data {
    DisposalJSONValue.object(
        members.map { DisposalJSONObjectMember(key: $0.key, value: $0.value) },
        disposalZeroSpan).canonicalData()
}

func disposalJSONString(_ value: String) -> DisposalJSONValue {
    .string(value, disposalZeroSpan)
}

func disposalJSONNumber(_ value: Int) -> DisposalJSONValue {
    .number(String(value), disposalZeroSpan)
}

func disposalJSONBoolean(_ value: Bool) -> DisposalJSONValue {
    .boolean(value, disposalZeroSpan)
}

func disposalJSONOptionalString(_ value: String?) -> DisposalJSONValue {
    value.map(disposalJSONString) ?? .null(disposalZeroSpan)
}
