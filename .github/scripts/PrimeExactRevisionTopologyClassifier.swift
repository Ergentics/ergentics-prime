// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Foundation

private let maximumCommitObjectByteCount = 1_048_576
private let boundedReadLimitByteCount = maximumCommitObjectByteCount + 1
private let maximumFDInventoryByteCount = 16_384
private let maximumFDClosurePassCount = 4
private let fdInventoryAllocationSlackRecordCount = 8
private let orderedMergeChildRelationModeToken =
    "--ordered-merge-child-relation"
private let exactRelationWitnessByteCount = 41
private let lineFeedByte = UInt8(10)

private struct ClassifierArguments {
    let literalCommitOID: [UInt8]
    let advertisedByteCount: Int
    let expectedTreeOID: [UInt8]
    let expectedParentOIDs: [[UInt8]]
}

private struct RelationClassifierArguments {
    let literalCommitOID: [UInt8]
    let advertisedByteCount: Int
    let expectedTreeOID: [UInt8]
    let fixedParentOID: [UInt8]
}

private struct StandardInputObservation {
    let bytes: [UInt8]
    let exceededBound: Bool
    let readSucceeded: Bool
}

private enum PhysicalHeaderLine {
    case field(name: [UInt8], value: [UInt8])
    case continuation
}

private struct ParsedCommitTopology {
    let treeOID: [UInt8]
    let parentOIDs: [[UInt8]]
}

private enum CommitTopologyParseResult {
    case failure(Int32)
    case success(ParsedCommitTopology)
}

private struct RelationClassification {
    let status: Int32
    let witness: [UInt8]?
}

private func isLowercaseHexOID(_ value: [UInt8]) -> Bool {
    guard value.count == 40 else { return false }
    return value.allSatisfy {
        ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
    }
}

private func canonicalNonnegativeDecimal(
    _ value: String,
    maximum: Int
) -> Int? {
    let bytes = Array(value.utf8)
    guard !bytes.isEmpty,
          bytes.allSatisfy({ $0 >= 48 && $0 <= 57 }),
          bytes.count == 1 || bytes[0] != 48
    else { return nil }

    var result = 0
    for byte in bytes {
        let digit = Int(byte - 48)
        guard result <= (maximum - digit) / 10 else { return nil }
        result = result * 10 + digit
    }
    return result
}

private func parseClassifierArguments() -> ClassifierArguments? {
    let arguments = CommandLine.arguments
    guard arguments.count >= 5,
          let advertisedByteCount = canonicalNonnegativeDecimal(
              arguments[2], maximum: maximumCommitObjectByteCount),
          let parentCount = canonicalNonnegativeDecimal(
              arguments[4], maximum: 8),
          arguments.count == 5 + parentCount
    else { return nil }

    let literalCommitOID = Array(arguments[1].utf8)
    let expectedTreeOID = Array(arguments[3].utf8)
    guard isLowercaseHexOID(literalCommitOID),
          isLowercaseHexOID(expectedTreeOID)
    else { return nil }

    let parents = arguments.dropFirst(5).map { Array($0.utf8) }
    guard parents.allSatisfy(isLowercaseHexOID) else { return nil }
    return ClassifierArguments(
        literalCommitOID: literalCommitOID,
        advertisedByteCount: advertisedByteCount,
        expectedTreeOID: expectedTreeOID,
        expectedParentOIDs: parents)
}

private func parseRelationClassifierArguments()
    -> RelationClassifierArguments?
{
    let arguments = CommandLine.arguments
    guard arguments.count == 6,
          arguments[1] == orderedMergeChildRelationModeToken,
          let advertisedByteCount = canonicalNonnegativeDecimal(
              arguments[3], maximum: maximumCommitObjectByteCount)
    else { return nil }

    let literalCommitOID = Array(arguments[2].utf8)
    let expectedTreeOID = Array(arguments[4].utf8)
    let fixedParentOID = Array(arguments[5].utf8)
    guard isLowercaseHexOID(literalCommitOID),
          isLowercaseHexOID(expectedTreeOID),
          isLowercaseHexOID(fixedParentOID)
    else { return nil }

    return RelationClassifierArguments(
        literalCommitOID: literalCommitOID,
        advertisedByteCount: advertisedByteCount,
        expectedTreeOID: expectedTreeOID,
        fixedParentOID: fixedParentOID)
}

private func inventoryFileDescriptors(
    capacityByteCount: Int
) -> [Int32]? {
    let stride = MemoryLayout<proc_fdinfo>.stride
    guard stride > 0,
          capacityByteCount > 0,
          capacityByteCount <= maximumFDInventoryByteCount,
          capacityByteCount % stride == 0,
          capacityByteCount <= Int(Int32.max)
    else { return nil }

    var records = Array(
        repeating: proc_fdinfo(proc_fd: 0, proc_fdtype: 0),
        count: capacityByteCount / stride)
    let filledByteCount = records.withUnsafeMutableBytes { buffer -> Int32 in
        errno = 0
        return proc_pidinfo(
            getpid(),
            PROC_PIDLISTFDS,
            0,
            buffer.baseAddress,
            Int32(capacityByteCount))
    }
    guard filledByteCount >= 0,
          Int(filledByteCount) % stride == 0,
          Int(filledByteCount) < capacityByteCount
    else { return nil }

    let recordCount = Int(filledByteCount) / stride
    var descriptors: [Int32] = []
    descriptors.reserveCapacity(recordCount)
    for record in records.prefix(recordCount) {
        guard record.proc_fd >= 0 else { return nil }
        descriptors.append(record.proc_fd)
    }
    return descriptors
}

private func closeInheritedFileDescriptorsUsingProcPIDInfo() -> Bool {
    let stride = MemoryLayout<proc_fdinfo>.stride
    let slack = stride.multipliedReportingOverflow(
        by: fdInventoryAllocationSlackRecordCount)
    guard stride > 0,
          !slack.overflow,
          slack.partialValue < maximumFDInventoryByteCount
    else { return false }

    errno = 0
    let initialFilledByteCount = proc_pidinfo(
        getpid(), PROC_PIDLISTFDS, 0, nil, 0)
    guard initialFilledByteCount >= 0,
          Int(initialFilledByteCount) % stride == 0,
          Int(initialFilledByteCount)
              <= maximumFDInventoryByteCount - slack.partialValue
    else { return false }

    let capacityAddition = Int(initialFilledByteCount)
        .addingReportingOverflow(slack.partialValue)
    guard !capacityAddition.overflow,
          capacityAddition.partialValue <= maximumFDInventoryByteCount
    else { return false }
    let capacityByteCount = max(
        capacityAddition.partialValue,
        stride * fdInventoryAllocationSlackRecordCount)

    for _ in 0 ..< maximumFDClosurePassCount {
        guard let descriptors = inventoryFileDescriptors(
            capacityByteCount: capacityByteCount)
        else { return false }

        var sawInheritedDescriptor = false
        for descriptor in descriptors where descriptor >= 3 {
            sawInheritedDescriptor = true
            errno = 0
            let result = Darwin.close(descriptor)
            guard result == 0 || (result == -1 && errno == EBADF)
            else { return false }
        }

        if !sawInheritedDescriptor {
            let complete_final_proc_pidinfo_snapshot_is_exactly_fd_0_1_2 =
                descriptors.sorted() == [0, 1, 2]
                && Set(descriptors).count == descriptors.count
            guard complete_final_proc_pidinfo_snapshot_is_exactly_fd_0_1_2
            else { return false }
            return true
        }
    }

    let proc_pidinfo_allocation_close_or_nonconvergence_failure_exits_27 = false
    return proc_pidinfo_allocation_close_or_nonconvergence_failure_exits_27
}

private func readStandardInputOnceToEOF() -> StandardInputObservation {
    var retained: [UInt8] = []
    retained.reserveCapacity(boundedReadLimitByteCount)
    var exceededBound = false
    var scratch = Array(repeating: UInt8(0), count: 32_768)

    while true {
        let count = scratch.withUnsafeMutableBytes { buffer -> Int in
            while true {
                errno = 0
                let result = Darwin.read(
                    STDIN_FILENO,
                    buffer.baseAddress,
                    buffer.count)
                if result < 0 && errno == EINTR { continue }
                return result
            }
        }
        if count < 0 {
            return StandardInputObservation(
                bytes: retained,
                exceededBound: exceededBound,
                readSucceeded: false)
        }
        if count == 0 { break }

        let remainingCapacity = boundedReadLimitByteCount - retained.count
        if remainingCapacity > 0 {
            retained.append(
                contentsOf: scratch.prefix(min(count, remainingCapacity)))
        }
        if count > remainingCapacity || retained.count >= boundedReadLimitByteCount {
            exceededBound = retained.count > maximumCommitObjectByteCount
                || count > remainingCapacity
        }
    }

    return StandardInputObservation(
        bytes: retained,
        exceededBound: exceededBound,
        readSucceeded: true)
}

private func gitCommitObjectOID(
    advertisedByteCount: Int,
    bytes: [UInt8]
) -> [UInt8] {
    var object = Data("commit \(advertisedByteCount)".utf8)
    object.append(0)
    object.append(contentsOf: bytes)
    let digest = Insecure.SHA1.hash(data: object)
    let alphabet = Array("0123456789abcdef".utf8)
    var encoded: [UInt8] = []
    encoded.reserveCapacity(40)
    for byte in digest {
        encoded.append(alphabet[Int(byte >> 4)])
        encoded.append(alphabet[Int(byte & 0x0f)])
    }
    return encoded
}

private func isHeaderName(_ bytes: ArraySlice<UInt8>) -> Bool {
    guard let first = bytes.first, first >= 97 && first <= 122 else {
        return false
    }
    return bytes.dropFirst().allSatisfy {
        ($0 >= 97 && $0 <= 122)
            || ($0 >= 48 && $0 <= 57)
            || $0 == 45
    }
}

private func splitHeaderLines(
    _ objectBytes: [UInt8]
) -> [ArraySlice<UInt8>]? {
    guard objectBytes.count >= 2 else { return nil }
    var separator: Int?
    for index in 0 ..< (objectBytes.count - 1) {
        if objectBytes[index] == 10 && objectBytes[index + 1] == 10 {
            separator = index
            break
        }
    }
    guard let headerEnd = separator, headerEnd > 0 else { return nil }

    let header = objectBytes[0 ..< headerEnd]
    guard !header.contains(13) else { return nil }
    var lines: [ArraySlice<UInt8>] = []
    var lineStart = header.startIndex
    var index = header.startIndex
    while index < header.endIndex {
        if header[index] == 10 {
            guard lineStart < index else { return nil }
            lines.append(header[lineStart ..< index])
            lineStart = header.index(after: index)
        }
        index = header.index(after: index)
    }
    guard lineStart < header.endIndex else { return nil }
    lines.append(header[lineStart ..< header.endIndex])
    return lines
}

@inline(never)
private func unreachable_parser_state_exits_26_before_topology_classification(
    _ observedCount: Int
) -> Bool {
    observedCount < 0
}

private func parseCommitObjectTopology(
    _ objectBytes: [UInt8]
) -> CommitTopologyParseResult {
    guard !unreachable_parser_state_exits_26_before_topology_classification(
        objectBytes.count)
    else { return .failure(26) }
    guard !objectBytes.contains(0) else { return .failure(25) }
    guard let rawLines = splitHeaderLines(objectBytes) else {
        return .failure(30)
    }

    var lines: [PhysicalHeaderLine] = []
    lines.reserveCapacity(rawLines.count)
    for rawLine in rawLines {
        if rawLine.first == 32 {
            lines.append(.continuation)
            continue
        }
        guard let separator = rawLine.firstIndex(of: 32),
              separator != rawLine.startIndex,
              isHeaderName(rawLine[..<separator])
        else { return .failure(30) }
        let valueStart = rawLine.index(after: separator)
        lines.append(.field(
            name: Array(rawLine[..<separator]),
            value: Array(rawLine[valueStart...])) )
    }

    let treeName = Array("tree".utf8)
    let parentName = Array("parent".utf8)
    let treeFields = lines.enumerated().compactMap { index, line -> Int? in
        guard case let .field(name, _) = line, name == treeName else {
            return nil
        }
        return index
    }
    guard treeFields.count == 1,
          treeFields[0] == 0
    else { return .failure(31) }

    var parsedTreeOID: [UInt8]?
    var parsedParentOIDs: [[UInt8]] = []
    var parentRunEnded = false
    for (index, line) in lines.enumerated() {
        switch line {
        case let .field(name, value):
            if index == 0 {
                parsedTreeOID = value
            } else if name == parentName {
                guard !parentRunEnded else { return .failure(32) }
                parsedParentOIDs.append(value)
            } else {
                parentRunEnded = true
            }
        case .continuation:
            if index > 0 { parentRunEnded = true }
        }
    }

    guard let treeOID = parsedTreeOID,
          isLowercaseHexOID(treeOID),
          parsedParentOIDs.allSatisfy(isLowercaseHexOID)
    else { return .failure(33) }

    let gpgsig = Array("gpgsig".utf8)
    let gpgsigSHA256 = Array("gpgsig-sha256".utf8)
    let mergetag = Array("mergetag".utf8)
    var attachedSignedHeader = false
    var gpgsigCount = 0
    var gpgsigSHA256Count = 0
    for line in lines {
        switch line {
        case let .field(name, _):
            attachedSignedHeader = name == gpgsig
                || name == gpgsigSHA256
                || name == mergetag
            if name == gpgsig { gpgsigCount += 1 }
            if name == gpgsigSHA256 { gpgsigSHA256Count += 1 }
        case .continuation:
            guard attachedSignedHeader else { return .failure(34) }
        }
    }
    guard gpgsigCount <= 1, gpgsigSHA256Count <= 1 else {
        return .failure(34)
    }

    return .success(ParsedCommitTopology(
        treeOID: treeOID,
        parentOIDs: parsedParentOIDs))
}

private func parseCommitObjectBytes(
    _ objectBytes: [UInt8],
    expectedTreeOID: [UInt8],
    expectedParentOIDs: [[UInt8]]
) -> Int32 {
    let topology: ParsedCommitTopology
    switch parseCommitObjectTopology(objectBytes) {
    case let .failure(status):
        return status
    case let .success(parsed):
        topology = parsed
    }

    guard topology.treeOID == expectedTreeOID else { return 41 }
    guard topology.parentOIDs == expectedParentOIDs else { return 42 }
    let bounded_byte_parser_reaches_one_closed_declared_classification =
        topology.treeOID.count == 40 && expectedTreeOID.count == 40
    guard bounded_byte_parser_reaches_one_closed_declared_classification
    else { return 26 }
    return 0
}

private func classify(
    bytes: [UInt8],
    arguments: ClassifierArguments
) -> Int32 {
    if let status = commitEnvelopeFailureStatus(
        bytes: bytes,
        literalCommitOID: arguments.literalCommitOID,
        advertisedByteCount: arguments.advertisedByteCount)
    {
        return status
    }
    return parseCommitObjectBytes(
        bytes,
        expectedTreeOID: arguments.expectedTreeOID,
        expectedParentOIDs: arguments.expectedParentOIDs)
}

private func commitEnvelopeFailureStatus(
    bytes: [UInt8],
    literalCommitOID: [UInt8],
    advertisedByteCount: Int
) -> Int32? {
    guard bytes.count <= maximumCommitObjectByteCount else { return 22 }
    guard bytes.count == advertisedByteCount else { return 23 }
    guard gitCommitObjectOID(
        advertisedByteCount: advertisedByteCount,
        bytes: bytes) == literalCommitOID
    else { return 24 }
    return nil
}

private func exactRelationWitness(parentOID: [UInt8]) -> [UInt8]? {
    guard isLowercaseHexOID(parentOID) else { return nil }
    var witness = parentOID
    witness.append(lineFeedByte)
    guard witness.count == exactRelationWitnessByteCount else { return nil }
    return witness
}

private func classifyOrderedMergeChildRelation(
    bytes: [UInt8],
    arguments: RelationClassifierArguments
) -> RelationClassification {
    if let status = commitEnvelopeFailureStatus(
        bytes: bytes,
        literalCommitOID: arguments.literalCommitOID,
        advertisedByteCount: arguments.advertisedByteCount)
    {
        return RelationClassification(status: status, witness: nil)
    }

    let topology: ParsedCommitTopology
    switch parseCommitObjectTopology(bytes) {
    case let .failure(status):
        return RelationClassification(status: status, witness: nil)
    case let .success(parsed):
        topology = parsed
    }

    let relation_safe_parent2_requires_base_flat_phases29_through33_equal_relation_phases31_through35 =
        topology.parentOIDs.count >= 2
    let witness =
        relation_safe_parent2_requires_base_flat_phases29_through33_equal_relation_phases31_through35
        ? exactRelationWitness(parentOID: topology.parentOIDs[1])
        : nil

    guard topology.treeOID == arguments.expectedTreeOID else {
        return RelationClassification(status: 41, witness: witness)
    }
    guard topology.parentOIDs.count == 2,
          topology.parentOIDs[0] == arguments.fixedParentOID
    else {
        return RelationClassification(status: 42, witness: witness)
    }
    guard witness != nil else {
        return RelationClassification(status: 26, witness: nil)
    }
    return RelationClassification(status: 0, witness: witness)
}

@inline(never)
private func writeExactRelationWitness(_ witness: [UInt8]) -> Bool {
    guard witness.count == exactRelationWitnessByteCount,
          witness.last == lineFeedByte,
          isLowercaseHexOID(Array(witness.dropLast()))
    else { return false }

    errno = 0
    let relation_witness_F_SETNOSIGPIPE_EINTR_short_write_exit28 =
        Darwin.fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, 1) != -1
    guard relation_witness_F_SETNOSIGPIPE_EINTR_short_write_exit28 else {
        return false
    }

    return witness.withUnsafeBytes { buffer -> Bool in
        while true {
            errno = 0
            let result = Darwin.write(
                STDOUT_FILENO,
                buffer.baseAddress,
                buffer.count)
            if result == -1 && errno == EINTR { continue }
            return result == buffer.count
        }
    }
}

private func selfTestArguments() -> ClassifierArguments {
    ClassifierArguments(
        literalCommitOID: Array(
            "60bc2812cc97ab2d2f2c7168aa101f7bfabcbf88".utf8),
        advertisedByteCount: 47,
        expectedTreeOID: Array(
            "0000000000000000000000000000000000000000".utf8),
        expectedParentOIDs: [])
}

private func relationSelfTestArguments(
    payload: [UInt8],
    expectedTreeOID: [UInt8],
    fixedParentOID: [UInt8]
) -> RelationClassifierArguments {
    RelationClassifierArguments(
        literalCommitOID: gitCommitObjectOID(
            advertisedByteCount: payload.count,
            bytes: payload),
        advertisedByteCount: payload.count,
        expectedTreeOID: expectedTreeOID,
        fixedParentOID: fixedParentOID)
}

private func relationSelfTestMatches(
    payload: [UInt8],
    expectedTreeOID: [UInt8],
    fixedParentOID: [UInt8],
    expectedStatus: Int32,
    expectedWitness: [UInt8]?
) -> Bool {
    let result = classifyOrderedMergeChildRelation(
        bytes: payload,
        arguments: relationSelfTestArguments(
            payload: payload,
            expectedTreeOID: expectedTreeOID,
            fixedParentOID: fixedParentOID))
    return result.status == expectedStatus
        && result.witness == expectedWitness
}

private func runSelfTest() -> Int32 {
    let tree0 = Array("0000000000000000000000000000000000000000".utf8)
    let tree3 = Array("3333333333333333333333333333333333333333".utf8)
    let fixedParent = Array(
        "1111111111111111111111111111111111111111".utf8)
    let parent2 = Array("2222222222222222222222222222222222222222".utf8)
    let wrongParent = Array(
        "4444444444444444444444444444444444444444".utf8)
    let parent3 = Array("5555555555555555555555555555555555555555".utf8)
    guard let expectedWitness = exactRelationWitness(parentOID: parent2)
    else { return 26 }

    let ordinaryPayload = Array(
        "tree 0000000000000000000000000000000000000000\n\n".utf8)
    guard classify(
        bytes: ordinaryPayload,
        arguments: selfTestArguments()) == 0
    else { return 26 }

    let validRelationPayload = Array(
        ("tree \(String(decoding: tree0, as: UTF8.self))\n"
            + "parent \(String(decoding: fixedParent, as: UTF8.self))\n"
            + "parent \(String(decoding: parent2, as: UTF8.self))\n\n").utf8)
    guard relationSelfTestMatches(
        payload: validRelationPayload,
        expectedTreeOID: tree0,
        fixedParentOID: fixedParent,
        expectedStatus: 0,
        expectedWitness: expectedWitness)
    else { return 26 }

    let wrongTreeTwoParentPayload = Array(
        ("tree \(String(decoding: tree3, as: UTF8.self))\n"
            + "parent \(String(decoding: fixedParent, as: UTF8.self))\n"
            + "parent \(String(decoding: parent2, as: UTF8.self))\n\n").utf8)
    guard relationSelfTestMatches(
        payload: wrongTreeTwoParentPayload,
        expectedTreeOID: tree0,
        fixedParentOID: fixedParent,
        expectedStatus: 41,
        expectedWitness: expectedWitness)
    else { return 26 }

    let wrongTreeOneParentPayload = Array(
        ("tree \(String(decoding: tree3, as: UTF8.self))\n"
            + "parent \(String(decoding: fixedParent, as: UTF8.self))\n\n").utf8)
    guard relationSelfTestMatches(
        payload: wrongTreeOneParentPayload,
        expectedTreeOID: tree0,
        fixedParentOID: fixedParent,
        expectedStatus: 41,
        expectedWitness: nil)
    else { return 26 }

    let wrongParentPayload = Array(
        ("tree \(String(decoding: tree0, as: UTF8.self))\n"
            + "parent \(String(decoding: wrongParent, as: UTF8.self))\n"
            + "parent \(String(decoding: parent2, as: UTF8.self))\n\n").utf8)
    guard relationSelfTestMatches(
        payload: wrongParentPayload,
        expectedTreeOID: tree0,
        fixedParentOID: fixedParent,
        expectedStatus: 42,
        expectedWitness: expectedWitness)
    else { return 26 }

    let threeParentPayload = Array(
        ("tree \(String(decoding: tree0, as: UTF8.self))\n"
            + "parent \(String(decoding: fixedParent, as: UTF8.self))\n"
            + "parent \(String(decoding: parent2, as: UTF8.self))\n"
            + "parent \(String(decoding: parent3, as: UTF8.self))\n\n").utf8)
    guard relationSelfTestMatches(
        payload: threeParentPayload,
        expectedTreeOID: tree0,
        fixedParentOID: fixedParent,
        expectedStatus: 42,
        expectedWitness: expectedWitness)
    else { return 26 }

    let structurallyMalformedPayload = Array(
        ("tree \(String(decoding: tree0, as: UTF8.self))\n"
            + "author fixture\n"
            + "parent \(String(decoding: fixedParent, as: UTF8.self))\n\n").utf8)
    guard relationSelfTestMatches(
        payload: structurallyMalformedPayload,
        expectedTreeOID: tree0,
        fixedParentOID: fixedParent,
        expectedStatus: 32,
        expectedWitness: nil)
    else { return 26 }

    let oneParentPayload = Array(
        ("tree \(String(decoding: tree0, as: UTF8.self))\n"
            + "parent \(String(decoding: fixedParent, as: UTF8.self))\n\n").utf8)
    guard relationSelfTestMatches(
        payload: oneParentPayload,
        expectedTreeOID: tree0,
        fixedParentOID: fixedParent,
        expectedStatus: 42,
        expectedWitness: nil)
    else { return 26 }

    return 0
}

private func classifierMain() -> Int32 {
    let selfTestRequested = CommandLine.arguments == [
        CommandLine.arguments[0], "--self-test",
    ]
    let relationModeRequested = CommandLine.arguments.count > 1
        && CommandLine.arguments[1] == orderedMergeChildRelationModeToken
    let relationArguments = selfTestRequested
        ? nil
        : parseRelationClassifierArguments()
    let arguments = selfTestRequested || relationModeRequested
        ? nil
        : parseClassifierArguments()
    let descriptorsClosed = closeInheritedFileDescriptorsUsingProcPIDInfo()
    let input = readStandardInputOnceToEOF()

    if selfTestRequested {
        guard input.bytes.isEmpty, !input.exceededBound else { return 20 }
        guard descriptorsClosed else { return 27 }
        guard input.readSucceeded else { return 21 }
        return runSelfTest()
    }

    if relationModeRequested {
        guard relationArguments != nil else { return 20 }
    } else {
        guard arguments != nil else { return 20 }
    }
    guard descriptorsClosed else { return 27 }
    guard input.readSucceeded else { return 21 }
    guard !input.exceededBound else { return 22 }

    if relationModeRequested {
        guard let relationArguments else { return 20 }
        let result = classifyOrderedMergeChildRelation(
            bytes: input.bytes,
            arguments: relationArguments)
        if let witness = result.witness,
           !writeExactRelationWitness(witness)
        {
            return 28
        }
        return result.status
    }

    guard let arguments else { return 20 }
    return classify(bytes: input.bytes, arguments: arguments)
}

Darwin.exit(classifierMain())
