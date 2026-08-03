// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceTopologyV25Tests:
    XCTestCase
{
    private typealias Source =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    private static let sourceContractSHA256 =
        "21f5a3805c6a5404072caa79d4c6c3463556c4a780d215e03fe570cd26d5a9d5"
    private static let topologyV25SHA256 =
        "a5907c0d1505c004a4fbd67193d2b1f7f640cd8c8906fdd94cdbed6eab667ba3"
    private static let topologyV24SHA256 =
        "711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91"
    private static let sourceBindingKey =
        "historical_worker_invocation_seam_caller_and_result_consumer_source_contract_binding"

    func testFrozenV25BindsOnlyTheReviewedSourceAndAuthorityCeiling()
        throws
    {
        let source = Source.frozenV1
        let topology = Topology.frozenV25
        let sourceSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(source)
        )

        XCTAssertNoThrow(try source.validate())
        XCTAssertNoThrow(try topology.validate())
        XCTAssertEqual(sourceSHA256, Self.sourceContractSHA256)
        XCTAssertEqual(topology.schemaVersion, 25)
        XCTAssertEqual(
            topology.contractID,
            "prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_caller_result_consumer_source_topology_v25"
        )
        XCTAssertEqual(
            topology
                .historicalWorkerInvocationSeamCallerAndResultConsumerSourceContractID,
            source.contractID
        )
        XCTAssertEqual(
            topology
                .historicalWorkerInvocationSeamCallerAndResultConsumerSourceContractSHA256,
            Self.sourceContractSHA256
        )
        XCTAssertEqual(
            topology.nextImplementationPrerequisite,
            source.nextImplementationPrerequisite
        )
        XCTAssertEqual(topology.status, .plannedNotMaterialized)
        XCTAssertFalse(topology.executionImplemented)
        XCTAssertFalse(topology.sourceBindingV7Issued)
        XCTAssertTrue(topology.historicalContractsPreserved)
        XCTAssertEqual(
            topology.packageCaptureAuthority,
            "actual_package_secure_capture_only_bound_source_\(source.contractID)_sha256_\(Self.sourceContractSHA256)_and_exact_compiler_feasibility_not_main_cross_file_safe_boundary_invocation_runtime_input_output_request_process_replay_transport_artifact_io_launch_execution_publication_authority_or_source_binding_v7_evidence"
        )

        for claim in [
            "V25 materializes one nested internal two-case nonpayload disposition",
            "one internal static synchronous nonthrowing boundary",
            "no checked-in caller invokes the new nonpayload boundary",
            "Main remains an unconditional status-78 exit",
            "two dispositions reveal only returned versus threw",
            "raw seam to private",
            "hardened isolation remains mandatory",
            "Prime remains ABSTAIN",
        ] {
            XCTAssertTrue(
                topology.authorityStatement.contains(claim),
                claim
            )
        }
    }

    func testV25CanonicalDeltaFromV24HasExactlySixKeys()
        throws
    {
        let previousObject = try canonicalObject(Topology.frozenV24)
        let topologyObject = try canonicalObject(Topology.frozenV25)
        let sharedChangedKeys: Set<String> = [
            "schema_version",
            "contract_id",
            "package_capture_authority",
            "next_implementation_prerequisite",
            "authority_statement",
        ]
        let exactChangedKeys =
            sharedChangedKeys.union([Self.sourceBindingKey])

        XCTAssertEqual(
            Set(topologyObject.keys)
                .subtracting(Set(previousObject.keys)),
            [Self.sourceBindingKey]
        )
        XCTAssertTrue(
            Set(previousObject.keys)
                .subtracting(Set(topologyObject.keys))
                .isEmpty
        )
        XCTAssertNil(previousObject[Self.sourceBindingKey])
        XCTAssertNotNil(topologyObject[Self.sourceBindingKey])

        for key in sharedChangedKeys {
            XCTAssertNotEqual(
                try canonicalValue(
                    try XCTUnwrap(previousObject[key])
                ),
                try canonicalValue(
                    try XCTUnwrap(topologyObject[key])
                ),
                key
            )
        }
        var previousStable = previousObject
        var topologyStable = topologyObject
        for key in exactChangedKeys {
            previousStable.removeValue(forKey: key)
            topologyStable.removeValue(forKey: key)
        }
        XCTAssertEqual(
            try canonicalDictionary(previousStable),
            try canonicalDictionary(topologyStable)
        )
    }

    func testV25GraphReachabilityPackageAndPriorBindingsRemainExact()
        throws
    {
        let previous = Topology.frozenV24
        let topology = Topology.frozenV25

        XCTAssertEqual(topology.targetGraph, previous.targetGraph)
        XCTAssertEqual(
            topology.forbiddenReachability,
            previous.forbiddenReachability
        )
        XCTAssertEqual(topology.status, previous.status)
        XCTAssertEqual(
            topology.executionImplemented,
            previous.executionImplemented
        )
        XCTAssertEqual(
            topology.historicalReplayPlanID,
            previous.historicalReplayPlanID
        )
        XCTAssertEqual(
            topology.historicalSourceBindingContractID,
            previous.historicalSourceBindingContractID
        )

        let priorBindings: [
            PrimeNativeNeuralGateTopologyContractBinding?
        ] = [
            topology.historicalEvidenceExportDesignContractBinding,
            topology.historicalEvidenceExportSourceContractBinding,
            topology
                .historicalWorkerEvidenceExportCallEdgeSourceContractBinding,
            topology
                .historicalEvidenceSemanticArtifactProjectionDesignContractBinding,
            topology
                .historicalEvidenceSemanticArtifactProjectionSourceContractBinding,
            topology
                .historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding,
            topology.historicalSemanticArtifactDecoderSourceContractBinding,
            topology
                .historicalWorkerSemanticArtifactDecoderCallEdgeSourceContractBinding,
            topology
                .historicalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractBinding,
            topology
                .historicalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractBinding,
            topology.historicalWorkerInvocationSeamDesignContractBinding,
            topology.historicalWorkerInvocationSeamSourceContractBinding,
            topology
                .historicalWorkerInvocationSeamCallerAndResultConsumerDesignContractBinding,
        ]
        let previousBindings: [
            PrimeNativeNeuralGateTopologyContractBinding?
        ] = [
            previous.historicalEvidenceExportDesignContractBinding,
            previous.historicalEvidenceExportSourceContractBinding,
            previous
                .historicalWorkerEvidenceExportCallEdgeSourceContractBinding,
            previous
                .historicalEvidenceSemanticArtifactProjectionDesignContractBinding,
            previous
                .historicalEvidenceSemanticArtifactProjectionSourceContractBinding,
            previous
                .historicalWorkerSemanticArtifactProjectionCallEdgeSourceContractBinding,
            previous.historicalSemanticArtifactDecoderSourceContractBinding,
            previous
                .historicalWorkerSemanticArtifactDecoderCallEdgeSourceContractBinding,
            previous
                .historicalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractBinding,
            previous
                .historicalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractBinding,
            previous.historicalWorkerInvocationSeamDesignContractBinding,
            previous.historicalWorkerInvocationSeamSourceContractBinding,
            previous
                .historicalWorkerInvocationSeamCallerAndResultConsumerDesignContractBinding,
        ]
        XCTAssertEqual(priorBindings, previousBindings)
        XCTAssertNil(
            previous
                .historicalWorkerInvocationSeamCallerAndResultConsumerSourceContractBinding
        )
        XCTAssertNotNil(
            topology
                .historicalWorkerInvocationSeamCallerAndResultConsumerSourceContractBinding
        )

        XCTAssertEqual(
            topology.historicalEvidenceExportTargetName,
            previous.historicalEvidenceExportTargetName
        )
        XCTAssertEqual(
            topology.historicalEvidenceSemanticArtifactProjectionTargetName,
            previous.historicalEvidenceSemanticArtifactProjectionTargetName
        )
        XCTAssertEqual(
            topology.historicalStatisticsArtifactContractTargetName,
            previous.historicalStatisticsArtifactContractTargetName
        )
        XCTAssertEqual(
            topology.historicalSemanticArtifactDecoderTargetName,
            previous.historicalSemanticArtifactDecoderTargetName
        )
        XCTAssertEqual(
            topology.historicalContainmentRootTargetName,
            previous.historicalContainmentRootTargetName
        )
        XCTAssertEqual(
            topology.historicalRuntimeTargetName,
            previous.historicalRuntimeTargetName
        )
        XCTAssertEqual(
            topology.historicalReplayTargetName,
            previous.historicalReplayTargetName
        )
        XCTAssertEqual(
            topology.pureReplayTargetName,
            previous.pureReplayTargetName
        )
        XCTAssertEqual(
            topology.donorAdaptationV2PreservedAsHistory,
            previous.donorAdaptationV2PreservedAsHistory
        )
        XCTAssertEqual(
            topology.donorAdaptationV3Required,
            previous.donorAdaptationV3Required
        )
        XCTAssertEqual(
            topology.donorAdaptationV3RequiredDestination,
            previous.donorAdaptationV3RequiredDestination
        )
        XCTAssertEqual(
            topology.sourceBindingV7Prerequisite,
            previous.sourceBindingV7Prerequisite
        )
        XCTAssertEqual(
            topology.mutationProducerDetectorTargetAssignmentDeferred,
            previous.mutationProducerDetectorTargetAssignmentDeferred
        )
        XCTAssertEqual(
            topology.mutationProducerDetectorMustBeDisjoint,
            previous.mutationProducerDetectorMustBeDisjoint
        )
    }

    func testAllV1ThroughV24CanonicalTopologyHashesRemainExact()
        throws
    {
        let expected: [(Topology, String)] = [
            (.frozenV1, "48e0f64fcb14193d74bf9c3d98a8aeef7ca366033cea6d8f00bc345ff0ad86b5"),
            (.frozenV2, "abc8f1ada303ecb95b7c9a44e72293ed314537b93e27354aebbb7763e1487415"),
            (.frozenV3, "b475e29347a31d27be8dc1aa54648fec84c4f1b47d673a1f111ccffb794985fd"),
            (.frozenV4, "8339bbd42b0e4052888db880aacbb067770c08dd2106bf4a7820c853c4b715af"),
            (.frozenV5, "252e027fc0f547e96b8c74b2e45cd1c316f1080d639a94619e9c03c87c480930"),
            (.frozenV6, "6a25a3d674a7ef3eda4475ed5532fff2366103b641736b410b37fabbc805bcd1"),
            (.frozenV7, "88fd8b2da5590576a3c9868e1ede55efb228e82d853d5db67a1d17d58834c156"),
            (.frozenV8, "8f49c8322951249568915cb5b6a9971e251127ff865709292f0c7a7bd0f1db5b"),
            (.frozenV9, "5b5f6aae6c74d7b3cf8380093e6ebc1ba8b321f22e9476ac884c8b852ceacc90"),
            (.frozenV10, "b7990ee20d69660b29d12e0ba9014df2849da5747329c80cbe168644b6a170a5"),
            (.frozenV11, "06ce2af33e574c04ef4a46ca356402457ddd4e045bce6d100fed796c19c909eb"),
            (.frozenV12, "335e6d54a94305ee2976c9433d0b5570cdd0f67ca8fea0fa00c8dd9f12eaebbe"),
            (.frozenV13, "b1564c277a50b8bc2b2ba325809130920dcb123f0d02297efba73e3bb3aec4ea"),
            (.frozenV14, "4aee5e011a7db85ed74955684f885b03f306e82b8fd4d0f12422d0b791663564"),
            (.frozenV15, "c4fe0ddd24fc5d614b36ee2698d62cb7cdae745b087c02cc176225a070852eb0"),
            (.frozenV16, "7e9dafad211bb0fb450ff9054be71a0022f5a259b4021d90123eb4736df747d3"),
            (.frozenV17, "3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166"),
            (.frozenV18, "aa9dd4031469742fca5d0241bd329e7712d98ec81677704fbca911d5bdcf043f"),
            (.frozenV19, "84f07261ff86dab5836e96a2667a8d3a05b0ec597b9677d5f1bab77c2c8801ba"),
            (.frozenV20, "b8045480883016fd49e7a63b02437f54835c1e7de6e61a4c2dea7f439a052a57"),
            (.frozenV21, "6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4"),
            (.frozenV22, "af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5"),
            (.frozenV23, "48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9"),
            (.frozenV24, Self.topologyV24SHA256),
        ]

        for (topology, sha256) in expected {
            XCTAssertEqual(
                PrimeSHA256.hexDigest(
                    of: try PrimeCanonicalJSON.encode(topology)
                ),
                sha256
            )
            XCTAssertNil(
                topology
                    .historicalWorkerInvocationSeamCallerAndResultConsumerSourceContractBinding
            )
        }
    }

    func testFrozenV25CanonicalRoundTripAndHash() throws {
        let topology = Topology.frozenV25
        let canonical = try PrimeCanonicalJSON.encode(topology)
        let decoded = try PrimeCanonicalJSON.decode(
            Topology.self,
            from: canonical
        )

        XCTAssertEqual(decoded, topology)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), canonical)
        let observed = try topology.contentSHA256()
        XCTAssertEqual(observed, PrimeSHA256.hexDigest(of: canonical))
        XCTAssertEqual(observed, Self.topologyV25SHA256)
    }

    func testV25SourceBindingIsRequiredAndRejectsNull() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV25)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let binding = try XCTUnwrap(
            object[Self.sourceBindingKey] as? [String: Any]
        )
        var mutations: [[String: Any]] = []

        do {
            var mutation = object
            mutation.removeValue(forKey: Self.sourceBindingKey)
            mutations.append(mutation)
        }
        do {
            var mutation = object
            mutation[Self.sourceBindingKey] = NSNull()
            mutations.append(mutation)
        }
        for nestedKey in ["contract_id", "content_sha256"] {
            do {
                var mutation = object
                var nested = binding
                nested.removeValue(forKey: nestedKey)
                mutation[Self.sourceBindingKey] = nested
                mutations.append(mutation)
            }
            do {
                var mutation = object
                var nested = binding
                nested[nestedKey] = NSNull()
                mutation[Self.sourceBindingKey] = nested
                mutations.append(mutation)
            }
        }

        for (index, mutation) in mutations.enumerated() {
            let data = try JSONSerialization.data(
                withJSONObject: mutation,
                options: [.sortedKeys]
            )
            do {
                let decoded = try JSONDecoder().decode(
                    Topology.self,
                    from: data
                )
                XCTAssertThrowsError(
                    try decoded.validate(),
                    "V25 source-binding required/null mutation \(index)"
                )
            } catch {
                continue
            }
        }
    }

    func testEveryV25CanonicalFieldMutationFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV25)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )

        for path in requiredFieldPaths(in: object) {
            let mutation = replacingValue(
                in: object,
                at: path,
                with: mutateJSONValue
            )
            XCTAssertThrowsError(
                try {
                    let decoded = try JSONDecoder().decode(
                        Topology.self,
                        from: try JSONSerialization.data(
                            withJSONObject: mutation,
                            options: [.sortedKeys]
                        )
                    )
                    try decoded.validate()
                }(),
                path.joined(separator: ".")
            )
        }
    }

    func testEveryV25CanonicalFieldIsRequiredAndRejectsNull()
        throws
    {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV25)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )

        for path in requiredFieldPaths(in: object) {
            let label = path.joined(separator: ".")
            let missingData = try JSONSerialization.data(
                withJSONObject: removingValue(in: object, at: path),
                options: [.sortedKeys]
            )
            do {
                let decoded = try JSONDecoder().decode(
                    Topology.self,
                    from: missingData
                )
                XCTAssertThrowsError(
                    try decoded.validate(),
                    "missing \(label)"
                )
            } catch {
                // A required decoding failure is also fail-closed.
            }

            let nullData = try JSONSerialization.data(
                withJSONObject: replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                options: [.sortedKeys]
            )
            do {
                let decoded = try JSONDecoder().decode(
                    Topology.self,
                    from: nullData
                )
                XCTAssertThrowsError(
                    try decoded.validate(),
                    "null \(label)"
                )
            } catch {
                // A required decoding failure is also fail-closed.
            }
        }
    }

    func testV25RuntimeAuthorityAndPriorBindingMutationsFailClosed()
        throws
    {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV25)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let binding = try XCTUnwrap(
            object[Self.sourceBindingKey] as? [String: Any]
        )
        let priorBindingKey =
            "historical_worker_invocation_seam_caller_and_result_consumer_design_contract_binding"
        let priorBinding = try XCTUnwrap(
            object[priorBindingKey] as? [String: Any]
        )
        let graph = try XCTUnwrap(
            object["target_graph"] as? [[String: Any]]
        )
        let reachability = try XCTUnwrap(
            object["forbidden_reachability"] as? [[String: Any]]
        )
        var mutations: [[String: Any]] = []

        for nestedKey in ["contract_id", "content_sha256"] {
            var mutation = object
            var drift = binding
            drift[nestedKey] = String(repeating: "f", count: 64)
            mutation[Self.sourceBindingKey] = drift
            mutations.append(mutation)
        }
        do {
            var mutation = object
            var drift = priorBinding
            drift["content_sha256"] = String(repeating: "e", count: 64)
            mutation[priorBindingKey] = drift
            mutations.append(mutation)
        }
        do {
            var mutation = object
            mutation["target_graph"] = Array(graph.dropLast())
            mutations.append(mutation)
        }
        do {
            var mutation = object
            mutation["forbidden_reachability"] =
                Array(reachability.dropLast())
            mutations.append(mutation)
        }
        for (key, value) in [
            ("execution_implemented", true),
            ("source_binding_v7_issued", true),
        ] {
            var mutation = object
            mutation[key] = value
            mutations.append(mutation)
        }
        do {
            var mutation = object
            mutation["status"] = "implemented"
            mutations.append(mutation)
        }
        for key in [
            "package_capture_authority",
            "next_implementation_prerequisite",
            "authority_statement",
        ] {
            var mutation = object
            mutation[key] =
                try XCTUnwrap(object[key] as? String) + "__weakened"
            mutations.append(mutation)
        }

        for (index, mutation) in mutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Topology.self,
                from: try JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "V25 runtime/authority mutation \(index)"
            )
        }
    }

    func testUnknownCanonicalV25TopologyKeyFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV25)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        object["unknown_runtime_or_publication_authority"] = true
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )

        let plain = try JSONDecoder().decode(Topology.self, from: data)
        XCTAssertEqual(plain, .frozenV25)
        XCTAssertNoThrow(try plain.validate())
        XCTAssertThrowsError(
            try PrimeCanonicalJSON.decode(Topology.self, from: data)
        )
    }

    private func canonicalObject(
        _ topology: Topology
    ) throws -> [String: Any] {
        try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: PrimeCanonicalJSON.encode(topology)
            ) as? [String: Any]
        )
    }

    private func canonicalValue(_ value: Any) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: ["value": value],
            options: [.sortedKeys]
        )
    }

    private func canonicalDictionary(
        _ value: [String: Any]
    ) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: value,
            options: [.sortedKeys]
        )
    }

    private func requiredFieldPaths(
        in object: [String: Any]
    ) -> [[String]] {
        var paths = object.keys.sorted().map { [$0] }
        for key in object.keys.sorted() {
            guard let nested = object[key] as? [String: Any] else {
                continue
            }
            paths.append(
                contentsOf: nestedLeafPaths(in: nested).map {
                    [key] + $0
                }
            )
        }
        return paths
    }

    private func nestedLeafPaths(
        in object: [String: Any]
    ) -> [[String]] {
        var paths: [[String]] = []
        for key in object.keys.sorted() {
            if let nested = object[key] as? [String: Any] {
                paths.append(
                    contentsOf: nestedLeafPaths(in: nested).map {
                        [key] + $0
                    }
                )
            } else {
                paths.append([key])
            }
        }
        return paths
    }

    private func replacingValue(
        in object: [String: Any],
        at path: [String],
        with transform: (Any) -> Any
    ) -> [String: Any] {
        var result = object
        let key = path[0]
        guard path.count > 1 else {
            result[key] = transform(result[key] as Any)
            return result
        }
        result[key] = replacingValue(
            in: result[key] as! [String: Any],
            at: Array(path.dropFirst()),
            with: transform
        )
        return result
    }

    private func removingValue(
        in object: [String: Any],
        at path: [String]
    ) -> [String: Any] {
        var result = object
        let key = path[0]
        guard path.count > 1 else {
            result.removeValue(forKey: key)
            return result
        }
        result[key] = removingValue(
            in: result[key] as! [String: Any],
            at: Array(path.dropFirst())
        )
        return result
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if let string = value as? String {
            return string + "__mutation"
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return number.int64Value + 1
        }
        if var array = value as? [Any] {
            if array.isEmpty {
                return ["__mutation"]
            }
            array[0] = mutateJSONValue(array[0])
            return array
        }
        if let object = value as? [String: Any],
           let key = object.keys.sorted().first
        {
            return replacingValue(
                in: object,
                at: [key],
                with: mutateJSONValue
            )
        }
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
    }
}
