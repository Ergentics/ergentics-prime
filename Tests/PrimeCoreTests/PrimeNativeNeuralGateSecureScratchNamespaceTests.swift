import Darwin
import Dispatch
import Foundation
import XCTest
@testable import PrimeCore

@_silgen_name("mbr_uid_to_uuid")
private func primeScratchTestUIDToUUID(
    _ identifier: uid_t,
    _ uuid: UnsafeMutablePointer<uuid_t>
) -> Int32

final class PrimeNativeNeuralGateSecureScratchNamespaceTests:
    XCTestCase
{
    func testFreshPerRoleNamespacesExpandExactLaunchPolicy()
        throws
    {
        let sourceDescriptor =
            try openPackageRoot()
        defer {
            _ = Darwin.close(
                sourceDescriptor
            )
        }
        let probe =
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: .probe,
                sourceRootDescriptor:
                    sourceDescriptor
            )
        defer {
            probe.close()
        }
        let verifier =
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: .verifier,
                sourceRootDescriptor:
                    sourceDescriptor
            )
        defer {
            verifier.close()
        }

        XCTAssertNotEqual(
            probe.runRootAbsolutePath,
            verifier.runRootAbsolutePath
        )
        XCTAssertTrue(
            probe.runRootAbsolutePath
                .contains(
                    "ergentics-prime-neural-gate-probe-"
                )
        )
        XCTAssertTrue(
            verifier.runRootAbsolutePath
                .contains(
                    "ergentics-prime-neural-gate-verifier-"
                )
        )

        let launch =
            try probe.launchConfiguration
        XCTAssertEqual(
            launch.arguments,
            [
                "--scratch-path",
                probe.runRootAbsolutePath
                    + "/work",
                "--cache-path",
                probe.runRootAbsolutePath
                    + "/cache",
                "--config-path",
                probe.runRootAbsolutePath
                    + "/config",
                "--security-path",
                probe.runRootAbsolutePath
                    + "/security",
                "--disable-dependency-cache",
                "--manifest-cache",
                "none",
                "--disable-prefetching",
                "--disable-automatic-resolution",
                "--disable-netrc",
                "--disable-keychain",
                "describe",
                "--type",
                "json",
            ]
        )
        XCTAssertFalse(
            launch.arguments.contains(
                "--skip-update"
            )
        )
        XCTAssertFalse(
            launch.arguments.contains(
                "--disable-sandbox"
            )
        )
        XCTAssertEqual(
            launch.orderedEnvironment
                .map(\.0),
            [
                "HOME",
                "TMPDIR",
                "CLANG_MODULE_CACHE_PATH",
                "SWIFT_MODULECACHE_PATH",
            ]
        )
        XCTAssertEqual(
            Dictionary(
                uniqueKeysWithValues:
                    launch
                    .orderedEnvironment
            ),
            [
                "HOME":
                    probe.runRootAbsolutePath
                    + "/home",
                "TMPDIR":
                    probe.runRootAbsolutePath
                    + "/tmp",
                "CLANG_MODULE_CACHE_PATH":
                    probe.runRootAbsolutePath
                    + "/module-cache",
                "SWIFT_MODULECACHE_PATH":
                    probe.runRootAbsolutePath
                    + "/module-cache",
            ]
        )

        _ = try probe.validateBeforeResume()
        _ = try probe.validateAfterReap(
            outerDeadlineMonotonicNanoseconds:
                futureDeadline()
        )
        let observation =
            try probe.observation()
        try observation.validate(
            role: .probe
        )
        XCTAssertEqual(
            observation
                .heldDirectoryDescriptorCount,
            8
        )
        XCTAssertEqual(
            observation.postAuditFileCount,
            0
        )
        XCTAssertEqual(
            observation
                .postAuditDirectoryCount,
            8
        )
        XCTAssertFalse(
            observation
                .networkDenialEstablished
        )
        XCTAssertFalse(
            observation
                .dependencyResolutionPermitted
        )
        XCTAssertTrue(
            observation
                .resolutionResiduesAbsent
        )
        XCTAssertEqual(
            observation
                .resolutionResiduePathCount,
            0
        )
        XCTAssertEqual(
            observation.schemaVersion,
            2
        )
        XCTAssertEqual(
            observation
                .extendedAttributePolicyID,
            "optional_exact_text_encoding_work_lock_bounded_opaque_provenance_v1"
        )
        XCTAssertEqual(
            observation
                .textEncodingObservedCount,
            0
        )
        XCTAssertTrue(
            observation
                .textEncodingAbsencePermitted
        )
        XCTAssertTrue(
            observation
                .allObservedTextEncodingAttributesMatchedPolicy
        )
        XCTAssertTrue(
            observation
                .provenanceValueOpaqueAndNonAuthoritative
        )
        XCTAssertEqual(
            observation
                .maximumProvenanceValueByteCount,
            4_096
        )
    }

    func testExactTextEncodingAtWorkLockIsAcceptedAndCounted()
        throws
    {
        let scratch = try makeScratch()
        defer {
            scratch.close()
        }
        _ = try scratch.validateBeforeResume()
        let descriptor =
            try createRegularFile(
                scratch: scratch,
                relativePath: "work/.lock"
            )
        defer {
            _ = Darwin.close(descriptor)
        }
        try setExtendedAttribute(
            descriptor: descriptor,
            name: "com.apple.TextEncoding",
            value: Array(
                "utf-8;134217984".utf8
            )
        )

        _ = try scratch.validateAfterReap(
            outerDeadlineMonotonicNanoseconds:
                futureDeadline()
        )
        let observation =
            try scratch.observation()
        try observation.validate(role: .probe)
        XCTAssertEqual(
            observation
                .textEncodingRelativePath,
            "work/.lock"
        )
        XCTAssertEqual(
            observation
                .textEncodingRequiredNodeType,
            "regular_file"
        )
        XCTAssertEqual(
            observation
                .textEncodingExactValue,
            "utf-8;134217984"
        )
        XCTAssertEqual(
            observation
                .textEncodingExactByteCount,
            15
        )
        XCTAssertEqual(
            observation
                .textEncodingObservedCount,
            1
        )
    }

    func testTextEncodingWrongPathAndWrongNodeAreRejected()
        throws
    {
        do {
            let scratch = try makeScratch()
            defer {
                scratch.close()
            }
            _ = try scratch.validateBeforeResume()
            let descriptor =
                try createRegularFile(
                    scratch: scratch,
                    relativePath:
                        "home/.lock"
                )
            defer {
                _ = Darwin.close(
                    descriptor
                )
            }
            try setExtendedAttribute(
                descriptor: descriptor,
                name:
                    "com.apple.TextEncoding",
                value: Array(
                    "utf-8;134217984".utf8
                )
            )
            XCTAssertThrowsError(
                try scratch.validateAfterReap(
                    outerDeadlineMonotonicNanoseconds:
                        futureDeadline()
                )
            )
        }
        do {
            let scratch = try makeScratch()
            defer {
                scratch.close()
            }
            _ = try scratch.validateBeforeResume()
            XCTAssertEqual(
                mkdirat(
                    scratch.runRootDescriptor,
                    "work/.lock",
                    mode_t(0o700)
                ),
                0
            )
            let descriptor =
                Darwin.openat(
                    scratch.runRootDescriptor,
                    "work/.lock",
                    O_RDONLY
                        | O_DIRECTORY
                        | O_NOFOLLOW_ANY
                        | O_CLOEXEC
                )
            XCTAssertGreaterThanOrEqual(
                descriptor,
                3
            )
            defer {
                if descriptor >= 0 {
                    _ = Darwin.close(
                        descriptor
                    )
                }
            }
            try setExtendedAttribute(
                descriptor: descriptor,
                name:
                    "com.apple.TextEncoding",
                value: Array(
                    "utf-8;134217984".utf8
                )
            )
            XCTAssertThrowsError(
                try scratch.validateAfterReap(
                    outerDeadlineMonotonicNanoseconds:
                        futureDeadline()
                )
            )
        }
    }

    func testTextEncodingValueMutationsAreRejected()
        throws
    {
        let mutations:
            [(String, [UInt8])] = [
                (
                    "uppercase",
                    Array(
                        "UTF-8;134217984".utf8
                    )
                ),
                (
                    "numeric_mismatch",
                    Array(
                        "utf-8;134217985".utf8
                    )
                ),
                ("empty", []),
                (
                    "partial",
                    Array("utf-8;".utf8)
                ),
                (
                    "nul_suffix",
                    Array(
                        "utf-8;134217984".utf8
                    ) + [0]
                ),
                (
                    "newline_suffix",
                    Array(
                        "utf-8;134217984\n".utf8
                    )
                ),
                (
                    "space_suffix",
                    Array(
                        "utf-8;134217984 ".utf8
                    )
                ),
                (
                    "prefix",
                    Array(
                        "xutf-8;134217984".utf8
                    )
                ),
                (
                    "suffix",
                    Array(
                        "utf-8;134217984x".utf8
                    )
                ),
                (
                    "future_extension",
                    Array(
                        "utf-8;134217984;v2".utf8
                    )
                ),
                (
                    "oversize",
                    [UInt8](
                        repeating: 0x61,
                        count: 4_097
                    )
                ),
            ]
        for (label, value) in mutations {
            let scratch = try makeScratch()
            defer {
                scratch.close()
            }
            _ = try scratch.validateBeforeResume()
            let descriptor =
                try createRegularFile(
                    scratch: scratch,
                    relativePath:
                        "work/.lock"
                )
            try setExtendedAttribute(
                descriptor: descriptor,
                name:
                    "com.apple.TextEncoding",
                value: value
            )
            _ = Darwin.close(descriptor)
            XCTAssertThrowsError(
                try scratch.validateAfterReap(
                    outerDeadlineMonotonicNanoseconds:
                        futureDeadline()
                ),
                label
            )
        }
    }

    func testUnknownExtendedAttributeIsRejected()
        throws
    {
        let scratch = try makeScratch()
        defer {
            scratch.close()
        }
        _ = try scratch.validateBeforeResume()
        let descriptor =
            try createRegularFile(
                scratch: scratch,
                relativePath: "work/output"
            )
        defer {
            _ = Darwin.close(descriptor)
        }
        try setExtendedAttribute(
            descriptor: descriptor,
            name:
                "com.ergentics.untrusted",
            value: [1]
        )
        XCTAssertThrowsError(
            try scratch.validateAfterReap(
                outerDeadlineMonotonicNanoseconds:
                    futureDeadline()
            )
        )
    }

    func testOpaqueProvenanceDescriptorBranchAndValueBound()
        throws
    {
        let scratch = try makeScratch()
        defer {
            scratch.close()
        }
        _ = try scratch.validateBeforeResume()
        let descriptor =
            try createRegularFile(
                scratch: scratch,
                relativePath: "work/output"
            )
        defer {
            _ = Darwin.close(descriptor)
        }
        // Darwin owns this attribute's stored representation; the test
        // exercises the descriptor-read branch without treating its bytes as
        // authority.
        try setExtendedAttribute(
            descriptor: descriptor,
            name: "com.apple.provenance",
            value: [0x01, 0x02]
        )

        _ = try scratch.validateAfterReap(
            outerDeadlineMonotonicNanoseconds:
                futureDeadline()
        )
        let observation =
            try scratch.observation()
        try observation.validate(role: .probe)
        XCTAssertTrue(
            observation
                .provenanceValueOpaqueAndNonAuthoritative
        )
        XCTAssertEqual(
            observation
                .maximumProvenanceValueByteCount,
            4_096
        )
        XCTAssertTrue(
            PrimeNativeNeuralGateSecureScratchNamespace
                .isPermittedOpaqueProvenanceValueByteCount(
                    4_096
                )
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateSecureScratchNamespace
                .isPermittedOpaqueProvenanceValueByteCount(
                    4_097
                )
        )
        XCTAssertFalse(
            PrimeNativeNeuralGateSecureScratchNamespace
                .isPermittedOpaqueProvenanceValueByteCount(
                    -1
                )
        )
    }

    func testExactTextEncodingDoesNotOverrideACLRejection()
        throws
    {
        let scratch = try makeScratch()
        defer {
            scratch.close()
        }
        _ = try scratch.validateBeforeResume()
        let descriptor =
            try createRegularFile(
                scratch: scratch,
                relativePath: "work/.lock"
            )
        defer {
            _ = Darwin.close(descriptor)
        }
        try setExtendedAttribute(
            descriptor: descriptor,
            name: "com.apple.TextEncoding",
            value: Array(
                "utf-8;134217984".utf8
            )
        )
        try addExtendedACL(
            descriptor: descriptor
        )
        XCTAssertThrowsError(
            try scratch.validateAfterReap(
                outerDeadlineMonotonicNanoseconds:
                    futureDeadline()
            )
        )
    }

    func testHeldPathSwapIsRejected()
        throws
    {
        let sourceDescriptor =
            try openPackageRoot()
        defer {
            _ = Darwin.close(
                sourceDescriptor
            )
        }
        let scratch =
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: .probe,
                sourceRootDescriptor:
                    sourceDescriptor
            )
        defer {
            scratch.close()
        }

        XCTAssertEqual(
            renameat(
                scratch.runRootDescriptor,
                "work",
                scratch.runRootDescriptor,
                "work-away"
            ),
            0
        )
        XCTAssertEqual(
            mkdirat(
                scratch.runRootDescriptor,
                "work",
                mode_t(0o700)
            ),
            0
        )
        XCTAssertThrowsError(
            try scratch.validateBeforeResume()
        )
    }

    func testFIFOIsRejectedWithoutBlockingPostAudit()
        throws
    {
        let sourceDescriptor =
            try openPackageRoot()
        defer {
            _ = Darwin.close(
                sourceDescriptor
            )
        }
        let scratch =
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: .probe,
                sourceRootDescriptor:
                    sourceDescriptor
            )
        defer {
            scratch.close()
        }
        _ = try scratch.validateBeforeResume()
        XCTAssertEqual(
            mkfifoat(
                scratch.runRootDescriptor,
                "work/blocking-fifo",
                mode_t(0o600)
            ),
            0
        )

        let started =
            DispatchTime.now()
            .uptimeNanoseconds
        XCTAssertThrowsError(
            try scratch.validateAfterReap(
                outerDeadlineMonotonicNanoseconds:
                    futureDeadline()
            )
        )
        let elapsed =
            DispatchTime.now()
            .uptimeNanoseconds
            - started
        XCTAssertLessThan(
            elapsed,
            1_000_000_000
        )
    }

    func testRenameAwayAndBackIsRejectedByVnodeReceipt()
        throws
    {
        let sourceDescriptor =
            try openPackageRoot()
        defer {
            _ = Darwin.close(
                sourceDescriptor
            )
        }
        let scratch =
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: .probe,
                sourceRootDescriptor:
                    sourceDescriptor
            )
        defer {
            scratch.close()
        }
        _ = try scratch.validateBeforeResume()
        XCTAssertEqual(
            renameat(
                scratch.runRootDescriptor,
                "work",
                scratch.runRootDescriptor,
                "work-away"
            ),
            0
        )
        XCTAssertEqual(
            renameat(
                scratch.runRootDescriptor,
                "work-away",
                scratch.runRootDescriptor,
                "work"
            ),
            0
        )

        XCTAssertThrowsError(
            try scratch.validateAfterReap(
                outerDeadlineMonotonicNanoseconds:
                    futureDeadline()
            )
        )
    }

    func testPackageResolvedResidueIsRejected()
        throws
    {
        let sourceDescriptor =
            try openPackageRoot()
        defer {
            _ = Darwin.close(
                sourceDescriptor
            )
        }
        let scratch =
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: .probe,
                sourceRootDescriptor:
                    sourceDescriptor
            )
        defer {
            scratch.close()
        }
        _ = try scratch.validateBeforeResume()
        let residueDescriptor =
            Darwin.openat(
                scratch.runRootDescriptor,
                "work/Package.resolved",
                O_WRONLY
                    | O_CREAT
                    | O_EXCL
                    | O_CLOEXEC,
                mode_t(0o600)
            )
        XCTAssertGreaterThanOrEqual(
            residueDescriptor,
            3
        )
        if residueDescriptor >= 0 {
            _ = Darwin.close(
                residueDescriptor
            )
        }

        XCTAssertThrowsError(
            try scratch.validateAfterReap(
                outerDeadlineMonotonicNanoseconds:
                    futureDeadline()
            )
        )
        XCTAssertEqual(
            unlinkat(
                scratch.runRootDescriptor,
                "work/Package.resolved",
                0
            ),
            0
        )
        XCTAssertThrowsError(
            try scratch.validateAfterReap(
                outerDeadlineMonotonicNanoseconds:
                    futureDeadline()
            )
        )
        XCTAssertThrowsError(
            try scratch.launchConfiguration
        )
    }

    func testHomeResolutionResidueIsRejectedAndPoisonsNamespace()
        throws
    {
        let sourceDescriptor =
            try openPackageRoot()
        defer {
            _ = Darwin.close(
                sourceDescriptor
            )
        }
        let scratch =
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: .probe,
                sourceRootDescriptor:
                    sourceDescriptor
            )
        defer {
            scratch.close()
        }
        _ = try scratch.validateBeforeResume()
        let residueDescriptor =
            Darwin.openat(
                scratch.runRootDescriptor,
                "home/Package.resolved",
                O_WRONLY
                    | O_CREAT
                    | O_EXCL
                    | O_CLOEXEC,
                mode_t(0o600)
            )
        XCTAssertGreaterThanOrEqual(
            residueDescriptor,
            3
        )
        if residueDescriptor >= 0 {
            _ = Darwin.close(
                residueDescriptor
            )
        }

        XCTAssertThrowsError(
            try scratch.validateAfterReap(
                outerDeadlineMonotonicNanoseconds:
                    futureDeadline()
            )
        )
        XCTAssertEqual(
            unlinkat(
                scratch.runRootDescriptor,
                "home/Package.resolved",
                0
            ),
            0
        )
        XCTAssertThrowsError(
            try scratch.validateAfterReap(
                outerDeadlineMonotonicNanoseconds:
                    futureDeadline()
            )
        )
    }

    func testHardLinkedRegularFileIsRejected()
        throws
    {
        let sourceDescriptor =
            try openPackageRoot()
        defer {
            _ = Darwin.close(
                sourceDescriptor
            )
        }
        let scratch =
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: .probe,
                sourceRootDescriptor:
                    sourceDescriptor
            )
        defer {
            scratch.close()
        }
        _ = try scratch.validateBeforeResume()
        let originalDescriptor =
            Darwin.openat(
                scratch.runRootDescriptor,
                "work/original",
                O_WRONLY
                    | O_CREAT
                    | O_EXCL
                    | O_CLOEXEC,
                mode_t(0o600)
            )
        XCTAssertGreaterThanOrEqual(
            originalDescriptor,
            3
        )
        if originalDescriptor >= 0 {
            _ = Darwin.close(
                originalDescriptor
            )
        }
        XCTAssertEqual(
            Darwin.linkat(
                scratch.runRootDescriptor,
                "work/original",
                scratch.runRootDescriptor,
                "home/alias",
                0
            ),
            0
        )

        XCTAssertThrowsError(
            try scratch.validateAfterReap(
                outerDeadlineMonotonicNanoseconds:
                    futureDeadline()
            )
        )
    }

    private func futureDeadline()
        -> UInt64
    {
        DispatchTime.now()
            .uptimeNanoseconds
            + 5_000_000_000
    }

    private func makeScratch()
        throws
        -> PrimeNativeNeuralGateSecureScratchNamespace
    {
        let sourceDescriptor =
            try openPackageRoot()
        defer {
            _ = Darwin.close(
                sourceDescriptor
            )
        }
        return
            try PrimeNativeNeuralGateSecureScratchNamespace(
                role: .probe,
                sourceRootDescriptor:
                    sourceDescriptor
            )
    }

    private func createRegularFile(
        scratch:
            PrimeNativeNeuralGateSecureScratchNamespace,
        relativePath: String
    ) throws -> Int32 {
        let descriptor =
            Darwin.openat(
                scratch.runRootDescriptor,
                relativePath,
                O_RDWR
                    | O_CREAT
                    | O_EXCL
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC,
                mode_t(0o600)
            )
        guard descriptor >= 3 else {
            throw PrimeNativeNeuralGateSecureExternalChildCaptureError
                .rejected(
                    "scratch_test_file_open_\(errno)"
                )
        }
        return descriptor
    }

    private func setExtendedAttribute(
        descriptor: Int32,
        name: String,
        value: [UInt8]
    ) throws {
        errno = 0
        let result =
            name.withCString {
                attributeName in
                value.withUnsafeBytes {
                    storage in
                    fsetxattr(
                        descriptor,
                        attributeName,
                        storage.baseAddress,
                        storage.count,
                        0,
                        0
                    )
                }
            }
        guard result == 0 else {
            throw PrimeNativeNeuralGateSecureExternalChildCaptureError
                .rejected(
                    "scratch_test_xattr_set_\(errno)"
                )
        }
    }

    private func addExtendedACL(
        descriptor: Int32
    ) throws {
        var identifier: uuid_t = (
            0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0
        )
        guard primeScratchTestUIDToUUID(
            geteuid(),
            &identifier
        ) == 0
        else {
            throw POSIXError(
                POSIXErrorCode(
                    rawValue: errno
                )!
            )
        }
        let text =
            "!#acl 1\nuser:"
            + "\(UUID(uuid: identifier).uuidString):"
            + "\(NSUserName()):\(geteuid()):allow:read\n"
        guard let accessControlList =
                text.withCString({
                    acl_from_text($0)
                })
        else {
            throw POSIXError(
                POSIXErrorCode(
                    rawValue: errno
                )!
            )
        }
        defer {
            _ = acl_free(
                UnsafeMutableRawPointer(
                    accessControlList
                )
            )
        }
        guard acl_set_fd_np(
            descriptor,
            accessControlList,
            ACL_TYPE_EXTENDED
        ) == 0
        else {
            throw POSIXError(
                POSIXErrorCode(
                    rawValue: errno
                )!
            )
        }
    }

    private func openPackageRoot()
        throws -> Int32
    {
        let root =
            URL(
                fileURLWithPath: #filePath
            )
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .standardizedFileURL
        let descriptor =
            Darwin.open(
                root.path,
                O_RDONLY
                    | O_DIRECTORY
                    | O_NOFOLLOW_ANY
                    | O_CLOEXEC
            )
        guard descriptor >= 3 else {
            throw PrimeNativeNeuralGateSecureExternalChildCaptureError
                .rejected(
                    "scratch_test_source_open_\(errno)"
                )
        }
        return descriptor
    }
}
