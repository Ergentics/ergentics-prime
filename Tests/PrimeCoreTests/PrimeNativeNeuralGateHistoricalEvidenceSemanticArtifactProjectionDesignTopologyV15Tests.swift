import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignTopologyV15Tests:
    XCTestCase
{
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract
    private typealias Design =
        PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContract

    private static let designContractSHA256 =
        "2d7da9703cf710f6f795900d91872780297a0e8d18f345cca302711d7fd0ec27"
    private static let topologyV15SHA256 =
        "c4fe0ddd24fc5d614b36ee2698d62cb7cdae745b087c02cc176225a070852eb0"

    func testFrozenV15BindsOnlyTheDesignAndAuthorityCeiling()
        throws
    {
        let topology = Topology.frozenV15
        let design = Design.frozenV1

        XCTAssertNoThrow(try design.validate())
        XCTAssertNoThrow(try topology.validate())
        XCTAssertEqual(topology.schemaVersion, 15)
        XCTAssertEqual(
            topology.contractID,
            "prime_stage_b_historical_evidence_semantic_artifact_projection_design_topology_v15"
        )
        XCTAssertEqual(
            topology
                .historicalEvidenceSemanticArtifactProjectionDesignContractID,
            design.contractID
        )
        XCTAssertEqual(
            topology
                .historicalEvidenceSemanticArtifactProjectionDesignContractSHA256,
            Self.designContractSHA256
        )
        XCTAssertEqual(
            try design.contentSHA256(),
            Self.designContractSHA256
        )
        XCTAssertEqual(topology.status, .plannedNotMaterialized)
        XCTAssertFalse(topology.executionImplemented)
        XCTAssertFalse(topology.sourceBindingV7Issued)
        XCTAssertTrue(
            topology.packageCaptureAuthority.contains(
                Self.designContractSHA256
            )
        )
        XCTAssertTrue(
            topology.authorityStatement.contains(
                "all three existing V4 historical specifications remain schema-deferred"
            )
        )
        XCTAssertTrue(
            topology.authorityStatement.contains(
                "No projection source or target is materialized"
            )
        )
        XCTAssertEqual(
            topology.nextImplementationPrerequisite,
            design.nextImplementationPrerequisite
        )
    }

    func testV15PreservesV14GraphAndReachabilityByteForByte()
        throws
    {
        let previous = Topology.frozenV14
        let topology = Topology.frozenV15

        XCTAssertEqual(topology.targetGraph, previous.targetGraph)
        XCTAssertEqual(
            topology.forbiddenReachability,
            previous.forbiddenReachability
        )
        XCTAssertEqual(
            topology.historicalEvidenceExportDesignContractBinding,
            previous.historicalEvidenceExportDesignContractBinding
        )
        XCTAssertEqual(
            topology.historicalEvidenceExportSourceContractBinding,
            previous.historicalEvidenceExportSourceContractBinding
        )
        XCTAssertEqual(
            topology
                .historicalWorkerEvidenceExportCallEdgeSourceContractBinding,
            previous
                .historicalWorkerEvidenceExportCallEdgeSourceContractBinding
        )
        XCTAssertEqual(
            try topology.transitiveLocalTargetNames(
                reachableFrom:
                    topology.historicalContainmentRootTargetName
            ),
            try previous.transitiveLocalTargetNames(
                reachableFrom:
                    previous.historicalContainmentRootTargetName
            )
        )
        XCTAssertFalse(
            try topology.transitiveLocalTargetNames(
                reachableFrom:
                    topology.historicalContainmentRootTargetName
            ).contains(
                Design.frozenV1.semanticRecordTargetName
            )
        )
        XCTAssertFalse(
            try topology.transitiveLocalTargetNames(
                reachableFrom:
                    topology.historicalContainmentRootTargetName
            ).contains(
                Design.frozenV1.correctedMutationSurfaceTargetName
            )
        )
    }

    func testAllPriorCanonicalTopologyIdentitiesRemainExact()
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
        ]

        for (topology, sha256) in expected {
            XCTAssertNoThrow(try topology.validate())
            XCTAssertEqual(try topology.contentSHA256(), sha256)
            XCTAssertNil(
                topology
                    .historicalEvidenceSemanticArtifactProjectionDesignContractBinding
            )
        }
    }

    func testV15CanonicalRoundTripAndHashAreExact()
        throws
    {
        let topology = Topology.frozenV15
        let data = try PrimeCanonicalJSON.encode(topology)
        let decoded = try PrimeCanonicalJSON.decode(
            Topology.self,
            from: data
        )

        XCTAssertEqual(decoded, topology)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(try PrimeCanonicalJSON.encode(decoded), data)
        XCTAssertEqual(
            try topology.contentSHA256(),
            Self.topologyV15SHA256
        )
    }

    func testV15BindingGraphReachabilityAndAuthorityMutationsFailClosed()
        throws
    {
        let data = try PrimeCanonicalJSON.encode(
            Topology.frozenV15
        )
        let canonicalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        )
        let bindingKey =
            "historical_evidence_semantic_artifact_projection_design_contract_binding"
        let binding = try XCTUnwrap(
            canonicalObject[bindingKey] as? [String: Any]
        )
        let graph = try XCTUnwrap(
            canonicalObject["target_graph"]
                as? [[String: Any]]
        )
        let reachability = try XCTUnwrap(
            canonicalObject["forbidden_reachability"]
                as? [[String: Any]]
        )
        var mutations: [[String: Any]] = []

        do {
            var object = canonicalObject
            object.removeValue(forKey: bindingKey)
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            var drift = binding
            drift["content_sha256"] =
                String(repeating: "0", count: 64)
            object[bindingKey] = drift
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            object["target_graph"] = Array(graph.dropLast())
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            object["forbidden_reachability"] =
                Array(reachability.dropLast())
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            object["execution_implemented"] = true
            mutations.append(object)
        }
        do {
            var object = canonicalObject
            object["status"] = "implemented"
            mutations.append(object)
        }

        for (index, object) in mutations.enumerated() {
            let decoded = try JSONDecoder().decode(
                Topology.self,
                from: JSONSerialization.data(
                    withJSONObject: object,
                    options: [.sortedKeys]
                )
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                "V15 mutation \(index)"
            )
        }
    }
}
