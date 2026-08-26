import Foundation

let disposalZeroSpan = DisposalJSONSpan(lowerBound: 0, upperBound: 0)

func disposalResourceData(_ name: String, extension extensionName: String) throws -> Data {
    guard let url = Bundle.module.url(forResource: name, withExtension: extensionName) else {
        throw DisposalProjectionRejection(code: "RESOURCE_ABSENT", detail: "\(name).\(extensionName)")
    }
    do {
        return try Data(contentsOf: url, options: [.mappedIfSafe])
    } catch {
        throw DisposalProjectionRejection(
            code: "RESOURCE_READ",
            detail: "\(name).\(extensionName):\(error)")
    }
}

func disposalID(_ domain: String, _ components: [String]) -> String {
    var bytes = Data(domain.utf8)
    for component in components {
        bytes.append(0)
        bytes.append(contentsOf: component.utf8)
    }
    return disposalSHA256(bytes)
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
