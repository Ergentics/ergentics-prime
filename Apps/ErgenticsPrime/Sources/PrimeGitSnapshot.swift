import Foundation

/// A bounded, imported observation for display. Decoding does not open a repository,
/// run Git, refresh remotes, prove consistency, or close any Gate E authority.
struct PrimeGitSnapshot: Codable, Equatable, Sendable {
    static let schemaIdentifier = "com.ergentics.provenance.prime-git.snapshot.v1"
    static let maximumJSONBytes = 1_048_576
    static let maximumRemotes = 32
    static let maximumCount = 1_000_000_000

    enum HeadMode: String, Codable, Sendable { case branch, detached, unborn }
    enum Consistency: String, Codable, Sendable { case unchecked, stable, changed }

    struct ChangeCounts: Codable, Equatable, Sendable {
        let staged: Int?
        let unstaged: Int?
        let untracked: Int?

        init(from decoder: Decoder) throws {
            try SnapshotValidation.keys(decoder, allowed: ["staged", "unstaged", "untracked"])
            let values = try decoder.container(keyedBy: CodingKeys.self)
            staged = try values.decodeIfPresent(Int.self, forKey: .staged)
            unstaged = try values.decodeIfPresent(Int.self, forKey: .unstaged)
            untracked = try values.decodeIfPresent(Int.self, forKey: .untracked)
            try [staged, unstaged, untracked].forEach(SnapshotValidation.count)
        }
    }

    struct Remote: Codable, Equatable, Sendable {
        let name: String
        /// Display text only. User information, query, and fragment are discarded.
        /// This is not an assurance that a server/path contains no secret.
        let url: String?

        init(from decoder: Decoder) throws {
            try SnapshotValidation.keys(decoder, allowed: ["name", "url"])
            let values = try decoder.container(keyedBy: CodingKeys.self)
            name = try values.decode(String.self, forKey: .name)
            guard (1...128).contains(name.utf8.count), name != ".", name != "..",
                  name.utf8.allSatisfy({ (65...90).contains($0) || (97...122).contains($0)
                      || (48...57).contains($0) || [45, 46, 95].contains($0) }) else {
                throw PrimeGitSnapshotError("Invalid remote name")
            }
            url = try values.decodeIfPresent(String.self, forKey: .url)
                .map(SnapshotValidation.remoteURL)
        }
    }

    struct Upstream: Codable, Equatable, Sendable {
        let ref: String
        let commitOID: String?
        /// Local cached comparison supplied by the importer, never a network result
        /// recomputed or independently certified by this decoder. Nil means unknown.
        let ahead: Int?
        let behind: Int?

        init(from decoder: Decoder) throws {
            try SnapshotValidation.keys(decoder, allowed: ["ref", "commitOID", "ahead", "behind"])
            let values = try decoder.container(keyedBy: CodingKeys.self)
            ref = try values.decode(String.self, forKey: .ref)
            commitOID = try values.decodeIfPresent(String.self, forKey: .commitOID)
            ahead = try values.decodeIfPresent(Int.self, forKey: .ahead)
            behind = try values.decodeIfPresent(Int.self, forKey: .behind)
            guard ref.hasPrefix("refs/") else {
                throw PrimeGitSnapshotError("Upstream must name a full refs/ reference")
            }
            try SnapshotValidation.reference(ref)
            try SnapshotValidation.oid(commitOID)
            try SnapshotValidation.count(ahead)
            try SnapshotValidation.count(behind)
            guard (ahead == nil) == (behind == nil), ahead == nil || commitOID != nil else {
                throw PrimeGitSnapshotError("Comparison counts require a pair and cached upstream OID")
            }
        }
    }

    let schema: String
    /// An imported absolute path label, not a canonical or descriptor-held identity.
    let repositoryPath: String
    let observedAt: String
    let headMode: HeadMode
    let branch: String?
    let headOID: String?
    let changeCounts: ChangeCounts?
    let remotes: [Remote]
    let upstream: Upstream?
    /// Reported by the producer. Even `stable` is not verified by this importer.
    let consistency: Consistency

    var observedDate: Date { SnapshotValidation.timestamp(observedAt)! }
    var isChanged: Bool { consistency == .changed }

    static func decode(_ data: Data) throws -> PrimeGitSnapshot {
        guard !data.isEmpty, data.count <= maximumJSONBytes,
              String(data: data, encoding: .utf8) != nil else {
            throw PrimeGitSnapshotError("Snapshot must be nonempty UTF-8 JSON, at most 1 MiB")
        }
        try SnapshotValidation.jsonStructure(data)
        return try JSONDecoder().decode(Self.self, from: data)
    }

    init(from decoder: Decoder) throws {
        try SnapshotValidation.keys(decoder, allowed: ["schema", "repositoryPath", "observedAt",
            "headMode", "branch", "headOID", "changeCounts", "remotes", "upstream", "consistency"])
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schema = try values.decode(String.self, forKey: .schema)
        repositoryPath = try values.decode(String.self, forKey: .repositoryPath)
        observedAt = try values.decode(String.self, forKey: .observedAt)
        headMode = try values.decode(HeadMode.self, forKey: .headMode)
        branch = try values.decodeIfPresent(String.self, forKey: .branch)
        headOID = try values.decodeIfPresent(String.self, forKey: .headOID)
        changeCounts = try values.decodeIfPresent(ChangeCounts.self, forKey: .changeCounts)
        remotes = try values.decode([Remote].self, forKey: .remotes)
        upstream = try values.decodeIfPresent(Upstream.self, forKey: .upstream)
        consistency = try values.decode(Consistency.self, forKey: .consistency)

        guard schema == Self.schemaIdentifier else { throw PrimeGitSnapshotError("Unsupported snapshot schema") }
        try SnapshotValidation.repositoryPath(repositoryPath)
        guard SnapshotValidation.timestamp(observedAt) != nil else {
            throw PrimeGitSnapshotError("observedAt must be an ISO-8601 timestamp with explicit time zone")
        }
        try branch.map(SnapshotValidation.reference)
        try SnapshotValidation.oid(headOID)
        switch headMode {
        case .branch:
            guard branch != nil, headOID != nil else {
                throw PrimeGitSnapshotError("Branch HEAD requires branch and OID")
            }
        case .detached:
            guard branch == nil, headOID != nil else {
                throw PrimeGitSnapshotError("Detached HEAD requires OID and no branch")
            }
        case .unborn:
            guard branch != nil, headOID == nil, upstream == nil else {
                throw PrimeGitSnapshotError("Unborn HEAD requires branch, no OID, and no upstream comparison")
            }
        }
        guard remotes.count <= Self.maximumRemotes, Set(remotes.map(\.name)).count == remotes.count else {
            throw PrimeGitSnapshotError("Too many or duplicate remote names")
        }
        if let cached = upstream?.commitOID, let headOID, cached.utf8.count != headOID.utf8.count {
            throw PrimeGitSnapshotError("HEAD and upstream OIDs must use the same object format")
        }
        if upstream?.ahead != nil, headOID == nil {
            throw PrimeGitSnapshotError("Comparison requires a reported HEAD OID")
        }
        if let upstream, let cached = upstream.commitOID, let headOID,
           let ahead = upstream.ahead, let behind = upstream.behind {
            let sameObject = cached.lowercased() == headOID.lowercased()
            guard sameObject == (ahead == 0 && behind == 0) else {
                throw PrimeGitSnapshotError("Comparison counts contradict the reported object identities")
            }
            // A necessary identity invariant only—not a traversal of Git ancestry.
        }
    }
}

struct PrimeGitSnapshotError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

private enum SnapshotValidation {
    private struct Key: CodingKey {
        let stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }

    static func keys(_ decoder: Decoder, allowed: Set<String>) throws {
        let values = try decoder.container(keyedBy: Key.self)
        guard values.allKeys.allSatisfy({ allowed.contains($0.stringValue) }) else {
            throw PrimeGitSnapshotError("Unknown snapshot field")
        }
    }

    static func count(_ value: Int?) throws {
        guard value.map({ (0...PrimeGitSnapshot.maximumCount).contains($0) }) ?? true else {
            throw PrimeGitSnapshotError("Observation count is outside its nonnegative bound")
        }
    }

    static func oid(_ value: String?) throws {
        guard let value else { return }
        guard [40, 64].contains(value.utf8.count), value.utf8.allSatisfy({
            (48...57).contains($0) || (65...70).contains($0) || (97...102).contains($0)
        }), value.utf8.contains(where: { $0 != 48 }) else {
            throw PrimeGitSnapshotError("OID must be a nonzero 40- or 64-digit hexadecimal object ID")
        }
    }

    static func repositoryPath(_ value: String) throws {
        guard (2...4096).contains(value.utf8.count), value.hasPrefix("/"),
              !value.hasSuffix("/"), !value.contains("//"), noControls(value),
              value.split(separator: "/").allSatisfy({ $0 != "." && $0 != ".." }) else {
            throw PrimeGitSnapshotError("Repository path must be a bounded absolute path without dot components")
        }
    }

    static func reference(_ value: String) throws {
        guard (1...1024).contains(value.utf8.count), noControls(value), value != "@",
              !value.hasPrefix("-"), !value.hasPrefix("/"), !value.hasSuffix("/"),
              !value.hasSuffix("."), !value.contains("//"), !value.contains(".."), !value.contains("@{"),
              !value.contains(where: { " ~^:?*[\\".contains($0) }),
              value.split(separator: "/").allSatisfy({ !$0.hasPrefix(".") && !$0.hasSuffix(".lock") }) else {
            throw PrimeGitSnapshotError("Invalid branch or reference label")
        }
    }

    static func remoteURL(_ value: String) throws -> String {
        guard (1...4096).contains(value.utf8.count), noControls(value),
              var parts = URLComponents(string: value),
              let scheme = parts.scheme?.lowercased(), ["https", "http", "ssh", "git", "file"].contains(scheme) else {
            throw PrimeGitSnapshotError("Remote URL must use an explicit supported scheme or be omitted")
        }
        if scheme == "file" {
            guard (parts.host ?? "").isEmpty || parts.host == "localhost", parts.path.hasPrefix("/") else {
                throw PrimeGitSnapshotError("Invalid local remote URL")
            }
        } else if parts.host?.isEmpty != false {
            throw PrimeGitSnapshotError("Remote URL requires a host")
        }
        parts.scheme = scheme
        parts.user = nil
        parts.password = nil
        parts.query = nil
        parts.fragment = nil
        guard noControls(parts.path), let sanitized = parts.string, sanitized.utf8.count <= 4096 else {
            throw PrimeGitSnapshotError("Invalid sanitized remote URL")
        }
        return sanitized
    }

    static func timestamp(_ value: String) -> Date? {
        guard (20...35).contains(value.utf8.count),
              value.range(of: "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]{1,9})?(Z|[+-][0-9]{2}:[0-9]{2})$",
                          options: .regularExpression) != nil else { return nil }
        let bytes = Array(value.utf8)
        func number(_ range: Range<Int>) -> Int { Int(String(decoding: bytes[range], as: UTF8.self))! }
        let year = number(0..<4), month = number(5..<7), day = number(8..<10)
        guard year > 0, (1...12).contains(month), (0...23).contains(number(11..<13)),
              (0...59).contains(number(14..<16)), (0...59).contains(number(17..<19)) else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        guard let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let days = calendar.range(of: .day, in: .month, for: first), days.contains(day) else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = value.contains(".")
            ? [.withInternetDateTime, .withFractionalSeconds] : [.withInternetDateTime]
        return formatter.date(from: value)
    }

    private static func noControls(_ value: String) -> Bool {
        !value.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) })
    }

    /// Preflight rejects duplicate decoded keys and excessive nesting before
    /// Foundation's Codable parser. It is not a canonical-JSON representation.
    static func jsonStructure(_ data: Data) throws {
        struct Frame { let object: Bool; var expectingKey: Bool; var keys: Set<String> = [] }
        let bytes = Array(data)
        var stack: [Frame] = []
        var index = 0
        while index < bytes.count {
            switch bytes[index] {
            case 123, 91:
                guard stack.count < 16 else { throw PrimeGitSnapshotError("Snapshot nesting exceeds 16") }
                stack.append(Frame(object: bytes[index] == 123, expectingKey: bytes[index] == 123))
            case 125, 93:
                guard let frame = stack.popLast(), frame.object == (bytes[index] == 125) else {
                    throw PrimeGitSnapshotError("Unbalanced JSON structure")
                }
            case 44:
                if !stack.isEmpty { stack[stack.count - 1].expectingKey = stack.last!.object }
            case 34:
                let start = index
                index += 1
                var escaped = false
                while index < bytes.count {
                    if escaped { escaped = false }
                    else if bytes[index] == 92 { escaped = true }
                    else if bytes[index] == 34 { break }
                    index += 1
                }
                guard index < bytes.count else { throw PrimeGitSnapshotError("Unterminated JSON string") }
                if stack.last?.expectingKey == true {
                    guard index - start <= 1024 else { throw PrimeGitSnapshotError("JSON field name is too long") }
                    let key = try JSONDecoder().decode(String.self, from: Data(bytes[start...index]))
                    guard stack[stack.count - 1].keys.insert(key).inserted else {
                        throw PrimeGitSnapshotError("Duplicate JSON field")
                    }
                    stack[stack.count - 1].expectingKey = false
                }
            default: break
            }
            index += 1
        }
        guard stack.isEmpty else { throw PrimeGitSnapshotError("Unclosed JSON structure") }
    }
}
