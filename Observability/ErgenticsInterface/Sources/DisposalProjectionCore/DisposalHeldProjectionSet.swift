import Darwin
import DisposalProjectionPrimitivesC
import Foundation

final class DisposalHeldProjectionSet {
    let rootDescriptor: Int32
    let evidence: Data
    let metrics: Data
    let graph: Data
    let seal: Data

    fileprivate struct HeldLeaf {
        let descriptor: Int32
        let admittedState: stat
        let bytes: Data
        let sha256: String
    }

    private static let leafSpecifications: [(leaf: String, maximumBytes: Int)] = [
        (DisposalProjectionSetV1.evidenceLeaf, 128 * 1_024 * 1_024),
        (DisposalProjectionSetV1.metricsLeaf, 128 * 1_024 * 1_024),
        (DisposalProjectionSetV1.graphLeaf, 128 * 1_024 * 1_024),
        (DisposalProjectionSetV1.sealLeaf, 1 * 1_024 * 1_024),
    ]

    private let rootPath: String
    private let parentPath: String
    private let rootLeaf: String
    private let expectedSealSHA256: String
    private let parentDescriptor: Int32
    private let admittedParentState: stat
    private let admittedRootState: stat
    private let heldLeaves: [String: HeldLeaf]

    init(rootPath: String, expectedSealSHA256: String) throws {
        try disposalRequireProjection(
            disposalIsLowerHex(expectedSealSHA256, count: 64),
            "DISPOSAL_READER_EXPECTED_SEAL_SHA256")
        try disposalRequireProjection(
            rootPath.hasPrefix("/private/tmp/") && !rootPath.utf8.contains(0),
            "DISPOSAL_READER_ROOT_SCOPE")

        let rootURL = URL(fileURLWithPath: rootPath)
        let derivedParentPath = rootURL.deletingLastPathComponent().path
        let derivedRootLeaf = rootURL.lastPathComponent
        try disposalRequireProjection(
            !derivedRootLeaf.isEmpty && derivedRootLeaf != "." &&
                derivedRootLeaf != ".." && !derivedRootLeaf.contains("/") &&
                !derivedRootLeaf.hasPrefix(DisposalSealedArtifactSet.stagingLeafPrefix) &&
                derivedParentPath + "/" + derivedRootLeaf == rootPath,
            "DISPOSAL_READER_ROOT_PATH_SHAPE")

        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        errno = 0
        guard realpath(derivedParentPath, &resolvedParent) != nil else {
            if errno == ENOENT { throw DisposalProjectionMissing() }
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_PARENT_REALPATH",
                detail: String(cString: strerror(errno)))
        }
        let canonicalParentPath = String(
            decoding: resolvedParent.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try disposalRequireProjection(
            canonicalParentPath == derivedParentPath,
            "DISPOSAL_READER_PARENT_ALIAS")

        var namedParentBefore = stat()
        guard lstat(derivedParentPath, &namedParentBefore) == 0 else {
            if errno == ENOENT { throw DisposalProjectionMissing() }
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_PARENT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            (namedParentBefore.st_mode & S_IFMT) == S_IFDIR,
            "DISPOSAL_READER_PARENT_NAMED_TYPE")

        errno = 0
        let openedParent = Darwin.open(
            derivedParentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        if openedParent < 0 && errno == ENOENT { throw DisposalProjectionMissing() }
        guard openedParent >= 0 else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_PARENT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var openedRoot: Int32 = -1
        var openedLeafDescriptors: [Int32] = []
        var retainDescriptors = false
        defer {
            if !retainDescriptors {
                for descriptor in openedLeafDescriptors { _ = Darwin.close(descriptor) }
                if openedRoot >= 0 { _ = Darwin.close(openedRoot) }
                _ = Darwin.close(openedParent)
            }
        }

        var parentState = stat()
        guard fstat(openedParent, &parentState) == 0 else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_PARENT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            (parentState.st_mode & S_IFMT) == S_IFDIR,
            "DISPOSAL_READER_PARENT_TYPE")
        try disposalRequireProjection(
            disposalHeldProjectionSameIdentity(namedParentBefore, parentState),
            "DISPOSAL_READER_PARENT_NAMED_HELD_JOIN")

        var namedRootBefore = stat()
        errno = 0
        guard fstatat(
            openedParent,
            derivedRootLeaf,
            &namedRootBefore,
            AT_SYMLINK_NOFOLLOW) == 0
        else {
            if errno == ENOENT { throw DisposalProjectionMissing() }
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_ROOT_LSTAT",
                detail: String(cString: strerror(errno)))
        }

        openedRoot = derivedRootLeaf.withCString {
            disposal_projection_openat_directory_no_follow(openedParent, $0)
        }
        guard openedRoot >= 0 else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_ROOT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var rootState = stat()
        guard fstat(openedRoot, &rootState) == 0 else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_ROOT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalHeldProjectionSameState(namedRootBefore, rootState),
            "DISPOSAL_READER_ROOT_NAMED_HELD_JOIN")
        try disposalRequireProjection(
            (rootState.st_mode & S_IFMT) == S_IFDIR,
            "DISPOSAL_READER_ROOT_TYPE")
        try disposalRequireProjection(
            (rootState.st_mode & 0o7777) == 0o500,
            "DISPOSAL_READER_ROOT_MODE")
        try disposalRequireProjection(
            rootState.st_uid == geteuid(),
            "DISPOSAL_READER_ROOT_OWNER")
        try disposalRequireProjection(
            rootState.st_nlink >= 2,
            "DISPOSAL_READER_ROOT_LINK_COUNT")

        let expectedInventory = Self.leafSpecifications.map(\.leaf).sorted()
        try disposalRequireProjection(
            try disposalHeldProjectionDirectoryEntries(openedRoot).sorted() == expectedInventory,
            "DISPOSAL_READER_ROOT_INVENTORY")

        var admittedLeaves: [String: HeldLeaf] = [:]
        for specification in Self.leafSpecifications {
            let held = try disposalHeldProjectionOpenLeaf(
                rootDescriptor: openedRoot,
                leaf: specification.leaf,
                maximumBytes: specification.maximumBytes)
            openedLeafDescriptors.append(held.descriptor)
            admittedLeaves[specification.leaf] = held
        }
        guard let heldEvidence = admittedLeaves[DisposalProjectionSetV1.evidenceLeaf],
              let heldMetrics = admittedLeaves[DisposalProjectionSetV1.metricsLeaf],
              let heldGraph = admittedLeaves[DisposalProjectionSetV1.graphLeaf],
              let heldSeal = admittedLeaves[DisposalProjectionSetV1.sealLeaf]
        else {
            throw DisposalProjectionRejection(code: "DISPOSAL_READER_HELD_INVENTORY")
        }
        try disposalRequireProjection(
            heldSeal.sha256 == expectedSealSHA256,
            "DISPOSAL_READER_SEAL_SHA256")

        self.rootPath = rootPath
        parentPath = derivedParentPath
        rootLeaf = derivedRootLeaf
        self.expectedSealSHA256 = expectedSealSHA256
        parentDescriptor = openedParent
        rootDescriptor = openedRoot
        admittedParentState = parentState
        admittedRootState = rootState
        heldLeaves = admittedLeaves
        evidence = heldEvidence.bytes
        metrics = heldMetrics.bytes
        graph = heldGraph.bytes
        seal = heldSeal.bytes

        try revalidate()
        retainDescriptors = true
    }

    deinit {
        for held in heldLeaves.values { _ = Darwin.close(held.descriptor) }
        _ = Darwin.close(rootDescriptor)
        _ = Darwin.close(parentDescriptor)
    }

    func revalidate() throws {
        try revalidateParentIdentity()

        let expectedInventory = Self.leafSpecifications.map(\.leaf).sorted()
        try disposalRequireProjection(
            try disposalHeldProjectionDirectoryEntries(rootDescriptor).sorted() ==
                expectedInventory,
            "DISPOSAL_READER_ROOT_INVENTORY_DRIFT")
        try disposalRequireProjection(
            heldLeaves.keys.sorted() == expectedInventory,
            "DISPOSAL_READER_HELD_INVENTORY_DRIFT")
        try disposalRequireProjection(
            heldLeaves[DisposalProjectionSetV1.evidenceLeaf]?.bytes == evidence &&
                heldLeaves[DisposalProjectionSetV1.metricsLeaf]?.bytes == metrics &&
                heldLeaves[DisposalProjectionSetV1.graphLeaf]?.bytes == graph &&
                heldLeaves[DisposalProjectionSetV1.sealLeaf]?.bytes == seal,
            "DISPOSAL_READER_HELD_BYTES_DRIFT")

        for leaf in expectedInventory {
            guard let held = heldLeaves[leaf] else {
                throw DisposalProjectionRejection(
                    code: "DISPOSAL_READER_HELD_LEAF_ABSENT",
                    detail: leaf)
            }
            var descriptorState = stat()
            var namedState = stat()
            guard fstat(held.descriptor, &descriptorState) == 0,
                  fstatat(
                    rootDescriptor,
                    leaf,
                    &namedState,
                    AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalProjectionRejection(
                    code: "DISPOSAL_READER_LEAF_REVALIDATE",
                    detail: leaf + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                disposalHeldProjectionSameState(held.admittedState, descriptorState),
                "DISPOSAL_READER_LEAF_DRIFT",
                detail: leaf)
            try disposalRequireProjection(
                disposalHeldProjectionSameState(descriptorState, namedState),
                "DISPOSAL_READER_LEAF_REBOUND",
                detail: leaf)
            let freshBytes = try disposalHeldProjectionPread(
                descriptor: held.descriptor,
                count: held.bytes.count,
                leaf: leaf)
            var descriptorAfterRead = stat()
            var namedAfterRead = stat()
            guard fstat(held.descriptor, &descriptorAfterRead) == 0,
                  fstatat(
                    rootDescriptor,
                    leaf,
                    &namedAfterRead,
                    AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalProjectionRejection(
                    code: "DISPOSAL_READER_LEAF_POSTREAD_REVALIDATE",
                    detail: leaf + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                disposalHeldProjectionSameState(descriptorState, descriptorAfterRead),
                "DISPOSAL_READER_LEAF_POSTREAD_DRIFT",
                detail: leaf)
            try disposalRequireProjection(
                disposalHeldProjectionSameState(descriptorAfterRead, namedAfterRead),
                "DISPOSAL_READER_LEAF_POSTREAD_REBOUND",
                detail: leaf)
            try disposalRequireProjection(
                freshBytes == held.bytes,
                "DISPOSAL_READER_LEAF_BYTES_DRIFT",
                detail: leaf)
            try disposalRequireProjection(
                disposalSHA256(freshBytes) == held.sha256,
                "DISPOSAL_READER_LEAF_SHA256_DRIFT",
                detail: leaf)
        }

        guard let heldSeal = heldLeaves[DisposalProjectionSetV1.sealLeaf] else {
            throw DisposalProjectionRejection(code: "DISPOSAL_READER_HELD_SEAL_ABSENT")
        }
        try disposalRequireProjection(
            heldSeal.bytes == seal && heldSeal.sha256 == expectedSealSHA256 &&
                disposalSHA256(seal) == expectedSealSHA256,
            "DISPOSAL_READER_SEAL_REVALIDATE")
        try disposalRequireProjection(
            try disposalHeldProjectionDirectoryEntries(rootDescriptor).sorted() ==
                expectedInventory,
            "DISPOSAL_READER_ROOT_POSTREAD_INVENTORY_DRIFT")

        try revalidateRootState()
        try revalidateParentIdentity()
    }

    private func revalidateParentIdentity() throws {
        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(parentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_PARENT_REALPATH_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        let canonicalParentPath = String(
            decoding: resolvedParent.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try disposalRequireProjection(
            canonicalParentPath == parentPath,
            "DISPOSAL_READER_PARENT_ALIAS_DRIFT")

        var heldParent = stat()
        var namedParent = stat()
        guard fstat(parentDescriptor, &heldParent) == 0,
              lstat(parentPath, &namedParent) == 0
        else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_PARENT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalHeldProjectionSameIdentity(admittedParentState, heldParent),
            "DISPOSAL_READER_PARENT_IDENTITY_DRIFT")
        try disposalRequireProjection(
            disposalHeldProjectionSameIdentity(heldParent, namedParent),
            "DISPOSAL_READER_PARENT_REBOUND")
    }

    private func revalidateRootState() throws {
        var heldRoot = stat()
        var namedRoot = stat()
        guard fstat(rootDescriptor, &heldRoot) == 0,
              fstatat(
                parentDescriptor,
                rootLeaf,
                &namedRoot,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_ROOT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalHeldProjectionSameState(admittedRootState, heldRoot),
            "DISPOSAL_READER_ROOT_DRIFT")
        try disposalRequireProjection(
            disposalHeldProjectionSameState(heldRoot, namedRoot),
            "DISPOSAL_READER_ROOT_REBOUND")
        try disposalRequireProjection(
            (heldRoot.st_mode & S_IFMT) == S_IFDIR &&
                (heldRoot.st_mode & 0o7777) == 0o500 &&
                heldRoot.st_uid == geteuid() && heldRoot.st_nlink >= 2,
            "DISPOSAL_READER_ROOT_POLICY_DRIFT")
    }
}

private func disposalHeldProjectionOpenLeaf(
    rootDescriptor: Int32,
    leaf: String,
    maximumBytes: Int
) throws -> DisposalHeldProjectionSet.HeldLeaf {
    let descriptor = leaf.withCString {
        disposal_projection_openat_readonly_no_follow(rootDescriptor, $0)
    }
    guard descriptor >= 0 else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_LEAF_OPEN",
            detail: leaf + ":" + String(cString: strerror(errno)))
    }
    var closeOnFailure = true
    defer { if closeOnFailure { _ = Darwin.close(descriptor) } }

    var before = stat()
    guard fstat(descriptor, &before) == 0 else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_LEAF_FSTAT",
            detail: leaf + ":" + String(cString: strerror(errno)))
    }
    try disposalRequireProjection(
        (before.st_mode & S_IFMT) == S_IFREG,
        "DISPOSAL_READER_LEAF_TYPE",
        detail: leaf)
    try disposalRequireProjection(
        (before.st_mode & 0o7777) == 0o400,
        "DISPOSAL_READER_LEAF_MODE",
        detail: leaf)
    try disposalRequireProjection(
        before.st_uid == geteuid() && before.st_nlink == 1,
        "DISPOSAL_READER_LEAF_IDENTITY",
        detail: leaf)
    try disposalRequireProjection(
        before.st_size > 0 && before.st_size <= off_t(maximumBytes),
        "DISPOSAL_READER_LEAF_SIZE",
        detail: leaf)

    let bytes = try disposalHeldProjectionPread(
        descriptor: descriptor,
        count: Int(before.st_size),
        leaf: leaf)
    var after = stat()
    var named = stat()
    guard fstat(descriptor, &after) == 0,
          fstatat(rootDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
    else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_LEAF_REVALIDATE",
            detail: leaf + ":" + String(cString: strerror(errno)))
    }
    try disposalRequireProjection(
        disposalHeldProjectionSameState(before, after),
        "DISPOSAL_READER_LEAF_DRIFT",
        detail: leaf)
    try disposalRequireProjection(
        disposalHeldProjectionSameState(after, named),
        "DISPOSAL_READER_LEAF_REBOUND",
        detail: leaf)
    closeOnFailure = false
    return .init(
        descriptor: descriptor,
        admittedState: after,
        bytes: bytes,
        sha256: disposalSHA256(bytes))
}

private func disposalHeldProjectionPread(
    descriptor: Int32,
    count: Int,
    leaf: String
) throws -> Data {
    var data = Data(count: count)
    var offset = 0
    while offset < count {
        let result = data.withUnsafeMutableBytes { raw -> Int in
            guard let base = raw.baseAddress else { return -1 }
            return pread(
                descriptor,
                base.advanced(by: offset),
                count - offset,
                off_t(offset))
        }
        if result > 0 {
            offset += result
        } else if result < 0 && errno == EINTR {
            continue
        } else {
            throw DisposalProjectionRejection(
                code: "DISPOSAL_READER_PREAD",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
    }
    return data
}

private func disposalHeldProjectionDirectoryEntries(
    _ descriptor: Int32
) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0 else {
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_ROOT_DUP",
            detail: String(cString: strerror(errno)))
    }
    guard let directory = fdopendir(copied) else {
        _ = Darwin.close(copied)
        throw DisposalProjectionRejection(
            code: "DISPOSAL_READER_ROOT_FDOPENDIR",
            detail: String(cString: strerror(errno)))
    }
    defer { closedir(directory) }
    rewinddir(directory)
    var result: [String] = []
    errno = 0
    while let entry = readdir(directory) {
        let name = withUnsafePointer(to: &entry.pointee.d_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(NAME_MAX) + 1) {
                String(cString: $0)
            }
        }
        if name != "." && name != ".." { result.append(name) }
        errno = 0
    }
    try disposalRequireProjection(
        errno == 0,
        "DISPOSAL_READER_ROOT_READDIR",
        detail: String(cString: strerror(errno)))
    return result
}

private func disposalHeldProjectionSameIdentity(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev &&
        lhs.st_ino == rhs.st_ino &&
        lhs.st_gen == rhs.st_gen &&
        lhs.st_mode == rhs.st_mode &&
        lhs.st_uid == rhs.st_uid &&
        lhs.st_gid == rhs.st_gid
}

private func disposalHeldProjectionSameState(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev &&
        lhs.st_ino == rhs.st_ino &&
        lhs.st_mode == rhs.st_mode &&
        lhs.st_nlink == rhs.st_nlink &&
        lhs.st_uid == rhs.st_uid &&
        lhs.st_gid == rhs.st_gid &&
        lhs.st_size == rhs.st_size &&
        lhs.st_gen == rhs.st_gen &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}
