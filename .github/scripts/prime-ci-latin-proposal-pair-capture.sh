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
readonly capture_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalPairCaptureTests.swift"
readonly v3_inputs_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalInputsV3Tests.swift"
readonly v3_snapshot_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalInputSnapshotV3Tests.swift"
readonly git_observation_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalGitSourceV3Tests.swift"
readonly producer_revalidation_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalProducerRevalidationObservationTests.swift"
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
    "$capture_tests" \
    "$v3_inputs_tests" \
    "$v3_snapshot_tests" \
    "$git_observation_tests" \
    "$producer_revalidation_tests" \
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
    "$prime_root/Tests/PrimeLatinProposalPairCaptureTests" \
    "PrimeLatinProposalGitSourceV3Tests.swift" \
    "PrimeLatinProposalPairCaptureSourceContractTests.swift" \
    "PrimeLatinProposalPairCaptureTests.swift" \
    "PrimeLatinProposalInputSnapshotV3Tests.swift" \
    "PrimeLatinProposalInputsV3Tests.swift" \
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
    '.executable(name:"PrimeLatinProposalPairCaptureProbe",targets:["PrimeLatinProposalPairCaptureProbe",])' \
    '.executable(name:"PrimeLatinProposalGitObservationProbe",targets:["PrimeLatinProposalGitObservationProbe",])' \
    '.executable(name:"PrimeLatinProposalProducerRevalidationObservationProbe",targets:["PrimeLatinProposalProducerRevalidationObservationProbe",])' \
    '.target(name:"PrimeLatinProposalPairCapture")' \
    '.target(name:"PrimeLatinProposalGitObservation",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.target(name:"PrimeLatinProposalProducerRevalidationObservation",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation",])' \
    '.executableTarget(name:"PrimeLatinProposalPairCaptureProbe",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.executableTarget(name:"PrimeLatinProposalGitObservationProbe",dependencies:["PrimeLatinProposalGitObservation",])' \
    '.executableTarget(name:"PrimeLatinProposalProducerRevalidationObservationProbe",dependencies:["PrimeLatinProposalProducerRevalidationObservation",])' \
    '.testTarget(name:"PrimeLatinProposalPairCaptureTests",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation","PrimeLatinProposalProducerRevalidationObservation",])'; do
    [[ "$root_manifest_compact" == *"$required_root_fragment"* ]] ||
        die "Prime root Latin target graph is not exact"
done
for required_validation_fragment in \
    '.target(name:"PrimeLatinProposalPairCapture")' \
    '.target(name:"PrimeLatinProposalGitObservation",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.target(name:"PrimeLatinProposalProducerRevalidationObservation",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation",])' \
    '.executableTarget(name:"PrimeLatinProposalPairCaptureProbe",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.executableTarget(name:"PrimeLatinProposalGitObservationProbe",dependencies:["PrimeLatinProposalGitObservation",])' \
    '.executableTarget(name:"PrimeLatinProposalProducerRevalidationObservationProbe",dependencies:["PrimeLatinProposalProducerRevalidationObservation",])' \
    '.testTarget(name:"PrimeLatinProposalPairCaptureTests",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation","PrimeLatinProposalProducerRevalidationObservation",])'; do
    [[ "$validation_manifest_compact" == *"$required_validation_fragment"* ]] ||
        die "isolated Latin validation target graph is not exact"
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
xcrun swiftc -frontend -parse "$capture_tests"
xcrun swiftc -frontend -parse "$v3_inputs_tests"
xcrun swiftc -frontend -parse "$v3_snapshot_tests"
xcrun swiftc -frontend -parse "$git_observation_tests"
xcrun swiftc -frontend -parse "$producer_revalidation_tests"
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
    --filter 'PrimeLatinProposalPairCaptureTests|PrimeLatinProposalInputsV3Tests|PrimeLatinProposalInputSnapshotV3Tests|PrimeLatinProposalGitSourceV3Tests|PrimeLatinProposalProducerRevalidationObservationTests|PrimeLatinProposalPairCaptureSourceContractTests' \
    2>&1 | tee "$test_log"
grep -Eq 'Executed [1-9][0-9]* tests?, with 0 failures' "$test_log" ||
    die "focused Latin capture and V3 test receipt is missing"
for expected_test_suite in \
    "PrimeLatinProposalPairCaptureTests" \
    "PrimeLatinProposalInputsV3Tests" \
    "PrimeLatinProposalInputSnapshotV3Tests" \
    "PrimeLatinProposalGitSourceV3Tests" \
    "PrimeLatinProposalProducerRevalidationObservationTests" \
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

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout changed commits during validation"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout changed during validation"

echo "OK: exact-head Latin V1/V3 pair capture, canonical V3 wire/hash-chain verification, original-input snapshot mechanics, fixed local Git observation, and the compiled-but-not-live-run producer-revalidation observer are dependency-isolated, abstaining, and non-authorizing"
