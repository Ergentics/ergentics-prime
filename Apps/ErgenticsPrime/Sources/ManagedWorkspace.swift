import Foundation

/// A stable product-local label. It is not a filesystem identity, bookmark,
/// capability, repository digest, or authority token.
struct ManagedWorkspaceID: RawRepresentable, Hashable, Sendable {
    static let maximumUTF8Bytes = 64
    static let prime = ManagedWorkspaceID(unchecked: "prime")

    let rawValue: String

    init?(rawValue: String) {
        guard Self.isValid(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    private init(unchecked rawValue: String) { self.rawValue = rawValue }

    private static func isValid(_ value: String) -> Bool {
        let bytes = Array(value.utf8)
        guard !bytes.isEmpty, bytes.count <= maximumUTF8Bytes,
              let first = bytes.first, (97...122).contains(first),
              let last = bytes.last, (97...122).contains(last) || (48...57).contains(last) else {
            return false
        }
        return bytes.allSatisfy {
            (97...122).contains($0) || (48...57).contains($0) || $0 == 45 || $0 == 46
        }
    }
}

enum ManagedWorkspaceKind: String, Equatable, Hashable, Sendable {
    case git
}

enum ManagedWorkspaceSelectionPolicy: String, Equatable, Hashable, Sendable {
    /// Every filesystem use requires a new explicit user-selected read grant.
    /// The definition retains no path, bookmark, descriptor, or credential.
    case userSelectedReadOnly
}

enum ManagedWorkspaceRegistryError: Error, Equatable, CustomStringConvertible {
    case invalidOrdinal
    case invalidDisplayName
    case duplicateID
    case duplicateOrdinal
    case unorderedOrdinal
    case tooManyDefinitions
    case unknownWorkspace

    var description: String {
        switch self {
        case .invalidOrdinal: return "Workspace ordinal must be positive"
        case .invalidDisplayName: return "Workspace display name is invalid"
        case .duplicateID: return "Workspace identifier is duplicated"
        case .duplicateOrdinal: return "Workspace ordinal is duplicated"
        case .unorderedOrdinal: return "Workspace definitions are not in increasing ordinal order"
        case .tooManyDefinitions: return "Workspace registry exceeds its fixed bound"
        case .unknownWorkspace: return "Workspace is not present in this registry"
        }
    }
}

struct ManagedWorkspaceDefinition: Equatable, Hashable, Sendable {
    static let maximumDisplayNameUTF8Bytes = 128

    let id: ManagedWorkspaceID
    let ordinal: UInt16
    let displayName: String
    let kind: ManagedWorkspaceKind
    let selectionPolicy: ManagedWorkspaceSelectionPolicy

    init(id: ManagedWorkspaceID, ordinal: UInt16, displayName: String,
         kind: ManagedWorkspaceKind, selectionPolicy: ManagedWorkspaceSelectionPolicy) throws {
        guard ordinal > 0 else { throw ManagedWorkspaceRegistryError.invalidOrdinal }
        let bytes = displayName.utf8
        guard !bytes.isEmpty, bytes.count <= Self.maximumDisplayNameUTF8Bytes,
              displayName == displayName.trimmingCharacters(in: .whitespacesAndNewlines),
              Array(displayName.utf8) == Array(displayName.precomposedStringWithCanonicalMapping.utf8),
              !displayName.unicodeScalars.contains(where: {
                  CharacterSet.controlCharacters.contains($0) ||
                  CharacterSet.illegalCharacters.contains($0) ||
                  $0.properties.generalCategory == .format ||
                  $0.properties.generalCategory == .lineSeparator ||
                  $0.properties.generalCategory == .paragraphSeparator
              }) else {
            throw ManagedWorkspaceRegistryError.invalidDisplayName
        }
        self.id = id
        self.ordinal = ordinal
        self.displayName = displayName
        self.kind = kind
        self.selectionPolicy = selectionPolicy
    }
}

/// Immutable, bounded product configuration. It intentionally offers only
/// exact-ID lookup; selection never falls back to cwd, HOME, enumeration, or a
/// previously used path.
struct ManagedWorkspaceRegistry: Equatable, Sendable {
    static let maximumDefinitions = 64
    static let product: ManagedWorkspaceRegistry = {
        let prime = try! ManagedWorkspaceDefinition(
            id: .prime,
            ordinal: 1,
            displayName: "Prime",
            kind: .git,
            selectionPolicy: .userSelectedReadOnly
        )
        return try! ManagedWorkspaceRegistry(validating: [prime])
    }()

    private let orderedDefinitions: [ManagedWorkspaceDefinition]

    init(validating definitions: [ManagedWorkspaceDefinition]) throws {
        guard definitions.count <= Self.maximumDefinitions else {
            throw ManagedWorkspaceRegistryError.tooManyDefinitions
        }
        var ids = Set<ManagedWorkspaceID>()
        var ordinals = Set<UInt16>()
        var previous: UInt16?
        for definition in definitions {
            guard ids.insert(definition.id).inserted else {
                throw ManagedWorkspaceRegistryError.duplicateID
            }
            guard ordinals.insert(definition.ordinal).inserted else {
                throw ManagedWorkspaceRegistryError.duplicateOrdinal
            }
            if let previous, definition.ordinal <= previous {
                throw ManagedWorkspaceRegistryError.unorderedOrdinal
            }
            previous = definition.ordinal
        }
        orderedDefinitions = definitions
    }

    var count: Int { orderedDefinitions.count }

    func definition(for id: ManagedWorkspaceID) -> ManagedWorkspaceDefinition? {
        orderedDefinitions.first { $0.id == id }
    }

    func require(_ id: ManagedWorkspaceID) throws -> ManagedWorkspaceDefinition {
        guard let definition = definition(for: id) else {
            throw ManagedWorkspaceRegistryError.unknownWorkspace
        }
        return definition
    }

}
