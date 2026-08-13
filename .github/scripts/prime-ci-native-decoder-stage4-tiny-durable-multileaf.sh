#!/usr/bin/env bash
# One-shot exact-main Stage-4 witness for the authorized tiny durable four-leaf
# checkpoint publication and bounded fault-injection boundary. This script
# consumes the retained same-job root/Metal/runtime/tokenizer prerequisites,
# stages their already built default.metallib into one fresh validation build,
# and directly runs the sole Stage-4 XCTest against one ephemeral private root.
# It retains and uploads no artifact and grants no retry or downstream stage.
set -euo pipefail
IFS=$'\n\t'

fail() {
    echo "prime-native-decoder-stage4-tiny-durable-multileaf: $*" >&2
    exit 2
}

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"
readonly base_revision="f15f22b580aebf924c1dfc4a5636263f962a659c"
readonly base_tree="01cd4898cb9eb77d8aa19f61d543ae01c2001b6c"
readonly repair_closure_workflow_run_id="31720005455"
readonly repair_closure_workflow_run_number="95"
readonly repair_closure_check_suite_id="86052386262"
readonly required_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly authority_canonical_sha256="0b167685f0cc10cbf5d705d6cf67b72b54555dfa52b9f4aaebd00613e057b031"
readonly repair_authority_canonical_sha256="6a6dfc7b30319f9ccc1d17c2f08282c266962cd500d47696cbb42b4b1b0ff826"
readonly authority_id="prime_native_decoder_tiny_durable_multileaf_commit_fault_injection_authority_v1"
readonly repair_authority_id="ergentics_prime_native_decoder_tiny_durable_multileaf_commit_fault_injection_package_resolved_scope_repair_authority_v1"
readonly receipt_prefix="PRIME_NATIVE_DECODER_STAGE4_TINY_DURABLE_MULTILEAF_RECEIPT="

readonly validation_root="$prime_root/Tests/PrimeNativeDecoderTrainingValidation"
readonly validation_manifest="$validation_root/Package.swift"
readonly validation_lock="$validation_root/Package.resolved"
readonly retained_stage2_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift"
readonly retained_stage3_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift"
readonly stage4_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests.swift"
readonly checkpoint_source="$prime_root/Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderTrajectoryCheckpointV1.swift"
readonly training_source="$prime_root/Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"
readonly authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthority.swift"
readonly authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityTests.swift"
readonly repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthority.swift"
readonly repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityTests.swift"
readonly stage3_launcher="$prime_root/.github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh"
readonly embedded_provenance="$prime_root/Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"

readonly mlx_bare="$runner_temp/ergentics-mlx-swift.git"
readonly mlx_source="$runner_temp/ergentics-mlx-swift"
readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"
readonly metal_build="$runner_temp/prime-native-decoder-build"
readonly active_root_log="$runner_temp/prime-active-root-tests.log"
readonly checkpoint_v2_log="$runner_temp/prime-checkpoint-v2-tests.log"
readonly checkpoint_v2_io_log="$runner_temp/prime-checkpoint-v2-io-tests.log"
readonly checkpoint_v2_io_execution_log="$runner_temp/prime-checkpoint-v2-io-execution-pure-tests.log"
readonly checkpoint_v2_io_root_repair_log="$runner_temp/prime-checkpoint-v2-io-root-identity-repair-execution-pure-tests.log"
readonly metal_log="$runner_temp/prime-native-decoder-metal-tests.log"
readonly runtime_test_log="$runner_temp/prime-native-decoder-runtime-closure-authority-tests.log"
readonly runtime_probe_log="$runner_temp/prime-native-decoder-runtime-closure-probe.log"
readonly tokenizer_test_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-authority-tests.log"
readonly tokenizer_probe_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-probe.log"

readonly scratch_path="$runner_temp/prime-native-decoder-stage4-tiny-durable-multileaf-build"
readonly cache_path="$runner_temp/prime-native-decoder-stage4-tiny-durable-multileaf-cache"
readonly config_path="$runner_temp/prime-native-decoder-stage4-tiny-durable-multileaf-config"
readonly security_path="$runner_temp/prime-native-decoder-stage4-tiny-durable-multileaf-security"
readonly private_cwd="$runner_temp/prime-native-decoder-stage4-tiny-durable-multileaf-cwd"
readonly artifact_root="$runner_temp/prime-native-decoder-stage4-tiny-durable-multileaf-artifacts"
readonly test_log="$runner_temp/prime-native-decoder-stage4-tiny-durable-multileaf-tests.log"
readonly test_class="PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests"
readonly test_method="testTinyDurableMultileafCommitIsExactAndFailClosed"
readonly test_filter="${test_class}/${test_method}"

for command_name in awk bash chmod cmp cp cut dirname env find git grep id jq \
    mkdir otool pwd shasum sort stat swift tee uname wc xcrun; do
    command -v "$command_name" >/dev/null 2>&1 ||
        fail "missing command: $command_name"
done

readonly xctest_failure_or_skip_regex="^Test Case '[^']+' failed \\(|^Test Suite '[^']+' failed at |^error:|^Test Case '[^']+' skipped \\(| : Test skipped - "

xctest_log_has_failure_or_skip() {
    grep -Eq "$xctest_failure_or_skip_regex" "$1"
}

[[ "${GITHUB_ACTIONS:-}" == "true" \
    && "${RUNNER_ENVIRONMENT:-}" == "github-hosted" \
    && "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" \
    && "${GITHUB_WORKFLOW:-}" == "Prime active-root quarantine" \
    && "${GITHUB_JOB:-}" == "trusted-main-compile" \
    && "${GITHUB_EVENT_NAME:-}" == "push" \
    && "${GITHUB_REF:-}" == "refs/heads/main" \
    && "${GITHUB_RUN_ATTEMPT:-}" == "1" \
    && "${RUNNER_OS:-}" == "macOS" \
    && "${RUNNER_ARCH:-}" == "ARM64" ]] ||
    fail "execution is not the first hosted exact-main attempt"
[[ "${GITHUB_SHA:-}" == "$exact_revision" \
    && "${GITHUB_WORKFLOW_SHA:-}" == "$exact_revision" ]] ||
    fail "GitHub revision binding changed"
[[ "$exact_revision" =~ ^[0-9a-f]{40}$ \
    && "$mlx_revision" == "$required_mlx_revision" ]] ||
    fail "revision pin changed"
[[ "$base_revision" =~ ^[0-9a-f]{40}$ \
    && "$base_tree" =~ ^[0-9a-f]{40}$ \
    && "$repair_closure_workflow_run_id" =~ ^[1-9][0-9]*$ \
    && "$repair_closure_workflow_run_number" =~ ^[1-9][0-9]*$ \
    && "$repair_closure_check_suite_id" =~ ^[1-9][0-9]*$ ]] ||
    fail "Stage-4 Package.resolved scope-repair exact-main closure is not pinned"
[[ -d "$runner_temp" && ! -L "$runner_temp" \
    && "$(cd "$runner_temp" && pwd -P)" == "$runner_temp" ]] ||
    fail "RUNNER_TEMP is not an exact physical directory"
[[ -f "${GITHUB_EVENT_PATH:-}" && ! -L "${GITHUB_EVENT_PATH:-}" ]] ||
    fail "push event payload is missing or linked"
jq -e --arg revision "$exact_revision" --arg base "$base_revision" \
    '.ref == "refs/heads/main"
     and .before == $base
     and .after == $revision
     and .head_commit.id == $revision
     and .repository.full_name == "Ergentics/ergentics-prime"
     and .deleted == false
     and .forced == false' "$GITHUB_EVENT_PATH" >/dev/null ||
    fail "push event is not the exact direct main successor"
[[ -z "${ERGENTICS_MLX_READ_TOKEN:-}" ]] ||
    fail "dependency credential reached Stage-4"

while IFS='=' read -r inherited_key _; do
    case "$inherited_key" in
        MLX_*|DYLD_*|LLVM_PROFILE_*|GIT_CONFIG_COUNT|GIT_CONFIG_KEY_*|GIT_CONFIG_VALUE_*)
            fail "forbidden inherited environment key: $inherited_key"
            ;;
    esac
done < <(env)
export MLX_ENABLE_TF32=0

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout is not exact and clean"
readonly parent_line="$(git -C "$prime_root" rev-list --parents -n 1 HEAD)"
IFS=' ' read -r executed_commit first_parent second_parent extra_parent \
    <<< "$parent_line"
[[ "$executed_commit" == "$exact_revision" \
    && "$first_parent" == "$base_revision" \
    && "$second_parent" =~ ^[0-9a-f]{40}$ \
    && -z "${extra_parent:-}" ]] ||
    fail "execution is not the exact two-parent direct successor"
[[ "$(git -C "$prime_root" rev-parse "${first_parent}^{tree}")" == "$base_tree" ]] ||
    fail "authority base tree changed"
readonly exact_tree="$(git -C "$prime_root" rev-parse 'HEAD^{tree}')"
[[ "$(git -C "$prime_root" rev-parse "${second_parent}^{tree}")" == "$exact_tree" ]] ||
    fail "merge tree differs from reviewed head tree"

readonly expected_changed_status=$'A\t.github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh\nA\tSources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderTrajectoryCheckpointV1.swift\nA\tTests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests.swift\nM\t.github/scripts/prime-ci-active-root-quarantine.sh\nM\t.github/workflows/prime-active-root-quarantine.yml\nM\tPackage.swift\nM\tSources/PrimeCore/PrimeEmbeddedBuildProvenance.swift\nM\tSources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift'
readonly observed_changed_status="$(git -C "$prime_root" diff-tree \
    --no-commit-id --name-status --no-renames -r \
    "$first_parent" "$exact_revision" | LC_ALL=C sort)"
[[ "$observed_changed_status" == "$expected_changed_status" ]] ||
    fail "Stage-4 direct-successor scope is not the exact eight paths"
readonly changed_paths_json="$(printf '%s\n' "$observed_changed_status" |
    awk -F '\t' '{print $2}' | LC_ALL=C sort |
    jq -Rsc 'split("\n")[:-1]')"

[[ -f "$embedded_provenance" && ! -L "$embedded_provenance" \
    && "$(stat -f %l "$embedded_provenance")" == "1" ]] ||
    fail "embedded Prime provenance source is missing or aliased"
readonly embedded_source_identity_declaration_count="$(
    grep -Ec '^[[:space:]]*public static let sourceIdentitySHA256 =$' \
        "$embedded_provenance" || true
)"
readonly embedded_source_identity_value_line="$(
    awk '
        /^[[:space:]]*public static let sourceIdentitySHA256 =$/ {
            capture_next = 1
            next
        }
        capture_next == 1 {
            print
            capture_next = 0
        }
    ' "$embedded_provenance"
)"
[[ "$embedded_source_identity_declaration_count" == "1" \
    && "$embedded_source_identity_value_line" =~ ^[[:space:]]*\"[0-9a-f]{64}\"[[:space:]]*$ ]] ||
    fail "embedded Prime provenance source identity format changed"
readonly embedded_source_identity="$(
    printf '%s\n' "$embedded_source_identity_value_line" |
        grep -Eo '[0-9a-f]{64}'
)"
[[ "$embedded_source_identity" =~ ^[0-9a-f]{64}$ ]] ||
    fail "embedded Prime source identity is invalid"

assert_pinned_file() {
    local relative_path="$1" expected_mode="$2" expected_blob="$3"
    local expected_bytes="$4" expected_sha256="$5"
    local absolute_path="$prime_root/$relative_path"
    [[ -f "$absolute_path" && ! -L "$absolute_path" \
        && "$(stat -f %l "$absolute_path")" == "1" ]] ||
        fail "pinned path is missing or aliased: $relative_path"
    [[ "$(git -C "$prime_root" ls-files -s -- "$relative_path" | awk '{print $1}')" \
        == "$expected_mode" ]] || fail "mode changed: $relative_path"
    [[ "$(git -C "$prime_root" hash-object -- "$relative_path")" == "$expected_blob" ]] ||
        fail "blob changed: $relative_path"
    [[ "$(stat -f %z "$absolute_path")" == "$expected_bytes" ]] ||
        fail "byte count changed: $relative_path"
    [[ "$(shasum -a 256 "$absolute_path" | awk '{print $1}')" == "$expected_sha256" ]] ||
        fail "SHA-256 changed: $relative_path"
}

assert_pinned_file 'Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthority.swift' \
    '100644' 'c9a1a23e65454fd7fd8f46e118c04060d0a78123' '36866' \
    '6b38af1926584bc47d20971299214e737bbda931395b08cef6bb5bf64b439ba8'
assert_pinned_file 'Tests/PrimeCoreTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityTests.swift' \
    '100644' 'c9eeea7514f28350ed95ab42e77de6cb865a6347' '15413' \
    '1a768e399edc92eacfbf32142fc9bf4faa897805697dc1b53c4f4441bbaf4406'
grep -Fq "$authority_canonical_sha256" "$authority_source" ||
    fail "Stage-4 authority canonical digest changed"
assert_pinned_file 'Sources/PrimeCore/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthority.swift' \
    '100644' '3e2c1065d15f2a3dc40a9aebe716d8a07e9d8d9e' '20899' \
    'a3ceff4fba525ec8bc625ce416feed78050f52da354bbcd3068e74552a8efe60'
assert_pinned_file 'Tests/PrimeCoreTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityTests.swift' \
    '100644' 'b06c46b77ed4b02b4953334fad2ddd2ec8d4f27d' '14773' \
    'aaf5d4e29842fd3b2695ca45aaf587d771eb1cefe9c4cc106f9974d3d3d837f3'
grep -Fq "$repair_authority_canonical_sha256" "$repair_authority_source" ||
    fail "Stage-4 Package.resolved scope-repair canonical digest changed"
assert_pinned_file '.github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh' \
    '100755' 'f912e776309866eaec5c6a162892c096b9bc2488' '26319' \
    '1a184b52e0055128afbb6a9ccc22c46e8a929f30b3e0f43752f6a43e48eae6bd'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Package.swift' \
    '100644' '9f05e5a17426f00adf9dad7b55d84057122e98f9' '1054' \
    '0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Package.resolved' \
    '100644' '8bf05edf1ea8789e7683e72fe756d79aaaa61320' '645' \
    'a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift' \
    '100644' '61e86200c508526ae2ab66e359d771841f7208db' '30214' \
    '29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift' \
    '100644' 'a986a63c9d674b03dc879a6c8131577999311a88' '15726' \
    '39051b266433bb510887750bafbc773646181f75cf85b2339ddd9fccb817cf6a'

assert_pinned_file 'Package.swift' \
    '100644' '8e14c10aded588b3902a042341bca7acc842bcc6' '32843' \
    'fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81'
assert_pinned_file 'Package.resolved' \
    '100644' '14d804bb4291720477240c27e24de6fbdc876b3b' '645' \
    'bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375'
assert_pinned_file 'Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderTrajectoryCheckpointV1.swift' \
    '100644' '3090f97ce75213d70bb1af18f915e168b6796f01' '24916' \
    '36c696977ec37a5d6edc35f1ae1fa05015c15498021fb099f403efb75977b399'
assert_pinned_file 'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift' \
    '100644' '2d12065e6b5ada265f2dbec2805fbb8bee8b7122' '74267' \
    'fb3e804332b84371ed7aa4fa34bf264b35bf60d92b6426cc582f386d5f4b6416'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests.swift' \
    '100644' '72727fe7582d10b467d72b37d8027c6f68e145aa' '18869' \
    '8746a70169b38bfea6f5a8ab75b08c23a59a4567e1501eb6009e8174db31116c'

[[ "$(find "$validation_root" -type f ! -path '*/.*' -print | LC_ALL=C sort)" \
    == "$validation_lock"$'\n'"$validation_manifest"$'\n'"$retained_stage3_test"$'\n'"$stage4_test"$'\n'"$retained_stage2_test" ]] ||
    fail "validation package inventory changed"

assert_regular_file() {
    [[ -f "$1" && ! -L "$1" && "$(stat -f %l "$1")" == "1" ]] ||
        fail "required artifact is missing or aliased: $1"
}

[[ -d "$mlx_bare" && ! -L "$mlx_bare" \
    && "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" == "$mlx_revision" ]] ||
    fail "MLX bare repository changed"
[[ -d "$mlx_source" && ! -L "$mlx_source" \
    && "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" \
    && -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX source worktree changed"

readonly predecessor_test_logs=(
    "$active_root_log" "$checkpoint_v2_log" "$checkpoint_v2_io_log"
    "$checkpoint_v2_io_execution_log" "$checkpoint_v2_io_root_repair_log"
    "$metal_log" "$runtime_test_log" "$tokenizer_test_log"
)
readonly predecessor_receipt_logs=("$runtime_probe_log" "$tokenizer_probe_log")
for predecessor_log in "${predecessor_test_logs[@]}" "${predecessor_receipt_logs[@]}"; do
    assert_regular_file "$predecessor_log"
done
grep -Fq 'Executed 50 tests, with 0 failures' "$active_root_log" ||
    fail "root-50 contracts did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_log" ||
    fail "checkpoint compatibility predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_io_log" ||
    fail "checkpoint I/O predecessor did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' "$checkpoint_v2_io_execution_log" ||
    fail "checkpoint I/O execution predecessor did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' "$checkpoint_v2_io_root_repair_log" ||
    fail "checkpoint root-repair predecessor did not complete"
grep -Fq 'Executed 44 tests, with 0 failures' "$metal_log" ||
    fail "Metal 44 did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$runtime_test_log" ||
    fail "runtime predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$tokenizer_test_log" ||
    fail "tokenizer predecessor did not complete"
for predecessor_test_log in "${predecessor_test_logs[@]}"; do
    ! xctest_log_has_failure_or_skip "$predecessor_test_log" ||
        fail "predecessor test log failed or skipped: $predecessor_test_log"
done
[[ "$(grep -Ec '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' "$runtime_probe_log")" == "1" \
    && "$(grep -Ec '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' "$tokenizer_probe_log")" == "1" ]] ||
    fail "predecessor receipt inventory changed"

[[ -d "$frozen_metallib_root" && ! -L "$frozen_metallib_root" ]] ||
    fail "fresh metallib root is missing"
metallib=""
metallib_count=0
while IFS= read -r candidate; do
    metallib="$candidate"
    metallib_count=$((metallib_count + 1))
done < <(find "$frozen_metallib_root" \
    \( -name default.metallib -o -name mlx.metallib \) -print)
[[ "$metallib_count" -eq 1 ]] || fail "fresh metallib candidate count is not one"
assert_regular_file "$metallib"
readonly metallib_byte_count="$(stat -f %z "$metallib")"
readonly metallib_sha256="$(shasum -a 256 "$metallib" | awk '{print $1}')"
[[ "$metallib_byte_count" =~ ^[1-9][0-9]*$ \
    && "$metallib_sha256" =~ ^[0-9a-f]{64}$ ]] ||
    fail "fresh metallib identity is invalid"

readonly runtime_receipt="$(grep -E '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' "$runtime_probe_log" | cut -d= -f2-)"
readonly tokenizer_receipt="$(grep -E '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' "$tokenizer_probe_log" | cut -d= -f2-)"
printf '%s' "$runtime_receipt" | jq -e \
    --arg sha "$metallib_sha256" --argjson bytes "$metallib_byte_count" \
    '.metallib.sha256 == $sha and .metallib.byte_count == $bytes
     and .runtime_loaded_metallib_identity_established == false
     and .training_execution_observed == false' >/dev/null ||
    fail "runtime receipt fresh-metallib binding changed"
printf '%s' "$tokenizer_receipt" | jq -e \
    --arg revision "$exact_revision" --arg tree "$exact_tree" \
    --arg sha "$metallib_sha256" --argjson bytes "$metallib_byte_count" \
    '.executed_revision == $revision and .executed_tree == $tree
     and .metallib_sha256 == $sha and .metallib_byte_count == $bytes
     and .loaded_metallib_identity_independently_observed == false
     and .training_execution_observed == false' >/dev/null ||
    fail "tokenizer receipt successor binding changed"

for fresh_path in "$scratch_path" "$cache_path" "$config_path" \
    "$security_path" "$private_cwd" "$artifact_root" "$test_log"; do
    [[ ! -e "$fresh_path" && ! -L "$fresh_path" ]] ||
        fail "Stage-4 path must be initially absent: $fresh_path"
done
mkdir -p "$scratch_path" "$cache_path" "$config_path" "$security_path" \
    "$private_cwd" "$artifact_root"
chmod 700 "$private_cwd" "$artifact_root"
[[ -d "$artifact_root" && ! -L "$artifact_root" \
    && "$(cd "$artifact_root" && pwd -P)" == "$artifact_root" \
    && "$(stat -f %Lp "$artifact_root")" == "700" \
    && "$(stat -f %l "$artifact_root")" == "2" \
    && -z "$(find "$artifact_root" -mindepth 1 -print)" ]] ||
    fail "Stage-4 artifact root is not initially empty"

readonly frozen_numerics_checkout="$metal_build/checkouts/swift-numerics"
[[ -d "$frozen_numerics_checkout" && ! -L "$frozen_numerics_checkout" \
    && "$(git -C "$frozen_numerics_checkout" rev-parse HEAD)" == "$numerics_revision" \
    && -z "$(git -C "$frozen_numerics_checkout" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "frozen Swift Numerics checkout changed"
export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0="url.file://${mlx_bare}/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/Ergentics/ergentics-mlx-swift"
export GIT_CONFIG_KEY_1="url.file://${frozen_numerics_checkout}/.insteadOf"
export GIT_CONFIG_VALUE_1="https://github.com/apple/swift-numerics"
export GIT_CONFIG_KEY_2="protocol.file.allow"
export GIT_CONFIG_VALUE_2="always"
TMPDIR="$runner_temp" swift build \
    --package-path "$validation_root" \
    --scratch-path "$scratch_path" \
    --cache-path "$cache_path" \
    --config-path "$config_path" \
    --security-path "$security_path" \
    --disable-dependency-cache --manifest-cache local \
    --disable-netrc --disable-keychain --force-resolved-versions \
    --configuration debug --jobs 2 --build-tests
unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1 GIT_CONFIG_KEY_2 GIT_CONFIG_VALUE_2

readonly bin_path="$scratch_path/arm64-apple-macosx/debug"
readonly test_bundle="$bin_path/PrimeNativeDecoderTrainingValidationPackageTests.xctest"
readonly test_executable="$test_bundle/Contents/MacOS/PrimeNativeDecoderTrainingValidationPackageTests"
readonly cli_metallib="$bin_path/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
readonly test_resource_metallib="$test_bundle/Contents/Resources/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
[[ -x "$test_executable" && ! -L "$test_executable" ]] ||
    fail "Stage-4 XCTest executable is missing"
for framework in CoreGraphics Metal; do
    otool -L "$test_executable" | grep -Fq "/${framework}.framework/" ||
        fail "Stage-4 XCTest executable does not link ${framework}"
done
[[ -z "$(find "$bin_path" \( -name default.metallib -o -name mlx.metallib \) -print)" ]] ||
    fail "Stage-4 build already contains a metallib candidate"
mkdir -p "$(dirname "$cli_metallib")" "$(dirname "$test_resource_metallib")"
cp -X "$metallib" "$cli_metallib"
cp -X "$metallib" "$test_resource_metallib"
chmod 444 "$cli_metallib" "$test_resource_metallib"
for staged_metallib in "$cli_metallib" "$test_resource_metallib"; do
    assert_regular_file "$staged_metallib"
    [[ "$(stat -f %Lp "$staged_metallib")" == "444" \
        && "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
        && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" == "$metallib_sha256" ]] ||
        fail "Stage-4 staged metallib identity changed"
    cmp -s "$metallib" "$staged_metallib" ||
        fail "Stage-4 staged metallib bytes changed"
done

set +e
(
    cd "$private_cwd"
    PRIME_NATIVE_DECODER_STAGE4_ARTIFACT_ROOT="$artifact_root" \
        TMPDIR="$runner_temp" xcrun xctest -XCTest "$test_filter" "$test_bundle"
) 2>&1 | tee "$test_log"
test_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${#test_pipe_status[@]}" -eq 2 \
    && "${test_pipe_status[0]}" -eq 0 \
    && "${test_pipe_status[1]}" -eq 0 ]] ||
    fail "Stage-4 direct XCTest or log capture failed"
assert_regular_file "$test_log"
[[ "$(grep -Ec '^Test Case .* started\.$' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* passed \(' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* failed \(' "$test_log")" == "0" \
    && "$(grep -Eic '^Test Case .* skipped \(' "$test_log")" == "0" ]] ||
    fail "Stage-4 test counts are not 1/1/0/0"
grep -Fq "$test_method" "$test_log" || fail "exact Stage-4 method did not execute"
grep -Eq 'Executed 1 test, with 0 failures' "$test_log" ||
    fail "Stage-4 test summary changed"
! xctest_log_has_failure_or_skip "$test_log" ||
    fail "Stage-4 test reported a failure or skip"

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && "$(git -C "$prime_root" rev-parse 'HEAD^{tree}')" == "$exact_tree" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime repository changed during Stage-4"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private Stage-4 working directory changed"
[[ -d "$artifact_root" && ! -L "$artifact_root" \
    && "$(cd "$artifact_root" && pwd -P)" == "$artifact_root" \
    && "$(stat -f %Lp "$artifact_root")" == "700" \
    && "$(stat -f %l "$artifact_root")" == "2" \
    && -z "$(find "$artifact_root" -mindepth 1 -print)" ]] ||
    fail "Stage-4 ephemeral artifact root was not reclaimed"
for prior_log in "${predecessor_test_logs[@]}" \
    "${predecessor_receipt_logs[@]}" "$test_log"; do
    ! grep -Fq "$receipt_prefix" "$prior_log" ||
        fail "Stage-4 receipt prefix existed before emission"
done

readonly receipt_json="$(jq -cnS \
    --arg authority_id "$authority_id" \
    --arg authority_canonical_sha256 "$authority_canonical_sha256" \
    --arg repair_authority_id "$repair_authority_id" \
    --arg repair_authority_canonical_sha256 "$repair_authority_canonical_sha256" \
    --argjson repair_closure_workflow_run_id "$repair_closure_workflow_run_id" \
    --argjson repair_closure_workflow_run_number "$repair_closure_workflow_run_number" \
    --argjson repair_closure_check_suite_id "$repair_closure_check_suite_id" \
    --arg embedded_source_identity "$embedded_source_identity" \
    --arg revision "$exact_revision" --arg tree "$exact_tree" \
    --arg first_parent "$first_parent" --arg second_parent "$second_parent" \
    --argjson changed_paths "$changed_paths_json" \
    --arg metallib_sha256 "$metallib_sha256" \
    --argjson metallib_byte_count "$metallib_byte_count" \
    --arg test_class "$test_class" --arg test_method "$test_method" \
    --arg test_filter "$test_filter" \
    '{schema_version:1,
      receipt_id:"prime_native_decoder_stage4_tiny_durable_multileaf_receipt_v1",
      authority_id:$authority_id,
      authority_canonical_sha256:$authority_canonical_sha256,
      repair_authority_id:$repair_authority_id,
      repair_authority_canonical_sha256:$repair_authority_canonical_sha256,
      status:"PASS_exact_main_tiny_ephemeral_durable_four_leaf_commit_fault_injection_one_test_zero_failure_zero_skip",
      execution:{revision:$revision,tree:$tree,first_parent_revision:$first_parent,
        second_parent_revision:$second_parent,parent_count:2,changed_paths:$changed_paths,
        github_event_name:"push",github_ref:"refs/heads/main",github_run_attempt:1,
        embedded_source_identity_sha256:$embedded_source_identity},
      repair_closure:{workflow_run_id:$repair_closure_workflow_run_id,
        workflow_run_number:$repair_closure_workflow_run_number,
        check_suite_id:$repair_closure_check_suite_id,run_attempt:1,
        focused_root_test_count:50,stage4_launcher_invocation_count:0,
        stage4_receipt_count:0,artifact_count:0,rerun_count:0},
      predecessor:{focused_root_test_count:50,focused_isolated_test_count:6,
        metal_test_count:44,maintained_runtime_test_count:1,tokenizer_test_count:1,
        focused_whole_test_count:56,pre_stage4_total_test_count:102,
        live_order:["root","metal","maintained_runtime","tokenizer","stage4"]},
      metallib:{byte_count:$metallib_byte_count,sha256:$metallib_sha256,
        source_candidate_count:1,staged_copy_count:2,staged_permission_mode:"444",
        loaded_path_inferred:false,independently_observed_loaded_identity:false,
        retained_after_job:false,artifact_provenance_established:false},
      stage4_test:{test_class:$test_class,test_method:$test_method,test_filter:$test_filter,
        build_command:"swift build --build-tests",build_count:1,direct_xctest_count:1,
        started_count:1,passed_count:1,failure_count:0,skip_count:0,
        total_test_count_after_stage4:103,published_file_count:4,
        exact_publication_order:["weights_v2","optimizer_moments","control_state_manifest","commit_manifest"],
        injected_failure_count:7,final_commit_manifest_published_last:true,
        externally_supplied_exact_commit_binding_required:true,
        every_partial_precommit_inventory_quarantined:true,
        exact_stage3_snapshot_round_trip_established:true},
      artifact:{ephemeral_private_root:true,initially_empty:true,reclaimed_after_test:true,
        retained_artifact_established:false,artifact_upload_invoked:false},
      ceiling:{additional_execution_or_rerun_authorized:false,
        retained_artifact_authorized:false,artifact_upload_authorized:false,
        checkpoint_admission_granted:false,public_v2_codec_widening_authorized:false,
        metal_determinism_established:false,stage5_authorized:false,
        native300m_allocation_authorized:false,native300m_training_authorized:false,
        general_training_resume_established:false,model_quality_established:false,
        candidate_admission_granted:false,trial_authorized:false,
        canary_authorized:false,product_use_authorized:false,
        publication_authorized:false}}')"
[[ "$(printf '%s' "$receipt_json" | jq -cS .)" == "$receipt_json" ]] ||
    fail "Stage-4 receipt is not canonical JSON"
printf '%s%s\n' "$receipt_prefix" "$receipt_json"
echo "OK: exact-main Stage-4 tiny durable four-leaf commit/fault-injection mechanics passed once; no artifact retained and Stage 5 remains unauthorized"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo 'The one-shot Stage-4 tiny mechanics witness serialized the exact Stage-3 post-step-1 snapshot into immutable weights, optimizer-moment, and canonical control leaves; it published one canonical commit leaf last and loaded only through an externally supplied exact four-leaf binding.'
        echo 'Seven separate precommit fault cuts produced no named commit or authoritative load, and every partial leaf inventory was quarantined. The successful four-leaf round trip restored the exact Stage-3 snapshot.'
        echo 'The tiny weights fixture is not Native-300M V2. The ephemeral artifact root was reclaimed; no artifact was retained or uploaded, and no retry, Stage 5, Metal-determinism, Native-300M, admission, training, trial, canary, product, or publication authority is granted.'
    } >> "$GITHUB_STEP_SUMMARY"
fi
