//
//  SaveTests.swift
//
//
//  Created by Rounak Jain on 4/2/24.
//

import MLX
import XCTest

#if canImport(Darwin)
    import Darwin
#endif

final class SaveTests: XCTestCase {

    let temporaryPath = FileManager.default.temporaryDirectory.appending(
        path: UUID().uuidString,
        directoryHint: .isDirectory
    )

    override func setUpWithError() throws {
        setDefaultDevice()
        try FileManager.default.createDirectory(
            at: temporaryPath,
            withIntermediateDirectories: false
        )
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: temporaryPath)
    }

    public func testSaveArrays() throws {
        let safetensorsPath = temporaryPath.appending(
            path: "arrays.safetensors",
            directoryHint: .notDirectory
        )

        let arrays: [String: MLXArray] = [
            "foo": MLX.ones([1, 2]),
            "bar": MLX.zeros([2, 1]),
        ]

        try MLX.save(arrays: arrays, url: safetensorsPath)

        let loadedArrays = try MLX.loadArrays(url: safetensorsPath)
        XCTAssertEqual(loadedArrays.keys.sorted(), arrays.keys.sorted())

        assertEqual(try XCTUnwrap(loadedArrays["foo"]), try XCTUnwrap(arrays["foo"]))
        assertEqual(try XCTUnwrap(loadedArrays["bar"]), try XCTUnwrap(arrays["bar"]))
    }

    public func testSaveArray() throws {
        // single array npy file
        let path = temporaryPath.appending(
            path: "array.npy",
            directoryHint: .notDirectory
        )

        let array = MLX.ones([2, 4])

        try MLX.save(array: array, url: path)

        let loaded = try MLX.loadArray(url: path)

        assertEqual(array, loaded)
    }

    public func testSaveArraysData() throws {
        let arrays: [String: MLXArray] = [
            "foo": MLX.ones([1, 2]),
            "bar": MLX.zeros([2, 1]),
        ]

        let data = try saveToData(arrays: arrays)
        let loadedArrays = try loadArrays(data: data)
        XCTAssertEqual(loadedArrays.keys.sorted(), arrays.keys.sorted())

        assertEqual(try XCTUnwrap(loadedArrays["foo"]), try XCTUnwrap(arrays["foo"]))
        assertEqual(try XCTUnwrap(loadedArrays["bar"]), try XCTUnwrap(arrays["bar"]))
    }

    public func testSaveArraysMetadataData() throws {
        let arrays: [String: MLXArray] = [
            "foo": MLX.ones([1, 2]),
            "bar": MLX.zeros([2, 1]),
        ]
        let metadata = [
            "key": "value",
            "key2": "value2",
        ]

        let data = try saveToData(arrays: arrays, metadata: metadata)
        let (loadedArrays, loadedMetadata) = try loadArraysAndMetadata(data: data)
        XCTAssertEqual(loadedArrays.keys.sorted(), arrays.keys.sorted())

        assertEqual(try XCTUnwrap(loadedArrays["foo"]), try XCTUnwrap(arrays["foo"]))
        assertEqual(try XCTUnwrap(loadedArrays["bar"]), try XCTUnwrap(arrays["bar"]))
        XCTAssertEqual(loadedMetadata, metadata)
    }

    #if canImport(Darwin)
        public func testSaveAndLoadArraysWithFileDescriptor() throws {
            let path = temporaryPath.appending(
                path: "descriptor-round-trip.safetensors",
                directoryHint: .notDirectory
            )
            let descriptor = try openFile(
                at: path,
                flags: O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC
            )
            defer { _ = Darwin.close(descriptor) }

            XCTAssertEqual(Darwin.lseek(descriptor, 23, SEEK_SET), 23)

            let arrays: [String: MLXArray] = [
                "foo": MLX.ones([1, 2]),
                "bar": MLX.zeros([2, 1]),
            ]
            let metadata = ["source": "descriptor"]

            try MLX.save(
                arrays: arrays,
                metadata: metadata,
                fileDescriptor: descriptor,
                maximumBytes: 1 << 20
            )

            // Descriptor ownership and its shared file offset remain with the
            // caller even though the file itself was truncated and rewritten.
            XCTAssertEqual(Darwin.fcntl(descriptor, F_GETFD) & FD_CLOEXEC, FD_CLOEXEC)
            XCTAssertEqual(Darwin.lseek(descriptor, 0, SEEK_CUR), 23)

            let (loadedArrays, loadedMetadata) = try MLX.loadArraysAndMetadata(
                fileDescriptor: descriptor,
                stream: .cpu
            )
            XCTAssertEqual(Darwin.lseek(descriptor, 0, SEEK_CUR), 23)
            XCTAssertEqual(loadedArrays.keys.sorted(), arrays.keys.sorted())
            XCTAssertEqual(loadedMetadata, metadata)
            assertEqual(try XCTUnwrap(loadedArrays["foo"]), try XCTUnwrap(arrays["foo"]))
            assertEqual(try XCTUnwrap(loadedArrays["bar"]), try XCTUnwrap(arrays["bar"]))
        }

        public func testFileDescriptorSaveRejectsWriteBeforeCrossingCap() throws {
            let path = temporaryPath.appending(
                path: "descriptor-cap.safetensors",
                directoryHint: .notDirectory
            )
            let descriptor = try openFile(
                at: path,
                flags: O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC
            )
            defer { _ = Darwin.close(descriptor) }

            XCTAssertEqual(Darwin.lseek(descriptor, 5, SEEK_SET), 5)
            let arrays = ["value": MLX.ones([1])]

            XCTAssertThrowsError(
                try MLX.save(
                    arrays: arrays,
                    fileDescriptor: descriptor,
                    maximumBytes: 8
                )
            ) { error in
                guard
                    case .maximumBytesExceeded(
                        maximumBytes: 8,
                        attemptedBytes: let attemptedBytes
                    ) = error as? SafetensorsFileDescriptorError
                else {
                    return XCTFail("unexpected error: \(error)")
                }
                XCTAssertGreaterThan(attemptedBytes, 8)
            }

            var metadata = stat()
            XCTAssertEqual(Darwin.fstat(descriptor, &metadata), 0)
            // The complete 8-byte length callback was written. The following
            // header callback was rejected as a whole.
            XCTAssertEqual(metadata.st_size, 8)
            XCTAssertEqual(Darwin.lseek(descriptor, 0, SEEK_CUR), 5)

            XCTAssertThrowsError(
                try MLX.save(
                    arrays: arrays,
                    fileDescriptor: descriptor,
                    maximumBytes: 7
                )
            )
            XCTAssertEqual(Darwin.fstat(descriptor, &metadata), 0)
            // Even the first 8-byte callback crosses this cap, so no prefix of
            // that callback is written.
            XCTAssertEqual(metadata.st_size, 0)
            XCTAssertEqual(Darwin.lseek(descriptor, 0, SEEK_CUR), 5)
        }

        public func testDescriptorMaterializedLoadSurvivesPathnameReplacement() throws {
            let path = temporaryPath.appending(
                path: "descriptor-lazy.safetensors",
                directoryHint: .notDirectory
            )
            let writer = try openFile(
                at: path,
                flags: O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC
            )
            try MLX.save(
                arrays: ["value": MLXArray([Float(3.25)], [1])],
                metadata: ["generation": "original"],
                fileDescriptor: writer,
                maximumBytes: 1 << 20
            )
            XCTAssertEqual(Darwin.close(writer), 0)

            let reader = try openFile(at: path, flags: O_RDWR | O_CLOEXEC)
            let (loadedArrays, loadedMetadata) = try MLX.loadArraysAndMetadata(
                fileDescriptor: reader,
                stream: .cpu
            )
            XCTAssertEqual(Darwin.ftruncate(reader, 0), 0)
            XCTAssertEqual(Darwin.close(reader), 0)

            let replacement = temporaryPath.appending(
                path: "replacement.safetensors",
                directoryHint: .notDirectory
            )
            let replacementDescriptor = try openFile(
                at: replacement,
                flags: O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC
            )
            let invalidBytes = [UInt8](repeating: 0, count: 16)
            try invalidBytes.withUnsafeBytes {
                try writeAll($0, to: replacementDescriptor, at: 0)
            }
            XCTAssertEqual(Darwin.close(replacementDescriptor), 0)

            let renameResult = replacement.path.withCString { replacementPath in
                path.path.withCString { originalPath in
                    Darwin.rename(replacementPath, originalPath)
                }
            }
            XCTAssertEqual(renameResult, 0)

            XCTAssertEqual(loadedMetadata, ["generation": "original"])
            let loaded = try XCTUnwrap(loadedArrays["value"])
            loaded.eval()
            XCTAssertEqual(loaded.asArray(Float.self), [3.25])
        }

        public func testDescriptorReadAtOffsetAboveUInt32() throws {
            let path = temporaryPath.appending(
                path: "descriptor-sparse.safetensors",
                directoryHint: .notDirectory
            )
            let descriptor = try openFile(
                at: path,
                flags: O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC
            )
            defer { _ = Darwin.close(descriptor) }

            let relativeStart = UInt64(UInt32.max) + 4_096
            let relativeEnd = relativeStart + 1
            let json = """
                {"value":{"dtype":"U8","shape":[1],"data_offsets":[\(relativeStart),\(relativeEnd)]}}
                """
            let headerCount = try writeSafetensorsHeader(json, to: descriptor)

            let absoluteValueOffset = UInt64(8 + headerCount) + relativeStart
            var marker: UInt8 = 0xA7
            try withUnsafeBytes(of: &marker) {
                try writeAll($0, to: descriptor, at: off_t(absoluteValueOffset))
            }
            XCTAssertGreaterThan(absoluteValueOffset, UInt64(UInt32.max))

            let (loadedArrays, _) = try MLX.loadArraysAndMetadata(
                fileDescriptor: descriptor,
                stream: .cpu
            )
            let loaded = try XCTUnwrap(loadedArrays["value"])
            loaded.eval()
            XCTAssertEqual(loaded.asArray(UInt8.self), [0xA7])
        }

        public func testDescriptorLoadRejectsOutOfFileTensorRange() throws {
            let path = temporaryPath.appending(
                path: "descriptor-out-of-range.safetensors",
                directoryHint: .notDirectory
            )
            let descriptor = try openFile(
                at: path,
                flags: O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC
            )
            defer { _ = Darwin.close(descriptor) }

            let json = """
                {"value":{"dtype":"U8","shape":[1],"data_offsets":[0,1]}}
                """
            _ = try writeSafetensorsHeader(json, to: descriptor)

            XCTAssertThrowsError(
                try MLX.loadArraysAndMetadata(
                    fileDescriptor: descriptor,
                    stream: .cpu
                )
            ) { error in
                guard
                    case .invalidDescriptor(let message) =
                        error as? SafetensorsFileDescriptorError
                else {
                    return XCTFail("unexpected error: \(error)")
                }
                XCTAssertTrue(message.contains("data range exceeds the file"))
            }
        }

        public func testDescriptorLoadRejectsOffsetAdditionOverflow() throws {
            let path = temporaryPath.appending(
                path: "descriptor-offset-overflow.safetensors",
                directoryHint: .notDirectory
            )
            let descriptor = try openFile(
                at: path,
                flags: O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC
            )
            defer { _ = Darwin.close(descriptor) }

            let relativeStart = UInt64.max - 4
            let relativeEnd = relativeStart + 1
            let json = """
                {"value":{"dtype":"U8","shape":[1],"data_offsets":[\(relativeStart),\(relativeEnd)]}}
                """
            _ = try writeSafetensorsHeader(json, to: descriptor)

            XCTAssertThrowsError(
                try MLX.loadArraysAndMetadata(
                    fileDescriptor: descriptor,
                    stream: .cpu
                )
            ) { error in
                guard
                    case .invalidDescriptor(let message) =
                        error as? SafetensorsFileDescriptorError
                else {
                    return XCTFail("unexpected error: \(error)")
                }
                XCTAssertTrue(message.contains("data range exceeds the file"))
            }
        }

        public func testDescriptorLoadRejectsDecodedDuplicateKeys() throws {
            let path = temporaryPath.appending(
                path: "descriptor-duplicate-key.safetensors",
                directoryHint: .notDirectory
            )
            let descriptor = try openFile(
                at: path,
                flags: O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC
            )
            defer { _ = Darwin.close(descriptor) }

            let json =
                #"{"value":{"dtype":"U8","shape":[0],"data_offsets":[0,0]},"\u0076alue":{"dtype":"U8","shape":[0],"data_offsets":[0,0]}}"#
            _ = try writeSafetensorsHeader(json, to: descriptor)

            XCTAssertThrowsError(
                try MLX.loadArraysAndMetadata(
                    fileDescriptor: descriptor,
                    stream: .cpu
                )
            ) { error in
                guard
                    case .invalidDescriptor(let message) =
                        error as? SafetensorsFileDescriptorError
                else {
                    return XCTFail("unexpected error: \(error)")
                }
                XCTAssertTrue(message.contains("duplicate top-level key"))
            }
        }

        public func testDescriptorLoadRejectsNonIntegerOffsetTokens() throws {
            let path = temporaryPath.appending(
                path: "descriptor-noninteger-offset.safetensors",
                directoryHint: .notDirectory
            )
            let descriptor = try openFile(
                at: path,
                flags: O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC
            )
            defer { _ = Darwin.close(descriptor) }

            let json = """
                {"value":{"dtype":"U8","shape":[0],"data_offsets":[0e0,0]}}
                """
            _ = try writeSafetensorsHeader(json, to: descriptor)

            XCTAssertThrowsError(
                try MLX.loadArraysAndMetadata(
                    fileDescriptor: descriptor,
                    stream: .cpu
                )
            ) { error in
                guard
                    case .invalidDescriptor(let message) =
                        error as? SafetensorsFileDescriptorError
                else {
                    return XCTFail("unexpected error: \(error)")
                }
                XCTAssertTrue(message.contains("must use integer tokens"))
            }
        }

        public func testDescriptorIORejectsNonRegularFile() throws {
            var descriptors = [Int32](repeating: -1, count: 2)
            XCTAssertEqual(Darwin.pipe(&descriptors), 0)
            defer {
                _ = Darwin.close(descriptors[0])
                _ = Darwin.close(descriptors[1])
            }

            XCTAssertThrowsError(
                try MLX.loadArraysAndMetadata(
                    fileDescriptor: descriptors[0],
                    stream: .cpu
                )
            ) { error in
                guard case .invalidDescriptor = error as? SafetensorsFileDescriptorError else {
                    return XCTFail("unexpected error: \(error)")
                }
            }
        }

        private enum DescriptorTestError: Error {
            case posix(operation: String, errorCode: Int32)
        }

        private func openFile(at path: URL, flags: Int32) throws -> Int32 {
            let descriptor = path.path.withCString {
                Darwin.open($0, flags, mode_t(0o600))
            }
            guard descriptor >= 0 else {
                throw DescriptorTestError.posix(
                    operation: "open",
                    errorCode: errno
                )
            }
            return descriptor
        }

        @discardableResult
        private func writeSafetensorsHeader(
            _ json: String,
            to descriptor: Int32
        ) throws -> Int {
            let header = Array(json.utf8)
            var headerLength = UInt64(header.count).littleEndian
            try withUnsafeBytes(of: &headerLength) {
                try writeAll($0, to: descriptor, at: 0)
            }
            try header.withUnsafeBytes {
                try writeAll($0, to: descriptor, at: 8)
            }
            return header.count
        }

        private func writeAll(
            _ bytes: UnsafeRawBufferPointer,
            to descriptor: Int32,
            at offset: off_t
        ) throws {
            guard let baseAddress = bytes.baseAddress else { return }
            var completed = 0
            while completed < bytes.count {
                let result = Darwin.pwrite(
                    descriptor,
                    baseAddress.advanced(by: completed),
                    bytes.count - completed,
                    offset + off_t(completed)
                )
                if result > 0 {
                    completed += result
                } else if result < 0, errno == EINTR {
                    continue
                } else {
                    throw DescriptorTestError.posix(
                        operation: "pwrite",
                        errorCode: result == 0 ? EIO : errno
                    )
                }
            }
        }
    #endif

}
