// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignTopologyV26Tests:
    XCTestCase
{
    private typealias Design =
        PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContract
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    private static let designContractSHA256 =
        "58bd67d365c38337b1eda6d2ca8e28422125f424ff7eccec72ca151a91dd4f8e"
    private static let topologyV26SHA256 =
        "dfbba4e7adecac57febd8ab0946ab34f698d63d6b55d3fe119fe53c029c8da63"
    private static let topologyV25SHA256 =
        "a5907c0d1505c004a4fbd67193d2b1f7f640cd8c8906fdd94cdbed6eab667ba3"
    private static let designBindingKey =
        "historical_worker_invocation_seam_private_access_rebinding_design_contract_binding"

    func testFrozenV26BindsOnlyTheReviewedDesignAndAuthorityCeiling()
        throws
    {
        let design = Design.frozenV1
        let topology = Topology.frozenV26
        let designSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(design)
        )

        XCTAssertNoThrow(try design.validate())
        XCTAssertNoThrow(try topology.validate())
        XCTAssertEqual(designSHA256, Self.designContractSHA256)
        XCTAssertEqual(topology.schemaVersion, 26)
        XCTAssertEqual(
            topology.contractID,
            "prime_stage_b_historical_worker_bounded_unavailable_composition_invocation_seam_private_access_rebinding_security_design_topology_v26"
        )
        XCTAssertEqual(
            topology
                .historicalWorkerInvocationSeamPrivateAccessRebindingDesignContractID,
            design.contractID
        )
        XCTAssertEqual(
            topology
                .historicalWorkerInvocationSeamPrivateAccessRebindingDesignContractSHA256,
            Self.designContractSHA256
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
                "bound_design_\(design.contractID)_sha256_\(Self.designContractSHA256)"
            )
        )
        XCTAssertTrue(
            topology.packageCaptureAuthority.contains(
                "not_checked_in_private_rebinding_release_product_build"
            )
        )

        for claim in [
            "preserves every V1 through V25 canonical identity",
            "checked-in worker remains the exact 14,175-byte V25 source",
            "half-open zero-based byte range 12,555..<12,563",
            "worker-source frontend typechecking",
            "ordinary direct Swift naming",
            "returned versus threw plus timing, resource, and crash behavior",
            "Prime remains ABSTAIN",
        ] {
            XCTAssertTrue(
                topology.authorityStatement.contains(claim),
                claim
            )
        }
    }

    func testV26CanonicalDeltaFromV25HasExactlySixKeys()
        throws
    {
        let previousObject = try canonicalObject(Topology.frozenV25)
        let topologyObject = try canonicalObject(Topology.frozenV26)
        let sharedChangedKeys: Set<String> = [
            "schema_version",
            "contract_id",
            "package_capture_authority",
            "next_implementation_prerequisite",
            "authority_statement",
        ]
        let exactChangedKeys =
            sharedChangedKeys.union([Self.designBindingKey])

        XCTAssertEqual(
            Set(topologyObject.keys)
                .subtracting(Set(previousObject.keys)),
            [Self.designBindingKey]
        )
        XCTAssertTrue(
            Set(previousObject.keys)
                .subtracting(Set(topologyObject.keys))
                .isEmpty
        )
        XCTAssertNil(previousObject[Self.designBindingKey])
        XCTAssertNotNil(topologyObject[Self.designBindingKey])

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

    func testV26GraphReachabilityPackageAndPriorBindingsRemainExact()
        throws
    {
        let previous = Topology.frozenV25
        let topology = Topology.frozenV26

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
                .historicalWorkerInvocationSeamCallerAndResultConsumerSourceContractBinding,
            previous
                .historicalWorkerInvocationSeamCallerAndResultConsumerSourceContractBinding
        )
        XCTAssertNil(
            previous
                .historicalWorkerInvocationSeamPrivateAccessRebindingDesignContractBinding
        )
        XCTAssertNotNil(
            topology
                .historicalWorkerInvocationSeamPrivateAccessRebindingDesignContractBinding
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

    func testV23ThroughV25CanonicalHashesRemainExact() throws {
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(Topology.frozenV23)
            ),
            "48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(Topology.frozenV24)
            ),
            "711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91"
        )
        XCTAssertEqual(
            PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(Topology.frozenV25)
            ),
            Self.topologyV25SHA256
        )
    }

    func testFrozenV26CanonicalRoundTripAndHash() throws {
        let topology = Topology.frozenV26
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
            Self.topologyV26SHA256
        )
        XCTAssertEqual(
            try topology.contentSHA256(),
            Self.topologyV26SHA256
        )
    }

    func testEveryV26CanonicalFieldMutationFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV26)
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

    func testEveryV26CanonicalFieldIsRequiredAndRejectsNull()
        throws
    {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV26)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )

        for path in requiredFieldPaths(in: object) {
            let label = path.joined(separator: ".")
            let missing = try JSONSerialization.data(
                withJSONObject: removingValue(in: object, at: path),
                options: [.sortedKeys]
            )
            try assertDecodingOrValidationFails(
                missing,
                "missing \(label)"
            )
            let null = try JSONSerialization.data(
                withJSONObject: replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                options: [.sortedKeys]
            )
            try assertDecodingOrValidationFails(
                null,
                "null \(label)"
            )
        }
    }

    func testV26BindingAndAuthorityMutationsFailClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV26)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let binding = try XCTUnwrap(
            object[Self.designBindingKey] as? [String: Any]
        )
        var mutations: [[String: Any]] = []

        for nestedKey in ["contract_id", "content_sha256"] {
            var mutation = object
            var drift = binding
            drift[nestedKey] = String(repeating: "f", count: 64)
            mutation[Self.designBindingKey] = drift
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
                "V26 binding/authority mutation \(index)"
            )
        }
    }

    func testUnknownCanonicalV26TopologyKeyFailsClosed() throws {
        let canonical = try PrimeCanonicalJSON.encode(Topology.frozenV26)
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
        XCTAssertEqual(plain, .frozenV26)
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
