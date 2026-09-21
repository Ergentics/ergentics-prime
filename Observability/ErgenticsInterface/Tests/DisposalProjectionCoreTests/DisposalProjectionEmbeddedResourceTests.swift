import Foundation
@testable import DisposalProjectionCore
import XCTest

final class DisposalProjectionEmbeddedResourceTests: XCTestCase {
    func testEmbeddedPackMatchesEveryUnchangedReferenceFixture() throws {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let referenceRoot = packageRoot.appendingPathComponent(
            "Sources/DisposalProjectionCore/Resources")
        let embedded = try DisposalProjectionEmbeddedResources.exact()
        let values = embedded.orderedValues()

        XCTAssertEqual(
            DisposalProjectionEmbeddedResources.specifications.count,
            values.count)
        for (specification, value) in zip(
            DisposalProjectionEmbeddedResources.specifications,
            values)
        {
            let reference = try Data(contentsOf: referenceRoot.appendingPathComponent(
                specification.leaf))
            XCTAssertEqual(value, reference, specification.leaf)
            XCTAssertEqual(value.count, specification.bytes, specification.leaf)
            XCTAssertEqual(disposalSHA256(value), specification.sha256, specification.leaf)
        }
        try DisposalProjectionEmbeddedResources.validate(embedded)
        XCTAssertEqual(
            DisposalProjectionEmbeddedResources.packCommitmentSHA256,
            "a35466c0d654c9d9c8c3da3b86fb886d1d01ce4f4487d84bdd57b46031f70f51")
    }

    func testDefaultResourceLookupIsEmbeddedAndFailClosed() throws {
        let evidence = try disposalResourceData("001-evidence", extension: "sql")
        XCTAssertEqual(evidence.count, 50_706)
        XCTAssertEqual(
            disposalSHA256(evidence),
            "f3e003136aa4f9a12308d310ffa6bc92d71bccb99a7a50656c32231b79a435c7")
        XCTAssertThrowsError(try disposalResourceData("unknown", extension: "bin")) {
            XCTAssertEqual(
                (error as? DisposalProjectionRejection)?.code,
                "RESOURCE_ABSENT")
        }
    }
}
