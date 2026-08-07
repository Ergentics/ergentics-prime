import CryptoKit
import Foundation
import XCTest
import PrimeLatinProposalPairCapture

final class PrimeLatinProposalPairCaptureTests: XCTestCase {
    func testCanonicalPairIsCapturedAsMechanicsOnlyAbstention() throws {
        let fixture = try PairFixture()

        let capture = try PrimeLatinProposalPairCapture.capture(
            labRoot: fixture.labRoot,
            pairSHA256: fixture.pairSHA256)

        XCTAssertEqual(capture.observation.pairReceiptSHA256, fixture.pairSHA256)
        XCTAssertEqual(
            capture.observation.llmSource.repository,
            "Ergentics/ergentics-llm")
        XCTAssertEqual(capture.observation.llmSource.commit, PairFixture.commit)
        XCTAssertEqual(capture.observation.llmSource.tree, PairFixture.tree)
        XCTAssertEqual(capture.observation.candidateIDs, ["latin_candidate_a"])
        XCTAssertEqual(
            capture.observation.outputNamespace,
            "models/latin-prospective/fixture_v2")

        let authority = capture.observation.authority
        XCTAssertFalse(authority.referencedInputSnapshotAvailable)
        XCTAssertFalse(authority.independentReplayComplete)
        XCTAssertFalse(authority.llmGitStateIndependentlyObserved)
        XCTAssertFalse(authority.producerClaimsIndependentlyRecomputed)
        XCTAssertFalse(authority.primeProposalPacketProduced)
        XCTAssertFalse(authority.primeTrialAuthorizationProduced)
        XCTAssertFalse(authority.trialExecutionAuthorized)
        XCTAssertFalse(authority.furtherTrainingAuthorized)
        XCTAssertFalse(authority.promotionAuthorized)
        XCTAssertFalse(authority.productUseAuthorized)
        XCTAssertEqual(
            authority.disposition,
            "abstain_requires_original_bound_input_bytes")

        XCTAssertEqual(
            try capture.recaptureAndValidateUnchanged(),
            capture.observation)

        let summary = capture.ephemeralSummary()
        XCTAssertEqual(
            summary.schema,
            "ergentics_prime_latin_proposal_pair_capture_summary_v1")
        XCTAssertEqual(summary.outcome, "abstain")
        XCTAssertEqual(
            summary.claimScope,
            "mechanics_transport_capture_only_non_authorizing")
        XCTAssertEqual(summary.pairReceiptSHA256, fixture.pairSHA256)
        XCTAssertFalse(summary.durableReceiptPublished)
        XCTAssertTrue(summary.ephemeralStandardOutputOnly)
        XCTAssertFalse(summary.primeProposalPacketProduced)
        XCTAssertFalse(summary.primeTrialAuthorizationProduced)
        XCTAssertFalse(summary.trialExecutionAuthorized)
        XCTAssertFalse(summary.furtherTrainingAuthorized)
        XCTAssertFalse(summary.promotionAuthorized)
        XCTAssertFalse(summary.productUseAuthorized)
        let summaryData = try summary.canonicalData()
        XCTAssertEqual(
            try JSONSerialization.data(
                withJSONObject: JSONSerialization.jsonObject(with: summaryData),
                options: [.sortedKeys, .withoutEscapingSlashes]),
            summaryData)
    }

    func testLocatorAndArgumentsRequireExactContentAddressedInput() throws {
        let fixture = try PairFixture()
        let locator = try PrimeLatinProposalPairLocator(
            sha256: fixture.pairSHA256)
        XCTAssertEqual(locator.sha256, fixture.pairSHA256)
        XCTAssertEqual(
            locator.relativePath,
            "evidence/latin-proposal-artifacts/pairs/" +
                "\(fixture.pairSHA256).json")

        let arguments = try PrimeLatinProposalPairCaptureArguments.parse([
            "--lab-root", fixture.labRoot.path,
            "--pair-sha256", fixture.pairSHA256,
        ])
        XCTAssertEqual(arguments.labRoot, fixture.labRoot)
        XCTAssertEqual(arguments.pairSHA256, fixture.pairSHA256)

        let invalidArguments = [
            ["--pair-sha256", fixture.pairSHA256,
             "--lab-root", fixture.labRoot.path],
            ["--lab-root", fixture.labRoot.path],
            ["--lab-root", fixture.labRoot.path,
             "--pair-sha256", fixture.pairSHA256,
             "--extra", "value"],
            ["--lab-root", ".",
             "--pair-sha256", fixture.pairSHA256],
            ["--lab-root", fixture.labRoot.path,
             "--pair-sha256", fixture.pairSHA256.uppercased()],
        ]
        for values in invalidArguments {
            XCTAssertThrowsError(
                try PrimeLatinProposalPairCaptureArguments.parse(values),
                "unexpectedly accepted arguments: \(values)")
        }

        for value in [
            "",
            String(repeating: "a", count: 63),
            String(repeating: "a", count: 65),
            String(repeating: "g", count: 64),
            String(repeating: "A", count: 64),
        ] {
            XCTAssertThrowsError(
                try PrimeLatinProposalPairLocator(sha256: value))
        }
    }

    func testUnknownAndNoncanonicalWireDocumentsAreRejected() throws {
        let wrongReceiptSchema = try PairFixture(receiptMutation: {
            $0["schema"] = "ergentics_latin_proposal_pair_receipt_v2"
        })
        XCTAssertCaptureFails(wrongReceiptSchema)

        let wrongCatalogSchema = try PairFixture(catalogMutation: {
            $0["schema"] = "ergentics_latin_candidate_catalog_v2"
        })
        XCTAssertCaptureFails(wrongCatalogSchema)

        let wrongExperimentSchema = try PairFixture(experimentMutation: {
            $0["schema"] = "ergentics_latin_experiment_manifest_v2"
        })
        XCTAssertCaptureFails(wrongExperimentSchema)

        let unknownReceipt = try PairFixture(receiptMutation: {
            $0["unexpected"] = false
        })
        XCTAssertCaptureFails(unknownReceipt)

        let unknownCatalog = try PairFixture(catalogMutation: {
            $0["unexpected"] = false
        })
        XCTAssertCaptureFails(unknownCatalog)

        let unknownExperiment = try PairFixture(experimentMutation: {
            $0["unexpected"] = false
        })
        XCTAssertCaptureFails(unknownExperiment)

        let noncanonicalReceipt = try PairFixture(
            receiptDataMutation: { $0 + Data("\n".utf8) })
        XCTAssertCaptureFails(noncanonicalReceipt)

        let noncanonicalCatalog = try PairFixture(
            catalogDataMutation: { $0 + Data("\n".utf8) })
        XCTAssertCaptureFails(noncanonicalCatalog)

        let noncanonicalExperiment = try PairFixture(
            experimentDataMutation: { $0 + Data("\n".utf8) })
        XCTAssertCaptureFails(noncanonicalExperiment)
    }

    func testReceiptDocumentHashPathAndByteCountMutationsAreRejected() throws {
        let wrongHash = try PairFixture(receiptMutation: { receipt in
            var document = receipt["candidateCatalog"] as! [String: Any]
            document["sha256"] = String(repeating: "f", count: 64)
            receipt["candidateCatalog"] = document
        })
        XCTAssertCaptureFails(wrongHash)

        let wrongPath = try PairFixture(receiptMutation: { receipt in
            var document = receipt["candidateCatalog"] as! [String: Any]
            document["relativePath"] =
                "evidence/latin-proposal-artifacts/experiments/" +
                "\(document["sha256"] as! String).json"
            receipt["candidateCatalog"] = document
        })
        XCTAssertCaptureFails(wrongPath)

        let traversal = try PairFixture(receiptMutation: { receipt in
            var document = receipt["candidateCatalog"] as! [String: Any]
            document["relativePath"] = "../catalog.json"
            receipt["candidateCatalog"] = document
        })
        XCTAssertCaptureFails(traversal)

        let wrongCount = try PairFixture(receiptMutation: { receipt in
            var document = receipt["experimentManifest"] as! [String: Any]
            document["byteCount"] = (document["byteCount"] as! Int) + 1
            receipt["experimentManifest"] = document
        })
        XCTAssertCaptureFails(wrongCount)

        let wrongKind = try PairFixture(receiptMutation: { receipt in
            var document = receipt["experimentManifest"] as! [String: Any]
            document["documentKind"] = "candidate_catalog"
            receipt["experimentManifest"] = document
        })
        XCTAssertCaptureFails(wrongKind)
    }

    func testSourceAndCatalogExperimentCrossBindingMutationsAreRejected() throws {
        let invalidRepository = try PairFixture(receiptMutation: { receipt in
            var source = receipt["llmSource"] as! [String: Any]
            source["repository"] = "Ergentics/not-ergentics-llm"
            receipt["llmSource"] = source
        })
        XCTAssertCaptureFails(invalidRepository)

        let invalidOID = try PairFixture(receiptMutation: { receipt in
            var source = receipt["llmSource"] as! [String: Any]
            source["commit"] = String(repeating: "A", count: 40)
            receipt["llmSource"] = source
        })
        XCTAssertCaptureFails(invalidOID)

        let sourceMismatch = try PairFixture(catalogMutation: { catalog in
            var source = catalog["llmSource"] as! [String: Any]
            source["tree"] = String(repeating: "e", count: 40)
            catalog["llmSource"] = source
        })
        XCTAssertCaptureFails(sourceMismatch)

        let unapprovedCommit =
            "2fded28b990464595a2ed25d733c8f26cc429eac"
        let unapprovedMatchingSource = try PairFixture(
            catalogMutation: { catalog in
                var source = catalog["llmSource"] as! [String: Any]
                source["commit"] = unapprovedCommit
                catalog["llmSource"] = source
            },
            experimentMutation: { experiment in
                var source = experiment["llmSource"] as! [String: Any]
                source["commit"] = unapprovedCommit
                experiment["llmSource"] = source
            },
            receiptMutation: { receipt in
                var source = receipt["llmSource"] as! [String: Any]
                source["commit"] = unapprovedCommit
                receipt["llmSource"] = source
            })
        XCTAssertCaptureFails(unapprovedMatchingSource)

        let catalogHashMismatch = try PairFixture(
            experimentMutation: { experiment in
                experiment["candidateCatalogSHA256"] =
                    String(repeating: "f", count: 64)
            })
        XCTAssertCaptureFails(catalogHashMismatch)

        let catalogCountMismatch = try PairFixture(
            experimentMutation: { experiment in
                experiment["candidateCatalogByteCount"] =
                    (experiment["candidateCatalogByteCount"] as! Int) + 1
            })
        XCTAssertCaptureFails(catalogCountMismatch)

        let candidateMismatch = try PairFixture(
            experimentMutation: { experiment in
                experiment["candidateIDs"] = ["latin_candidate_b"]
            })
        XCTAssertCaptureFails(candidateMismatch)

        let dependencyMismatch = try PairFixture(
            experimentMutation: { experiment in
                var binding = experiment["dependencyLock"] as! [String: Any]
                binding["sha256"] = String(repeating: "f", count: 64)
                experiment["dependencyLock"] = binding
            })
        XCTAssertCaptureFails(dependencyMismatch)

        let replacementLockSHA = String(repeating: "8", count: 64)
        let consistentlyUnapprovedDependency = try PairFixture(
            catalogMutation: { catalog in
                var binding = catalog["dependencyLock"] as! [String: Any]
                binding["sha256"] = replacementLockSHA
                catalog["dependencyLock"] = binding
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["dependencyLock"] = binding
                catalog["dependencyQuarantine"] = quarantine
            },
            experimentMutation: { experiment in
                var binding = experiment["dependencyLock"] as! [String: Any]
                binding["sha256"] = replacementLockSHA
                experiment["dependencyLock"] = binding
            })
        XCTAssertCaptureFails(consistentlyUnapprovedDependency)

        let tokenizerMismatch = try PairFixture(
            experimentMutation: { experiment in
                var binding = experiment["tokenizerManifest"] as! [String: Any]
                binding["sha256"] = String(repeating: "f", count: 64)
                experiment["tokenizerManifest"] = binding
            })
        XCTAssertCaptureFails(tokenizerMismatch)

        let initializationMismatch = try PairFixture(
            experimentMutation: { experiment in
                var binding = experiment["initializationContract"]
                    as! [String: Any]
                binding["sha256"] = String(repeating: "f", count: 64)
                experiment["initializationContract"] = binding
            })
        XCTAssertCaptureFails(initializationMismatch)
    }

    func testCatalogAndExperimentSemanticMutationsAreRejected() throws {
        let catalogLane = try PairFixture(catalogMutation: {
            $0["laneID"] = "latin_secondary_prospective_v1"
        })
        XCTAssertCaptureFails(catalogLane)

        let experimentLane = try PairFixture(experimentMutation: {
            $0["laneID"] = "latin_secondary_prospective_v1"
        })
        XCTAssertCaptureFails(experimentLane)

        let mlxLocation = try PairFixture(catalogMutation: {
            $0["ergenticsMLXLocation"] =
                "https://github.com/example/unapproved"
        })
        XCTAssertCaptureFails(mlxLocation)

        let mlxRevision = try PairFixture(catalogMutation: {
            $0["ergenticsMLXRevision"] = String(repeating: "f", count: 40)
        })
        XCTAssertCaptureFails(mlxRevision)

        let packageBinding = try PairFixture(catalogMutation: { catalog in
            var binding = catalog["packageManifest"] as! [String: Any]
            binding["sha256"] = String(repeating: "f", count: 64)
            catalog["packageManifest"] = binding
            var quarantine = catalog["dependencyQuarantine"]
                as! [String: Any]
            quarantine["packageManifest"] = binding
            catalog["dependencyQuarantine"] = quarantine
        })
        XCTAssertCaptureFails(packageBinding)

        let packagePath = try PairFixture(catalogMutation: { catalog in
            var binding = catalog["packageManifest"] as! [String: Any]
            binding["relativePath"] = "Manifests/Package.swift"
            catalog["packageManifest"] = binding
            var quarantine = catalog["dependencyQuarantine"]
                as! [String: Any]
            quarantine["packageManifest"] = binding
            catalog["dependencyQuarantine"] = quarantine
        })
        XCTAssertCaptureFails(packagePath)

        let packageScope = try PairFixture(catalogMutation: { catalog in
            var binding = catalog["packageManifest"] as! [String: Any]
            binding["scope"] = "ergentics_mlx_lab"
            catalog["packageManifest"] = binding
            var quarantine = catalog["dependencyQuarantine"]
                as! [String: Any]
            quarantine["packageManifest"] = binding
            catalog["dependencyQuarantine"] = quarantine
        })
        XCTAssertCaptureFails(packageScope)

        let dependencyLockPath = try PairFixture(
            catalogMutation: { catalog in
                var binding = catalog["dependencyLock"] as! [String: Any]
                binding["relativePath"] = "Locks/Package.resolved"
                catalog["dependencyLock"] = binding
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["dependencyLock"] = binding
                catalog["dependencyQuarantine"] = quarantine
            },
            experimentMutation: { experiment in
                var binding = experiment["dependencyLock"]
                    as! [String: Any]
                binding["relativePath"] = "Locks/Package.resolved"
                experiment["dependencyLock"] = binding
            })
        XCTAssertCaptureFails(dependencyLockPath)

        let dependencyLockScope = try PairFixture(
            catalogMutation: { catalog in
                var binding = catalog["dependencyLock"] as! [String: Any]
                binding["scope"] = "ergentics_mlx_lab"
                catalog["dependencyLock"] = binding
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["dependencyLock"] = binding
                catalog["dependencyQuarantine"] = quarantine
            },
            experimentMutation: { experiment in
                var binding = experiment["dependencyLock"]
                    as! [String: Any]
                binding["scope"] = "ergentics_mlx_lab"
                experiment["dependencyLock"] = binding
            })
        XCTAssertCaptureFails(dependencyLockScope)

        let packageByteCount = try PairFixture(
            catalogMutation: { catalog in
                var binding = catalog["packageManifest"] as! [String: Any]
                binding["byteCount"] = 6_110
                catalog["packageManifest"] = binding
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["packageManifest"] = binding
                catalog["dependencyQuarantine"] = quarantine
            })
        XCTAssertCaptureFails(packageByteCount)

        let dependencyLockByteCount = try PairFixture(
            catalogMutation: { catalog in
                var binding = catalog["dependencyLock"] as! [String: Any]
                binding["byteCount"] = 646
                catalog["dependencyLock"] = binding
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["dependencyLock"] = binding
                catalog["dependencyQuarantine"] = quarantine
            },
            experimentMutation: { experiment in
                var binding = experiment["dependencyLock"]
                    as! [String: Any]
                binding["byteCount"] = 646
                experiment["dependencyLock"] = binding
        })
        XCTAssertCaptureFails(dependencyLockByteCount)

        let emptyCandidateCatalog = try PairFixture(
            catalogMutation: { catalog in
                catalog["candidates"] = [[String: Any]]()
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["candidateImplementationSources"] =
                    [[String: Any]]()
                catalog["dependencyQuarantine"] = quarantine
            },
            experimentMutation: { experiment in
                experiment["candidateIDs"] = [String]()
            })
        XCTAssertCaptureFails(emptyCandidateCatalog)

        let duplicateCandidateCatalog = try PairFixture(
            catalogMutation: { catalog in
                let first =
                    (catalog["candidates"] as! [[String: Any]])[0]
                var second = first

                var architecture = second["architectureDeclaration"]
                    as! [String: Any]
                architecture["relativePath"] =
                    "Research/Latin/candidates/candidate_duplicate_id.json"
                architecture["sha256"] = String(repeating: "8", count: 64)
                second["architectureDeclaration"] = architecture
                second["declarationSHA256"] = architecture["sha256"]

                var implementation = second["implementationSource"]
                    as! [String: Any]
                implementation["relativePath"] =
                    "Sources/LatinCandidates/CandidateDuplicateID.swift"
                implementation["sha256"] = String(repeating: "9", count: 64)
                second["implementationSource"] = implementation

                var derivation = second["parameterCountDerivation"]
                    as! [String: Any]
                derivation["relativePath"] =
                    "Research/Latin/candidates/" +
                    "candidate_duplicate_id-parameter-count.json"
                derivation["sha256"] = String(repeating: "0", count: 64)
                second["parameterCountDerivation"] = derivation

                catalog["candidates"] = [first, second]
                let firstImplementation = first["implementationSource"]
                    as! [String: Any]
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["candidateImplementationSources"] = [
                    firstImplementation, implementation,
                ]
                catalog["dependencyQuarantine"] = quarantine
            },
            experimentMutation: { experiment in
                experiment["candidateIDs"] = [
                    "latin_candidate_a", "latin_candidate_a",
                ]
            })
        XCTAssertCaptureFails(duplicateCandidateCatalog)

        let unsortedCandidateCatalog = try PairFixture(
            catalogMutation: { catalog in
                let first = (catalog["candidates"]
                    as! [[String: Any]])[0]
                var second = first
                second["candidateID"] = "latin_candidate_b"

                var architecture = second["architectureDeclaration"]
                    as! [String: Any]
                architecture["relativePath"] =
                    "Research/Latin/candidates/candidate_b.json"
                architecture["sha256"] = String(repeating: "8", count: 64)
                second["architectureDeclaration"] = architecture
                second["declarationSHA256"] = architecture["sha256"]

                var implementation = second["implementationSource"]
                    as! [String: Any]
                implementation["relativePath"] =
                    "Sources/LatinCandidates/CandidateB.swift"
                implementation["sha256"] = String(repeating: "9", count: 64)
                second["implementationSource"] = implementation

                var derivation = second["parameterCountDerivation"]
                    as! [String: Any]
                derivation["relativePath"] =
                    "Research/Latin/candidates/" +
                    "candidate_b-parameter-count.json"
                derivation["sha256"] = String(repeating: "0", count: 64)
                second["parameterCountDerivation"] = derivation

                catalog["candidates"] = [second, first]
                let firstImplementation = first["implementationSource"]
                    as! [String: Any]
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["candidateImplementationSources"] = [
                    firstImplementation, implementation,
                ]
                catalog["dependencyQuarantine"] = quarantine
            },
            experimentMutation: { experiment in
                experiment["candidateIDs"] = [
                    "latin_candidate_b", "latin_candidate_a",
                ]
            })
        XCTAssertCaptureFails(unsortedCandidateCatalog)

        let oversizedCandidateCatalog = try PairFixture(
            catalogMutation: { catalog in
                let template = (catalog["candidates"]
                    as! [[String: Any]])[0]
                var candidates = [[String: Any]]()
                var implementations = [[String: Any]]()
                for index in 0 ..< 65 {
                    let suffix = String(format: "%03d", index)
                    var candidate = template
                    candidate["candidateID"] = "latin_candidate_\(suffix)"

                    var architecture = candidate["architectureDeclaration"]
                        as! [String: Any]
                    architecture["relativePath"] =
                        "Research/Latin/candidates/candidate_\(suffix).json"
                    architecture["sha256"] = String(
                        format: "%064llx", UInt64(0x100 + index * 3))
                    candidate["architectureDeclaration"] = architecture
                    candidate["declarationSHA256"] = architecture["sha256"]

                    var implementation = candidate["implementationSource"]
                        as! [String: Any]
                    implementation["relativePath"] =
                        "Sources/LatinCandidates/Candidate\(suffix).swift"
                    implementation["sha256"] = String(
                        format: "%064llx", UInt64(0x101 + index * 3))
                    candidate["implementationSource"] = implementation

                    var derivation = candidate["parameterCountDerivation"]
                        as! [String: Any]
                    derivation["relativePath"] =
                        "Research/Latin/candidates/" +
                        "candidate_\(suffix)-parameter-count.json"
                    derivation["sha256"] = String(
                        format: "%064llx", UInt64(0x102 + index * 3))
                    candidate["parameterCountDerivation"] = derivation

                    candidates.append(candidate)
                    implementations.append(implementation)
                }
                catalog["candidates"] = candidates
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["candidateImplementationSources"] =
                    implementations
                catalog["dependencyQuarantine"] = quarantine
            },
            experimentMutation: { experiment in
                experiment["candidateIDs"] = (0 ..< 65).map {
                    "latin_candidate_" + String(format: "%03d", $0)
                }
            })
        XCTAssertCaptureFails(oversizedCandidateCatalog)

        let candidateSource = try PairFixture(catalogMutation: { catalog in
            var candidates = catalog["candidates"] as! [[String: Any]]
            candidates[0]["sourceKind"] = "generated"
            catalog["candidates"] = candidates
        })
        XCTAssertCaptureFails(candidateSource)

        let candidateAuthentication = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                candidates[0]["cryptographicHumanAuthentication"] = true
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(candidateAuthentication)

        let candidateAssurance = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                candidates[0]["attributionAssurance"] = "unverified"
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(candidateAssurance)

        let candidateDeclaration = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                candidates[0]["declarationSHA256"] =
                    String(repeating: "9", count: 64)
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(candidateDeclaration)

        let candidateBindingScope = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                var architecture = candidates[0]["architectureDeclaration"]
                    as! [String: Any]
                architecture["scope"] = "ergentics_mlx_lab"
                candidates[0]["architectureDeclaration"] = architecture
                catalog["candidates"] = candidates
        })
        XCTAssertCaptureFails(candidateBindingScope)

        let candidateImplementationScope = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"]
                    as! [[String: Any]]
                var implementation = candidates[0]["implementationSource"]
                    as! [String: Any]
                implementation["scope"] = "ergentics_mlx_lab"
                candidates[0]["implementationSource"] = implementation
                catalog["candidates"] = candidates
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["candidateImplementationSources"] = [
                    implementation,
                ]
                catalog["dependencyQuarantine"] = quarantine
            })
        XCTAssertCaptureFails(candidateImplementationScope)

        let candidateDerivationScope = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"]
                    as! [[String: Any]]
                var derivation = candidates[0]["parameterCountDerivation"]
                    as! [String: Any]
                derivation["scope"] = "ergentics_mlx_lab"
                candidates[0]["parameterCountDerivation"] = derivation
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(candidateDerivationScope)

        let zeroParameterCount = try PairFixture(catalogMutation: { catalog in
            var candidates = catalog["candidates"] as! [[String: Any]]
            candidates[0]["parameterCount"] = 0
            catalog["candidates"] = candidates
        })
        XCTAssertCaptureFails(zeroParameterCount)

        let forbiddenCandidateContext = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                candidates[0]["candidateID"] = "latin_llama_candidate"
                catalog["candidates"] = candidates
            },
            experimentMutation: { experiment in
                experiment["candidateIDs"] = ["latin_llama_candidate"]
        })
        XCTAssertCaptureFails(forbiddenCandidateContext)

        let missingLatinCandidatePrefix = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"]
                    as! [[String: Any]]
                candidates[0]["candidateID"] = "candidate_a"
                catalog["candidates"] = candidates
            },
            experimentMutation: { experiment in
                experiment["candidateIDs"] = ["candidate_a"]
            })
        XCTAssertCaptureFails(missingLatinCandidatePrefix)

        let primeAttributedCandidate = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"]
                    as! [[String: Any]]
                candidates[0]["sourceAttribution"] = "prime_research"
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(primeAttributedCandidate)

        let forbiddenAttributionContext = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                candidates[0]["sourceAttribution"] = "pmhnp_research"
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(forbiddenAttributionContext)

        let forbiddenPathContext = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                var implementation = candidates[0]["implementationSource"]
                    as! [String: Any]
                implementation["relativePath"] =
                    "Sources/huggingface/CandidateA.swift"
                candidates[0]["implementationSource"] = implementation
                catalog["candidates"] = candidates
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["candidateImplementationSources"] =
                    [implementation]
                catalog["dependencyQuarantine"] = quarantine
            })
        XCTAssertCaptureFails(forbiddenPathContext)

        let inconsistentDuplicatePath = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                let implementation = candidates[0]["implementationSource"]
                    as! [String: Any]
                var architecture = candidates[0]["architectureDeclaration"]
                    as! [String: Any]
                architecture["relativePath"] = implementation["relativePath"]
                candidates[0]["architectureDeclaration"] = architecture
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(inconsistentDuplicatePath)

        let inconsistentDuplicateHash = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                let implementation = candidates[0]["implementationSource"]
                    as! [String: Any]
                var architecture = candidates[0]["architectureDeclaration"]
                    as! [String: Any]
                architecture["sha256"] = implementation["sha256"]
                architecture["byteCount"] =
                    (implementation["byteCount"] as! Int) + 1
                candidates[0]["declarationSHA256"] =
                    implementation["sha256"]
                candidates[0]["architectureDeclaration"] = architecture
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(inconsistentDuplicateHash)

        let inconsistentCaseAliasedPath = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                var architecture = candidates[0]["architectureDeclaration"]
                    as! [String: Any]
                architecture["relativePath"] =
                    "sources/latincandidates/candidatea.swift"
                candidates[0]["architectureDeclaration"] = architecture
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(inconsistentCaseAliasedPath)

        let tokenizerInitializationAlias = try PairFixture(
            catalogMutation: { catalog in
                let initialization = catalog["initializationContract"]
                    as! [String: Any]
                catalog["tokenizerManifest"] = initialization
            },
            experimentMutation: { experiment in
                let initialization = experiment["initializationContract"]
                    as! [String: Any]
                experiment["tokenizerManifest"] = initialization
            })
        XCTAssertCaptureFails(tokenizerInitializationAlias)

        let architectureDerivationAlias = try PairFixture(
            catalogMutation: { catalog in
                var candidates = catalog["candidates"] as! [[String: Any]]
                let derivation = candidates[0]["parameterCountDerivation"]
                    as! [String: Any]
                candidates[0]["architectureDeclaration"] = derivation
                candidates[0]["declarationSHA256"] = derivation["sha256"]
                catalog["candidates"] = candidates
            })
        XCTAssertCaptureFails(architectureDerivationAlias)

        let publicationNamespaceAlias =
            "evidence/latin-proposal-artifacts/pairs/" +
            String(repeating: "a", count: 64) + ".json"
        let referencedPublicationDocument = try PairFixture(
            catalogMutation: { catalog in
                var tokenizer = catalog["tokenizerManifest"]
                    as! [String: Any]
                tokenizer["relativePath"] = publicationNamespaceAlias
                catalog["tokenizerManifest"] = tokenizer
            },
            experimentMutation: { experiment in
                var tokenizer = experiment["tokenizerManifest"]
                    as! [String: Any]
                tokenizer["relativePath"] = publicationNamespaceAlias
                experiment["tokenizerManifest"] = tokenizer
            })
        XCTAssertCaptureFails(referencedPublicationDocument)

        let referencedPublicationRoot = try PairFixture(
            catalogMutation: { catalog in
                var tokenizer = catalog["tokenizerManifest"]
                    as! [String: Any]
                tokenizer["relativePath"] =
                    "evidence/latin-proposal-artifacts"
                catalog["tokenizerManifest"] = tokenizer
            },
            experimentMutation: { experiment in
                var tokenizer = experiment["tokenizerManifest"]
                    as! [String: Any]
                tokenizer["relativePath"] =
                    "evidence/latin-proposal-artifacts"
                experiment["tokenizerManifest"] = tokenizer
            })
        XCTAssertCaptureFails(referencedPublicationRoot)

        let inputBelowOutputNamespace = try PairFixture(
            catalogMutation: { catalog in
                var tokenizer = catalog["tokenizerManifest"]
                    as! [String: Any]
                tokenizer["relativePath"] =
                    "models/latin-prospective/fixture_v2/tokenizer.json"
                catalog["tokenizerManifest"] = tokenizer
            },
            experimentMutation: { experiment in
                var tokenizer = experiment["tokenizerManifest"]
                    as! [String: Any]
                tokenizer["relativePath"] =
                    "models/latin-prospective/fixture_v2/tokenizer.json"
                experiment["tokenizerManifest"] = tokenizer
            })
        XCTAssertCaptureFails(inputBelowOutputNamespace)

        let caseAliasedInputBelowOutputNamespace = try PairFixture(
            catalogMutation: { catalog in
                var tokenizer = catalog["tokenizerManifest"]
                    as! [String: Any]
                tokenizer["relativePath"] =
                    "Models/Latin-Prospective/fixture_v2/tokenizer.json"
                catalog["tokenizerManifest"] = tokenizer
            },
            experimentMutation: { experiment in
                var tokenizer = experiment["tokenizerManifest"]
                    as! [String: Any]
                tokenizer["relativePath"] =
                    "Models/Latin-Prospective/fixture_v2/tokenizer.json"
                experiment["tokenizerManifest"] = tokenizer
            })
        XCTAssertCaptureFails(caseAliasedInputBelowOutputNamespace)

        let inputAboveOutputNamespace = try PairFixture(
            experimentMutation: { experiment in
                var corpus = experiment["corpusManifest"]
                    as! [String: Any]
                corpus["relativePath"] = "models/latin-prospective"
                experiment["corpusManifest"] = corpus
            })
        XCTAssertCaptureFails(inputAboveOutputNamespace)

        let splitStatus = try PairFixture(experimentMutation: { experiment in
            var splits = experiment["splits"] as! [String: Any]
            splits["selectionDataStatus"] = "observed"
            experiment["splits"] = splits
        })
        XCTAssertCaptureFails(splitStatus)

        let duplicateSplitID = try PairFixture(
            experimentMutation: { experiment in
                var splits = experiment["splits"] as! [String: Any]
                splits["validationSplitID"] = splits["trainingSplitID"]
                experiment["splits"] = splits
            })
        XCTAssertCaptureFails(duplicateSplitID)

        let forbiddenSplitID = try PairFixture(
            experimentMutation: { experiment in
                var splits = experiment["splits"] as! [String: Any]
                splits["selectionSplitID"] = "latin_llama_selection"
                experiment["splits"] = splits
            })
        XCTAssertCaptureFails(forbiddenSplitID)

        let reservedHoldoutSplitID = try PairFixture(
            experimentMutation: { experiment in
                var splits = experiment["splits"] as! [String: Any]
                splits["selectionSplitID"] = "latin_selection_holdout_v2"
                experiment["splits"] = splits
            })
        XCTAssertCaptureFails(reservedHoldoutSplitID)

        let reservedHistoricalSplitID = try PairFixture(
            experimentMutation: { experiment in
                var splits = experiment["splits"] as! [String: Any]
                splits["selectionSplitID"] = "latin_selection_primary_v1"
                experiment["splits"] = splits
            })
        XCTAssertCaptureFails(reservedHistoricalSplitID)

        let zeroBudget = try PairFixture(experimentMutation: { experiment in
            var budget = experiment["requestedTrialBudget"] as! [String: Any]
            budget["optimizerSteps"] = 0
            experiment["requestedTrialBudget"] = budget
        })
        XCTAssertCaptureFails(zeroBudget)

        let budgetApplication = try PairFixture(
            experimentMutation: { experiment in
                var budget = experiment["requestedTrialBudget"]
                    as! [String: Any]
                budget["application"] = "caller_selected"
                experiment["requestedTrialBudget"] = budget
            })
        XCTAssertCaptureFails(budgetApplication)

        for field in ["trainingTokens", "wallClockSeconds"] {
            let fixture = try PairFixture(
                experimentMutation: { experiment in
                    var budget = experiment["requestedTrialBudget"]
                        as! [String: Any]
                    budget[field] = 0
                    experiment["requestedTrialBudget"] = budget
                })
            XCTAssertCaptureFails(fixture)
        }

        let outputDisposition = try PairFixture(experimentMutation: {
            $0["outputDisposition"] = "replace_existing"
        })
        XCTAssertCaptureFails(outputDisposition)

        let outputNamespace = try PairFixture(experimentMutation: {
            $0["outputNamespace"] = "models/unbounded/fixture"
        })
        XCTAssertCaptureFails(outputNamespace)

        let reservedHistoricalOutputNamespace = try PairFixture(
            experimentMutation: {
                $0["outputNamespace"] =
                    "models/latin-prospective/ergentics_latin_primary_v1"
            })
        XCTAssertCaptureFails(reservedHistoricalOutputNamespace)
    }

    func testAuthorityAndQuarantineMutationsAreRejected() throws {
        let receiptAuthority = try PairFixture(receiptMutation: {
            $0["authorityStatus"] = "authorizing"
        })
        XCTAssertCaptureFails(receiptAuthority)

        let snapshotClaim = try PairFixture(receiptMutation: {
            $0["referencedInputSnapshot"] = "present"
        })
        XCTAssertCaptureFails(snapshotClaim)

        for (field, value) in [
            ("completionScope", "complete"),
            ("independentReplayStatus", "complete"),
            ("externalStateCommitAtomicity", "claimed_atomic"),
            ("publicationCoordination", "uncoordinated"),
        ] {
            let fixture = try PairFixture(receiptMutation: {
                $0[field] = value
            })
            XCTAssertCaptureFails(fixture)
        }

        let executionClaim = try PairFixture(experimentMutation: { experiment in
            var authority = experiment["authority"] as! [String: Any]
            authority["trialExecutionAuthorized"] = true
            experiment["authority"] = authority
        })
        XCTAssertCaptureFails(executionClaim)

        let packetClaim = try PairFixture(experimentMutation: { experiment in
            var authority = experiment["authority"] as! [String: Any]
            authority["primeProposalPacket"] = "present"
            experiment["authority"] = authority
        })
        XCTAssertCaptureFails(packetClaim)

        for field in [
            "furtherTrainingAuthorized",
            "promotionAuthorized",
            "productUseAuthorized",
        ] {
            let fixture = try PairFixture(experimentMutation: { experiment in
                var authority = experiment["authority"] as! [String: Any]
                authority[field] = true
                experiment["authority"] = authority
            })
            XCTAssertCaptureFails(fixture)
        }

        let trialAuthorizationClaim = try PairFixture(
            experimentMutation: { experiment in
                var authority = experiment["authority"] as! [String: Any]
                authority["primeTrialAuthorization"] = "present"
                experiment["authority"] = authority
            })
        XCTAssertCaptureFails(trialAuthorizationClaim)

        let catalogAuthority = try PairFixture(catalogMutation: {
            $0["authorityStatus"] = "authorizing"
        })
        XCTAssertCaptureFails(catalogAuthority)

        let topLevelPolicyMismatch = try PairFixture(catalogMutation: {
            $0["quarantinePolicyID"] = "ergentics_latin_wrong_policy_v1"
        })
        XCTAssertCaptureFails(topLevelPolicyMismatch)

        let quarantineStatus = try PairFixture(catalogMutation: { catalog in
            var quarantine = catalog["dependencyQuarantine"] as! [String: Any]
            quarantine["status"] = "caller_claimed_pass"
            catalog["dependencyQuarantine"] = quarantine
        })
        XCTAssertCaptureFails(quarantineStatus)

        let dependencyCount = try PairFixture(catalogMutation: { catalog in
            var quarantine = catalog["dependencyQuarantine"] as! [String: Any]
            quarantine["authorityTargetDependencyCount"] = 1
            catalog["dependencyQuarantine"] = quarantine
        })
        XCTAssertCaptureFails(dependencyCount)

        let incompleteScan = try PairFixture(catalogMutation: { catalog in
            var quarantine = catalog["dependencyQuarantine"] as! [String: Any]
            quarantine["lockfilePinScanComplete"] = false
            catalog["dependencyQuarantine"] = quarantine
        })
        XCTAssertCaptureFails(incompleteScan)

        let implementationMismatch = try PairFixture(
            catalogMutation: { catalog in
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                quarantine["candidateImplementationSources"] = []
                catalog["dependencyQuarantine"] = quarantine
            })
        XCTAssertCaptureFails(implementationMismatch)

        let quarantinePackageMismatch = try PairFixture(
            catalogMutation: { catalog in
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                var binding = quarantine["packageManifest"]
                    as! [String: Any]
                binding["sha256"] = String(repeating: "8", count: 64)
                quarantine["packageManifest"] = binding
                catalog["dependencyQuarantine"] = quarantine
            })
        XCTAssertCaptureFails(quarantinePackageMismatch)

        let quarantineLockMismatch = try PairFixture(
            catalogMutation: { catalog in
                var quarantine = catalog["dependencyQuarantine"]
                    as! [String: Any]
                var binding = quarantine["dependencyLock"]
                    as! [String: Any]
                binding["sha256"] = String(repeating: "8", count: 64)
                quarantine["dependencyLock"] = binding
                catalog["dependencyQuarantine"] = quarantine
            })
        XCTAssertCaptureFails(quarantineLockMismatch)

        let policyMismatch = try PairFixture(catalogMutation: { catalog in
            var quarantine = catalog["dependencyQuarantine"] as! [String: Any]
            quarantine["policyID"] = "ergentics_latin_wrong_policy_v1"
            catalog["dependencyQuarantine"] = quarantine
        })
        XCTAssertCaptureFails(policyMismatch)
    }

    func testUnsafeModesLinksAndSymlinksAreRejected() throws {
        let writable = try PairFixture()
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o644],
            ofItemAtPath: writable.catalogURL.path)
        XCTAssertCaptureFails(writable)

        let linked = try PairFixture()
        try FileManager.default.linkItem(
            at: linked.experimentURL,
            to: linked.labRoot.appendingPathComponent("experiment-hard-link.json"))
        XCTAssertCaptureFails(linked)

        let symlink = try PairFixture()
        let preserved = symlink.labRoot.appendingPathComponent("preserved-pair.json")
        try Data(contentsOf: symlink.pairURL).write(
            to: preserved,
            options: .withoutOverwriting)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o444],
            ofItemAtPath: preserved.path)
        try FileManager.default.removeItem(at: symlink.pairURL)
        try FileManager.default.createSymbolicLink(
            at: symlink.pairURL,
            withDestinationURL: preserved)
        XCTAssertCaptureFails(symlink)

        let rootAlias = try PairFixture()
        let alias = rootAlias.labRoot.deletingLastPathComponent()
            .appendingPathComponent("lab-alias-\(UUID().uuidString)")
        try FileManager.default.createSymbolicLink(
            at: alias,
            withDestinationURL: rootAlias.labRoot)
        defer { try? FileManager.default.removeItem(at: alias) }
        XCTAssertThrowsError(
            try PrimeLatinProposalPairCapture.capture(
                labRoot: alias,
                pairSHA256: rootAlias.pairSHA256))
    }

    func testRecaptureRejectsAnyCapturedDocumentChange() throws {
        let modeChange = try PairFixture()
        let modeCapture = try PrimeLatinProposalPairCapture.capture(
            labRoot: modeChange.labRoot,
            pairSHA256: modeChange.pairSHA256)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o644],
            ofItemAtPath: modeChange.experimentURL.path)
        XCTAssertThrowsError(try modeCapture.recaptureAndValidateUnchanged())

        let byteChange = try PairFixture()
        let byteCapture = try PrimeLatinProposalPairCapture.capture(
            labRoot: byteChange.labRoot,
            pairSHA256: byteChange.pairSHA256)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o644],
            ofItemAtPath: byteChange.catalogURL.path)
        try Data("{}".utf8).write(to: byteChange.catalogURL)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o444],
            ofItemAtPath: byteChange.catalogURL.path)
        XCTAssertThrowsError(try byteCapture.recaptureAndValidateUnchanged())

        let identityChange = try PairFixture()
        let identityCapture = try PrimeLatinProposalPairCapture.capture(
            labRoot: identityChange.labRoot,
            pairSHA256: identityChange.pairSHA256)
        let preservedBytes = try Data(contentsOf: identityChange.catalogURL)
        try FileManager.default.removeItem(at: identityChange.catalogURL)
        try preservedBytes.write(
            to: identityChange.catalogURL,
            options: .withoutOverwriting)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o444],
            ofItemAtPath: identityChange.catalogURL.path)
        XCTAssertThrowsError(
            try identityCapture.recaptureAndValidateUnchanged())

        let restoredInPlace = try PairFixture()
        let restoredCapture = try PrimeLatinProposalPairCapture.capture(
            labRoot: restoredInPlace.labRoot,
            pairSHA256: restoredInPlace.pairSHA256)
        let restoredBytes = try Data(contentsOf: restoredInPlace.catalogURL)
        let originalInode = try FileManager.default.attributesOfItem(
            atPath: restoredInPlace.catalogURL.path)[.systemFileNumber]
            as? NSNumber
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o644],
            ofItemAtPath: restoredInPlace.catalogURL.path)
        let handle = try FileHandle(forWritingTo: restoredInPlace.catalogURL)
        try handle.truncate(atOffset: 0)
        try handle.seek(toOffset: 0)
        try handle.write(contentsOf: Data("mutated".utf8))
        try handle.truncate(atOffset: 0)
        try handle.seek(toOffset: 0)
        try handle.write(contentsOf: restoredBytes)
        try handle.synchronize()
        try handle.close()
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o444],
            ofItemAtPath: restoredInPlace.catalogURL.path)
        let finalInode = try FileManager.default.attributesOfItem(
            atPath: restoredInPlace.catalogURL.path)[.systemFileNumber]
            as? NSNumber
        XCTAssertEqual(finalInode, originalInode)
        XCTAssertEqual(
            try Data(contentsOf: restoredInPlace.catalogURL),
            restoredBytes)
        XCTAssertThrowsError(
            try restoredCapture.recaptureAndValidateUnchanged())
    }

    private func XCTAssertCaptureFails(
        _ fixture: PairFixture,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeLatinProposalPairCapture.capture(
                labRoot: fixture.labRoot,
                pairSHA256: fixture.pairSHA256),
            file: file,
            line: line)
    }
}

private struct PairFixture {
    static let commit = "81cc7ee8e58ad7f3c917b0c32ae55c09d5606e1b"
    static let tree = "01c7f0045e30e79cd4154ef00345f6d6a29d137a"

    let labRoot: URL
    let pairSHA256: String
    let pairURL: URL
    let catalogURL: URL
    let experimentURL: URL
    private let cleanup: PairFixtureRoot

    init(
        catalogMutation: ((inout [String: Any]) -> Void)? = nil,
        experimentMutation: ((inout [String: Any]) -> Void)? = nil,
        receiptMutation: ((inout [String: Any]) -> Void)? = nil,
        catalogDataMutation: ((Data) -> Data)? = nil,
        experimentDataMutation: ((Data) -> Data)? = nil,
        receiptDataMutation: ((Data) -> Data)? = nil
    ) throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "prime-latin-pair-capture-\(UUID().uuidString)",
            isDirectory: true)
        try FileManager.default.createDirectory(
            at: root,
            withIntermediateDirectories: true)
        let canonicalRoot = root.resolvingSymlinksInPath().standardizedFileURL
        let cleanup = PairFixtureRoot(root)

        var catalog = Self.catalogObject()
        catalogMutation?(&catalog)
        var catalogData = try Self.canonical(catalog)
        catalogData = catalogDataMutation?(catalogData) ?? catalogData
        let catalogSHA256 = Self.sha256(catalogData)

        var experiment = Self.experimentObject(
            catalogSHA256: catalogSHA256,
            catalogByteCount: catalogData.count)
        experimentMutation?(&experiment)
        var experimentData = try Self.canonical(experiment)
        experimentData = experimentDataMutation?(experimentData)
            ?? experimentData
        let experimentSHA256 = Self.sha256(experimentData)

        var receipt = Self.receiptObject(
            catalogSHA256: catalogSHA256,
            catalogByteCount: catalogData.count,
            experimentSHA256: experimentSHA256,
            experimentByteCount: experimentData.count)
        receiptMutation?(&receipt)
        var receiptData = try Self.canonical(receipt)
        receiptData = receiptDataMutation?(receiptData) ?? receiptData
        let pairSHA256 = Self.sha256(receiptData)

        let catalogURL = try Self.writeFinal(
            catalogData,
            root: canonicalRoot,
            relativePath: "evidence/latin-proposal-artifacts/catalogs/" +
                "\(catalogSHA256).json")
        let experimentURL = try Self.writeFinal(
            experimentData,
            root: canonicalRoot,
            relativePath: "evidence/latin-proposal-artifacts/experiments/" +
                "\(experimentSHA256).json")
        let pairURL = try Self.writeFinal(
            receiptData,
            root: canonicalRoot,
            relativePath: "evidence/latin-proposal-artifacts/pairs/" +
                "\(pairSHA256).json")

        self.labRoot = canonicalRoot
        self.pairSHA256 = pairSHA256
        self.catalogURL = catalogURL
        self.experimentURL = experimentURL
        self.pairURL = pairURL
        self.cleanup = cleanup

    }

    private static func source() -> [String: Any] {
        [
            "repository": "Ergentics/ergentics-llm",
            "commit": commit,
            "tree": tree,
        ]
    }

    private static func binding(
        scope: String,
        path: String,
        hashCharacter: Character,
        byteCount: Int = 1
    ) -> [String: Any] {
        [
            "scope": scope,
            "relativePath": path,
            "sha256": String(repeating: hashCharacter, count: 64),
            "byteCount": byteCount,
        ]
    }

    private static func catalogObject() -> [String: Any] {
        var package = binding(
            scope: "ergentics_llm_repository",
            path: "Package.swift",
            hashCharacter: "a",
            byteCount: 6_109)
        package["sha256"] =
            "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902"
        var lock = binding(
            scope: "ergentics_llm_repository",
            path: "Package.resolved",
            hashCharacter: "b",
            byteCount: 645)
        lock["sha256"] =
            "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530"
        let tokenizer = binding(
            scope: "ergentics_mlx_lab",
            path: "tokenizer/latin/manifest.json",
            hashCharacter: "c")
        let initialization = binding(
            scope: "ergentics_mlx_lab",
            path: "initialization/latin/contract.json",
            hashCharacter: "d")
        let architecture = binding(
            scope: "ergentics_llm_repository",
            path: "Research/Latin/candidates/candidate_a.json",
            hashCharacter: "e")
        let implementation = binding(
            scope: "ergentics_llm_repository",
            path: "Sources/LatinCandidates/CandidateA.swift",
            hashCharacter: "f")
        let derivation = binding(
            scope: "ergentics_llm_repository",
            path: "Research/Latin/candidates/candidate_a-parameter-count.json",
            hashCharacter: "1")
        let candidate: [String: Any] = [
            "candidateID": "latin_candidate_a",
            "sourceKind": "contributor_declared",
            "sourceAttribution": "ergentics_research",
            "attributionAssurance": "trusted_local_declaration",
            "cryptographicHumanAuthentication": false,
            "declarationSHA256": architecture["sha256"]!,
            "architectureDeclaration": architecture,
            "implementationSource": implementation,
            "parameterCount": 1_024,
            "parameterCountDerivation": derivation,
        ]
        let quarantine: [String: Any] = [
            "policyID": "ergentics_latin_first_party_dependency_quarantine_v1",
            "packageManifest": package,
            "dependencyLock": lock,
            "candidateImplementationSources": [implementation],
            "authorityTargetDependencyCount": 0,
            "lockfilePinScanComplete": true,
            "status": "producer_recomputed_pass",
        ]
        return [
            "schema": "ergentics_latin_candidate_catalog_v1",
            "laneID": "latin_primary_prospective_v1",
            "llmSource": source(),
            "packageManifest": package,
            "dependencyLock": lock,
            "tokenizerManifest": tokenizer,
            "initializationContract": initialization,
            "candidates": [candidate],
            "ergenticsMLXLocation":
                "https://github.com/Ergentics/ergentics-mlx-swift",
            "ergenticsMLXRevision":
                "d37885a278f1c37484a94d0f401a418735e66519",
            "quarantinePolicyID":
                "ergentics_latin_first_party_dependency_quarantine_v1",
            "dependencyQuarantine": quarantine,
            "authorityStatus":
                "root_bound_proposal_input_only_non_authorizing",
        ]
    }

    private static func experimentObject(
        catalogSHA256: String,
        catalogByteCount: Int
    ) -> [String: Any] {
        let catalog = catalogObject()
        let split: (String, String, Character) -> [String: Any] = {
            binding(
                scope: "ergentics_mlx_lab",
                path: $0,
                hashCharacter: $2,
                byteCount: 8)
        }
        return [
            "schema": "ergentics_latin_experiment_manifest_v1",
            "laneID": "latin_primary_prospective_v1",
            "llmSource": source(),
            "candidateCatalogSHA256": catalogSHA256,
            "candidateCatalogByteCount": catalogByteCount,
            "candidateIDs": ["latin_candidate_a"],
            "dependencyLock": catalog["dependencyLock"]!,
            "corpusManifest": binding(
                scope: "ergentics_mlx_lab",
                path: "corpus/la/prospective/manifest.json",
                hashCharacter: "2"),
            "tokenizerManifest": catalog["tokenizerManifest"]!,
            "initializationContract": catalog["initializationContract"]!,
            "evaluationContract": binding(
                scope: "ergentics_llm_repository",
                path: "Research/Latin/evaluation_contract.json",
                hashCharacter: "3"),
            "splits": [
                "trainingSplitID": "latin_train_v2",
                "validationSplitID": "latin_validation_v2",
                "selectionSplitID": "latin_selection_prospective_v2",
                "selectionDataStatus": "trusted_local_declared_unverified",
                "trainingSplit": split(
                    "corpus/la/prospective/train.txt", "training", "4"),
                "validationSplit": split(
                    "corpus/la/prospective/validation.txt", "validation", "5"),
                "selectionSplit": split(
                    "corpus/la/prospective/selection.txt", "selection", "6"),
                "selectionObservationDeclaration": binding(
                    scope: "ergentics_mlx_lab",
                    path: "corpus/la/prospective/selection-observation.json",
                    hashCharacter: "7"),
            ],
            "requestedTrialBudget": [
                "application": "identical_per_candidate_requested_ceiling",
                "optimizerSteps": 1,
                "trainingTokens": 128,
                "wallClockSeconds": 60,
            ],
            "outputNamespace": "models/latin-prospective/fixture_v2",
            "outputDisposition": "must_be_absent_create_once_non_restorable",
            "authority": [
                "primeProposalPacket": "absent",
                "primeTrialAuthorization": "absent",
                "trialExecutionAuthorized": false,
                "furtherTrainingAuthorized": false,
                "promotionAuthorized": false,
                "productUseAuthorized": false,
            ],
        ]
    }

    private static func receiptObject(
        catalogSHA256: String,
        catalogByteCount: Int,
        experimentSHA256: String,
        experimentByteCount: Int
    ) -> [String: Any] {
        [
            "schema": "ergentics_latin_proposal_pair_receipt_v1",
            "llmSource": source(),
            "candidateCatalog": [
                "documentKind": "candidate_catalog",
                "relativePath":
                    "evidence/latin-proposal-artifacts/catalogs/" +
                    "\(catalogSHA256).json",
                "sha256": catalogSHA256,
                "byteCount": catalogByteCount,
            ],
            "experimentManifest": [
                "documentKind": "experiment_manifest",
                "relativePath":
                    "evidence/latin-proposal-artifacts/experiments/" +
                    "\(experimentSHA256).json",
                "sha256": experimentSHA256,
                "byteCount": experimentByteCount,
            ],
            "authorityStatus": "mechanics_only_non_authorizing",
            "completionScope": "catalog_experiment_pair_only",
            "referencedInputSnapshot": "absent",
            "independentReplayStatus":
                "requires_original_bound_input_bytes",
            "externalStateCommitAtomicity":
                "absent_live_roots_revalidated_before_receipt_rename",
            "publicationCoordination": "cooperative_process_lock_only",
        ]
    }

    private static func canonical(_ object: Any) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes])
    }

    private static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }

    private static func writeFinal(
        _ data: Data,
        root: URL,
        relativePath: String
    ) throws -> URL {
        let url = root.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true)
        try data.write(to: url, options: .withoutOverwriting)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o444],
            ofItemAtPath: url.path)
        return url
    }
}

private final class PairFixtureRoot {
    private let root: URL

    init(_ root: URL) {
        self.root = root
    }

    deinit {
        try? FileManager.default.removeItem(at: root)
    }
}
