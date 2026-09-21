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
        try DisposalProjectionEmbeddedResources.exact()
    }

    func orderedValues() -> [Data] {
        [evidenceDDL, graphDDL, metricsDDL, adapters, lattice]
    }
}

final class DisposalHeldProjectionRuleResources {
    private struct HeldFile {
        let descriptor: Int32
        let admittedState: stat
        let bytes: Data
        let sha256: String
    }

    private static let maximumExecutableBytes = 64 * 1_024 * 1_024

    let resources: DisposalProjectionRuleResources
    let executableSHA256: String

    private let location: DisposalExecutableRelativeResourceLocation
    private let parentDescriptor: Int32
    private let closureDescriptor: Int32
    private let resourceRootDescriptor: Int32
    private let admittedParentState: stat
    private let admittedClosureState: stat
    private let admittedResourceRootState: stat
    private let heldExecutable: HeldFile
    private let heldResourceLeaves: [String: HeldFile]

    static func admitFrozen() throws -> DisposalHeldProjectionRuleResources {
        let embedded = try DisposalProjectionEmbeddedResources.exact()
        return try DisposalHeldProjectionRuleResources(
            location: DisposalExecutableRelativeResourceRoot.resolveFrozen(),
            embedded: embedded)
    }

    private init(
        location: DisposalExecutableRelativeResourceLocation,
        embedded: DisposalProjectionRuleResources
    ) throws {
        try DisposalProjectionEmbeddedResources.validate(embedded)
        self.location = location

        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(location.closureParentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "RULE_CLOSURE_PARENT_REALPATH",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourcePath(resolvedParent) == location.closureParentPath,
            "RULE_CLOSURE_PARENT_ALIAS")
        var namedParent = stat()
        guard lstat(location.closureParentPath, &namedParent) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_CLOSURE_PARENT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        let openedParent = Darwin.open(
            location.closureParentPath,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard openedParent >= 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_CLOSURE_PARENT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var openedClosure: Int32 = -1
        var openedResourceRoot: Int32 = -1
        var capturedExecutable: HeldFile?
        var capturedResources: [String: HeldFile] = [:]
        var retainDescriptors = false
        defer {
            if !retainDescriptors {
                if let capturedExecutable {
                    _ = Darwin.close(capturedExecutable.descriptor)
                }
                for held in capturedResources.values {
                    _ = Darwin.close(held.descriptor)
                }
                if openedResourceRoot >= 0 { _ = Darwin.close(openedResourceRoot) }
                if openedClosure >= 0 { _ = Darwin.close(openedClosure) }
                _ = Darwin.close(openedParent)
            }
        }

        var parentState = stat()
        guard fstat(openedParent, &parentState) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_CLOSURE_PARENT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameIdentity(namedParent, parentState) &&
                (parentState.st_mode & S_IFMT) == S_IFDIR &&
                (parentState.st_mode & 0o7777) == 0o1777 &&
                parentState.st_uid == 0 && parentState.st_gid == 0,
            "RULE_CLOSURE_PARENT_POLICY")

        var namedClosure = stat()
        guard fstatat(
            openedParent,
            location.closureRootLeaf,
            &namedClosure,
            AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RULE_CLOSURE_ROOT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        openedClosure = location.closureRootLeaf.withCString {
            disposal_projection_openat_directory_no_follow(openedParent, $0)
        }
        guard openedClosure >= 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_CLOSURE_ROOT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var closureState = stat()
        guard fstat(openedClosure, &closureState) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_CLOSURE_ROOT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        let closureInventory = [location.executableLeaf, location.resourceRootLeaf].sorted()
        let observedClosureInventory = try disposalRuleResourceDirectoryEntries(
            openedClosure).sorted()
        // The pinned APFS substrate reports a directory link count of two plus
        // its complete immediate-entry inventory, including regular files.
        try disposalRequireProjection(
            disposalRuleResourceSameState(namedClosure, closureState) &&
                (closureState.st_mode & S_IFMT) == S_IFDIR &&
                (closureState.st_mode & 0o7777) == 0o500 &&
                closureState.st_uid == geteuid() && closureState.st_gid == getegid() &&
                closureState.st_nlink == nlink_t(2 + closureInventory.count) &&
                observedClosureInventory == closureInventory,
            "RULE_CLOSURE_ROOT_POLICY")

        capturedExecutable = try Self.captureFile(
            parentDescriptor: openedClosure,
            leaf: location.executableLeaf,
            expectedMode: 0o500,
            maximumBytes: Self.maximumExecutableBytes,
            expectedBytes: nil)

        var namedResourceRoot = stat()
        guard fstatat(
            openedClosure,
            location.resourceRootLeaf,
            &namedResourceRoot,
            AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_ROOT_LSTAT",
                detail: String(cString: strerror(errno)))
        }
        openedResourceRoot = location.resourceRootLeaf.withCString {
            disposal_projection_openat_directory_no_follow(openedClosure, $0)
        }
        guard openedResourceRoot >= 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_ROOT_OPEN",
                detail: String(cString: strerror(errno)))
        }
        var resourceRootState = stat()
        guard fstat(openedResourceRoot, &resourceRootState) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_RESOURCE_ROOT_FSTAT",
                detail: String(cString: strerror(errno)))
        }
        let specifications = DisposalProjectionEmbeddedResources.specifications
        let expectedInventory = specifications.map(\.leaf).sorted()
        let observedResourceInventory = try disposalRuleResourceDirectoryEntries(
            openedResourceRoot).sorted()
        try disposalRequireProjection(
            disposalRuleResourceSameState(namedResourceRoot, resourceRootState) &&
                (resourceRootState.st_mode & S_IFMT) == S_IFDIR &&
                (resourceRootState.st_mode & 0o7777) == 0o500 &&
                resourceRootState.st_uid == geteuid() &&
                resourceRootState.st_gid == getegid() &&
                resourceRootState.st_nlink == nlink_t(2 + specifications.count) &&
                observedResourceInventory == expectedInventory,
            "RULE_RESOURCE_ROOT_POLICY")

        let embeddedValues = embedded.orderedValues()
        for (specification, expectedBytes) in zip(specifications, embeddedValues) {
            let held = try Self.captureFile(
                parentDescriptor: openedResourceRoot,
                leaf: specification.leaf,
                expectedMode: 0o400,
                maximumBytes: specification.bytes,
                expectedBytes: expectedBytes)
            // Transfer descriptor ownership before any subsequent throwing check.
            capturedResources[specification.leaf] = held
            try disposalRequireProjection(
                held.bytes.count == specification.bytes &&
                    held.sha256 == specification.sha256,
                "RULE_RESOURCE_EXTERNAL_EMBEDDED_JOIN",
                detail: specification.leaf)
        }
        guard let capturedExecutable else {
            throw DisposalProjectionRejection(code: "RULE_EXECUTABLE_CAPTURE_ABSENT")
        }

        parentDescriptor = openedParent
        closureDescriptor = openedClosure
        resourceRootDescriptor = openedResourceRoot
        admittedParentState = parentState
        admittedClosureState = closureState
        admittedResourceRootState = resourceRootState
        heldExecutable = capturedExecutable
        heldResourceLeaves = capturedResources
        resources = embedded
        executableSHA256 = capturedExecutable.sha256
        try revalidate()
        retainDescriptors = true
    }

    deinit {
        _ = Darwin.close(heldExecutable.descriptor)
        for held in heldResourceLeaves.values { _ = Darwin.close(held.descriptor) }
        _ = Darwin.close(resourceRootDescriptor)
        _ = Darwin.close(closureDescriptor)
        _ = Darwin.close(parentDescriptor)
    }

    func revalidate() throws {
        let freshLocation = try DisposalExecutableRelativeResourceRoot.resolveFrozen()
        try disposalRequireProjection(
            freshLocation == location,
            "RULE_EXECUTABLE_RELATIVE_LOCATION_DRIFT")
        try revalidateParent()
        try revalidateDirectory(
            descriptor: closureDescriptor,
            admittedState: admittedClosureState,
            parentDescriptor: parentDescriptor,
            leaf: location.closureRootLeaf,
            expectedMode: 0o500,
            expectedInventory: [location.executableLeaf, location.resourceRootLeaf])
        try Self.revalidateFile(
            heldExecutable,
            parentDescriptor: closureDescriptor,
            leaf: location.executableLeaf)
        try revalidateDirectory(
            descriptor: resourceRootDescriptor,
            admittedState: admittedResourceRootState,
            parentDescriptor: closureDescriptor,
            leaf: location.resourceRootLeaf,
            expectedMode: 0o500,
            expectedInventory: DisposalProjectionEmbeddedResources.specifications.map(\.leaf))

        let freshEmbedded = try DisposalProjectionEmbeddedResources.exact()
        try disposalRequireProjection(
            freshEmbedded.orderedValues() == resources.orderedValues(),
            "RULE_EMBEDDED_RESOURCE_DRIFT")
        for (specification, embeddedBytes) in zip(
            DisposalProjectionEmbeddedResources.specifications,
            resources.orderedValues())
        {
            guard let held = heldResourceLeaves[specification.leaf] else {
                throw DisposalProjectionRejection(
                    code: "RULE_RESOURCE_HELD_LEAF_ABSENT",
                    detail: specification.leaf)
            }
            try Self.revalidateFile(
                held,
                parentDescriptor: resourceRootDescriptor,
                leaf: specification.leaf)
            try disposalRequireProjection(
                held.bytes == embeddedBytes && held.sha256 == specification.sha256,
                "RULE_RESOURCE_REVALIDATED_EMBEDDED_JOIN",
                detail: specification.leaf)
        }
        try revalidateDirectory(
            descriptor: resourceRootDescriptor,
            admittedState: admittedResourceRootState,
            parentDescriptor: closureDescriptor,
            leaf: location.resourceRootLeaf,
            expectedMode: 0o500,
            expectedInventory: DisposalProjectionEmbeddedResources.specifications.map(\.leaf))
        try revalidateDirectory(
            descriptor: closureDescriptor,
            admittedState: admittedClosureState,
            parentDescriptor: parentDescriptor,
            leaf: location.closureRootLeaf,
            expectedMode: 0o500,
            expectedInventory: [location.executableLeaf, location.resourceRootLeaf])
        try revalidateParent()
    }

    private func revalidateParent() throws {
        var resolvedParent = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(location.closureParentPath, &resolvedParent) != nil else {
            throw DisposalProjectionRejection(
                code: "RULE_CLOSURE_PARENT_REALPATH_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourcePath(resolvedParent) == location.closureParentPath,
            "RULE_CLOSURE_PARENT_ALIAS_DRIFT")
        var held = stat()
        var named = stat()
        guard fstat(parentDescriptor, &held) == 0,
              lstat(location.closureParentPath, &named) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RULE_CLOSURE_PARENT_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameIdentity(admittedParentState, held) &&
                disposalRuleResourceSameIdentity(held, named),
            "RULE_CLOSURE_PARENT_REBOUND")
    }

    private func revalidateDirectory(
        descriptor: Int32,
        admittedState: stat,
        parentDescriptor: Int32,
        leaf: String,
        expectedMode: mode_t,
        expectedInventory: [String]
    ) throws {
        var held = stat()
        var named = stat()
        guard fstat(descriptor, &held) == 0,
              fstatat(parentDescriptor, leaf, &named, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RULE_DIRECTORY_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        let inventory = try disposalRuleResourceDirectoryEntries(descriptor).sorted()
        try disposalRequireProjection(
            disposalRuleResourceSameState(admittedState, held) &&
                disposalRuleResourceSameState(held, named) &&
                (held.st_mode & S_IFMT) == S_IFDIR &&
                (held.st_mode & 0o7777) == expectedMode &&
                inventory == expectedInventory.sorted(),
            "RULE_DIRECTORY_DRIFT",
            detail: leaf)
    }

    private static func captureFile(
        parentDescriptor: Int32,
        leaf: String,
        expectedMode: mode_t,
        maximumBytes: Int,
        expectedBytes: Data?
    ) throws -> HeldFile {
        var namedBefore = stat()
        guard fstatat(parentDescriptor, leaf, &namedBefore, AT_SYMLINK_NOFOLLOW) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_FILE_LSTAT",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        let descriptor = leaf.withCString {
            disposal_projection_openat_readonly_no_follow(parentDescriptor, $0)
        }
        guard descriptor >= 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_FILE_OPEN",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        var retainDescriptor = false
        defer { if !retainDescriptor { _ = Darwin.close(descriptor) } }
        var before = stat()
        guard fstat(descriptor, &before) == 0 else {
            throw DisposalProjectionRejection(
                code: "RULE_FILE_FSTAT",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameState(namedBefore, before) &&
                (before.st_mode & S_IFMT) == S_IFREG &&
                (before.st_mode & 0o7777) == expectedMode &&
                before.st_uid == geteuid() && before.st_gid == getegid() &&
                before.st_nlink == 1 && before.st_size > 0 &&
                before.st_size <= off_t(maximumBytes),
            "RULE_FILE_POLICY",
            detail: leaf)
        let bytes = try disposalRuleResourcePread(
            descriptor: descriptor,
            count: Int(before.st_size),
            leaf: leaf)
        var after = stat()
        var namedAfter = stat()
        guard fstat(descriptor, &after) == 0,
              fstatat(parentDescriptor, leaf, &namedAfter, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RULE_FILE_CAPTURE_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameState(before, after) &&
                disposalRuleResourceSameState(after, namedAfter) &&
                expectedBytes.map { $0 == bytes } ?? true,
            "RULE_FILE_CAPTURE_DRIFT",
            detail: leaf)
        retainDescriptor = true
        return .init(
            descriptor: descriptor,
            admittedState: after,
            bytes: bytes,
            sha256: disposalSHA256(bytes))
    }

    private static func revalidateFile(
        _ heldFile: HeldFile,
        parentDescriptor: Int32,
        leaf: String
    ) throws {
        var before = stat()
        var namedBefore = stat()
        guard fstat(heldFile.descriptor, &before) == 0,
              fstatat(parentDescriptor, leaf, &namedBefore, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RULE_FILE_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameState(heldFile.admittedState, before) &&
                disposalRuleResourceSameState(before, namedBefore),
            "RULE_FILE_DRIFT",
            detail: leaf)
        let fresh = try disposalRuleResourcePread(
            descriptor: heldFile.descriptor,
            count: heldFile.bytes.count,
            leaf: leaf)
        var after = stat()
        var namedAfter = stat()
        guard fstat(heldFile.descriptor, &after) == 0,
              fstatat(parentDescriptor, leaf, &namedAfter, AT_SYMLINK_NOFOLLOW) == 0
        else {
            throw DisposalProjectionRejection(
                code: "RULE_FILE_POSTREAD_REVALIDATE",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalRuleResourceSameState(before, after) &&
                disposalRuleResourceSameState(after, namedAfter) &&
                fresh == heldFile.bytes && disposalSHA256(fresh) == heldFile.sha256,
            "RULE_FILE_POSTREAD_DRIFT",
            detail: leaf)
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
                code: "RULE_FILE_PREAD",
                detail: leaf + ":" + String(cString: strerror(errno)))
        }
    }
    return data
}

private func disposalRuleResourceDirectoryEntries(_ descriptor: Int32) throws -> [String] {
    let copied = dup(descriptor)
    guard copied >= 0 else {
        throw DisposalProjectionRejection(
            code: "RULE_DIRECTORY_DUP",
            detail: String(cString: strerror(errno)))
    }
    guard let directory = fdopendir(copied) else {
        _ = Darwin.close(copied)
        throw DisposalProjectionRejection(
            code: "RULE_DIRECTORY_FDOPENDIR",
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
            code: "RULE_DIRECTORY_READDIR",
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
