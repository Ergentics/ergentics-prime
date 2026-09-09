#if EPR_H3_QUALIFICATION
import Foundation
import Security
import Darwin

final class H3QualificationExecutable {
    let path: String
    let codePath: String
    let descriptor: H3QualificationDescriptor
    let original: H3QualificationFileSnapshot
    let sha256: String
    let uuid: String

    init(path: String, codePath: String) throws {
        self.path = path; self.codePath = codePath
        try H3QualificationStorage.canonical(codePath)
        descriptor = try H3QualificationStorage.openAbsolute(path, directory: false)
        let capture = try H3QualificationStorage.read(descriptor.value, maximum: 67108864,
                                                    device: nil, executable: true, retain: false)
        original = capture.snapshot; sha256 = capture.sha256
        uuid = try Self.machoUUID(capture.bytes)
        _ = try observeNamed(requireHash: true)
    }

    func observeNamed(requireHash: Bool) throws -> H3QualificationFileSnapshot {
        let named = try H3QualificationStorage.openAbsolute(path, directory: false)
        let observed: H3QualificationFileSnapshot
        if requireHash {
            let capture = try H3QualificationStorage.read(named.value, maximum: 67108864,
                                                        device: original.device, executable: true, retain: false)
            guard capture.sha256 == sha256, try Self.machoUUID(capture.bytes) == uuid else {
                throw H3QualificationControllerFailure.rejected("executable named bytes")
            }
            observed = capture.snapshot
        } else {
            observed = try H3QualificationStorage.snapshot(named.value)
        }
        try named.close()
        guard H3QualificationPathIdentityPolicy.snapshot(observed, matches: original),
              try H3QualificationPathIdentityPolicy.snapshot(H3QualificationStorage.snapshot(descriptor.value), matches: original) else {
            throw H3QualificationControllerFailure.rejected("executable vnode")
        }
        return observed
    }

    func terminalObservation() throws -> (held: H3QualificationFileSnapshot, named: H3QualificationFileSnapshot) {
        let held = try H3QualificationStorage.read(descriptor.value, maximum: 67108864,
                                                 device: original.device, executable: true, retain: false, seek: true)
        guard H3QualificationPathIdentityPolicy.snapshot(held.snapshot, matches: original),
              held.sha256 == sha256, try Self.machoUUID(held.bytes) == uuid else {
            throw H3QualificationControllerFailure.rejected("executable terminal bytes")
        }
        return (held.snapshot, try observeNamed(requireHash: true))
    }

    private static func machoUUID(_ prefix: Data) throws -> String {
        let bytes = [UInt8](prefix)
        func word(_ offset: Int) throws -> UInt32 {
            guard offset >= 0, offset <= bytes.count - 4 else {
                throw H3QualificationControllerFailure.rejected("Mach-O truncated")
            }
            return UInt32(bytes[offset]) | UInt32(bytes[offset + 1]) << 8 |
                   UInt32(bytes[offset + 2]) << 16 | UInt32(bytes[offset + 3]) << 24
        }
        guard bytes.count >= 32, try word(0) == 0xfeedfacf, try word(4) == 0x0100000c,
              try word(12) == 2 else { throw H3QualificationControllerFailure.rejected("arm64 executable") }
        let commands = Int(try word(16)), commandBytes = Int(try word(20))
        guard commands > 0, commands <= 4096, commandBytes <= 1048576,
              commandBytes <= bytes.count - 32 else {
            throw H3QualificationControllerFailure.rejected("Mach-O command bound")
        }
        var offset = 32
        var uuid: [UInt8]?
        for _ in 0..<commands {
            let command = try word(offset), size = Int(try word(offset + 4))
            guard size >= 8, size % 8 == 0, size <= 32 + commandBytes - offset else {
                throw H3QualificationControllerFailure.rejected("Mach-O command size")
            }
            if command == 0x1b {
                guard size == 24, uuid == nil else { throw H3QualificationControllerFailure.rejected("Mach-O UUID") }
                uuid = Array(bytes[(offset + 8)..<(offset + 24)])
            }
            offset += size
        }
        guard offset == commandBytes + 32, let uuid else {
            throw H3QualificationControllerFailure.rejected("Mach-O command consumption")
        }
        let hex = uuid.map { String(format: "%02x", $0) }.joined()
        let indexes = [0, 8, 12, 16, 20, 32]
        return (0..<5).map { index in
            String(hex[hex.index(hex.startIndex, offsetBy: indexes[index])..<hex.index(hex.startIndex, offsetBy: indexes[index + 1])])
        }.joined(separator: "-")
    }
}

enum H3QualificationSigning {
    static let team = "ZCQ435U8JP"
    static let applicationIdentifier = "com.ergentics.provenance"
    static let controllerIdentifier = "com.ergentics.provenance.h3-qualification-controller"

    static func rule(_ identifier: String) -> String {
        "anchor apple generic and identifier \"\(identifier)\" and certificate leaf[subject.OU] = \"ZCQ435U8JP\""
    }

    private static func require(_ status: OSStatus, _ label: String) throws {
        guard status == errSecSuccess else { throw H3QualificationControllerFailure.system(label, status) }
    }

    private static func requirement(_ identifier: String) throws -> SecRequirement {
        var result: SecRequirement?
        try require(SecRequirementCreateWithString(rule(identifier) as CFString, SecCSFlags(), &result), "requirement")
        guard let result else { throw H3QualificationControllerFailure.rejected("missing requirement") }
        return result
    }

    private static func claim(_ code: SecStaticCode, executable: H3QualificationExecutable,
                              identifier: String) throws -> H3QValue {
        var path: CFURL?
        try require(SecCodeCopyPath(code, SecCSFlags(), &path), "code path")
        guard let path, H3QualificationPathIdentityPolicy.codeObjectPath((path as URL).path, expected: executable.codePath) else {
            throw H3QualificationControllerFailure.rejected("code object path")
        }
        var dictionary: CFDictionary?
        // Security's public header values: SigningInformation=1<<1,
        // StrictValidate=1<<4, CheckAllArchitectures=1<<0, NoNetworkAccess=1<<29.
        try require(SecCodeCopySigningInformation(code, SecCSFlags(rawValue: 1 << 1), &dictionary), "signing information")
        guard let dictionary else { throw H3QualificationControllerFailure.rejected("missing signing information") }
        let values = dictionary as NSDictionary
        guard let certificates = values[kSecCodeInfoCertificates] as? [SecCertificate],
              let leaf = certificates.first,
              let summary = SecCertificateCopySubjectSummary(leaf) as String?,
              summary.hasPrefix("Apple Development: ") else {
            throw H3QualificationControllerFailure.rejected("Apple Development certificate")
        }
        guard let actualIdentifier = values[kSecCodeInfoIdentifier] as? String, actualIdentifier == identifier,
              let actualTeam = values[kSecCodeInfoTeamIdentifier] as? String, actualTeam == team,
              let flags = values[kSecCodeInfoFlags] as? NSNumber,
              CFGetTypeID(flags) != CFBooleanGetTypeID(), flags.uint32Value & 0x10000 != 0,
              let cdhash = values[kSecCodeInfoUnique] as? Data, [20, 32].contains(cdhash.count),
              let mainExecutable = values[kSecCodeInfoMainExecutable] as? URL,
              H3QualificationPathIdentityPolicy.executablePath(mainExecutable.path, expected: executable.path) else {
            throw H3QualificationControllerFailure.rejected("code identity fields")
        }
        let entitlements: H3QValue
        if identifier == controllerIdentifier {
            if let raw = values[kSecCodeInfoEntitlementsDict] {
                guard let dictionary = raw as? NSDictionary, dictionary.count == 0 else {
                    throw H3QualificationControllerFailure.rejected("controller entitlements")
                }
            } else if values[kSecCodeInfoEntitlements] != nil {
                throw H3QualificationControllerFailure.rejected("undecoded controller entitlement blob")
            }
            entitlements = .null
        } else {
            let keys = ["com.apple.security.app-sandbox", "com.apple.security.files.user-selected.read-only",
                        "com.apple.security.hypervisor"]
            guard let dictionary = values[kSecCodeInfoEntitlementsDict] as? NSDictionary,
                  dictionary.count == keys.count else {
                throw H3QualificationControllerFailure.rejected("application entitlements")
            }
            for key in keys {
                guard let value = dictionary[key], CFGetTypeID(value as CFTypeRef) == CFBooleanGetTypeID(),
                      (value as? NSNumber)?.boolValue == true else {
                    throw H3QualificationControllerFailure.rejected("effective entitlement value")
                }
            }
            entitlements = .object(Dictionary(uniqueKeysWithValues: keys.map { ($0, .bool(true)) }))
        }
        let entitlementBytes = try H3QualificationCanonicalJSON.encode(entitlements, maximumBytes: 1024)
        // Admission above evaluates our frozen requirement. Evidence separately
        // retains the actual embedded designated requirement, matching the
        // external codesign probe rather than substituting policy text for it.
        var designated: SecRequirement?
        try require(SecCodeCopyDesignatedRequirement(code, SecCSFlags(), &designated), "designated requirement")
        guard let designated else { throw H3QualificationControllerFailure.rejected("missing designated requirement") }
        var designatedText: CFString?
        try require(SecRequirementCopyString(designated, SecCSFlags(), &designatedText), "designated requirement text")
        guard let designatedText else { throw H3QualificationControllerFailure.rejected("missing designated requirement text") }
        let requirementText = designatedText as String
        guard !requirementText.isEmpty, requirementText.utf8.count <= 256,
              !requirementText.unicodeScalars.contains(where: { $0.value < 32 || $0.value == 127 }) else {
            throw H3QualificationControllerFailure.rejected("designated requirement text bound")
        }
        let result: H3QValue = .object([
            "cdhash": .string(cdhash.map { String(format: "%02x", $0) }.joined()),
            "code_object_path": .string(executable.codePath), "designated_requirement": .string(requirementText),
            "entitlements": entitlements, "entitlements_sha256": .string(h3qHash(entitlementBytes)),
            "executable_path": .string(executable.path), "executable_sha256": .string(executable.sha256),
            "identifier": .string(identifier), "macho_uuid": .string(executable.uuid), "runtime": .bool(true),
            "team_identifier": .string(actualTeam), "valid": .bool(true)
        ])
        try H3QualificationWire.validate(result, schema: "code_identity_claim")
        return result
    }

    static func staticApplication(_ executable: H3QualificationExecutable) throws -> H3QValue {
        var code: SecStaticCode?
        try require(SecStaticCodeCreateWithPath(URL(fileURLWithPath: executable.codePath) as CFURL, SecCSFlags(), &code), "static code")
        guard let code else { throw H3QualificationControllerFailure.rejected("missing static code") }
        let flags = SecCSFlags(rawValue: (1 << 4) | (1 << 0) | (1 << 29))
        try require(SecStaticCodeCheckValidity(code, flags, requirement(applicationIdentifier)), "static validation")
        return try claim(code, executable: executable, identifier: applicationIdentifier)
    }

    static func dynamicApplication(pid: Int32, executable: H3QualificationExecutable) throws -> (claim: H3QValue, path: String) {
        // Security/kernel calls are entered synchronously and cannot be preempted by
        // this owner. The finite policy bounds intentional polling/waiting, while the
        // separately frozen outer supervisor retains this platform-call residual.
        guard pid > 0 else { throw H3QualificationControllerFailure.rejected("positive child") }
        var code: SecCode?
        let attributes = [kSecGuestAttributePid as String: NSNumber(value: pid)] as CFDictionary
        try require(SecCodeCopyGuestWithAttributes(nil, attributes, SecCSFlags(), &code), "exact PID code")
        guard let code else { throw H3QualificationControllerFailure.rejected("missing child code") }
        try require(SecCodeCheckValidity(code, SecCSFlags(rawValue: (1 << 4) | (1 << 29)),
                                             requirement(applicationIdentifier)), "dynamic validation")
        var staticCode: SecStaticCode?
        try require(SecCodeCopyStaticCode(code, SecCSFlags(), &staticCode), "dynamic static code")
        guard let staticCode else { throw H3QualificationControllerFailure.rejected("missing dynamic static code") }
        let path = try processPath(pid)
        guard H3QualificationPathIdentityPolicy.executablePath(path, expected: executable.path) else { throw H3QualificationControllerFailure.rejected("proc path") }
        return (try claim(staticCode, executable: executable, identifier: applicationIdentifier), path)
    }

    static func processPath(_ pid: Int32) throws -> String {
        var bytes = [UInt8](repeating: 0, count: 4096)
        let count = proc_pidpath(pid, &bytes, UInt32(bytes.count))
        guard count > 0, count < bytes.count, let end = bytes.firstIndex(of: 0),
              end > 0, end <= Int(count), let path = String(bytes: bytes[..<end], encoding: .utf8) else {
            throw H3QualificationControllerFailure.rejected("proc_pidpath result")
        }
        try H3QualificationStorage.canonical(path)
        return path
    }

    static func selfAdmission(executable: H3QualificationExecutable) throws -> H3QValue {
        let pid = getpid()
        guard pid > 0, try H3QualificationPathIdentityPolicy.executablePath(processPath(pid), expected: executable.path) else {
            throw H3QualificationControllerFailure.rejected("self PID path")
        }
        var code: SecCode?
        try require(SecCodeCopySelf(SecCSFlags(), &code), "self code")
        guard let code else { throw H3QualificationControllerFailure.rejected("missing self code") }
        try require(SecCodeCheckValidity(code, SecCSFlags(rawValue: (1 << 4) | (1 << 29)),
                                             requirement(controllerIdentifier)), "self validity")
        var staticCode: SecStaticCode?
        try require(SecCodeCopyStaticCode(code, SecCSFlags(), &staticCode), "self static code")
        guard let staticCode else { throw H3QualificationControllerFailure.rejected("missing self static code") }
        let codeClaim = try claim(staticCode, executable: executable, identifier: controllerIdentifier)
        return .object(["code": codeClaim, "held_at_start": executable.original.wire,
                        "named_at_start": executable.original.wire, "pid": .integer(Int64(pid))])
    }
}
#endif
