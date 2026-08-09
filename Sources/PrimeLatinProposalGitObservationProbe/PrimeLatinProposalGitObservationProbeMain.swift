import Foundation
import PrimeLatinProposalGitObservation

private enum PrimeLatinProposalGitObservationProbeError: Error {
    case invalidArguments
    case invalidObservation
}

private struct PrimeLatinProposalGitObservationArguments {
    let labRoot: URL
    let llmRepositoryRoot: URL
    let pairSHA256: String

    static func parse(_ rawArguments: [String]) throws -> Self {
        guard rawArguments.count == 8 else {
            throw PrimeLatinProposalGitObservationProbeError
                .invalidArguments
        }

        var action: String?
        var labRoot: String?
        var llmRepositoryRoot: String?
        var pairSHA256: String?
        var index = 0
        while index < rawArguments.count {
            let option = rawArguments[index]
            let value = rawArguments[index + 1]
            guard !value.isEmpty else {
                throw PrimeLatinProposalGitObservationProbeError
                    .invalidArguments
            }
            switch option {
            case "--action":
                guard action == nil else {
                    throw PrimeLatinProposalGitObservationProbeError
                        .invalidArguments
                }
                action = value
            case "--lab-root":
                guard labRoot == nil else {
                    throw PrimeLatinProposalGitObservationProbeError
                        .invalidArguments
                }
                labRoot = value
            case "--llm-repository-root":
                guard llmRepositoryRoot == nil else {
                    throw PrimeLatinProposalGitObservationProbeError
                        .invalidArguments
                }
                llmRepositoryRoot = value
            case "--pair-sha256":
                guard pairSHA256 == nil else {
                    throw PrimeLatinProposalGitObservationProbeError
                        .invalidArguments
                }
                pairSHA256 = value
            default:
                throw PrimeLatinProposalGitObservationProbeError
                    .invalidArguments
            }
            index += 2
        }

        guard action == "observe",
              let labRoot,
              labRoot.hasPrefix("/"),
              let llmRepositoryRoot,
              llmRepositoryRoot.hasPrefix("/"),
              let pairSHA256,
              pairSHA256.count == 64,
              pairSHA256.utf8.allSatisfy({
                  ($0 >= 48 && $0 <= 57) ||
                    ($0 >= 97 && $0 <= 102)
              }) else {
            throw PrimeLatinProposalGitObservationProbeError
                .invalidArguments
        }

        return Self(
            labRoot: URL(fileURLWithPath: labRoot, isDirectory: true),
            llmRepositoryRoot: URL(
                fileURLWithPath: llmRepositoryRoot,
                isDirectory: true),
            pairSHA256: pairSHA256)
    }
}

@main
struct PrimeLatinProposalGitObservationProbeMain {
    static func main() throws {
        let arguments = try PrimeLatinProposalGitObservationArguments.parse(
            Array(CommandLine.arguments.dropFirst()))
        let capture = try PrimeLatinProposalGitSourceCaptureV3.capture(
            labRoot: arguments.labRoot,
            llmRepositoryRoot: arguments.llmRepositoryRoot,
            pairSHA256: arguments.pairSHA256)
        let observation = try capture.recaptureAndValidateUnchanged()
        let authority = observation.authority
        guard observation == capture.observation,
              observation.schema
                == "ergentics_prime_latin_proposal_git_source_v3_observation",
              observation.outcome == "abstain",
              observation.verificationScope
                == "fixed_read_only_git_process_exact_head_tree_clean_status_and_seven_snapshot_repository_bindings_only_non_authorizing",
              observation.pairReceiptSHA256 == arguments.pairSHA256,
              observation.llmSource.repository
                == "Ergentics/ergentics-llm",
              observation.llmSource.commit
                == "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831",
              observation.llmSource.tree
                == "c1f41758aea2860ab06039776f5ea0403dff1b61",
              observation.headCommit == observation.llmSource.commit,
              observation.headTree == observation.llmSource.tree,
              observation.snapshotArtifactCount == 21,
              observation.repositoryArtifactCount == 7,
              observation.repositoryArtifacts.count == 7,
              observation.trackedIndexEntryCount == 144,
              observation.trackedIndexInventoryByteCount == 6_933,
              observation.trackedIndexInventorySHA256
                == "101afd50470f669f8b4de14f9188e16854a4166b355bf8a4e9ec810a59a9e289",
              observation.gitCommandCount == 17,
              observation.gitTool.absolutePath == "/usr/bin/git",
              observation.gitTool.environmentPolicyID
                == "prime_latin_git_read_only_fixed_environment_v1",
              observation.locallyDeclaredOriginURL
                == "https://github.com/Ergentics/ergentics-llm.git",
              observation.originObservationScope
                == "locally_declared_origin_only_not_network_authenticated",
              observation.objectFormat == "sha1",
              observation.porcelainV2StatusByteCount == 0,
              observation.porcelainV2StatusSHA256
                == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
              observation.rawCommitGitOID == observation.headCommit,
              observation.recomputedRawCommitGitOID
                == observation.headCommit,
              authority.disposition
                == "abstain_git_observation_only_requires_live_producer_revalidation_and_independent_replay",
              authority.snapshotCaptureAndRecaptureComplete,
              authority.stableLLMRepositoryRootBoundObservationComplete,
              authority.stableGitToolObservationComplete,
              authority.exactHeadCommitObserved,
              authority.exactHeadTreeObserved,
              authority.cleanPorcelainV2StatusObserved,
              authority.noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved,
              authority.exactRawCommitObjectObserved,
              authority.exactSevenRepositoryTreeEntriesObserved,
              authority.sevenRepositoryBlobHashCountBindingsMatchedSnapshot,
              authority.localOriginDeclarationObserved,
              authority.repeatedGitObservationUnchanged,
              authority.referencedInputSnapshotAvailable,
              authority.referencedArtifactBytesAvailable,
              authority.llmGitStateIndependentlyObserved,
              !authority.originRemoteCryptographicallyAuthenticated,
              !authority.ignoredWorkspaceBytesObserved,
              !authority.durableInputSnapshotPublished,
              !authority.durableGitObservationPublished,
              !authority.liveProducerWorkspaceRevalidationComplete,
              !authority.independentReplayComplete,
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
              !authority.primeDurableReceiptPublished else {
            throw PrimeLatinProposalGitObservationProbeError
                .invalidObservation
        }

        let ephemeralSummary =
            "{\"git_command_count\":\(observation.gitCommandCount)," +
            "\"head_commit\":\"\(observation.headCommit)\"," +
            "\"head_tree\":\"\(observation.headTree)\"," +
            "\"llm_git_state_independently_observed\":true," +
            "\"no_assume_unchanged_or_skip_worktree_index_entries_observed\":" +
            "true," +
            "\"outcome\":\"abstain\"," +
            "\"pair_receipt_sha256\":\"" +
            "\(observation.pairReceiptSHA256)\"," +
            "\"repository_artifact_count\":" +
            "\(observation.repositoryArtifactCount)," +
            "\"schema\":\"\(observation.schema)\"," +
            "\"snapshot_artifact_count\":" +
            "\(observation.snapshotArtifactCount)," +
            "\"tracked_index_entry_count\":" +
            "\(observation.trackedIndexEntryCount)," +
            "\"tracked_index_inventory_byte_count\":" +
            "\(observation.trackedIndexInventoryByteCount)," +
            "\"tracked_index_inventory_sha256\":\"" +
            "\(observation.trackedIndexInventorySHA256)\"}\n"
        let output = Data(ephemeralSummary.utf8)
        guard output.count <= 1_024 else {
            throw PrimeLatinProposalGitObservationProbeError
                .invalidObservation
        }
        try FileHandle.standardOutput.write(contentsOf: output)
    }
}
