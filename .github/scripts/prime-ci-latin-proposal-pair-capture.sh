#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

readonly script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly prime_root="$(cd -- "$script_directory/../.." && pwd -P)"
readonly expected_prime_head="${ERGENTICS_EXACT_REVISION:?ERGENTICS_EXACT_REVISION is required}"
readonly runner_temp="${RUNNER_TEMP:-/private/tmp}"

die() {
    echo "prime-ci-latin-proposal-pair-capture: $*" >&2
    exit 1
}

count_fixed_occurrences() {
    local needle="$1"
    local source_file="$2"
    awk -v needle="$needle" '
        BEGIN { count = 0 }
        {
            remainder = $0
            while ((offset = index(remainder, needle)) > 0) {
                count += 1
                remainder = substr(remainder, offset + length(needle))
            }
        }
        END { print count }
    ' "$source_file"
}

source_section_between() {
    local start_needle="$1"
    local end_needle="$2"
    local source_file="$3"
    awk -v start_needle="$start_needle" -v end_needle="$end_needle" '
        index($0, start_needle) > 0 { emitting = 1 }
        emitting && index($0, end_needle) > 0 &&
            index($0, start_needle) == 0 { exit }
        emitting { print }
    ' "$source_file"
}

for command_name in awk cp find git grep jq mkdir mktemp shasum sort stat swift tee tr unlink xcrun; do
    command -v "$command_name" >/dev/null 2>&1 ||
        die "missing command: $command_name"
done

require_exact_file_inventory() {
    local source_directory="$1"
    shift
    local observed_inventory
    local expected_inventory
    observed_inventory="$(
        find "$source_directory" \( -type f -o -type l \) -print |
            while IFS= read -r source_path; do
                printf '%s\n' "${source_path#"$source_directory/"}"
            done |
            LC_ALL=C sort
    )"
    expected_inventory="$(printf '%s\n' "$@" | LC_ALL=C sort)"
    [[ "$observed_inventory" == "$expected_inventory" ]] ||
        die "unexpected Swift source inventory: $source_directory"
}

[[ "$expected_prime_head" =~ ^[0-9a-f]{40}$ ]] ||
    die "exact revision must be a lowercase 40-character object ID"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout does not match ERGENTICS_EXACT_REVISION"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout is dirty"

readonly validation_manifest="$prime_root/Tests/PrimeLatinProposalPairCaptureValidation/Package.swift"
readonly capture_source="$prime_root/Sources/PrimeLatinProposalPairCapture/PrimeLatinProposalPairCapture.swift"
readonly capture_support="$prime_root/Sources/PrimeLatinProposalPairCapture/PrimeLatinArtifactReadSupport.swift"
readonly v3_inputs_source="$prime_root/Sources/PrimeLatinProposalPairCapture/PrimeLatinProposalInputsV3.swift"
readonly v3_capture_source="$prime_root/Sources/PrimeLatinProposalPairCapture/PrimeLatinProposalPairCaptureV3.swift"
readonly v3_snapshot_source="$prime_root/Sources/PrimeLatinProposalPairCapture/PrimeLatinProposalInputSnapshotV3.swift"
readonly probe_source="$prime_root/Sources/PrimeLatinProposalPairCaptureProbe/PrimeLatinProposalPairCaptureProbeMain.swift"
readonly git_observation_source="$prime_root/Sources/PrimeLatinProposalGitObservation/PrimeLatinProposalGitSourceV3.swift"
readonly git_observation_probe_source="$prime_root/Sources/PrimeLatinProposalGitObservationProbe/PrimeLatinProposalGitObservationProbeMain.swift"
readonly producer_revalidation_source="$prime_root/Sources/PrimeLatinProposalProducerRevalidationObservation/PrimeLatinProposalProducerRevalidationObservationV1.swift"
readonly producer_revalidation_probe_source="$prime_root/Sources/PrimeLatinProposalProducerRevalidationObservationProbe/PrimeLatinProposalProducerRevalidationObservationProbeMain.swift"
readonly independent_replay_source="$prime_root/Sources/PrimeLatinProposalIndependentReplay/PrimeLatinProposalIndependentReplayV1.swift"
readonly independent_replay_probe_source="$prime_root/Sources/PrimeLatinProposalIndependentReplayProbe/PrimeLatinProposalIndependentReplayProbeMain.swift"
readonly validation_composition_source="$prime_root/Sources/PrimeLatinProposalValidationComposition/PrimeLatinProposalValidationCompositionV1.swift"
readonly validation_composition_receipt_source="$prime_root/Sources/PrimeLatinProposalValidationCompositionReceipt/PrimeLatinProposalValidationCompositionReceiptV1.swift"
readonly validation_composition_receipt_publisher_source="$prime_root/Sources/PrimeLatinProposalValidationCompositionReceiptPublisher/PrimeLatinProposalValidationCompositionReceiptPublisherV1.swift"
readonly capture_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalPairCaptureTests.swift"
readonly v3_inputs_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalInputsV3Tests.swift"
readonly v3_snapshot_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalInputSnapshotV3Tests.swift"
readonly git_observation_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalGitSourceV3Tests.swift"
readonly producer_revalidation_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalProducerRevalidationObservationTests.swift"
readonly independent_replay_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalIndependentReplayV1Tests.swift"
readonly validation_composition_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalValidationCompositionV1Tests.swift"
readonly validation_composition_receipt_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalValidationCompositionReceiptV1Tests.swift"
readonly validation_composition_receipt_publisher_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalValidationCompositionReceiptPublisherV1Tests.swift"
readonly source_contract_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalPairCaptureSourceContractTests.swift"

for required_file in \
    "$validation_manifest" \
    "$capture_source" \
    "$capture_support" \
    "$v3_inputs_source" \
    "$v3_capture_source" \
    "$v3_snapshot_source" \
    "$probe_source" \
    "$git_observation_source" \
    "$git_observation_probe_source" \
    "$producer_revalidation_source" \
    "$producer_revalidation_probe_source" \
    "$independent_replay_source" \
    "$independent_replay_probe_source" \
    "$validation_composition_source" \
    "$validation_composition_receipt_source" \
    "$validation_composition_receipt_publisher_source" \
    "$capture_tests" \
    "$v3_inputs_tests" \
    "$v3_snapshot_tests" \
    "$git_observation_tests" \
    "$producer_revalidation_tests" \
    "$independent_replay_tests" \
    "$validation_composition_tests" \
    "$validation_composition_receipt_tests" \
    "$validation_composition_receipt_publisher_tests" \
    "$source_contract_tests"; do
    [[ -f "$required_file" && ! -L "$required_file" ]] ||
        die "required validation source is missing or linked: $required_file"
done
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalPairCapture" \
    "PrimeLatinArtifactReadSupport.swift" \
    "PrimeLatinProposalInputSnapshotV3.swift" \
    "PrimeLatinProposalInputsV3.swift" \
    "PrimeLatinProposalPairCapture.swift" \
    "PrimeLatinProposalPairCaptureV3.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalPairCaptureProbe" \
    "PrimeLatinProposalPairCaptureProbeMain.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalGitObservation" \
    "PrimeLatinProposalGitSourceV3.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalGitObservationProbe" \
    "PrimeLatinProposalGitObservationProbeMain.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalProducerRevalidationObservation" \
    "PrimeLatinProposalProducerRevalidationObservationV1.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalProducerRevalidationObservationProbe" \
    "PrimeLatinProposalProducerRevalidationObservationProbeMain.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalIndependentReplay" \
    "PrimeLatinProposalIndependentReplayV1.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalIndependentReplayProbe" \
    "PrimeLatinProposalIndependentReplayProbeMain.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalValidationComposition" \
    "PrimeLatinProposalValidationCompositionV1.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalValidationCompositionReceipt" \
    "PrimeLatinProposalValidationCompositionReceiptV1.swift"
require_exact_file_inventory \
    "$prime_root/Sources/PrimeLatinProposalValidationCompositionReceiptPublisher" \
    "PrimeLatinProposalValidationCompositionReceiptPublisherV1.swift"
require_exact_file_inventory \
    "$prime_root/Tests/PrimeLatinProposalPairCaptureTests" \
    "PrimeLatinProposalGitSourceV3Tests.swift" \
    "PrimeLatinProposalPairCaptureSourceContractTests.swift" \
    "PrimeLatinProposalPairCaptureTests.swift" \
    "PrimeLatinProposalInputSnapshotV3Tests.swift" \
    "PrimeLatinProposalInputsV3Tests.swift" \
    "PrimeLatinProposalIndependentReplayV1Tests.swift" \
    "PrimeLatinProposalValidationCompositionV1Tests.swift" \
    "PrimeLatinProposalValidationCompositionReceiptV1Tests.swift" \
    "PrimeLatinProposalValidationCompositionReceiptPublisherV1Tests.swift" \
    "PrimeLatinProposalProducerRevalidationObservationTests.swift"

for forbidden_source_value in \
    "MLXLLM" \
    "LlamaModel" \
    "import PrimeCore" \
    "ErgenticsPrimeRuntime" \
    "ErgenticsNativeScaleEngineRecommend" \
    "Process(" \
    "O_WRONLY" \
    "O_RDWR" \
    "mkdirat(" \
    "renameat" \
    "unlinkat(" \
    "shell" \
    "pmhnp-companion-ergentics" \
    "--disable-sandbox"; do
    if grep -Fq -- "$forbidden_source_value" \
        "$capture_source" \
        "$capture_support" \
        "$v3_inputs_source" \
        "$v3_capture_source" \
        "$v3_snapshot_source" \
        "$probe_source" \
        "$validation_manifest"; then
        die "Latin capture surface contains forbidden value: $forbidden_source_value"
    fi
done

for forbidden_git_observation_value in \
    "import PrimeCore" \
    "import ErgenticsLLM" \
    "import ErgenticsTokenizer" \
    "import MLX" \
    "ErgenticsPrimeRuntime" \
    "LlamaModel" \
    "HuggingFace" \
    "PMHNP" \
    "pmhnp-companion-ergentics" \
    "ProcessInfo.processInfo.environment" \
    "URLSession" \
    "Network.framework" \
    "NWConnection" \
    "socket(" \
    "connect(" \
    "curl" \
    "python" \
    "ssh" \
    "scp" \
    "shell" \
    '"/bin/sh"' \
    '"/bin/bash"' \
    '"/usr/bin/env"' \
    "O_CREAT" \
    "O_WRONLY" \
    "O_RDWR" \
    "mkdirat(" \
    "renameat" \
    "unlinkat(" \
    "removeItem(" \
    "createDirectory(" \
    "createFile(" \
    "func publish" \
    "PrimeLatinTrialProposal" \
    "PrimeLatinTrialAuthorization" \
    '"fetch"' \
    '"push"' \
    '"clone"' \
    "--disable-sandbox"; do
    if grep -Fq -- "$forbidden_git_observation_value" \
        "$git_observation_source" \
        "$git_observation_probe_source" \
        "$validation_manifest"; then
        die "Latin Git-observation surface contains forbidden value: $forbidden_git_observation_value"
    fi
done
readonly git_observation_imports="$(grep -E '^import ' "$git_observation_source")"
readonly expected_git_observation_imports=$'import Darwin\nimport Glibc\nimport CryptoKit\nimport Foundation\nimport PrimeLatinProposalPairCapture'
[[ "$git_observation_imports" == "$expected_git_observation_imports" ]] ||
    die "Latin Git-observation source import inventory is not exact"
readonly git_observation_probe_imports="$(
    grep -E '^import ' "$git_observation_probe_source"
)"
readonly expected_git_observation_probe_imports=$'import Foundation\nimport PrimeLatinProposalGitObservation'
[[ "$git_observation_probe_imports" == \
        "$expected_git_observation_probe_imports" ]] ||
    die "Latin Git-observation probe import inventory is not exact"
[[ "$(count_fixed_occurrences "Process()" "$git_observation_source")" \
        == "1" ]] ||
    die "Latin Git-observation source must contain exactly one process launcher"
[[ "$(count_fixed_occurrences \
        "process.executableURL" "$git_observation_source")" \
        == "1" ]] ||
    die "Latin Git-observation source must assign exactly one executable URL"
[[ "$(count_fixed_occurrences '"/usr/bin/git"' \
        "$git_observation_source")" == "1" ]] ||
    die "Latin Git-observation source must bind exactly one Git executable"
[[ "$(count_fixed_occurrences "Process(" \
        "$git_observation_probe_source")" \
        == "0" ]] ||
    die "Latin Git-observation probe may not launch a process directly"
grep -Fq -- 'mode_t(0o6000) == 0' "$git_observation_source" ||
    die "Latin Git-observation source permits privileged Git mode bits"
grep -Fq -- '"core.fileMode=true"' "$git_observation_source" ||
    die "Latin Git-observation source does not force file-mode observation"
grep -Fq -- '"GIT_NO_LAZY_FETCH": "1"' "$git_observation_source" ||
    die "Latin Git-observation source does not prohibit promisor lazy fetches"
grep -Fq -- '"GIT_ALLOW_PROTOCOL": "none"' "$git_observation_source" ||
    die "Latin Git-observation source does not prohibit Git protocols"
grep -Fq -- 'operation: "tracked_index_visibility"' \
    "$git_observation_source" ||
    die "Latin Git-observation source lacks tracked-index visibility binding"
grep -Fq -- 'arguments: ["ls-files", "-v", "-z"]' \
    "$git_observation_source" ||
    die "Latin Git-observation source lacks its exact tracked-index command"
grep -Fq -- 'noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved = true' \
    "$git_observation_source" ||
    die "Latin Git-observation source lacks its tracked-index authority anchor"
for tracked_index_anchor in \
    "trackedIndexEntryCount" \
    "trackedIndexInventoryByteCount" \
    "trackedIndexInventorySHA256"; do
    grep -Fq -- "$tracked_index_anchor" "$git_observation_source" ||
        die "Latin Git-observation source lacks tracked-index evidence: $tracked_index_anchor"
done

readonly producer_revalidation_imports="$(
    grep -E '^import ' "$producer_revalidation_source"
)"
readonly expected_producer_revalidation_imports=$'import Darwin\nimport Glibc\nimport CryptoKit\nimport Compression\nimport Foundation\nimport PrimeLatinProposalGitObservation\nimport PrimeLatinProposalPairCapture'
[[ "$producer_revalidation_imports" == \
        "$expected_producer_revalidation_imports" ]] ||
    die "Latin producer-revalidation source import inventory is not exact"
readonly producer_revalidation_probe_imports="$(
    grep -E '^import ' "$producer_revalidation_probe_source"
)"
readonly expected_producer_revalidation_probe_imports=$'import Foundation\nimport PrimeLatinProposalProducerRevalidationObservation'
[[ "$producer_revalidation_probe_imports" == \
        "$expected_producer_revalidation_probe_imports" ]] ||
    die "Latin producer-revalidation probe import inventory is not exact"
for forbidden_producer_revalidation_value in \
    "import PrimeCore" \
    "import ErgenticsLLM" \
    "import ErgenticsTokenizer" \
    "import MLX" \
    "ErgenticsPrimeRuntime" \
    "LlamaModel" \
    "HuggingFace" \
    "PMHNP" \
    "pmhnp-companion-ergentics" \
    "ProcessInfo.processInfo.environment" \
    "URLSession" \
    "Network.framework" \
    "NWConnection" \
    "socket(" \
    "connect(" \
    "curl" \
    "python" \
    "ssh" \
    "scp" \
    '"/bin/sh"' \
    '"/bin/bash"' \
    '"/usr/bin/env"' \
    '"swift build"' \
    '"swift package"' \
    "publishProposalPairV3" \
    "func publish" \
    "PrimeLatinTrialProposal" \
    "PrimeLatinTrialAuthorization" \
    '"fetch"' \
    '"push"' \
    '"clone"' \
    "--disable-sandbox"; do
    if grep -Fq -- "$forbidden_producer_revalidation_value" \
        "$producer_revalidation_source" \
        "$producer_revalidation_probe_source" \
        "$validation_manifest"; then
        die "Latin producer-revalidation surface contains forbidden value: $forbidden_producer_revalidation_value"
    fi
done
[[ "$(count_fixed_occurrences "Process(" \
        "$producer_revalidation_probe_source")" == "0" ]] ||
    die "Latin producer-revalidation probe may not launch a process directly"
[[ "$(count_fixed_occurrences "Process()" \
        "$producer_revalidation_source")" == "1" ]] ||
    die "Latin producer-revalidation source must have one closed process launcher"
[[ "$(count_fixed_occurrences "process.executableURL" \
        "$producer_revalidation_source")" == "1" ]] ||
    die "Latin producer-revalidation source must assign one executable URL"
[[ "$(count_fixed_occurrences "/usr/bin/xcrun" \
        "$producer_revalidation_source")" == "4" ]] ||
    die "Latin producer-revalidation source must pin the exact xcrun route"
[[ "$(count_fixed_occurrences '"swiftc"' \
        "$producer_revalidation_source")" == "1" ]] ||
    die "Latin producer-revalidation source must use one fixed swiftc argv literal"
grep -Fq -- "processLaunchCount == 5" "$producer_revalidation_source" ||
    die "Latin producer-revalidation observation lacks its exact five-launch receipt"
[[ "$(count_fixed_occurrences "timeoutSeconds: 120" \
        "$producer_revalidation_source")" == "2" ]] ||
    die "Latin producer-revalidation source lacks its exact child timeouts"
grep -Fq -- "timeoutSeconds <= 300" "$producer_revalidation_source" ||
    die "Latin producer-revalidation runner lacks its absolute timeout ceiling"
grep -Fq -- \
    'Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver' \
    "$producer_revalidation_source" ||
    die "Latin producer-revalidation source lacks its fixed Swift driver path"
grep -Fq -- \
    'fixed_developer_directory_exact_swift_driver_binary_observed_not_cryptographically_authenticated' \
    "$producer_revalidation_source" ||
    die "Latin producer-revalidation source lacks its compiler identity scope"
for lexical_receipt in \
    "acl_get_fd_np:1" \
    "flistxattr:2" \
    "O_NOFOLLOW:3" \
    "fstat(:3" \
    "lstat(:2" \
    "realpath(:1" \
    "mkdtemp(:1" \
    "mkdir(:1" \
    "FileManager.default.removeItem:2"; do
    lexical_needle="${lexical_receipt%:*}"
    lexical_count="${lexical_receipt##*:}"
    [[ "$(count_fixed_occurrences "$lexical_needle" \
            "$producer_revalidation_source")" == "$lexical_count" ]] ||
        die "Latin producer-revalidation lexical receipt changed: $lexical_needle"
done
for required_producer_revalidation_identity in \
    "1ccfb6bf6718e2378f14ab87cacae1ada303cf48" \
    "6ee438bf1132d26767fbf447355b8165455b956f" \
    "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831" \
    "380c13a3f9f3421db875d2ccc3c4547002374a9d74427a0573e0c59f6d3078ac" \
    "802f7505ad91869b27420e0beb152e6ba725eb82a801b4fd9289d999afac0c81" \
    "302ccde06959cc6ffb411d455ad656c9e50e4ce1" \
    "686ee51886ed5813db6a9883cc6e5e9fa86f1e3f918dafad865e06926824a6e3" \
    "828f18920113f77a849dec56997618ae6f1addc7" \
    "91aa0ca7ebeeb97e808493ad4f0cede9c54dbb08ecc7476619e52cada883a0ee" \
    "b050f965afab11b46bed9037b42c0a59d27e3f26" \
    "180ebeb889cd6d585c89384efa8b4b55984501b4e6be0dbb8928d92cffb2c52d" \
    "9617fac7d88afb2bf33df7324ab15efa1a5a94aa" \
    "136a65f9f574b6a1f3a6e25d4fed66e9b859e536c55b8f28f8a6dd4797d64bd6" \
    "Sources/ErgenticsLatinProposalArtifacts/ErgenticsLatinProposalArtifacts.swift" \
    "Sources/ErgenticsLatinProposalV3Revalidation/ErgenticsLatinProposalV3Revalidation.swift" \
    "Sources/ErgenticsLatinProposalV3RevalidationProbe/ErgenticsLatinProposalV3RevalidationProbeMain.swift" \
    ".github/scripts/latin-proposal-artifacts.Package.swift"; do
    grep -Fq -- "$required_producer_revalidation_identity" \
        "$producer_revalidation_source" ||
        die "Latin producer-revalidation source lacks frozen tool identity: $required_producer_revalidation_identity"
done
readonly producer_revalidation_compact="$(tr -d '[:space:]' < "$producer_revalidation_source")"
for required_tool_byte_count in \
    "toolRawCommitByteCount:UInt64=1_328" \
    "trackedIndexEntryCount:UInt64=147" \
    "trackedIndexInventoryByteCount:UInt64=14_281" \
    "byteCount:325_892" \
    "byteCount:55_905" \
    "byteCount:8_115" \
    "byteCount:1_463"; do
    [[ "$producer_revalidation_compact" == *"$required_tool_byte_count"* ]] ||
        die "Latin producer-revalidation source lacks frozen byte count: $required_tool_byte_count"
done
for required_build_count in \
    "compileCommandCount:3" \
    "processLaunchCount:5" \
    "governanceArtifactCount:4" \
    "compilerInputSourceCount:3" \
    "invocationCount:2"; do
    [[ "$producer_revalidation_compact" == *"$required_build_count"* ]] ||
        die "Latin producer-revalidation source lacks exact build/process count: $required_build_count"
done
for required_child_probe_option in \
    "--producer-repository-root" \
    "--lab-root" \
    "--expected-pair-receipt-sha256" \
    "--dependency-lock-relative-path" \
    "--initialization-contract-relative-path" \
    "--corpus-manifest-relative-path" \
    "--evaluation-contract-relative-path" \
    "--training-split-id" \
    "--training-split-relative-path" \
    "--validation-split-id" \
    "--validation-split-relative-path" \
    "--selection-split-id" \
    "--selection-split-relative-path" \
    "--selection-observation-relative-path" \
    "--optimizer-steps" \
    "--training-tokens" \
    "--wall-clock-seconds" \
    "--output-namespace"; do
    [[ "$(count_fixed_occurrences "$required_child_probe_option" \
            "$producer_revalidation_source")" == "1" ]] ||
        die "Latin producer-revalidation child option is not exact once: $required_child_probe_option"
done

readonly independent_replay_imports="$(
    grep -E '^import ' "$independent_replay_source"
)"
readonly expected_independent_replay_imports=$'import CryptoKit\nimport Foundation\nimport PrimeLatinProposalGitObservation\nimport PrimeLatinProposalPairCapture'
[[ "$independent_replay_imports" == \
        "$expected_independent_replay_imports" ]] ||
    die "Latin independent-replay source import inventory is not exact"
readonly independent_replay_probe_imports="$(
    grep -E '^import ' "$independent_replay_probe_source"
)"
readonly expected_independent_replay_probe_imports=$'import Foundation\nimport PrimeLatinProposalIndependentReplay'
[[ "$independent_replay_probe_imports" == \
        "$expected_independent_replay_probe_imports" ]] ||
    die "Latin independent-replay probe import inventory is not exact"
for forbidden_independent_replay_value in \
    "import PrimeLatinProposalProducerRevalidationObservation" \
    "PrimeLatinProposalProducerRevalidationCapture" \
    "import PrimeCore" \
    "import ErgenticsLLM" \
    "import ErgenticsTokenizer" \
    "import ErgenticsLatinProposalArtifacts" \
    "import ErgenticsLatinCandidateDeclarations" \
    "import MLX" \
    "ErgenticsPrimeRuntime" \
    "LlamaModel" \
    "HuggingFace" \
    "PMHNP" \
    "pmhnp-companion-ergentics" \
    "ProcessInfo.processInfo.environment" \
    "URLSession" \
    "Network.framework" \
    "NWConnection" \
    "socket(" \
    "connect(" \
    "curl" \
    "python" \
    "ssh" \
    "scp" \
    '"/bin/sh"' \
    '"/bin/bash"' \
    '"/usr/bin/env"' \
    '"/usr/bin/xcrun"' \
    '"/usr/bin/git"' \
    "O_CREAT" \
    "O_WRONLY" \
    "O_RDWR" \
    "mkdirat(" \
    "renameat" \
    "unlinkat(" \
    "removeItem(" \
    "createDirectory(" \
    "createFile(" \
    ".write(to:" \
    '"swift build"' \
    '"swift package"' \
    "publishProposalPairV3" \
    "func publish" \
    "PrimeLatinTrialProposal" \
    "PrimeLatinTrialAuthorization" \
    '"fetch"' \
    '"push"' \
    '"clone"' \
    "--disable-sandbox"; do
    if grep -Fq -- "$forbidden_independent_replay_value" \
        "$independent_replay_source" \
        "$independent_replay_probe_source"; then
        die "Latin independent-replay surface contains forbidden value: $forbidden_independent_replay_value"
    fi
done
[[ "$(count_fixed_occurrences "Process(" \
        "$independent_replay_source")" == "0" ]] ||
    die "Latin independent replay may not launch a process"
[[ "$(count_fixed_occurrences "Process(" \
        "$independent_replay_probe_source")" == "0" ]] ||
    die "Latin independent-replay probe may not launch a process"
for required_independent_replay_identity in \
    "ergentics_prime_latin_proposal_v3_independent_replay_observation_v1" \
    "prime_owned_independent_typed_reconstruction_from_one_git_bound_retained_twenty_one_original_input_snapshot_and_byte_exact_catalog_experiment_cross_check_only_non_authorizing" \
    "abstain_independent_prime_structural_replay_complete_live_producer_revalidation_not_composed_and_runtime_decoder_initialization_evaluation_trial_and_publication_authority_absent" \
    "prime_latin_v3_retained_original_input_independent_reconstruction_v1" \
    "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7" \
    "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831" \
    "c1f41758aea2860ab06039776f5ea0403dff1b61" \
    "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4" \
    "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76" \
    "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70" \
    "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f" \
    "815b3231fbb000968bbe2c19efe92013540d7241cba728c9b0ec1e89e9a4d193" \
    "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881" \
    "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c" \
    "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265" \
    "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd" \
    "models/latin-prospective/structural-fixture-v3-776c412e"; do
    grep -Fq -- "$required_independent_replay_identity" \
        "$independent_replay_source" ||
        die "Latin independent replay lacks frozen identity: $required_independent_replay_identity"
done
readonly independent_replay_compact="$(tr -d '[:space:]' < "$independent_replay_source")"
readonly independent_replay_probe_compact="$(
    tr -d '[:space:]' < "$independent_replay_probe_source"
)"
for required_independent_replay_plan_count in \
    "pairReceiptByteCount:1_833" \
    "candidateCatalogByteCount:20_803" \
    "experimentManifestByteCount:3_364" \
    "declarationTargetClosureByteCount:1_961" \
    "declarationBundleByteCount:14_302" \
    "candidateDeclarationSetByteCount:14_860" \
    "tokenizerBundleByteCount:2_930"; do
    [[ "$independent_replay_compact" == \
        *"$required_independent_replay_plan_count"* ]] ||
        die "Latin independent replay lacks frozen plan count: $required_independent_replay_plan_count"
done
for required_independent_replay_count in \
    "observation.inputBindingCount==21" \
    "observation.retainedOriginalInputByteCount==8_084_712" \
    "observation.pairReceiptByteCount==1_833" \
    "observation.candidateCatalogByteCount==20_803" \
    "observation.experimentManifestByteCount==3_364" \
    "observation.candidateDeclarationSetByteCount==14_860" \
    "observation.tokenizerBundleByteCount==2_930" \
    "observation.optimizerSteps==1" \
    "observation.trainingTokens==128" \
    "observation.wallClockSeconds==60" \
    "observation.orderedTensorCount==12" \
    "observation.uniqueParameterStorageCount==11" \
    "observation.totalParameterCount==131_736"; do
    [[ "$independent_replay_probe_compact" == \
        *"$required_independent_replay_count"* ]] ||
        die "Latin independent replay lacks frozen count: $required_independent_replay_count"
done
for required_true_authority_field in \
    "pairCaptureAndRecaptureComplete" \
    "inputSnapshotCaptureAndRecaptureComplete" \
    "producerGitObservationComplete" \
    "exactTwentyOneOriginalInputBindingsCrossBound" \
    "exactTwentyOneOriginalInputBytesRetained" \
    "retainedOriginalInputHashCountRecomputationComplete" \
    "independentTokenizerBundleReconstructionComplete" \
    "independentDeclarationTargetClosureReconstructionComplete" \
    "independentCandidateIdentityReconstructionComplete" \
    "independentCandidateDeclarationSetReconstructionComplete" \
    "independentCandidateCatalogReconstructionComplete" \
    "independentExperimentManifestReconstructionComplete" \
    "canonicalCandidateCatalogBytesMatched" \
    "canonicalExperimentManifestBytesMatched" \
    "canonicalHashChainRecomputationComplete" \
    "outputNamespaceAbsenceVerified" \
    "referencedInputSnapshotAvailable" \
    "referencedArtifactBytesAvailable" \
    "llmGitStateIndependentlyObserved" \
    "independentPrimeReplayComplete"; do
    [[ "$independent_replay_compact" == \
        *"$required_true_authority_field=true"* ]] ||
        die "Latin independent replay lacks true authority receipt: $required_true_authority_field"
done
for required_false_authority_field in \
    "ergenticsLatinProducerModuleImported" \
    "ergenticsLatinProducerFunctionInvoked" \
    "ergenticsLatinProducerSourceUsedAsReplayImplementation" \
    "liveProducerWorkspaceRevalidationComplete" \
    "revalidatorToolSourceIndependentlyObserved" \
    "originRemoteCryptographicallyAuthenticated" \
    "ignoredWorkspaceBytesObserved" \
    "declarationSourceSemanticsIndependentlyVerified" \
    "tokenizerModelSemanticsIndependentlyValidated" \
    "tokenizerTrainingReplayComplete" \
    "evaluationExecutionComplete" \
    "selectionObservationComplete" \
    "durableInputSnapshotPublished" \
    "durableGitObservationPublished" \
    "durableIndependentReplayObservationPublished" \
    "runtimeDecoderImplementationAvailable" \
    "runtimeDependencyClosureEstablished" \
    "runtimeInitializationEstablished" \
    "primeProposalPacketProduced" \
    "primeTrialAuthorizationProduced" \
    "primeDecisionReceiptProduced" \
    "candidateSelectionAuthorized" \
    "trialExecutionAuthorized" \
    "furtherTrainingAuthorized" \
    "promotionAuthorized" \
    "productUseAuthorized" \
    "publicationAuthorized" \
    "proposalPairPublicationPerformedByThisObservation" \
    "primeDurableReceiptPublished"; do
    [[ "$independent_replay_compact" == \
        *"$required_false_authority_field=false"* ]] ||
        die "Latin independent replay lacks false authority ceiling: $required_false_authority_field"
done
[[ "$producer_revalidation_compact" == \
    *"independentPrimeReplayComplete=false"* ]] ||
    die "producer revalidation may not claim independent replay completion"
readonly v3_capture_compact="$(tr -d '[:space:]' < "$v3_capture_source")"
[[ "$v3_capture_compact" == *"independentReplayComplete=false"* \
        && "$v3_capture_compact" == \
            *"liveProducerWorkspaceRevalidationComplete=false"* ]] ||
    die "pair capture may not absorb sibling completion claims"
readonly git_observation_compact="$(
    tr -d '[:space:]' < "$git_observation_source"
)"
[[ "$git_observation_compact" == *"independentReplayComplete=false"* \
        && "$git_observation_compact" == \
            *"liveProducerWorkspaceRevalidationComplete=false"* ]] ||
    die "Git observation may not absorb sibling completion claims"
for required_independent_replay_probe_option in \
    "--action" \
    "--lab-root" \
    "--llm-repository-root"; do
    [[ "$(count_fixed_occurrences "$required_independent_replay_probe_option" \
            "$independent_replay_probe_source")" == "1" ]] ||
        die "Latin independent-replay probe option is not exact once: $required_independent_replay_probe_option"
done

readonly validation_composition_imports="$(
    grep -E '^import ' "$validation_composition_source"
)"
readonly expected_validation_composition_imports=$'import Foundation\nimport PrimeLatinProposalIndependentReplay\nimport PrimeLatinProposalProducerRevalidationObservation'
[[ "$validation_composition_imports" == \
        "$expected_validation_composition_imports" ]] ||
    die "Latin validation-composition source import inventory is not exact"
for forbidden_validation_composition_value in \
    "import PrimeLatinProposalPairCapture" \
    "import PrimeLatinProposalGitObservation" \
    "PrimeLatinProposalPairCaptureV3" \
    "PrimeLatinProposalGitSourceCaptureV3" \
    "PrimeLatinProposalInputSnapshotCaptureV3" \
    "import PrimeCore" \
    "import ErgenticsLLM" \
    "import ErgenticsTokenizer" \
    "import ErgenticsLatinProposalArtifacts" \
    "import ErgenticsLatinCandidateDeclarations" \
    "import MLX" \
    "ErgenticsPrimeRuntime" \
    "LlamaModel" \
    "HuggingFace" \
    "PMHNP" \
    "pmhnp-companion-ergentics" \
    "@main" \
    "CommandLine" \
    "Process(" \
    "ProcessInfo.processInfo.environment" \
    "FileManager" \
    "URLSession" \
    "Network.framework" \
    "NWConnection" \
    "socket(" \
    "connect(" \
    "curl" \
    "python" \
    "ssh" \
    "scp" \
    '"/bin/sh"' \
    '"/bin/bash"' \
    '"/usr/bin/env"' \
    '"/usr/bin/git"' \
    "O_CREAT" \
    "O_WRONLY" \
    "O_RDWR" \
    "mkdirat(" \
    "renameat" \
    "unlinkat(" \
    "removeItem(" \
    "createDirectory(" \
    "createFile(" \
    ".write(to:" \
    "FileHandle.standardOutput" \
    "FileHandle.standardError" \
    "publishProposalPairV3" \
    "func publish" \
    "PrimeLatinTrialProposal" \
    "PrimeLatinTrialAuthorization" \
    '"fetch"' \
    '"push"' \
    '"clone"' \
    "--disable-sandbox"; do
    if grep -Fq -- "$forbidden_validation_composition_value" \
        "$validation_composition_source"; then
        die "Latin validation-composition surface contains forbidden value: $forbidden_validation_composition_value"
    fi
done
for required_validation_composition_anchor in \
    "public enum PrimeLatinProposalValidationCompositionErrorV1" \
    "public struct PrimeLatinProposalValidationCompositionAuthorityBoundaryV1" \
    "public struct PrimeLatinProposalValidationCompositionObservationV1" \
    "public final class PrimeLatinProposalValidationCompositionCaptureV1" \
    "public static func capture(" \
    "request: PrimeLatinProposalProducerRevalidationRequestV1" \
    "public let observation" \
    "public func recaptureAndValidateUnchanged()" \
    "compositionPolicyID" \
    "producerRevalidationObservation" \
    "independentReplayObservation" \
    "invalidChildObservation" \
    "crossBindingMismatch" \
    "captureChanged" \
    "ergentics_prime_latin_proposal_v3_validation_composition_observation_v1" \
    "abstain" \
    "prime_latin_v3_producer_revalidation_independent_replay_composition_v1" \
    "prime_owned_cooperative_same_request_root_sequence_composing_one_live_producer_revalidation_observation_and_one_independent_replay_observation_with_exact_shared_identity_hash_count_budget_and_output_namespace_cross_bindings_only_non_authorizing" \
    "abstain_live_producer_revalidation_and_independent_prime_replay_composed_proposal_policy_runtime_decoder_initialization_evaluation_trial_decision_and_publication_authority_absent"; do
    grep -Fq -- "$required_validation_composition_anchor" \
        "$validation_composition_source" ||
        die "Latin validation composition lacks frozen anchor: $required_validation_composition_anchor"
done
readonly validation_composition_compact="$(
    tr -d '[:space:]' < "$validation_composition_source"
)"
for required_validation_composition_true_field in \
    "producerRevalidationCaptureAndRecaptureComplete" \
    "independentReplayCaptureAndRecaptureComplete" \
    "cooperativeSameRequestRootSequenceComplete" \
    "producerRevalidationAuthorityBoundaryExact" \
    "independentReplayAuthorityBoundaryExact" \
    "exactPairReceiptCrossBindingMatched" \
    "exactProducerSourceCrossBindingMatched" \
    "exactCandidateCatalogCrossBindingMatched" \
    "exactExperimentManifestCrossBindingMatched" \
    "exactCandidateDeclarationSetCrossBindingMatched" \
    "exactTokenizerBundleCrossBindingMatched" \
    "exactCandidateIdentityInventoryCrossBindingMatched" \
    "exactTwentyOneInputBindingCountCrossBindingMatched" \
    "exactTwentyOneOriginalInputBytesRetained" \
    "exactTrialBudgetCrossBindingMatched" \
    "exactOutputNamespaceCrossBindingMatched" \
    "outputNamespaceAbsenceVerified" \
    "referencedInputSnapshotAvailable" \
    "referencedArtifactBytesAvailable" \
    "llmGitStateIndependentlyObserved" \
    "revalidatorToolSourceIndependentlyObserved" \
    "liveProducerWorkspaceRevalidationComplete" \
    "independentPrimeReplayComplete" \
    "validationCompositionComplete"; do
    [[ "$validation_composition_compact" == \
        *"$required_validation_composition_true_field=true"* ]] ||
        die "Latin validation composition lacks true authority receipt: $required_validation_composition_true_field"
done
for required_validation_composition_false_field in \
    "atomicCrossProcessSnapshotEstablished" \
    "compilerCryptographicallyAuthenticated" \
    "externalSourceToBinaryAttestationAvailable" \
    "originRemoteCryptographicallyAuthenticated" \
    "ignoredWorkspaceBytesObserved" \
    "declarationSourceSemanticsIndependentlyVerified" \
    "tokenizerModelSemanticsIndependentlyValidated" \
    "tokenizerTrainingReplayComplete" \
    "evaluationExecutionComplete" \
    "selectionObservationComplete" \
    "durableInputSnapshotPublished" \
    "durableGitObservationPublished" \
    "durableProducerRevalidationObservationPublished" \
    "durableIndependentReplayObservationPublished" \
    "durableValidationCompositionObservationPublished" \
    "runtimeDecoderImplementationAvailable" \
    "runtimeDependencyClosureEstablished" \
    "runtimeInitializationEstablished" \
    "primeProposalPolicyEstablished" \
    "primeProposalPacketProduced" \
    "primeTrialAuthorizationProduced" \
    "primeDecisionReceiptProduced" \
    "candidateSelectionAuthorized" \
    "trialExecutionAuthorized" \
    "furtherTrainingAuthorized" \
    "promotionAuthorized" \
    "productUseAuthorized" \
    "publicationAuthorized" \
    "proposalPairPublicationPerformedByThisComposition" \
    "primeDurableReceiptPublished"; do
    [[ "$validation_composition_compact" == \
        *"$required_validation_composition_false_field=false"* ]] ||
        die "Latin validation composition lacks false authority ceiling: $required_validation_composition_false_field"
done
readonly validation_composition_producer_projection="$(
    source_section_between \
        "    private static func projectProducer(" \
        "    private static func projectReplay(" \
        "$validation_composition_source"
)"
readonly validation_composition_replay_projection="$(
    source_section_between \
        "    private static func projectReplay(" \
        "    private static func producerContractExact(" \
        "$validation_composition_source"
)"
readonly validation_composition_producer_contract="$(
    source_section_between \
        "    private static func producerContractExact(" \
        "    private static func replayContractExact(" \
        "$validation_composition_source"
)"
readonly validation_composition_engine="$(
    source_section_between \
        "enum PrimeLatinProposalValidationCompositionEngineV1 {" \
        "public final class PrimeLatinProposalValidationCompositionCaptureV1" \
        "$validation_composition_source"
)"
readonly validation_composition_sequence="$(
    source_section_between \
        "    static func validateSequenceForTesting(" \
        "    private static func validateLiveSequence(" \
        "$validation_composition_source"
)"
readonly validation_composition_live_sequence="$(
    source_section_between \
        "    private static func validateLiveSequence(" \
        "    private static func exactProjectionForTesting(" \
        "$validation_composition_source"
)"
readonly validation_composition_producer_projection_compact="$(
    tr -d '[:space:]' <<< "$validation_composition_producer_projection"
)"
readonly validation_composition_replay_projection_compact="$(
    tr -d '[:space:]' <<< "$validation_composition_replay_projection"
)"
readonly validation_composition_producer_contract_compact="$(
    tr -d '[:space:]' <<< "$validation_composition_producer_contract"
)"
readonly validation_composition_sequence_compact="$(
    tr -d '[:space:]' <<< "$validation_composition_sequence"
)"
readonly validation_composition_live_sequence_compact="$(
    tr -d '[:space:]' <<< "$validation_composition_live_sequence"
)"
[[ "$(count_fixed_occurrences '"/usr/bin/xcrun"' \
        "$validation_composition_source")" == "1" ]] ||
    die "Latin validation composition must bind exactly one xcrun child observation"
[[ "$validation_composition_producer_contract_compact" == \
        *'build.compilerLauncher.absolutePath=="/usr/bin/xcrun"'* ]] ||
    die "Latin validation composition does not bind the producer compiler launcher"
for validation_composition_raw_field in \
    "pairReceiptSHA256" \
    "producerRepository" \
    "producerCommit" \
    "producerTree" \
    "candidateCatalogSHA256" \
    "candidateCatalogByteCount" \
    "experimentManifestSHA256" \
    "experimentManifestByteCount" \
    "candidateDeclarationSetSHA256" \
    "candidateDeclarationSetByteCount" \
    "tokenizerBundleSHA256" \
    "tokenizerBundleByteCount" \
    "candidateIDs" \
    "candidateIdentitySHA256s" \
    "declarationBundleSHA256s" \
    "inputBindingCount" \
    "optimizerSteps" \
    "trainingTokens" \
    "wallClockSeconds" \
    "outputNamespace"; do
    [[ "$validation_composition_producer_projection_compact" == \
        *"$validation_composition_raw_field:value.$validation_composition_raw_field"* ]] ||
        die "Latin validation composition does not raw-project producer field: $validation_composition_raw_field"
    [[ "$validation_composition_replay_projection_compact" == \
        *"$validation_composition_raw_field:value.$validation_composition_raw_field"* ]] ||
        die "Latin validation composition does not raw-project replay field: $validation_composition_raw_field"
done
for validation_composition_producer_mapping in \
    "kind:.producer" \
    "requestLabRoot:request.labRoot.path" \
    "requestProducerRepositoryRoot:request.producerRepositoryRoot.path" \
    "childContractExact:producerContractExact(value)" \
    "pairReceiptByteCount:expected.pairReceiptByteCount" \
    "retainedOriginalInputByteCount:expected.retainedOriginalInputByteCount" \
    "orderedTensorCount:expected.orderedTensorCount" \
    "uniqueParameterStorageCount:expected.uniqueParameterStorageCount" \
    "totalParameterCount:expected.totalParameterCount"; do
    [[ "$validation_composition_producer_projection_compact" == \
        *"$validation_composition_producer_mapping"* ]] ||
        die "Latin validation composition lacks producer projection mapping: $validation_composition_producer_mapping"
done
for validation_composition_replay_mapping in \
    "kind:.replay" \
    "requestLabRoot:request.labRoot.path" \
    "requestProducerRepositoryRoot:request.producerRepositoryRoot.path" \
    "childContractExact:replayContractExact(value)" \
    "pairReceiptByteCount:value.pairReceiptByteCount" \
    "retainedOriginalInputByteCount:value.retainedOriginalInputByteCount" \
    "orderedTensorCount:value.orderedTensorCount" \
    "uniqueParameterStorageCount:value.uniqueParameterStorageCount" \
    "totalParameterCount:value.totalParameterCount"; do
    [[ "$validation_composition_replay_projection_compact" == \
        *"$validation_composition_replay_mapping"* ]] ||
        die "Latin validation composition lacks replay projection mapping: $validation_composition_replay_mapping"
done
[[ "$validation_composition_engine" != \
    *"PrimeLatinProposalProducerRevalidationObservationV1"* ]] ||
    die "Latin validation composition engine directly consumes the producer child"
[[ "$validation_composition_engine" != \
    *"PrimeLatinProposalIndependentReplayObservationV1"* ]] ||
    die "Latin validation composition engine directly consumes the replay child"
[[ "$(count_fixed_occurrences \
        "static func validate(" \
        "$validation_composition_source")" == "1" ]] ||
    die "Latin validation composition has an alternate validation engine"
[[ "$(count_fixed_occurrences \
        "PrimeLatinProposalValidationCompositionEngineV1.validate(" \
        "$validation_composition_source")" == "2" ]] ||
    die "Latin validation composition engine routing is not exact"
[[ "$(count_fixed_occurrences \
        "PrimeLatinProposalValidationCompositionBindingV1(" \
        "$validation_composition_source")" == "1" ]] ||
    die "Latin validation composition binding has an alternate constructor path"
[[ "$validation_composition_sequence_compact" == \
    *"letreplayBefore=tryrecaptureReplay()letproducerCurrent=tryrecaptureProducer()letreplayAfter=tryrecaptureReplay()"* ]] ||
    die "Latin validation composition sequence is not replay-producer-replay"
[[ "$validation_composition_sequence_compact" == \
    *"PrimeLatinProposalValidationCompositionEngineV1.validate(producer:producerCurrent,replay:replayAfter)"* ]] ||
    die "Latin validation composition sequence bypasses the single engine"
[[ "$validation_composition_live_sequence_compact" == \
    *"returntryvalidateSequenceForTesting("* ]] ||
    die "Latin validation composition live path bypasses the tested sequence"
[[ "$(count_fixed_occurrences \
        "validateSequenceForTesting(" \
        "$validation_composition_source")" == "2" ]] ||
    die "Latin validation composition sequence routing is not exact"
[[ "$(count_fixed_occurrences \
        "projectProducer(" \
        "$validation_composition_source")" == "3" ]] ||
    die "Latin validation composition producer projection routing is not exact"
[[ "$(count_fixed_occurrences \
        "projectReplay(" \
        "$validation_composition_source")" == "3" ]] ||
    die "Latin validation composition replay projection routing is not exact"

readonly validation_composition_receipt_imports="$(
    grep -E '^import ' "$validation_composition_receipt_source"
)"
[[ "$validation_composition_receipt_imports" == "import Foundation" ]] ||
    die "Latin validation-composition receipt import inventory is not exact"
for forbidden_validation_composition_receipt_value in \
    "import PrimeCore" \
    "import PrimeLatinProposalValidationComposition" \
    "import PrimeLatinProposalValidationCompositionReceiptPublisher" \
    "import Darwin" \
    "import Glibc" \
    "import CryptoKit" \
    "import MLX" \
    "MLXLLM" \
    "LlamaModel" \
    "ErgenticsPrimeRuntime" \
    "PrimeArtifactRoot" \
    "PrimeCanonicalJSON" \
    "PrimeSHA256" \
    "PrimeLatinProposalValidationCompositionCaptureV1" \
    "PrimeLatinProposalAdmissionPolicy" \
    "@main" \
    "CommandLine" \
    "Process(" \
    "ProcessInfo.processInfo.environment" \
    "FileManager" \
    "FileHandle" \
    "URLSession" \
    "NWConnection" \
    "socket(" \
    "connect(" \
    "O_CREAT" \
    "O_WRONLY" \
    "O_RDWR" \
    "mkdirat(" \
    "renameat" \
    "unlinkat(" \
    "removeItem(" \
    "createDirectory(" \
    "createFile(" \
    ".write(to:" \
    "func publish" \
    '"fetch"' \
    '"push"' \
    '"clone"' \
    "--disable-sandbox"; do
    if grep -Fq -- "$forbidden_validation_composition_receipt_value" \
        "$validation_composition_receipt_source"; then
        die "Latin validation-composition receipt contains forbidden capability: $forbidden_validation_composition_receipt_value"
    fi
done
for required_validation_composition_receipt_anchor in \
    "public enum PrimeLatinProposalValidationCompositionReceiptErrorV1" \
    "case invalidReceipt(String)" \
    "package enum PrimeLatinProposalValidationCompositionReceiptContractV1" \
    "package struct PrimeLatinProposalValidationCompositionReceiptProjectionV1" \
    "public struct PrimeLatinProposalValidationCompositionReceiptV1" \
    "Codable" \
    "Equatable" \
    "Sendable" \
    "public static let maximumByteCount: UInt64 = 65_536" \
    "package static var exactFinal: Self" \
    "package init(" \
    "projecting projection:" \
    "public init(from decoder: Decoder) throws" \
    "public func validateExactV1() throws" \
    "package var projection:" \
    "package static func relativePath(" \
    "forSHA256 sha256: String" \
    "ergentics_prime_latin_proposal_v3_validation_composition_receipt_v1" \
    'package static let outcome = "abstain"' \
    "durable_content_addressed_canonical_projection_of_one_exact_prime_" \
    "current_liveness_proposal_admission_runtime_trial_selection_" \
    "promotion_product_and_model_publication_authority_absent" \
    "prime_latin_v3_validation_composition_content_addressed_receipt_v1" \
    '"latin-validation-composition-receipts"' \
    'return receiptDirectory + "/" + sha256 + ".json"'; do
    grep -Fq -- "$required_validation_composition_receipt_anchor" \
        "$validation_composition_receipt_source" ||
        die "Latin validation-composition receipt lacks frozen anchor: $required_validation_composition_receipt_anchor"
done
readonly validation_composition_receipt_true_claims="$(
    source_section_between \
        "    package static let sourceAuthorityTrueClaims = [" \
        "    package static let sourceAuthorityFalseClaims = [" \
        "$validation_composition_receipt_source"
)"
readonly validation_composition_receipt_false_claims="$(
    source_section_between \
        "    package static let sourceAuthorityFalseClaims = [" \
        "    package static let receiptDirectory =" \
        "$validation_composition_receipt_source"
)"
[[ "$(grep -Ec '^[[:space:]]+"[A-Za-z0-9]+",$' \
        <<< "$validation_composition_receipt_true_claims")" == "24" ]] ||
    die "Latin validation-composition receipt true-claim inventory is not exact"
[[ "$(grep -Ec '^[[:space:]]+"[A-Za-z0-9]+",$' \
        <<< "$validation_composition_receipt_false_claims")" == "30" ]] ||
    die "Latin validation-composition receipt false-claim inventory is not exact"
for validation_composition_receipt_true_claim in \
    "producerRevalidationCaptureAndRecaptureComplete" \
    "independentReplayCaptureAndRecaptureComplete" \
    "cooperativeSameRequestRootSequenceComplete" \
    "producerRevalidationAuthorityBoundaryExact" \
    "independentReplayAuthorityBoundaryExact" \
    "exactPairReceiptCrossBindingMatched" \
    "exactProducerSourceCrossBindingMatched" \
    "exactCandidateCatalogCrossBindingMatched" \
    "exactExperimentManifestCrossBindingMatched" \
    "exactCandidateDeclarationSetCrossBindingMatched" \
    "exactTokenizerBundleCrossBindingMatched" \
    "exactCandidateIdentityInventoryCrossBindingMatched" \
    "exactTwentyOneInputBindingCountCrossBindingMatched" \
    "exactTwentyOneOriginalInputBytesRetained" \
    "exactTrialBudgetCrossBindingMatched" \
    "exactOutputNamespaceCrossBindingMatched" \
    "outputNamespaceAbsenceVerified" \
    "referencedInputSnapshotAvailable" \
    "referencedArtifactBytesAvailable" \
    "llmGitStateIndependentlyObserved" \
    "revalidatorToolSourceIndependentlyObserved" \
    "liveProducerWorkspaceRevalidationComplete" \
    "independentPrimeReplayComplete" \
    "validationCompositionComplete"; do
    [[ "$(count_fixed_occurrences \
            "\"$validation_composition_receipt_true_claim\"" \
            /dev/stdin <<< "$validation_composition_receipt_true_claims")" == "1" ]] ||
        die "Latin validation-composition receipt true claim is not exact: $validation_composition_receipt_true_claim"
done
for validation_composition_receipt_false_claim in \
    "atomicCrossProcessSnapshotEstablished" \
    "compilerCryptographicallyAuthenticated" \
    "externalSourceToBinaryAttestationAvailable" \
    "originRemoteCryptographicallyAuthenticated" \
    "ignoredWorkspaceBytesObserved" \
    "declarationSourceSemanticsIndependentlyVerified" \
    "tokenizerModelSemanticsIndependentlyValidated" \
    "tokenizerTrainingReplayComplete" \
    "evaluationExecutionComplete" \
    "selectionObservationComplete" \
    "durableInputSnapshotPublished" \
    "durableGitObservationPublished" \
    "durableProducerRevalidationObservationPublished" \
    "durableIndependentReplayObservationPublished" \
    "durableValidationCompositionObservationPublished" \
    "runtimeDecoderImplementationAvailable" \
    "runtimeDependencyClosureEstablished" \
    "runtimeInitializationEstablished" \
    "primeProposalPolicyEstablished" \
    "primeProposalPacketProduced" \
    "primeTrialAuthorizationProduced" \
    "primeDecisionReceiptProduced" \
    "candidateSelectionAuthorized" \
    "trialExecutionAuthorized" \
    "furtherTrainingAuthorized" \
    "promotionAuthorized" \
    "productUseAuthorized" \
    "publicationAuthorized" \
    "proposalPairPublicationPerformedByThisComposition" \
    "primeDurableReceiptPublished"; do
    [[ "$(count_fixed_occurrences \
            "\"$validation_composition_receipt_false_claim\"" \
            /dev/stdin <<< "$validation_composition_receipt_false_claims")" == "1" ]] ||
        die "Latin validation-composition receipt false claim is not exact: $validation_composition_receipt_false_claim"
done
[[ "$(count_fixed_occurrences \
        "try validateExactV1()" \
        "$validation_composition_receipt_source")" == "1" ]] ||
    die "Latin validation-composition receipt has an alternate validation path"
[[ "$(count_fixed_occurrences \
        "try self.init(projecting: projection)" \
        "$validation_composition_receipt_source")" == "1" ]] ||
    die "Latin validation-composition receipt decode bypasses its package initializer"
[[ "$(count_fixed_occurrences \
        "PrimeLatinProposalValidationCompositionReceiptProjectionV1(" \
        "$validation_composition_receipt_source")" == "2" ]] ||
    die "Latin validation-composition receipt projection routing is not exact"

readonly validation_composition_receipt_publisher_imports="$(
    grep -E '^import ' "$validation_composition_receipt_publisher_source"
)"
readonly expected_validation_composition_receipt_publisher_imports=$'import Foundation\nimport PrimeCore\nimport PrimeLatinProposalValidationComposition\nimport PrimeLatinProposalValidationCompositionReceipt'
[[ "$validation_composition_receipt_publisher_imports" == \
        "$expected_validation_composition_receipt_publisher_imports" ]] ||
    die "Latin validation-composition receipt-publisher imports are not exact"
for forbidden_validation_composition_receipt_publisher_value in \
    "import PrimeLatinProposalPairCapture" \
    "import PrimeLatinProposalGitObservation" \
    "import PrimeLatinProposalProducerRevalidationObservation" \
    "import PrimeLatinProposalIndependentReplay" \
    "import Darwin" \
    "import Glibc" \
    "import CryptoKit" \
    "import ErgenticsLLM" \
    "import ErgenticsTokenizer" \
    "import MLX" \
    "MLXLLM" \
    "LlamaModel" \
    "ErgenticsPrimeRuntime" \
    "PrimeLatinProposalAdmissionPolicy" \
    "@main" \
    "CommandLine" \
    "Process(" \
    "ProcessInfo.processInfo.environment" \
    "FileManager" \
    "FileHandle" \
    "URLSession" \
    "NWConnection" \
    "socket(" \
    "connect(" \
    "O_CREAT" \
    "O_WRONLY" \
    "O_RDWR" \
    "open(" \
    "mkdirat(" \
    "renameat" \
    "unlinkat(" \
    "removeItem(" \
    "createDirectory(" \
    "createFile(" \
    ".write(to:" \
    '"/bin/sh"' \
    '"/bin/bash"' \
    '"/usr/bin/env"' \
    '"/usr/bin/git"' \
    '"fetch"' \
    '"push"' \
    '"clone"' \
    "PrimeLatinProposalValidationCompositionCaptureV1.capture(" \
    "PrimeLatinTrialProposal" \
    "PrimeLatinTrialAuthorization" \
    "--disable-sandbox"; do
    if grep -Fq -- "$forbidden_validation_composition_receipt_publisher_value" \
        "$validation_composition_receipt_publisher_source"; then
        die "Latin validation-composition receipt publisher contains forbidden capability: $forbidden_validation_composition_receipt_publisher_value"
    fi
done
for required_validation_composition_receipt_publisher_anchor in \
    "public enum PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1" \
    "case invalidSourceObservation(String)" \
    "case captureChanged" \
    "case receiptTooLarge" \
    "case publicationFailed" \
    "case verificationFailed" \
    "public struct PrimeLatinProposalValidationCompositionReceiptPublicationAuthorityBoundaryV1" \
    "public struct PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1" \
    "public enum PrimeLatinProposalValidationCompositionReceiptPublisherV1" \
    "public static func publish(" \
    "capture: PrimeLatinProposalValidationCompositionCaptureV1" \
    "artifactRoot: PrimeArtifactRoot" \
    "PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1" \
    "static func publishForTesting(" \
    "private static func publishUsingSingleEngine(" \
    "ergentics_prime_latin_proposal_v3_validation_composition_" \
    "receipt_publication_observation_v1" \
    'outcome = "abstain"' \
    "prime_owned_descriptor_safe_exclusive_content_addressed_" \
    "publication_of_one_canonical_validation_composition_" \
    "receipt_only_non_authorizing" \
    "prime_latin_v3_validation_composition_receipt_publication_v1" \
    "abstain_durable_validation_composition_receipt_published_" \
    "decoded_receipt_does_not_restore_live_validation_or_" \
    "establish_proposal_admission_packet_trial_runtime_selection_" \
    "promotion_product_or_publication_authority"; do
    grep -Fq -- "$required_validation_composition_receipt_publisher_anchor" \
        "$validation_composition_receipt_publisher_source" ||
        die "Latin validation-composition receipt publisher lacks frozen anchor: $required_validation_composition_receipt_publisher_anchor"
done
readonly validation_composition_receipt_publication_authority="$(
    source_section_between \
        "public struct PrimeLatinProposalValidationCompositionReceiptPublicationAuthorityBoundaryV1:" \
        "public struct PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1:" \
        "$validation_composition_receipt_publisher_source"
)"
readonly validation_composition_receipt_publication_observation="$(
    source_section_between \
        "public struct PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1:" \
        "public enum PrimeLatinProposalValidationCompositionReceiptPublisherV1" \
        "$validation_composition_receipt_publisher_source"
)"
for forbidden_receipt_publication_wire_surface in \
    "Codable" \
    "Encodable" \
    "Decodable" \
    "public init"; do
    if grep -Fq -- "$forbidden_receipt_publication_wire_surface" \
        <<< "$validation_composition_receipt_publication_authority"; then
        die "Latin receipt-publication authority exposes a forbidden wire surface: $forbidden_receipt_publication_wire_surface"
    fi
    if grep -Fq -- "$forbidden_receipt_publication_wire_surface" \
        <<< "$validation_composition_receipt_publication_observation"; then
        die "Latin receipt-publication observation exposes a forbidden wire surface: $forbidden_receipt_publication_wire_surface"
    fi
done
readonly validation_composition_receipt_publication_authority_compact="$(
    tr -d '[:space:]' <<< \
        "$validation_composition_receipt_publication_authority"
)"
[[ "$(count_fixed_occurrences \
        ":Bool" \
        /dev/stdin <<< \
            "$validation_composition_receipt_publication_authority_compact")" \
        == "55" ]] ||
    die "Latin receipt-publication authority inventory is not exact"
for required_validation_composition_receipt_publication_true_field in \
    "validationCompositionCaptureAndRecaptureComplete" \
    "validationCompositionAuthorityBoundaryExact" \
    "exactReceiptProjectionComplete" \
    "canonicalReceiptEncodingComplete" \
    "canonicalReceiptRedecodeComplete" \
    "receiptContentAddressBindingVerified" \
    "privateArtifactRootModeVerified" \
    "artifactRootEmptyAtAdmission" \
    "artifactRootEmptyAtFinalPrepublicationMutationCheck" \
    "exclusiveNoReplacePublicationComplete" \
    "immutableSingleLinkReceiptArtifactVerified" \
    "receiptFileDurabilitySyncComplete" \
    "receiptDirectoryDurabilitySyncComplete" \
    "durableValidationCompositionReceiptPublished" \
    "primeDurableReceiptPublished"; do
    [[ "$validation_composition_receipt_publication_authority_compact" == \
        *"publiclet$required_validation_composition_receipt_publication_true_field:Bool"* ]] ||
        die "Latin receipt-publication authority lacks true field: $required_validation_composition_receipt_publication_true_field"
    [[ "$validation_composition_receipt_publication_authority_compact" == \
        *"$required_validation_composition_receipt_publication_true_field=true"* ]] ||
        die "Latin receipt-publication completion is not true: $required_validation_composition_receipt_publication_true_field"
done
for required_validation_composition_receipt_publication_false_field in \
    "atomicCrossProcessSnapshotEstablished" \
    "exclusiveArtifactRootOwnershipEstablished" \
    "postPublicationSourceRecaptureComplete" \
    "compilerCryptographicallyAuthenticated" \
    "externalSourceToBinaryAttestationAvailable" \
    "publisherIdentityCryptographicallyAuthenticated" \
    "receiptCryptographicallySigned" \
    "originRemoteCryptographicallyAuthenticated" \
    "ignoredWorkspaceBytesObserved" \
    "declarationSourceSemanticsIndependentlyVerified" \
    "tokenizerModelSemanticsIndependentlyValidated" \
    "tokenizerTrainingReplayComplete" \
    "evaluationExecutionComplete" \
    "selectionObservationComplete" \
    "durableInputSnapshotPublished" \
    "durableGitObservationPublished" \
    "durableProducerRevalidationObservationPublished" \
    "durableIndependentReplayObservationPublished" \
    "durableValidationCompositionObservationPublished" \
    "rawProducerRevalidationObservationPublished" \
    "rawIndependentReplayObservationPublished" \
    "currentLiveProducerWorkspaceRevalidationRestoredFromReceipt" \
    "currentIndependentPrimeReplayRestoredFromReceipt" \
    "runtimeDecoderImplementationAvailable" \
    "runtimeDependencyClosureEstablished" \
    "runtimeInitializationEstablished" \
    "primeProposalPolicyEstablished" \
    "proposalAdmissionEvaluationComplete" \
    "proposalAdmissionGranted" \
    "primeProposalPacketProduced" \
    "primeTrialAuthorizationProduced" \
    "primeDecisionReceiptProduced" \
    "candidateSelectionAuthorized" \
    "trialExecutionAuthorized" \
    "furtherTrainingAuthorized" \
    "promotionAuthorized" \
    "productUseAuthorized" \
    "publicationAuthorized" \
    "proposalPairPublicationPerformedByThisPublisher" \
    "publicNetworkPublicationPerformed"; do
    [[ "$validation_composition_receipt_publication_authority_compact" == \
        *"publiclet$required_validation_composition_receipt_publication_false_field:Bool"* ]] ||
        die "Latin receipt-publication authority lacks false field: $required_validation_composition_receipt_publication_false_field"
    [[ "$validation_composition_receipt_publication_authority_compact" == \
        *"$required_validation_composition_receipt_publication_false_field=false"* ]] ||
        die "Latin receipt-publication authority ceiling is not false: $required_validation_composition_receipt_publication_false_field"
done
[[ "$(count_fixed_occurrences \
        "public static func " \
        "$validation_composition_receipt_publisher_source")" == "1" ]] ||
    die "Latin receipt publisher has an alternate public mutation API"
[[ "$(count_fixed_occurrences \
        "public func " \
        "$validation_composition_receipt_publisher_source")" == "0" ]] ||
    die "Latin receipt publisher exposes a public instance mutation API"
[[ "$(count_fixed_occurrences \
        "publishUsingSingleEngine(" \
        "$validation_composition_receipt_publisher_source")" == "3" ]] ||
    die "Latin receipt publisher does not route both paths through one engine"
[[ "$(count_fixed_occurrences \
        "capture.recaptureAndValidateUnchanged()" \
        "$validation_composition_receipt_publisher_source")" == "1" ]] ||
    die "Latin receipt publisher capture recapture routing is not exact"
for exact_receipt_publication_call in \
    "artifactRoot.requirePrivateRootMode():2" \
    "artifactRoot.requireEmpty():2" \
    "artifactRoot.ensurePrivateDirectory(:1" \
    "artifactRoot.requireAbsent(:1" \
    "artifactRoot.publishCanonicalExclusively(:1" \
    "artifactRoot.bindExisting(:1" \
    "artifactRoot.verify(:1" \
    "artifactRoot.decodeVerified(:1" \
    "PrimeCanonicalJSON.encode(:2" \
    "PrimeSHA256.hexDigest(:1"; do
    receipt_publication_needle="${exact_receipt_publication_call%:*}"
    receipt_publication_count="${exact_receipt_publication_call##*:}"
    [[ "$(count_fixed_occurrences \
            "$receipt_publication_needle" \
            "$validation_composition_receipt_publisher_source")" == \
            "$receipt_publication_count" ]] ||
        die "Latin receipt publisher capability count is not exact: $receipt_publication_needle"
done
readonly validation_composition_receipt_publisher_test_imports="$(
    grep -E '^(@testable )?import ' \
        "$validation_composition_receipt_publisher_tests"
)"
readonly expected_validation_composition_receipt_publisher_test_imports=$'import Darwin\nimport Foundation\nimport XCTest\n@testable import PrimeCore\n@testable import PrimeLatinProposalValidationCompositionReceipt\n@testable import PrimeLatinProposalValidationCompositionReceiptPublisher'
[[ "$validation_composition_receipt_publisher_test_imports" == \
        "$expected_validation_composition_receipt_publisher_test_imports" ]] ||
    die "Latin receipt-publisher test imports are not exact"
[[ "$(count_fixed_occurrences \
        "publishForTesting(" \
        "$validation_composition_receipt_publisher_tests")" == "2" ]] ||
    die "Latin receipt-publisher tests bypass the synthetic engine seam"
[[ "$(count_fixed_occurrences \
        "FileManager.default.temporaryDirectory" \
        "$validation_composition_receipt_publisher_tests")" == "1" ]] ||
    die "Latin receipt-publisher tests lack one temporary-root owner"
for forbidden_validation_composition_receipt_publisher_test_value in \
    "PrimeLatinProposalValidationCompositionCaptureV1" \
    ".publish(" \
    "Process(" \
    "ProcessInfo.processInfo.environment" \
    "URLSession" \
    "NWConnection" \
    "socket(" \
    "connect(" \
    '"/usr/bin/git"' \
    '"fetch"' \
    '"push"' \
    '"clone"' \
    "--disable-sandbox"; do
    if grep -Fq -- \
        "$forbidden_validation_composition_receipt_publisher_test_value" \
        "$validation_composition_receipt_publisher_tests"; then
        die "Latin receipt-publisher tests contain a live or external path: $forbidden_validation_composition_receipt_publisher_test_value"
    fi
done

[[ "$(grep -Fc -- '.package(' "$prime_root/Package.swift")" == "1" ]] ||
    die "Prime root gained an unexpected package dependency"
! grep -Fq -- '.package(' "$validation_manifest" ||
    die "isolated Latin validation package gained a package dependency"
readonly root_manifest_compact="$(tr -d '[:space:]' < "$prime_root/Package.swift")"
readonly validation_manifest_compact="$(tr -d '[:space:]' < "$validation_manifest")"
for required_root_fragment in \
    '.library(name:"PrimeLatinProposalPairCapture",targets:["PrimeLatinProposalPairCapture",])' \
    '.library(name:"PrimeLatinProposalGitObservation",targets:["PrimeLatinProposalGitObservation",])' \
    '.library(name:"PrimeLatinProposalProducerRevalidationObservation",targets:["PrimeLatinProposalProducerRevalidationObservation",])' \
    '.library(name:"PrimeLatinProposalIndependentReplay",targets:["PrimeLatinProposalIndependentReplay",])' \
    '.executable(name:"PrimeLatinProposalPairCaptureProbe",targets:["PrimeLatinProposalPairCaptureProbe",])' \
    '.executable(name:"PrimeLatinProposalGitObservationProbe",targets:["PrimeLatinProposalGitObservationProbe",])' \
    '.executable(name:"PrimeLatinProposalProducerRevalidationObservationProbe",targets:["PrimeLatinProposalProducerRevalidationObservationProbe",])' \
    '.executable(name:"PrimeLatinProposalIndependentReplayProbe",targets:["PrimeLatinProposalIndependentReplayProbe",])' \
    '.target(name:"PrimeLatinProposalPairCapture")' \
    '.target(name:"PrimeLatinProposalGitObservation",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.target(name:"PrimeLatinProposalProducerRevalidationObservation",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation",])' \
    '.target(name:"PrimeLatinProposalIndependentReplay",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation",])' \
    '.target(name:"PrimeLatinProposalValidationComposition",dependencies:["PrimeLatinProposalProducerRevalidationObservation","PrimeLatinProposalIndependentReplay",])' \
    '.target(name:"PrimeLatinProposalValidationCompositionReceipt")' \
    '.target(name:"PrimeLatinProposalValidationCompositionReceiptPublisher",dependencies:["PrimeCore","PrimeLatinProposalValidationComposition","PrimeLatinProposalValidationCompositionReceipt",])' \
    '.executableTarget(name:"PrimeLatinProposalPairCaptureProbe",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.executableTarget(name:"PrimeLatinProposalGitObservationProbe",dependencies:["PrimeLatinProposalGitObservation",])' \
    '.executableTarget(name:"PrimeLatinProposalProducerRevalidationObservationProbe",dependencies:["PrimeLatinProposalProducerRevalidationObservation",])' \
    '.executableTarget(name:"PrimeLatinProposalIndependentReplayProbe",dependencies:["PrimeLatinProposalIndependentReplay",])' \
    '.testTarget(name:"PrimeLatinProposalPairCaptureTests",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation","PrimeLatinProposalProducerRevalidationObservation","PrimeLatinProposalIndependentReplay","PrimeLatinProposalValidationComposition","PrimeLatinProposalValidationCompositionReceipt","PrimeLatinProposalValidationCompositionReceiptPublisher",])'; do
    [[ "$root_manifest_compact" == *"$required_root_fragment"* ]] ||
        die "Prime root Latin target graph is not exact"
done
for required_validation_fragment in \
    '.target(name:"PrimeCore")' \
    '.target(name:"PrimeLatinProposalPairCapture")' \
    '.target(name:"PrimeLatinProposalGitObservation",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.target(name:"PrimeLatinProposalProducerRevalidationObservation",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation",])' \
    '.target(name:"PrimeLatinProposalIndependentReplay",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation",])' \
    '.target(name:"PrimeLatinProposalValidationComposition",dependencies:["PrimeLatinProposalProducerRevalidationObservation","PrimeLatinProposalIndependentReplay",])' \
    '.target(name:"PrimeLatinProposalValidationCompositionReceipt")' \
    '.target(name:"PrimeLatinProposalValidationCompositionReceiptPublisher",dependencies:["PrimeCore","PrimeLatinProposalValidationComposition","PrimeLatinProposalValidationCompositionReceipt",])' \
    '.executableTarget(name:"PrimeLatinProposalPairCaptureProbe",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.executableTarget(name:"PrimeLatinProposalGitObservationProbe",dependencies:["PrimeLatinProposalGitObservation",])' \
    '.executableTarget(name:"PrimeLatinProposalProducerRevalidationObservationProbe",dependencies:["PrimeLatinProposalProducerRevalidationObservation",])' \
    '.executableTarget(name:"PrimeLatinProposalIndependentReplayProbe",dependencies:["PrimeLatinProposalIndependentReplay",])' \
    '.testTarget(name:"PrimeLatinProposalPairCaptureTests",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation","PrimeLatinProposalProducerRevalidationObservation","PrimeLatinProposalIndependentReplay","PrimeLatinProposalValidationComposition","PrimeLatinProposalValidationCompositionReceipt","PrimeLatinProposalValidationCompositionReceiptPublisher",])'; do
    [[ "$validation_manifest_compact" == *"$required_validation_fragment"* ]] ||
        die "isolated Latin validation target graph is not exact"
done
for forbidden_receipt_manifest_fragment in \
    '.library(name:"PrimeLatinProposalValidationCompositionReceipt"' \
    '.library(name:"PrimeLatinProposalValidationCompositionReceiptPublisher"' \
    '.executable(name:"PrimeLatinProposalValidationCompositionReceipt"' \
    '.executable(name:"PrimeLatinProposalValidationCompositionReceiptPublisher"' \
    '.executableTarget(name:"PrimeLatinProposalValidationCompositionReceipt"' \
    '.executableTarget(name:"PrimeLatinProposalValidationCompositionReceiptPublisher"' \
    '.target(name:"PrimeLatinProposalAdmissionPolicy"' \
    '.library(name:"PrimeLatinProposalAdmissionPolicy"' \
    '.executable(name:"PrimeLatinProposalAdmissionPolicy"' \
    '.executableTarget(name:"PrimeLatinProposalAdmissionPolicy"'; do
    [[ "$root_manifest_compact" != *"$forbidden_receipt_manifest_fragment"* ]] ||
        die "Prime root exposes a forbidden receipt product or executable"
    [[ "$validation_manifest_compact" != *"$forbidden_receipt_manifest_fragment"* ]] ||
        die "isolated package exposes a forbidden receipt product or executable"
done
for forbidden_validation_composition_manifest_fragment in \
    '.library(name:"PrimeLatinProposalValidationComposition"' \
    '.executable(name:"PrimeLatinProposalValidationComposition"' \
    '.executableTarget(name:"PrimeLatinProposalValidationComposition"'; do
    [[ "$root_manifest_compact" != \
        *"$forbidden_validation_composition_manifest_fragment"* ]] ||
        die "Prime root exposes a forbidden validation-composition product or executable"
    [[ "$validation_manifest_compact" != \
        *"$forbidden_validation_composition_manifest_fragment"* ]] ||
        die "isolated package exposes a forbidden validation-composition product or executable"
done

readonly embedded_provenance="$prime_root/Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"
readonly excluded_provenance="Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"
[[ -f "$embedded_provenance" && ! -L "$embedded_provenance" ]] ||
    die "embedded Prime provenance is missing or linked"
[[ "$(stat -f '%l' "$embedded_provenance")" == "1" ]] ||
    die "embedded Prime provenance is not single-link"
readonly -a fixed_source_paths=(
    ".gitignore"
    ".swiftpm/configuration/mirrors.json"
    "Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json"
    "Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration/mirrors.json"
    "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json"
    "LICENSE"
    "Package.swift"
    "Package.resolved"
    "README.md"
    "THIRD_PARTY_NOTICES.md"
)
readonly maximum_source_file_bytes=8388608
readonly maximum_snapshot_file_count=4096
readonly maximum_snapshot_directory_count=4096
readonly maximum_snapshot_aggregate_bytes=536870912
readonly maximum_snapshot_relative_depth=32
snapshot_file_count=0
snapshot_directory_count=0
snapshot_aggregate_bytes=0

admit_regular_source_file() {
    local source_file="$1"
    local relative_path="$2"
    local source_bytes
    local relative_depth
    [[ ! -L "$source_file" && -f "$source_file" ]] ||
        die "admitted source is not a regular file: $relative_path"
    [[ "$(stat -f '%l' "$source_file")" == "1" ]] ||
        die "admitted source is not single-link: $relative_path"
    source_bytes="$(stat -f '%z' "$source_file")"
    [[ "$source_bytes" =~ ^[0-9]+$ ]] ||
        die "admitted source has an invalid byte count: $relative_path"
    (( source_bytes <= maximum_source_file_bytes )) ||
        die "admitted source exceeds the per-file bound: $relative_path"
    relative_depth="$(awk -F/ '{print NF}' <<< "$relative_path")"
    (( relative_depth <= maximum_snapshot_relative_depth )) ||
        die "admitted source exceeds the relative-depth bound: $relative_path"
    snapshot_file_count=$((snapshot_file_count + 1))
    (( snapshot_file_count <= maximum_snapshot_file_count )) ||
        die "admitted source exceeds the file-count bound"
    snapshot_aggregate_bytes=$((snapshot_aggregate_bytes + source_bytes))
    (( snapshot_aggregate_bytes <= maximum_snapshot_aggregate_bytes )) ||
        die "admitted source exceeds the aggregate-byte bound"
}

for relative_path in "${fixed_source_paths[@]}"; do
    admit_regular_source_file "$prime_root/$relative_path" "$relative_path"
done
for relative_path in Sources Tests docs; do
    [[ ! -L "$prime_root/$relative_path" \
            && -d "$prime_root/$relative_path" ]] ||
        die "recursive source root is missing or linked: $relative_path"
done
readonly source_node_inventory="$(
    mktemp "$runner_temp/prime-latin-source-nodes.XXXXXX"
)"
find "$prime_root/Sources" "$prime_root/Tests" "$prime_root/docs" \
    \( -name '.*' -prune \) -o -print0 > "$source_node_inventory"
while IFS= read -r -d '' absolute_path; do
    relative_path="${absolute_path#"$prime_root/"}"
    [[ "$relative_path" != "$absolute_path" ]] ||
        die "recursive source node escaped Prime root"
    [[ "$relative_path" != *$'\n'* && "$relative_path" != *$'\r'* ]] ||
        die "recursive source path contains a line delimiter"
    relative_depth="$(awk -F/ '{print NF}' <<< "$relative_path")"
    (( relative_depth <= maximum_snapshot_relative_depth )) ||
        die "recursive source node exceeds the relative-depth bound: $relative_path"
    [[ ! -L "$absolute_path" ]] ||
        die "recursive source node is a symbolic link: $relative_path"
    if [[ -d "$absolute_path" ]]; then
        snapshot_directory_count=$((snapshot_directory_count + 1))
        (( snapshot_directory_count <= maximum_snapshot_directory_count )) ||
            die "admitted source exceeds the directory-count bound"
    elif [[ -f "$absolute_path" ]]; then
        admit_regular_source_file "$absolute_path" "$relative_path"
    else
        die "recursive source node is neither a directory nor regular file: $relative_path"
    fi
done < "$source_node_inventory"
unlink "$source_node_inventory"
(( snapshot_file_count > 0 )) ||
    die "admitted source snapshot contains no files"
(( snapshot_directory_count >= 3 )) ||
    die "admitted source snapshot is missing a recursive root"
(( snapshot_aggregate_bytes > 0 )) ||
    die "admitted source snapshot contains no bytes"
readonly observed_source_identity="$({
    for relative_path in "${fixed_source_paths[@]}"; do
        printf '%s\n' "$relative_path"
    done
    find "$prime_root/Sources" "$prime_root/Tests" "$prime_root/docs" \
        -type f ! -path '*/.*' -print |
        while IFS= read -r absolute_path; do
            printf '%s\n' "${absolute_path#"$prime_root/"}"
        done
} | LC_ALL=C sort -u | while IFS= read -r relative_path; do
    [[ "$relative_path" == "$excluded_provenance" ]] && continue
    source_file="$prime_root/$relative_path"
    [[ -f "$source_file" && ! -L "$source_file" ]] ||
        die "admitted source is missing or linked: $relative_path"
    [[ "$(stat -f '%l' "$source_file")" == "1" ]] ||
        die "admitted source is not single-link: $relative_path"
    source_sha="$(shasum -a 256 "$source_file" | awk '{print $1}')"
    source_bytes="$(stat -f '%z' "$source_file")"
    jq -cnS \
        --arg relative_path "$relative_path" \
        --arg sha256 "$source_sha" \
        --argjson byte_count "$source_bytes" \
        '{relative_path:$relative_path,sha256:$sha256,byte_count:$byte_count}'
done | jq -jcsS . | shasum -a 256 | awk '{print $1}')"
readonly embedded_source_identity_matches="$(
    grep -Eo '"[0-9a-f]{64}"' "$embedded_provenance" || true
)"
[[ "$(printf '%s\n' "$embedded_source_identity_matches" |
    awk 'NF { count += 1 } END { print count + 0 }')" == "1" ]] ||
    die "embedded Prime provenance must contain exactly one source identity"
readonly embedded_source_identity="${embedded_source_identity_matches//\"/}"
[[ "$observed_source_identity" == "$embedded_source_identity" ]] ||
    die "embedded Prime source identity is stale"
readonly expected_embedded_provenance_sha="$(
    printf '%s\n' \
        'public enum PrimeEmbeddedBuildProvenance {' \
        '    #if DEBUG' \
        '        public static let buildConfiguration = "debug"' \
        '    #else' \
        '        public static let buildConfiguration = "release"' \
        '    #endif' \
        '' \
        '    // This file is excluded only to avoid a self-referential digest. Runtime' \
        '    // verification requires this exact canonical template and digest; every' \
        '    // other admitted package, source, test, and architecture file is hashed.' \
        '    public static let sourceIdentitySHA256 =' \
        "        \"$embedded_source_identity\"" \
        '}' |
        shasum -a 256 | awk '{print $1}'
)"
[[ "$(shasum -a 256 "$embedded_provenance" | awk '{print $1}')" \
        == "$expected_embedded_provenance_sha" ]] ||
    die "embedded Prime provenance does not match the canonical source template"

readonly stage_root="$(mktemp -d "$runner_temp/prime-latin-pair-capture.XXXXXX")"
readonly scratch_path="$stage_root/.scratch"
readonly cache_path="$stage_root/.cache"
readonly config_path="$stage_root/.config"
readonly security_path="$stage_root/.security"
readonly test_log="$stage_root/prime-latin-pair-capture-tests.log"

mkdir -p \
    "$stage_root/Sources" \
    "$stage_root/Tests" \
    "$scratch_path" \
    "$cache_path" \
    "$config_path" \
    "$security_path"
cp "$validation_manifest" "$stage_root/Package.swift"
cp -R \
    "$prime_root/Sources/PrimeCore" \
    "$stage_root/Sources/PrimeCore"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalPairCapture" \
    "$stage_root/Sources/PrimeLatinProposalPairCapture"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalPairCaptureProbe" \
    "$stage_root/Sources/PrimeLatinProposalPairCaptureProbe"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalGitObservation" \
    "$stage_root/Sources/PrimeLatinProposalGitObservation"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalGitObservationProbe" \
    "$stage_root/Sources/PrimeLatinProposalGitObservationProbe"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalProducerRevalidationObservation" \
    "$stage_root/Sources/PrimeLatinProposalProducerRevalidationObservation"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalProducerRevalidationObservationProbe" \
    "$stage_root/Sources/PrimeLatinProposalProducerRevalidationObservationProbe"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalIndependentReplay" \
    "$stage_root/Sources/PrimeLatinProposalIndependentReplay"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalIndependentReplayProbe" \
    "$stage_root/Sources/PrimeLatinProposalIndependentReplayProbe"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalValidationComposition" \
    "$stage_root/Sources/PrimeLatinProposalValidationComposition"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalValidationCompositionReceipt" \
    "$stage_root/Sources/PrimeLatinProposalValidationCompositionReceipt"
cp -R \
    "$prime_root/Sources/PrimeLatinProposalValidationCompositionReceiptPublisher" \
    "$stage_root/Sources/PrimeLatinProposalValidationCompositionReceiptPublisher"
cp -R \
    "$prime_root/Tests/PrimeLatinProposalPairCaptureTests" \
    "$stage_root/Tests/PrimeLatinProposalPairCaptureTests"

xcrun swiftc -frontend -parse "$capture_source"
xcrun swiftc -frontend -parse "$capture_support"
xcrun swiftc -frontend -parse "$v3_inputs_source"
xcrun swiftc -frontend -parse "$v3_capture_source"
xcrun swiftc -frontend -parse "$v3_snapshot_source"
xcrun swiftc -frontend -parse "$probe_source"
xcrun swiftc -frontend -parse "$git_observation_source"
xcrun swiftc -frontend -parse "$git_observation_probe_source"
xcrun swiftc -frontend -parse "$producer_revalidation_source"
xcrun swiftc -frontend -parse "$producer_revalidation_probe_source"
xcrun swiftc -frontend -parse "$independent_replay_source"
xcrun swiftc -frontend -parse "$independent_replay_probe_source"
xcrun swiftc -frontend -parse "$validation_composition_source"
xcrun swiftc -frontend -parse "$validation_composition_receipt_source"
xcrun swiftc -frontend -parse "$validation_composition_receipt_publisher_source"
xcrun swiftc -frontend -parse "$capture_tests"
xcrun swiftc -frontend -parse "$v3_inputs_tests"
xcrun swiftc -frontend -parse "$v3_snapshot_tests"
xcrun swiftc -frontend -parse "$git_observation_tests"
xcrun swiftc -frontend -parse "$producer_revalidation_tests"
xcrun swiftc -frontend -parse "$independent_replay_tests"
xcrun swiftc -frontend -parse "$validation_composition_tests"
xcrun swiftc -frontend -parse "$validation_composition_receipt_tests"
xcrun swiftc -frontend -parse "$validation_composition_receipt_publisher_tests"
xcrun swiftc -frontend -parse "$source_contract_tests"

TMPDIR="$stage_root" swift test \
    --package-path "$stage_root" \
    --scratch-path "$scratch_path" \
    --cache-path "$cache_path" \
    --config-path "$config_path" \
    --security-path "$security_path" \
    --disable-dependency-cache \
    --manifest-cache local \
    --disable-netrc \
    --disable-keychain \
    --filter 'PrimeLatinProposalPairCaptureTests|PrimeLatinProposalInputsV3Tests|PrimeLatinProposalInputSnapshotV3Tests|PrimeLatinProposalGitSourceV3Tests|PrimeLatinProposalProducerRevalidationObservationTests|PrimeLatinProposalIndependentReplayV1Tests|PrimeLatinProposalValidationCompositionV1Tests|PrimeLatinProposalValidationCompositionReceiptV1Tests|PrimeLatinProposalValidationCompositionReceiptPublisherV1Tests|PrimeLatinProposalPairCaptureSourceContractTests' \
    2>&1 | tee "$test_log"
grep -Eq 'Executed [1-9][0-9]* tests?, with 0 failures' "$test_log" ||
    die "focused Latin capture and V3 test receipt is missing"
for expected_test_suite in \
    "PrimeLatinProposalPairCaptureTests" \
    "PrimeLatinProposalInputsV3Tests" \
    "PrimeLatinProposalInputSnapshotV3Tests" \
    "PrimeLatinProposalGitSourceV3Tests" \
    "PrimeLatinProposalProducerRevalidationObservationTests" \
    "PrimeLatinProposalIndependentReplayV1Tests" \
    "PrimeLatinProposalValidationCompositionV1Tests" \
    "PrimeLatinProposalValidationCompositionReceiptV1Tests" \
    "PrimeLatinProposalValidationCompositionReceiptPublisherV1Tests" \
    "PrimeLatinProposalPairCaptureSourceContractTests"; do
    grep -Fq -- "$expected_test_suite" "$test_log" ||
        die "focused Latin test suite receipt is missing: $expected_test_suite"
done

TMPDIR="$stage_root" swift build \
    --package-path "$stage_root" \
    --scratch-path "$scratch_path" \
    --cache-path "$cache_path" \
    --config-path "$config_path" \
    --security-path "$security_path" \
    --disable-dependency-cache \
    --manifest-cache local \
    --disable-netrc \
    --disable-keychain \
    --target PrimeLatinProposalPairCaptureProbe

TMPDIR="$stage_root" swift build \
    --package-path "$stage_root" \
    --scratch-path "$scratch_path" \
    --cache-path "$cache_path" \
    --config-path "$config_path" \
    --security-path "$security_path" \
    --disable-dependency-cache \
    --manifest-cache local \
    --disable-netrc \
    --disable-keychain \
    --target PrimeLatinProposalGitObservationProbe

TMPDIR="$stage_root" swift build \
    --package-path "$stage_root" \
    --scratch-path "$scratch_path" \
    --cache-path "$cache_path" \
    --config-path "$config_path" \
    --security-path "$security_path" \
    --disable-dependency-cache \
    --manifest-cache local \
    --disable-netrc \
    --disable-keychain \
    --target PrimeLatinProposalProducerRevalidationObservationProbe

TMPDIR="$stage_root" swift build \
    --package-path "$stage_root" \
    --scratch-path "$scratch_path" \
    --cache-path "$cache_path" \
    --config-path "$config_path" \
    --security-path "$security_path" \
    --disable-dependency-cache \
    --manifest-cache local \
    --disable-netrc \
    --disable-keychain \
    --target PrimeLatinProposalIndependentReplayProbe

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout changed commits during validation"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout changed during validation"

echo "OK: exact-head Latin V1/V3 pair capture, canonical V3 wire/hash-chain verification, original-input snapshot mechanics, fixed local Git observation, compiled-but-not-live-run producer revalidation, compiled-and-synthetically-tested-but-not-live-run Prime-owned independent structural replay, synthetically tested but never live-run validation composition, pure validation-composition receipt encoding, and synthetic-only durable receipt publication are dependency-isolated, bounded, and non-authorizing"
