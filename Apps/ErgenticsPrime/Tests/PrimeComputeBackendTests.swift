import CryptoKit
import Foundation
import XCTest

/// Decoder fixtures only: these tests do not launch a model, GPU or guest.
final class PrimeComputeBackendTests: XCTestCase {
    private let pid: Int32 = 1234
    private let weightsSHA = String(repeating: "a", count: 64)
    private func data(_ object: [String: Any]) throws -> Data { try JSONSerialization.data(withJSONObject: object, options: .sortedKeys) }
    private func sha(_ value: Data) -> String { SHA256.hash(data: value).map { String(format: "%02x", $0) }.joined() }

    private func modelFixture() throws -> (Data, [String: Any]) {
        let request = try PrimeStudyInput().request(weightsPath: "/weights", weightsSHA256: weightsSHA, execution: "guest")
        let inputs = [[1,64,80,96,6,68,80,96,3], [1,5,64,80,96,3], [1,5,68,80,96,3], [1,7,149,143,3]]
        let ids = [192,149,143,192]
        let rows: [[String: Any]] = (0..<4).map { ["id":"study-choice", "predictionTokenID":ids[$0], "inputTokenIDs":inputs[$0], "logitsFinite":true] }
        var observations: [String: Any] = ["status":0, "runCount":5]
        for key in ["cleanupComplete", "guestInputChecksPassed", "registerChecksPassed", "codeImmutableValidated", "dataGuardValidated", "completionHVCCount"] { observations[key] = 1 }
        for key in ["callbackCount", "completedCount", "inferenceRequestCount", "inferenceReturnCount"] { observations[key] = 4 }
        let guest: [String: Any] = ["guestCommittedPredictions":ids, "observedInputTokenIDs":inputs, "observations":observations]
        return (request, ["schema":"prime_10m_feedback_inference_result_v2", "status":"completed", "execution":"guest",
            "requestSHA256":sha(request), "processID":pid, "trainingPerformed":false, "modelWeightsInGuest":false,
            "tensorCount":74, "parameterCount":10227968, "weightsBefore":["sha256":weightsSHA], "weightsAfter":["sha256":weightsSHA],
            "device":"Decoder fixture", "cases":[["id":"study-choice", "status":"completed", "predictions":rows, "guest":guest]]])
    }

    func testModelDecoderAcceptsOnlyMatchingRequestAndExactChild() throws {
        let (request, original) = try modelFixture()
        XCTAssertEqual(try PrimeComputeBackend.modelResult(data(original), request:request, processID:pid).ids, [192,149,143,192])
        for (key, value) in [("requestSHA256", "wrong" as Any), ("processID", 5678 as Any), ("schema", "wrong" as Any)] {
            var changed = original; changed[key] = value
            XCTAssertThrowsError(try PrimeComputeBackend.modelResult(data(changed), request:request, processID:pid))
        }
        let edited = try PrimeStudyInput(left:.init(domain:1,readiness:4,durability:2)).request(weightsPath:"/weights", weightsSHA256:weightsSHA, execution:"guest")
        var falselyRebound = original; falselyRebound["requestSHA256"] = sha(edited)
        XCTAssertThrowsError(try PrimeComputeBackend.modelResult(data(falselyRebound), request:edited, processID:pid))
    }

    func testModelDecoderRejectsReplacedFeedbackOutOfVocabularyAndGuestMismatch() throws {
        let (request, original) = try modelFixture()
        for badToken in [16384 as Any, true as Any] {
            var changed = original, cases = original["cases"] as! [[String: Any]]
            var rows = cases[0]["predictions"] as! [[String: Any]]; rows[0]["predictionTokenID"] = badToken
            cases[0]["predictions"] = rows; changed["cases"] = cases
            XCTAssertThrowsError(try PrimeComputeBackend.modelResult(data(changed), request:request, processID:pid))
        }
        var changed = original, cases = original["cases"] as! [[String: Any]]
        var rows = cases[0]["predictions"] as! [[String: Any]]
        rows[3]["inputTokenIDs"] = [1,7,128,128,3] // A substituted target must not replace actual summary outputs.
        cases[0]["predictions"] = rows; changed["cases"] = cases
        XCTAssertThrowsError(try PrimeComputeBackend.modelResult(data(changed), request:request, processID:pid))
        cases = original["cases"] as! [[String: Any]]
        var guest = cases[0]["guest"] as! [String: Any]; guest["guestCommittedPredictions"] = [192,149,143,195]
        cases[0]["guest"] = guest; changed["cases"] = cases
        XCTAssertThrowsError(try PrimeComputeBackend.modelResult(data(changed), request:request, processID:pid))
    }

    private func geometryFixture() throws -> (Data, [String: Any]) {
        let request = try PrimeComputeBackend.geometryRequest(pointsText:"[[0,0]]", nodesText:"[[0,0,1]]", sigma:0.5, execution:"host")
        var values: [UInt32] = [Float(-1).bitPattern.littleEndian, 0, 0]
        let output = values.withUnsafeMutableBytes { Data($0) }
        return (request, ["schema":"prime_app_geometry_result_v1", "status":"completed", "execution":"host",
            "requestSHA256":sha(request), "processID":pid, "device":"Decoder fixture",
            "points":[[0,0]], "nodes":[["x":0,"y":0,"weight":1]], "sigma":0.5,
            "potential":[-1], "gradientXY":[0,0], "valueCount":3, "outputSHA256":sha(output),
            "trainingPerformed":false,"learnedModelInvoked":false,"CPUFallback":false,
            "validation":["CPUComparisonPassed":true,"oneActualMetalDispatch":true]])
    }

    func testGeometryDecoderRejectsWrongInputCountOutputHashAndProcess() throws {
        let (request, original) = try geometryFixture()
        XCTAssertEqual(try PrimeComputeBackend.geometryResult(data(original), request:request, processID:pid).potential, [-1])
        for (key, value) in [("potential", [-1,-1] as Any), ("outputSHA256", "wrong" as Any),
                             ("processID", 5678 as Any), ("points", [[0.5,0]] as Any), ("sigma", 0.7 as Any)] {
            var changed = original; changed[key] = value
            XCTAssertThrowsError(try PrimeComputeBackend.geometryResult(data(changed), request:request, processID:pid))
        }
        let edited = try PrimeComputeBackend.geometryRequest(pointsText:"[[0.5,0]]", nodesText:"[[0,0,1]]", sigma:0.5, execution:"host")
        var falselyRebound = original; falselyRebound["requestSHA256"] = sha(edited)
        XCTAssertThrowsError(try PrimeComputeBackend.geometryResult(data(falselyRebound), request:edited, processID:pid))
    }

    func testGeometryGuestCannotUseAHostReceiptAsEvidence() throws {
        let (_, original) = try geometryFixture()
        let request = try PrimeComputeBackend.geometryRequest(pointsText:"[[0,0]]", nodesText:"[[0,0,1]]", sigma:0.5, execution:"guest")
        var changed = original; changed["execution"] = "guest"; changed["requestSHA256"] = sha(request)
        XCTAssertThrowsError(try PrimeComputeBackend.geometryResult(data(changed), request:request, processID:pid))
    }

    func testGeometryRequestChecksEditedValuesAndFiniteFloatSigmaRange() throws {
        let request = try PrimeComputeBackend.geometryRequest(pointsText:"[[0.25,-0.5]]", nodesText:"[[1,2,0.75]]", sigma:0.7, execution:"guest")
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with:request) as? [String: Any])
        XCTAssertEqual(object["points"] as? [[Double]], [[0.25,-0.5]])
        XCTAssertEqual(object["nodes"] as? [[String: Double]], [["x":1,"y":2,"weight":0.75]])
        for sigma in [0, -1, Double.leastNonzeroMagnitude, 1e-30, 1e30, Double.infinity] {
            XCTAssertThrowsError(try PrimeComputeBackend.geometryRequest(pointsText:"[[0,0]]", nodesText:"[[0,0,1]]", sigma:sigma, execution:"guest"))
        }
        XCTAssertThrowsError(try PrimeComputeBackend.geometryRequest(pointsText:"[[0,0,0]]", nodesText:"[[0,0,1]]", sigma:0.5, execution:"guest"))
        XCTAssertThrowsError(try PrimeComputeBackend.geometryRequest(pointsText:"[[1e100,0]]", nodesText:"[[0,0,1]]", sigma:0.5, execution:"guest"))
    }
}
