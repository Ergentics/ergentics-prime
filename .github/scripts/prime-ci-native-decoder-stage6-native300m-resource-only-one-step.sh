#!/usr/bin/env bash
# One-shot exact-main Stage-6 Native-300M resource-only one-step probe.
# The Release executable owns a bounded supervisor/worker topology. The worker
# owns the nonblocking PrimeMetalDeviceLease; its receipt/progress transport
# uses only the supervisor-owned anonymous pipe. The supervisor alone emits one canonical
# PASS or ABSTAIN receipt. This launcher validates but never re-emits it.
# No retry, rerun, checkpoint, retained artifact, quality evaluation, Stage 7,
# product, publication, or broader training authority is granted.
set -euo pipefail
IFS=$'\n\t'
umask 077

fail() {
    echo "prime-ci-native-decoder-stage6-native300m-resource-only-one-step: $*" >&2
    exit 2
}

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"

readonly required_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly authority_id="prime_native_decoder_native300m_resource_only_one_step_probe_authority_v1"
readonly authority_canonical_sha256="2627ffc0dd6499a9a1b20fa217b7f1c4a9723a6fd6332ef24a9ee251b5b0bf56"
readonly receipt_id="ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_receipt_v1"
readonly receipt_prefix="PRIME_NATIVE_DECODER_STAGE6_NATIVE300M_RESOURCE_ONLY_ONE_STEP_RECEIPT="
# Frozen receipt schema cardinalities: top-level 11, authority 6, ceiling 25,
# configuration 45, environment 26, execution 52, lease 8, limits 29,
# outcome 19, operation counts 19, six phase rows with 14 keys each.

# Terminal green pure-authority closure: signed main merge / PR 106 / run 109.
readonly authority_closure_revision="7dd21f2b8c79ebe53f62eab1945ac41b104c2b27"
readonly authority_closure_tree="5124b8a75ca753d1e7659a2535242aa909329c44"
readonly authority_closure_first_parent="f5a9638194c53922f09c39c3c76095b5cc47c25e"
readonly authority_closure_second_parent="a2014dee81123f99600b0ac4ff41e4295131195d"
readonly authority_closure_reviewed_head="a2014dee81123f99600b0ac4ff41e4295131195d"
readonly authority_closure_pull_request_number="106"
readonly authority_closure_run_id="31773463958"
readonly authority_closure_run_number="109"
readonly authority_closure_run_attempt="1"
readonly authority_closure_check_suite_id="86198647430"
readonly authority_closure_active_job_id="94683934560"
readonly authority_closure_active_job_image="macos-15"
readonly authority_closure_active_job_conclusion="success"
readonly authority_closure_reviewed_job_id="94684324255"
readonly authority_closure_reviewed_job_image="macos-26"
readonly authority_closure_reviewed_job_conclusion="success"
readonly authority_closure_event="push"
readonly authority_closure_ref="refs/heads/main"
readonly authority_closure_status="completed"
readonly authority_closure_conclusion="success"
readonly authority_closure_artifact_count="0"
readonly authority_closure_rerun_count="0"

readonly authority_source_relative_path="Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthority.swift"
readonly authority_test_relative_path="Tests/PrimeCoreTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityTests.swift"
readonly training_probe_relative_path="Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift"
readonly validation_manifest_relative_path="Tests/PrimeNativeDecoderTrainingValidation/Package.swift"
readonly executable_main_relative_path="Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe/main.swift"
readonly contract_test_relative_path="Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests.swift"
readonly launcher_relative_path=".github/scripts/prime-ci-native-decoder-stage6-native300m-resource-only-one-step.sh"
readonly gate_relative_path=".github/scripts/prime-ci-active-root-quarantine.sh"
readonly workflow_relative_path=".github/workflows/prime-active-root-quarantine.yml"
readonly provenance_relative_path="Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"
readonly model_source_relative_path="Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift"
readonly lease_source_relative_path="Sources/PrimeCore/PrimeMetalDeviceLease.swift"
readonly existing_training_source_relative_path="Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"

readonly expected_preserved_index_sha256="643a78cbfc47dcb9bea1fa1a7193736d702918561acff440898d682bc378d7dc"
readonly expected_embedded_source_identity_sha256="087b9008d051d8f1ec7ab5d762ae11180ffca94ee31e461a9c81f254b163f678"

readonly validation_root="$prime_root/Tests/PrimeNativeDecoderTrainingValidation"
readonly validation_lock="$validation_root/Package.resolved"
readonly mlx_bare="$runner_temp/ergentics-mlx-swift.git"
readonly mlx_source="$runner_temp/ergentics-mlx-swift"
readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"
readonly root_numerics_checkout="$runner_temp/prime-active-root-build/checkouts/swift-numerics"
readonly root_numerics_cache="$runner_temp/prime-active-root-build/repositories/swift-numerics-d936ec6c"

readonly active_root_log="$runner_temp/prime-active-root-tests.log"
readonly checkpoint_v2_log="$runner_temp/prime-checkpoint-v2-tests.log"
readonly checkpoint_v2_io_log="$runner_temp/prime-checkpoint-v2-io-tests.log"
readonly checkpoint_v2_io_execution_log="$runner_temp/prime-checkpoint-v2-io-execution-pure-tests.log"
readonly checkpoint_v2_io_root_repair_log="$runner_temp/prime-checkpoint-v2-io-root-identity-repair-execution-pure-tests.log"
readonly focused_contract_log="$runner_temp/prime-native-decoder-stage6-resource-probe-contract-tests.log"
readonly metal_log="$runner_temp/prime-native-decoder-metal-tests.log"
readonly runtime_test_log="$runner_temp/prime-native-decoder-runtime-closure-authority-tests.log"
readonly runtime_probe_log="$runner_temp/prime-native-decoder-runtime-closure-probe.log"
readonly tokenizer_test_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-authority-tests.log"
readonly tokenizer_probe_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-probe.log"

readonly scratch_path="$runner_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-build"
readonly cache_path="$runner_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-cache"
readonly config_path="$runner_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-config"
readonly security_path="$runner_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-security"
readonly private_cwd="$runner_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-cwd"
readonly lease_root="$runner_temp/prime-native-decoder-stage6-metal-lease"
readonly lease_path="$lease_root/device-0.lock"
readonly direct_contract_log="$runner_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-contract-tests.log"
readonly supervisor_log="$runner_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-supervisor.log"
readonly contract_class="PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests"
readonly contract_method="testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure"
readonly contract_filter="${contract_class}/${contract_method}"

for command_name in awk bash chmod cmp cp dirname env find git grep id jq \
    mkdir otool pwd rm rmdir shasum sort stat swift sw_vers tee tr uname wc \
    xcodebuild xcrun; do
    command -v "$command_name" >/dev/null 2>&1 ||
        fail "missing command: $command_name"
done

assert_regular_file() {
    [[ -f "$1" && ! -L "$1" && "$(stat -f %l "$1")" == "1" ]] ||
        fail "required file is missing, linked, or multiply linked: $1"
}

xctest_log_has_failure_or_skip() {
    grep -Eq "^Test Case '[^']+' failed \\(|^Test Suite '[^']+' failed at |^error:|^Test Case '[^']+' skipped \\(| : Test skipped - " "$1"
}

source_identity_json() {
    local repository_root="$1" relative_path="$2"
    local index_record mode blob bytes sha
    index_record="$(git -C "$repository_root" ls-files -s -- "$relative_path")"
    [[ "$(printf '%s\n' "$index_record" | wc -l | tr -d '[:space:]')" == "1" ]] ||
        fail "source identity index record is not singular: $relative_path"
    mode="$(printf '%s\n' "$index_record" | awk '{print $1}')"
    blob="$(printf '%s\n' "$index_record" | awk '{print $2}')"
    assert_regular_file "$repository_root/$relative_path"
    bytes="$(stat -f %z "$repository_root/$relative_path")"
    sha="$(shasum -a 256 "$repository_root/$relative_path" | awk '{print $1}')"
    [[ "$mode" =~ ^100(644|755)$ && "$blob" =~ ^[0-9a-f]{40}$ \
        && "$bytes" =~ ^[1-9][0-9]*$ && "$sha" =~ ^[0-9a-f]{64}$ ]] ||
        fail "source identity is invalid: $relative_path"
    jq -cnS --arg path "$relative_path" --arg mode "$mode" \
        --arg git_blob "$blob" --argjson byte_count "$bytes" \
        --arg sha256 "$sha" \
        '{byte_count:$byte_count,git_blob:$git_blob,mode:$mode,path:$path,sha256:$sha256}'
}

assert_pinned_file() {
    local relative_path="$1" expected_mode="$2" expected_blob="$3"
    local expected_bytes="$4" expected_sha="$5"
    local observed
    observed="$(source_identity_json "$prime_root" "$relative_path")"
    printf '%s' "$observed" | jq -e \
        --arg path "$relative_path" --arg mode "$expected_mode" \
        --arg blob "$expected_blob" --argjson bytes "$expected_bytes" \
        --arg sha "$expected_sha" \
        '. == {byte_count:$bytes,git_blob:$blob,mode:$mode,path:$path,sha256:$sha}' \
        >/dev/null || fail "pinned file identity changed: $relative_path"
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
    && "${GITHUB_WORKFLOW_SHA:-}" == "$exact_revision" \
    && "${GITHUB_RUN_ID:-}" =~ ^[1-9][0-9]*$ \
    && "${GITHUB_RUN_NUMBER:-}" =~ ^[1-9][0-9]*$ \
    && "$exact_revision" =~ ^[0-9a-f]{40}$ \
    && "$mlx_revision" == "$required_mlx_revision" ]] ||
    fail "mechanics workflow identity changed"
[[ "$authority_closure_revision" =~ ^[0-9a-f]{40}$ \
    && "$authority_closure_tree" =~ ^[0-9a-f]{40}$ \
    && "$authority_closure_first_parent" \
        == "f5a9638194c53922f09c39c3c76095b5cc47c25e" \
    && "$authority_closure_second_parent" == "$authority_closure_reviewed_head" \
    && "$authority_closure_pull_request_number" == "106" \
    && "$authority_closure_run_number" == "109" \
    && "$authority_closure_run_attempt" == "1" \
    && "$authority_closure_active_job_image" == "macos-15" \
    && "$authority_closure_reviewed_job_image" == "macos-26" \
    && "$authority_closure_active_job_conclusion" == "success" \
    && "$authority_closure_reviewed_job_conclusion" == "success" \
    && "$authority_closure_artifact_count" == "0" \
    && "$authority_closure_rerun_count" == "0" ]] ||
    fail "terminal run-109 authority closure pins changed"
[[ -d "$runner_temp" && ! -L "$runner_temp" \
    && "$(cd "$runner_temp" && pwd -P)" == "$runner_temp" ]] ||
    fail "RUNNER_TEMP is not an exact physical directory"
[[ -f "${GITHUB_EVENT_PATH:-}" && ! -L "${GITHUB_EVENT_PATH:-}" ]] ||
    fail "push event payload is missing or linked"
jq -e --arg revision "$exact_revision" --arg base "$authority_closure_revision" \
    '.ref == "refs/heads/main"
     and .before == $base
     and .after == $revision
     and .head_commit.id == $revision
     and .repository.full_name == "Ergentics/ergentics-prime"
     and .deleted == false
     and .forced == false' "$GITHUB_EVENT_PATH" >/dev/null ||
    fail "push event is not the direct Stage-6 mechanics successor"
[[ -z "${ERGENTICS_MLX_READ_TOKEN:-}" ]] ||
    fail "dependency credential reached Stage-6"

while IFS='=' read -r inherited_key _; do
    case "$inherited_key" in
        MLX_*|DYLD_*|LLVM_PROFILE_*|GIT_CONFIG_COUNT|GIT_CONFIG_KEY_*|GIT_CONFIG_VALUE_*|PRIME_NATIVE_DECODER_STAGE6_*)
            fail "forbidden inherited environment key: $inherited_key"
            ;;
    esac
done < <(env)
export MLX_ENABLE_TF32=0

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout is not exact and clean"
readonly exact_tree="$(git -C "$prime_root" rev-parse 'HEAD^{tree}')"
readonly raw_commit_header="$(git -C "$prime_root" cat-file -p HEAD | \
    awk 'NF == 0 { exit } { print }')"
readonly raw_tree_count="$(printf '%s\n' "$raw_commit_header" | \
    grep -Ec '^tree [0-9a-f]{40}$')"
readonly raw_parent_count="$(printf '%s\n' "$raw_commit_header" | \
    grep -Ec '^parent [0-9a-f]{40}$')"
readonly raw_tree="$(printf '%s\n' "$raw_commit_header" | \
    awk '/^tree / { print $2 }')"
readonly first_parent="$(printf '%s\n' "$raw_commit_header" | \
    awk '/^parent / { count += 1; if (count == 1) print $2 }')"
readonly second_parent="$(printf '%s\n' "$raw_commit_header" | \
    awk '/^parent / { count += 1; if (count == 2) print $2 }')"
[[ "$raw_tree_count" == "1" && "$raw_parent_count" == "2" \
    && "$raw_tree" == "$exact_tree" \
    && "$first_parent" == "$authority_closure_revision" \
    && "$second_parent" =~ ^[0-9a-f]{40}$ \
    && "$second_parent" != "$first_parent" \
    && "$second_parent" != "$exact_revision" ]] ||
    fail "raw mechanics commit is not the direct two-parent authority successor"
readonly shallow_path="$prime_root/.git/shallow"
[[ "$(git -C "$prime_root" rev-parse --is-shallow-repository)" == "true" \
    && -f "$shallow_path" && ! -L "$shallow_path" \
    && "$(stat -f %l "$shallow_path")" == "1" \
    && "$(wc -l < "$shallow_path" | awk '{print $1}')" == "1" \
    && "$(grep -Fxc -- "$exact_revision" "$shallow_path")" == "1" ]] ||
    fail "mechanics checkout is not preserved at exact depth one"

readonly exact_stage6_paths=(
    "$gate_relative_path"
    "$launcher_relative_path"
    "$workflow_relative_path"
    "$provenance_relative_path"
    "$training_probe_relative_path"
    "$validation_manifest_relative_path"
    "$executable_main_relative_path"
    "$contract_test_relative_path"
)
readonly observed_preserved_index_sha256="$({
    git -C "$prime_root" ls-files -s |
        while IFS= read -r index_record; do
            relative_path="${index_record#*$'\t'}"
            skip_record=false
            for exact_stage6_path in "${exact_stage6_paths[@]}"; do
                if [[ "$relative_path" == "$exact_stage6_path" ]]; then
                    skip_record=true
                    break
                fi
            done
            [[ "$skip_record" == true ]] || printf '%s\n' "$index_record"
        done
} | LC_ALL=C sort | shasum -a 256 | awk '{print $1}')"
[[ "$observed_preserved_index_sha256" == "$expected_preserved_index_sha256" ]] ||
    fail "Stage-6 mechanics changed a path outside the exact eight-path closure"
for exact_stage6_path in "${exact_stage6_paths[@]}"; do
    expected_mode="100644"
    case "$exact_stage6_path" in
        .github/scripts/*) expected_mode="100755" ;;
    esac
    [[ "$(git -C "$prime_root" ls-files -s -- "$exact_stage6_path" | \
        awk '{print $1}')" == "$expected_mode" ]] ||
        fail "exact Stage-6 path is missing or has wrong mode: $exact_stage6_path"
done

assert_pinned_file "$authority_source_relative_path" \
    "100644" "d65361e24a5eb3608ca774066a76ecf608c76d53" "210057" \
    "a03507b0cbd532949178fa5515d0b0d0cabfe786b0d79619d89453ea23b855c6"
assert_pinned_file "$authority_test_relative_path" \
    "100644" "a6ff11d4d8beb2aa39ca6e04ac32defb94220033" "36733" \
    "a501188363b11b61731099066d61594a0dc3d27fbe5c5c4eec3d0fbcea0de065"
assert_pinned_file "$model_source_relative_path" \
    "100644" "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f" "39598" \
    "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994"
assert_pinned_file "$lease_source_relative_path" \
    "100644" "da3daa54802b67dc2c8c04a89b388e9927dd8726" "16985" \
    "edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657"
assert_pinned_file "$existing_training_source_relative_path" \
    "100644" "271b7fe4a856a76a00730954c23bdca3b33e761d" "86387" \
    "f49b946e5272992f09ecf7b1dd8439bda15c5ac696a4f6298bafa19994f2b4c2"
assert_pinned_file "Package.swift" \
    "100644" "8e14c10aded588b3902a042341bca7acc842bcc6" "32843" \
    "fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81"
assert_pinned_file "Package.resolved" \
    "100644" "14d804bb4291720477240c27e24de6fbdc876b3b" "645" \
    "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375"
assert_pinned_file "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved" \
    "100644" "8bf05edf1ea8789e7683e72fe756d79aaaa61320" "645" \
    "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225"

readonly authority_source_identity_json="$(source_identity_json "$prime_root" "$authority_source_relative_path")"
readonly authority_test_identity_json="$(source_identity_json "$prime_root" "$authority_test_relative_path")"
readonly exact_changed_source_identities_json="$(
    for exact_stage6_path in "${exact_stage6_paths[@]}"; do
        source_identity_json "$prime_root" "$exact_stage6_path"
    done | jq -csS 'sort_by(.path)'
)"
[[ "$(printf '%s' "$exact_changed_source_identities_json" | jq 'length')" == "8" \
    && "$(printf '%s' "$exact_changed_source_identities_json" | jq -cS .)" \
        == "$exact_changed_source_identities_json" ]] ||
    fail "exact changed source identity array is invalid"

readonly embedded_source_identity="$(awk '
    /public static let sourceIdentitySHA256/ { getline; gsub(/[ "\t]/, ""); print; exit }
' "$prime_root/$provenance_relative_path")"
[[ "$expected_embedded_source_identity_sha256" =~ ^[0-9a-f]{64}$ \
    && "$embedded_source_identity" == "$expected_embedded_source_identity_sha256" ]] ||
    fail "embedded source identity is not finally pinned"

readonly predecessor_test_logs=(
    "$active_root_log" "$checkpoint_v2_log" "$checkpoint_v2_io_log"
    "$checkpoint_v2_io_execution_log" "$checkpoint_v2_io_root_repair_log"
    "$focused_contract_log" "$metal_log" "$runtime_test_log"
    "$tokenizer_test_log"
)
readonly predecessor_receipt_logs=("$runtime_probe_log" "$tokenizer_probe_log")
for predecessor_log in "${predecessor_test_logs[@]}" \
    "${predecessor_receipt_logs[@]}"; do
    assert_regular_file "$predecessor_log"
done
grep -Fq 'Executed 55 tests, with 0 failures' "$active_root_log" ||
    fail "root-55 contracts did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_log" ||
    fail "checkpoint compatibility predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_io_log" ||
    fail "checkpoint I/O predecessor did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' "$checkpoint_v2_io_execution_log" ||
    fail "checkpoint I/O execution predecessor did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' "$checkpoint_v2_io_root_repair_log" ||
    fail "checkpoint root-repair predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$focused_contract_log" ||
    fail "focused Stage-6 pure contract did not complete"
grep -Fq "$contract_class" "$focused_contract_log" ||
    fail "focused Stage-6 pure contract identity changed"
grep -Fq 'Executed 44 tests, with 0 failures' "$metal_log" ||
    fail "Metal 44 did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$runtime_test_log" ||
    fail "maintained-runtime predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$tokenizer_test_log" ||
    fail "tokenizer predecessor did not complete"
for predecessor_test_log in "${predecessor_test_logs[@]}"; do
    ! xctest_log_has_failure_or_skip "$predecessor_test_log" ||
        fail "predecessor test failed or skipped: $predecessor_test_log"
done
[[ "$(grep -Ec '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' "$runtime_probe_log")" == "1" \
    && "$(grep -Ec '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' "$tokenizer_probe_log")" == "1" ]] ||
    fail "predecessor receipt inventory changed"
for predecessor_log in "${predecessor_test_logs[@]}" \
    "${predecessor_receipt_logs[@]}"; do
    [[ "$(awk -v needle="$receipt_prefix" '
        { line = $0; while ((position = index(line, needle)) > 0) {
            count += 1; line = substr(line, position + length(needle))
        }} END { print count + 0 }
    ' "$predecessor_log")" == "0" ]] ||
        fail "Stage-6 receipt prefix existed in a predecessor log"
done

[[ -d "$mlx_bare" && ! -L "$mlx_bare" \
    && "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" \
        == "$mlx_revision" ]] ||
    fail "MLX bare repository changed"
[[ -d "$mlx_source" && ! -L "$mlx_source" \
    && "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" \
    && -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "MLX source worktree changed"
[[ -d "$root_numerics_checkout" && ! -L "$root_numerics_checkout" \
    && "$(cd "$root_numerics_checkout" && pwd -P)" == "$root_numerics_checkout" \
    && "$(git -C "$root_numerics_checkout" rev-parse HEAD)" == "$numerics_revision" \
    && "$(git -C "$root_numerics_checkout" config --get-all remote.origin.url)" \
        == "$root_numerics_cache" \
    && -z "$(git -C "$root_numerics_checkout" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "root Swift Numerics checkout changed"
[[ -d "$root_numerics_cache" && ! -L "$root_numerics_cache" \
    && "$(cd "$root_numerics_cache" && pwd -P)" == "$root_numerics_cache" \
    && "$(git -C "$root_numerics_cache" rev-parse --is-bare-repository)" == "true" \
    && "$(git -C "$root_numerics_cache" config --get-all remote.origin.url)" \
        == "https://github.com/apple/swift-numerics" \
    && "$(git -C "$root_numerics_cache" rev-parse "$numerics_revision^{commit}")" \
        == "$numerics_revision" \
    && "$(git -C "$root_numerics_cache" rev-parse 'refs/tags/1.1.1^{commit}')" \
        == "$numerics_revision" ]] ||
    fail "root Swift Numerics cache topology changed"
assert_pinned_mlx_source() {
    local relative_path="$1" expected_blob="$2" expected_bytes="$3"
    local expected_sha="$4" observed
    observed="$(source_identity_json "$mlx_source" "$relative_path")"
    printf '%s' "$observed" | jq -e --arg path "$relative_path" \
        --arg blob "$expected_blob" --argjson bytes "$expected_bytes" \
        --arg sha "$expected_sha" \
        '. == {byte_count:$bytes,git_blob:$blob,mode:"100644",path:$path,sha256:$sha}' \
        >/dev/null || fail "pinned MLX source identity changed: $relative_path"
}
assert_pinned_mlx_source "Source/MLX/Memory.swift" \
    "89baf9cc69d7e4f046467f197ce9da8a309248c3" "12919" \
    "cb6976cc37aa3e8a0fa1be8269fea2869ecdf5951e469556f67e21604b1701f8"
assert_pinned_mlx_source "Source/MLXOptimizers/Optimizers.swift" \
    "fb9c5d9636a211bb74fae7bf6a1dbbd4fe01d7b9" "24109" \
    "f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d"

readonly provenance_source_identities_json="$(
    {
        source_identity_json "$prime_root" "$authority_source_relative_path"
        source_identity_json "$prime_root" "$authority_test_relative_path"
        source_identity_json "$prime_root" "$training_probe_relative_path"
        source_identity_json "$prime_root" "$model_source_relative_path"
        source_identity_json "$prime_root" "$lease_source_relative_path"
        source_identity_json "$mlx_source" "Source/MLX/Memory.swift"
        source_identity_json "$mlx_source" "Source/MLXOptimizers/Optimizers.swift"
    } | jq -csS --arg embedded "$embedded_source_identity" \
        '{embedded_source_identity_sha256:$embedded,identities:sort_by(.path)}'
)"
[[ "$(printf '%s' "$provenance_source_identities_json" | jq -cS .)" \
    == "$provenance_source_identities_json" \
    && "$(printf '%s' "$provenance_source_identities_json" | \
        jq '.identities | length')" == "7" ]] ||
    fail "provenance source identity object is invalid"

[[ -d "$frozen_metallib_root" && ! -L "$frozen_metallib_root" ]] ||
    fail "fresh metallib root is missing"
metallib=""
metallib_count=0
while IFS= read -r candidate; do
    metallib="$candidate"
    metallib_count=$((metallib_count + 1))
done < <(find "$frozen_metallib_root" \
    \( -name default.metallib -o -name mlx.metallib \) -print)
[[ "$metallib_count" -eq 1 ]] ||
    fail "fresh metallib candidate count is not one"
assert_regular_file "$metallib"
readonly metallib_byte_count="$(stat -f %z "$metallib")"
readonly metallib_sha256="$(shasum -a 256 "$metallib" | awk '{print $1}')"
[[ "$metallib_byte_count" =~ ^[1-9][0-9]*$ \
    && "$metallib_sha256" =~ ^[0-9a-f]{64}$ ]] ||
    fail "fresh metallib identity is invalid"

for fresh_path in "$scratch_path" "$cache_path" "$config_path" \
    "$security_path" "$private_cwd" "$lease_root" "$lease_path" \
    "$direct_contract_log" "$supervisor_log"; do
    [[ ! -e "$fresh_path" && ! -L "$fresh_path" ]] ||
        fail "Stage-6 path must be initially absent: $fresh_path"
done
mkdir -p "$cache_path" "$config_path" "$security_path"

export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0="url.file://${mlx_bare}/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/Ergentics/ergentics-mlx-swift"
export GIT_CONFIG_KEY_1="url.file://${root_numerics_cache}/.insteadOf"
export GIT_CONFIG_VALUE_1="https://github.com/apple/swift-numerics"
export GIT_CONFIG_KEY_2="protocol.file.allow"
export GIT_CONFIG_VALUE_2="always"

# Exactly one Release compilation of default products plus tests.
TMPDIR="$runner_temp" swift build \
    --package-path "$validation_root" --configuration release --build-tests \
    -Xswiftc -enable-testing \
    --scratch-path "$scratch_path" --cache-path "$cache_path" \
    --config-path "$config_path" --security-path "$security_path" \
    --disable-dependency-cache --manifest-cache local \
    --disable-netrc --disable-keychain --force-resolved-versions --jobs 2

# Exactly one direct pure-contract XCTest start, reusing that Release build.
set +e
TMPDIR="$runner_temp" swift test \
    --package-path "$validation_root" --configuration release --skip-build \
    -Xswiftc -enable-testing \
    --filter "$contract_filter" \
    --scratch-path "$scratch_path" --cache-path "$cache_path" \
    --config-path "$config_path" --security-path "$security_path" \
    --disable-dependency-cache --manifest-cache local \
    --disable-netrc --disable-keychain --force-resolved-versions \
    2>&1 | tee "$direct_contract_log"
contract_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${#contract_pipe_status[@]}" -eq 2 \
    && "${contract_pipe_status[0]}" -eq 0 \
    && "${contract_pipe_status[1]}" -eq 0 ]] ||
    fail "Release pure-contract test or log capture failed"
assert_regular_file "$direct_contract_log"
[[ "$(grep -Ec '^Test Case .* started\.$' "$direct_contract_log")" == "1" \
    && "$(grep -Ec '^Test Case .* passed \(' "$direct_contract_log")" == "1" \
    && "$(grep -Ec '^Test Case .* failed \(' "$direct_contract_log")" == "0" \
    && "$(grep -Eic '^Test Case .* skipped \(' "$direct_contract_log")" == "0" \
    && "$(grep -Fc -- "$contract_class" "$direct_contract_log")" -ge 1 \
    && "$(grep -Fc -- "$contract_method" "$direct_contract_log")" -ge 1 ]] ||
    fail "Release pure-contract XCTest inventory changed"
! xctest_log_has_failure_or_skip "$direct_contract_log" ||
    fail "Release pure-contract XCTest failed or skipped"

# This query resolves the already-built executable and performs no compilation.
readonly bin_path="$(TMPDIR="$runner_temp" swift build \
    --package-path "$validation_root" --configuration release --show-bin-path \
    -Xswiftc -enable-testing \
    --scratch-path "$scratch_path" --cache-path "$cache_path" \
    --config-path "$config_path" --security-path "$security_path" \
    --disable-dependency-cache --manifest-cache local \
    --disable-netrc --disable-keychain --force-resolved-versions)"
unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
unset GIT_CONFIG_KEY_1 GIT_CONFIG_VALUE_1 GIT_CONFIG_KEY_2 GIT_CONFIG_VALUE_2

[[ -d "$bin_path" && ! -L "$bin_path" \
    && "$(cd "$bin_path" && pwd -P)" == "$bin_path" ]] ||
    fail "Release bin path is not a physical directory"
readonly executable="$bin_path/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe"
readonly staged_metallib="$bin_path/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
[[ -x "$executable" && -f "$executable" && ! -L "$executable" \
    && "$(stat -f %l "$executable")" == "1" ]] ||
    fail "Release Stage-6 executable is missing or aliased"
for framework in CoreGraphics Metal; do
    otool -L "$executable" | grep -Fq "/${framework}.framework/" ||
        fail "Release Stage-6 executable does not link ${framework}"
done
[[ -z "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print)" ]] ||
    fail "Release build already contains a metallib candidate"
mkdir -p "$(dirname "$staged_metallib")"
cp -X "$metallib" "$staged_metallib"
chmod 444 "$staged_metallib"
assert_regular_file "$staged_metallib"
[[ "$(stat -f %Lp "$staged_metallib")" == "444" \
    && "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
    && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
        == "$metallib_sha256" ]] ||
    fail "staged Release metallib identity changed"
cmp -s "$metallib" "$staged_metallib" ||
    fail "staged Release metallib bytes changed"

mkdir -p "$private_cwd" "$lease_root"
chmod 700 "$private_cwd" "$lease_root"
readonly effective_uid="$(id -u)"
for private_directory in "$private_cwd" "$lease_root"; do
    [[ -d "$private_directory" && ! -L "$private_directory" \
        && "$(cd "$private_directory" && pwd -P)" == "$private_directory" \
        && "$(stat -f %u "$private_directory")" == "$effective_uid" \
        && "$(stat -f %Lp "$private_directory")" == "700" \
        && "$(stat -f %l "$private_directory")" == "2" \
        && -z "$(find "$private_directory" -mindepth 1 -print)" ]] ||
        fail "private Stage-6 directory is invalid: $private_directory"
done

readonly operating_system_build="$(sw_vers -productVersion)-$(sw_vers -buildVersion)"
readonly kernel_identity="$(uname -srvmp)"
readonly swift_toolchain="$(swift --version | tr '\n' ' ' | awk '{$1=$1; print}')"
readonly xcode_toolchain="$(xcodebuild -version | tr '\n' ' ' | awk '{$1=$1; print}')"
readonly macos_sdk="$(xcrun --sdk macosx --show-sdk-version)"

set +e
(
    cd "$private_cwd"
    env \
        TMPDIR="$runner_temp" \
        MLX_ENABLE_TF32=0 \
        PRIME_NATIVE_DECODER_STAGE6_METAL_LEASE_PATH="$lease_path" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_ID="$authority_id" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CANONICAL_SHA256="$authority_canonical_sha256" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_SOURCE_IDENTITY_JSON="$authority_source_identity_json" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_TEST_IDENTITY_JSON="$authority_test_identity_json" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_BASE_REVISION="f5a9638194c53922f09c39c3c76095b5cc47c25e" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_BASE_TREE="a17a8f92604157c0de0252dbc30cf22681d6a13d" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_REVISION="$authority_closure_revision" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_TREE="$authority_closure_tree" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_RUN_ID="$authority_closure_run_id" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_RUN_NUMBER="$authority_closure_run_number" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_RUN_ATTEMPT="$authority_closure_run_attempt" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_CHECK_SUITE_ID="$authority_closure_check_suite_id" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_ACTIVE_JOB_ID="$authority_closure_active_job_id" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_ACTIVE_JOB_CONCLUSION="$authority_closure_active_job_conclusion" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_REVIEWED_JOB_ID="$authority_closure_reviewed_job_id" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_REVIEWED_JOB_CONCLUSION="$authority_closure_reviewed_job_conclusion" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_EVENT="$authority_closure_event" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_REF="$authority_closure_ref" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_STATUS="$authority_closure_status" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_CONCLUSION="$authority_closure_conclusion" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_ARTIFACT_COUNT="$authority_closure_artifact_count" \
        PRIME_NATIVE_DECODER_STAGE6_AUTHORITY_CLOSURE_RERUN_COUNT="$authority_closure_rerun_count" \
        PRIME_NATIVE_DECODER_STAGE6_MECHANICS_EXECUTED_REVISION="$exact_revision" \
        PRIME_NATIVE_DECODER_STAGE6_MECHANICS_EXECUTED_TREE="$exact_tree" \
        PRIME_NATIVE_DECODER_STAGE6_MECHANICS_FIRST_PARENT="$first_parent" \
        PRIME_NATIVE_DECODER_STAGE6_MECHANICS_SECOND_PARENT="$second_parent" \
        PRIME_NATIVE_DECODER_STAGE6_MECHANICS_EVENT="$GITHUB_EVENT_NAME" \
        PRIME_NATIVE_DECODER_STAGE6_MECHANICS_REF="$GITHUB_REF" \
        PRIME_NATIVE_DECODER_STAGE6_MECHANICS_RUN_ID="$GITHUB_RUN_ID" \
        PRIME_NATIVE_DECODER_STAGE6_MECHANICS_RUN_NUMBER="$GITHUB_RUN_NUMBER" \
        PRIME_NATIVE_DECODER_STAGE6_MECHANICS_RUN_ATTEMPT="$GITHUB_RUN_ATTEMPT" \
        PRIME_NATIVE_DECODER_STAGE6_EXACT_CHANGED_SOURCE_IDENTITIES_JSON="$exact_changed_source_identities_json" \
        PRIME_NATIVE_DECODER_STAGE6_PROVENANCE_SOURCE_IDENTITIES_JSON="$provenance_source_identities_json" \
        PRIME_NATIVE_DECODER_STAGE6_EMBEDDED_SOURCE_IDENTITY_SHA256="$embedded_source_identity" \
        PRIME_NATIVE_DECODER_STAGE6_EXACT_MLX_REVISION="$mlx_revision" \
        PRIME_NATIVE_DECODER_STAGE6_METALLIB_PATH="$staged_metallib" \
        PRIME_NATIVE_DECODER_STAGE6_METALLIB_BYTES="$metallib_byte_count" \
        PRIME_NATIVE_DECODER_STAGE6_METALLIB_SHA256="$metallib_sha256" \
        PRIME_NATIVE_DECODER_STAGE6_OPERATING_SYSTEM_BUILD="$operating_system_build" \
        PRIME_NATIVE_DECODER_STAGE6_KERNEL_IDENTITY="$kernel_identity" \
        PRIME_NATIVE_DECODER_STAGE6_SWIFT_TOOLCHAIN="$swift_toolchain" \
        PRIME_NATIVE_DECODER_STAGE6_XCODE_TOOLCHAIN="$xcode_toolchain" \
        PRIME_NATIVE_DECODER_STAGE6_MACOS_SDK="$macos_sdk" \
        PRIME_NATIVE_DECODER_STAGE6_BUILD_CONFIGURATION="release" \
        PRIME_NATIVE_DECODER_STAGE6_MLX_GRAPH_COMPILE_MODE="eager_uncompiled_no_compile_transform" \
        "$executable"
) 2>&1 | tee "$supervisor_log"
supervisor_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${#supervisor_pipe_status[@]}" -eq 2 \
    && "${supervisor_pipe_status[0]}" -eq 0 \
    && "${supervisor_pipe_status[1]}" -eq 0 ]] ||
    fail "Stage-6 supervisor or log capture failed without a valid terminal result"
assert_regular_file "$supervisor_log"
readonly anchored_receipt_count="$(grep -Ec "^${receipt_prefix}" "$supervisor_log")"
readonly total_receipt_occurrence_count="$(awk -v needle="$receipt_prefix" '
    { line = $0; while ((position = index(line, needle)) > 0) {
        count += 1; line = substr(line, position + length(needle))
    }} END { print count + 0 }
' "$supervisor_log")"
[[ "$anchored_receipt_count" == "1" \
    && "$total_receipt_occurrence_count" == "1" ]] ||
    fail "Stage-6 supervisor did not emit exactly one canonical receipt"
readonly receipt_json="$(awk -v prefix="$receipt_prefix" '
    index($0, prefix) == 1 { print substr($0, length(prefix) + 1) }
' "$supervisor_log")"
[[ -n "$receipt_json" \
    && "$(printf '%s' "$receipt_json" | jq -cS .)" == "$receipt_json" ]] ||
    fail "Stage-6 receipt is not one canonical sorted JSON object"

printf '%s' "$receipt_json" | jq -e \
    --arg receipt_id "$receipt_id" \
    --arg authority_id "$authority_id" \
    --arg authority_canonical "$authority_canonical_sha256" \
    --argjson authority_source "$authority_source_identity_json" \
    --argjson authority_test "$authority_test_identity_json" \
    --arg authority_base_revision "f5a9638194c53922f09c39c3c76095b5cc47c25e" \
    --arg authority_base_tree "a17a8f92604157c0de0252dbc30cf22681d6a13d" \
    --arg closure_revision "$authority_closure_revision" \
    --arg closure_tree "$authority_closure_tree" \
    --argjson closure_run_id "$authority_closure_run_id" \
    --argjson closure_run_number "$authority_closure_run_number" \
    --argjson closure_run_attempt "$authority_closure_run_attempt" \
    --argjson closure_suite_id "$authority_closure_check_suite_id" \
    --argjson closure_active_job_id "$authority_closure_active_job_id" \
    --arg closure_active_conclusion "$authority_closure_active_job_conclusion" \
    --argjson closure_reviewed_job_id "$authority_closure_reviewed_job_id" \
    --arg closure_reviewed_conclusion "$authority_closure_reviewed_job_conclusion" \
    --arg mechanics_revision "$exact_revision" \
    --arg mechanics_tree "$exact_tree" \
    --arg mechanics_first_parent "$first_parent" \
    --arg mechanics_second_parent "$second_parent" \
    --argjson mechanics_run_id "$GITHUB_RUN_ID" \
    --argjson mechanics_run_number "$GITHUB_RUN_NUMBER" \
    --argjson mechanics_run_attempt "$GITHUB_RUN_ATTEMPT" \
    --argjson exact_sources "$exact_changed_source_identities_json" \
    --argjson provenance_sources "$provenance_source_identities_json" \
    --arg lease_path "$lease_path" \
    --arg mlx_revision "$mlx_revision" \
    --arg metallib_path "$staged_metallib" \
    --argjson metallib_bytes "$metallib_byte_count" \
    --arg metallib_sha "$metallib_sha256" \
    --arg operating_system_build "$operating_system_build" \
    --arg swift_version "$swift_toolchain" \
    --arg xcode_version "$xcode_toolchain" \
    --arg swift_sdk "$macos_sdk" \
    '
      def exact_keys($expected): keys == ($expected | sort);
      def hex64:
        type == "string" and test("^[0-9a-f]{64}$");
      def nonnegative_integer:
        type == "number" and . >= 0 and . == floor;
      def positive_integer:
        nonnegative_integer and . > 0;
      def uint32:
        nonnegative_integer and . <= 4294967295;
      def finite_float32_bits:
        uint32
        and (((. / 8388608) | floor) % 256) != 255;
      def finite_positive_float32_bits:
        uint32 and . > 0 and . < 2139095040;
      def round_positive_to_nearest_even:
        . as $value
        | ($value | floor) as $lower
        | ($value - $lower) as $fraction
        | if $fraction < 0.5 then $lower
          elif $fraction > 0.5 then $lower + 1
          elif ($lower % 2) == 0 then $lower
          else $lower + 1 end;
      def positive_float32_value:
        . as $bits
        | (($bits / 8388608) | floor) as $exponent
        | ($bits % 8388608) as $fraction
        | if $exponent == 0 then
            $fraction * pow(2; -149)
          else
            (1 + ($fraction / 8388608)) * pow(2; $exponent - 127)
          end;
      def positive_float32_bits:
        . as $value
        | if $value == 0 then 0
          elif $value < pow(2; -126) then
            (($value / pow(2; -149)) | round_positive_to_nearest_even)
          else
            (($value | log2) | floor) as $unbiased
            | ((($value / pow(2; $unbiased) - 1) * 8388608)
                | round_positive_to_nearest_even) as $rounded_fraction
            | if $rounded_fraction == 8388608 then
                ($unbiased + 128) * 8388608
              else
                ($unbiased + 127) * 8388608 + $rounded_fraction
              end
          end;
      def expected_gradient_clip_scale_bits:
        . as $norm_bits
        | if $norm_bits < 1065353216 then 1065353216
          else
            ((897988541 | positive_float32_value)
              + ($norm_bits | positive_float32_value)
              | positive_float32_bits
              | positive_float32_value) as $denominator
            | ((1 / $denominator) | positive_float32_bits)
          end;
      def fields_all_null($object; $fields):
        [$fields[] as $field | $object[$field]] | all(. == null);
      def fields_all_nonnull($object; $fields):
        [$fields[] as $field | $object[$field]] | all(. != null);
      def fields_atomic_nullable($object; $fields):
        fields_all_null($object; $fields)
        or fields_all_nonnull($object; $fields);
      def strictly_increasing:
        . as $values
        | all(range(1; length); . as $index
            | $values[$index] > $values[$index - 1]);
      def nondecreasing:
        . as $values
        | all(range(1; length); . as $index
            | $values[$index] >= $values[$index - 1]);
      def metal_observation_keys: [
        "metal_device_count","metal_device_index","metal_device_is_default",
        "metal_device_max_buffer_length_bytes",
        "metal_device_max_recommended_working_set_bytes",
        "metal_device_has_unified_memory","metal_device_name",
        "metal_device_registry_id"
      ];
      def mlx_policy_observation_keys: [
        "mlx_cpu_fallback_used","mlx_default_device_is_supplied_device",
        "mlx_default_stream_is_gpu","mlx_device_constructor_index",
        "mlx_device_type"
      ];
      def filesystem_observation_keys: [
        "filesystem_observation_fsid","filesystem_observation_path"
      ];
      def configured_limit_observation_keys: [
        "configured_cache_limit_readback_bytes",
        "configured_memory_limit_bytes",
        "configured_memory_limit_readback_bytes"
      ];
      def validated_model_observation_keys: [
        "validated_parameter_path_count","validated_unique_parameter_count",
        "validated_weights_logical_bytes"
      ];
      def validated_gradient_observation_keys: [
        "validated_gradient_logical_bytes","validated_gradient_path_count"
      ];
      def validated_moment_observation_keys: [
        "validated_first_moment_tensor_count",
        "validated_optimizer_moment_logical_bytes",
        "validated_second_moment_tensor_count"
      ];
      def outcome_observation_keys: [
        "loss_float32_bits","raw_gradient_norm_float32_bits",
        "gradient_clip_scale_float32_bits",
        "parameter_fingerprint_before","parameter_fingerprint_after",
        "parameter_fingerprint_sample_plan_sha256",
        "parameter_fingerprint_sample_count",
        "postflight_device_identity_matches_preflight",
        "postflight_mlx_policy_and_limits_match_preflight",
        "update_occurred"
      ];
      def postflight_outcome_observation_keys: [
        "postflight_device_identity_matches_preflight",
        "postflight_mlx_policy_and_limits_match_preflight"
      ];
      def numeric_phase_metric_keys: [
        "cumulative_worker_probe_elapsed_nanoseconds",
        "physical_memory_capacity_bytes","task_resident_bytes",
        "task_physical_footprint_bytes","getrusage_max_rss_bytes",
        "mlx_active_bytes","mlx_cache_bytes","mlx_peak_bytes",
        "metal_current_allocated_bytes","filesystem_capacity_bytes",
        "filesystem_available_bytes"
      ];
      def source_identity:
        exact_keys(["byte_count","git_blob","mode","path","sha256"])
        and .byte_count > 0
        and (.git_blob | type == "string" and test("^[0-9a-f]{40}$"))
        and (.mode == "100644" or .mode == "100755")
        and (.path | type == "string" and length > 0)
        and (.sha256 | hex64);

      . as $receipt
      | ($receipt | exact_keys([
          "authority","ceiling","configuration","environment","execution",
          "lease","limits","outcome","phase_metrics","receipt_id",
          "schema_version"
        ]))
      and $receipt.schema_version == 1
      and $receipt.receipt_id == $receipt_id

      and ($receipt.authority | exact_keys([
          "authority_canonical_sha256","authority_id",
          "authority_source_git_blob","authority_source_sha256",
          "authority_test_git_blob","authority_test_sha256"
        ]))
      and $receipt.authority == {
          authority_canonical_sha256:$authority_canonical,
          authority_id:$authority_id,
          authority_source_git_blob:$authority_source.git_blob,
          authority_source_sha256:$authority_source.sha256,
          authority_test_git_blob:$authority_test.git_blob,
          authority_test_sha256:$authority_test.sha256
        }

      and ($receipt.ceiling | exact_keys([
          "additional_execution_or_rerun_authorized",
          "artifact_upload_authorized",
          "broad_native300m_training_authorized",
          "candidate_admission_granted","canary_authorized",
          "checkpoint_admission_granted","downstream_trial_authorized",
          "durable_checkpoint_io_authorized",
          "exact_metal_gradient_bytes_established",
          "general_training_resume_established",
          "metal_determinism_established","model_quality_established",
          "native300m_trajectory_training_resume_established",
          "ordinary_job_fit_established","product_use_authorized",
          "publication_authorized","quantization_authorized",
          "repeated_trajectory_determinism_established",
          "retained_artifact_authorized",
          "stage5_assay_clearance_established",
          "stage5_mechanics_success_established",
          "stage5_replacement_execution_authorized",
          "stage5_result_established","stage7_authority_established",
          "stage7_authorized"
        ]))
      and ([$receipt.ceiling[]] | all(. == false))

      and ($receipt.configuration | exact_keys([
          "adamw_beta1_float32_bits","adamw_beta2_float32_bits",
          "adamw_bias_correction_applied","adamw_epsilon_float32_bits",
          "adamw_learning_rate_float32_bits",
          "adamw_weight_decay_float32_bits","batch_size",
          "batch_token_ids_sha256","completion_mask_dtype",
          "cross_entropy_api","cross_entropy_reduction",
          "gradient_accumulation_count","gradient_clip_algorithm_id",
          "gradient_clip_mode","gradient_norm_epsilon_float32_bits",
          "initialization_seed","logits_dtype","loss_dtype",
          "loss_graph_algorithm_id","maximum_gradient_norm_float32_bits",
          "model_configuration_factory","model_factory",
          "optimizer_qualified_type","optimizer_state_inspection_api",
          "optimizer_state_pair_topology","optimizer_step_count",
          "parameter_dtype","parameter_fingerprint_algorithm_id",
          "parameter_fingerprint_expected_path_count",
          "parameter_fingerprint_expected_sample_count",
          "parameter_fingerprint_samples_per_path",
          "parameter_path_count","per_target_loss_dtype",
          "per_target_loss_expected_element_count",
          "per_target_loss_expected_shape",
          "post_model_full_state_evaluation_api",
          "post_update_full_state_evaluation_api",
          "raw_gradient_norm_algorithm_id","selected_target_count",
          "sequence_length","token_id_dtype","training_logits_api",
          "unique_parameter_count","valid_token_count","value_and_grad_api"
        ]))
      and $receipt.configuration == {
          adamw_beta1_float32_bits:1063675494,
          adamw_beta2_float32_bits:1065336439,
          adamw_bias_correction_applied:false,
          adamw_epsilon_float32_bits:841731191,
          adamw_learning_rate_float32_bits:953267991,
          adamw_weight_decay_float32_bits:1008981770,
          batch_size:1,
          batch_token_ids_sha256:
            "220a52583cdbb82311863f4643679734b2ffc69725af021f066a84fc7520a172",
          completion_mask_dtype:"bool",
          cross_entropy_api:
            "MLXNN.crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)",
          cross_entropy_reduction:"none",
          gradient_accumulation_count:1,
          gradient_clip_algorithm_id:
            "prime_stage6_global_norm_clip_f32_v1",
          gradient_clip_mode:"global_l2_norm_clip_once_before_adamw_update",
          gradient_norm_epsilon_float32_bits:897988541,
          initialization_seed:44,
          logits_dtype:"float32",
          loss_dtype:"float32",
          loss_graph_algorithm_id:
            "prime_stage6_causal_masked_mean_cross_entropy_f32_v1",
          maximum_gradient_norm_float32_bits:1065353216,
          model_configuration_factory:"native300MInventory(vocabularySize:)",
          model_factory:"make(configuration:seed:)",
          optimizer_qualified_type:"MLXOptimizers.AdamW",
          optimizer_state_inspection_api:"MLXOptimizers.AdamW.innerState()",
          optimizer_state_pair_topology:
            "218_adjacent_[first_moment,second_moment]_pairs_from_TupleState.innerState",
          optimizer_step_count:1,
          parameter_dtype:"float32",
          parameter_fingerprint_algorithm_id:
            "prime_stage6_parameter_catalog_sample_f32be_sha256_v1",
          parameter_fingerprint_expected_path_count:218,
          parameter_fingerprint_expected_sample_count:654,
          parameter_fingerprint_samples_per_path:3,
          parameter_path_count:218,
          per_target_loss_dtype:"float32",
          per_target_loss_expected_element_count:127,
          per_target_loss_expected_shape:[1,127],
          post_model_full_state_evaluation_api:
            "checkedEval(model,before_fingerprint_sample_views)",
          post_update_full_state_evaluation_api:
            "checkedEval(model,optimizer,after_fingerprint_sample_views)",
          raw_gradient_norm_algorithm_id:
            "prime_stage6_global_f32_l2_norm_utf8_catalog_v1",
          selected_target_count:127,
          sequence_length:128,
          token_id_dtype:"int32",
          training_logits_api:"PrimeNativeGQADecoder.trainingLogitsNoCache",
          unique_parameter_count:271107072,
          valid_token_count:128,
          value_and_grad_api:"MLXNN.valueAndGrad(model:_:)"
        }

      and ($receipt.environment | exact_keys([
          "filesystem_observation_fsid","filesystem_observation_path",
          "metal_device_count","metal_device_has_unified_memory",
          "metal_device_index","metal_device_is_default",
          "metal_device_max_buffer_length_bytes",
          "metal_device_max_recommended_working_set_bytes",
          "metal_device_name","metal_device_registry_id",
          "mlx_compile_transform_invocation_count",
          "mlx_cpu_fallback_used",
          "mlx_default_device_is_supplied_device",
          "mlx_default_stream_is_gpu","mlx_device_constructor_index",
          "mlx_device_type","mlx_enable_tf32","mlx_revision",
          "operating_system_build","runtime_metallib_byte_count",
          "runtime_metallib_path","runtime_metallib_sha256",
          "swift_sdk","swift_version","swiftpm_build_configuration",
          "xcode_version"
        ]))
      and $receipt.environment.mlx_enable_tf32 == "0"
      and $receipt.environment.mlx_revision == $mlx_revision
      and $receipt.environment.mlx_compile_transform_invocation_count == 0
      and $receipt.environment.operating_system_build == $operating_system_build
      and $receipt.environment.runtime_metallib_path == $metallib_path
      and $receipt.environment.runtime_metallib_byte_count == $metallib_bytes
      and $receipt.environment.runtime_metallib_sha256 == $metallib_sha
      and $receipt.environment.swift_sdk == $swift_sdk
      and $receipt.environment.swift_version == $swift_version
      and $receipt.environment.swiftpm_build_configuration == "release"
      and $receipt.environment.xcode_version == $xcode_version
      and fields_atomic_nullable(
        $receipt.environment; metal_observation_keys)
      and fields_atomic_nullable(
        $receipt.environment; mlx_policy_observation_keys)
      and fields_atomic_nullable(
        $receipt.environment; filesystem_observation_keys)
      and (fields_all_null($receipt.environment; metal_observation_keys)
        or (
          ($receipt.environment.metal_device_count | nonnegative_integer)
          and ($receipt.environment.metal_device_index | nonnegative_integer)
          and ($receipt.environment.metal_device_is_default | type == "boolean")
          and ($receipt.environment.metal_device_max_buffer_length_bytes
            | positive_integer)
          and ($receipt.environment.metal_device_max_recommended_working_set_bytes
            | positive_integer)
          and ($receipt.environment.metal_device_has_unified_memory
            | type == "boolean")
          and ($receipt.environment.metal_device_name
            | type == "string" and length > 0)
          and ($receipt.environment.metal_device_registry_id
            | nonnegative_integer)
        ))
      and (fields_all_null($receipt.environment; mlx_policy_observation_keys)
        or (
          ($receipt.environment.mlx_cpu_fallback_used | type == "boolean")
          and ($receipt.environment.mlx_default_device_is_supplied_device
            | type == "boolean")
          and ($receipt.environment.mlx_default_stream_is_gpu
            | type == "boolean")
          and ($receipt.environment.mlx_device_constructor_index
            | nonnegative_integer)
          and ($receipt.environment.mlx_device_type
            | type == "string" and length > 0)
        ))
      and (fields_all_null($receipt.environment; filesystem_observation_keys)
        or (
          ($receipt.environment.filesystem_observation_path
            | type == "string"
              and startswith("/") and . != "/" and (endswith("/") | not)
              and (test("(^|/)\\.\\.?(/|$)") | not))
          and ($receipt.environment.filesystem_observation_fsid
            | type == "array" and length == 2
              and all(.[];
                type == "number" and . == floor
                  and . >= -2147483648 and . <= 2147483647))
        ))

      and ($receipt.execution | exact_keys([
          "authority_base_revision","authority_base_tree",
          "authority_closure_active_job_conclusion",
          "authority_closure_active_job_id","authority_closure_artifact_count",
          "authority_closure_check_suite_id","authority_closure_conclusion",
          "authority_closure_event","authority_closure_ref",
          "authority_closure_rerun_count","authority_closure_revision",
          "authority_closure_reviewed_job_conclusion",
          "authority_closure_reviewed_job_id",
          "authority_closure_run_attempt","authority_closure_run_id",
          "authority_closure_run_number","authority_closure_status",
          "authority_closure_tree","build_count",
          "direct_executable_probe_count","direct_xctest_count",
          "exact_changed_source_identities","launcher_invocation_count",
          "mechanics_event","mechanics_head_ordered_parent_revisions",
          "mechanics_head_revision","mechanics_head_tree","mechanics_ref",
          "mechanics_run_attempt","mechanics_run_id","mechanics_run_number",
          "provenance_source_identities","repository",
          "supervisor_end_to_end_elapsed_nanoseconds",
          "supervisor_process_count",
          "supervisor_timeout_trigger_elapsed_nanoseconds",
          "supervisor_timeout_triggered","timeout_scope",
          "worker_active_elapsed_nanoseconds","worker_candidate_frame_count",
          "worker_exit_code","worker_last_complete_frame_sequence",
          "worker_process_count","worker_progress_frame_count",
          "worker_signal","worker_spawn_attempt_count","worker_spawn_errno",
          "worker_spawn_succeeded",
          "worker_timeout_trigger_elapsed_nanoseconds",
          "worker_timeout_triggered",
          "worker_trailing_partial_frame_discarded",
          "worker_transport_drift_detected"
        ]))
      and $receipt.execution.authority_base_revision == $authority_base_revision
      and $receipt.execution.authority_base_tree == $authority_base_tree
      and $receipt.execution.authority_closure_revision == $closure_revision
      and $receipt.execution.authority_closure_tree == $closure_tree
      and $receipt.execution.authority_closure_run_id == $closure_run_id
      and $receipt.execution.authority_closure_run_number == $closure_run_number
      and $receipt.execution.authority_closure_run_attempt == $closure_run_attempt
      and $receipt.execution.authority_closure_check_suite_id == $closure_suite_id
      and $receipt.execution.authority_closure_active_job_id
        == $closure_active_job_id
      and $receipt.execution.authority_closure_active_job_conclusion
        == $closure_active_conclusion
      and $receipt.execution.authority_closure_reviewed_job_id
        == $closure_reviewed_job_id
      and $receipt.execution.authority_closure_reviewed_job_conclusion
        == $closure_reviewed_conclusion
      and $receipt.execution.authority_closure_event == "push"
      and $receipt.execution.authority_closure_ref == "refs/heads/main"
      and $receipt.execution.authority_closure_status == "completed"
      and $receipt.execution.authority_closure_conclusion == "success"
      and $receipt.execution.authority_closure_artifact_count == 0
      and $receipt.execution.authority_closure_rerun_count == 0
      and $receipt.execution.mechanics_event == "push"
      and $receipt.execution.mechanics_ref == "refs/heads/main"
      and $receipt.execution.mechanics_head_revision == $mechanics_revision
      and $receipt.execution.mechanics_head_tree == $mechanics_tree
      and $receipt.execution.mechanics_head_ordered_parent_revisions
        == [$mechanics_first_parent,$mechanics_second_parent]
      and $receipt.execution.mechanics_run_id == $mechanics_run_id
      and $receipt.execution.mechanics_run_number == $mechanics_run_number
      and $receipt.execution.mechanics_run_attempt == $mechanics_run_attempt
      and $receipt.execution.repository == "Ergentics/ergentics-prime"
      and $receipt.execution.build_count == 1
      and $receipt.execution.direct_xctest_count == 1
      and $receipt.execution.direct_executable_probe_count == 1
      and $receipt.execution.launcher_invocation_count == 1
      and $receipt.execution.supervisor_process_count == 1
      and $receipt.execution.worker_spawn_attempt_count == 1
      and $receipt.execution.exact_changed_source_identities == $exact_sources
      and $receipt.execution.provenance_source_identities
        == $provenance_sources
      and ($receipt.execution.exact_changed_source_identities
        | length == 8 and all(.[]; source_identity))
      and ($receipt.execution.provenance_source_identities.identities
        | length == 7 and all(.[]; source_identity))
      and ($receipt.execution.supervisor_end_to_end_elapsed_nanoseconds
        | nonnegative_integer)
      and ($receipt.execution.worker_process_count
        | nonnegative_integer and (. == 0 or . == 1))
      and ($receipt.execution.worker_spawn_succeeded | type == "boolean")
      and ($receipt.execution.worker_timeout_triggered | type == "boolean")
      and ($receipt.execution.supervisor_timeout_triggered | type == "boolean")
      and ($receipt.execution.worker_trailing_partial_frame_discarded
        | type == "boolean")
      and ($receipt.execution.worker_transport_drift_detected
        | type == "boolean")
      and ($receipt.execution.worker_progress_frame_count
        | nonnegative_integer)
      and ($receipt.execution.worker_candidate_frame_count
        | nonnegative_integer)
      and (($receipt.execution.worker_progress_frame_count
          + $receipt.execution.worker_candidate_frame_count) as $frame_count
        | if $frame_count == 0 then
            $receipt.execution.worker_last_complete_frame_sequence == null
          elif $receipt.execution.worker_transport_drift_detected == true then
            $receipt.execution.worker_last_complete_frame_sequence == null
              or ($receipt.execution.worker_last_complete_frame_sequence
                | nonnegative_integer)
          else
            ($receipt.execution.worker_last_complete_frame_sequence
              | nonnegative_integer)
            and $receipt.execution.worker_last_complete_frame_sequence
              == ($frame_count - 1)
          end)
      and (if $receipt.execution.worker_process_count == 0 then
          $receipt.execution.worker_spawn_succeeded == false
          and ($receipt.execution.worker_spawn_errno | positive_integer)
          and $receipt.execution.worker_exit_code == null
          and $receipt.execution.worker_signal == null
          and $receipt.execution.worker_active_elapsed_nanoseconds == null
          and $receipt.execution.worker_timeout_triggered == false
          and $receipt.execution.worker_timeout_trigger_elapsed_nanoseconds
            == null
        else
          $receipt.execution.worker_spawn_succeeded == true
          and $receipt.execution.worker_spawn_errno == null
          and ((($receipt.execution.worker_exit_code
                | nonnegative_integer and . <= 255)
              and $receipt.execution.worker_signal == null)
            or ($receipt.execution.worker_exit_code == null
              and ($receipt.execution.worker_signal
                | positive_integer and . <= 127)))
          and ($receipt.execution.worker_active_elapsed_nanoseconds
            | nonnegative_integer)
          and $receipt.execution.worker_active_elapsed_nanoseconds
            <= $receipt.execution.supervisor_end_to_end_elapsed_nanoseconds
        end)
      and (if $receipt.execution.worker_timeout_triggered == false then
          $receipt.execution.worker_timeout_trigger_elapsed_nanoseconds == null
        else
          ($receipt.execution.worker_timeout_trigger_elapsed_nanoseconds
            | nonnegative_integer and . >= 1200000000000)
          and $receipt.execution.worker_active_elapsed_nanoseconds
            >= $receipt.execution.worker_timeout_trigger_elapsed_nanoseconds
        end)
      and (if $receipt.execution.supervisor_timeout_triggered == false then
          $receipt.execution.supervisor_timeout_trigger_elapsed_nanoseconds
            == null
        else
          ($receipt.execution.supervisor_timeout_trigger_elapsed_nanoseconds
            | nonnegative_integer and . >= 1500000000000)
          and $receipt.execution.supervisor_end_to_end_elapsed_nanoseconds
            >= $receipt.execution.supervisor_timeout_trigger_elapsed_nanoseconds
        end)
      and (if $receipt.execution.worker_timeout_triggered == false
          and $receipt.execution.supervisor_timeout_triggered == false then
          $receipt.execution.timeout_scope == null
          and ($receipt.execution.worker_active_elapsed_nanoseconds == null
            or $receipt.execution.worker_active_elapsed_nanoseconds
              < 1200000000000)
          and $receipt.execution.supervisor_end_to_end_elapsed_nanoseconds
            < 1500000000000
        elif $receipt.execution.worker_timeout_triggered == true
          and $receipt.execution.supervisor_timeout_triggered == false then
          $receipt.execution.timeout_scope == "worker_active"
        elif $receipt.execution.worker_timeout_triggered == false
          and $receipt.execution.supervisor_timeout_triggered == true then
          $receipt.execution.timeout_scope == "supervisor_end_to_end"
        else
          $receipt.execution.timeout_scope
            == "worker_active_and_supervisor_end_to_end"
        end)

      and ($receipt.lease | exact_keys([
          "acquired_before_coregraphics_metal_or_mlx","acquired_nonblocking",
          "held_through_candidate_flush","held_through_postflight",
          "lease_path","supervisor_reacquire_release_proved","type",
          "worker_owned"
        ]))
      and $receipt.lease.lease_path == $lease_path
      and $receipt.lease.type == "PrimeMetalDeviceLease"
      and $receipt.lease.acquired_nonblocking == true
      and ([
          $receipt.lease.acquired_before_coregraphics_metal_or_mlx,
          $receipt.lease.held_through_candidate_flush,
          $receipt.lease.held_through_postflight,
          $receipt.lease.supervisor_reacquire_release_proved,
          $receipt.lease.worker_owned
        ] | all(type == "boolean"))
      and $receipt.lease.worker_owned
        == $receipt.lease.acquired_before_coregraphics_metal_or_mlx
      and (if $receipt.lease.held_through_candidate_flush then
          $receipt.lease.acquired_before_coregraphics_metal_or_mlx
        else true end)
      and (if $receipt.lease.held_through_postflight then
          $receipt.lease.acquired_before_coregraphics_metal_or_mlx
        else true end)

      and ($receipt.limits | exact_keys([
          "available_filesystem_floor_bytes",
          "configured_cache_limit_bytes",
          "configured_cache_limit_readback_bytes",
          "configured_memory_limit_bytes",
          "configured_memory_limit_formula",
          "configured_memory_limit_readback_bytes",
          "container_headers_and_manifests_included_in_minimum",
          "duplicate_materializations_graphs_and_temporary_buffers_included_in_minimum",
          "gradient_logical_bytes","minimum_committed_tensor_state_bytes",
          "minimum_memory_limit_floor_bytes",
          "minimum_state_plus_gradient_bytes","mlx_limit_is_not_rss_limit",
          "optimizer_moment_logical_bytes","optimizer_moment_tensor_count",
          "statfs_is_observational_only",
          "supervisor_end_to_end_timeout_seconds",
          "termination_grace_seconds",
          "three_times_committed_state_disk_comparator_bytes",
          "validated_first_moment_tensor_count",
          "validated_gradient_logical_bytes",
          "validated_gradient_path_count",
          "validated_optimizer_moment_logical_bytes",
          "validated_parameter_path_count",
          "validated_second_moment_tensor_count",
          "validated_unique_parameter_count",
          "validated_weights_logical_bytes","weights_logical_bytes",
          "worker_active_timeout_seconds"
        ]))
      and $receipt.limits.available_filesystem_floor_bytes == 12884901888
      and $receipt.limits.configured_cache_limit_bytes == 0
      and $receipt.limits.configured_memory_limit_formula
        == "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)"
      and $receipt.limits.gradient_logical_bytes == 1084428288
      and $receipt.limits.minimum_committed_tensor_state_bytes == 3253284864
      and $receipt.limits.minimum_memory_limit_floor_bytes == 4337713152
      and $receipt.limits.minimum_state_plus_gradient_bytes == 4337713152
      and $receipt.limits.mlx_limit_is_not_rss_limit == true
      and $receipt.limits.optimizer_moment_logical_bytes == 2168856576
      and $receipt.limits.optimizer_moment_tensor_count == 436
      and $receipt.limits.statfs_is_observational_only == true
      and $receipt.limits.supervisor_end_to_end_timeout_seconds == 1500
      and $receipt.limits.termination_grace_seconds == 10
      and $receipt.limits.three_times_committed_state_disk_comparator_bytes
        == 9759854592
      and $receipt.limits.weights_logical_bytes == 1084428288
      and $receipt.limits.worker_active_timeout_seconds == 1200
      and $receipt.limits.container_headers_and_manifests_included_in_minimum
        == false
      and $receipt.limits.duplicate_materializations_graphs_and_temporary_buffers_included_in_minimum
        == false
      and fields_atomic_nullable(
        $receipt.limits; configured_limit_observation_keys)
      and fields_atomic_nullable(
        $receipt.limits; validated_model_observation_keys)
      and fields_atomic_nullable(
        $receipt.limits; validated_gradient_observation_keys)
      and fields_atomic_nullable(
        $receipt.limits; validated_moment_observation_keys)
      and (fields_all_null(
          $receipt.limits; configured_limit_observation_keys)
        or (
          ($receipt.limits.configured_cache_limit_readback_bytes
            | nonnegative_integer)
          and ($receipt.limits.configured_memory_limit_bytes
            | positive_integer)
          and ($receipt.limits.configured_memory_limit_readback_bytes
            | nonnegative_integer)
          and fields_all_nonnull(
            $receipt.environment; metal_observation_keys)
          and $receipt.limits.configured_memory_limit_bytes
            == (if
                $receipt.environment
                  .metal_device_max_recommended_working_set_bytes
                  < 17179869184
              then
                $receipt.environment
                  .metal_device_max_recommended_working_set_bytes
              else 17179869184 end)
        ))
      and (fields_all_null($receipt.limits; validated_model_observation_keys)
        or (validated_model_observation_keys
          | all(. as $key
              | $receipt.limits[$key] | nonnegative_integer)))
      and (fields_all_null(
          $receipt.limits; validated_gradient_observation_keys)
        or (validated_gradient_observation_keys
          | all(. as $key
              | $receipt.limits[$key] | nonnegative_integer)))
      and (fields_all_null($receipt.limits; validated_moment_observation_keys)
        or (validated_moment_observation_keys
          | all(. as $key
              | $receipt.limits[$key] | nonnegative_integer)))

      and ($receipt.outcome | exact_keys([
          "classification","gradient_clip_scale_float32_bits",
          "loss_float32_bits","one_shot_consumed","operation_counts",
          "parameter_fingerprint_after","parameter_fingerprint_before",
          "parameter_fingerprint_sample_count",
          "parameter_fingerprint_sample_plan_sha256",
          "postflight_device_identity_matches_preflight",
          "postflight_mlx_policy_and_limits_match_preflight",
          "raw_gradient_norm_float32_bits",
          "resource_clearance_established",
          "resource_envelope_established","resource_probe_executed",
          "runner_memory_capacity_established","status","update_occurred",
          "worker_candidate_present"
        ]))
      and ($receipt.outcome.operation_counts | exact_keys([
          "adamw_update_count","backward_count",
          "checked_evaluation_barrier_count","cross_entropy_count",
          "evaluation_forward_pass_count","forward_loss_count",
          "full_graph_evaluation_count",
          "gpu_synchronization_barrier_count","gradient_clip_count",
          "gradient_norm_count","kv_cache_allocation_count",
          "memory_clear_cache_count","mlx_peak_memory_reset_count",
          "model_allocation_count","model_materialization_count",
          "optimizer_step_count","postflight_device_reenumeration_count",
          "training_logits_count","value_and_grad_count"
        ]))
      and ([
          $receipt.outcome.operation_counts.adamw_update_count <= 1,
          $receipt.outcome.operation_counts.backward_count <= 1,
          $receipt.outcome.operation_counts.checked_evaluation_barrier_count <= 5,
          $receipt.outcome.operation_counts.cross_entropy_count <= 1,
          $receipt.outcome.operation_counts.evaluation_forward_pass_count == 0,
          $receipt.outcome.operation_counts.forward_loss_count <= 1,
          $receipt.outcome.operation_counts.full_graph_evaluation_count <= 1,
          $receipt.outcome.operation_counts.gpu_synchronization_barrier_count <= 5,
          $receipt.outcome.operation_counts.gradient_clip_count <= 1,
          $receipt.outcome.operation_counts.gradient_norm_count <= 1,
          $receipt.outcome.operation_counts.kv_cache_allocation_count == 0,
          $receipt.outcome.operation_counts.memory_clear_cache_count <= 1,
          $receipt.outcome.operation_counts.mlx_peak_memory_reset_count <= 1,
          $receipt.outcome.operation_counts.model_allocation_count <= 1,
          $receipt.outcome.operation_counts.model_materialization_count <= 1,
          $receipt.outcome.operation_counts.optimizer_step_count <= 1,
          $receipt.outcome.operation_counts.postflight_device_reenumeration_count <= 1,
          $receipt.outcome.operation_counts.training_logits_count <= 1,
          $receipt.outcome.operation_counts.value_and_grad_count <= 1
        ] | all(. == true))
      and ([$receipt.outcome.operation_counts[]]
        | all(nonnegative_integer))
      and $receipt.outcome.one_shot_consumed == true
      and ($receipt.outcome.resource_clearance_established
        | type == "boolean")
      and ($receipt.outcome.resource_envelope_established
        | type == "boolean")
      and ($receipt.outcome.resource_probe_executed | type == "boolean")
      and ($receipt.outcome.runner_memory_capacity_established
        | type == "boolean")
      and ($receipt.outcome.worker_candidate_present | type == "boolean")
      and ($receipt.outcome.loss_float32_bits == null
        or ($receipt.outcome.loss_float32_bits | uint32))
      and ($receipt.outcome.raw_gradient_norm_float32_bits == null
        or ($receipt.outcome.raw_gradient_norm_float32_bits | uint32))
      and ($receipt.outcome.gradient_clip_scale_float32_bits == null
        or ($receipt.outcome.gradient_clip_scale_float32_bits | uint32))
      and ($receipt.outcome.parameter_fingerprint_before == null
        or ($receipt.outcome.parameter_fingerprint_before | hex64))
      and ($receipt.outcome.parameter_fingerprint_after == null
        or ($receipt.outcome.parameter_fingerprint_after | hex64))
      and ($receipt.outcome.parameter_fingerprint_sample_plan_sha256 == null
        or ($receipt.outcome.parameter_fingerprint_sample_plan_sha256
          | hex64))
      and ($receipt.outcome.parameter_fingerprint_sample_count == null
        or ($receipt.outcome.parameter_fingerprint_sample_count
          | nonnegative_integer))
      and ($receipt.outcome.postflight_device_identity_matches_preflight
          == null
        or ($receipt.outcome.postflight_device_identity_matches_preflight
          | type == "boolean"))
      and ($receipt.outcome.postflight_mlx_policy_and_limits_match_preflight
          == null
        or ($receipt.outcome.postflight_mlx_policy_and_limits_match_preflight
          | type == "boolean"))
      and fields_atomic_nullable(
        $receipt.outcome; postflight_outcome_observation_keys)
      and ($receipt.outcome.update_occurred == null
        or ($receipt.outcome.update_occurred | type == "boolean"))
      and ($receipt.outcome.classification | IN(
          "pass","worker_spawn_failure","preflight_floor","lease_busy","oom",
          "timeout","signal","nonfinite","topology_dtype","no_update",
          "executor_receipt_drift"
        ))
      and (($receipt.outcome.status == "PASS"
          and $receipt.outcome.classification == "pass")
        or ($receipt.outcome.status == "ABSTAIN"
          and $receipt.outcome.classification != "pass"))
      and (($receipt.outcome.classification == "worker_spawn_failure")
        == ($receipt.execution.worker_process_count == 0))
      and (($receipt.outcome.classification == "timeout")
        == ($receipt.execution.worker_timeout_triggered
          or $receipt.execution.supervisor_timeout_triggered))
      and (if $receipt.execution.worker_signal != null
          and $receipt.execution.worker_timeout_triggered == false
          and $receipt.execution.supervisor_timeout_triggered == false
        then $receipt.outcome.classification == "signal"
        else true end)
      and (if $receipt.outcome.status == "PASS" then
          $receipt.execution.worker_candidate_frame_count == 1
        elif $receipt.outcome.classification == "executor_receipt_drift" then
          true
        else
          $receipt.execution.worker_candidate_frame_count <= 1
        end)
      and (if $receipt.execution.worker_candidate_frame_count >= 2 then
          $receipt.outcome.classification == "executor_receipt_drift"
          and $receipt.execution.worker_transport_drift_detected == true
        else true end)
      and (if $receipt.execution.worker_transport_drift_detected == true
          or $receipt.execution.worker_trailing_partial_frame_discarded == true
        then
          $receipt.outcome.status == "ABSTAIN"
          and ($receipt.outcome.classification | IN(
            "timeout","signal","executor_receipt_drift"))
        else true end)
      and ($receipt.outcome.resource_probe_executed
        == ($receipt.outcome.operation_counts.model_allocation_count == 1))
      and ($receipt.outcome.runner_memory_capacity_established
        == (($receipt.environment.metal_device_has_unified_memory == true)
          and any($receipt.phase_metrics[];
            .availability == "observed"
            and .physical_memory_capacity_bytes != null)))

      and ($receipt.phase_metrics | type == "array" and length == 6)
      and ([$receipt.phase_metrics[].phase] == [
          "preflight","post_model_materialization",
          "post_forward_backward","post_norm_clip",
          "post_adam_update_full_evaluation",
          "post_lexical_deallocation_and_clear_cache"
        ])
      and all($receipt.phase_metrics[];
        exact_keys([
          "availability","cumulative_worker_probe_elapsed_nanoseconds",
          "filesystem_available_bytes","filesystem_capacity_bytes",
          "getrusage_max_rss_bytes","metal_current_allocated_bytes",
          "mlx_active_bytes","mlx_cache_bytes","mlx_peak_bytes","phase",
          "physical_memory_capacity_bytes","task_physical_footprint_bytes",
          "task_resident_bytes","unavailable_reason"
        ]))
      and all($receipt.phase_metrics[];
        (.availability | IN(
          "observed","unavailable_before_probe_start",
          "unavailable_after_fatal","unavailable_after_classification"
        )))
      and all($receipt.phase_metrics[];
        . as $phase
        | if $phase.availability == "observed" then
            $phase.unavailable_reason == null
            and (numeric_phase_metric_keys
              | all(. as $key | $phase[$key] | nonnegative_integer))
            and ($phase.physical_memory_capacity_bytes | positive_integer)
            and ($phase.filesystem_capacity_bytes | positive_integer)
            and $phase.filesystem_available_bytes
              <= $phase.filesystem_capacity_bytes
          else
            $phase.unavailable_reason == $receipt.outcome.classification
            and (numeric_phase_metric_keys
              | all(. as $key | $phase[$key] == null))
          end)
      and (reduce $receipt.phase_metrics[] as $phase
        ({unavailable_seen:false,valid:true};
          if $phase.availability == "observed" then
            .valid = (.valid and (.unavailable_seen | not))
          else
            .unavailable_seen = true
          end
        ) | .valid)
      and ([ $receipt.phase_metrics[]
          | select(.availability == "observed")
          | .cumulative_worker_probe_elapsed_nanoseconds ]
        | strictly_increasing)
      and ([ $receipt.phase_metrics[]
          | select(.availability == "observed")
          | .mlx_peak_bytes ] | nondecreasing)
      and ([ $receipt.phase_metrics[]
          | select(.availability == "observed")
          | .getrusage_max_rss_bytes ] | nondecreasing)
      and ([ $receipt.phase_metrics[]
          | select(.availability == "observed")
          | .cumulative_worker_probe_elapsed_nanoseconds ] as $elapsed
        | ($elapsed | length) == 0
          or ($receipt.execution.worker_active_elapsed_nanoseconds != null
            and $elapsed[-1]
              <= $receipt.execution.worker_active_elapsed_nanoseconds))
      and ([$receipt.phase_metrics[].availability] as $availability
        | ([$availability[] | select(. == "observed")] | length)
            as $observed
        | if $receipt.outcome.classification == "pass" then
            $observed == 6
          elif ($receipt.outcome.classification
            | IN("worker_spawn_failure","lease_busy")) then
            $observed == 0
            and all($availability[];
              . == "unavailable_before_probe_start")
          elif $receipt.outcome.classification == "preflight_floor" then
            $observed == 1
            and all($availability[$observed:][];
              . == "unavailable_after_classification")
          elif ($receipt.outcome.classification
            | IN("oom","timeout","signal")) then
            all($availability[$observed:][];
              . == "unavailable_after_fatal")
          elif ($receipt.outcome.classification
            | IN("nonfinite","no_update")) then
            $observed >= 1
            and all($availability[$observed:][];
              . == "unavailable_after_classification")
          else
            all($availability[$observed:][];
              . == "unavailable_after_classification")
          end
        and (if $observed >= 1 then
            fields_all_nonnull(
              $receipt.environment; metal_observation_keys)
            and fields_all_nonnull(
              $receipt.environment; mlx_policy_observation_keys)
            and fields_all_nonnull(
              $receipt.environment; filesystem_observation_keys)
            and fields_all_nonnull(
              $receipt.limits; configured_limit_observation_keys)
            and $receipt.outcome.operation_counts.mlx_peak_memory_reset_count
              == 1
          else true end)
        and (if $observed >= 2 then
            fields_all_nonnull(
              $receipt.limits; validated_model_observation_keys)
            and $receipt.outcome.operation_counts.model_allocation_count == 1
            and $receipt.outcome.operation_counts.model_materialization_count
              == 1
            and $receipt.outcome.operation_counts
              .checked_evaluation_barrier_count >= 1
            and $receipt.outcome.operation_counts
              .gpu_synchronization_barrier_count >= 1
          else true end)
        and (if $observed >= 3 then
            fields_all_nonnull(
              $receipt.limits; validated_gradient_observation_keys)
            and $receipt.outcome.operation_counts.value_and_grad_count == 1
            and $receipt.outcome.operation_counts.training_logits_count == 1
            and $receipt.outcome.operation_counts.cross_entropy_count == 1
            and $receipt.outcome.operation_counts.forward_loss_count == 1
            and $receipt.outcome.operation_counts.backward_count == 1
            and $receipt.outcome.operation_counts
              .checked_evaluation_barrier_count >= 2
            and $receipt.outcome.operation_counts
              .gpu_synchronization_barrier_count >= 2
          else true end)
        and (if $observed >= 4 then
            $receipt.outcome.operation_counts.gradient_norm_count == 1
            and $receipt.outcome.operation_counts.gradient_clip_count == 1
            and $receipt.outcome.operation_counts
              .checked_evaluation_barrier_count >= 4
            and $receipt.outcome.operation_counts
              .gpu_synchronization_barrier_count >= 4
          else true end)
        and (if $observed >= 5 then
            fields_all_nonnull(
              $receipt.limits; validated_moment_observation_keys)
            and $receipt.outcome.operation_counts.adamw_update_count == 1
            and $receipt.outcome.operation_counts.optimizer_step_count == 1
            and $receipt.outcome.operation_counts.full_graph_evaluation_count
              == 1
            and $receipt.outcome.operation_counts
              .checked_evaluation_barrier_count == 5
            and $receipt.outcome.operation_counts
              .gpu_synchronization_barrier_count == 5
          else true end)
        and (if $observed >= 6 then
            $receipt.outcome.operation_counts.memory_clear_cache_count == 1
          else true end)
        and (if $observed >= 2 then
            $receipt.outcome.parameter_fingerprint_sample_plan_sha256 != null
            and $receipt.outcome.parameter_fingerprint_sample_count != null
            and $receipt.outcome.parameter_fingerprint_before != null
          else
            $receipt.outcome.parameter_fingerprint_sample_plan_sha256 == null
            and $receipt.outcome.parameter_fingerprint_sample_count == null
            and $receipt.outcome.parameter_fingerprint_before == null
          end)
        and (if $observed >= 3 then
            $receipt.outcome.loss_float32_bits != null
          else $receipt.outcome.loss_float32_bits == null end)
        and (if $observed >= 4 then
            $receipt.outcome.raw_gradient_norm_float32_bits != null
            and $receipt.outcome.gradient_clip_scale_float32_bits != null
          else
            $receipt.outcome.raw_gradient_norm_float32_bits == null
            and $receipt.outcome.gradient_clip_scale_float32_bits == null
          end)
        and (if $observed >= 5 then
            $receipt.outcome.parameter_fingerprint_after != null
            and $receipt.outcome.update_occurred != null
          else
            $receipt.outcome.parameter_fingerprint_after == null
            and $receipt.outcome.update_occurred == null
          end)
        and (if $receipt.outcome.operation_counts
              .postflight_device_reenumeration_count == 0 then
            $receipt.outcome
              .postflight_device_identity_matches_preflight == null
            and $receipt.outcome
              .postflight_mlx_policy_and_limits_match_preflight == null
          elif fields_all_nonnull(
              $receipt.outcome; postflight_outcome_observation_keys) then
            $observed == 6
          else
            ($receipt.outcome.classification
              | IN("oom","timeout","signal","executor_receipt_drift"))
          end))
      and $receipt.outcome.operation_counts.gpu_synchronization_barrier_count
        <= $receipt.outcome.operation_counts.checked_evaluation_barrier_count
      and $receipt.outcome.operation_counts.checked_evaluation_barrier_count
        <= ($receipt.outcome.operation_counts
          .gpu_synchronization_barrier_count + 1)
      and $receipt.outcome.operation_counts.model_materialization_count
        <= $receipt.outcome.operation_counts.model_allocation_count
      and $receipt.outcome.operation_counts.model_allocation_count
        <= $receipt.outcome.operation_counts.mlx_peak_memory_reset_count
      and $receipt.outcome.operation_counts.value_and_grad_count
        <= $receipt.outcome.operation_counts.model_materialization_count
      and ([
          $receipt.outcome.operation_counts.value_and_grad_count,
          $receipt.outcome.operation_counts.training_logits_count,
          $receipt.outcome.operation_counts.cross_entropy_count,
          $receipt.outcome.operation_counts.forward_loss_count,
          $receipt.outcome.operation_counts.backward_count
        ] | unique | length) == 1
      and $receipt.outcome.operation_counts.gradient_norm_count
        <= $receipt.outcome.operation_counts.backward_count
      and $receipt.outcome.operation_counts.gradient_clip_count
        <= $receipt.outcome.operation_counts.gradient_norm_count
      and $receipt.outcome.operation_counts.adamw_update_count
        <= $receipt.outcome.operation_counts.gradient_clip_count
      and $receipt.outcome.operation_counts.optimizer_step_count
        == $receipt.outcome.operation_counts.adamw_update_count
      and $receipt.outcome.operation_counts.full_graph_evaluation_count
        <= $receipt.outcome.operation_counts.adamw_update_count
      and $receipt.outcome.operation_counts.memory_clear_cache_count
        <= $receipt.outcome.operation_counts.model_allocation_count
      and $receipt.outcome.operation_counts.postflight_device_reenumeration_count
        <= $receipt.outcome.operation_counts.memory_clear_cache_count
      and ($receipt.outcome.operation_counts.model_materialization_count
        == (if $receipt.outcome.operation_counts
            .checked_evaluation_barrier_count >= 1 then 1 else 0 end))
      and (if $receipt.outcome.operation_counts
          .checked_evaluation_barrier_count >= 2 then
          $receipt.outcome.operation_counts.value_and_grad_count == 1
        else true end)
      and (if $receipt.outcome.operation_counts
          .checked_evaluation_barrier_count >= 3 then
          $receipt.outcome.operation_counts.gradient_norm_count == 1
        else true end)
      and (if $receipt.outcome.operation_counts
          .checked_evaluation_barrier_count >= 4 then
          $receipt.outcome.operation_counts.gradient_clip_count == 1
        else true end)
      and ($receipt.outcome.operation_counts.full_graph_evaluation_count
        == (if $receipt.outcome.operation_counts
            .checked_evaluation_barrier_count == 5 then 1 else 0 end))
      and (if $receipt.outcome.operation_counts.memory_clear_cache_count == 1
        then
          $receipt.phase_metrics[4].availability == "observed"
        else true end)
      and ($receipt.outcome.operation_counts
          .postflight_device_reenumeration_count
        == (if $receipt.phase_metrics[5].availability == "observed"
          then 1 else 0 end))
      and (if $receipt.phase_metrics[0].availability == "observed" then
          if $receipt.outcome.classification == "preflight_floor" then
            $receipt.limits.configured_memory_limit_bytes
                < $receipt.limits.minimum_memory_limit_floor_bytes
              or $receipt.phase_metrics[0].filesystem_available_bytes
                < $receipt.limits.available_filesystem_floor_bytes
          else
            $receipt.limits.configured_memory_limit_bytes
                >= $receipt.limits.minimum_memory_limit_floor_bytes
            and $receipt.phase_metrics[0].filesystem_available_bytes
                >= $receipt.limits.available_filesystem_floor_bytes
          end
        else true end)
      and (if fields_all_nonnull(
          $receipt.limits; configured_limit_observation_keys) then
          if ($receipt.limits.configured_memory_limit_readback_bytes
                != $receipt.limits.configured_memory_limit_bytes)
            or ($receipt.limits.configured_cache_limit_readback_bytes != 0)
          then
            ($receipt.outcome.classification
              | IN("topology_dtype","executor_receipt_drift"))
          else true end
        else true end)
      and (if fields_all_nonnull(
          $receipt.environment; metal_observation_keys) then
          if $receipt.environment.metal_device_count != 1
            or $receipt.environment.metal_device_index != 0
            or $receipt.environment.metal_device_is_default != true
            or $receipt.environment.metal_device_has_unified_memory != true
          then
            ($receipt.outcome.classification
              | IN("topology_dtype","executor_receipt_drift"))
          else true end
        else true end)
      and (if fields_all_nonnull(
          $receipt.environment; mlx_policy_observation_keys) then
          if $receipt.environment.mlx_device_type != "gpu"
            or $receipt.environment.mlx_device_constructor_index != 0
            or $receipt.environment.mlx_default_device_is_supplied_device
              != true
            or $receipt.environment.mlx_default_stream_is_gpu != true
            or $receipt.environment.mlx_cpu_fallback_used != false
          then
            ($receipt.outcome.classification
              | IN("topology_dtype","executor_receipt_drift"))
          else true end
        else true end)
      and (if fields_all_nonnull(
          $receipt.limits; validated_model_observation_keys) then
          if $receipt.limits.validated_parameter_path_count != 218
            or $receipt.limits.validated_unique_parameter_count != 271107072
            or $receipt.limits.validated_weights_logical_bytes != 1084428288
          then
            ($receipt.outcome.classification
              | IN("topology_dtype","executor_receipt_drift"))
          else true end
        else true end)
      and (if fields_all_nonnull(
          $receipt.limits; validated_gradient_observation_keys) then
          if $receipt.limits.validated_gradient_path_count != 218
            or $receipt.limits.validated_gradient_logical_bytes != 1084428288
          then
            ($receipt.outcome.classification
              | IN("topology_dtype","executor_receipt_drift"))
          else true end
        else true end)
      and (if fields_all_nonnull(
          $receipt.limits; validated_moment_observation_keys) then
          if $receipt.limits.validated_first_moment_tensor_count != 218
            or $receipt.limits.validated_second_moment_tensor_count != 218
            or $receipt.limits.validated_optimizer_moment_logical_bytes
              != 2168856576
          then
            ($receipt.outcome.classification
              | IN("topology_dtype","executor_receipt_drift"))
          else true end
        else true end)
      and (if $receipt.outcome.update_occurred == false then
          ($receipt.outcome.classification
            | IN("no_update","topology_dtype","executor_receipt_drift"))
        else true end)
      and (if
          $receipt.outcome.postflight_device_identity_matches_preflight == false
          or $receipt.outcome
            .postflight_mlx_policy_and_limits_match_preflight == false
        then
          ($receipt.outcome.classification
            | IN("topology_dtype","executor_receipt_drift"))
        else true end)
      and (if any($receipt.phase_metrics[];
          .availability == "observed")
          or $receipt.outcome.operation_counts.model_allocation_count == 1
        then
          $receipt.lease.acquired_before_coregraphics_metal_or_mlx == true
        else true end)
      and (if fields_all_nonnull(
          $receipt.environment; metal_observation_keys)
          or fields_all_nonnull(
            $receipt.environment; mlx_policy_observation_keys)
          or fields_all_nonnull(
            $receipt.limits; configured_limit_observation_keys)
        then
          $receipt.lease.acquired_before_coregraphics_metal_or_mlx == true
        else true end)
      and (if fields_all_nonnull(
          $receipt.limits; validated_gradient_observation_keys)
        then $receipt.outcome.operation_counts.backward_count == 1
        else true end)
      and (if fields_all_nonnull(
          $receipt.limits; validated_moment_observation_keys)
        then $receipt.outcome.operation_counts.adamw_update_count == 1
        else true end)
      and (if
          $receipt.outcome.postflight_device_identity_matches_preflight != null
          or $receipt.outcome
            .postflight_mlx_policy_and_limits_match_preflight != null
        then $receipt.lease.held_through_postflight == true
        else true end)
      and $receipt.lease.supervisor_reacquire_release_proved
        == ($receipt.execution.worker_process_count == 1
          and $receipt.outcome.classification != "lease_busy")

      and (if $receipt.outcome.status == "PASS" then
          all($receipt.phase_metrics[]; .availability == "observed")
          and $receipt.outcome.resource_clearance_established == true
          and $receipt.outcome.resource_envelope_established == true
          and $receipt.outcome.resource_probe_executed == true
          and $receipt.outcome.worker_candidate_present == true
          and $receipt.execution.worker_process_count == 1
          and $receipt.execution.worker_exit_code == 0
          and $receipt.execution.worker_signal == null
          and $receipt.execution.worker_timeout_triggered == false
          and $receipt.execution.supervisor_timeout_triggered == false
          and $receipt.execution.timeout_scope == null
          and $receipt.execution.worker_candidate_frame_count == 1
          and $receipt.execution.worker_transport_drift_detected == false
          and $receipt.execution.worker_trailing_partial_frame_discarded == false
          and $receipt.lease.acquired_before_coregraphics_metal_or_mlx == true
          and $receipt.lease.held_through_candidate_flush == true
          and $receipt.lease.held_through_postflight == true
          and $receipt.lease.supervisor_reacquire_release_proved == true
          and $receipt.lease.worker_owned == true
          and $receipt.environment.metal_device_count == 1
          and $receipt.environment.metal_device_index == 0
          and $receipt.environment.metal_device_is_default == true
          and $receipt.environment.metal_device_has_unified_memory == true
          and $receipt.environment.mlx_device_type == "gpu"
          and $receipt.environment.mlx_device_constructor_index == 0
          and $receipt.environment.mlx_default_device_is_supplied_device == true
          and $receipt.environment.mlx_default_stream_is_gpu == true
          and $receipt.environment.mlx_cpu_fallback_used == false
          and $receipt.limits.configured_cache_limit_readback_bytes == 0
          and $receipt.limits.configured_memory_limit_bytes
            >= $receipt.limits.minimum_memory_limit_floor_bytes
          and $receipt.limits.configured_memory_limit_bytes
            == $receipt.limits.configured_memory_limit_readback_bytes
          and $receipt.limits.validated_parameter_path_count == 218
          and $receipt.limits.validated_unique_parameter_count == 271107072
          and $receipt.limits.validated_weights_logical_bytes == 1084428288
          and $receipt.limits.validated_gradient_path_count == 218
          and $receipt.limits.validated_gradient_logical_bytes == 1084428288
          and $receipt.limits.validated_first_moment_tensor_count == 218
          and $receipt.limits.validated_second_moment_tensor_count == 218
          and $receipt.limits.validated_optimizer_moment_logical_bytes
            == 2168856576
          and ($receipt.outcome.loss_float32_bits | finite_float32_bits)
          and ($receipt.outcome.raw_gradient_norm_float32_bits
            | finite_positive_float32_bits)
          and ($receipt.outcome.gradient_clip_scale_float32_bits
            | finite_positive_float32_bits)
          and $receipt.outcome.gradient_clip_scale_float32_bits
            == ($receipt.outcome.raw_gradient_norm_float32_bits
              | expected_gradient_clip_scale_bits)
          and ($receipt.outcome.parameter_fingerprint_before | hex64)
          and ($receipt.outcome.parameter_fingerprint_after | hex64)
          and $receipt.outcome.parameter_fingerprint_before
            != $receipt.outcome.parameter_fingerprint_after
          and ($receipt.outcome.parameter_fingerprint_sample_plan_sha256
            | hex64)
          and $receipt.outcome.parameter_fingerprint_sample_count == 654
          and $receipt.outcome.postflight_device_identity_matches_preflight
            == true
          and $receipt.outcome.postflight_mlx_policy_and_limits_match_preflight
            == true
          and $receipt.outcome.update_occurred == true
          and $receipt.outcome.operation_counts == {
            adamw_update_count:1,backward_count:1,
            checked_evaluation_barrier_count:5,cross_entropy_count:1,
            evaluation_forward_pass_count:0,forward_loss_count:1,
            full_graph_evaluation_count:1,
            gpu_synchronization_barrier_count:5,gradient_clip_count:1,
            gradient_norm_count:1,kv_cache_allocation_count:0,
            memory_clear_cache_count:1,mlx_peak_memory_reset_count:1,
            model_allocation_count:1,model_materialization_count:1,
            optimizer_step_count:1,postflight_device_reenumeration_count:1,
            training_logits_count:1,value_and_grad_count:1
          }
        else
          $receipt.outcome.resource_clearance_established == false
          and $receipt.outcome.resource_envelope_established == false
          and $receipt.outcome.worker_candidate_present == false
        end)
      and (if $receipt.outcome.classification == "worker_spawn_failure" then
          $receipt.execution.worker_process_count == 0
          and all($receipt.phase_metrics[];
            .availability == "unavailable_before_probe_start")
          and ([$receipt.outcome.operation_counts[]] | all(. == 0))
          and $receipt.outcome.resource_probe_executed == false
          and $receipt.outcome.runner_memory_capacity_established == false
          and $receipt.execution.worker_progress_frame_count == 0
          and $receipt.execution.worker_candidate_frame_count == 0
          and $receipt.execution.worker_last_complete_frame_sequence == null
          and $receipt.execution.worker_trailing_partial_frame_discarded
            == false
          and $receipt.execution.worker_transport_drift_detected == false
          and fields_all_null(
            $receipt.environment; metal_observation_keys)
          and fields_all_null(
            $receipt.environment; mlx_policy_observation_keys)
          and fields_all_null(
            $receipt.environment; filesystem_observation_keys)
          and fields_all_null(
            $receipt.limits; configured_limit_observation_keys)
          and fields_all_null(
            $receipt.limits; validated_model_observation_keys)
          and fields_all_null(
            $receipt.limits; validated_gradient_observation_keys)
          and fields_all_null(
            $receipt.limits; validated_moment_observation_keys)
          and fields_all_null($receipt.outcome; outcome_observation_keys)
          and $receipt.lease.acquired_before_coregraphics_metal_or_mlx
            == false
          and $receipt.lease.held_through_candidate_flush == false
          and $receipt.lease.held_through_postflight == false
          and $receipt.lease.supervisor_reacquire_release_proved == false
          and $receipt.lease.worker_owned == false
        elif $receipt.outcome.classification == "lease_busy" then
          all($receipt.phase_metrics[];
            .availability == "unavailable_before_probe_start")
          and $receipt.execution.worker_process_count == 1
          and $receipt.execution.worker_exit_code == 0
          and $receipt.execution.worker_signal == null
          and $receipt.execution.worker_timeout_triggered == false
          and $receipt.execution.supervisor_timeout_triggered == false
          and $receipt.execution.worker_progress_frame_count >= 1
          and $receipt.execution.worker_candidate_frame_count == 0
          and $receipt.execution.worker_trailing_partial_frame_discarded
            == false
          and $receipt.execution.worker_transport_drift_detected == false
          and ([$receipt.outcome.operation_counts[]] | all(. == 0))
          and $receipt.outcome.resource_probe_executed == false
          and $receipt.outcome.runner_memory_capacity_established == false
          and fields_all_null(
            $receipt.environment; metal_observation_keys)
          and fields_all_null(
            $receipt.environment; mlx_policy_observation_keys)
          and fields_all_null(
            $receipt.environment; filesystem_observation_keys)
          and fields_all_null(
            $receipt.limits; configured_limit_observation_keys)
          and fields_all_null(
            $receipt.limits; validated_model_observation_keys)
          and fields_all_null(
            $receipt.limits; validated_gradient_observation_keys)
          and fields_all_null(
            $receipt.limits; validated_moment_observation_keys)
          and fields_all_null($receipt.outcome; outcome_observation_keys)
          and $receipt.lease.acquired_before_coregraphics_metal_or_mlx == false
          and $receipt.lease.held_through_candidate_flush == false
          and $receipt.lease.held_through_postflight == false
          and $receipt.lease.supervisor_reacquire_release_proved == false
          and $receipt.lease.worker_owned == false
        elif $receipt.outcome.classification == "preflight_floor" then
          $receipt.execution.worker_process_count == 1
          and $receipt.execution.worker_exit_code == 0
          and $receipt.execution.worker_signal == null
          and $receipt.execution.worker_timeout_triggered == false
          and $receipt.execution.supervisor_timeout_triggered == false
          and $receipt.execution.worker_progress_frame_count >= 1
          and $receipt.execution.worker_candidate_frame_count == 0
          and $receipt.outcome.operation_counts.mlx_peak_memory_reset_count
            == 1
          and ([ $receipt.outcome.operation_counts
              | to_entries[]
              | select(.key != "mlx_peak_memory_reset_count")
              | .value ] | all(. == 0))
        elif $receipt.outcome.classification == "no_update" then
          $receipt.outcome.update_occurred == false
          and $receipt.execution.worker_candidate_frame_count == 0
        elif $receipt.outcome.classification == "signal" then
          $receipt.execution.worker_signal != null
          and $receipt.execution.worker_candidate_frame_count <= 1
        elif $receipt.outcome.classification == "timeout" then
          ($receipt.execution.worker_timeout_triggered
            or $receipt.execution.supervisor_timeout_triggered)
        else true end)
    ' >/dev/null ||
    fail "Stage-6 receipt is invalid or not exact-source/execution-bound"

readonly receipt_classification="$(printf '%s' "$receipt_json" | \
    jq -r '.outcome.classification')"
if [[ "$receipt_classification" != "lease_busy" ]]; then
    if [[ -e "$lease_path" || -L "$lease_path" ]]; then
        [[ -f "$lease_path" && ! -L "$lease_path" \
            && "$(stat -f %u "$lease_path")" == "$effective_uid" \
            && "$(stat -f %Lp "$lease_path")" == "600" \
            && "$(stat -f %l "$lease_path")" == "1" \
            && "$(stat -f %z "$lease_path")" == "0" ]] ||
            fail "Stage-6 lease file is not safe to reclaim"
        rm -- "$lease_path"
    fi
    [[ -z "$(find "$lease_root" -mindepth 1 -print)" ]] ||
        fail "Stage-6 lease parent contains an unexpected entry"
    rmdir -- "$lease_root"
else
    # Another owner may legitimately hold the nonblocking lock. Never wait,
    # steal, unlink, or claim cleanup proof on this ABSTAIN branch.
    [[ "$(printf '%s' "$receipt_json" | \
        jq -r '.lease.supervisor_reacquire_release_proved')" \
        == "false" ]] ||
        fail "lease_busy receipt fabricated cleanup proof"
fi
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private Stage-6 working directory changed"
rmdir -- "$private_cwd"

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && "$(git -C "$prime_root" rev-parse 'HEAD^{tree}')" == "$exact_tree" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime repository changed during Stage-6"
[[ "$(stat -f %Lp "$staged_metallib")" == "444" \
    && "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
    && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
        == "$metallib_sha256" ]] ||
    fail "staged metallib changed during Stage-6"
cmp -s "$metallib" "$staged_metallib" ||
    fail "staged metallib bytes changed during Stage-6"

echo "OK: exact-main Stage-6 Native-300M resource-only one-step probe produced one validated ${receipt_classification} receipt; no artifact retained or uploaded"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo 'The sole Stage-6 launcher built Release once, ran the frozen pure contract once with --skip-build, and directly invoked the already-built supervisor executable once.'
        echo "The supervisor emitted one validated ${receipt_classification} receipt after child termination and lease disposition; worker transport remained internal."
        echo 'No Actions artifact, checkpoint I/O, quality claim, ordinary-job-fit claim, retry, rerun, Stage 7, trial, canary, product, or publication authority is granted.'
    } >> "$GITHUB_STEP_SUMMARY"
fi
