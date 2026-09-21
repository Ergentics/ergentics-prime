import Foundation

/// Indices into the retained model's fixed symbolic vocabulary, not measurements
/// inferred from a question or a person's clinical record.
struct PrimeStudyCandidate: Codable, Equatable, Sendable {
    var domain: Int
    var readiness: Int
    var durability: Int

    init(domain: Int = 0, readiness: Int = 0, durability: Int = 0) {
        self.domain = domain; self.readiness = readiness; self.durability = durability
    }

    fileprivate var isValid: Bool {
        (0..<5).contains(domain) && (0..<5).contains(readiness) && (0..<3).contains(durability)
    }

    fileprivate var tokens: [Int] { [64 + domain, 80 + readiness, 96 + durability] }
}

enum PrimeStudyInputFailure: Error, LocalizedError {
    case invalidCandidate, invalidRuntimeBinding

    var errorDescription: String? {
        switch self {
        case .invalidCandidate: return "Choose a listed domain, readiness, and durability value for each candidate."
        case .invalidRuntimeBinding: return "The retained Prime model or execution route is not valid."
        }
    }
}

/// Input-only projection of ErgenticsPrimeDomainTraceShadowCanary.swift.
/// The runtime receives four jobs and fills the final job with its two actual
/// summary predictions. Scope metadata below never enters those jobs.
struct PrimeStudyInput: Codable, Equatable, Sendable {
    var left: PrimeStudyCandidate
    var right: PrimeStudyCandidate

    init(left: PrimeStudyCandidate = .init(), right: PrimeStudyCandidate = .init(domain: 4)) {
        self.left = left; self.right = right
    }

    static let domainLabels = [
        "I · Scientific Foundation", "II · Advanced Practice Skills", "III · Diagnosis & Treatment",
        "IV · Psychotherapy & Theories", "V · Ethical & Legal Practice",
    ]
    static let readinessValues = [0.18, 0.30, 0.45, 0.64, 0.82]
    static let durabilityValues = [0.0, 0.35, 0.70]
    private static let eventLabels = ["Worked example", "Productive failure", "Retrieval practice"]

    private struct Feedback: Codable, Sendable {
        let inputOffset: Int
        let sourceJobIndex: Int
    }
    private struct Job: Codable, Sendable {
        let inputTokenIDs: [Int]
        let feedbackBindings: [Feedback]
    }
    private struct InputCase: Codable, Sendable {
        let id: String
        let allowedValueMinimum: Int
        let allowedValueCount: Int
        let jobs: [Job]
    }
    private struct Request: Codable, Sendable {
        let schema: String
        let execution: String
        let weightsPath: String
        let weightsSHA256: String
        let cases: [InputCase]
    }

    func request(weightsPath: String, weightsSHA256: String, execution: String) throws -> Data {
        guard left.isValid, right.isValid else { throw PrimeStudyInputFailure.invalidCandidate }
        guard weightsPath.hasPrefix("/"), !weightsPath.utf8.contains(0),
              weightsSHA256.utf8.count == 64,
              weightsSHA256.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }),
              execution == "host" || execution == "guest" else {
            throw PrimeStudyInputFailure.invalidRuntimeBinding
        }
        let jobs = [
            Job(inputTokenIDs: [1] + left.tokens + [6] + right.tokens + [3], feedbackBindings: []),
            Job(inputTokenIDs: [1, 5] + left.tokens + [3], feedbackBindings: []),
            Job(inputTokenIDs: [1, 5] + right.tokens + [3], feedbackBindings: []),
            Job(inputTokenIDs: [1, 7, 0, 0, 3], feedbackBindings: [
                Feedback(inputOffset: 2, sourceJobIndex: 1), Feedback(inputOffset: 3, sourceJobIndex: 2),
            ]),
        ]
        let value = Request(schema: "prime_10m_feedback_inference_request_v2", execution: execution,
            weightsPath: weightsPath, weightsSHA256: weightsSHA256,
            cases: [InputCase(id: "study-choice", allowedValueMinimum: 0, allowedValueCount: 16_384, jobs: jobs)])
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    /// Decodes only the token actually returned by the model. No predicted
    /// token is repaired, selected from a rule table, or replaced with a target.
    static func label(for token: Int) -> String {
        if token == 224 { return "ABSTAIN (token 224)" }
        if (192...197).contains(token) {
            let value = token - 192
            return "\(value < 3 ? "Left" : "Right") · \(eventLabels[value % 3]) (token \(token))"
        }
        if (128...163).contains(token) {
            let value = token - 128
            return "Priority band \(value / 3) of 0–11 · \(eventLabels[value % 3]) (token \(token))"
        }
        return "Unmapped model token \(token)"
    }

    var scopeNote: String {
        guard left.isValid, right.isValid else { return "A selection is outside the retained input vocabulary." }
        guard left.domain != right.domain else {
            return "The fields use the retained vocabulary; same-domain pairs were outside the represented examples."
        }
        guard Self.band(left) != Self.band(right) else {
            return "The fields use the retained vocabulary; equal-priority-band pairs were outside the represented examples."
        }
        let low = min(left.domain, right.domain), high = max(left.domain, right.domain)
        let heldOut = (low == 0 && high == 4) || (low == 1 && high == 3)
        if left.domain > right.domain {
            return heldOut
                ? "This ordering is a retained reversed held-out example. Predictions still come from the learned model."
                : "The fields use the retained vocabulary; this reversed ordering was outside the retained examples."
        }
        if heldOut { return "This combination belongs to the retained held-out domain pairs. Predictions come from the learned model." }
        if (low == 0 && high == 2) || (low == 1 && high == 4) {
            return "This combination belongs to the retained validation domain pairs. Predictions come from the learned model."
        }
        return "This combination belongs to the retained training grid. Predictions come from the learned model."
    }

    // Scope-only metadata, indexed [domain][readiness][durability]. Each band
    // was recovered from the original manifest's represented candidate states:
    // summaryToken = 128 + 3*band + eventIndex. The generating Swift engine
    // ranks distinct priorities, then min(11, rank*12/uniquePriorityCount).
    // These bands are never used to construct a model output or request target.
    private static let bands = [
        [[7, 3, 1], [10, 7, 4], [10, 9, 7], [10, 10, 9], [6, 5, 4]],
        [[9, 6, 1], [11, 9, 6], [11, 11, 9], [11, 11, 10], [8, 7, 6]],
        [[7, 3, 1], [10, 7, 4], [10, 9, 7], [10, 10, 9], [6, 5, 4]],
        [[1, 0, 0], [4, 2, 0], [4, 3, 2], [5, 4, 3], [1, 1, 0]],
        [[5, 2, 0], [8, 5, 2], [8, 7, 5], [8, 8, 6], [3, 3, 2]],
    ]
    private static func band(_ candidate: PrimeStudyCandidate) -> Int {
        bands[candidate.domain][candidate.readiness][candidate.durability]
    }
}
