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
readonly capture_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalPairCaptureTests.swift"
readonly v3_inputs_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalInputsV3Tests.swift"
readonly v3_snapshot_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalInputSnapshotV3Tests.swift"
readonly git_observation_tests="$prime_root/Tests/PrimeLatinProposalPairCaptureTests/PrimeLatinProposalGitSourceV3Tests.swift"
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
    "$capture_tests" \
    "$v3_inputs_tests" \
    "$v3_snapshot_tests" \
    "$git_observation_tests" \
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
    "$prime_root/Tests/PrimeLatinProposalPairCaptureTests" \
    "PrimeLatinProposalGitSourceV3Tests.swift" \
    "PrimeLatinProposalPairCaptureSourceContractTests.swift" \
    "PrimeLatinProposalPairCaptureTests.swift" \
    "PrimeLatinProposalInputSnapshotV3Tests.swift" \
    "PrimeLatinProposalInputsV3Tests.swift"

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

[[ "$(grep -Fc -- '.package(' "$prime_root/Package.swift")" == "1" ]] ||
    die "Prime root gained an unexpected package dependency"
! grep -Fq -- '.package(' "$validation_manifest" ||
    die "isolated Latin validation package gained a package dependency"
readonly root_manifest_compact="$(tr -d '[:space:]' < "$prime_root/Package.swift")"
readonly validation_manifest_compact="$(tr -d '[:space:]' < "$validation_manifest")"
for required_root_fragment in \
    '.library(name:"PrimeLatinProposalPairCapture",targets:["PrimeLatinProposalPairCapture",])' \
    '.library(name:"PrimeLatinProposalGitObservation",targets:["PrimeLatinProposalGitObservation",])' \
    '.executable(name:"PrimeLatinProposalPairCaptureProbe",targets:["PrimeLatinProposalPairCaptureProbe",])' \
    '.executable(name:"PrimeLatinProposalGitObservationProbe",targets:["PrimeLatinProposalGitObservationProbe",])' \
    '.target(name:"PrimeLatinProposalPairCapture")' \
    '.target(name:"PrimeLatinProposalGitObservation",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.executableTarget(name:"PrimeLatinProposalPairCaptureProbe",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.executableTarget(name:"PrimeLatinProposalGitObservationProbe",dependencies:["PrimeLatinProposalGitObservation",])' \
    '.testTarget(name:"PrimeLatinProposalPairCaptureTests",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation",])'; do
    [[ "$root_manifest_compact" == *"$required_root_fragment"* ]] ||
        die "Prime root Latin target graph is not exact"
done
for required_validation_fragment in \
    '.target(name:"PrimeLatinProposalPairCapture")' \
    '.target(name:"PrimeLatinProposalGitObservation",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.executableTarget(name:"PrimeLatinProposalPairCaptureProbe",dependencies:["PrimeLatinProposalPairCapture",])' \
    '.executableTarget(name:"PrimeLatinProposalGitObservationProbe",dependencies:["PrimeLatinProposalGitObservation",])' \
    '.testTarget(name:"PrimeLatinProposalPairCaptureTests",dependencies:["PrimeLatinProposalPairCapture","PrimeLatinProposalGitObservation",])'; do
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
xcrun swiftc -frontend -parse "$capture_tests"
xcrun swiftc -frontend -parse "$v3_inputs_tests"
xcrun swiftc -frontend -parse "$v3_snapshot_tests"
xcrun swiftc -frontend -parse "$git_observation_tests"
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
    --filter 'PrimeLatinProposalPairCaptureTests|PrimeLatinProposalInputsV3Tests|PrimeLatinProposalInputSnapshotV3Tests|PrimeLatinProposalGitSourceV3Tests|PrimeLatinProposalPairCaptureSourceContractTests' \
    2>&1 | tee "$test_log"
grep -Eq 'Executed [1-9][0-9]* tests?, with 0 failures' "$test_log" ||
    die "focused Latin capture and V3 test receipt is missing"
for expected_test_suite in \
    "PrimeLatinProposalPairCaptureTests" \
    "PrimeLatinProposalInputsV3Tests" \
    "PrimeLatinProposalInputSnapshotV3Tests" \
    "PrimeLatinProposalGitSourceV3Tests" \
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

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$expected_prime_head" ]] ||
    die "Prime checkout changed commits during validation"
[[ -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    die "Prime checkout changed during validation"

echo "OK: exact-head Latin V1/V3 pair capture, canonical V3 wire/hash-chain verification, original-input snapshot mechanics, and fixed local Git observation with tracked-index visibility are dependency-isolated, read-only, abstaining, and non-authorizing"
