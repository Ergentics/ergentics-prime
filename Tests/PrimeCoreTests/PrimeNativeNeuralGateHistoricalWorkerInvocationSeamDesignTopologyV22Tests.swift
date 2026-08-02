// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignTopologyV22Tests:
    XCTestCase
{
    private typealias Design =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    private static let designContractSHA256 =
        "3954a98474cdaf79a62c65a20cf612f3a1ddaf6b8305aa941e94d3863791e757"
    private static let topologyV22SHA256 =
        "af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5"
    private static let nextImplementationPrerequisite =
        "source_bind_the_bounded_unavailable_historical_worker_invocation_seam_as_an_append_only_same_file_v21_composition_continuation_preserving_all_v21_private_members_and_delegating_exactly_once_from_one_new_internal_nonpublic_typed_bridge_without_adding_a_main_call_edge_replay_transport_integration_request_handling_sealing_launch_execution_artifact_io_publication_or_issuing_source_binding_v7"

    func testFrozenV22BindsOnlyTheInvocationSeamDesignAndAuthorityCeiling()
        throws
    {
        let design = Design.frozenV1
        let topology = Topology.frozenV22

        XCTAssertNoThrow(try design.validate())
        XCTAssertNoThrow(try topology.validate())
        XCTAssertEqual(topology.schemaVersion, 22)
        XCTAssertEqual(
            topology.contractID,
            "prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_design_topology_v22"
        )
        XCTAssertEqual(
            topology.historicalWorkerInvocationSeamDesignContractID,
            design.contractID
        )
        XCTAssertEqual(
            topology
                .historicalWorkerInvocationSeamDesignContractSHA256,
            Self.designContractSHA256
        )
        XCTAssertEqual(
            try design.contentSHA256(),
            Self.designContractSHA256
        )
        XCTAssertEqual(
            topology.nextImplementationPrerequisite,
            Self.nextImplementationPrerequisite
        )
        XCTAssertEqual(
            topology.nextImplementationPrerequisite,
            design.nextImplementationPrerequisite
        )
        XCTAssertEqual(topology.status, .plannedNotMaterialized)
        XCTAssertFalse(topology.executionImplemented)
        XCTAssertFalse(topology.sourceBindingV7Issued)
        XCTAssertTrue(topology.historicalContractsPreserved)
        XCTAssertTrue(
            topology.packageCaptureAuthority.contains(
                Self.designContractSHA256
            )
        )
        XCTAssertTrue(
            topology.authorityStatement.contains(
                "source-binds only the bounded unavailable historical-worker composition invocation-seam design"
            )
        )
        XCTAssertTrue(
            topology.authorityStatement.contains(
                "does not add that seam"
            )
        )
        XCTAssertTrue(
            topology.authorityStatement.contains(
                "Prime remains ABSTAIN"
            )
        )
    }

    func testV22CanonicalDeltaFromV21HasExactlySixKeys()
        throws
    {
        let previousObject = try canonicalObject(Topology.frozenV21)
        let topologyObject = try canonicalObject(Topology.frozenV22)
        let bindingKey =
            "historical_worker_invocation_seam_design_contract_binding"
        let sharedChangedKeys: Set<String> = [
            "schema_version",
            "contract_id",
            "package_capture_authority",
            "next_implementation_prerequisite",
            "authority_statement",
        ]
        let exactChangedKeys = sharedChangedKeys.union([bindingKey])

        XCTAssertEqual(
            Set(topologyObject.keys)
                .subtracting(Set(previousObject.keys)),
            [bindingKey]
        )
        XCTAssertTrue(
            Set(previousObject.keys)
                .subtracting(Set(topologyObject.keys))
                .isEmpty
        )
        XCTAssertNil(previousObject[bindingKey])
        XCTAssertNotNil(topologyObject[bindingKey])

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

    func testV22GraphReachabilityAndAllPriorStateRemainExact()
        throws
    {
        let previous = Topology.frozenV21
        let topology = Topology.frozenV22

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
        XCTAssertEqual(
            topology
                .historicalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractBinding,
            previous
                .historicalWorkerExportedEvidenceProjectionDecodeCompositionDesignContractBinding
        )
        XCTAssertEqual(
            topology
                .historicalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractBinding,
            previous
                .historicalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractBinding
        )
        XCTAssertNil(
            previous.historicalWorkerInvocationSeamDesignContractBinding
        )
        XCTAssertNotNil(
            topology.historicalWorkerInvocationSeamDesignContractBinding
        )
        XCTAssertEqual(
            topology.historicalEvidenceExportTargetName,
            previous.historicalEvidenceExportTargetName
        )
        XCTAssertEqual(
            topology
                .historicalEvidenceSemanticArtifactProjectionTargetName,
            previous
                .historicalEvidenceSemanticArtifactProjectionTargetName
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
            topology.historicalContractsPreserved,
            previous.historicalContractsPreserved
        )
        XCTAssertEqual(
            topology.historicalFutureTargetGraphSuperseded,
            previous.historicalFutureTargetGraphSuperseded
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

    func testAllV1ThroughV21CanonicalTopologyHashesRemainExact()
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
                    .historicalWorkerInvocationSeamDesignContractBinding
            )
        }
    }

    func testFrozenV22CanonicalRoundTripAndHash() throws {
        let topology = Topology.frozenV22
        let canonical = try PrimeCanonicalJSON.encode(topology)
        let decoded = try PrimeCanonicalJSON.decode(
            Topology.self,
            from: canonical
        )

        XCTAssertEqual(decoded, topology)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), canonical)
        let observed = try topology.contentSHA256()
        XCTAssertEqual(observed.utf8.count, 64)
        XCTAssertEqual(observed, PrimeSHA256.hexDigest(of: canonical))
        XCTAssertEqual(observed, Self.topologyV22SHA256)
    }

    func testV22BindingGraphAndAuthorityMutationsFailClosed()
        throws
    {
        let canonical = try PrimeCanonicalJSON.encode(
            Topology.frozenV22
        )
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let bindingKey =
            "historical_worker_invocation_seam_design_contract_binding"
        let preservedV21BindingKey =
            "historical_worker_exported_evidence_projection_decode_composition_call_edge_source_contract_binding"
        let binding = try XCTUnwrap(
            object[bindingKey] as? [String: Any]
        )
        let preservedV21Binding = try XCTUnwrap(
            object[preservedV21BindingKey] as? [String: Any]
        )
        let graph = try XCTUnwrap(
            object["target_graph"] as? [[String: Any]]
        )
        let reachability = try XCTUnwrap(
            object["forbidden_reachability"] as? [[String: Any]]
        )
        var mutations: [[String: Any]] = []

        do {
            var mutation = object
            mutation.removeValue(forKey: bindingKey)
            mutations.append(mutation)
        }
        do {
            var mutation = object
            var drift = binding
            drift["content_sha256"] =
                String(repeating: "f", count: 64)
            mutation[bindingKey] = drift
            mutations.append(mutation)
        }
        do {
            var mutation = object
            var drift = preservedV21Binding
            drift["content_sha256"] =
                String(repeating: "e", count: 64)
            mutation[preservedV21BindingKey] = drift
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

        for (index, mutation) in mutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Topology.self,
                from: JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "V22 mutation \(index)"
            )
        }
    }

    func testUnknownCanonicalV22TopologyKeyFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV22)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        object["unknown_future_invocation_authority"] = true
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys]
        )

        let plain = try JSONDecoder().decode(Topology.self, from: data)
        XCTAssertEqual(plain, .frozenV22)
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
}
