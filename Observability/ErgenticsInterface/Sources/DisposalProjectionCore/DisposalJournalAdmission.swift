import Darwin
import Foundation

public enum DisposalJournalAdmission {
    public static func readExact(
        path: String,
        expectedSHA256: String
    ) throws -> Data {
        try disposalRequireProjection(path.hasPrefix("/"), "JOURNAL_PATH_NOT_ABSOLUTE")
        try disposalRequireProjection(
            disposalIsLowerHex(expectedSHA256, count: 64),
            "JOURNAL_EXPECTED_SHA256")
        var resolved = [CChar](repeating: 0, count: Int(PATH_MAX))
        guard realpath(path, &resolved) != nil else {
            throw DisposalProjectionRejection(
                code: "JOURNAL_REALPATH",
                detail: String(cString: strerror(errno)))
        }
        let resolvedPath = String(
            decoding: resolved.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) },
            as: UTF8.self)
        try disposalRequireProjection(resolvedPath == path, "JOURNAL_PATH_ALIAS")

        var namedBefore = stat()
        guard lstat(path, &namedBefore) == 0 else {
            throw DisposalProjectionRejection(
                code: "JOURNAL_LSTAT_BEFORE",
                detail: String(cString: strerror(errno)))
        }
        let descriptor = Darwin.open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY)
        guard descriptor >= 0 else {
            throw DisposalProjectionRejection(
                code: "JOURNAL_OPEN",
                detail: String(cString: strerror(errno)))
        }
        defer { _ = Darwin.close(descriptor) }
        var heldBefore = stat()
        guard fstat(descriptor, &heldBefore) == 0 else {
            throw DisposalProjectionRejection(
                code: "JOURNAL_FSTAT_BEFORE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalAdmissionSameState(namedBefore, heldBefore),
            "JOURNAL_NAMED_HELD_JOIN_BEFORE")
        try disposalRequireProjection((heldBefore.st_mode & S_IFMT) == S_IFREG, "JOURNAL_TYPE")
        try disposalRequireProjection(heldBefore.st_nlink == 1, "JOURNAL_LINK_COUNT")
        try disposalRequireProjection(heldBefore.st_uid == geteuid(), "JOURNAL_OWNER")
        try disposalRequireProjection(
            heldBefore.st_size > 0 &&
                heldBefore.st_size <= off_t(DisposalEventJournal.maximumSourceBytes),
            "JOURNAL_SIZE")

        let data = try disposalAdmissionPread(
            descriptor: descriptor,
            count: Int(heldBefore.st_size))
        try disposalRequireProjection(
            disposalSHA256(data) == expectedSHA256,
            "JOURNAL_SHA256")

        var heldAfter = stat()
        var namedAfter = stat()
        guard fstat(descriptor, &heldAfter) == 0,
              lstat(path, &namedAfter) == 0
        else {
            throw DisposalProjectionRejection(
                code: "JOURNAL_REVALIDATE",
                detail: String(cString: strerror(errno)))
        }
        try disposalRequireProjection(
            disposalAdmissionSameState(heldBefore, heldAfter),
            "JOURNAL_HELD_DRIFT")
        try disposalRequireProjection(
            disposalAdmissionSameState(heldAfter, namedAfter),
            "JOURNAL_NAMED_HELD_JOIN_AFTER")
        return data
    }
}

private func disposalAdmissionPread(descriptor: Int32, count: Int) throws -> Data {
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
                code: "JOURNAL_PREAD",
                detail: String(cString: strerror(errno)))
        }
    }
    return data
}

private func disposalAdmissionSameState(_ lhs: stat, _ rhs: stat) -> Bool {
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
