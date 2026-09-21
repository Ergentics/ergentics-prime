#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import Foundation

/// The exact maintained MLX Metal library admitted by the initial native
/// calibration lane.
///
/// Runtime capture and receipts bind the canonical SwiftPM resource bundle
/// adjacent to the running executable. The dedicated staging bridge separately
/// validates the exact Xcode donor bundle and transfers only its admitted Metal
/// library into an already-existing canonical SwiftPM bundle. Every tree is
/// descriptor-walked without following symlinks, and publication uses
/// `PrimeArtifactRoot`'s immutable no-replace path before any MLX device use.
public enum PrimePinnedMLXMetallib {
    private enum InfoPlistManifest {
        case canonicalSwiftPMRuntime
        case xcodeDonor

        var expectedByteCount: UInt64 {
            switch self {
            case .canonicalSwiftPMRuntime:
                PrimePinnedMLXMetallib
                    .expectedInfoPlistByteCount
            case .xcodeDonor:
                PrimePinnedMLXMetallib
                    .expectedXcodeDonorInfoPlistByteCount
            }
        }
    }

    public static let mlxSwiftVersion = "0.31.3"
    public static let bundleRelativePath =
        "mlx-swift_Cmlx.bundle"
    public static let sourceBundleRelativePath =
        "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
    public static let infoPlistSourceRelativePath =
        "mlx-swift_Cmlx.bundle/Contents/Info.plist"
    public static let artifactRelativePath =
        sourceBundleRelativePath
    public static let infoPlistArtifactRelativePath =
        infoPlistSourceRelativePath
    public static let expectedByteCount: UInt64 =
        3_817_916
    public static let expectedSHA256 =
        "24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b"
    public static let expectedInfoPlistByteCount:
        UInt64 = 1_120
    public static let expectedInfoPlistSHA256 =
        "62486b35d9253522fe58dba1487d910b3d00d892954558145c553051bd61684d"
    public static let expectedXcodeDonorInfoPlistByteCount:
        UInt64 = 1_130
    public static let expectedXcodeDonorInfoPlistSHA256 =
        "124c82bbfd7fe1ea93aa05b5a50d1e5828759fb268556ed119399212726e6a1e"

    private static let permittedExtendedAttributes:
        Set<String> = [
            "com.apple.provenance",
        ]

    private static let permittedBuildRootExtendedAttributes:
        Set<String> = [
            "com.apple.provenance",
            "com.apple.xcode.CreatedByBuildSystem",
        ]

    public static func captureSibling(
        of runningExecutableURL: URL,
        into artifactRoot: PrimeArtifactRoot
    ) throws -> PrimePinnedMLXMetallibBinding {
        try captureSibling(
            of: runningExecutableURL,
            into: artifactRoot,
            runtimeRole: .calibration
        )
    }

    public static func captureSibling(
        of runningExecutableURL: URL,
        into artifactRoot: PrimeArtifactRoot,
        runtimeRole: PrimeMLXRuntimeRole
    ) throws -> PrimePinnedMLXMetallibBinding {
        guard runningExecutableURL.isFileURL else {
            throw PrimeDurableArtifactError.unsafeArtifact(
                runningExecutableURL.absoluteString
            )
        }
        let executableURL =
            runningExecutableURL.standardizedFileURL
        let executableDirectory =
            executableURL.deletingLastPathComponent()
        let runtimeEnvironmentPolicy =
            try requireSanitizedDynamicLoaderEnvironment()
        let releaseInstrumentationPolicy =
            try PrimeReleaseInstrumentationAdmissionPolicy
                .validateCurrentProcess()
                .declaration
        let rootDescriptor = executableDirectory.path
            .withCString {
                open(
                    $0,
                    O_RDONLY | O_DIRECTORY
                        | O_NOFOLLOW | O_CLOEXEC
                )
            }
        guard rootDescriptor >= 0 else {
            throw posix(
                operation:
                    "open pinned MLX build-product root",
                path: executableDirectory.path
            )
        }
        defer {
            _ = close(rootDescriptor)
        }

        try requireTrustedDirectory(
            rootDescriptor,
            path: executableDirectory.path,
            permittedExtendedAttributes:
                permittedBuildRootExtendedAttributes
        )
        try requireTrustedExecutable(
            named: executableURL.lastPathComponent,
            in: rootDescriptor,
            displayedPath: executableURL.path
        )
        let sourceURL = executableDirectory
            .appendingPathComponent(
                sourceBundleRelativePath
            )
            .standardizedFileURL
        try requireNoLoaderShadowPaths(
            executableDirectory:
                executableDirectory,
            sourceURL: sourceURL,
            includeCurrentProcessContext: true
        )

        let bundleData = try readExactBundle(
            from: rootDescriptor,
            infoPlistManifest:
                .canonicalSwiftPMRuntime
        )
        guard UInt64(bundleData.metallib.count)
                == expectedByteCount,
              PrimeSHA256.hexDigest(
                  of: bundleData.metallib
              )
                == expectedSHA256 else {
            throw PrimeDurableArtifactError.hashMismatch(
                path: sourceBundleRelativePath,
                expected: expectedSHA256,
                actual:
                    PrimeSHA256.hexDigest(
                        of: bundleData.metallib
                    )
            )
        }
        guard UInt64(bundleData.infoPlist.count)
                == expectedInfoPlistByteCount,
              PrimeSHA256.hexDigest(
                  of: bundleData.infoPlist
              ) == expectedInfoPlistSHA256 else {
            throw PrimeDurableArtifactError.hashMismatch(
                path: infoPlistSourceRelativePath,
                expected: expectedInfoPlistSHA256,
                actual: PrimeSHA256.hexDigest(
                    of: bundleData.infoPlist
                )
            )
        }
        try artifactRoot.ensurePrivateDirectory(
            at: bundleRelativePath
        )
        try artifactRoot.ensurePrivateDirectory(
            at: "\(bundleRelativePath)/Contents"
        )
        try artifactRoot.ensurePrivateDirectory(
            at:
                "\(bundleRelativePath)/Contents/Resources"
        )
        let artifact = try artifactRoot.publish(
            bundleData.metallib,
            at: artifactRelativePath,
            purpose: .immutableData
        )
        let infoPlistArtifact =
            try artifactRoot.publish(
                bundleData.infoPlist,
                at: infoPlistArtifactRelativePath,
                purpose: .immutableData
            )
        _ = try artifactRoot.verify(artifact)
        _ = try artifactRoot.verify(
            infoPlistArtifact
        )
        let binding = PrimePinnedMLXMetallibBinding(
            mlxSwiftVersion: mlxSwiftVersion,
            sourceBundleRelativePath:
                sourceBundleRelativePath,
            artifact: artifact,
            infoPlistSourceRelativePath:
                infoPlistSourceRelativePath,
            infoPlistArtifact:
                infoPlistArtifact,
            runtimeEnvironmentPolicy:
                runtimeEnvironmentPolicy,
            runtimeImageLayout:
                PrimeMLXRuntimeImageLayout
                    .declaration(
                        for: runtimeRole
                    ),
            releaseInstrumentationPolicy:
                releaseInstrumentationPolicy
        )
        try binding.validateDeclaration()
        try PrimeMLXRuntimeImageLayout.require(
            binding.runtimeImageLayout,
            for: runtimeRole
        )
        return binding
    }

    /// Verifies the independently Xcode-built private-package resource and
    /// installs only its exact Metal library into the canonical SwiftPM
    /// runtime bundle beside `destinationExecutableURL`.
    ///
    /// Xcode derives the donor bundle identifier from the private repository
    /// identity, while SwiftPM derives the runtime identifier from the
    /// package name. Both manifests are exact, role-specific inputs. The
    /// donor manifest is never substituted for the runtime manifest.
    public static func stageExactXcodeMetallib(
        from xcodeExecutableURL: URL,
        beside destinationExecutableURL: URL,
        runtimeRole: PrimeMLXRuntimeRole
    ) throws -> (
        binding: PrimePinnedMLXMetallibBinding,
        destinationMetallibInitiallyAbsent: Bool
    ) {
        guard xcodeExecutableURL.isFileURL,
              destinationExecutableURL.isFileURL else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(
                    "MLX staging hosts must be file URLs"
                )
        }
        let sourceExecutable =
            xcodeExecutableURL.standardizedFileURL
        let destinationExecutable =
            destinationExecutableURL.standardizedFileURL
        guard sourceExecutable
                .resolvingSymlinksInPath()
                .standardizedFileURL
                == sourceExecutable,
              destinationExecutable
                .resolvingSymlinksInPath()
                .standardizedFileURL
                == destinationExecutable else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(
                    "MLX staging hosts must not traverse symlinks"
                )
        }
        guard sourceExecutable
                != destinationExecutable else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "Xcode donor and SwiftPM runtime hosts must be distinct"
                )
        }
        let expectedDestinationName =
            PrimeMLXRuntimeImageLayout
            .destinationHostExecutableName(
                for: runtimeRole
            )
        guard destinationExecutable
                .lastPathComponent
                == expectedDestinationName else {
            throw PrimeDurableArtifactError
                .invalidSemantics(
                    "SwiftPM runtime host must be \(expectedDestinationName) for \(runtimeRole.rawValue)"
                )
        }

        let runtimeEnvironmentPolicy =
            try requireSanitizedDynamicLoaderEnvironment()
        let releaseInstrumentationPolicy =
            try PrimeReleaseInstrumentationAdmissionPolicy
                .validateCurrentProcess()
                .declaration

        let sourceDirectory =
            sourceExecutable.deletingLastPathComponent()
        let sourceDescriptor = sourceDirectory.path
            .withCString {
                open(
                    $0,
                    O_RDONLY | O_DIRECTORY
                        | O_NOFOLLOW | O_CLOEXEC
                )
            }
        guard sourceDescriptor >= 0 else {
            throw posix(
                operation:
                    "open Xcode MLX donor root",
                path: sourceDirectory.path
            )
        }
        defer {
            _ = close(sourceDescriptor)
        }
        try requireTrustedDirectory(
            sourceDescriptor,
            path: sourceDirectory.path,
            permittedExtendedAttributes:
                permittedBuildRootExtendedAttributes
        )
        try requireTrustedExecutable(
            named: sourceExecutable.lastPathComponent,
            in: sourceDescriptor,
            displayedPath: sourceExecutable.path
        )
        try requireNoLoaderShadowPaths(
            executableDirectory: sourceDirectory,
            sourceURL:
                sourceDirectory
                .appendingPathComponent(
                    sourceBundleRelativePath
                )
                .standardizedFileURL,
            includeCurrentProcessContext: false
        )
        let donor = try readExactBundle(
            from: sourceDescriptor,
            infoPlistManifest: .xcodeDonor
        )
        let donorMetallibSHA256 =
            PrimeSHA256.hexDigest(
                of: donor.metallib
            )
        guard UInt64(donor.metallib.count)
                == expectedByteCount,
              donorMetallibSHA256
                == expectedSHA256 else {
            throw PrimeDurableArtifactError
                .hashMismatch(
                    path: sourceBundleRelativePath,
                    expected: expectedSHA256,
                    actual: donorMetallibSHA256
                )
        }
        let donorInfoPlistSHA256 =
            PrimeSHA256.hexDigest(
                of: donor.infoPlist
            )
        guard UInt64(donor.infoPlist.count)
                == expectedXcodeDonorInfoPlistByteCount,
              donorInfoPlistSHA256
                == expectedXcodeDonorInfoPlistSHA256 else {
            throw PrimeDurableArtifactError
                .hashMismatch(
                    path: infoPlistSourceRelativePath,
                    expected:
                        expectedXcodeDonorInfoPlistSHA256,
                    actual: donorInfoPlistSHA256
                )
        }

        let destinationDirectory =
            destinationExecutable
            .deletingLastPathComponent()
        let destinationDescriptor =
            destinationDirectory.path.withCString {
                open(
                    $0,
                    O_RDONLY | O_DIRECTORY
                        | O_NOFOLLOW | O_CLOEXEC
                )
            }
        guard destinationDescriptor >= 0 else {
            throw posix(
                operation:
                    "open SwiftPM MLX runtime root",
                path: destinationDirectory.path
            )
        }
        defer {
            _ = close(destinationDescriptor)
        }
        try requireTrustedDirectory(
            destinationDescriptor,
            path: destinationDirectory.path,
            permittedExtendedAttributes:
                permittedBuildRootExtendedAttributes
        )
        try requireTrustedExecutable(
            named:
                destinationExecutable
                .lastPathComponent,
            in: destinationDescriptor,
            displayedPath:
                destinationExecutable.path
        )
        try requireNoLoaderShadowPaths(
            executableDirectory:
                destinationDirectory,
            sourceURL:
                destinationDirectory
                .appendingPathComponent(
                    sourceBundleRelativePath
                )
                .standardizedFileURL,
            includeCurrentProcessContext: false
        )
        let destinationBefore =
            try readCanonicalRuntimeBundleForStaging(
                from: destinationDescriptor
            )
        let destinationInfoPlistSHA256 =
            PrimeSHA256.hexDigest(
                of: destinationBefore.infoPlist
            )
        guard UInt64(
                destinationBefore.infoPlist.count
              ) == expectedInfoPlistByteCount,
              destinationInfoPlistSHA256
                == expectedInfoPlistSHA256 else {
            throw PrimeDurableArtifactError
                .hashMismatch(
                    path:
                        infoPlistSourceRelativePath,
                    expected:
                        expectedInfoPlistSHA256,
                    actual:
                        destinationInfoPlistSHA256
                )
        }

        let destinationMetallibInitiallyAbsent: Bool
        if let existing =
            destinationBefore.metallib
        {
            destinationMetallibInitiallyAbsent =
                false
            let existingSHA256 =
                PrimeSHA256.hexDigest(of: existing)
            guard UInt64(existing.count)
                    == expectedByteCount,
                  existingSHA256
                    == expectedSHA256 else {
                throw PrimeDurableArtifactError
                    .hashMismatch(
                        path:
                            sourceBundleRelativePath,
                        expected: expectedSHA256,
                        actual: existingSHA256
                    )
            }
        } else {
            let destinationRoot =
                try PrimeArtifactRoot(
                    directoryURL:
                        destinationDirectory
                )
            let published =
                try destinationRoot.publish(
                    donor.metallib,
                    at: artifactRelativePath,
                    purpose: .immutableData
                )
            guard published.sha256
                    == expectedSHA256,
                  published.byteCount
                    == expectedByteCount else {
                throw PrimeDurableArtifactError
                    .invalidSemantics(
                        "staged MLX metallib binding diverges from the frozen donor"
                )
            }
            destinationMetallibInitiallyAbsent =
                true
        }

        let donorAfterPublication =
            try readExactBundle(
                from: sourceDescriptor,
                infoPlistManifest: .xcodeDonor
            )
        guard donorAfterPublication.infoPlist
                == donor.infoPlist,
              donorAfterPublication.metallib
                == donor.metallib else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(
                    "Xcode MLX donor changed during staging"
                )
        }

        let binding =
            PrimePinnedMLXMetallibBinding(
                mlxSwiftVersion:
                    mlxSwiftVersion,
                sourceBundleRelativePath:
                    sourceBundleRelativePath,
                artifact:
                    PrimeArtifactBinding(
                        relativePath:
                            artifactRelativePath,
                        sha256:
                            expectedSHA256,
                        byteCount:
                            expectedByteCount,
                        purpose:
                            .immutableData
                    ),
                infoPlistSourceRelativePath:
                    infoPlistSourceRelativePath,
                infoPlistArtifact:
                    PrimeArtifactBinding(
                        relativePath:
                            infoPlistArtifactRelativePath,
                        sha256:
                            expectedInfoPlistSHA256,
                        byteCount:
                            expectedInfoPlistByteCount,
                        purpose:
                            .immutableData
                    ),
                runtimeEnvironmentPolicy:
                    runtimeEnvironmentPolicy,
                runtimeImageLayout:
                    PrimeMLXRuntimeImageLayout
                    .declaration(
                        for: runtimeRole
                    ),
                releaseInstrumentationPolicy:
                    releaseInstrumentationPolicy
            )
        try binding.validateDeclaration()
        try reverifyStagedRuntimeImage(
            of: destinationExecutable,
            matches: binding,
            runtimeRole: runtimeRole
        )
        return (
            binding,
            destinationMetallibInitiallyAbsent
        )
    }

    /// Revalidates the exact sibling bytes after MLX execution. This closes
    /// the capture-to-load interval in the receipt contract: a worker cannot
    /// publish either GROUNDED or post-device ABSTAIN evidence if the loader
    /// source changed while the mechanics attempt was active.
    public static func reverifySibling(
        of runningExecutableURL: URL,
        matches binding:
            PrimePinnedMLXMetallibBinding
    ) throws {
        try reverifySibling(
            of: runningExecutableURL,
            matches: binding,
            runtimeRole: .calibration
        )
    }

    public static func reverifySibling(
        of runningExecutableURL: URL,
        matches binding:
            PrimePinnedMLXMetallibBinding,
        runtimeRole: PrimeMLXRuntimeRole
    ) throws {
        let executableURL =
            runningExecutableURL
            .resolvingSymlinksInPath()
            .standardizedFileURL
        guard try resolvesToCurrentExecutable(
            executableURL
        ) else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "current-process MLX reverification requires the actual running executable"
            )
        }
        try reverifyRuntimeImage(
            executableURL,
            matches: binding,
            runtimeRole: runtimeRole,
            includeCurrentProcessContext: true
        )
    }

    /// Revalidates an exact staged worker image from its supervising process.
    ///
    /// Loaded bundles, frameworks, the current working directory, runtime
    /// environment, and instrumentation belong to the supervisor process and
    /// cannot attest the exited worker's loader context. The worker already
    /// verifies those live-process conditions before publishing its candidate.
    /// This independent pass therefore validates only trusted target
    /// executable metadata, its colocated loader paths, and the exact immutable
    /// bundle tree. The caller must separately verify the executable's bound
    /// bytes before invoking this method.
    public static func reverifyStagedRuntimeImage(
        of stagedExecutableURL: URL,
        matches binding:
            PrimePinnedMLXMetallibBinding
    ) throws {
        try reverifyStagedRuntimeImage(
            of: stagedExecutableURL,
            matches: binding,
            runtimeRole: .calibration
        )
    }

    public static func reverifyStagedRuntimeImage(
        of stagedExecutableURL: URL,
        matches binding:
            PrimePinnedMLXMetallibBinding,
        runtimeRole: PrimeMLXRuntimeRole
    ) throws {
        let executableURL =
            stagedExecutableURL
            .resolvingSymlinksInPath()
            .standardizedFileURL
        guard try !resolvesToCurrentExecutable(
            executableURL
        ) else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "staged-image MLX reverification cannot replace current-process loader admission"
            )
        }
        try reverifyRuntimeImage(
            executableURL,
            matches: binding,
            runtimeRole: runtimeRole,
            includeCurrentProcessContext: false
        )
    }

    private static func reverifyRuntimeImage(
        _ executableURL: URL,
        matches binding:
            PrimePinnedMLXMetallibBinding,
        runtimeRole: PrimeMLXRuntimeRole,
        includeCurrentProcessContext: Bool
    ) throws {
        try binding.validateDeclaration()
        try PrimeMLXRuntimeImageLayout.require(
            binding.runtimeImageLayout,
            for: runtimeRole
        )
        let executableDirectory =
            executableURL.deletingLastPathComponent()
        if includeCurrentProcessContext {
            _ = try requireSanitizedDynamicLoaderEnvironment()
            let releaseInstrumentationPolicy =
                try PrimeReleaseInstrumentationAdmissionPolicy
                    .validateCurrentProcess()
                    .declaration
            guard releaseInstrumentationPolicy
                    == binding
                        .releaseInstrumentationPolicy else {
                throw PrimeDurableArtifactError.invalidSemantics(
                    "the current executable diverges from the bound Release instrumentation admission policy"
                )
            }
        }
        try requireNoLoaderShadowPaths(
            executableDirectory:
                executableDirectory,
            sourceURL:
                executableDirectory
                    .appendingPathComponent(
                        sourceBundleRelativePath
                    )
                    .standardizedFileURL,
            includeCurrentProcessContext:
                includeCurrentProcessContext
        )

        let rootDescriptor = executableDirectory.path
            .withCString {
                open(
                    $0,
                    O_RDONLY | O_DIRECTORY
                        | O_NOFOLLOW | O_CLOEXEC
                )
            }
        guard rootDescriptor >= 0 else {
            throw posix(
                operation:
                    "reopen pinned MLX build-product root",
                path: executableDirectory.path
            )
        }
        defer {
            _ = close(rootDescriptor)
        }
        try requireTrustedDirectory(
            rootDescriptor,
            path: executableDirectory.path,
            permittedExtendedAttributes:
                permittedBuildRootExtendedAttributes
        )
        try requireTrustedExecutable(
            named: executableURL.lastPathComponent,
            in: rootDescriptor,
            displayedPath: executableURL.path
        )

        let bundleData = try readExactBundle(
            from: rootDescriptor,
            infoPlistManifest:
                .canonicalSwiftPMRuntime
        )
        let observedSHA256 = PrimeSHA256
            .hexDigest(of: bundleData.metallib)
        guard UInt64(bundleData.metallib.count)
                == binding.artifact.byteCount,
              observedSHA256
                == binding.artifact.sha256 else {
            throw PrimeDurableArtifactError.hashMismatch(
                path: sourceBundleRelativePath,
                expected: binding.artifact.sha256,
                actual: observedSHA256
            )
        }
        let observedInfoPlistSHA256 =
            PrimeSHA256.hexDigest(
                of: bundleData.infoPlist
            )
        guard UInt64(bundleData.infoPlist.count)
                == binding
                    .infoPlistArtifact.byteCount,
              observedInfoPlistSHA256
                == binding
                    .infoPlistArtifact.sha256 else {
            throw PrimeDurableArtifactError.hashMismatch(
                path: infoPlistSourceRelativePath,
                expected:
                    binding.infoPlistArtifact.sha256,
                actual:
                    observedInfoPlistSHA256
            )
        }
    }

    private static func readExactBundle(
        from buildProductRoot: Int32,
        infoPlistManifest: InfoPlistManifest
    ) throws -> (
        infoPlist: Data,
        metallib: Data
    ) {
        let bundle = try openTrustedDirectory(
            named: bundleRelativePath,
            in: buildProductRoot,
            displayedPath: bundleRelativePath
        )
        defer {
            _ = close(bundle)
        }
        try requireExactDirectoryEntries(
            bundle,
            expected: ["Contents"],
            path: bundleRelativePath
        )

        let contents = try openTrustedDirectory(
            named: "Contents",
            in: bundle,
            displayedPath:
                "\(bundleRelativePath)/Contents"
        )
        defer {
            _ = close(contents)
        }
        try requireExactDirectoryEntries(
            contents,
            expected: ["Info.plist", "Resources"],
            path: "\(bundleRelativePath)/Contents"
        )
        let infoPlist = try readTrustedImmutableFile(
            named: "Info.plist",
            in: contents,
            displayedPath:
                infoPlistSourceRelativePath,
            expectedByteCount:
                infoPlistManifest
                .expectedByteCount
        )

        let resources = try openTrustedDirectory(
            named: "Resources",
            in: contents,
            displayedPath:
                "\(bundleRelativePath)/Contents/Resources"
        )
        defer {
            _ = close(resources)
        }
        try requireExactDirectoryEntries(
            resources,
            expected: ["default.metallib"],
            path:
                "\(bundleRelativePath)/Contents/Resources"
        )
        let metallib = try readTrustedImmutableFile(
            named: "default.metallib",
            in: resources,
            displayedPath:
                sourceBundleRelativePath,
            expectedByteCount:
                expectedByteCount
        )
        try requireExactDirectoryEntries(
            resources,
            expected: ["default.metallib"],
            path:
                "\(bundleRelativePath)/Contents/Resources"
        )
        try requireExactDirectoryEntries(
            contents,
            expected: ["Info.plist", "Resources"],
            path: "\(bundleRelativePath)/Contents"
        )
        try requireExactDirectoryEntries(
            bundle,
            expected: ["Contents"],
            path: bundleRelativePath
        )
        return (infoPlist, metallib)
    }

    private static func readCanonicalRuntimeBundleForStaging(
        from buildProductRoot: Int32
    ) throws -> (
        infoPlist: Data,
        metallib: Data?
    ) {
        let bundle = try openTrustedDirectory(
            named: bundleRelativePath,
            in: buildProductRoot,
            displayedPath: bundleRelativePath
        )
        defer {
            _ = close(bundle)
        }
        try requireExactDirectoryEntries(
            bundle,
            expected: ["Contents"],
            path: bundleRelativePath
        )

        let contents = try openTrustedDirectory(
            named: "Contents",
            in: bundle,
            displayedPath:
                "\(bundleRelativePath)/Contents"
        )
        defer {
            _ = close(contents)
        }
        try requireExactDirectoryEntries(
            contents,
            expected: ["Info.plist", "Resources"],
            path: "\(bundleRelativePath)/Contents"
        )
        let infoPlist = try readTrustedImmutableFile(
            named: "Info.plist",
            in: contents,
            displayedPath:
                infoPlistSourceRelativePath,
            expectedByteCount:
                expectedInfoPlistByteCount
        )

        let resources = try openTrustedDirectory(
            named: "Resources",
            in: contents,
            displayedPath:
                "\(bundleRelativePath)/Contents/Resources"
        )
        defer {
            _ = close(resources)
        }
        var metadata = stat()
        let status = "default.metallib"
            .withCString {
                fstatat(
                    resources,
                    $0,
                    &metadata,
                    AT_SYMLINK_NOFOLLOW
                )
            }
        let statusError = errno
        let metallib: Data?
        if status == 0 {
            try requireExactDirectoryEntries(
                resources,
                expected: ["default.metallib"],
                path:
                    "\(bundleRelativePath)/Contents/Resources"
            )
            metallib =
                try readTrustedImmutableFile(
                    named: "default.metallib",
                    in: resources,
                    displayedPath:
                        sourceBundleRelativePath,
                    expectedByteCount:
                        expectedByteCount
                )
        } else {
            guard statusError == ENOENT else {
                throw posix(
                    operation:
                        "inspect canonical SwiftPM metallib",
                    path:
                        sourceBundleRelativePath
                )
            }
            try requireExactDirectoryEntries(
                resources,
                expected: [],
                path:
                    "\(bundleRelativePath)/Contents/Resources"
            )
            metallib = nil
        }
        try requireExactDirectoryEntries(
            contents,
            expected: ["Info.plist", "Resources"],
            path: "\(bundleRelativePath)/Contents"
        )
        try requireExactDirectoryEntries(
            bundle,
            expected: ["Contents"],
            path: bundleRelativePath
        )
        return (infoPlist, metallib)
    }

    private static func openTrustedDirectory(
        named name: String,
        in parent: Int32,
        displayedPath: String
    ) throws -> Int32 {
        let descriptor = name.withCString {
            openat(
                parent,
                $0,
                O_RDONLY | O_DIRECTORY
                    | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard descriptor >= 0 else {
            throw posix(
                operation:
                    "open pinned MLX bundle directory",
                path: displayedPath
            )
        }
        do {
            try requireTrustedDirectory(
                descriptor,
                path: displayedPath,
                permittedExtendedAttributes:
                    permittedExtendedAttributes
            )
        } catch {
            _ = close(descriptor)
            throw error
        }
        return descriptor
    }

    private static func requireExactDirectoryEntries(
        _ descriptor: Int32,
        expected: Set<String>,
        path: String
    ) throws {
        let duplicate = dup(descriptor)
        guard duplicate >= 0,
              lseek(duplicate, 0, SEEK_SET) >= 0,
              let directory = fdopendir(duplicate) else {
            if duplicate >= 0 {
                _ = close(duplicate)
            }
            throw posix(
                operation:
                    "enumerate pinned MLX bundle directory",
                path: path
            )
        }
        defer {
            _ = closedir(directory)
        }
        var observed = Set<String>()
        errno = 0
        while let entry = readdir(directory) {
            let name = withUnsafePointer(
                to: entry.pointee.d_name
            ) {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MAXNAMLEN) + 1
                ) {
                    String(cString: $0)
                }
            }
            if name != ".", name != ".." {
                guard observed.insert(name).inserted else {
                    throw PrimeDurableArtifactError
                        .unsafeArtifact(path)
                }
            }
            errno = 0
        }
        guard errno == 0,
              observed == expected else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "pinned MLX bundle entries diverge at \(path): expected=\(expected.sorted()) observed=\(observed.sorted()) errno=\(errno)"
            )
        }
    }

    private static func requireTrustedExecutable(
        named name: String,
        in parent: Int32,
        displayedPath: String
    ) throws {
        guard !name.isEmpty,
              name != ".",
              name != "..",
              !name.utf8.contains(0) else {
            throw PrimeDurableArtifactError.unsafeArtifact(
                displayedPath
            )
        }
        let descriptor = name.withCString {
            openat(
                parent,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard descriptor >= 0 else {
            throw posix(
                operation:
                    "open running executable for metallib binding",
                path: displayedPath
            )
        }
        defer {
            _ = close(descriptor)
        }

        var opened = stat()
        var bound = stat()
        let boundStatus = name.withCString {
            fstatat(
                parent,
                $0,
                &bound,
                AT_SYMLINK_NOFOLLOW
            )
        }
        guard fstat(descriptor, &opened) == 0,
              boundStatus == 0,
              opened.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              bound.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              opened.st_uid == geteuid(),
              bound.st_uid == geteuid(),
              opened.st_nlink == 1,
              bound.st_nlink == 1,
              opened.st_dev == bound.st_dev,
              opened.st_ino == bound.st_ino,
              opened.st_mode & mode_t(0o022) == 0,
              bound.st_mode & mode_t(0o022) == 0,
              opened.st_mode & mode_t(0o7000) == 0,
              bound.st_mode & mode_t(0o7000) == 0,
              opened.st_mode & mode_t(0o100) != 0,
              bound.st_mode & mode_t(0o100) != 0 else {
            throw PrimeDurableArtifactError.unsafeArtifact(
                displayedPath
            )
        }
        try requireTrustedDescriptorMetadata(
            descriptor,
            path: displayedPath,
            permittedExtendedAttributes:
                permittedExtendedAttributes
        )
    }

    private static func readTrustedImmutableFile(
        named name: String,
        in parent: Int32,
        displayedPath: String,
        expectedByteCount: UInt64
    ) throws -> Data {
        let descriptor = name.withCString {
            openat(
                parent,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard descriptor >= 0 else {
            throw posix(
                operation:
                    "open pinned MLX bundle file",
                path: displayedPath
            )
        }
        defer {
            _ = close(descriptor)
        }

        let before = try requireTrustedImmutableFile(
            descriptor,
            parent: parent,
            leaf: name,
            displayedPath: displayedPath,
            expectedByteCount:
                expectedByteCount
        )
        var data = Data()
        data.reserveCapacity(Int(before.st_size))
        var buffer = [UInt8](
            repeating: 0,
            count: 64 * 1024
        )
        while true {
            let count = buffer.withUnsafeMutableBytes {
                read(
                    descriptor,
                    $0.baseAddress,
                    $0.count
                )
            }
            if count < 0, errno == EINTR {
                continue
            }
            guard count >= 0 else {
                throw posix(
                    operation:
                        "read pinned MLX bundle file",
                    path: displayedPath
                )
            }
            if count == 0 {
                break
            }
            data.append(contentsOf: buffer[0 ..< count])
            guard UInt64(data.count)
                    <= expectedByteCount else {
                throw PrimeDurableArtifactError
                    .artifactTooLarge(
                        displayedPath
                    )
            }
        }
        let after = try requireTrustedImmutableFile(
            descriptor,
            parent: parent,
            leaf: name,
            displayedPath: displayedPath,
            expectedByteCount:
                expectedByteCount
        )
        guard before.st_dev == after.st_dev,
              before.st_ino == after.st_ino,
              before.st_size == after.st_size,
              before.st_uid == after.st_uid,
              before.st_nlink == after.st_nlink,
              before.st_mode == after.st_mode,
              data.count == Int(after.st_size) else {
            throw PrimeDurableArtifactError.unsafeArtifact(
                displayedPath
            )
        }
        return data
    }

    private static func requireTrustedImmutableFile(
        _ descriptor: Int32,
        parent: Int32,
        leaf: String,
        displayedPath: String,
        expectedByteCount: UInt64
    ) throws -> stat {
        var opened = stat()
        var bound = stat()
        let boundStatus = leaf.withCString {
            fstatat(
                parent,
                $0,
                &bound,
                AT_SYMLINK_NOFOLLOW
            )
        }
        guard fstat(descriptor, &opened) == 0,
              boundStatus == 0,
              opened.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              bound.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFREG),
              opened.st_uid == geteuid(),
              bound.st_uid == geteuid(),
              opened.st_nlink == 1,
              bound.st_nlink == 1,
              opened.st_dev == bound.st_dev,
              opened.st_ino == bound.st_ino,
              opened.st_size > 0,
              UInt64(opened.st_size)
                == expectedByteCount,
              opened.st_mode & mode_t(0o022) == 0,
              bound.st_mode & mode_t(0o022) == 0,
              opened.st_mode & mode_t(0o7000) == 0,
              bound.st_mode & mode_t(0o7000) == 0,
              opened.st_mode & mode_t(0o111) == 0,
              bound.st_mode & mode_t(0o111) == 0,
              opened.st_mode & mode_t(0o400) != 0,
              bound.st_mode & mode_t(0o400) != 0 else {
            throw PrimeDurableArtifactError.unsafeArtifact(
                displayedPath
            )
        }
        try requireTrustedDescriptorMetadata(
            descriptor,
            path: displayedPath,
            permittedExtendedAttributes:
                permittedExtendedAttributes
        )
        return opened
    }

    private static func requireSanitizedDynamicLoaderEnvironment()
        throws
        -> PrimeMLXRuntimeEnvironmentPolicyDeclaration
    {
        try PrimeMLXRuntimeEnvironmentPolicy
            .validateCurrentProcess()
    }

    private static func requireNoLoaderShadowPaths(
        executableDirectory: URL,
        sourceURL: URL,
        includeCurrentProcessContext: Bool
    ) throws {
        let executableCandidates = [
            "mlx.metallib",
            "Resources/mlx.metallib",
            "Resources/default.metallib",
        ]
        for relativePath in executableCandidates {
            let candidate = executableDirectory
                .appendingPathComponent(relativePath)
                .standardizedFileURL
            if candidate == sourceURL {
                continue
            }
            try requireAbsentLoaderCandidate(
                candidate,
                displayedPath: candidate.path
            )
        }

        guard includeCurrentProcessContext else {
            return
        }

        var bundleCandidates = [URL]()
        if let mainBundleURL = Bundle.main.bundleURL
            as URL? {
            bundleCandidates.append(
                mainBundleURL
                    .appendingPathComponent(
                        sourceBundleRelativePath
                    )
            )
        }
        for bundle in Bundle.allBundles {
            if let resourceURL = bundle.resourceURL {
                bundleCandidates.append(
                    resourceURL
                        .appendingPathComponent(
                            sourceBundleRelativePath
                        )
                )
            }
        }
        for framework in Bundle.allFrameworks
        where framework.bundleIdentifier
            == "mlx-swift_Cmlx"
            || framework.bundleIdentifier
                == "com.apple.mlx.Cmlx"
        {
            if let resourceURL =
                    framework.resourceURL {
                bundleCandidates.append(
                    resourceURL
                        .appendingPathComponent(
                            "default.metallib"
                        )
                )
            }
        }
        var observedBundleCandidates = Set<String>()
        for rawCandidate in bundleCandidates {
            let candidate =
                rawCandidate.standardizedFileURL
            guard observedBundleCandidates
                    .insert(candidate.path)
                    .inserted else {
                continue
            }
            if candidate == sourceURL {
                continue
            }
            try requireAbsentLoaderCandidate(
                candidate,
                displayedPath: candidate.path
            )
        }

        let workingDirectory = URL(
            fileURLWithPath:
                FileManager.default
                    .currentDirectoryPath,
            isDirectory: true
        ).standardizedFileURL
        let defaultCandidate = workingDirectory
            .appendingPathComponent(
                "default.metallib"
            )
            .standardizedFileURL
        if defaultCandidate != sourceURL {
            try requireAbsentLoaderCandidate(
                defaultCandidate,
                displayedPath:
                    defaultCandidate.path
            )
        }
    }

    private static func resolvesToCurrentExecutable(
        _ candidate: URL
    ) throws -> Bool {
        var requiredSize: UInt32 = 0
        _ = _NSGetExecutablePath(nil, &requiredSize)
        guard requiredSize > 1 else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "could not resolve the current executable for MLX loader admission"
            )
        }
        var buffer = [CChar](
            repeating: 0,
            count: Int(requiredSize)
        )
        guard _NSGetExecutablePath(
            &buffer,
            &requiredSize
        ) == 0 else {
            throw PrimeDurableArtifactError.invalidSemantics(
                "could not resolve the current executable for MLX loader admission"
            )
        }
        let current = URL(
            fileURLWithPath: String(cString: buffer)
        ).resolvingSymlinksInPath()
            .standardizedFileURL
        return candidate.resolvingSymlinksInPath()
            .standardizedFileURL == current
    }

    private static func requireAbsentLoaderCandidate(
        _ candidate: URL,
        displayedPath: String
    ) throws {
        let parentURL =
            candidate.deletingLastPathComponent()
        var parentMetadata = stat()
        if lstat(parentURL.path, &parentMetadata) != 0 {
            if errno == ENOENT {
                return
            }
            throw posix(
                operation:
                    "inspect MLX loader shadow parent",
                path: displayedPath
            )
        }
        guard parentMetadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR) else {
            throw PrimeDurableArtifactError
                .conflictingArtifact(displayedPath)
        }
        let parent = parentURL.path.withCString {
            open(
                $0,
                O_RDONLY | O_DIRECTORY
                    | O_NOFOLLOW | O_CLOEXEC
            )
        }
        guard parent >= 0 else {
            throw PrimeDurableArtifactError
                .conflictingArtifact(displayedPath)
        }
        defer {
            _ = close(parent)
        }
        var metadata = stat()
        let status = candidate.lastPathComponent
            .withCString {
                fstatat(
                    parent,
                    $0,
                    &metadata,
                    AT_SYMLINK_NOFOLLOW
                )
            }
        if status != 0, errno == ENOENT {
            return
        }
        guard status != 0 else {
            throw PrimeDurableArtifactError
                .conflictingArtifact(displayedPath)
        }
        throw posix(
            operation: "inspect MLX loader shadow",
            path: displayedPath
        )
    }

    private static func requireTrustedDirectory(
        _ descriptor: Int32,
        path: String,
        permittedExtendedAttributes: Set<String>
    ) throws {
        var metadata = stat()
        guard fstat(descriptor, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT)
                == mode_t(S_IFDIR),
              metadata.st_uid == geteuid(),
              metadata.st_mode & mode_t(0o022) == 0,
              metadata.st_mode & mode_t(0o7000) == 0 else {
            throw PrimeDurableArtifactError
                .untrustedDirectory(path)
        }
        try requireTrustedDescriptorMetadata(
            descriptor,
            path: path,
            permittedExtendedAttributes:
                permittedExtendedAttributes
        )
    }

    private static func requireTrustedDescriptorMetadata(
        _ descriptor: Int32,
        path: String,
        permittedExtendedAttributes: Set<String>
    ) throws {
        #if canImport(Darwin)
        errno = 0
        if let accessControlList = acl_get_fd_np(
            descriptor,
            ACL_TYPE_EXTENDED
        ) {
            acl_free(
                UnsafeMutableRawPointer(
                    accessControlList
                )
            )
            // Darwin returns 0 when acl_get_entry successfully finds an
            // entry. acl_get_fd_np returns nil+ENOENT for no extended ACL,
            // so any nonnil ACL object is rejected fail-closed.
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        } else if errno != ENOENT {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }

        errno = 0
        let requiredSize = flistxattr(
            descriptor,
            nil,
            0,
            0
        )
        guard requiredSize >= 0,
              requiredSize <= 65_536 else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }
        guard requiredSize > 0 else {
            return
        }
        var names = [CChar](
            repeating: 0,
            count: requiredSize
        )
        let actualSize = names.withUnsafeMutableBufferPointer {
            flistxattr(
                descriptor,
                $0.baseAddress,
                $0.count,
                0
            )
        }
        guard actualSize == requiredSize else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }

        let bytes = names.prefix(actualSize).map {
            UInt8(bitPattern: $0)
        }
        var start = bytes.startIndex
        var observedNames = Set<String>()
        for index in bytes.indices where bytes[index] == 0 {
            guard start < index,
                  let name = String(
                      bytes: bytes[start ..< index],
                      encoding: .utf8
                  ) else {
                throw PrimeDurableArtifactError
                    .unsafeArtifact(path)
            }
            observedNames.insert(name)
            start = bytes.index(after: index)
        }
        guard start == bytes.endIndex,
              observedNames.isSubset(
                  of: permittedExtendedAttributes
              ) else {
            throw PrimeDurableArtifactError
                .unsafeArtifact(path)
        }
        #else
        throw PrimeDurableArtifactError.unsupportedPlatform(
            "pinned MLX metallib ACL/xattr validation requires Darwin"
        )
        #endif
    }

    private static func posix(
        operation: String,
        path: String
    ) -> PrimeDurableArtifactError {
        .posix(
            operation: operation,
            path: path,
            code: errno
        )
    }
}
