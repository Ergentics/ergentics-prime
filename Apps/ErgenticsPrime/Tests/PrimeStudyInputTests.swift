import Foundation
import XCTest

final class PrimeStudyInputTests: XCTestCase {
    private let digest = String(repeating: "a", count: 64)

    private func object(_ input: PrimeStudyInput = .init(), execution: String = "guest") throws -> [String: Any] {
        let data = try input.request(weightsPath: "/model/weights.safetensors", weightsSHA256: digest, execution: execution)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func testRequestUsesActualTwoSourceFeedbackWithNoTargetFields() throws {
        let request = try object()
        XCTAssertEqual(Set(request.keys), ["schema", "execution", "weightsPath", "weightsSHA256", "cases"])
        let cases = try XCTUnwrap(request["cases"] as? [[String: Any]])
        XCTAssertEqual(cases.count, 1)
        let c = try XCTUnwrap(cases.first)
        XCTAssertEqual(c["allowedValueMinimum"] as? Int, 0)
        XCTAssertEqual(c["allowedValueCount"] as? Int, 16384)
        let jobs = try XCTUnwrap(c["jobs"] as? [[String: Any]])
        XCTAssertEqual(jobs.count, 4)
        XCTAssertEqual(jobs.map { $0["inputTokenIDs"] as? [Int] }, [
            [1, 64, 80, 96, 6, 68, 80, 96, 3], [1, 5, 64, 80, 96, 3],
            [1, 5, 68, 80, 96, 3], [1, 7, 0, 0, 3],
        ])
        for job in jobs { XCTAssertEqual(Set(job.keys), ["inputTokenIDs", "feedbackBindings"]) }
        for job in jobs.prefix(3) { XCTAssertEqual((job["feedbackBindings"] as? [[String: Int]])?.count, 0) }
        XCTAssertEqual(jobs[3]["feedbackBindings"] as? [[String: Int]], [
            ["inputOffset": 2, "sourceJobIndex": 1], ["inputOffset": 3, "sourceJobIndex": 2],
        ])
    }

    func testEditedCandidatesChangeAllThreeFieldsAndHostRoutePreservesJobs() throws {
        let input = PrimeStudyInput(left: .init(domain: 1, readiness: 4, durability: 2), right: .init(domain: 3, readiness: 2, durability: 1))
        let guest = try object(input), host = try object(input, execution: "host")
        XCTAssertEqual(host["execution"] as? String, "host")
        let cases = try XCTUnwrap(guest["cases"] as? [[String: Any]])
        let jobs = try XCTUnwrap(cases[0]["jobs"] as? [[String: Any]])
        XCTAssertEqual(jobs[0]["inputTokenIDs"] as? [Int], [1, 65, 84, 98, 6, 67, 82, 97, 3])
        XCTAssertEqual(jobs[1]["inputTokenIDs"] as? [Int], [1, 5, 65, 84, 98, 3])
        XCTAssertEqual(jobs[2]["inputTokenIDs"] as? [Int], [1, 5, 67, 82, 97, 3])
        XCTAssertEqual(try JSONSerialization.data(withJSONObject: guest["cases"]!, options: .sortedKeys),
                       try JSONSerialization.data(withJSONObject: host["cases"]!, options: .sortedKeys))
    }

    func testInvalidSelectionsAndRuntimeBindingAreRejectedAfterDecode() throws {
        for candidate in [PrimeStudyCandidate(domain: -1), .init(domain: 5), .init(readiness: -1), .init(readiness: 5), .init(durability: -1), .init(durability: 3)] {
            let encoded = try JSONEncoder().encode(PrimeStudyInput(left: candidate))
            let input = try JSONDecoder().decode(PrimeStudyInput.self, from: encoded)
            XCTAssertThrowsError(try object(input))
        }
        XCTAssertThrowsError(try PrimeStudyInput().request(weightsPath: "relative", weightsSHA256: digest, execution: "guest"))
        XCTAssertThrowsError(try PrimeStudyInput().request(weightsPath: "/weights", weightsSHA256: "wrong", execution: "guest"))
        XCTAssertThrowsError(try PrimeStudyInput().request(weightsPath: "/weights", weightsSHA256: digest, execution: "unknown"))
    }

    func testLabelsOnlyDecodeReturnedTokensIncludingAbstainAndUnmapped() {
        let expected = ["Left · Worked example", "Left · Productive failure", "Left · Retrieval practice",
                        "Right · Worked example", "Right · Productive failure", "Right · Retrieval practice"]
        for (offset, label) in expected.enumerated() {
            XCTAssertEqual(PrimeStudyInput.label(for: 192 + offset), "\(label) (token \(192 + offset))")
        }
        XCTAssertEqual(PrimeStudyInput.label(for: 224), "ABSTAIN (token 224)")
        XCTAssertEqual(PrimeStudyInput.label(for: 47), "Unmapped model token 47")
        XCTAssertEqual(PrimeStudyInput.label(for: 16383), "Unmapped model token 16383")
        XCTAssertEqual(PrimeStudyInput.label(for: 128), "Priority band 0 of 0–11 · Worked example (token 128)")
        XCTAssertEqual(PrimeStudyInput.label(for: 163), "Priority band 11 of 0–11 · Retrieval practice (token 163)")
    }

    func testScopeMetadataSeparatesRetainedAndUndefinedCombinations() {
        XCTAssertTrue(PrimeStudyInput().scopeNote.contains("held-out"))
        XCTAssertTrue(PrimeStudyInput(left: .init(domain: 4), right: .init(domain: 0)).scopeNote.contains("reversed held-out"))
        XCTAssertTrue(PrimeStudyInput(right: .init(domain: 1)).scopeNote.contains("training grid"))
        XCTAssertTrue(PrimeStudyInput(right: .init(domain: 0, readiness: 1)).scopeNote.contains("same-domain"))
        XCTAssertTrue(PrimeStudyInput(right: .init(domain: 2)).scopeNote.contains("equal-priority-band"))
        XCTAssertTrue(PrimeStudyInput(left: .init(domain: 1), right: .init(domain: 0)).scopeNote.contains("outside the retained examples"))
    }
}
