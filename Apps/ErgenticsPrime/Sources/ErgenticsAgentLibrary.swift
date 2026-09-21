import CryptoKit
import Darwin
import Foundation

public struct ErgenticsAgentProfile: Identifiable, Sendable, Equatable, Codable {
    public let id: String
    public let version: String
    public let name: String
    public let purpose: String
    public let instructionPaths: [String]
    public let skillPaths: [String]
    public let defaultLessonIDs: [String]

    public init(id: String, version: String, name: String, purpose: String,
                instructionPaths: [String], skillPaths: [String], defaultLessonIDs: [String]) {
        self.id = id
        self.version = version
        self.name = name
        self.purpose = purpose
        self.instructionPaths = instructionPaths
        self.skillPaths = skillPaths
        self.defaultLessonIDs = defaultLessonIDs
    }
}

public struct ErgenticsAgentLesson: Identifiable, Sendable, Equatable, Codable {
    public let id: String
    public let version: String
    public let name: String
    public let path: String
    public let kind: String
    public let profileIDs: [String]

    public init(id: String, version: String, name: String, path: String,
                kind: String, profileIDs: [String]) {
        self.id = id
        self.version = version
        self.name = name
        self.path = path
        self.kind = kind
        self.profileIDs = profileIDs
    }
}

public enum ErgenticsAgentLibraryError: Error, Equatable, LocalizedError, Sendable {
    case invalidRoot
    case invalidCatalog(String)
    case catalogHashMismatch
    case unsupportedCatalog
    case invalidResourcePath(String)
    case invalidResource(String)
    case duplicate(String)
    case missingResource(String)
    case invalidUTF8(String)
    case unknownProfile(String)
    case unknownLesson(String)
    case wrongProfileLesson(String)
    case tooManyLessons
    case invalidTask
    case invalidRequestedModel
    case outputTooLarge
    case fileReadFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidRoot: return "The catalog root is not a safe directory."
        case .invalidCatalog(let detail): return "The agent catalog is invalid: \(detail)."
        case .catalogHashMismatch: return "The agent catalog hash does not match the expected identity."
        case .unsupportedCatalog: return "The agent catalog schema or version is unsupported."
        case .invalidResourcePath(let path): return "The resource path is invalid: \(path)."
        case .invalidResource(let path): return "The resource is invalid: \(path)."
        case .duplicate(let value): return "The catalog contains a duplicate: \(value)."
        case .missingResource(let path): return "The catalog references a missing resource: \(path)."
        case .invalidUTF8(let path): return "The resource is not valid UTF-8: \(path)."
        case .unknownProfile(let id): return "The requested profile is unknown: \(id)."
        case .unknownLesson(let id): return "The requested lesson is unknown: \(id)."
        case .wrongProfileLesson(let id): return "The lesson is not eligible for the selected profile: \(id)."
        case .tooManyLessons: return "The prepared task selects more than eight lessons."
        case .invalidTask: return "The task is blank or exceeds its UTF-8 limit."
        case .invalidRequestedModel: return "The requested model is blank or exceeds its UTF-8 limit."
        case .outputTooLarge: return "The prepared task is larger than the output limit."
        case .fileReadFailed(let path): return "The resource could not be safely read: \(path)."
        }
    }
}

public struct ErgenticsAgentLibrary: Sendable {
    public let version: String
    public let owner: String
    public let sourceCommit: String
    public let profiles: [ErgenticsAgentProfile]
    public let lessons: [ErgenticsAgentLesson]

    private let catalogSHA256: String
    private let resourceIdentities: [String: ResourceIdentity]
    private let resourceBytes: [String: Data]
    private let profileRecords: [String: ProfileRecord]
    private let lessonRecords: [String: LessonRecord]

    private static let catalogSchema = "ergentics.hypervisor-agent-catalog.v1"
    private static let catalogVersion = "0.1.0"
    private static let stableProfiles: Set<String> = ["ergentics_swift_c", "ergentics_cpp"]
    private static let catalogLimit = 128 * 1024
    private static let resourceLimit = 256 * 1024
    private static let resourceCountLimit = 64
    private static let resourceTotalLimit = 1024 * 1024
    private static let lessonLimit = 16
    private static let selectedLessonLimit = 8
    private static let taskLimit = 8192
    private static let modelLimit = 128
    private static let outputLimit = 1024 * 1024

    private struct ResourceRecord: Decodable {
        let path: String
        let bytes: Int
        let sha256: String
    }

    private struct ProfileRecord: Decodable {
        let id: String
        let version: String
        let name: String
        let purpose: String
        let instructionPaths: [String]
        let skillPaths: [String]
        let defaultLessonIDs: [String]
    }

    private struct LessonRecord: Decodable {
        let id: String
        let version: String
        let name: String
        let path: String
        let kind: String
        let profileIDs: [String]
    }

    private struct Catalog: Decodable {
        let schema: String
        let version: String
        let owner: String
        let sourceCommit: String
        let resources: [ResourceRecord]
        let profiles: [ProfileRecord]
        let lessons: [LessonRecord]
    }

    private struct ResourceIdentity: Encodable, Sendable {
        let path: String
        let bytes: Int
        let sha256: String
    }

    private struct PreparedResource: Encodable {
        let path: String
        let bytes: Int
        let sha256: String
        let text: String
    }

    private struct PreparedLesson: Encodable {
        let id: String
        let version: String
        let name: String
        let path: String
        let kind: String
        let profileIDs: [String]
        let text: String
    }

    private struct PreparedTask: Encodable {
        let schema: String
        let taskID: String
        let catalog: CatalogIdentity
        let profile: ErgenticsAgentProfile
        let resources: [ResourceIdentity]
        let instructions: [PreparedResource]
        let skills: [PreparedResource]
        let lessons: [PreparedLesson]
        let task: String
        let requested: RequestedSettings
        let execution: ExecutionState
    }

    private struct CatalogIdentity: Encodable {
        let schema: String
        let version: String
        let sourceCommit: String
        let sha256: String
    }

    private struct RequestedSettings: Encodable {
        let model: String
    }

    private struct ExecutionState: Encodable {
        let preparation: String
        let modelDispatch: String
        let modelContextIngestion: String
        let nativeExecution: String
    }

    private init(catalog: Catalog, catalogSHA256: String,
                 identities: [String: ResourceIdentity], bytes: [String: Data]) {
        self.version = catalog.version
        self.owner = catalog.owner
        self.sourceCommit = catalog.sourceCommit
        self.profiles = catalog.profiles.map {
            ErgenticsAgentProfile(id: $0.id, version: $0.version, name: $0.name,
                                  purpose: $0.purpose, instructionPaths: $0.instructionPaths,
                                  skillPaths: $0.skillPaths, defaultLessonIDs: $0.defaultLessonIDs)
        }
        self.lessons = catalog.lessons.map {
            ErgenticsAgentLesson(id: $0.id, version: $0.version, name: $0.name,
                                 path: $0.path, kind: $0.kind, profileIDs: $0.profileIDs)
        }
        self.catalogSHA256 = catalogSHA256
        self.resourceIdentities = identities
        self.resourceBytes = bytes
        self.profileRecords = Dictionary(uniqueKeysWithValues: catalog.profiles.map { ($0.id, $0) })
        self.lessonRecords = Dictionary(uniqueKeysWithValues: catalog.lessons.map { ($0.id, $0) })
    }

    public static func load(root: URL, expectedCatalogSHA256: String) throws -> Self {
        guard root.isFileURL else { throw ErgenticsAgentLibraryError.invalidRoot }
        guard isSHA256(expectedCatalogSHA256) else { throw ErgenticsAgentLibraryError.catalogHashMismatch }
        let rootFD = try openDirectory(root)
        defer { _ = Darwin.close(rootFD) }

        let catalogData = try readFile(path: "catalog.json", rootFD: rootFD, limit: catalogLimit)
        let catalogDigest = sha256(catalogData)
        guard catalogDigest == expectedCatalogSHA256 else { throw ErgenticsAgentLibraryError.catalogHashMismatch }
        let catalog: Catalog
        do {
            catalog = try JSONDecoder().decode(Catalog.self, from: catalogData)
        } catch {
            throw ErgenticsAgentLibraryError.invalidCatalog("JSON decoding failed")
        }
        try validate(catalog)

        var identities: [String: ResourceIdentity] = [:]
        var bytesByPath: [String: Data] = [:]
        for resource in catalog.resources {
            let data = try readFile(path: resource.path, rootFD: rootFD, limit: resourceLimit)
            guard data.count == resource.bytes, sha256(data) == resource.sha256 else {
                throw ErgenticsAgentLibraryError.invalidResource(resource.path)
            }
            guard String(data: data, encoding: .utf8) != nil else {
                throw ErgenticsAgentLibraryError.invalidUTF8(resource.path)
            }
            identities[resource.path] = ResourceIdentity(path: resource.path, bytes: resource.bytes, sha256: resource.sha256)
            bytesByPath[resource.path] = data
        }
        return Self(catalog: catalog, catalogSHA256: catalogDigest, identities: identities, bytes: bytesByPath)
    }

    public func text(at path: String) throws -> String {
        guard let data = resourceBytes[path] else { throw ErgenticsAgentLibraryError.missingResource(path) }
        guard let text = String(data: data, encoding: .utf8) else {
            throw ErgenticsAgentLibraryError.invalidUTF8(path)
        }
        return text
    }

    public func prepareTask(profileID: String, task: String, lessonIDs: [String],
                            requestedModel: String) throws -> Data {
        guard let profile = profileRecords[profileID] else {
            throw ErgenticsAgentLibraryError.unknownProfile(profileID)
        }
        guard Self.validTask(task, limit: Self.taskLimit) else { throw ErgenticsAgentLibraryError.invalidTask }
        guard Self.validTask(requestedModel, limit: Self.modelLimit) else {
            throw ErgenticsAgentLibraryError.invalidRequestedModel
        }
        guard lessonIDs.count <= Self.selectedLessonLimit else { throw ErgenticsAgentLibraryError.tooManyLessons }
        guard Set(lessonIDs).count == lessonIDs.count else { throw ErgenticsAgentLibraryError.duplicate("selected lesson") }

        let selectedLessons = try lessonIDs.map { id -> LessonRecord in
            guard let lesson = lessonRecords[id] else { throw ErgenticsAgentLibraryError.unknownLesson(id) }
            guard lesson.profileIDs.contains(profileID) else { throw ErgenticsAgentLibraryError.wrongProfileLesson(id) }
            return lesson
        }
        let instructions = try profile.instructionPaths.map { try preparedResource(path: $0) }
        let skills = try profile.skillPaths.map { try preparedResource(path: $0) }
        let lessonPayloads = try selectedLessons.map {
            PreparedLesson(id: $0.id, version: $0.version, name: $0.name, path: $0.path,
                           kind: $0.kind, profileIDs: $0.profileIDs, text: try text(at: $0.path))
        }
        let selectedPaths = Self.unique(instructions.map(\.path) + skills.map(\.path) + lessonPayloads.map(\.path))
        let resources = selectedPaths.compactMap { resourceIdentities[$0] }
        let prepared = PreparedTask(
            schema: "ergentics.hypervisor-agent-task.v1",
            taskID: UUID().uuidString.lowercased(),
            catalog: CatalogIdentity(schema: Self.catalogSchema, version: version,
                                     sourceCommit: sourceCommit, sha256: catalogSHA256),
            profile: ErgenticsAgentProfile(id: profile.id, version: profile.version, name: profile.name,
                                           purpose: profile.purpose, instructionPaths: profile.instructionPaths,
                                           skillPaths: profile.skillPaths, defaultLessonIDs: profile.defaultLessonIDs),
            resources: resources,
            instructions: instructions,
            skills: skills,
            lessons: lessonPayloads,
            task: task,
            requested: RequestedSettings(model: requestedModel),
            execution: ExecutionState(preparation: "prepared", modelDispatch: "NOT_PERFORMED",
                                      modelContextIngestion: "NOT_OBSERVED", nativeExecution: "NOT_PERFORMED")
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let output = try encoder.encode(prepared)
        guard output.count <= Self.outputLimit else { throw ErgenticsAgentLibraryError.outputTooLarge }
        return output
    }

    private func preparedResource(path: String) throws -> PreparedResource {
        guard let identity = resourceIdentities[path] else {
            throw ErgenticsAgentLibraryError.missingResource(path)
        }
        return PreparedResource(path: identity.path, bytes: identity.bytes, sha256: identity.sha256,
                                text: try text(at: path))
    }

    private static func validate(_ catalog: Catalog) throws {
        guard catalog.schema == catalogSchema, catalog.version == catalogVersion else {
            throw ErgenticsAgentLibraryError.unsupportedCatalog
        }
        guard !catalog.owner.isEmpty, !catalog.sourceCommit.isEmpty else {
            throw ErgenticsAgentLibraryError.invalidCatalog("missing identity")
        }
        guard catalog.resources.count <= resourceCountLimit,
              catalog.lessons.count <= lessonLimit,
              Set(catalog.profiles.map(\.id)) == stableProfiles,
              catalog.profiles.count == stableProfiles.count else {
            throw ErgenticsAgentLibraryError.invalidCatalog("catalog limits or stable profiles")
        }
        let resourcePaths = try uniquePaths(catalog.resources.map(\.path))
        var resourceTotal = 0
        for resource in catalog.resources {
            try validatePath(resource.path)
            guard resource.bytes >= 0 && resource.bytes <= resourceLimit,
                  isSHA256(resource.sha256) else { throw ErgenticsAgentLibraryError.invalidResource(resource.path) }
            guard resourceTotal <= resourceTotalLimit - resource.bytes else {
                throw ErgenticsAgentLibraryError.invalidCatalog("resource total")
            }
            resourceTotal += resource.bytes
        }
        let profileIDs = Set(catalog.profiles.map(\.id))
        for profile in catalog.profiles {
            guard !profile.version.isEmpty, !profile.name.isEmpty, !profile.purpose.isEmpty else {
                throw ErgenticsAgentLibraryError.invalidCatalog("profile identity")
            }
            _ = try uniquePaths(profile.instructionPaths)
            _ = try uniquePaths(profile.skillPaths)
            try uniqueIDs(profile.defaultLessonIDs, label: "default lesson")
            for path in profile.instructionPaths + profile.skillPaths {
                guard resourcePaths.contains(path) else { throw ErgenticsAgentLibraryError.missingResource(path) }
            }
        }
        try uniqueIDs(catalog.lessons.map(\.id), label: "lesson")
        let lessonIDs = Set(catalog.lessons.map(\.id))
        for lesson in catalog.lessons {
            try validatePath(lesson.path)
            guard resourcePaths.contains(lesson.path), !lesson.version.isEmpty, !lesson.name.isEmpty,
                  !lesson.kind.isEmpty, !lesson.profileIDs.isEmpty else {
                throw ErgenticsAgentLibraryError.invalidCatalog("lesson \(lesson.id)")
            }
            try uniqueIDs(lesson.profileIDs, label: "lesson profile")
            guard Set(lesson.profileIDs).isSubset(of: profileIDs) else {
                throw ErgenticsAgentLibraryError.invalidCatalog("lesson profile scope")
            }
        }
        for profile in catalog.profiles {
            for lessonID in profile.defaultLessonIDs {
                guard lessonIDs.contains(lessonID), catalog.lessons.first(where: { $0.id == lessonID })?.profileIDs.contains(profile.id) == true else {
                    throw ErgenticsAgentLibraryError.invalidCatalog("default lesson \(lessonID)")
                }
            }
        }
    }

    private static func uniquePaths(_ paths: [String]) throws -> Set<String> {
        for path in paths { try validatePath(path) }
        let values = Set(paths)
        guard values.count == paths.count else { throw ErgenticsAgentLibraryError.duplicate("resource path") }
        return values
    }

    private static func uniqueIDs(_ ids: [String], label: String) throws {
        guard Set(ids).count == ids.count else { throw ErgenticsAgentLibraryError.duplicate(label) }
        guard ids.allSatisfy({ !$0.isEmpty && $0.utf8.count <= 128 }) else {
            throw ErgenticsAgentLibraryError.invalidCatalog(label)
        }
    }

    private static func validatePath(_ path: String) throws {
        guard !path.isEmpty, path.utf8.count <= 1024, !path.hasPrefix("/"), !path.contains("\\"),
              !path.utf8.contains(0) else {
            throw ErgenticsAgentLibraryError.invalidResourcePath(path)
        }
        let components = path.split(separator: "/", omittingEmptySubsequences: false)
        guard components.count <= 64,
              !components.contains(where: { $0.isEmpty || $0 == "." || $0 == ".." }) else {
            throw ErgenticsAgentLibraryError.invalidResourcePath(path)
        }
    }

    private static func validTask(_ value: String, limit: Int) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && value.utf8.count <= limit
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    private static func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }

    private static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static func openDirectory(_ url: URL) throws -> Int32 {
        let fd = Darwin.open(url.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard fd >= 0 else { throw ErgenticsAgentLibraryError.invalidRoot }
        var info = stat()
        guard fstat(fd, &info) == 0, info.st_mode & S_IFMT == S_IFDIR else {
            _ = Darwin.close(fd); throw ErgenticsAgentLibraryError.invalidRoot
        }
        return fd
    }

    private static func readFile(path: String, rootFD: Int32, limit: Int) throws -> Data {
        let components = path.split(separator: "/").map(String.init)
        guard !components.isEmpty else { throw ErgenticsAgentLibraryError.invalidResourcePath(path) }
        var directory = rootFD
        var ownedDirectory: Int32?
        defer { if let ownedDirectory { _ = Darwin.close(ownedDirectory) } }
        for component in components.dropLast() {
            let next = component.withCString { Darwin.openat(directory, $0, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC) }
            guard next >= 0 else { throw ErgenticsAgentLibraryError.fileReadFailed(path) }
            if directory != rootFD { _ = Darwin.close(directory) }
            directory = next
            ownedDirectory = next
        }
        let leaf = components.last!
        let fd = leaf.withCString { Darwin.openat(directory, $0, O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK) }
        guard fd >= 0 else { throw ErgenticsAgentLibraryError.fileReadFailed(path) }
        defer { _ = Darwin.close(fd) }
        var before = stat()
        guard fstat(fd, &before) == 0, before.st_mode & S_IFMT == S_IFREG,
              before.st_size >= 0, before.st_size <= off_t(limit) else {
            throw ErgenticsAgentLibraryError.fileReadFailed(path)
        }
        var data = Data()
        data.reserveCapacity(Int(before.st_size))
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        while true {
            let count = buffer.withUnsafeMutableBytes { Darwin.read(fd, $0.baseAddress, $0.count) }
            if count < 0 && errno == EINTR { continue }
            guard count >= 0 else { throw ErgenticsAgentLibraryError.fileReadFailed(path) }
            if count == 0 { break }
            data.append(buffer, count: count)
            guard data.count <= limit else { throw ErgenticsAgentLibraryError.fileReadFailed(path) }
        }
        var after = stat()
        guard fstat(fd, &after) == 0, before.st_dev == after.st_dev, before.st_ino == after.st_ino,
              after.st_size == off_t(data.count) else {
            throw ErgenticsAgentLibraryError.fileReadFailed(path)
        }
        return data
    }
}
