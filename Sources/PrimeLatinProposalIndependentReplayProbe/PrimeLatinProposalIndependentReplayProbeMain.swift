import Foundation
import PrimeLatinProposalIndependentReplay

private enum PrimeLatinProposalIndependentReplayProbeError: Error {
    case invalidArguments
    case invalidObservation
}

private struct PrimeLatinProposalIndependentReplayProbeArguments {
    let action: String
    let labRoot: URL
    let llmRepositoryRoot: URL

    init(rawArguments: [String]) throws {
        guard rawArguments.count == 6 else {
            throw PrimeLatinProposalIndependentReplayProbeError
                .invalidArguments
        }
        var action: String?
        var labRootPath: String?
        var llmRepositoryRootPath: String?
        var index = 0
        while index < rawArguments.count {
            let option = rawArguments[index]
            let value = rawArguments[index + 1]
            switch option {
            case "--action":
                guard action == nil else {
                    throw PrimeLatinProposalIndependentReplayProbeError
                        .invalidArguments
                }
                action = value
            case "--lab-root":
                guard labRootPath == nil else {
                    throw PrimeLatinProposalIndependentReplayProbeError
                        .invalidArguments
                }
                labRootPath = value
            case "--llm-repository-root":
                guard llmRepositoryRootPath == nil else {
                    throw PrimeLatinProposalIndependentReplayProbeError
                        .invalidArguments
                }
                llmRepositoryRootPath = value
            default:
                throw PrimeLatinProposalIndependentReplayProbeError
                    .invalidArguments
            }
            index += 2
        }
        guard let action,
              action == "replay",
              let labRootPath,
              let llmRepositoryRootPath,
              Self.isCanonicalAbsolutePath(labRootPath),
              Self.isCanonicalAbsolutePath(llmRepositoryRootPath),
              labRootPath != llmRepositoryRootPath
        else {
            throw PrimeLatinProposalIndependentReplayProbeError
                .invalidArguments
        }
        self.action = action
        labRoot = URL(fileURLWithPath: labRootPath, isDirectory: true)
        llmRepositoryRoot = URL(
            fileURLWithPath: llmRepositoryRootPath,
            isDirectory: true)
    }

    private static func isCanonicalAbsolutePath(_ value: String) -> Bool {
        value.hasPrefix("/")
            && value != "/"
            && !value.hasSuffix("/")
            && !value.contains("//")
            && !value.contains("/./")
            && !value.contains("/../")
            && !value.hasSuffix("/..")
            && !value.utf8.contains(0)
            && value.split(separator: "/").allSatisfy {
                $0 != "." && $0 != ".."
            }
    }
}

private struct PrimeLatinProposalIndependentReplayProbeSummary: Encodable {
    let schema: String
    let outcome: String
    let replayPolicyID: String
    let pairReceiptSHA256: String
    let producerCommit: String
    let candidateCatalogSHA256: String
    let experimentManifestSHA256: String
    let independentPrimeReplayComplete: Bool
    let liveProducerWorkspaceRevalidationComplete: Bool

    enum CodingKeys: String, CodingKey {
        case schema, outcome
        case replayPolicyID = "replay_policy_id"
        case pairReceiptSHA256 = "pair_receipt_sha256"
        case producerCommit = "producer_commit"
        case candidateCatalogSHA256 = "candidate_catalog_sha256"
        case experimentManifestSHA256 = "experiment_manifest_sha256"
        case independentPrimeReplayComplete =
            "independent_prime_replay_complete"
        case liveProducerWorkspaceRevalidationComplete =
            "live_producer_workspace_revalidation_complete"
    }
}

@main
struct PrimeLatinProposalIndependentReplayProbeMain {
    static func main() throws {
        let arguments = try PrimeLatinProposalIndependentReplayProbeArguments(
            rawArguments: Array(CommandLine.arguments.dropFirst()))
        guard arguments.action == "replay" else {
            throw PrimeLatinProposalIndependentReplayProbeError
                .invalidArguments
        }
        let capture = try PrimeLatinProposalIndependentReplayCaptureV1.capture(
            labRoot: arguments.labRoot,
            llmRepositoryRoot: arguments.llmRepositoryRoot)
        let observation = capture.observation
        let recaptured = try capture.recaptureAndValidateUnchanged()
        guard recaptured == observation else {
            throw PrimeLatinProposalIndependentReplayProbeError
                .invalidObservation
        }

        let authority = observation.authority
        guard observation.schema
                == "ergentics_prime_latin_proposal_v3_independent_replay_observation_v1",
              observation.outcome == "abstain",
              observation.verificationScope
                == "prime_owned_independent_typed_reconstruction_from_one_git_bound_retained_twenty_one_original_input_snapshot_and_byte_exact_catalog_experiment_cross_check_only_non_authorizing",
              observation.replayPolicyID
                == "prime_latin_v3_retained_original_input_independent_reconstruction_v1",
              observation.pairReceiptSHA256
                == "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7",
              observation.pairReceiptByteCount == 1_833,
              observation.producerRepository == "Ergentics/ergentics-llm",
              observation.producerCommit
                == "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831",
              observation.producerTree
                == "c1f41758aea2860ab06039776f5ea0403dff1b61",
              observation.inputBindingCount == 21,
              observation.retainedOriginalInputByteCount == 8_084_712,
              observation.candidateCatalogSHA256
                == "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4",
              observation.candidateCatalogByteCount == 20_803,
              observation.experimentManifestSHA256
                == "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76",
              observation.experimentManifestByteCount == 3_364,
              observation.candidateDeclarationSetSHA256
                == "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881",
              observation.candidateDeclarationSetByteCount == 14_860,
              observation.tokenizerBundleSHA256
                == "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c",
              observation.tokenizerBundleByteCount == 2_930,
              observation.candidateIDs == ["latin_structural_fixture_v1"],
              observation.candidateIdentitySHA256s
                == ["64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265"],
              observation.declarationBundleSHA256s
                == ["6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd"],
              observation.optimizerSteps == 1,
              observation.trainingTokens == 128,
              observation.wallClockSeconds == 60,
              observation.outputNamespace
                == "models/latin-prospective/structural-fixture-v3-776c412e",
              observation.orderedTensorCount == 12,
              observation.uniqueParameterStorageCount == 11,
              observation.totalParameterCount == 131_736,
              authority.disposition
                == "abstain_independent_prime_structural_replay_complete_live_producer_revalidation_not_composed_and_runtime_decoder_initialization_evaluation_trial_and_publication_authority_absent",
              authority.pairCaptureAndRecaptureComplete,
              authority.inputSnapshotCaptureAndRecaptureComplete,
              authority.producerGitObservationComplete,
              authority.exactTwentyOneOriginalInputBindingsCrossBound,
              authority.exactTwentyOneOriginalInputBytesRetained,
              authority.retainedOriginalInputHashCountRecomputationComplete,
              authority.independentTokenizerBundleReconstructionComplete,
              authority.independentDeclarationTargetClosureReconstructionComplete,
              authority.independentCandidateIdentityReconstructionComplete,
              authority.independentCandidateDeclarationSetReconstructionComplete,
              authority.independentCandidateCatalogReconstructionComplete,
              authority.independentExperimentManifestReconstructionComplete,
              authority.canonicalCandidateCatalogBytesMatched,
              authority.canonicalExperimentManifestBytesMatched,
              authority.canonicalHashChainRecomputationComplete,
              authority.outputNamespaceAbsenceVerified,
              authority.referencedInputSnapshotAvailable,
              authority.referencedArtifactBytesAvailable,
              authority.llmGitStateIndependentlyObserved,
              authority.independentPrimeReplayComplete,
              !authority.ergenticsLatinProducerModuleImported,
              !authority.ergenticsLatinProducerFunctionInvoked,
              !authority.ergenticsLatinProducerSourceUsedAsReplayImplementation,
              !authority.liveProducerWorkspaceRevalidationComplete,
              !authority.revalidatorToolSourceIndependentlyObserved,
              !authority.originRemoteCryptographicallyAuthenticated,
              !authority.ignoredWorkspaceBytesObserved,
              !authority.declarationSourceSemanticsIndependentlyVerified,
              !authority.tokenizerModelSemanticsIndependentlyValidated,
              !authority.tokenizerTrainingReplayComplete,
              !authority.evaluationExecutionComplete,
              !authority.selectionObservationComplete,
              !authority.durableInputSnapshotPublished,
              !authority.durableGitObservationPublished,
              !authority.durableIndependentReplayObservationPublished,
              !authority.runtimeDecoderImplementationAvailable,
              !authority.runtimeDependencyClosureEstablished,
              !authority.runtimeInitializationEstablished,
              !authority.primeProposalPacketProduced,
              !authority.primeTrialAuthorizationProduced,
              !authority.primeDecisionReceiptProduced,
              !authority.candidateSelectionAuthorized,
              !authority.trialExecutionAuthorized,
              !authority.furtherTrainingAuthorized,
              !authority.promotionAuthorized,
              !authority.productUseAuthorized,
              !authority.publicationAuthorized,
              !authority.proposalPairPublicationPerformedByThisObservation,
              !authority.primeDurableReceiptPublished
        else {
            throw PrimeLatinProposalIndependentReplayProbeError
                .invalidObservation
        }

        let summary = PrimeLatinProposalIndependentReplayProbeSummary(
            schema: observation.schema,
            outcome: observation.outcome,
            replayPolicyID: observation.replayPolicyID,
            pairReceiptSHA256: observation.pairReceiptSHA256,
            producerCommit: observation.producerCommit,
            candidateCatalogSHA256: observation.candidateCatalogSHA256,
            experimentManifestSHA256: observation.experimentManifestSHA256,
            independentPrimeReplayComplete:
                authority.independentPrimeReplayComplete,
            liveProducerWorkspaceRevalidationComplete:
                authority.liveProducerWorkspaceRevalidationComplete)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var output = try encoder.encode(summary)
        output.append(0x0A)
        guard output.count <= 1_024 else {
            throw PrimeLatinProposalIndependentReplayProbeError
                .invalidObservation
        }
        FileHandle.standardOutput.write(output)
    }
}
