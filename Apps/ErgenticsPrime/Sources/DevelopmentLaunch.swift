import Foundation

enum DevelopmentLaunch {
    enum Mode: Equatable, Sendable {
        case ordinary
        case deltaPUReadiness
        case rustBootstrapOnce
        case primeGitReadiness
        case fixedGuestOnce
        #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
        case h3QualificationAdmission(nonce: String)
        case h3QualificationGuest(nonce: String)
        #endif
        case invalid
    }

    /// One closed argument grammar. There is no command language, path input,
    /// environment routing, option composition, or implicit fallback.
    static func parse(arguments: [String]) -> Mode {
        #if EPR_H3_QUALIFICATION
        return evaluate(arguments: arguments, qualificationEnabled: true)
        #elseif EPR_H3_QUALIFICATION_TESTS
        return evaluate(arguments: arguments, qualificationEnabled: false)
        #else
        return ordinaryParse(arguments: arguments)
        #endif
    }

    #if EPR_H3_QUALIFICATION || EPR_H3_QUALIFICATION_TESTS
    static func evaluate(arguments: [String], qualificationEnabled: Bool) -> Mode {
        guard qualificationEnabled else { return ordinaryParse(arguments: arguments) }
        guard arguments.count == 2, arguments[1].utf8.count == 64,
              arguments[1].utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }) else {
            return .invalid
        }
        switch arguments[0] {
        case "--h3-qualification-admission-once": return .h3QualificationAdmission(nonce: arguments[1])
        case "--h3-qualification-guest-once": return .h3QualificationGuest(nonce: arguments[1])
        default: return .invalid
        }
    }
    #endif

    private static func ordinaryParse(arguments: [String]) -> Mode {
        guard !arguments.isEmpty else { return .ordinary }
        if arguments == ["--check-prime-services"] { return .ordinary }
        #if DEBUG
        switch arguments {
        case ["--deltapu-readiness"]: return .deltaPUReadiness
        case ["--run-rust-bootstrap-once"]: return .rustBootstrapOnce
        case ["--prime-git-readiness"]: return .primeGitReadiness
        case ["--run-fixed-guest-once"]: return .fixedGuestOnce
        default: return .invalid
        }
        #else
        return .invalid
        #endif
    }

    /// CommandLine is sampled exactly once for the process. Every consumer
    /// routes through this immutable mode.
    private static let launchArguments = Array(CommandLine.arguments.dropFirst())
    static let processMode = parse(arguments: launchArguments)
    static let computeCheckRequested = launchArguments == ["--check-prime-services"]

    static func isDeltaPUReadiness(arguments: [String]) -> Bool {
        parse(arguments: arguments) == .deltaPUReadiness
    }

    static var deltaPUReadinessRequested: Bool {
        processMode == .deltaPUReadiness
    }

    static func isRustBoot(arguments: [String]) -> Bool {
        parse(arguments: arguments) == .rustBootstrapOnce
    }

    static var rustBootRequested: Bool {
        processMode == .rustBootstrapOnce
    }

    static func isReadinessProbe(arguments: [String]) -> Bool {
        parse(arguments: arguments) == .primeGitReadiness
    }

    static var readinessRequested: Bool {
        processMode == .primeGitReadiness
    }

    static var fixedGuestRequested: Bool { processMode == .fixedGuestOnce }
}

#if DEBUG
/// Deliberately drops values before constructing any retained report.
struct DevelopmentEnvironmentNames {
    let names: [String]
    var count: Int { names.count }

    init(environment: [String: String]) {
        names = environment.keys.sorted()
    }
}

/// Pure report model; hostless tests do not link the GUI observer or native lab.
struct DevelopmentReadinessReport: Encodable {
    let schema = "com.ergentics.provenance.gui-readiness.v2"
    let pid: Int32
    let bundleIdentifier: String
    let executablePath: String
    let team: String
    let signatureAdmitted: Bool
    let signingStatus: String
    let environmentCountAtProbeStart: Int
    let environmentCountAtObservation: Int
    let environmentNamesAtProbeStart: [String]
    let environmentNamesAtObservation: [String]
    let visibleWindowCount: Int
    let contentWindowAttached: Bool
    let observedWindowTitle: String
    let windowWidth: Double
    let windowHeight: Double
    let labStartupSkipped: Bool
    let capabilityQueriesSkipped: Bool
    let guestModelIdle: Bool
    let primeGitModelIdle: Bool
    let pollingCanceled: Bool
    let startTicks: String
    let observationTicks: String
    let timebaseStatus: Int32
    let timebaseNumerator: UInt32
    let timebaseDenominator: UInt32
    let normalQuitPlanned = true
    let scope = "GUI startup observation only; no guest, Git, journal or Gate E execution proof"
    let timingScope = "Probe start through observation; excludes framework startup, output write and termination"

    var startupReady: Bool {
        signatureAdmitted && bundleIdentifier == "com.ergentics.provenance" &&
        contentWindowAttached && visibleWindowCount > 0 && windowWidth.isFinite && windowHeight.isFinite &&
        windowWidth > 0 && windowHeight > 0 && labStartupSkipped &&
        capabilityQueriesSkipped && guestModelIdle && primeGitModelIdle && !pollingCanceled && timingValid &&
        environmentNamesConsistent
    }

    var environmentNamesConsistent: Bool {
        environmentCountAtProbeStart == environmentNamesAtProbeStart.count &&
        environmentCountAtObservation == environmentNamesAtObservation.count &&
        environmentNamesAtProbeStart == Set(environmentNamesAtProbeStart).sorted() &&
        environmentNamesAtObservation == Set(environmentNamesAtObservation).sorted()
    }

    var timingValid: Bool {
        guard timebaseStatus == 0, timebaseNumerator > 0, timebaseDenominator > 0,
              let start = UInt64(startTicks), let end = UInt64(observationTicks) else { return false }
        return end >= start
    }
}
#endif
