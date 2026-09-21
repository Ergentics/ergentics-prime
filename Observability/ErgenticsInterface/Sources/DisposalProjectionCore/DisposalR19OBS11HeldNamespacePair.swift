import Darwin
import DisposalProjectionPrimitivesC
import Foundation

final class DisposalR19OBS11HeldNamespacePair {
    private struct LeafSpecification {
        let leaf: String
        let maximumBytes: Int
    }

    private struct HeldLeaf {
        let descriptor: Int32
        let admittedState: stat
        let bytes: Data
        let sha256: String
    }

    private struct HeldRoot {
        let descriptor: Int32
        let admittedState: stat
        let leaves: [String: HeldLeaf]
    }

    private static let parentPath = "/private/tmp"
    private static let specifications = [
        LeafSpecification(
            leaf: DisposalProjectionSetV1.evidenceLeaf,
            maximumBytes: 128 * 1_024 * 1_024),
        LeafSpecification(
            leaf: DisposalProjectionSetV1.metricsLeaf,
            maximumBytes: 128 * 1_024 * 1_024),
        LeafSpecification(
            leaf: DisposalProjectionSetV1.graphLeaf,
            maximumBytes: 128 * 1_024 * 1_024),
        LeafSpecification(
            leaf: DisposalProjectionSetV1.sealLeaf,
            maximumBytes: 1 * 1_024 * 1_024),
    ]

    let state: DisposalR19OBS11RetainedNamespaceState

    private let finalLeaf: String
    private let stagingLeaf: String
    private let parentDescriptor: Int32
    private let admittedParentState: stat
    private let heldFinal: HeldRoot?
    private let heldStaging: HeldRoot?
    private let ownership: DisposalOutputNamespaceOwnership?

    init(
        plan: DisposalR19OBS11PlanStep,
        ownership: DisposalOutputNamespaceOwnership?
    ) throws {
        let finalURL = URL(fileURLWithPath: plan.finalRoot)
        let stagingURL = URL(fileURLWithPath: plan.stagingRoot)
        let derivedFinalLeaf = finalURL.lastPathComponent
        let derivedStagingLeaf = stagingURL.lastPathComponent
        try disposalRequireProjection(
            finalURL.deletingLastPathComponent().path == Self.parentPath &&
                stagingURL.deletingLastPathComponent().path == Self.parentPath &&
                Self.parentPath + "/" + derivedFinalLeaf == plan.finalRoot &&
                Self.parentPath + "/" + derivedStagingLeaf == plan.stagingRoot &&
                DisposalSealedArtifactSet.stagingPath(for: plan.finalRoot) ==
                    plan.stagingRoot &&
                derivedFinalLeaf != derivedStagingLeaf,
            "OBS11_RETAINED_NAMESPACE_PATH_JOIN")

        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(Self.parentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_PARENT_REALPATH",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19OBS11HeldNamespacePath(resolvedParent) == Self.parentPath,
            "OBS11_RETAINED_PARENT_ALIAS")
        var namedParent = stat()
        guard lstat(Self.parentPath, &namedParent) == 0 else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_PARENT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        let openedParent = Darwin.open(
            Self.parentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedParent >= 0 else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_PARENT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var capturedFinal: HeldRoot?
        var capturedStaging: HeldRoot?
        var retainDescriptors = false
        defer {
            if !retainDescriptors {
                Self.close(capturedFinal)
                Self.close(capturedStaging)
                _ = Darwin.close(openedParent)
            }
        }
        var parentState = stat()
        guard fstat(openedParent, &parentState) == 0 else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_PARENT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19OBS11HeldNamespaceSameIdentity(namedParent, parentState) &&
                (parentState.st_mode & S_IFMT) == S_IFDIR &&
                (parentState.st_mode & 0o7777) == 0o1777 &&
                parentState.st_uid == 0 && parentState.st_gid == 0,
            "OBS11_RETAINED_PARENT_POLICY")

        if ownership == nil {
            try Self.requireAbsent(
                parentDescriptor: openedParent,
                leaf: derivedFinalLeaf)
            try Self.requireAbsent(
                parentDescriptor: openedParent,
                leaf: derivedStagingLeaf)
        } else {
            capturedFinal = try Self.captureRoot(
                parentDescriptor: openedParent,
                leaf: derivedFinalLeaf)
            capturedStaging = try Self.captureRoot(
                parentDescriptor: openedParent,
                leaf: derivedStagingLeaf)
        }
        try disposalRequireProjection(
            capturedFinal == nil || capturedStaging == nil,
            "OBS11_RETAINED_BOTH_NAMES_PRESENT")
        let finalPresent = capturedFinal != nil
        let stagingPresent = capturedStaging != nil
        if let ownership {
            try disposalRequireProjection(
                ownership.finalPath == plan.finalRoot &&
                    ownership.stagingPath == plan.stagingRoot,
                "OBS11_RETAINED_OWNERSHIP_PATH_JOIN")
            try ownership.revalidate(
                finalPresent: finalPresent,
                stagingPresent: stagingPresent)
            try ownership.proveDurable(
                finalPresent: finalPresent,
                stagingPresent: stagingPresent)
        } else {
            try disposalRequireProjection(
                !finalPresent && !stagingPresent,
                "OBS11_RETAINED_PRESENT_ORIGIN_UNPROVEN")
        }

        finalLeaf = derivedFinalLeaf
        stagingLeaf = derivedStagingLeaf
        parentDescriptor = openedParent
        admittedParentState = parentState
        heldFinal = capturedFinal
        heldStaging = capturedStaging
        self.ownership = ownership
        let originProof = ownership == nil
            ? "ABSENT_BOTH_NAMES_DESCRIPTOR_REVALIDATED"
            : "BUILDER_PREPARED_DURABLE_NAMESPACE_DESCRIPTOR_JOIN"
        let snapshotComponents = Self.snapshotComponents(
            plan: plan,
            final: capturedFinal,
            staging: capturedStaging,
            originProof: originProof)
        state = .init(
            step: plan.step,
            finalRootState: capturedFinal == nil ? "ABSENT" : "PRESENT_RETAINED",
            stagingRootState: capturedStaging == nil ? "ABSENT" : "PRESENT_RETAINED",
            originProof: originProof,
            snapshotSHA256: Self.snapshotCommitment(snapshotComponents),
            snapshotComponents: snapshotComponents)
        try revalidate()
        retainDescriptors = true
    }

    deinit {
        Self.close(heldFinal)
        Self.close(heldStaging)
        _ = Darwin.close(parentDescriptor)
    }

    func revalidate() throws {
        try revalidateParent()
        try revalidateRoot(heldFinal, leaf: finalLeaf)
        try revalidateRoot(heldStaging, leaf: stagingLeaf)
        try ownership?.revalidate(
            finalPresent: heldFinal != nil,
            stagingPresent: heldStaging != nil)
        try revalidateRoot(heldFinal, leaf: finalLeaf)
        try revalidateRoot(heldStaging, leaf: stagingLeaf)
        try revalidateParent()
    }

    private func revalidateParent() throws {
        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(Self.parentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_PARENT_REALPATH_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19OBS11HeldNamespacePath(resolvedParent) == Self.parentPath,
            "OBS11_RETAINED_PARENT_ALIAS_DRIFT")
        var held = stat()
        var named = stat()
        guard fstat(parentDescriptor, &held) == 0,
              lstat(Self.parentPath, &named) == 0
        else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_PARENT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19OBS11HeldNamespaceSameIdentity(admittedParentState, held) &&
                disposalR19OBS11HeldNamespaceSameIdentity(held, named),
            "OBS11_RETAINED_PARENT_REBOUND")
    }

    private func revalidateRoot(_ root: HeldRoot?, leaf: String) throws {
        guard let root else {
            var named = stat()
            errno = 0
            let result = fstatat(
                parentDescriptor,
                leaf,
                &named,
                AT_SYMLINK_NOFOLLOW)
            try disposalRequireProjection(
                result != 0 && errno == ENOENT,
                "OBS11_RETAINED_ABSENCE_DRIFT",
                detail: leaf)
            return
        }

        var heldRoot = stat()
        var namedRoot = stat()
        guard fstat(root.descriptor, &heldRoot) == 0,
              fstatat(
                parentDescriptor,
                leaf,
                &namedRoot,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_ROOT_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        let expectedLeaves = root.leaves.keys.sorted()
        try disposalRequireProjection(
                disposalR19OBS11HeldNamespaceSameState(root.admittedState, heldRoot) &&
                disposalR19OBS11HeldNamespaceSameState(heldRoot, namedRoot) &&
                (try disposalR19OBS11HeldNamespaceEntries(root.descriptor)).sorted() ==
                    expectedLeaves,
            "OBS11_RETAINED_ROOT_DRIFT",
            detail: leaf)

        for leafName in expectedLeaves {
            guard let heldLeaf = root.leaves[leafName] else {
                throw DisposalProjectionRejection(
                    code: "OBS11_RETAINED_HELD_LEAF_ABSENT",
                    detail: leafName)
            }
            try Self.revalidateLeaf(
                heldLeaf,
                rootDescriptor: root.descriptor,
                leaf: leafName)
        }
        var heldAfter = stat()
        var namedAfter = stat()
        guard fstat(root.descriptor, &heldAfter) == 0,
              fstatat(
                parentDescriptor,
                leaf,
                &namedAfter,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_ROOT_POSTREAD_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19OBS11HeldNamespaceSameState(heldRoot, heldAfter) &&
                disposalR19OBS11HeldNamespaceSameState(heldAfter, namedAfter) &&
                (try disposalR19OBS11HeldNamespaceEntries(root.descriptor)).sorted() ==
                    expectedLeaves,
            "OBS11_RETAINED_ROOT_POSTREAD_DRIFT",
            detail: leaf)
    }

    private static func captureRoot(
        parentDescriptor: Int32,
        leaf: String
    ) throws -> HeldRoot? {
        var namedBefore = stat()
        errno = 0
        guard fstatat(
            parentDescriptor,
            leaf,
            &namedBefore,
            AT_SYMLINK_NOFOLLOW) == 0
        else {
            if errno == ENOENT { return nil }
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_ROOT_LSTAT",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        let descriptor = leaf.withCString {
            disposal_projection_openat_directory_no_follow(parentDescriptor, $0)
        }
        guard descriptor >= 0 else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_ROOT_OPEN",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        var openedLeaves: [Int32] = []
        var retainDescriptors = false
        defer {
            if !retainDescriptors {
                for descriptor in openedLeaves { _ = Darwin.close(descriptor) }
                _ = Darwin.close(descriptor)
            }
        }
        var rootBefore = stat()
        guard fstat(descriptor, &rootBefore) == 0 else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_ROOT_FSTAT",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        let inventory = try disposalR19OBS11HeldNamespaceEntries(descriptor).sorted()
        let allowed = Set(specifications.map(\.leaf))
        try disposalRequireProjection(
            disposalR19OBS11HeldNamespaceSameState(namedBefore, rootBefore) &&
                (rootBefore.st_mode & S_IFMT) == S_IFDIR &&
                [mode_t(0o700), mode_t(0o500)].contains(rootBefore.st_mode & 0o7777) &&
                rootBefore.st_uid == geteuid() && rootBefore.st_nlink >= 2 &&
                Set(inventory).count == inventory.count &&
                inventory.allSatisfy { allowed.contains($0) },
            "OBS11_RETAINED_ROOT_POLICY",
            detail: leaf)

        var leaves: [String: HeldLeaf] = [:]
        for leafName in inventory {
            guard let specification = specifications.first(where: { $0.leaf == leafName })
            else {
                throw DisposalProjectionRejection(
                    code: "OBS11_RETAINED_LEAF_SPECIFICATION",
                    detail: leafName)
            }
            let opened = leafName.withCString {
                disposal_projection_openat_readonly_no_follow(descriptor, $0)
            }
            guard opened >= 0 else {
                throw DisposalProjectionRejection(
                    code: "OBS11_RETAINED_LEAF_OPEN",
                    detail: leafName + ":" + String(cString: strerror(errno)))
            }
            openedLeaves.append(opened)
            var leafBefore = stat()
            guard fstat(opened, &leafBefore) == 0 else {
                throw DisposalProjectionRejection(
                    code: "OBS11_RETAINED_LEAF_FSTAT",
                    detail: leafName + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                (leafBefore.st_mode & S_IFMT) == S_IFREG &&
                    [mode_t(0o600), mode_t(0o400)].contains(
                        leafBefore.st_mode & 0o7777) &&
                    leafBefore.st_uid == geteuid() && leafBefore.st_nlink == 1 &&
                    leafBefore.st_size >= 0 &&
                    leafBefore.st_size <= off_t(specification.maximumBytes),
                "OBS11_RETAINED_LEAF_POLICY",
                detail: leafName)
            let bytes = try disposalR19OBS11HeldNamespacePread(
                descriptor: opened,
                count: Int(leafBefore.st_size),
                leaf: leafName)
            var leafAfter = stat()
            var namedLeaf = stat()
            guard fstat(opened, &leafAfter) == 0,
                  fstatat(descriptor, leafName, &namedLeaf, AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalProjectionRejection(
                    code: "OBS11_RETAINED_LEAF_CAPTURE_REVALIDATE",
                    detail: leafName + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                disposalR19OBS11HeldNamespaceSameState(leafBefore, leafAfter) &&
                    disposalR19OBS11HeldNamespaceSameState(leafAfter, namedLeaf),
                "OBS11_RETAINED_LEAF_CAPTURE_DRIFT",
                detail: leafName)
            leaves[leafName] = .init(
                descriptor: opened,
                admittedState: leafAfter,
                bytes: bytes,
                sha256: disposalSHA256(bytes))
        }
        var rootAfter = stat()
        var namedAfter = stat()
        guard fstat(descriptor, &rootAfter) == 0,
              fstatat(
                parentDescriptor,
                leaf,
                &namedAfter,
                AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_ROOT_CAPTURE_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19OBS11HeldNamespaceSameState(rootBefore, rootAfter) &&
                disposalR19OBS11HeldNamespaceSameState(rootAfter, namedAfter) &&
                (try disposalR19OBS11HeldNamespaceEntries(descriptor)).sorted() == inventory,
            "OBS11_RETAINED_ROOT_CAPTURE_DRIFT",
            detail: leaf)
        retainDescriptors = true
        return .init(
            descriptor: descriptor,
            admittedState: rootAfter,
            leaves: leaves)
    }

    private static func requireAbsent(
        parentDescriptor: Int32,
        leaf: String
    ) throws {
        var named = stat()
        errno = 0
        let result = fstatat(
            parentDescriptor,
            leaf,
            &named,
            AT_SYMLINK_NOFOLLOW)
        try disposalRequireProjection(
            result != 0 && errno == ENOENT,
            "OBS11_RETAINED_PRESENT_ORIGIN_UNPROVEN",
            detail: leaf)
    }

    private static func revalidateLeaf(
        _ leafState: HeldLeaf,
        rootDescriptor: Int32,
        leaf: String
    ) throws {
        var before = stat()
        var namedBefore = stat()
        guard fstat(leafState.descriptor, &before) == 0,
              fstatat(rootDescriptor, leaf, &namedBefore, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_LEAF_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19OBS11HeldNamespaceSameState(leafState.admittedState, before) &&
                disposalR19OBS11HeldNamespaceSameState(before, namedBefore),
            "OBS11_RETAINED_LEAF_DRIFT",
            detail: leaf)
        let fresh = try disposalR19OBS11HeldNamespacePread(
            descriptor: leafState.descriptor,
            count: leafState.bytes.count,
            leaf: leaf)
        var after = stat()
        var namedAfter = stat()
        guard fstat(leafState.descriptor, &after) == 0,
              fstatat(rootDescriptor, leaf, &namedAfter, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "OBS11_RETAINED_LEAF_POSTREAD_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalR19OBS11HeldNamespaceSameState(before, after) &&
                disposalR19OBS11HeldNamespaceSameState(after, namedAfter) &&
                fresh == leafState.bytes && disposalSHA256(fresh) == leafState.sha256,
            "OBS11_RETAINED_LEAF_POSTREAD_DRIFT",
            detail: leaf)
    }

    private static func close(_ root: HeldRoot?) {
        guard let root else { return }
        for leaf in root.leaves.values { _ = Darwin.close(leaf.descriptor) }
        _ = Darwin.close(root.descriptor)
    }

    private static func snapshotComponents(
        plan: DisposalR19OBS11PlanStep,
        final: HeldRoot?,
        staging: HeldRoot?,
        originProof: String
    ) -> [String] {
        var components = [
            String(plan.step),
            plan.finalRoot,
            plan.stagingRoot,
            originProof,
        ]
        append(root: final, label: "FINAL", to: &components)
        append(root: staging, label: "STAGING", to: &components)
        return components
    }

    private static func snapshotCommitment(_ components: [String]) -> String {
        return disposalLengthFramedID(
            "ergentics-r19-obs11-retained-namespace-snapshot-v1",
            components)
    }

    private static func append(
        root: HeldRoot?,
        label: String,
        to components: inout [String]
    ) {
        guard let root else {
            components.append(contentsOf: [label, "ABSENT"])
            return
        }
        components.append(contentsOf: [label, "PRESENT"])
        append(state: root.admittedState, to: &components)
        for leaf in root.leaves.keys.sorted() {
            guard let held = root.leaves[leaf] else { continue }
            components.append(leaf)
            append(state: held.admittedState, to: &components)
            components.append(held.sha256)
        }
    }

    private static func append(state: stat, to components: inout [String]) {
        components.append(contentsOf: [
            String(UInt64(state.st_dev)),
            String(UInt64(state.st_ino)),
            String(UInt64(state.st_gen)),
            String(UInt64(state.st_mode)),
            String(UInt64(state.st_uid)),
            String(UInt64(state.st_gid)),
            String(UInt64(state.st_nlink)),
            String(Int64(state.st_size)),
            String(Int64(state.st_mtimespec.tv_sec)),
            String(Int64(state.st_mtimespec.tv_nsec)),
            String(Int64(state.st_ctimespec.tv_sec)),
            String(Int64(state.st_ctimespec.tv_nsec)),
        ])
    }
}

private func disposalR19OBS11HeldNamespacePath(_ buffer: [CChar]) -> String {
    String(
        decoding: buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
        as: UTF8.self)
}

private func disposalR19OBS11HeldNamespacePread(
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
                code: "OBS11_RETAINED_LEAF_PREAD",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
    }
    return data
}

private func disposalR19OBS11HeldNamespaceEntries(
    _ descriptor: Int32
) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0 else {
        throw DisposalProjectionRejection(
            code: "OBS11_RETAINED_ROOT_DUP",
            detail: String(cString: strerror(errno)))
    }
    guard let directory = fdopendir(copied) else {
        _ = Darwin.close(copied)
        throw DisposalProjectionRejection(
            code: "OBS11_RETAINED_ROOT_FDOPENDIR",
            detail: String(cString: strerror(errno)))
    }
    defer { closedir(directory) }
    rewinddir(directory)
    var entries: [String] = []
    errno = 0
    while let entry = readdir(directory) {
        let name = withUnsafePointer(to: &entry.pointee.d_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(NAME_MAX) + 1) {
                String(cString: $0)
            }
        }
        if name != "." && name != ".." { entries.append(name) }
        errno = 0
    }
    guard errno == 0 else {
        throw DisposalProjectionRejection(
            code: "OBS11_RETAINED_ROOT_READDIR",
            detail: String(cString: strerror(errno)))
    }
    return entries
}

private func disposalR19OBS11HeldNamespaceSameIdentity(
    _ lhs: stat,
    _ rhs: stat
) -> Bool {
    lhs.st_dev == rhs.st_dev && lhs.st_ino == rhs.st_ino &&
        lhs.st_gen == rhs.st_gen && lhs.st_mode == rhs.st_mode &&
        lhs.st_uid == rhs.st_uid && lhs.st_gid == rhs.st_gid
}

private func disposalR19OBS11HeldNamespaceSameState(
    _ lhs: stat,
    _ rhs: stat
) -> Bool {
    disposalR19OBS11HeldNamespaceSameIdentity(lhs, rhs) &&
        lhs.st_nlink == rhs.st_nlink && lhs.st_size == rhs.st_size &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}
