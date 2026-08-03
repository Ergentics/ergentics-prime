// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeNeuralGateHistoricalTopologyValidationWorkflowTests:
    XCTestCase
{
    private typealias Topology =
        PrimeNativeNeuralGateTrapDisjointTopologyContract

    private static let topologyRelativePath =
        "Sources/PrimeCore/PrimeNativeNeuralGateTrapDisjointTopology.swift"

    func testHistoricalBindingsValidateOnlyAtIntroductionVersion()
        throws
    {
        let body = try topologyValidationSource()
        let directThrowingValidation = try NSRegularExpression(
            pattern:
                #"\btry[?!]?\s+[A-Za-z_][A-Za-z0-9_]*\s*\.\s*validate\s*\("#
        )

        for version in 17 ... 20 {
            XCTAssertTrue(
                body.contains("if schemaVersion == \(version)"),
                "V\(version) must validate its bound contract at introduction"
            )
            XCTAssertTrue(
                body.contains("else if schemaVersion > \(version)"),
                "later schemas must verify retained V\(version) receipts"
            )
            XCTAssertFalse(
                body.contains("schemaVersion >= \(version)"),
                "later schemas must not replay the V\(version) validator"
            )
            let retainedBranch = try retainedBindingBranch(
                for: version,
                in: body
            )
            XCTAssertNil(
                directThrowingValidation.firstMatch(
                    in: retainedBranch,
                    range: NSRange(
                        retainedBranch.startIndex ..< retainedBranch.endIndex,
                        in: retainedBranch
                    )
                ),
                "later schemas must not directly replay V\(version) validation"
            )
            XCTAssertFalse(
                retainedBranch.contains(".contentSHA256()"),
                "later schemas must not indirectly revalidate frozen V\(version) content"
            )
        }

        XCTAssertFalse(
            body.contains(".contentSHA256()"),
            "topology validation must not call a hash API that revalidates"
        )
    }

    func testV17ThroughV27CanonicalTopologyHashesRemainExact()
        throws
    {
        let frozen: [(Topology, String)] = [
            (.frozenV17, "3a14288df628b1d44936013af44dd237e876fd1cf2b38e4ce0afd3a4c5cd2166"),
            (.frozenV18, "aa9dd4031469742fca5d0241bd329e7712d98ec81677704fbca911d5bdcf043f"),
            (.frozenV19, "84f07261ff86dab5836e96a2667a8d3a05b0ec597b9677d5f1bab77c2c8801ba"),
            (.frozenV20, "b8045480883016fd49e7a63b02437f54835c1e7de6e61a4c2dea7f439a052a57"),
            (.frozenV21, "6d9e2787b54b6ab20f449497e6ac2b91c9945567211badfd4383f37b417f14a4"),
            (.frozenV22, "af914f70b10917e95b895fbf1fc24c6e52764893972d6616bdbb409ba712f4f5"),
            (.frozenV23, "48f5f1359af1eb3151196ef1e9cb417a6189d8c6461b0c3e595edee39aaee3d9"),
            (.frozenV24, "711f57d47575f7f166bee5f2b32708d3a86631406a3a3b96f370e1de1da8ce91"),
            (.frozenV25, "a5907c0d1505c004a4fbd67193d2b1f7f640cd8c8906fdd94cdbed6eab667ba3"),
            (.frozenV26, "dfbba4e7adecac57febd8ab0946ab34f698d63d6b55d3fe119fe53c029c8da63"),
            (.frozenV27, "a572b5813e0410235f387222f6399c2984fcb52da69f4bd9393a5adf6869cd7c"),
        ]

        for (topology, expectedSHA256) in frozen {
            XCTAssertEqual(
                PrimeSHA256.hexDigest(
                    of: try PrimeCanonicalJSON.encode(topology)
                ),
                expectedSHA256,
                topology.contractID
            )
        }
    }

    private func topologyValidationSource() throws -> String {
        let source = try String(
            contentsOf: repositoryRoot
                .appendingPathComponent(Self.topologyRelativePath),
            encoding: .utf8
        )
        let start = try XCTUnwrap(
            source.range(of: "    public func validate() throws {")
        )
        let end = try XCTUnwrap(
            source.range(
                of: "    public func contentSHA256() throws -> String {",
                range: start.upperBound ..< source.endIndex
            )
        )
        return String(source[start.lowerBound ..< end.lowerBound])
    }

    private func retainedBindingBranch(
        for version: Int,
        in body: String
    ) throws -> String {
        let start = try XCTUnwrap(
            body.range(
                of: "        } else if schemaVersion > \(version) {"
            )
        )
        let end = try XCTUnwrap(
            body.range(
                of: "        } else {",
                range: start.upperBound ..< body.endIndex
            )
        )
        return String(body[start.lowerBound ..< end.lowerBound])
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
