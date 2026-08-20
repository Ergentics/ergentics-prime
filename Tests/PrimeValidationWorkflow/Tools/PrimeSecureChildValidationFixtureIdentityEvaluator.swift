// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CryptoKit
import Darwin
import Foundation
import MachO

private let maximumFixtureByteCount = 4_194_304
private let maximumReadChunkByteCount = 65_536
private let evaluatorOutputSchemaID =
    "prime_secure_child_validation_fixture_identity_evaluator_output_v1"

private enum MeasurementRefusal: Error {
    case refused
}

private struct FileSnapshot {
    let device: UInt64
    let inode: UInt64
    let owner: UInt32
    let mode: mode_t
    let linkCount: UInt64
    let byteCount: Int
}

private struct MachOIdentity: Equatable {
    let uuid: String
    let platform: UInt32
    let minimumOS: UInt32
    let sdk: UInt32
    let buildVersionCommand: Data
}

private struct FixtureIdentity {
    let snapshot: FileSnapshot
    let bytes: Data
    let sha256: String
    let machO: MachOIdentity
}

private func checkedAdd(_ lhs: Int, _ rhs: Int) throws -> Int {
    let (value, overflow) = lhs.addingReportingOverflow(rhs)
    guard !overflow else { throw MeasurementRefusal.refused }
    return value
}

private func checkedMultiply(_ lhs: Int, _ rhs: Int) throws -> Int {
    let (value, overflow) = lhs.multipliedReportingOverflow(by: rhs)
    guard !overflow else { throw MeasurementRefusal.refused }
    return value
}

private func canonicalPhysicalPath(_ path: String) throws -> String {
    guard path.hasPrefix("/"), !path.utf8.contains(0) else {
        throw MeasurementRefusal.refused
    }
    guard let resolvedPointer = path.withCString({ realpath($0, nil) }) else {
        throw MeasurementRefusal.refused
    }
    defer { free(resolvedPointer) }
    guard let resolved = String(validatingUTF8: resolvedPointer), resolved == path else {
        throw MeasurementRefusal.refused
    }
    return resolved
}

private func snapshot(_ value: stat) throws -> FileSnapshot {
    guard (value.st_mode & S_IFMT) == S_IFREG,
          value.st_uid == geteuid(),
          value.st_nlink == 1,
          (value.st_mode & S_IXUSR) != 0,
          value.st_size > 0,
          let unsignedSize = UInt64(exactly: value.st_size),
          let admittedSize = Int(exactly: unsignedSize),
          admittedSize <= maximumFixtureByteCount,
          let device = UInt64(exactly: value.st_dev),
          let inode = UInt64(exactly: value.st_ino),
          let owner = UInt32(exactly: value.st_uid),
          let links = UInt64(exactly: value.st_nlink)
    else {
        throw MeasurementRefusal.refused
    }
    return FileSnapshot(
        device: device,
        inode: inode,
        owner: owner,
        mode: value.st_mode,
        linkCount: links,
        byteCount: admittedSize)
}

private func stableIdentity(_ lhs: FileSnapshot, _ rhs: FileSnapshot) -> Bool {
    lhs.device == rhs.device
        && lhs.inode == rhs.inode
        && lhs.owner == rhs.owner
        && lhs.mode == rhs.mode
        && lhs.linkCount == rhs.linkCount
        && lhs.byteCount == rhs.byteCount
}

private func lstatSnapshot(_ path: String) throws -> FileSnapshot {
    var value = stat()
    guard path.withCString({ Darwin.lstat($0, &value) }) == 0 else {
        throw MeasurementRefusal.refused
    }
    return try snapshot(value)
}

private func fstatSnapshot(_ descriptor: Int32) throws -> FileSnapshot {
    var value = stat()
    guard Darwin.fstat(descriptor, &value) == 0 else {
        throw MeasurementRefusal.refused
    }
    return try snapshot(value)
}

private func readExactly(
    descriptor: Int32,
    admittedByteCount: Int
) throws -> Data {
    var bytes = Data(count: admittedByteCount)
    try bytes.withUnsafeMutableBytes { rawBuffer in
        guard let baseAddress = rawBuffer.baseAddress else {
            throw MeasurementRefusal.refused
        }
        var offset = 0
        while offset < admittedByteCount {
            let remaining = admittedByteCount - offset
            let requested = min(remaining, maximumReadChunkByteCount)
            let result = Darwin.read(
                descriptor,
                baseAddress.advanced(by: offset),
                requested)
            if result < 0 && errno == EINTR {
                continue
            }
            guard result > 0, let readCount = Int(exactly: result) else {
                throw MeasurementRefusal.refused
            }
            let next = try checkedAdd(offset, readCount)
            guard next <= admittedByteCount else {
                throw MeasurementRefusal.refused
            }
            offset = next
        }
        guard offset == admittedByteCount else {
            throw MeasurementRefusal.refused
        }
    }

    var trailingByte: UInt8 = 0
    while true {
        let result = Darwin.read(descriptor, &trailingByte, 1)
        if result < 0 && errno == EINTR {
            continue
        }
        guard result == 0 else { throw MeasurementRefusal.refused }
        break
    }
    return bytes
}

private func readUInt32LE(_ bytes: Data, at offset: Int) throws -> UInt32 {
    let end = try checkedAdd(offset, 4)
    guard offset >= 0, end <= bytes.count else {
        throw MeasurementRefusal.refused
    }
    let byte1 = try checkedAdd(offset, 1)
    let byte2 = try checkedAdd(offset, 2)
    let byte3 = try checkedAdd(offset, 3)
    return UInt32(bytes[offset])
        | (UInt32(bytes[byte1]) << 8)
        | (UInt32(bytes[byte2]) << 16)
        | (UInt32(bytes[byte3]) << 24)
}

private func lowercaseHex<S: Sequence>(_ bytes: S) -> String where S.Element == UInt8 {
    let alphabet = Array("0123456789abcdef".utf8)
    var output = [UInt8]()
    output.reserveCapacity(bytes.underestimatedCount * 2)
    for byte in bytes {
        output.append(alphabet[Int(byte >> 4)])
        output.append(alphabet[Int(byte & 0x0f)])
    }
    return String(decoding: output, as: UTF8.self)
}

private func parseMachO(_ bytes: Data) throws -> MachOIdentity {
    let headerByteCount = MemoryLayout<mach_header_64>.size
    let loadCommandHeaderByteCount = MemoryLayout<load_command>.size
    guard headerByteCount == 32,
          loadCommandHeaderByteCount == 8,
          bytes.count >= headerByteCount,
          try readUInt32LE(bytes, at: 0) == UInt32(MH_MAGIC_64),
          try readUInt32LE(bytes, at: 4) == UInt32(bitPattern: CPU_TYPE_ARM64),
          try readUInt32LE(bytes, at: 12) == UInt32(MH_EXECUTE)
    else {
        throw MeasurementRefusal.refused
    }

    let commandCount = try readUInt32LE(bytes, at: 16)
    let commandRegionByteCount = try readUInt32LE(bytes, at: 20)
    guard let commandCountInt = Int(exactly: commandCount),
          let commandRegionByteCountInt = Int(exactly: commandRegionByteCount),
          commandCountInt <= commandRegionByteCountInt / loadCommandHeaderByteCount
    else {
        throw MeasurementRefusal.refused
    }
    let commandRegionEnd = try checkedAdd(headerByteCount, commandRegionByteCountInt)
    guard commandRegionEnd <= bytes.count else {
        throw MeasurementRefusal.refused
    }

    var uuid: String?
    var buildPlatform: UInt32?
    var minimumOS: UInt32?
    var sdk: UInt32?
    var buildVersionCommand: Data?
    var uuidCount = 0
    var buildVersionCount = 0
    var codeSignatureCount = 0
    var offset = headerByteCount

    for _ in 0..<commandCountInt {
        let commandHeaderEnd = try checkedAdd(offset, loadCommandHeaderByteCount)
        guard commandHeaderEnd <= commandRegionEnd else {
            throw MeasurementRefusal.refused
        }
        let command = try readUInt32LE(bytes, at: offset)
        let commandSizeOffset = try checkedAdd(offset, 4)
        let commandSize = try readUInt32LE(bytes, at: commandSizeOffset)
        guard let commandSizeInt = Int(exactly: commandSize),
              commandSizeInt >= 8,
              commandSizeInt % 8 == 0
        else {
            throw MeasurementRefusal.refused
        }
        let commandEnd = try checkedAdd(offset, commandSizeInt)
        guard commandEnd <= commandRegionEnd else {
            throw MeasurementRefusal.refused
        }

        if command == UInt32(LC_UUID) {
            uuidCount = try checkedAdd(uuidCount, 1)
            guard commandSizeInt == 24 else {
                throw MeasurementRefusal.refused
            }
            let uuidStart = try checkedAdd(offset, 8)
            let uuidEnd = try checkedAdd(offset, 24)
            uuid = lowercaseHex(bytes[uuidStart..<uuidEnd])
        } else if command == UInt32(LC_BUILD_VERSION) {
            buildVersionCount = try checkedAdd(buildVersionCount, 1)
            guard commandSizeInt >= 24 else {
                throw MeasurementRefusal.refused
            }
            let toolCountOffset = try checkedAdd(offset, 20)
            let toolCount = try readUInt32LE(bytes, at: toolCountOffset)
            guard let toolCountInt = Int(exactly: toolCount) else {
                throw MeasurementRefusal.refused
            }
            let toolBytes = try checkedMultiply(toolCountInt, 8)
            let expectedCommandSize = try checkedAdd(24, toolBytes)
            guard commandSizeInt == expectedCommandSize else {
                throw MeasurementRefusal.refused
            }
            let platformOffset = try checkedAdd(offset, 8)
            let minimumOSOffset = try checkedAdd(offset, 12)
            let sdkOffset = try checkedAdd(offset, 16)
            let platform = try readUInt32LE(bytes, at: platformOffset)
            guard platform == UInt32(PLATFORM_MACOS) else {
                throw MeasurementRefusal.refused
            }
            buildPlatform = platform
            minimumOS = try readUInt32LE(bytes, at: minimumOSOffset)
            sdk = try readUInt32LE(bytes, at: sdkOffset)
            buildVersionCommand = Data(bytes[offset..<commandEnd])
        } else if command == UInt32(LC_CODE_SIGNATURE) {
            codeSignatureCount = try checkedAdd(codeSignatureCount, 1)
            guard commandSizeInt == 16 else {
                throw MeasurementRefusal.refused
            }
            let dataOffsetField = try checkedAdd(offset, 8)
            let dataSizeField = try checkedAdd(offset, 12)
            let dataOffset = try readUInt32LE(bytes, at: dataOffsetField)
            let dataSize = try readUInt32LE(bytes, at: dataSizeField)
            guard let dataOffsetInt = Int(exactly: dataOffset),
                  let dataSizeInt = Int(exactly: dataSize)
            else {
                throw MeasurementRefusal.refused
            }
            let signatureEnd = try checkedAdd(dataOffsetInt, dataSizeInt)
            guard dataOffsetInt >= 0, signatureEnd <= bytes.count else {
                throw MeasurementRefusal.refused
            }
        }
        offset = commandEnd
    }

    guard offset == commandRegionEnd,
          uuidCount == 1,
          buildVersionCount == 1,
          codeSignatureCount == 1,
          let uuid,
          let buildPlatform,
          let minimumOS,
          let sdk,
          let buildVersionCommand
    else {
        throw MeasurementRefusal.refused
    }
    return MachOIdentity(
        uuid: uuid,
        platform: buildPlatform,
        minimumOS: minimumOS,
        sdk: sdk,
        buildVersionCommand: buildVersionCommand)
}

private func measureFixture(at suppliedPath: String) throws -> FixtureIdentity {
    let path = try canonicalPhysicalPath(suppliedPath)
    let initialNameSnapshot = try lstatSnapshot(path)
    let descriptor = path.withCString {
        Darwin.open($0, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
    }
    guard descriptor >= 0 else { throw MeasurementRefusal.refused }
    defer { _ = Darwin.close(descriptor) }

    let descriptorBefore = try fstatSnapshot(descriptor)
    let nameBeforeRead = try lstatSnapshot(path)
    guard stableIdentity(initialNameSnapshot, descriptorBefore),
          stableIdentity(descriptorBefore, nameBeforeRead)
    else {
        throw MeasurementRefusal.refused
    }

    let bytes = try readExactly(
        descriptor: descriptor,
        admittedByteCount: descriptorBefore.byteCount)
    let descriptorAfter = try fstatSnapshot(descriptor)
    let nameAfterRead = try lstatSnapshot(path)
    guard stableIdentity(descriptorBefore, descriptorAfter),
          stableIdentity(descriptorAfter, nameAfterRead),
          bytes.count == descriptorBefore.byteCount
    else {
        throw MeasurementRefusal.refused
    }

    let digest = SHA256.hash(data: bytes)
    return FixtureIdentity(
        snapshot: descriptorAfter,
        bytes: bytes,
        sha256: lowercaseHex(digest),
        machO: try parseMachO(bytes))
}

private func booleanJSON(_ value: Bool) -> String {
    value ? "true" : "false"
}

private func canonicalOutput(
    fixtureA: FixtureIdentity,
    fixtureB: FixtureIdentity
) throws -> Data {
    let byteCountEqual = fixtureA.snapshot.byteCount == fixtureB.snapshot.byteCount
    let sha256Equal = fixtureA.sha256 == fixtureB.sha256
    let fullBytesEqual = fixtureA.bytes == fixtureB.bytes
    let machOIdentityEqual = fixtureA.machO == fixtureB.machO
    guard !fullBytesEqual || (byteCountEqual && sha256Equal && machOIdentityEqual) else {
        throw MeasurementRefusal.refused
    }

    let output = "{\"byte_count_equal\":\(booleanJSON(byteCountEqual)),"
        + "\"fixture_a_build_platform_packed\":\(fixtureA.machO.platform),"
        + "\"fixture_a_byte_count\":\(fixtureA.snapshot.byteCount),"
        + "\"fixture_a_macho_uuid\":\"\(fixtureA.machO.uuid)\","
        + "\"fixture_a_minimum_os_packed\":\(fixtureA.machO.minimumOS),"
        + "\"fixture_a_sdk_packed\":\(fixtureA.machO.sdk),"
        + "\"fixture_a_sha256\":\"\(fixtureA.sha256)\","
        + "\"fixture_b_build_platform_packed\":\(fixtureB.machO.platform),"
        + "\"fixture_b_byte_count\":\(fixtureB.snapshot.byteCount),"
        + "\"fixture_b_macho_uuid\":\"\(fixtureB.machO.uuid)\","
        + "\"fixture_b_minimum_os_packed\":\(fixtureB.machO.minimumOS),"
        + "\"fixture_b_sdk_packed\":\(fixtureB.machO.sdk),"
        + "\"fixture_b_sha256\":\"\(fixtureB.sha256)\","
        + "\"full_bytes_equal\":\(booleanJSON(fullBytesEqual)),"
        + "\"macho_identity_equal\":\(booleanJSON(machOIdentityEqual)),"
        + "\"schema_id\":\"\(evaluatorOutputSchemaID)\","
        + "\"schema_version\":1,"
        + "\"sha256_equal\":\(booleanJSON(sha256Equal))}"
    let data = Data(output.utf8)
    guard data.count <= 2_048,
          !data.contains(0),
          !data.contains(10),
          !data.contains(13),
          data.allSatisfy({ $0 < 128 })
    else {
        throw MeasurementRefusal.refused
    }
    return data
}

private func writeAll(_ data: Data, descriptor: Int32) throws {
    try data.withUnsafeBytes { rawBuffer in
        guard let baseAddress = rawBuffer.baseAddress else {
            throw MeasurementRefusal.refused
        }
        var offset = 0
        while offset < data.count {
            let result = Darwin.write(
                descriptor,
                baseAddress.advanced(by: offset),
                data.count - offset)
            if result < 0 && errno == EINTR {
                continue
            }
            guard result > 0, let written = Int(exactly: result) else {
                throw MeasurementRefusal.refused
            }
            offset = try checkedAdd(offset, written)
            guard offset <= data.count else {
                throw MeasurementRefusal.refused
            }
        }
    }
}

private func closeUnrelatedInheritedDescriptors() throws {
    var limits = rlimit()
    guard getrlimit(RLIMIT_NOFILE, &limits) == 0,
          let upperBound = Int32(exactly: limits.rlim_cur),
          upperBound >= 3,
          upperBound <= 1_048_576
    else {
        throw MeasurementRefusal.refused
    }
    var descriptor: Int32 = 3
    while descriptor < upperBound {
        let closeStatus = Darwin.close(descriptor)
        guard closeStatus == 0 || errno == EBADF else {
            throw MeasurementRefusal.refused
        }
        let (next, overflow) = descriptor.addingReportingOverflow(1)
        guard !overflow else { throw MeasurementRefusal.refused }
        descriptor = next
    }
}

private func run() -> Int32 {
    let arguments = CommandLine.arguments
    guard arguments.count == 4,
          arguments[1] == "measure_fixture_identity"
    else {
        return 1
    }
    do {
        try closeUnrelatedInheritedDescriptors()
        let fixtureA = try measureFixture(at: arguments[2])
        let fixtureB = try measureFixture(at: arguments[3])
        guard fixtureA.snapshot.device == fixtureB.snapshot.device,
              fixtureA.snapshot.inode != fixtureB.snapshot.inode
        else {
            throw MeasurementRefusal.refused
        }
        let output = try canonicalOutput(fixtureA: fixtureA, fixtureB: fixtureB)
        try writeAll(output, descriptor: STDOUT_FILENO)
        return 0
    } catch {
        return 1
    }
}

exit(run())
