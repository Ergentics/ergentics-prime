import Foundation
import Testing
@testable import ErgenticsShotResearchCore

@Suite("shot hypothesis research lattice")
struct DisposalShotResearchLatticeTests {
    @Test("tracked sibling lattice is exact and the result lattice identity is unchanged")
    func resourceIdentity() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let resourceRoot = packageRoot
            .appendingPathComponent("Sources/ErgenticsShotResearchCore/Resources")
        let manifest = try String(
            contentsOf: packageRoot.appendingPathComponent("Package.swift"),
            encoding: .utf8)
        let hypothesis = try Data(contentsOf: resourceRoot.appendingPathComponent(
            "disposal-hypothesis-lattice.v1.json"))
        let result = try Data(contentsOf: packageRoot
            .deletingLastPathComponent()
            .appendingPathComponent(
                "ErgenticsInterface/Sources/DisposalProjectionCore/Resources/" +
                    "disposal-lattice.v1.json"))

        #expect(hypothesis == DisposalShotResearchLatticeResources.hypothesisLatticeWithLF)
        #expect(disposalSHA256(hypothesis) ==
            "9284a87263a28b4a5e33b5629d672cb020b8d5f47bf319fdfc36ec56f8fd89fd")
        #expect(disposalSHA256(result) ==
            "c99361cb2052032e176b1ab5cd22898a67231b98bdea8c972388bdeab12ba022")
        #expect(manifest.contains(#"["-Xlinker", "-S"]"#))
        #expect(manifest.contains(#".when(configuration: .release)"#))
    }

    @Test("consistent registered model reaches H40 with zero authority")
    func consistentModel() throws {
        let input = hypothesisInput()
        let report = try DisposalShotHypothesisChecker.evaluate(exactCanonicalJSON: input)

        #expect(report.decision == .modelConsistent)
        #expect(report.matchedRuleID == "H40")
        #expect(report.canonicalJSONWithLF.last == 0x0a)
        #expect(Data(report.canonicalJSONWithLF.dropLast()) == report.canonicalJSON)
        let roundTrip = try canonicalRoundTrip(report.canonicalJSON)
        #expect(report.canonicalJSON == roundTrip)
        let text = String(decoding: report.canonicalJSON, as: UTF8.self)
        #expect(text.contains(#""authority_vector":"00000000""#))
        #expect(text.contains(#""authoritative":false"#))
        #expect(text.contains(#""may_authorize_launch":false"#))
        #expect(text.contains(#""may_feed_controller":false"#))
        #expect(text.contains(#""prose_may_supply_fact":false"#))
        #expect(text.contains(#""measurement_protocol":"MACH_CONTINUOUS_TIME_BEFORE_ACTUATION_THROUGH_TERMINAL_CONSERVATION""#))
    }

    @Test("first-match order distinguishes contradiction, failed constraint, and unknown")
    func firstMatchOrder() throws {
        let contradiction = try DisposalShotHypothesisChecker.evaluate(
            exactCanonicalJSON: hypothesisInput(modelValue: "FALSE"))
        #expect(contradiction.decision == .modelInconsistent)
        #expect(contradiction.matchedRuleID == "H10")

        let failedConstraint = try DisposalShotHypothesisChecker.evaluate(
            exactCanonicalJSON: hypothesisInput(constraintValue: "FALSE"))
        #expect(failedConstraint.decision == .modelInconsistent)
        #expect(failedConstraint.matchedRuleID == "H20")

        let unknown = try DisposalShotHypothesisChecker.evaluate(
            exactCanonicalJSON: hypothesisInput(unknowns: ["LIVE_PROCESS_STATE"]))
        #expect(unknown.decision == .abstainUnknown)
        #expect(unknown.matchedRuleID == "H30")
    }

    @Test("content commitments move while an unchanged truth vector remains stable")
    func commitmentSeparation() throws {
        let first = try DisposalShotHypothesisChecker.evaluate(
            exactCanonicalJSON: hypothesisInput(identitySHA256: hex("3")))
        let second = try DisposalShotHypothesisChecker.evaluate(
            exactCanonicalJSON: hypothesisInput(identitySHA256: hex("4")))

        #expect(first.inputSHA256 != second.inputSHA256)
        #expect(first.commitmentMerkleRootSHA256 != second.commitmentMerkleRootSHA256)
        #expect(first.predicateVectorSHA256 == second.predicateVectorSHA256)
        #expect(first.decision == second.decision)
    }

    @Test("noncanonical, duplicate, extra, and unsorted inputs fail closed")
    func malformedInputs() throws {
        var withLF = hypothesisInput()
        withLF.append(0x0a)
        #expect(throws: DisposalProjectionRejection.self) {
            try DisposalShotHypothesisChecker.evaluate(exactCanonicalJSON: withLF)
        }

        let duplicate = Data(#"{"authoritative":false,"authoritative":false}"#.utf8)
        #expect(throws: DisposalProjectionRejection.self) {
            try DisposalShotHypothesisChecker.evaluate(exactCanonicalJSON: duplicate)
        }

        let extra = hypothesisInput(extraTopLevel: true)
        #expect(throws: DisposalProjectionRejection.self) {
            try DisposalShotHypothesisChecker.evaluate(exactCanonicalJSON: extra)
        }

        let unsorted = hypothesisInput(unknowns: ["Z_UNKNOWN", "A_UNKNOWN"])
        #expect(throws: DisposalProjectionRejection.self) {
            try DisposalShotHypothesisChecker.evaluate(exactCanonicalJSON: unsorted)
        }

        #expect(throws: DisposalProjectionRejection.self) {
            try DisposalShotHypothesisChecker.evaluate(
                exactCanonicalJSON: hypothesisInput(
                    hypothesisID: "OVERALL_RESULT_CLASS"))
        }
        #expect(throws: DisposalProjectionRejection.self) {
            try DisposalShotHypothesisChecker.evaluate(
                exactCanonicalJSON: hypothesisInput(
                    resultKey: "OVERALL_RESULT_CLASS"))
        }
    }

    @Test("registered result confirms, refutes, or leaves the hypothesis indeterminate")
    func resultDelta() throws {
        let hypothesis = hypothesisInput()

        let confirmed = try DisposalShotHypothesisResultComparator.compare(
            hypothesisExactCanonicalJSON: hypothesis,
            resultExactCanonicalJSON: resultInput(value: "TRUE"))
        #expect(confirmed.decision == .confirmed)

        let refuted = try DisposalShotHypothesisResultComparator.compare(
            hypothesisExactCanonicalJSON: hypothesis,
            resultExactCanonicalJSON: resultInput(value: "FALSE"))
        #expect(refuted.decision == .refuted)

        let indeterminate = try DisposalShotHypothesisResultComparator.compare(
            hypothesisExactCanonicalJSON: hypothesis,
            resultExactCanonicalJSON: resultInput(value: nil))
        #expect(indeterminate.decision == .indeterminate)

        #expect(confirmed.deltaMerkleRootSHA256 != refuted.deltaMerkleRootSHA256)
        #expect(confirmed.resultInputSHA256 != refuted.resultInputSHA256)
        let text = String(decoding: confirmed.canonicalJSON, as: UTF8.self)
        #expect(text.contains(#""elapsed_nanoseconds_denominator":1"#))
        #expect(text.contains(#""elapsed_nanoseconds_numerator":100"#))
        #expect(text.contains(#""utc_stamps_display_only":true"#))
        #expect(text.contains(#""may_authorize_launch":false"#))
    }

    @Test("result comparison cannot confirm a failed or unknown precheck")
    func resultRequiresAdmittedPrecheck() throws {
        let inconsistent = try DisposalShotHypothesisResultComparator.compare(
            hypothesisExactCanonicalJSON: hypothesisInput(modelValue: "FALSE"),
            resultExactCanonicalJSON: resultInput(value: "TRUE"))
        #expect(inconsistent.decision == .indeterminate)

        let unknown = try DisposalShotHypothesisResultComparator.compare(
            hypothesisExactCanonicalJSON: hypothesisInput(unknowns: ["LIVE_PROCESS_STATE"]),
            resultExactCanonicalJSON: resultInput(value: "TRUE"))
        #expect(unknown.decision == .indeterminate)
        #expect(String(decoding: unknown.canonicalJSON, as: UTF8.self).contains(
            #""comparison_qualified_by_precheck":false"#))
    }

    @Test("monotonic elapsed time must join start, end, and timebase exactly")
    func timingJoin() throws {
        #expect(throws: DisposalProjectionRejection.self) {
            try DisposalShotHypothesisResultComparator.compare(
                hypothesisExactCanonicalJSON: hypothesisInput(),
                resultExactCanonicalJSON: resultInput(
                    value: "TRUE", elapsedNanosecondsNumerator: 99))
        }
        let rational = try DisposalShotHypothesisResultComparator.compare(
            hypothesisExactCanonicalJSON: hypothesisInput(),
            resultExactCanonicalJSON: resultInput(
                value: "TRUE",
                startTicks: 100,
                endTicks: 101,
                timebaseNumerator: 1,
                timebaseDenominator: 3))
        let rationalText = String(decoding: rational.canonicalJSON, as: UTF8.self)
        #expect(rationalText.contains(#""elapsed_nanoseconds_denominator":3"#))
        #expect(rationalText.contains(#""elapsed_nanoseconds_numerator":1"#))

        #expect(throws: DisposalProjectionRejection.self) {
            try DisposalShotHypothesisResultComparator.compare(
                hypothesisExactCanonicalJSON: hypothesisInput(),
                resultExactCanonicalJSON: resultInput(
                    value: "TRUE",
                    startUTC: "2026-02-31T12:00:00.000000000Z"))
        }
        _ = try DisposalShotHypothesisResultComparator.compare(
            hypothesisExactCanonicalJSON: hypothesisInput(),
            resultExactCanonicalJSON: resultInput(
                value: "TRUE",
                startUTC: "2024-02-29T12:00:00.000000000Z"))
    }

    @Test("known values require resolved typed content-addressed witnesses")
    func typedWitnessJoin() throws {
        let admittedWitness = witness(
            kind: "CONSTRAINT_VALUE",
            components: ["C01_STATIC_IDENTITY", "TRUE"])
        var input = String(decoding: hypothesisInput(), as: UTF8.self)
        let range = try #require(input.range(of: admittedWitness.sha256))
        input.replaceSubrange(range, with: hex("f"))
        #expect(throws: DisposalProjectionRejection.self) {
            try DisposalShotHypothesisChecker.evaluate(
                exactCanonicalJSON: Data(input.utf8))
        }
    }

    @Test("checker transport is a bounded zero-argument research surface")
    func checkerTransportSurface() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let main = try String(
            contentsOf: packageRoot.appendingPathComponent(
                "Sources/ErgenticsShotHypothesisChecker/main.swift"),
            encoding: .utf8)
        #expect(main.contains("guard CommandLine.arguments.count == 1"))
        #expect(main.contains("guard isClosedFoundationBootstrapEnvironment()"))
        #expect(main.contains("__CF_USER_TEXT_ENCODING="))
        #expect(main.contains("horizonNanoseconds: UInt64 = 5_000_000_000"))
        #expect(main.contains("DisposalShotHypothesisChecker.maximumInputBytes"))
        #expect(main.contains("clock.remainingMilliseconds("))
        #expect(main.contains("poll(&descriptor, 1, remaining)"))
        #expect(main.contains("O_NONBLOCK"))
        #expect(main.contains("F_SETNOSIGPIPE"))
        #expect(main.contains("Darwin.read(STDIN_FILENO"))
        #expect(main.contains("Darwin.write("))
        for forbidden in [
            "Process(", "posix_spawn", "fork(", "execv(", "kill(", "signal(",
            "FileManager", "URLSession", "socket(", "sqlite3", "controller",
        ] {
            #expect(!main.contains(forbidden), "forbidden checker surface: \(forbidden)")
        }
    }

    @Test("checker executable round-trips the exact canonical research report")
    func checkerExecutableRoundTrip() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let buildRoot = packageRoot.appendingPathComponent(".build")
        let enumerator = try #require(FileManager.default.enumerator(
            at: buildRoot,
            includingPropertiesForKeys: [.isExecutableKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]))
        let candidates = enumerator.compactMap { element -> URL? in
            guard let url = element as? URL,
                  url.lastPathComponent == "ErgenticsShotHypothesisChecker",
                  FileManager.default.isExecutableFile(atPath: url.path)
            else { return nil }
            return url
        }
        let checker = try #require(candidates.sorted { $0.path < $1.path }.first)
        #expect(FileManager.default.isExecutableFile(atPath: checker.path))

        let input = hypothesisInput()
        let expected = try DisposalShotHypothesisChecker.evaluate(
            exactCanonicalJSON: input).canonicalJSONWithLF
        let process = Process()
        let standardInput = Pipe()
        let standardOutput = Pipe()
        let standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["-i", checker.path]
        process.environment = [:]
        process.standardInput = standardInput
        process.standardOutput = standardOutput
        process.standardError = standardError
        try process.run()
        try standardInput.fileHandleForWriting.write(contentsOf: input)
        try standardInput.fileHandleForWriting.close()
        let output = standardOutput.fileHandleForReading.readDataToEndOfFile()
        let error = standardError.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        #expect(process.terminationReason == .exit)
        #expect(process.terminationStatus == 0)
        #expect(error.isEmpty)
        #expect(output == expected)
    }

    private func hypothesisInput(
        constraintValue: String = "TRUE",
        modelValue: String = "TRUE",
        hypothesisID: String = "H01_CONSERVATION",
        resultKey: String = "R01_CONSERVATION",
        identitySHA256: String? = nil,
        unknowns: [String] = [],
        extraTopLevel: Bool = false
    ) -> Data {
        let constraintWitness = witness(
            kind: "CONSTRAINT_VALUE",
            components: ["C01_STATIC_IDENTITY", constraintValue])
        let hypothesisWitness = witness(
            kind: "HYPOTHESIS_MODEL_VALUE",
            components: [hypothesisID, modelValue])
        let witnessInventory = [constraintWitness, hypothesisWitness].sorted {
            $0.sha256 < $1.sha256
        }
        var members: [String: DisposalJSONValue] = [
            "authoritative": disposalJSONBoolean(false),
            "authority_vector": disposalJSONString("00000000"),
            "constraints": array([
                object([
                    "constraint_id": disposalJSONString("C01_STATIC_IDENTITY"),
                    "required": disposalJSONBoolean(true),
                    "statement_sha256": disposalJSONString(hex("1")),
                    "value": disposalJSONString(constraintValue),
                    "witness_sha256": array([disposalJSONString(constraintWitness.sha256)]),
                ]),
            ]),
            "hypotheses": array([
                object([
                    "expected_value": disposalJSONString("TRUE"),
                    "hypothesis_id": disposalJSONString(hypothesisID),
                    "model_value": disposalJSONString(modelValue),
                    "required": disposalJSONBoolean(true),
                    "result_key": disposalJSONString(resultKey),
                    "statement_sha256": disposalJSONString(hex("5")),
                    "witness_sha256": array([disposalJSONString(hypothesisWitness.sha256)]),
                ]),
            ]),
            "identity_bindings": array([
                object([
                    "byte_count": disposalJSONNumber(4096),
                    "role": disposalJSONString("CONTROLLER_IMAGE"),
                    "sha256": disposalJSONString(identitySHA256 ?? hex("6")),
                ]),
            ]),
            "may_feed_controller": disposalJSONBoolean(false),
            "measurement_plan": object([
                "clock": disposalJSONString("MACH_CONTINUOUS_TIME"),
                "end_boundary": disposalJSONString("AFTER_TERMINAL_CONSERVATION"),
                "start_boundary": disposalJSONString("BEFORE_FIRST_LIVE_ACTUATION"),
                "utc_display": disposalJSONString("RFC3339_NANOSECONDS_DISPLAY_ONLY"),
            ]),
            "predicted_result_class": disposalJSONString("PASS"),
            "prose_may_supply_fact": disposalJSONBoolean(false),
            "schema": disposalJSONString("ergentics_shot_hypothesis_registration_v1"),
            "shot_class": disposalJSONString("R19_SUCCESSOR_PRECHECK"),
            "status": disposalJSONString("REGISTERED_HYPOTHESIS"),
            "study_id": disposalJSONString("STUDY_R19_001"),
            "unknowns": array(unknowns.map(disposalJSONString)),
            "witness_inventory": array(witnessInventory.map { $0.json }),
        ]
        if extraTopLevel { members["unexpected"] = disposalJSONBoolean(true) }
        return disposalCanonicalObject(members)
    }

    private func resultInput(
        value: String?,
        elapsedNanosecondsNumerator: Int? = nil,
        elapsedNanosecondsDenominator: Int? = nil,
        startTicks: Int = 100,
        endTicks: Int = 200,
        timebaseNumerator: Int = 1,
        timebaseDenominator: Int = 1,
        startUTC: String = "2026-08-26T12:00:00.000000000Z",
        endUTC: String = "2026-08-26T12:00:01.000000000Z"
    ) -> Data {
        let unreducedNumerator = (endTicks - startTicks) * timebaseNumerator
        let divisor = gcd(unreducedNumerator, timebaseDenominator)
        let admittedElapsedNumerator = elapsedNanosecondsNumerator ??
            unreducedNumerator / divisor
        let admittedElapsedDenominator = elapsedNanosecondsDenominator ??
            timebaseDenominator / divisor
        let classWitness = witness(kind: "RESULT_CLASS", components: ["PASS"])
        let startWitness = witness(
            kind: "TIMING_START",
            components: [
                "MACH_CONTINUOUS_TIME", "BEFORE_FIRST_LIVE_ACTUATION", String(startTicks),
                startUTC,
            ])
        let endWitness = witness(
            kind: "TIMING_END",
            components: [
                "MACH_CONTINUOUS_TIME", "AFTER_TERMINAL_CONSERVATION", String(endTicks),
                endUTC,
            ])
        let observations: [DisposalJSONValue]
        var resultWitnesses = [classWitness, startWitness, endWitness]
        if let value {
            let observationWitness = witness(
                kind: "RESULT_OBSERVATION",
                components: ["R01_CONSERVATION", value])
            resultWitnesses.append(observationWitness)
            observations = [object([
                "result_key": disposalJSONString("R01_CONSERVATION"),
                "value": disposalJSONString(value),
                "witness_sha256": array([disposalJSONString(observationWitness.sha256)]),
            ])]
        } else {
            observations = []
        }
        return disposalCanonicalObject([
            "authoritative": disposalJSONBoolean(false),
            "authority_vector": disposalJSONString("00000000"),
            "may_feed_controller": disposalJSONBoolean(false),
            "measurement_window": object([
                "clock": disposalJSONString("MACH_CONTINUOUS_TIME"),
                "elapsed_nanoseconds_denominator": disposalJSONNumber(
                    admittedElapsedDenominator),
                "elapsed_nanoseconds_numerator": disposalJSONNumber(
                    admittedElapsedNumerator),
                "end_boundary": disposalJSONString("AFTER_TERMINAL_CONSERVATION"),
                "end_continuous_ticks": disposalJSONNumber(endTicks),
                "end_utc": disposalJSONString(endUTC),
                "end_witness_sha256": disposalJSONString(endWitness.sha256),
                "start_boundary": disposalJSONString("BEFORE_FIRST_LIVE_ACTUATION"),
                "start_continuous_ticks": disposalJSONNumber(startTicks),
                "start_utc": disposalJSONString(startUTC),
                "start_witness_sha256": disposalJSONString(startWitness.sha256),
                "timebase_denominator": disposalJSONNumber(timebaseDenominator),
                "timebase_numerator": disposalJSONNumber(timebaseNumerator),
            ]),
            "observations": array(observations),
            "observed_result_class": disposalJSONString("PASS"),
            "observed_result_class_witness_sha256": array([
                disposalJSONString(classWitness.sha256),
            ]),
            "prose_may_supply_fact": disposalJSONBoolean(false),
            "schema": disposalJSONString("ergentics_shot_result_observation_v1"),
            "shot_class": disposalJSONString("R19_SUCCESSOR_PRECHECK"),
            "status": disposalJSONString("REGISTERED_RESULT"),
            "study_id": disposalJSONString("STUDY_R19_001"),
            "witness_inventory": array(
                resultWitnesses.sorted { $0.sha256 < $1.sha256 }.map { $0.json }),
        ])
    }

    private func canonicalRoundTrip(_ data: Data) throws -> Data {
        var parser = DisposalCanonicalJSONParser(
            data: data, frameOrdinal: 1, journalByteOffset: 0)
        return try parser.parse().canonicalData()
    }

    private func object(_ members: [String: DisposalJSONValue]) -> DisposalJSONValue {
        .object(
            members.map { DisposalJSONObjectMember(key: $0.key, value: $0.value) },
            disposalZeroSpan)
    }

    private func array(_ values: [DisposalJSONValue]) -> DisposalJSONValue {
        .array(values, disposalZeroSpan)
    }

    private func hex(_ digit: Character) -> String {
        String(repeating: String(digit), count: 64)
    }

    private func gcd(_ left: Int, _ right: Int) -> Int {
        var a = left
        var b = right
        while b != 0 {
            let remainder = a % b
            a = b
            b = remainder
        }
        return a
    }

    private func witness(
        kind: String,
        components: [String]
    ) -> (sha256: String, json: DisposalJSONValue) {
        let digestFree = disposalCanonicalObject([
            "components": array(components.map(disposalJSONString)),
            "kind": disposalJSONString(kind),
        ])
        let sha256 = disposalSHA256(digestFree)
        return (
            sha256,
            object([
                "byte_count": disposalJSONNumber(digestFree.count),
                "components": array(components.map(disposalJSONString)),
                "kind": disposalJSONString(kind),
                "sha256": disposalJSONString(sha256),
            ]))
    }
}
