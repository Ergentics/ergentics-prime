import Darwin
import Foundation
import XCTest
@testable import PrimeCore
@testable import PrimeLatinProposalValidationCompositionReceipt
@testable import PrimeLatinProposalValidationCompositionReceiptPublisher

final class PrimeLatinProposalValidationCompositionReceiptPublisherV1Tests:
    XCTestCase
{
    typealias Projection =
        PrimeLatinProposalValidationCompositionReceiptProjectionV1
    typealias PublisherError =
        PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1

    private var temporaryRoot: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        temporaryRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-latin-receipt-publisher-tests-" +
                    UUID().uuidString,
                isDirectory: true)
        try FileManager.default.createDirectory(
            at: temporaryRoot,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700])
        XCTAssertEqual(chmod(temporaryRoot.path, 0o700), 0)
    }

    override func tearDownWithError() throws {
        if let temporaryRoot {
            try? FileManager.default.removeItem(at: temporaryRoot)
        }
        temporaryRoot = nil
        try super.tearDownWithError()
    }

    func testPublishesCanonicalContentAddressedReceiptAndExactAuthority()
        throws
    {
        let fixture = try makeArtifactRoot(named: "success")
        var recaptureCount = 0
        let observation = try publisher(
            root: fixture.root,
            recapture: {
                recaptureCount += 1
                return .exactFinal
            })
        XCTAssertEqual(recaptureCount, 1)

        XCTAssertEqual(
            observation.schema,
            "ergentics_prime_latin_proposal_v3_validation_composition_" +
                "receipt_publication_observation_v1")
        XCTAssertEqual(observation.outcome, "abstain")
        XCTAssertEqual(
            observation.verificationScope,
            "prime_owned_descriptor_safe_exclusive_content_addressed_" +
                "publication_of_one_canonical_validation_composition_" +
                "receipt_only_non_authorizing")
        XCTAssertEqual(
            observation.publicationPolicyID,
            "prime_latin_v3_validation_composition_receipt_publication_v1")

        let canonical = try PrimeCanonicalJSON.encode(observation.receipt)
        let digest = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(canonical.count, 4_744)
        XCTAssertEqual(
            digest,
            "99517013a20c48962e9f8f1a19687e1158f0ce24e225bc30dd8487aca3d25832")
        let expectedPath = try
            PrimeLatinProposalValidationCompositionReceiptContractV1
                .relativePath(forSHA256: digest)
        XCTAssertEqual(
            expectedPath,
            "latin-validation-composition-receipts/" + digest + ".json")
        XCTAssertEqual(
            observation.artifactBinding,
            PrimeArtifactBinding(
                relativePath: expectedPath,
                sha256: digest,
                byteCount: UInt64(canonical.count),
                purpose: .immutableData))
        XCTAssertEqual(
            observation.verifiedArtifact.binding,
            observation.artifactBinding)
        XCTAssertEqual(observation.verifiedArtifact.actualMode, 0o444)
        XCTAssertEqual(
            try fixture.root.readVerified(
                observation.artifactBinding,
                maximumByteCount:
                    PrimeLatinProposalValidationCompositionReceiptV1
                        .maximumByteCount),
            canonical)
        XCTAssertEqual(
            try fixture.root.decodeVerified(
                PrimeLatinProposalValidationCompositionReceiptV1.self,
                binding: observation.artifactBinding,
                maximumByteCount:
                    PrimeLatinProposalValidationCompositionReceiptV1
                        .maximumByteCount),
            observation.receipt)

        let authority = observation.authority
        XCTAssertEqual(
            authority.disposition,
            "abstain_durable_validation_composition_receipt_published_" +
                "decoded_receipt_does_not_restore_live_validation_or_" +
                "establish_proposal_admission_packet_trial_runtime_" +
                "selection_promotion_product_or_publication_authority")
        let requiredTrue: [(String, Bool)] = [
            ("validationCompositionCaptureAndRecaptureComplete",
             authority.validationCompositionCaptureAndRecaptureComplete),
            ("validationCompositionAuthorityBoundaryExact",
             authority.validationCompositionAuthorityBoundaryExact),
            ("exactReceiptProjectionComplete",
             authority.exactReceiptProjectionComplete),
            ("canonicalReceiptEncodingComplete",
             authority.canonicalReceiptEncodingComplete),
            ("canonicalReceiptRedecodeComplete",
             authority.canonicalReceiptRedecodeComplete),
            ("receiptContentAddressBindingVerified",
             authority.receiptContentAddressBindingVerified),
            ("privateArtifactRootModeVerified",
             authority.privateArtifactRootModeVerified),
            ("artifactRootEmptyAtAdmission",
             authority.artifactRootEmptyAtAdmission),
            ("artifactRootEmptyAtFinalPrepublicationMutationCheck",
             authority.artifactRootEmptyAtFinalPrepublicationMutationCheck),
            ("exclusiveNoReplacePublicationComplete",
             authority.exclusiveNoReplacePublicationComplete),
            ("immutableSingleLinkReceiptArtifactVerified",
             authority.immutableSingleLinkReceiptArtifactVerified),
            ("receiptFileDurabilitySyncComplete",
             authority.receiptFileDurabilitySyncComplete),
            ("receiptDirectoryDurabilitySyncComplete",
             authority.receiptDirectoryDurabilitySyncComplete),
            ("durableValidationCompositionReceiptPublished",
             authority.durableValidationCompositionReceiptPublished),
            ("primeDurableReceiptPublished",
             authority.primeDurableReceiptPublished),
        ]
        XCTAssertEqual(requiredTrue.count, 15)
        for (field, value) in requiredTrue {
            XCTAssertTrue(value, "expected true publication field: \(field)")
        }

        let requiredFalse: [(String, Bool)] = [
            ("atomicCrossProcessSnapshotEstablished",
             authority.atomicCrossProcessSnapshotEstablished),
            ("exclusiveArtifactRootOwnershipEstablished",
             authority.exclusiveArtifactRootOwnershipEstablished),
            ("postPublicationSourceRecaptureComplete",
             authority.postPublicationSourceRecaptureComplete),
            ("compilerCryptographicallyAuthenticated",
             authority.compilerCryptographicallyAuthenticated),
            ("externalSourceToBinaryAttestationAvailable",
             authority.externalSourceToBinaryAttestationAvailable),
            ("publisherIdentityCryptographicallyAuthenticated",
             authority.publisherIdentityCryptographicallyAuthenticated),
            ("receiptCryptographicallySigned",
             authority.receiptCryptographicallySigned),
            ("originRemoteCryptographicallyAuthenticated",
             authority.originRemoteCryptographicallyAuthenticated),
            ("ignoredWorkspaceBytesObserved",
             authority.ignoredWorkspaceBytesObserved),
            ("declarationSourceSemanticsIndependentlyVerified",
             authority.declarationSourceSemanticsIndependentlyVerified),
            ("tokenizerModelSemanticsIndependentlyValidated",
             authority.tokenizerModelSemanticsIndependentlyValidated),
            ("tokenizerTrainingReplayComplete",
             authority.tokenizerTrainingReplayComplete),
            ("evaluationExecutionComplete",
             authority.evaluationExecutionComplete),
            ("selectionObservationComplete",
             authority.selectionObservationComplete),
            ("durableInputSnapshotPublished",
             authority.durableInputSnapshotPublished),
            ("durableGitObservationPublished",
             authority.durableGitObservationPublished),
            ("durableProducerRevalidationObservationPublished",
             authority.durableProducerRevalidationObservationPublished),
            ("durableIndependentReplayObservationPublished",
             authority.durableIndependentReplayObservationPublished),
            ("durableValidationCompositionObservationPublished",
             authority.durableValidationCompositionObservationPublished),
            ("rawProducerRevalidationObservationPublished",
             authority.rawProducerRevalidationObservationPublished),
            ("rawIndependentReplayObservationPublished",
             authority.rawIndependentReplayObservationPublished),
            ("currentLiveProducerWorkspaceRevalidationRestoredFromReceipt",
             authority
                .currentLiveProducerWorkspaceRevalidationRestoredFromReceipt),
            ("currentIndependentPrimeReplayRestoredFromReceipt",
             authority.currentIndependentPrimeReplayRestoredFromReceipt),
            ("runtimeDecoderImplementationAvailable",
             authority.runtimeDecoderImplementationAvailable),
            ("runtimeDependencyClosureEstablished",
             authority.runtimeDependencyClosureEstablished),
            ("runtimeInitializationEstablished",
             authority.runtimeInitializationEstablished),
            ("primeProposalPolicyEstablished",
             authority.primeProposalPolicyEstablished),
            ("proposalAdmissionEvaluationComplete",
             authority.proposalAdmissionEvaluationComplete),
            ("proposalAdmissionGranted",
             authority.proposalAdmissionGranted),
            ("primeProposalPacketProduced",
             authority.primeProposalPacketProduced),
            ("primeTrialAuthorizationProduced",
             authority.primeTrialAuthorizationProduced),
            ("primeDecisionReceiptProduced",
             authority.primeDecisionReceiptProduced),
            ("candidateSelectionAuthorized",
             authority.candidateSelectionAuthorized),
            ("trialExecutionAuthorized",
             authority.trialExecutionAuthorized),
            ("furtherTrainingAuthorized",
             authority.furtherTrainingAuthorized),
            ("promotionAuthorized", authority.promotionAuthorized),
            ("productUseAuthorized", authority.productUseAuthorized),
            ("publicationAuthorized", authority.publicationAuthorized),
            ("proposalPairPublicationPerformedByThisPublisher",
             authority.proposalPairPublicationPerformedByThisPublisher),
            ("publicNetworkPublicationPerformed",
             authority.publicNetworkPublicationPerformed),
        ]
        XCTAssertEqual(requiredFalse.count, 40)
        for (field, value) in requiredFalse {
            XCTAssertFalse(value, "expected false publication field: \(field)")
        }
    }

    func testPrivateAndEmptyRootAdmissionFailsBeforeMutation() throws {
        let permissive = try makeArtifactRoot(
            named: "not-private",
            mode: 0o755)
        assertPublisherError(.publicationFailed) {
            try publisher(root: permissive.root)
        }
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: permissive.url.path),
            [])

        let occupied = try makeArtifactRoot(named: "occupied")
        let sentinel = occupied.url.appendingPathComponent("sentinel")
        try Data("preserved".utf8).write(to: sentinel)
        XCTAssertEqual(chmod(sentinel.path, 0o444), 0)
        assertPublisherError(.publicationFailed) {
            try publisher(root: occupied.root)
        }
        XCTAssertEqual(try Data(contentsOf: sentinel), Data("preserved".utf8))
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: occupied.url.path),
            ["sentinel"])
    }

    func testRecaptureDriftLeavesRootUnchangedAndAllowsFreshRetry() throws {
        let fixture = try makeArtifactRoot(named: "recapture-drift")
        var changed = Projection.exactFinal
        changed.outputNamespace += "-drift"
        assertPublisherError(.captureChanged) {
            try publisher(root: fixture.root, recapture: { changed })
        }
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.url.path),
            [])

        let published = try publisher(root: fixture.root)
        XCTAssertEqual(
            published.artifactBinding.relativePath,
            try expectedReceiptPath())
    }

    func testInvalidInitialProjectionLeavesRootUnchangedAndAllowsFreshRetry()
        throws
    {
        let fixture = try makeArtifactRoot(named: "invalid-initial")
        var invalid = Projection.exactFinal
        invalid.outputNamespace += "-invalid"

        assertPublisherError(
            .invalidSourceObservation("initial_receipt_projection")
        ) {
            try PrimeLatinProposalValidationCompositionReceiptPublisherV1
                .publishForTesting(
                    initialProjection: invalid,
                    artifactRoot: fixture.root,
                    recaptureProjection: { .exactFinal })
        }
        XCTAssertEqual(
            try FileManager.default.contentsOfDirectory(
                atPath: fixture.url.path),
            [])

        let published = try publisher(root: fixture.root)
        XCTAssertEqual(
            published.artifactBinding.relativePath,
            try expectedReceiptPath())
    }

    func testRootMutationDuringRecaptureFailsSecondEmptyGateAndPoisonsRoot()
        throws
    {
        let fixture = try makeArtifactRoot(named: "recapture-root-mutation")
        let sentinel = fixture.url.appendingPathComponent("sentinel")

        assertPublisherError(.publicationFailed) {
            try publisher(
                root: fixture.root,
                recapture: {
                    try Data("preserved".utf8).write(to: sentinel)
                    XCTAssertEqual(chmod(sentinel.path, 0o444), 0)
                    return .exactFinal
                })
        }

        XCTAssertEqual(try Data(contentsOf: sentinel), Data("preserved".utf8))
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: fixture.url.appendingPathComponent(
                    "latin-validation-composition-receipts",
                    isDirectory: true).path))
        assertPublisherError(.publicationFailed) {
            try publisher(root: fixture.root)
        }
        XCTAssertEqual(try Data(contentsOf: sentinel), Data("preserved".utf8))
    }

    func testDestinationSymlinkRaceIsNoReplaceAndPoisonsRoot() throws {
        let fixture = try makeArtifactRoot(named: "destination-race")
        let relativePath = try expectedReceiptPath()
        let racedURL = fixture.url.appendingPathComponent(relativePath)
        let missingTarget = temporaryRoot.appendingPathComponent(
            "missing-race-target")
        var hookRan = false

        assertPublisherError(.publicationFailed) {
            try publisher(
                root: fixture.root,
                afterDirectoryCreated: {
                    hookRan = true
                    try FileManager.default.createSymbolicLink(
                        at: racedURL,
                        withDestinationURL: missingTarget)
                })
        }
        XCTAssertTrue(hookRan)
        let values = try racedURL.resourceValues(
            forKeys: [.isSymbolicLinkKey])
        XCTAssertEqual(values.isSymbolicLink, true)

        assertPublisherError(.publicationFailed) {
            try publisher(root: fixture.root)
        }
        XCTAssertEqual(
            try FileManager.default.destinationOfSymbolicLink(
                atPath: racedURL.path),
            missingTarget.path)
    }

    func testPostPublicationModeHardLinkAndCanonicalDriftFailVerification()
        throws
    {
        do {
            let fixture = try makeArtifactRoot(named: "mode-drift")
            var hookRan = false
            assertPublisherError(.verificationFailed) {
                try publisher(
                    root: fixture.root,
                    afterExclusivePublication: { binding in
                        hookRan = true
                        XCTAssertEqual(
                            chmod(
                                fixture.url.appendingPathComponent(
                                    binding.relativePath).path,
                                0o644),
                            0)
                    })
            }
            XCTAssertTrue(hookRan)
            assertPublisherError(.publicationFailed) {
                try publisher(root: fixture.root)
            }
        }

        do {
            let fixture = try makeArtifactRoot(named: "hard-link-drift")
            let alias = fixture.url.appendingPathComponent("receipt-alias")
            var hookRan = false
            assertPublisherError(.verificationFailed) {
                try publisher(
                    root: fixture.root,
                    afterExclusivePublication: { binding in
                        hookRan = true
                        XCTAssertEqual(
                            Darwin.link(
                                fixture.url.appendingPathComponent(
                                    binding.relativePath).path,
                                alias.path),
                            0)
                    })
            }
            XCTAssertTrue(hookRan)
            var metadata = stat()
            XCTAssertEqual(lstat(alias.path, &metadata), 0)
            XCTAssertEqual(metadata.st_nlink, 2)
        }

        do {
            let fixture = try makeArtifactRoot(named: "canonical-drift")
            var hookRan = false
            assertPublisherError(.verificationFailed) {
                try publisher(
                    root: fixture.root,
                    afterExclusivePublication: { binding in
                        hookRan = true
                        let receiptURL = fixture.url.appendingPathComponent(
                            binding.relativePath)
                        XCTAssertEqual(chmod(receiptURL.path, 0o600), 0)
                        var noncanonical = try Data(contentsOf: receiptURL)
                        noncanonical.append(0x0a)
                        try noncanonical.write(to: receiptURL)
                        XCTAssertEqual(chmod(receiptURL.path, 0o444), 0)
                    })
            }
            XCTAssertTrue(hookRan)
        }
    }

    private func publisher(
        root: PrimeArtifactRoot,
        recapture: () throws -> Projection = { .exactFinal },
        afterDirectoryCreated: () throws -> Void = {},
        afterExclusivePublication:
            (PrimeArtifactBinding) throws -> Void = { _ in }
    ) throws
        -> PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1
    {
        try PrimeLatinProposalValidationCompositionReceiptPublisherV1
            .publishForTesting(
                initialProjection: .exactFinal,
                artifactRoot: root,
                recaptureProjection: recapture,
                afterDirectoryCreated: afterDirectoryCreated,
                afterExclusivePublication: afterExclusivePublication)
    }

    private func makeArtifactRoot(
        named name: String,
        mode: mode_t = 0o700
    ) throws -> (url: URL, root: PrimeArtifactRoot) {
        let url = temporaryRoot.appendingPathComponent(
            name,
            isDirectory: true)
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: NSNumber(value: mode)])
        XCTAssertEqual(chmod(url.path, mode), 0)
        return (url, try PrimeArtifactRoot(directoryURL: url))
    }

    private func expectedReceiptPath() throws -> String {
        let receipt = try
            PrimeLatinProposalValidationCompositionReceiptV1(
                projecting: .exactFinal)
        let data = try PrimeCanonicalJSON.encode(receipt)
        return try
            PrimeLatinProposalValidationCompositionReceiptContractV1
                .relativePath(
                    forSHA256: PrimeSHA256.hexDigest(of: data))
    }

    private func assertPublisherError<T>(
        _ expected: PublisherError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ body: () throws -> T
    ) {
        XCTAssertThrowsError(
            try body(),
            file: file,
            line: line
        ) { error in
            XCTAssertEqual(
                error as? PublisherError,
                expected,
                file: file,
                line: line)
        }
    }
}
