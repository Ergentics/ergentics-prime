// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: MIT

#if canImport(Darwin)
    import Cmlx
    import Darwin
    import Foundation

    /// Errors produced by descriptor-backed safetensors I/O.
    public enum SafetensorsFileDescriptorError: Error, Equatable, Sendable {
        /// The descriptor does not identify a regular, seekable file with the
        /// access mode required by the operation.
        case invalidDescriptor(String)

        /// A POSIX operation failed.
        case systemCallFailed(operation: String, errorCode: Int32)

        /// A writer callback would make the safetensors file exceed its byte cap.
        ///
        /// The rejected callback writes no bytes. Data from earlier callbacks may
        /// remain in the file.
        case maximumBytesExceeded(maximumBytes: UInt64, attemptedBytes: UInt64)
    }

    extension SafetensorsFileDescriptorError: LocalizedError {
        public var errorDescription: String? {
            switch self {
            case .invalidDescriptor(let reason):
                return "Invalid safetensors file descriptor: \(reason)"
            case .systemCallFailed(let operation, let errorCode):
                return "\(operation) failed with errno \(errorCode)"
            case .maximumBytesExceeded(let maximumBytes, let attemptedBytes):
                return
                    "Safetensors output would use \(attemptedBytes) bytes, exceeding the \(maximumBytes)-byte maximum"
            }
        }
    }

    private struct SafetensorsHeaderParser {
        private let bytes: [UInt8]
        private let headerEnd: UInt64
        private let fileSize: UInt64
        private var index = 0

        init(bytes: [UInt8], headerEnd: UInt64, fileSize: UInt64) {
            self.bytes = bytes
            self.headerEnd = headerEnd
            self.fileSize = fileSize
        }

        mutating func validate() throws {
            skipWhitespace()
            try expect(ascii: "{")

            var tensorNames = Set<String>()
            skipWhitespace()
            if consume(ascii: "}") {
                try finish()
                return
            }

            while true {
                let name = try parseString()
                guard tensorNames.insert(name).inserted else {
                    throw invalid("duplicate top-level key \(name.debugDescription)")
                }

                skipWhitespace()
                try expect(ascii: ":")
                if name == "__metadata__" {
                    try skipValue(depth: 0)
                } else {
                    try validateTensor(named: name)
                }

                skipWhitespace()
                if consume(ascii: "}") {
                    break
                }
                try expect(ascii: ",")
                skipWhitespace()
            }

            try finish()
        }

        private mutating func validateTensor(named name: String) throws {
            skipWhitespace()
            try expect(ascii: "{")

            var fieldNames = Set<String>()
            var dtypeSize: UInt64?
            var shape: [UInt64]?
            var dataOffsets: (start: UInt64, end: UInt64)?

            skipWhitespace()
            if !consume(ascii: "}") {
                while true {
                    let fieldName = try parseString()
                    guard fieldNames.insert(fieldName).inserted else {
                        throw invalid(
                            "duplicate field \(fieldName.debugDescription) in tensor \(name.debugDescription)"
                        )
                    }

                    skipWhitespace()
                    try expect(ascii: ":")
                    switch fieldName {
                    case "dtype":
                        dtypeSize = try parseDTypeSize()
                    case "shape":
                        shape = try parseShape()
                    case "data_offsets":
                        dataOffsets = try parseDataOffsets()
                    default:
                        try skipValue(depth: 0)
                    }

                    skipWhitespace()
                    if consume(ascii: "}") {
                        break
                    }
                    try expect(ascii: ",")
                    skipWhitespace()
                }
            }

            guard let dtypeSize, let shape, let dataOffsets else {
                throw invalid("tensor \(name.debugDescription) is missing a required field")
            }
            guard dataOffsets.start <= dataOffsets.end else {
                throw invalid("tensor \(name.debugDescription) has descending data offsets")
            }

            var elementCount: UInt64 = 1
            for dimension in shape.reversed() {
                let (product, overflow) = elementCount.multipliedReportingOverflow(by: dimension)
                guard !overflow, product <= UInt64(Int64.max) else {
                    throw invalid("tensor \(name.debugDescription) shape byte size overflowed")
                }
                elementCount = product
            }
            let (tensorByteCount, byteCountOverflow) =
                elementCount.multipliedReportingOverflow(by: dtypeSize)
            guard !byteCountOverflow else {
                throw invalid("tensor \(name.debugDescription) shape byte size overflowed")
            }

            let (declaredByteCount, rangeUnderflow) =
                dataOffsets.end.subtractingReportingOverflow(dataOffsets.start)
            guard !rangeUnderflow, declaredByteCount == tensorByteCount else {
                throw invalid(
                    "tensor \(name.debugDescription) data offsets do not match its shape and dtype"
                )
            }

            let (_, startOverflow) = headerEnd.addingReportingOverflow(dataOffsets.start)
            let (absoluteEnd, endOverflow) =
                headerEnd.addingReportingOverflow(dataOffsets.end)
            guard !startOverflow, !endOverflow, absoluteEnd <= fileSize else {
                throw invalid("tensor \(name.debugDescription) data range exceeds the file")
            }
        }

        private mutating func parseDTypeSize() throws -> UInt64 {
            skipWhitespace()
            let dtype = try parseString()
            switch dtype {
            case "BOOL", "I8", "U8", "F8_E4M3":
                return 1
            case "F16", "BF16", "I16", "U16":
                return 2
            case "F32", "I32", "U32":
                return 4
            case "I64", "U64", "C64":
                return 8
            default:
                throw invalid("unsupported safetensors dtype \(dtype.debugDescription)")
            }
        }

        private mutating func parseShape() throws -> [UInt64] {
            skipWhitespace()
            try expect(ascii: "[")

            var dimensions = [UInt64]()
            skipWhitespace()
            if consume(ascii: "]") {
                return dimensions
            }

            while true {
                let dimension = try parseUnsignedInteger()
                guard dimension <= UInt64(Int32.max) else {
                    throw invalid("tensor shape dimension exceeds Int32.max")
                }
                dimensions.append(dimension)

                skipWhitespace()
                if consume(ascii: "]") {
                    return dimensions
                }
                try expect(ascii: ",")
                skipWhitespace()
            }
        }

        private mutating func parseDataOffsets() throws -> (start: UInt64, end: UInt64) {
            skipWhitespace()
            try expect(ascii: "[")
            skipWhitespace()
            let start = try parseUnsignedInteger()
            skipWhitespace()
            try expect(ascii: ",")
            skipWhitespace()
            let end = try parseUnsignedInteger()
            skipWhitespace()
            try expect(ascii: "]")
            return (start, end)
        }

        private mutating func parseUnsignedInteger() throws -> UInt64 {
            skipWhitespace()
            guard index < bytes.count else {
                throw invalid("expected an unsigned integer")
            }
            guard bytes[index] != ascii("-") else {
                throw invalid("expected a nonnegative integer")
            }

            let first = bytes[index]
            guard isDigit(first) else {
                throw invalid("expected an unsigned integer")
            }

            var value: UInt64 = 0
            if first == ascii("0") {
                index += 1
                if index < bytes.count, isDigit(bytes[index]) {
                    throw invalid("integer has a leading zero")
                }
            } else {
                while index < bytes.count, isDigit(bytes[index]) {
                    let digit = UInt64(bytes[index] - ascii("0"))
                    let (multiplied, multiplyOverflow) =
                        value.multipliedReportingOverflow(by: 10)
                    let (next, addOverflow) = multiplied.addingReportingOverflow(digit)
                    guard !multiplyOverflow, !addOverflow else {
                        throw invalid("integer exceeds UInt64.max")
                    }
                    value = next
                    index += 1
                }
            }

            if index < bytes.count,
                bytes[index] == ascii(".") || bytes[index] == ascii("e")
                    || bytes[index] == ascii("E")
            {
                throw invalid("tensor shape and data offsets must use integer tokens")
            }
            return value
        }

        private mutating func skipValue(depth: Int) throws {
            guard depth < 512 else {
                throw invalid("JSON nesting exceeds 512 levels")
            }

            skipWhitespace()
            guard index < bytes.count else {
                throw invalid("expected a JSON value")
            }

            switch bytes[index] {
            case ascii("{"):
                try skipObject(depth: depth + 1)
            case ascii("["):
                try skipArray(depth: depth + 1)
            case ascii("\""):
                _ = try parseString()
            case ascii("t"):
                try consumeLiteral("true")
            case ascii("f"):
                try consumeLiteral("false")
            case ascii("n"):
                try consumeLiteral("null")
            case ascii("-"), ascii("0") ... ascii("9"):
                try skipNumber()
            default:
                throw invalid("expected a JSON value")
            }
        }

        private mutating func skipObject(depth: Int) throws {
            try expect(ascii: "{")
            var fieldNames = Set<String>()

            skipWhitespace()
            if consume(ascii: "}") {
                return
            }

            while true {
                let fieldName = try parseString()
                guard fieldNames.insert(fieldName).inserted else {
                    throw invalid("duplicate object key \(fieldName.debugDescription)")
                }
                skipWhitespace()
                try expect(ascii: ":")
                try skipValue(depth: depth)
                skipWhitespace()
                if consume(ascii: "}") {
                    return
                }
                try expect(ascii: ",")
                skipWhitespace()
            }
        }

        private mutating func skipArray(depth: Int) throws {
            try expect(ascii: "[")
            skipWhitespace()
            if consume(ascii: "]") {
                return
            }

            while true {
                try skipValue(depth: depth)
                skipWhitespace()
                if consume(ascii: "]") {
                    return
                }
                try expect(ascii: ",")
                skipWhitespace()
            }
        }

        private mutating func skipNumber() throws {
            if consume(ascii: "-") {
                guard index < bytes.count else {
                    throw invalid("invalid JSON number")
                }
            }

            guard index < bytes.count else {
                throw invalid("invalid JSON number")
            }
            if consume(ascii: "0") {
                if index < bytes.count, isDigit(bytes[index]) {
                    throw invalid("JSON number has a leading zero")
                }
            } else {
                guard bytes[index] >= ascii("1"), bytes[index] <= ascii("9") else {
                    throw invalid("invalid JSON number")
                }
                while index < bytes.count, isDigit(bytes[index]) {
                    index += 1
                }
            }

            if consume(ascii: ".") {
                guard index < bytes.count, isDigit(bytes[index]) else {
                    throw invalid("invalid JSON number fraction")
                }
                while index < bytes.count, isDigit(bytes[index]) {
                    index += 1
                }
            }

            if consume(ascii: "e") || consume(ascii: "E") {
                _ = consume(ascii: "+") || consume(ascii: "-")
                guard index < bytes.count, isDigit(bytes[index]) else {
                    throw invalid("invalid JSON number exponent")
                }
                while index < bytes.count, isDigit(bytes[index]) {
                    index += 1
                }
            }
        }

        private mutating func parseString() throws -> String {
            skipWhitespace()
            try expect(ascii: "\"")

            var decoded = [UInt8]()
            while index < bytes.count {
                let byte = bytes[index]
                index += 1

                switch byte {
                case ascii("\""):
                    guard let string = String(bytes: decoded, encoding: .utf8) else {
                        throw invalid("string contains invalid UTF-8")
                    }
                    return string
                case ascii("\\"):
                    try parseEscape(into: &decoded)
                case 0 ... 0x1F:
                    throw invalid("string contains an unescaped control character")
                default:
                    decoded.append(byte)
                }
            }

            throw invalid("unterminated string")
        }

        private mutating func parseEscape(into decoded: inout [UInt8]) throws {
            guard index < bytes.count else {
                throw invalid("unterminated string escape")
            }
            let escape = bytes[index]
            index += 1

            switch escape {
            case ascii("\""), ascii("\\"), ascii("/"):
                decoded.append(escape)
            case ascii("b"):
                decoded.append(0x08)
            case ascii("f"):
                decoded.append(0x0C)
            case ascii("n"):
                decoded.append(0x0A)
            case ascii("r"):
                decoded.append(0x0D)
            case ascii("t"):
                decoded.append(0x09)
            case ascii("u"):
                let first = try parseHexQuad()
                let scalar: UInt32
                if first >= 0xD800, first <= 0xDBFF {
                    guard consume(ascii: "\\"), consume(ascii: "u") else {
                        throw invalid("high surrogate is not followed by a low surrogate")
                    }
                    let second = try parseHexQuad()
                    guard second >= 0xDC00, second <= 0xDFFF else {
                        throw invalid("high surrogate is not followed by a low surrogate")
                    }
                    scalar =
                        0x10000 + (UInt32(first - 0xD800) << 10)
                        + UInt32(second - 0xDC00)
                } else {
                    guard first < 0xDC00 || first > 0xDFFF else {
                        throw invalid("unexpected low surrogate")
                    }
                    scalar = UInt32(first)
                }
                appendUTF8(scalar, to: &decoded)
            default:
                throw invalid("invalid string escape")
            }
        }

        private mutating func parseHexQuad() throws -> UInt16 {
            guard index <= bytes.count, bytes.count - index >= 4 else {
                throw invalid("incomplete unicode escape")
            }

            var value: UInt16 = 0
            for _ in 0 ..< 4 {
                let byte = bytes[index]
                index += 1
                let digit: UInt16
                switch byte {
                case ascii("0") ... ascii("9"):
                    digit = UInt16(byte - ascii("0"))
                case ascii("A") ... ascii("F"):
                    digit = UInt16(byte - ascii("A") + 10)
                case ascii("a") ... ascii("f"):
                    digit = UInt16(byte - ascii("a") + 10)
                default:
                    throw invalid("unicode escape contains a non-hex digit")
                }
                value = (value << 4) | digit
            }
            return value
        }

        private func appendUTF8(_ scalar: UInt32, to bytes: inout [UInt8]) {
            if scalar <= 0x7F {
                bytes.append(UInt8(scalar))
            } else if scalar <= 0x7FF {
                bytes.append(UInt8(0xC0 | (scalar >> 6)))
                bytes.append(UInt8(0x80 | (scalar & 0x3F)))
            } else if scalar <= 0xFFFF {
                bytes.append(UInt8(0xE0 | (scalar >> 12)))
                bytes.append(UInt8(0x80 | ((scalar >> 6) & 0x3F)))
                bytes.append(UInt8(0x80 | (scalar & 0x3F)))
            } else {
                bytes.append(UInt8(0xF0 | (scalar >> 18)))
                bytes.append(UInt8(0x80 | ((scalar >> 12) & 0x3F)))
                bytes.append(UInt8(0x80 | ((scalar >> 6) & 0x3F)))
                bytes.append(UInt8(0x80 | (scalar & 0x3F)))
            }
        }

        private mutating func consumeLiteral(_ literal: StaticString) throws {
            let literalBytes = UnsafeRawBufferPointer(
                start: literal.utf8Start,
                count: literal.utf8CodeUnitCount
            )
            guard index <= bytes.count, literalBytes.count <= bytes.count - index else {
                throw invalid("incomplete JSON literal")
            }
            for literalByte in literalBytes {
                guard bytes[index] == literalByte else {
                    throw invalid("invalid JSON literal")
                }
                index += 1
            }
        }

        private mutating func finish() throws {
            skipWhitespace()
            guard index == bytes.count else {
                throw invalid("unexpected trailing bytes")
            }
        }

        private mutating func expect(ascii character: Character) throws {
            guard consume(ascii: character) else {
                throw invalid("expected \(character.debugDescription)")
            }
        }

        private mutating func consume(ascii character: Character) -> Bool {
            let expected = ascii(character)
            guard index < bytes.count, bytes[index] == expected else {
                return false
            }
            index += 1
            return true
        }

        private mutating func skipWhitespace() {
            while index < bytes.count {
                switch bytes[index] {
                case 0x09, 0x0A, 0x0D, 0x20:
                    index += 1
                default:
                    return
                }
            }
        }

        private func isDigit(_ byte: UInt8) -> Bool {
            byte >= ascii("0") && byte <= ascii("9")
        }

        private func ascii(_ character: Character) -> UInt8 {
            character.asciiValue!
        }

        private func invalid(_ reason: String) -> SafetensorsFileDescriptorError {
            .invalidDescriptor("malformed safetensors header at byte \(index): \(reason)")
        }
    }

    private final class SafetensorsFileDescriptorState: @unchecked Sendable {
        let descriptor: Int32
        let fileSize: UInt64
        let maximumBytes: UInt64?
        let readable: Bool
        let writable: Bool

        private let lock = NSLock()
        private var offset: UInt64 = 0
        private var failure: SafetensorsFileDescriptorError?
        private var validatedHeaderPrefix: [UInt8]?

        init(
            descriptor: Int32,
            fileSize: UInt64,
            maximumBytes: UInt64?,
            readable: Bool,
            writable: Bool
        ) {
            self.descriptor = descriptor
            self.fileSize = fileSize
            self.maximumBytes = maximumBytes
            self.readable = readable
            self.writable = writable
        }

        func preflightSafetensorsHeader() throws {
            guard readable else {
                throw SafetensorsFileDescriptorError.invalidDescriptor(
                    "the descriptor is not readable"
                )
            }
            guard fileSize >= 8 else {
                throw SafetensorsFileDescriptorError.invalidDescriptor(
                    "the file is too small to contain a safetensors header"
                )
            }

            var encodedHeaderLength: UInt64 = 0
            try withUnsafeMutableBytes(of: &encodedHeaderLength) {
                try preadExactlyForPreflight(into: $0, at: 0)
            }
            let headerLength = UInt64(littleEndian: encodedHeaderLength)
            let maximumHeaderLength: UInt64 = 100_000_000
            guard headerLength > 0, headerLength < maximumHeaderLength else {
                throw SafetensorsFileDescriptorError.invalidDescriptor(
                    "the safetensors header length is invalid"
                )
            }

            let (headerEnd, headerEndOverflow) = UInt64(8).addingReportingOverflow(headerLength)
            guard !headerEndOverflow, headerEnd <= fileSize else {
                throw SafetensorsFileDescriptorError.invalidDescriptor(
                    "the safetensors header exceeds the \(fileSize)-byte file"
                )
            }
            guard headerLength <= UInt64(Int.max) else {
                throw SafetensorsFileDescriptorError.invalidDescriptor(
                    "the safetensors header is too large to address"
                )
            }

            var header = [UInt8](repeating: 0, count: Int(headerLength))
            try header.withUnsafeMutableBytes {
                try preadExactlyForPreflight(into: $0, at: 8)
            }

            var parser = SafetensorsHeaderParser(
                bytes: header,
                headerEnd: headerEnd,
                fileSize: fileSize
            )
            try parser.validate()

            var prefix = [UInt8]()
            prefix.reserveCapacity(Int(headerEnd))
            withUnsafeBytes(of: &encodedHeaderLength) {
                prefix.append(contentsOf: $0)
            }
            prefix.append(contentsOf: header)
            lock.withLock {
                validatedHeaderPrefix = prefix
            }
        }

        deinit {
            _ = Darwin.close(descriptor)
        }

        var error: SafetensorsFileDescriptorError? {
            lock.withLock { failure }
        }

        var isGood: Bool {
            lock.withLock { failure == nil }
        }

        var currentOffset: Int {
            lock.withLock { Int(offset) }
        }

        func seek(by amount: Int64, relativeTo whence: Int32) {
            lock.withLock {
                guard failure == nil else { return }

                let base: Int64
                switch whence {
                case SEEK_SET:
                    base = 0
                case SEEK_CUR:
                    guard offset <= UInt64(Int64.max) else {
                        setFailureLocked(
                            .invalidDescriptor("the current offset is not representable by off_t")
                        )
                        return
                    }
                    base = Int64(offset)
                case SEEK_END:
                    var metadata = stat()
                    guard Darwin.fstat(descriptor, &metadata) == 0 else {
                        setFailureLocked(
                            .systemCallFailed(operation: "fstat", errorCode: errno)
                        )
                        return
                    }
                    guard metadata.st_size >= 0 else {
                        setFailureLocked(.invalidDescriptor("the file has a negative size"))
                        return
                    }
                    base = metadata.st_size
                default:
                    setFailureLocked(.invalidDescriptor("unsupported seek origin \(whence)"))
                    return
                }

                let (newOffset, overflow) = base.addingReportingOverflow(amount)
                guard !overflow, newOffset >= 0 else {
                    setFailureLocked(.invalidDescriptor("seek produced an invalid offset"))
                    return
                }
                offset = UInt64(newOffset)
            }
        }

        func read(_ destination: UnsafeMutablePointer<CChar>?, count: Int) {
            guard count >= 0 else {
                recordFailure(.invalidDescriptor("read received a negative byte count"))
                return
            }
            guard count == 0 || destination != nil else {
                recordFailure(.invalidDescriptor("read received a nil destination"))
                return
            }
            guard readable else {
                zero(destination, count: count)
                recordFailure(.invalidDescriptor("the descriptor is not readable"))
                return
            }

            let start: UInt64? = lock.withLock {
                guard failure == nil else { return nil }
                let byteCount = UInt64(count)
                let (end, overflow) = offset.addingReportingOverflow(byteCount)
                guard !overflow, end <= fileSize else {
                    setFailureLocked(
                        .invalidDescriptor(
                            "read range exceeds the \(fileSize)-byte file"
                        )
                    )
                    return nil
                }
                let start = offset
                offset = end
                return start
            }

            guard let start else {
                zero(destination, count: count)
                return
            }
            guard let destination else { return }
            if readValidatedHeaderPrefix(into: destination, count: count, at: start) {
                return
            }
            readExactly(into: destination, count: count, at: start)
        }

        func read(
            _ destination: UnsafeMutablePointer<CChar>?,
            count: Int,
            at requestedOffset: Int
        ) {
            guard count >= 0 else {
                recordFailure(.invalidDescriptor("read received a negative byte count"))
                return
            }
            guard count == 0 || destination != nil else {
                recordFailure(.invalidDescriptor("read received a nil destination"))
                return
            }
            guard requestedOffset >= 0 else {
                zero(destination, count: count)
                recordFailure(.invalidDescriptor("read received a negative offset"))
                return
            }
            guard readable else {
                zero(destination, count: count)
                recordFailure(.invalidDescriptor("the descriptor is not readable"))
                return
            }
            guard isGood else {
                zero(destination, count: count)
                return
            }

            let start = UInt64(requestedOffset)
            let (end, overflow) = start.addingReportingOverflow(UInt64(count))
            guard !overflow, end <= fileSize else {
                zero(destination, count: count)
                recordFailure(
                    .invalidDescriptor(
                        "read range exceeds the \(fileSize)-byte file"
                    )
                )
                return
            }

            guard let destination else { return }
            readExactly(into: destination, count: count, at: start)
        }

        func write(_ source: UnsafePointer<CChar>?, count: Int) {
            guard count >= 0 else {
                recordFailure(.invalidDescriptor("write received a negative byte count"))
                return
            }
            guard count == 0 || source != nil else {
                recordFailure(.invalidDescriptor("write received a nil source"))
                return
            }
            guard writable, let maximumBytes else {
                recordFailure(.invalidDescriptor("the descriptor is not writable"))
                return
            }

            let start: UInt64? = lock.withLock {
                guard failure == nil else { return nil }
                let (end, overflow) = offset.addingReportingOverflow(UInt64(count))
                guard !overflow else {
                    setFailureLocked(.invalidDescriptor("write offset overflowed"))
                    return nil
                }
                guard end <= maximumBytes else {
                    setFailureLocked(
                        .maximumBytesExceeded(
                            maximumBytes: maximumBytes,
                            attemptedBytes: end
                        )
                    )
                    return nil
                }
                guard end <= UInt64(Int64.max) else {
                    setFailureLocked(
                        .invalidDescriptor("write offset is not representable by off_t")
                    )
                    return nil
                }
                let start = offset
                offset = end
                return start
            }

            guard let start, let source else { return }
            writeExactly(from: source, count: count, at: start)
        }

        private func readExactly(
            into destination: UnsafeMutablePointer<CChar>,
            count: Int,
            at start: UInt64
        ) {
            var completed = 0
            while completed < count {
                let chunk = min(count - completed, Int(Int32.max))
                let position = start + UInt64(completed)
                let result = Darwin.pread(
                    descriptor,
                    destination.advanced(by: completed),
                    chunk,
                    off_t(position)
                )
                if result > 0 {
                    completed += result
                } else if result < 0, errno == EINTR {
                    continue
                } else {
                    memset(destination, 0, count)
                    recordFailure(
                        .systemCallFailed(
                            operation: "pread",
                            errorCode: result == 0 ? EIO : errno
                        )
                    )
                    return
                }
            }
        }

        private func zero(_ destination: UnsafeMutablePointer<CChar>?, count: Int) {
            guard count > 0, let destination else { return }
            memset(destination, 0, count)
        }

        private func readValidatedHeaderPrefix(
            into destination: UnsafeMutablePointer<CChar>,
            count: Int,
            at start: UInt64
        ) -> Bool {
            lock.withLock {
                guard let validatedHeaderPrefix else { return false }
                let (end, overflow) = start.addingReportingOverflow(UInt64(count))
                guard !overflow, end <= UInt64(validatedHeaderPrefix.count) else {
                    return false
                }
                validatedHeaderPrefix.withUnsafeBytes { source in
                    guard let baseAddress = source.baseAddress else { return }
                    memcpy(destination, baseAddress.advanced(by: Int(start)), count)
                }
                return true
            }
        }

        private func preadExactlyForPreflight(
            into destination: UnsafeMutableRawBufferPointer,
            at start: UInt64
        ) throws {
            guard let baseAddress = destination.baseAddress else { return }

            var completed = 0
            while completed < destination.count {
                let chunk = min(destination.count - completed, Int(Int32.max))
                let position = start + UInt64(completed)
                let result = Darwin.pread(
                    descriptor,
                    baseAddress.advanced(by: completed),
                    chunk,
                    off_t(position)
                )
                if result > 0 {
                    completed += result
                } else if result < 0, errno == EINTR {
                    continue
                } else {
                    throw SafetensorsFileDescriptorError.systemCallFailed(
                        operation: "pread",
                        errorCode: result == 0 ? EIO : errno
                    )
                }
            }
        }

        private func writeExactly(
            from source: UnsafePointer<CChar>,
            count: Int,
            at start: UInt64
        ) {
            var completed = 0
            while completed < count {
                let chunk = min(count - completed, Int(Int32.max))
                let position = start + UInt64(completed)
                let result = Darwin.pwrite(
                    descriptor,
                    source.advanced(by: completed),
                    chunk,
                    off_t(position)
                )
                if result > 0 {
                    completed += result
                } else if result < 0, errno == EINTR {
                    continue
                } else {
                    recordFailure(
                        .systemCallFailed(
                            operation: "pwrite",
                            errorCode: result == 0 ? EIO : errno
                        )
                    )
                    return
                }
            }
        }

        private func recordFailure(_ error: SafetensorsFileDescriptorError) {
            lock.withLock {
                setFailureLocked(error)
            }
        }

        private func setFailureLocked(_ error: SafetensorsFileDescriptorError) {
            if failure == nil {
                failure = error
            }
        }
    }

    private let safetensorsDescriptorLabel: StaticString =
        "<safetensors file descriptor>\0"

    private func makeFileDescriptorIOVTable() -> mlx_io_vtable {
        mlx_io_vtable { pointer in
            pointer != nil
        } good: { pointer in
            guard let pointer else { return false }
            return Unmanaged<SafetensorsFileDescriptorState>
                .fromOpaque(pointer)
                .takeUnretainedValue()
                .isGood
        } tell: { pointer in
            guard let pointer else { return 0 }
            return Unmanaged<SafetensorsFileDescriptorState>
                .fromOpaque(pointer)
                .takeUnretainedValue()
                .currentOffset
        } seek: { pointer, offset, whence in
            guard let pointer else { return }
            Unmanaged<SafetensorsFileDescriptorState>
                .fromOpaque(pointer)
                .takeUnretainedValue()
                .seek(by: offset, relativeTo: whence)
        } read: { pointer, destination, count in
            guard let pointer else { return }
            Unmanaged<SafetensorsFileDescriptorState>
                .fromOpaque(pointer)
                .takeUnretainedValue()
                .read(destination, count: count)
        } read_at_offset: { pointer, destination, count, offset in
            guard let pointer else { return }
            Unmanaged<SafetensorsFileDescriptorState>
                .fromOpaque(pointer)
                .takeUnretainedValue()
                .read(destination, count: count, at: offset)
        } write: { pointer, source, count in
            guard let pointer else { return }
            Unmanaged<SafetensorsFileDescriptorState>
                .fromOpaque(pointer)
                .takeUnretainedValue()
                .write(source, count: count)
        } label: { _ in
            UnsafeRawPointer(safetensorsDescriptorLabel.utf8Start)
                .assumingMemoryBound(to: CChar.self)
        } free: { pointer in
            guard let pointer else { return }
            Unmanaged<SafetensorsFileDescriptorState>.fromOpaque(pointer).release()
        }
    }

    private enum SafetensorsDescriptorAccess {
        case read
        case write(maximumBytes: UInt64)
    }

    private func duplicateSafetensorsDescriptor(
        _ fileDescriptor: Int32,
        access: SafetensorsDescriptorAccess
    ) throws -> SafetensorsFileDescriptorState {
        let duplicate = Darwin.fcntl(fileDescriptor, F_DUPFD_CLOEXEC, 0)
        guard duplicate >= 0 else {
            throw SafetensorsFileDescriptorError.systemCallFailed(
                operation: "fcntl(F_DUPFD_CLOEXEC)",
                errorCode: errno
            )
        }

        do {
            var metadata = stat()
            guard Darwin.fstat(duplicate, &metadata) == 0 else {
                throw SafetensorsFileDescriptorError.systemCallFailed(
                    operation: "fstat",
                    errorCode: errno
                )
            }
            guard (metadata.st_mode & S_IFMT) == S_IFREG else {
                throw SafetensorsFileDescriptorError.invalidDescriptor(
                    "file descriptor \(fileDescriptor) does not identify a regular file"
                )
            }
            guard metadata.st_size >= 0 else {
                throw SafetensorsFileDescriptorError.invalidDescriptor(
                    "file descriptor \(fileDescriptor) has a negative size"
                )
            }

            let statusFlags = Darwin.fcntl(duplicate, F_GETFL)
            guard statusFlags >= 0 else {
                throw SafetensorsFileDescriptorError.systemCallFailed(
                    operation: "fcntl(F_GETFL)",
                    errorCode: errno
                )
            }
            guard Darwin.lseek(duplicate, 0, SEEK_CUR) >= 0 else {
                throw SafetensorsFileDescriptorError.invalidDescriptor(
                    "file descriptor \(fileDescriptor) is not seekable"
                )
            }

            let accessMode = statusFlags & O_ACCMODE
            switch access {
            case .read:
                guard accessMode == O_RDONLY || accessMode == O_RDWR else {
                    throw SafetensorsFileDescriptorError.invalidDescriptor(
                        "file descriptor \(fileDescriptor) is not readable"
                    )
                }
                return SafetensorsFileDescriptorState(
                    descriptor: duplicate,
                    fileSize: UInt64(metadata.st_size),
                    maximumBytes: nil,
                    readable: true,
                    writable: false
                )

            case .write(let maximumBytes):
                guard accessMode == O_WRONLY || accessMode == O_RDWR else {
                    throw SafetensorsFileDescriptorError.invalidDescriptor(
                        "file descriptor \(fileDescriptor) is not writable"
                    )
                }
                guard statusFlags & O_APPEND == 0 else {
                    throw SafetensorsFileDescriptorError.invalidDescriptor(
                        "append-mode descriptors cannot save safetensors"
                    )
                }
                guard Darwin.ftruncate(duplicate, 0) == 0 else {
                    throw SafetensorsFileDescriptorError.systemCallFailed(
                        operation: "ftruncate",
                        errorCode: errno
                    )
                }
                return SafetensorsFileDescriptorState(
                    descriptor: duplicate,
                    fileSize: 0,
                    maximumBytes: maximumBytes,
                    readable: false,
                    writable: true
                )
            }
        } catch {
            _ = Darwin.close(duplicate)
            throw error
        }
    }

    private func makeFileDescriptorIOReader(
        _ fileDescriptor: Int32
    ) throws -> (mlx_io_reader, SafetensorsFileDescriptorState) {
        let state = try duplicateSafetensorsDescriptor(fileDescriptor, access: .read)
        let pointer = Unmanaged.passRetained(state).toOpaque()
        return (
            mlx_io_reader_new(pointer, makeFileDescriptorIOVTable()),
            state
        )
    }

    private func makeFileDescriptorIOWriter(
        _ fileDescriptor: Int32,
        maximumBytes: UInt64
    ) throws -> (mlx_io_writer, SafetensorsFileDescriptorState) {
        let state = try duplicateSafetensorsDescriptor(
            fileDescriptor,
            access: .write(maximumBytes: maximumBytes)
        )
        let pointer = Unmanaged.passRetained(state).toOpaque()
        return (
            mlx_io_writer_new(pointer, makeFileDescriptorIOVTable()),
            state
        )
    }

    /// Saves a dictionary of arrays in safetensors format through an open Darwin
    /// file descriptor.
    ///
    /// The descriptor is borrowed and remains owned by the caller. This function
    /// retains an independent `CLOEXEC` duplicate for the duration of the save,
    /// truncates the regular file to zero bytes, and writes from byte zero without
    /// changing the caller descriptor's file offset. A writer callback that would
    /// make the file larger than `maximumBytes` is rejected before it writes any
    /// part of that callback.
    ///
    /// - Parameters:
    ///   - arrays: Arrays to save.
    ///   - metadata: Metadata to save.
    ///   - fileDescriptor: An open, seekable regular-file descriptor with write
    ///     access. The caller retains ownership and must close it.
    ///   - maximumBytes: The maximum resulting file size.
    public func save(
        arrays: [String: MLXArray],
        metadata: [String: String] = [:],
        fileDescriptor: Int32,
        maximumBytes: UInt64
    ) throws {
        let mlxArrays = new_mlx_array_map(arrays)
        defer { mlx_map_string_to_array_free(mlxArrays) }

        let mlxMetadata = new_mlx_string_map(metadata)
        defer { mlx_map_string_to_string_free(mlxMetadata) }

        let (writer, state) = try makeFileDescriptorIOWriter(
            fileDescriptor,
            maximumBytes: maximumBytes
        )
        defer { mlx_io_writer_free(writer) }

        _ = try withError { error in
            let result = evalLock.withLock {
                mlx_save_safetensors_writer(writer, mlxArrays, mlxMetadata)
            }
            if let descriptorError = state.error {
                throw descriptorError
            }
            try error.check()
            return result
        }
    }

    /// Loads arrays and metadata from a safetensors file through an open
    /// Darwin file descriptor.
    ///
    /// The descriptor is borrowed and remains owned by the caller. The function
    /// reads from byte zero without changing the caller descriptor's file offset
    /// and fully materializes every returned array. MLX retains an independent
    /// `CLOEXEC` duplicate for the duration of the load, so the caller may close
    /// its descriptor immediately after this function returns.
    ///
    /// - Parameters:
    ///   - fileDescriptor: An open, seekable regular-file descriptor with read
    ///     access. The caller retains ownership and must close it.
    ///   - stream: Stream or device on which the arrays will be evaluated.
    public func loadArraysAndMetadata(
        fileDescriptor: Int32,
        stream: StreamOrDevice = .cpu
    ) throws -> ([String: MLXArray], [String: String]) {
        let (reader, state) = try makeFileDescriptorIOReader(fileDescriptor)
        defer { mlx_io_reader_free(reader) }
        try state.preflightSafetensorsHeader()

        var arrays = mlx_map_string_to_array_new()
        var metadata = mlx_map_string_to_string_new()
        defer { mlx_map_string_to_array_free(arrays) }
        defer { mlx_map_string_to_string_free(metadata) }

        _ = try withError { error in
            let result = mlx_load_safetensors_reader(
                &arrays,
                &metadata,
                reader,
                stream.ctx
            )
            if let descriptorError = state.error {
                throw descriptorError
            }
            try error.check()
            return result
        }

        let loadedArrays = mlx_map_array_values(arrays)
        do {
            try checkedEval(loadedArrays.values.map { $0 as Any })
        } catch {
            if let descriptorError = state.error {
                throw descriptorError
            }
            throw error
        }
        if let descriptorError = state.error {
            throw descriptorError
        }

        return (loadedArrays, mlx_map_string_values(metadata))
    }
#endif
