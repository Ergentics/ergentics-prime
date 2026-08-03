// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation

struct PrimeSecureChildMemoryDrainSnapshot:
    Equatable,
    Sendable
{
    let data: Data
    let totalByteCount: UInt64
    let overflowed: Bool
    let workerFinished: Bool
    let reachedEOF: Bool
    let readErrorNumber: Int32
}

final class PrimeSecureChildMemoryBoundedDrain:
    @unchecked Sendable
{
    private let descriptor: Int32
    private let maximumByteCount:
        UInt64
    private let chunkByteCount: Int
    private let lock = NSLock()
    private var data = Data()
    private var totalByteCount: UInt64 = 0
    private var overflowed = false
    private var workerFinished = false
    private var reachedEOF = false
    private var readErrorNumber: Int32 = 0
    private var stopRequested = false

    init(
        descriptor: Int32,
        maximumByteCount: UInt64,
        chunkByteCount: Int
    ) {
        self.descriptor = descriptor
        self.maximumByteCount =
            maximumByteCount
        self.chunkByteCount =
            chunkByteCount
        data.reserveCapacity(
            Int(
                min(
                    maximumByteCount,
                    UInt64(
                        256 * 1024
                    )
                )
            )
        )
    }

    func start(group: DispatchGroup) {
        group.enter()
        DispatchQueue.global(
            qos: .utility
        ).async {
            self.drain()
            group.leave()
        }
    }

    func requestStop() {
        lock.lock()
        stopRequested = true
        lock.unlock()
    }

    func snapshot() -> PrimeSecureChildMemoryDrainSnapshot {
        lock.lock()
        defer {
            lock.unlock()
        }
        return PrimeSecureChildMemoryDrainSnapshot(
            data: data,
            totalByteCount:
                totalByteCount,
            overflowed: overflowed,
            workerFinished:
                workerFinished,
            reachedEOF:
                reachedEOF,
            readErrorNumber:
                readErrorNumber
        )
    }

    private func drain() {
        defer {
            lock.lock()
            workerFinished = true
            lock.unlock()
            _ = Darwin.close(
                descriptor
            )
        }
        var buffer = [UInt8](
            repeating: 0,
            count: chunkByteCount
        )
        while true {
            if shouldStop() {
                return
            }
            let count =
                buffer
                .withUnsafeMutableBytes {
                    Darwin.read(
                        descriptor,
                        $0.baseAddress,
                        $0.count
                    )
                }
            if count > 0 {
                consume(
                    buffer[0 ..< count]
                )
                continue
            }
            if count == 0 {
                lock.lock()
                reachedEOF = true
                lock.unlock()
                return
            }
            let readErrno = errno
            if readErrno == EINTR {
                continue
            }
            if readErrno == EAGAIN
                || readErrno == EWOULDBLOCK
            {
                var event =
                    pollfd(
                        fd: descriptor,
                        events:
                            Int16(
                                POLLIN
                                | POLLHUP
                                | POLLERR
                            ),
                        revents: 0
                    )
                let pollResult =
                    Darwin.poll(
                        &event,
                        1,
                        100
                    )
                if pollResult < 0,
                   errno != EINTR
                {
                    recordReadError(
                        errno
                    )
                    return
                }
                continue
            }
            recordReadError(
                readErrno
            )
            return
        }
    }

    private func shouldStop() -> Bool {
        lock.lock()
        defer {
            lock.unlock()
        }
        return stopRequested
    }

    private func consume(
        _ bytes:
            ArraySlice<UInt8>
    ) {
        lock.lock()
        defer {
            lock.unlock()
        }
        let next =
            totalByteCount
            .addingReportingOverflow(
                UInt64(bytes.count)
            )
        if next.overflow {
            totalByteCount =
                UInt64.max
            overflowed = true
        } else {
            totalByteCount =
                next.partialValue
            if totalByteCount
                > maximumByteCount
            {
                overflowed = true
            }
        }
        let remaining =
            maximumByteCount
                > UInt64(data.count)
            ? maximumByteCount
                - UInt64(data.count)
            : 0
        if remaining > 0 {
            data.append(
                contentsOf:
                    bytes.prefix(
                        Int(remaining)
                    )
            )
        }
    }

    private func recordReadError(
        _ errorNumber: Int32
    ) {
        lock.lock()
        readErrorNumber =
            errorNumber
        lock.unlock()
    }
}

struct PrimeSecureChildFileBackedDrainSnapshot:
    Equatable,
    Sendable
{
    let totalByteCount: UInt64
    let capturedByteCount: UInt64
    let overflowed: Bool
    let workerFinished: Bool
    let reachedEOF: Bool
    let readErrorNumber: Int32
    let writeErrorNumber: Int32
    let outputDeviceID: UInt64
    let outputInode: UInt64
    let outputByteCount: UInt64
    let outputPermissionMode: UInt16
    let outputSHA256: String
    let outputMetadataObserved: Bool
}

final class PrimeSecureChildFileBackedBoundedDrain:
    @unchecked Sendable
{
    private let inputDescriptor: Int32
    private let outputDescriptor: Int32
    private let maximumByteCount: UInt64
    private let lock = NSLock()
    private var totalByteCount: UInt64 = 0
    private var capturedByteCount: UInt64 = 0
    private var overflowed = false
    private var workerFinished = false
    private var reachedEOF = false
    private var readErrorNumber: Int32 = 0
    private var writeErrorNumber: Int32 = 0
    private var outputDeviceID: UInt64 = 0
    private var outputInode: UInt64 = 0
    private var outputByteCount: UInt64 = 0
    private var outputPermissionMode: UInt16 = 0
    private var outputSHA256 = ""
    private var outputMetadataObserved = false

    init(
        inputDescriptor: Int32,
        outputDescriptor: Int32,
        maximumByteCount: UInt64
    ) {
        self.inputDescriptor = inputDescriptor
        self.outputDescriptor = outputDescriptor
        self.maximumByteCount = maximumByteCount
    }

    func start(group: DispatchGroup) {
        group.enter()
        DispatchQueue.global(qos: .utility).async {
            self.drain()
            group.leave()
        }
    }

    func snapshot() -> PrimeSecureChildFileBackedDrainSnapshot {
        lock.lock()
        defer { lock.unlock() }
        return PrimeSecureChildFileBackedDrainSnapshot(
            totalByteCount: totalByteCount,
            capturedByteCount: capturedByteCount,
            overflowed: overflowed,
            workerFinished: workerFinished,
            reachedEOF: reachedEOF,
            readErrorNumber: readErrorNumber,
            writeErrorNumber: writeErrorNumber,
            outputDeviceID: outputDeviceID,
            outputInode: outputInode,
            outputByteCount: outputByteCount,
            outputPermissionMode: outputPermissionMode,
            outputSHA256: outputSHA256,
            outputMetadataObserved: outputMetadataObserved
        )
    }

    private func drain() {
        defer {
            finalizeOutput()
            Darwin.close(outputDescriptor)
            Darwin.close(inputDescriptor)
            lock.lock()
            workerFinished = true
            lock.unlock()
        }
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        while true {
            let count = buffer.withUnsafeMutableBytes {
                Darwin.read(inputDescriptor, $0.baseAddress, $0.count)
            }
            if count > 0 {
                consume(buffer[0 ..< count])
                continue
            }
            if count == 0 {
                lock.lock()
                reachedEOF = true
                lock.unlock()
                return
            }
            var failure = errno
            if failure == EINTR { continue }
            if failure == EAGAIN || failure == EWOULDBLOCK {
                var event = pollfd(
                    fd: inputDescriptor,
                    events: Int16(POLLIN | POLLHUP | POLLERR),
                    revents: 0
                )
                let polled = Darwin.poll(&event, 1, 100)
                if polled >= 0 || errno == EINTR { continue }
                failure = errno
            }
            lock.lock()
            readErrorNumber = failure
            lock.unlock()
            return
        }
    }

    private func consume(_ bytes: ArraySlice<UInt8>) {
        lock.lock()
        let addition = totalByteCount.addingReportingOverflow(
            UInt64(bytes.count)
        )
        totalByteCount = addition.overflow
            ? UInt64.max
            : addition.partialValue
        let remaining = maximumByteCount > capturedByteCount
            ? maximumByteCount - capturedByteCount
            : 0
        let wanted = Int(min(remaining, UInt64(bytes.count)))
        overflowed = addition.overflow
            || totalByteCount > maximumByteCount
        let mayWrite = writeErrorNumber == 0 && wanted > 0
        lock.unlock()

        guard mayWrite else { return }
        let prefix = bytes.prefix(wanted)
        var offset = 0
        while offset < prefix.count {
            let written = prefix.withUnsafeBytes {
                Darwin.write(
                    outputDescriptor,
                    $0.baseAddress!.advanced(by: offset),
                    $0.count - offset
                )
            }
            if written > 0 {
                offset += written
                continue
            }
            if written < 0 && errno == EINTR { continue }
            recordWriteError(errno)
            return
        }
        lock.lock()
        capturedByteCount += UInt64(offset)
        lock.unlock()
    }

    private func recordWriteError(_ value: Int32) {
        lock.lock()
        if writeErrorNumber == 0 {
            writeErrorNumber = value == 0 ? EIO : value
        }
        lock.unlock()
    }

    private func finalizeOutput() {
        if fchmod(outputDescriptor, mode_t(0o444)) != 0 {
            recordWriteError(errno)
        }
        if fsync(outputDescriptor) != 0 {
            recordWriteError(errno)
        }
        if fcntl(outputDescriptor, F_FULLFSYNC) != 0 {
            recordWriteError(errno)
        }
        var before = stat()
        lock.lock()
        let expectedByteCount = capturedByteCount
        lock.unlock()
        guard fstat(outputDescriptor, &before) == 0,
              before.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              before.st_uid == geteuid(),
              before.st_nlink == 1,
              before.st_mode & mode_t(0o7777) == mode_t(0o444),
              before.st_size >= 0,
              UInt64(before.st_size) == expectedByteCount
        else {
            recordWriteError(errno == 0 ? EIO : errno)
            return
        }
        let data: Data
        do {
            data = try PrimeSecureChildPath.readExact(
                descriptor: outputDescriptor,
                byteCount: Int(before.st_size)
            )
        } catch {
            recordWriteError(EIO)
            return
        }
        var after = stat()
        guard fstat(outputDescriptor, &after) == 0,
              after.st_dev == before.st_dev,
              after.st_ino == before.st_ino,
              after.st_mode == before.st_mode,
              after.st_nlink == before.st_nlink,
              after.st_size == before.st_size,
              after.st_mtimespec.tv_sec == before.st_mtimespec.tv_sec,
              after.st_mtimespec.tv_nsec == before.st_mtimespec.tv_nsec,
              after.st_ctimespec.tv_sec == before.st_ctimespec.tv_sec,
              after.st_ctimespec.tv_nsec == before.st_ctimespec.tv_nsec
        else {
            recordWriteError(errno == 0 ? EIO : errno)
            return
        }
        lock.lock()
        outputDeviceID = UInt64(bitPattern: Int64(after.st_dev))
        outputInode = UInt64(after.st_ino)
        outputByteCount = UInt64(after.st_size)
        outputPermissionMode =
            UInt16(after.st_mode & mode_t(0o7777))
        outputSHA256 = PrimeSHA256.hexDigest(of: data)
        outputMetadataObserved = true
        lock.unlock()
    }
}
