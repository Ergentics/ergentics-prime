// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceTopologyV27Tests:
    XCTestCase
{
    private typealias Source =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    private static let sourceContractSHA256 =
        "92f6abf8417d7845d5425b973f7a45d13297bc5af736bd1a9248bc39fdc191ce"
    private static let topologyV27SHA256 =
        "a572b5813e0410235f387222f6399c2984fcb52da69f4bd9393a5adf6869cd7c"
    private static let topologyV26SHA256 =
        "dfbba4e7adecac57febd8ab0946ab34f698d63d6b55d3fe119fe53c029c8da63"
    private static let sourceBindingKey =
        "historical_worker_invocation_seam_private_access_rebinding_source_contract_binding"

    func testFrozenV27BindsOnlyTheReviewedSourceAndAuthorityCeiling()
        throws
    {
        let source = Source.frozenV1
        let topology = Topology.frozenV27
        let sourceSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(source)
        )

        XCTAssertNoThrow(try source.validate())
        XCTAssertNoThrow(try topology.validate())
        XCTAssertEqual(sourceSHA256, Self.sourceContractSHA256)
        XCTAssertEqual(topology.schemaVersion, 27)
        XCTAssertEqual(
            topology.contractID,
            "prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_private_access_rebinding_source_topology_v27"
        )
        XCTAssertEqual(
            topology
                .historicalWorkerInvocationSeamPrivateAccessRebindingSourceContractID,
            source.contractID
        )
        XCTAssertEqual(
            topology
                .historicalWorkerInvocationSeamPrivateAccessRebindingSourceContractSHA256,
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
        XCTAssertTrue(
            topology.packageCaptureAuthority.contains(
                "bound_source_\(source.contractID)_sha256_\(Self.sourceContractSHA256)"
            )
        )
        for claim in [
            "preserves every V1 through V26 canonical identity",
            "14,174 bytes with private at 12,555..<12,562",
            "isolated fresh Release product build",
            "actual fifth-file",
            "ordinary direct-name narrowing",
            "Prime remains ABSTAIN",
            "did not complete within the bounded 1,800-second observation",
        ] {
            XCTAssertTrue(
                topology.authorityStatement.contains(claim),
                claim
            )
        }
    }

    func testV27CanonicalDeltaFromV26HasExactlySixKeys() throws {
        let previousObject = try canonicalObject(Topology.frozenV26)
        let topologyObject = try canonicalObject(Topology.frozenV27)
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

    func testV27GraphReachabilityPackageAndPriorBindingsRemainExact()
        throws
    {
        let previous = Topology.frozenV26
        let topology = Topology.frozenV27

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
                .historicalWorkerInvocationSeamPrivateAccessRebindingDesignContractBinding,
            previous
                .historicalWorkerInvocationSeamPrivateAccessRebindingDesignContractBinding
        )
        XCTAssertNil(
            previous
                .historicalWorkerInvocationSeamPrivateAccessRebindingSourceContractBinding
        )
        XCTAssertNotNil(
            topology
                .historicalWorkerInvocationSeamPrivateAccessRebindingSourceContractBinding
        )
        XCTAssertEqual(
            Set(
                try topology.transitiveLocalTargetNames(
                    reachableFrom: "PrimeCore"
                )
            ),
            Set(
                try previous.transitiveLocalTargetNames(
                    reachableFrom: "PrimeCore"
                )
            )
        )
    }

    func testAllV1ThroughV26CanonicalTopologyHashesRemainExact()
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
            (.frozenV24, "711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91"),
            (.frozenV25, "a5907c0d1505c004a4fbd67193d2b1f7f640cd8c8906fdd94cdbed6eab667ba3"),
            (.frozenV26, Self.topologyV26SHA256),
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
                    .historicalWorkerInvocationSeamPrivateAccessRebindingSourceContractBinding
            )
        }
    }

    func testFrozenV27CanonicalRoundTripAndHash() throws {
        let topology = Topology.frozenV27
        let canonical = try PrimeCanonicalJSON.encode(topology)
        let decoded = try PrimeCanonicalJSON.decode(
            Topology.self,
            from: canonical
        )
        let plain = try JSONDecoder().decode(
            Topology.self,
            from: canonical
        )

        XCTAssertEqual(decoded, topology)
        XCTAssertEqual(plain, topology)
        XCTAssertNoThrow(try decoded.validate())
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Self.topologyV27SHA256
        )
        XCTAssertEqual(
            try topology.contentSHA256(),
            Self.topologyV27SHA256
        )
    }

    func testEveryV27CanonicalFieldMutationFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV27)
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
            try assertDecodingOrValidationFails(
                try JSONSerialization.data(
                    withJSONObject: mutation,
                    options: [.sortedKeys]
                ),
                path.joined(separator: ".")
            )
        }
    }

    func testEveryV27CanonicalFieldIsRequiredAndRejectsNull()
        throws
    {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV27)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )

        for path in requiredFieldPaths(in: object) {
            let label = path.joined(separator: ".")
            try assertDecodingOrValidationFails(
                try JSONSerialization.data(
                    withJSONObject: removingValue(in: object, at: path),
                    options: [.sortedKeys]
                ),
                "missing \(label)"
            )
            try assertDecodingOrValidationFails(
                try JSONSerialization.data(
                    withJSONObject: replacingValue(
                        in: object,
                        at: path,
                        with: { _ in NSNull() }
                    ),
                    options: [.sortedKeys]
                ),
                "null \(label)"
            )
        }
    }

    func testV27BindingAndAuthorityMutationsFailClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV27)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let binding = try XCTUnwrap(
            object[Self.sourceBindingKey] as? [String: Any]
        )
        var mutations: [[String: Any]] = []

        for nestedKey in ["contract_id", "content_sha256"] {
            var mutation = object
            var drift = binding
            drift[nestedKey] = String(repeating: "f", count: 64)
            mutation[Self.sourceBindingKey] = drift
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
        var statusMutation = object
        statusMutation["status"] = "implemented"
        mutations.append(statusMutation)
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
                "V27 binding/authority mutation \(index)"
            )
        }
    }

    func testUnknownCanonicalV27TopologyKeyFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV27)
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
        XCTAssertEqual(plain, .frozenV27)
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

    private func assertDecodingOrValidationFails(
        _ data: Data,
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        do {
            let decoded = try JSONDecoder().decode(
                Topology.self,
                from: data
            )
            XCTAssertThrowsError(
                try decoded.validate(),
                label,
                file: file,
                line: line
            )
        } catch {
            // A decoding rejection is also fail-closed.
        }
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
