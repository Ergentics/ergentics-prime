import Darwin
import DisposalProjectionPrimitivesC
import Foundation

struct DisposalProjectionRuleResources: Sendable {
    let evidenceDDL: Data
    let graphDDL: Data
    let metricsDDL: Data
    let adapters: Data
    let lattice: Data

    static func bundleDefault() throws -> Self {
        .init(
            evidenceDDL: try disposalResourceData("001-evidence", extension: "sql"),
            graphDDL: try disposalResourceData("001-graph", extension: "sql"),
            metricsDDL: try disposalResourceData("001-metrics", extension: "sql"),
            adapters: try disposalResourceData("disposal-adapters.v1", extension: "json"),
            lattice: try disposalResourceData("disposal-lattice.v1", extension: "json"))
    }
}

final class DisposalHeldProjectionRuleResources {
    private struct Specification: Sendable {
        let leaf: String
        let bytes: Int
        let sha256: String
    }

    private struct HeldLeaf {
        let descriptor: Int32
        let admittedState: stat
        let bytes: Data
        let sha256: String
    }

    private static let specifications: [Specification] = [
        .init(
            leaf: "001-evidence.sql",
            bytes: 50_706,
            sha256: "f3e003136aa4f9a12308d310ffa6bc92d71bccb99a7a50656c32231b79a435c7"),
        .init(
            leaf: "001-graph.sql",
            bytes: 41_517,
            sha256: "f65eb702e528f851bfd3bcce2817258dfdc5779132bba780964c82c0d752009e"),
        .init(
            leaf: "001-metrics.sql",
            bytes: 12_119,
            sha256: "eda615d5bc71246c54d7335679f641646e11c8938ef01a459cf168be2aa5ce61"),
        .init(
            leaf: "disposal-adapters.v1.json",
            bytes: 4_610,
            sha256: "68e09200dd29a47fcbe49e083df41fe55ead950198edf75300ab6e302b61be1b"),
        .init(
            leaf: "disposal-lattice.v1.json",
            bytes: 1_937,
            sha256: "c99361cb2052032e176b1ab5cd22898a67231b98bdea8c972388bdeab12ba022"),
    ]

    let resources: DisposalProjectionRuleResources

    private let parentPath: String
    private let rootPath: String
    private let rootLeaf: String
    private let parentDescriptor: Int32
    private let rootDescriptor: Int32
    private let admittedParentState: stat
    private let admittedRootState: stat
    private let heldLeaves: [String: HeldLeaf]

    static func admitFrozen() throws -> DisposalHeldProjectionRuleResources {
        var resolvedPaths: [String: String] = [:]
        for specification in specifications {
            let url = URL(fileURLWithPath: specification.leaf)
            let resourceName = url.deletingPathExtension().lastPathComponent
            let resourceExtension = url.pathExtension
            guard let resourceURL = Bundle.module.url(
                forResource: resourceName,
                withExtension: resourceExtension)
            else {
                throw DisposalProjectionRejection(
                    code: "RULE_RESOURCE_ABSENT",
                    detail: specification.leaf)
            }
            resolvedPaths[specification.leaf] = resourceURL.path
        }
        let parents = Set(resolvedPaths.values.map {
            URL(fileURLWithPath: $0).deletingLastPathComponent().path
        })
        try disposalRequireProjection(
            parents.count == 1,
            "RULE_RESOURCE_COMMON_PARENT")
        guard let rootPath = parents.first else {
            throw DisposalProjectionRejection(code: "RULE_RESOURCE_ROOT_ABSENT")
        }
        for specification in specifications {
            try disposalRequireProjection(
                resolvedPaths[specification.leaf] == rootPath + "/" + specification.leaf,
                "RULE_RESOURCE_PATH_JOIN",
                detail: specification.leaf)
        }
        return try DisposalHeldProjectionRuleResources(rootPath: rootPath)
    }

    private init(rootPath: String) throws {
        self.rootPath = rootPath
        try disposalRequireProjection(
            rootPath.hasPrefix("/") && !rootPath.utf8.contains(0),
            "RULE_RESOURCE_ROOT_PATH")
        let rootURL = URL(fileURLWithPath: rootPath)
        parentPath = rootURL.deletingLastPathComponent().path
        rootLeaf = rootURL.lastPathComponent
        try disposalRequireProjection(
            !rootLeaf.isEmpty && rootLeaf != "." && rootLeaf != ".." &&
                !rootLeaf.contains("/") && parentPath + "/" + rootLeaf == rootPath,
            "RULE_RESOURCE_ROOT_PATH")

        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(parentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_PARENT_REALPATH",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourcePath(resolvedParent) == parentPath,
            "RULE_RESOURCE_PARENT_ALIAS")

        var namedParent = stat()
        guard lstat(parentPath, &namedParent) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_PARENT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        let openedParent = Darwin.open(
            parentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedParent >= 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_PARENT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var openedRoot: Int32 = -1
        var openedLeaves: [Int32] = []
        var retainDescriptors = false
        defer {
            if !retainDescriptors {
                for descriptor in openedLeaves { _ = Darwin.close(descriptor) }
                if openedRoot >= 0 { _ = Darwin.close(openedRoot) }
                _ = Darwin.close(openedParent)
            }
        }

        var parentState = stat()
        guard fstat(openedParent, &parentState) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_PARENT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameIdentity(namedParent, parentState) &&
                (parentState.st_mode & S_IFMT) == S_IFDIR &&
                parentState.st_uid == geteuid() &&
                (parentState.st_mode & 0o022) == 0,
            "RULE_RESOURCE_PARENT_POLICY")

        var namedRoot = stat()
        guard fstatat(openedParent, rootLeaf, &namedRoot, AT_SYMLINK_NOFOLLOW) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_ROOT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        openedRoot = rootLeaf.withCString {
            disposal_projection_openat_directory_no_follow(openedParent, $0)
        }
        guard openedRoot >= 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_ROOT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var rootState = stat()
        guard fstat(openedRoot, &rootState) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_ROOT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameState(namedRoot, rootState) &&
                (rootState.st_mode & S_IFMT) == S_IFDIR &&
                (rootState.st_mode & 0o7777) == 0o500 &&
                rootState.st_uid == geteuid() &&
                rootState.st_nlink == nlink_t(2 + Self.specifications.count),
            "RULE_RESOURCE_ROOT_POLICY")
        try disposalRequireProjection(
            try disposalRuleResourceDirectoryEntries(openedRoot).sorted() ==
                Self.specifications.map(\.leaf).sorted(),
            "RULE_RESOURCE_INVENTORY")

        var leaves: [String: HeldLeaf] = [:]
        for specification in Self.specifications {
            let descriptor = specification.leaf.withCString {
                disposal_projection_openat_readonly_no_follow(openedRoot, $0)
            }
            guard descriptor >= 0 else {
                throw DisposalProjectionRejection(
                    code: "RULE_RESOURCE_LEAF_OPEN",
                    detail: specification.leaf + ":" + String(cString: strerror(errno)))
            }
            openedLeaves.append(descriptor)
            var before = stat()
            guard fstat(descriptor, &before) == 0 else {
                throw DisposalProjectionRejection(
                    code: "RULE_RESOURCE_LEAF_FSTAT",
                    detail: specification.leaf + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                (before.st_mode & S_IFMT) == S_IFREG &&
                    (before.st_mode & 0o7777) == 0o400 &&
                    before.st_uid == geteuid() && before.st_nlink == 1 &&
                    before.st_size == off_t(specification.bytes),
                "RULE_RESOURCE_LEAF_POLICY",
                detail: specification.leaf)
            let bytes = try disposalRuleResourcePread(
                descriptor: descriptor,
                count: specification.bytes,
                leaf: specification.leaf)
            var after = stat()
            var named = stat()
            guard fstat(descriptor, &after) == 0,
                  fstatat(openedRoot, specification.leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalProjectionRejection(
                    code: "RULE_RESOURCE_LEAF_REVALIDATE",
                    detail: specification.leaf + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                disposalRuleResourceSameState(before, after) &&
                    disposalRuleResourceSameState(after, named),
                "RULE_RESOURCE_LEAF_JOIN",
                detail: specification.leaf)
            let digest = disposalSHA256(bytes)
            try disposalRequireProjection(
                digest == specification.sha256,
                "RULE_RESOURCE_LEAF_SHA256",
                detail: specification.leaf)
            leaves[specification.leaf] = .init(
                descriptor: descriptor,
                admittedState: after,
                bytes: bytes,
                sha256: digest)
        }

        guard let evidenceDDL = leaves["001-evidence.sql"]?.bytes,
              let graphDDL = leaves["001-graph.sql"]?.bytes,
              let metricsDDL = leaves["001-metrics.sql"]?.bytes,
              let adapters = leaves["disposal-adapters.v1.json"]?.bytes,
              let lattice = leaves["disposal-lattice.v1.json"]?.bytes
        else {
            throw DisposalProjectionRejection(code: "RULE_RESOURCE_HELD_INVENTORY")
        }
        parentDescriptor = openedParent
        rootDescriptor = openedRoot
        admittedParentState = parentState
        admittedRootState = rootState
        heldLeaves = leaves
        resources = .init(
            evidenceDDL: evidenceDDL,
            graphDDL: graphDDL,
            metricsDDL: metricsDDL,
            adapters: adapters,
            lattice: lattice)
        try revalidate()
        retainDescriptors = true
    }

    deinit {
        for leaf in heldLeaves.values { _ = Darwin.close(leaf.descriptor) }
        _ = Darwin.close(rootDescriptor)
        _ = Darwin.close(parentDescriptor)
    }

    func revalidate() throws {
        try revalidateParentAndRoot()
        let expectedInventory = Self.specifications.map(\.leaf).sorted()
        try disposalRequireProjection(
            try disposalRuleResourceDirectoryEntries(rootDescriptor).sorted() == expectedInventory &&
                heldLeaves.keys.sorted() == expectedInventory,
            "RULE_RESOURCE_INVENTORY_DRIFT")

        for specification in Self.specifications {
            guard let held = heldLeaves[specification.leaf] else {
                throw DisposalProjectionRejection(
                    code: "RULE_RESOURCE_HELD_LEAF_ABSENT",
                    detail: specification.leaf)
            }
            var before = stat()
            var namedBefore = stat()
            guard fstat(held.descriptor, &before) == 0,
                  fstatat(
                    rootDescriptor,
                    specification.leaf,
                    &namedBefore,
                    AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalProjectionRejection(
                    code: "RULE_RESOURCE_LEAF_REVALIDATE",
                    detail: specification.leaf + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                disposalRuleResourceSameState(held.admittedState, before) &&
                    disposalRuleResourceSameState(before, namedBefore),
                "RULE_RESOURCE_LEAF_DRIFT",
                detail: specification.leaf)
            let fresh = try disposalRuleResourcePread(
                descriptor: held.descriptor,
                count: specification.bytes,
                leaf: specification.leaf)
            var after = stat()
            var namedAfter = stat()
            guard fstat(held.descriptor, &after) == 0,
                  fstatat(
                    rootDescriptor,
                    specification.leaf,
                    &namedAfter,
                    AT_SYMLINK_NOFOLLOW) == 0
            else {
                throw DisposalProjectionRejection(
                    code: "RULE_RESOURCE_LEAF_POSTREAD_REVALIDATE",
                    detail: specification.leaf + ":" + String(cString: strerror(errno)))
            }
            try disposalRequireProjection(
                disposalRuleResourceSameState(before, after) &&
                    disposalRuleResourceSameState(after, namedAfter) &&
                    fresh == held.bytes && disposalSHA256(fresh) == held.sha256,
                "RULE_RESOURCE_LEAF_POSTREAD_DRIFT",
                detail: specification.leaf)
        }
        try disposalRequireProjection(
            try disposalRuleResourceDirectoryEntries(rootDescriptor).sorted() == expectedInventory,
            "RULE_RESOURCE_POSTREAD_INVENTORY_DRIFT")
        try revalidateParentAndRoot()
    }

    private func revalidateParentAndRoot() throws {
        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(parentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_PARENT_REALPATH_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourcePath(resolvedParent) == parentPath,
            "RULE_RESOURCE_PARENT_ALIAS_DRIFT")

        var heldParent = stat()
        var namedParent = stat()
        guard fstat(parentDescriptor, &heldParent) == 0,
              lstat(parentPath, &namedParent) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_PARENT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameState(admittedParentState, heldParent),
            "RULE_RESOURCE_PARENT_DRIFT")
        try disposalRequireProjection(
            disposalRuleResourceSameState(heldParent, namedParent),
            "RULE_RESOURCE_PARENT_REBOUND")

        var heldRoot = stat()
        var namedRoot = stat()
        guard fstat(rootDescriptor, &heldRoot) == 0,
              fstatat(parentDescriptor, rootLeaf, &namedRoot, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_ROOT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameState(admittedRootState, heldRoot),
            "RULE_RESOURCE_ROOT_DRIFT")
        try disposalRequireProjection(
            disposalRuleResourceSameState(heldRoot, namedRoot),
            "RULE_RESOURCE_ROOT_REBOUND")
    }
}

private func disposalRuleResourcePath(_ buffer: [CChar]) -> String {
    String(
        decoding: buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
        as: UTF8.self)
}

private func disposalRuleResourcePread(
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
                code: "RULE_RESOURCE_PREAD",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
    }
    return data
}

private func disposalRuleResourceDirectoryEntries(_ descriptor: Int32) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0 else {
        throw DisposalProjectionRejection(
            code: "RULE_RESOURCE_ROOT_DUP",
            detail: String(cString: strerror(errno)))
    }
    guard let directory = fdopendir(copied) else {
        _ = Darwin.close(copied)
        throw DisposalProjectionRejection(
            code: "RULE_RESOURCE_ROOT_FDOPENDIR",
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
            code: "RULE_RESOURCE_ROOT_READDIR",
            detail: String(cString: strerror(errno)))
    }
    return entries
}

private func disposalRuleResourceSameIdentity(_ lhs: stat, _ rhs: stat) -> Bool {
    lhs.st_dev == rhs.st_dev && lhs.st_ino == rhs.st_ino && lhs.st_gen == rhs.st_gen &&
        lhs.st_mode == rhs.st_mode && lhs.st_uid == rhs.st_uid && lhs.st_gid == rhs.st_gid
}

private func disposalRuleResourceSameState(_ lhs: stat, _ rhs: stat) -> Bool {
    disposalRuleResourceSameIdentity(lhs, rhs) && lhs.st_nlink == rhs.st_nlink &&
        lhs.st_size == rhs.st_size &&
        lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec &&
        lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec &&
        lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec &&
        lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}
