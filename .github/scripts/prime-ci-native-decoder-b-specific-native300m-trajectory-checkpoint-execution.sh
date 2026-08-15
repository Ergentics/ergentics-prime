#!/usr/bin/env bash
# One exact-main Stage-7 B-specific Native-300M trajectory/checkpoint
# execution. Swift owns the bounded worker/supervisor/verifier topology and
# emits exactly two private frames. This launcher independently validates and
# projects those frames, then alone may publish one final canonical receipt.
# Beginning the sole supervisor invocation consumes the opportunity forever.
set -euo pipefail
IFS=$'\n\t'
umask 077

fail() {
    /usr/bin/printf '%s\n' \
        "prime-ci-native-decoder-b-specific-native300m-trajectory-checkpoint-execution: $*" \
        >&2
    exit 2
}

trap 'exit 130' HUP INT TERM

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"
readonly effective_uid="$(id -u)"
readonly effective_gid="$(id -g)"

readonly required_mlx_origin="https://github.com/Ergentics/ergentics-mlx-swift"
readonly required_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly authority_id="prime_native_decoder_native300m_trajectory_checkpoint_execution_authority_v1"
readonly authority_canonical_sha256="4d995b21a20424f1b05fbcb9fbe33780dbd7af03cbf68047270db4aae192caa4"
readonly candidate_schema_id="ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_candidate_v1"
readonly terminal_schema_id="ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_terminal_v1"
readonly receipt_schema_id="ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_receipt_v1"
readonly receipt_prefix="PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RECEIPT_V1="
readonly candidate_maximum_byte_count="262144"
readonly terminal_maximum_byte_count="65536"
readonly public_receipt_maximum_byte_count="131072"
readonly maximum_frame_chunk_byte_count="16384"
readonly frame_read_deadline_seconds="30"
readonly candidate_schema_key_count="16"
readonly terminal_schema_key_count="10"
readonly public_receipt_schema_key_count="18"
readonly implementation_inventory_count="17"
readonly comparison_domain_count="18"
readonly maximum_tensor_catalog_path_count="218"
readonly resource_phase_count="12"
readonly checkpoint_set_count="3"
readonly semantic_path_projection_count="5"
readonly worker_timeout_seconds="4800"
readonly supervisor_timeout_seconds="5100"
readonly termination_grace_seconds="10"
readonly external_supervisor_failsafe_seconds="5120"
readonly outer_workflow_timeout_seconds="7200"
readonly maximum_pre_one_shot_setup_seconds="1790"
readonly runner_start_and_finalization_reserve_seconds="240"
readonly maximal_public_receipt_fixture_byte_count="54022"

# Terminal green Stage-7 authority closure: exact main / PR 115 / run 127.
readonly authority_closure_revision="300bad298bc9ff6f2752d1409639ff9e99318db6"
readonly authority_closure_tree="d7c57b442e6c9a278b2ab58142ac86cbfa622930"
readonly authority_closure_first_parent="912ca2ab8148255fa588a2a1d336b9dcb1221978"
readonly authority_closure_second_parent="11dd1e6098fba025cae8107284d2c231a9f2ebf8"
readonly authority_closure_reviewed_head="$authority_closure_second_parent"
readonly authority_closure_pull_request_number="115"
readonly authority_closure_run_id="31871108399"
readonly authority_closure_run_number="127"
readonly authority_closure_run_attempt="1"
readonly authority_closure_check_suite_id="86457353564"
readonly authority_closure_active_job_id="94979749298"
readonly authority_closure_active_job_image="macos-15"
readonly authority_closure_active_job_conclusion="success"
readonly authority_closure_reviewed_job_id="94980086476"
readonly authority_closure_reviewed_job_image="macos-26"
readonly authority_closure_reviewed_job_conclusion="success"
readonly authority_closure_event="push"
readonly authority_closure_ref="refs/heads/main"
readonly authority_closure_status="completed"
readonly authority_closure_conclusion="success"
readonly authority_closure_artifact_count="0"
readonly authority_closure_rerun_count="0"
readonly authority_closure_xctest_count="114"
readonly authority_closure_stage7_mechanics_count="0"
readonly authority_closure_stage7_receipt_count="0"

readonly gate_relative_path=".github/scripts/prime-ci-active-root-quarantine.sh"
readonly launcher_relative_path=".github/scripts/prime-ci-native-decoder-b-specific-native300m-trajectory-checkpoint-execution.sh"
readonly workflow_relative_path=".github/workflows/prime-active-root-quarantine.yml"
readonly provenance_relative_path="Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"
readonly checkpoint_source_relative_path="Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderNative300MTrajectoryCheckpointV1.swift"
readonly training_source_relative_path="Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift"
readonly validation_manifest_relative_path="Tests/PrimeNativeDecoderTrainingValidation/Package.swift"
readonly executable_main_relative_path="Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution/main.swift"
readonly contract_test_relative_path="Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionContractTests.swift"
readonly authority_source_relative_path="Sources/PrimeCore/PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthority.swift"
readonly authority_test_relative_path="Tests/PrimeCoreTests/PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityTests.swift"
readonly expected_preserved_index_sha256="ef6d76c7fc23cbbbe4d91fb408516ba605c92b3fd53d07720003d72930d8006f"

readonly validation_root="$prime_root/Tests/PrimeNativeDecoderTrainingValidation"
readonly mlx_bare="$runner_temp/ergentics-mlx-swift.git"
readonly mlx_source="$runner_temp/ergentics-mlx-swift"
readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"
readonly root_numerics_checkout="$runner_temp/prime-active-root-build/checkouts/swift-numerics"
readonly root_numerics_cache="$runner_temp/prime-active-root-build/repositories/swift-numerics-d936ec6c"
readonly stage7_job_epoch_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-job.epoch"

readonly scratch_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-build"
readonly cache_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-cache"
readonly config_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-config"
readonly security_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-security"
readonly private_cwd="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-cwd"
readonly artifact_root="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-artifacts"
readonly lease_root="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-metal-lease"
readonly lease_path="$lease_root/device-0.lock"
readonly launcher_contract_log="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-launcher-contract-tests.log"
readonly supervisor_stdout="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-supervisor.stdout"
readonly supervisor_stderr="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-supervisor.stderr"
readonly supervisor_timeout_marker="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-supervisor.timeout"
readonly candidate_json_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-candidate.json"
readonly candidate_canonical_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-candidate.canonical.json"
readonly terminal_json_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-terminal.json"
readonly terminal_canonical_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-terminal.canonical.json"
readonly trailing_byte_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-trailing-byte"
readonly public_json_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-public.json"
readonly public_canonical_path="$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-public.canonical.json"
readonly contract_class="PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionContractTests"
readonly contract_method="testBSpecificNative300MTrajectoryCheckpointExecutionContractIsExactAndExecutionPure"
readonly contract_filter="${contract_class}/${contract_method}"
readonly expected_root_test_count="62"
readonly expected_isolated_test_count="6"
readonly expected_focused_contract_test_count="1"
readonly expected_focused_whole_test_count="69"
readonly expected_metal_test_count="44"
readonly expected_maintained_runtime_test_count="1"
readonly expected_tokenizer_test_count="1"
readonly expected_launcher_contract_test_count="1"
readonly expected_retained_live_test_count="46"
readonly expected_live_xctest_count="47"
readonly expected_total_xctest_count="116"

[[ "$expected_focused_whole_test_count" -eq \
        $((expected_root_test_count + expected_isolated_test_count \
            + expected_focused_contract_test_count)) \
    && "$expected_retained_live_test_count" -eq \
        $((expected_metal_test_count \
            + expected_maintained_runtime_test_count \
            + expected_tokenizer_test_count)) \
    && "$expected_live_xctest_count" -eq \
        $((expected_retained_live_test_count \
            + expected_launcher_contract_test_count)) \
    && "$expected_total_xctest_count" -eq \
        $((expected_focused_whole_test_count \
            + expected_live_xctest_count)) ]] ||
    fail "frozen Stage-7 successor XCTest accounting changed"

for command_name in awk bash chmod cmp cp date dd dirname env find git grep id \
    jq kill ls mkdir otool ps pwd shasum sleep sort stat swift sw_vers tee tr uname wc \
    xattr xcodebuild xcrun; do
    command -v "$command_name" >/dev/null 2>&1 ||
        fail "missing command: $command_name"
done

[[ "$external_supervisor_failsafe_seconds" -eq \
        $((supervisor_timeout_seconds + (2 * termination_grace_seconds))) \
    && $((maximum_pre_one_shot_setup_seconds \
            + external_supervisor_failsafe_seconds \
            + (5 * termination_grace_seconds))) -eq 6960 \
    && $((maximum_pre_one_shot_setup_seconds \
            + external_supervisor_failsafe_seconds \
            + (5 * termination_grace_seconds) \
            + runner_start_and_finalization_reserve_seconds)) \
        -eq "$outer_workflow_timeout_seconds" ]] ||
    fail "external supervisor containment timing changed"

assert_regular_file() {
    [[ -f "$1" && ! -L "$1" && "$(stat -f %l "$1")" == "1" ]] ||
        fail "required file is missing, linked, or multiply linked: $1"
}

xctest_log_has_failure_or_skip() {
    grep -Eq "^Test Case '[^']+' failed \\(|^Test Suite '[^']+' failed at |^error:|^Test Case '[^']+' skipped \\(| : Test skipped - " "$1"
}

occurrence_count() {
    local needle="$1" source_file="$2"
    awk -v needle="$needle" '
        { line = $0; while ((position = index(line, needle)) > 0) {
            count += 1; line = substr(line, position + length(needle))
        }} END { print count + 0 }
    ' "$source_file"
}

source_identity_json() {
    local repository_root="$1" relative_file="$2"
    local index_record mode blob bytes lf_bytes sha
    index_record="$(git -C "$repository_root" ls-files -s -- "$relative_file")"
    [[ "$(/usr/bin/printf '%s\n' "$index_record" | wc -l | tr -d '[:space:]')" == "1" ]] ||
        fail "source identity index record is not singular: $relative_file"
    mode="$(/usr/bin/printf '%s\n' "$index_record" | awk '{print $1}')"
    blob="$(/usr/bin/printf '%s\n' "$index_record" | awk '{print $2}')"
    assert_regular_file "$repository_root/$relative_file"
    bytes="$(stat -f %z "$repository_root/$relative_file")"
    lf_bytes="$(LC_ALL=C tr -cd '\n' < "$repository_root/$relative_file" | wc -c | tr -d '[:space:]')"
    sha="$(shasum -a 256 "$repository_root/$relative_file" | awk '{print $1}')"
    [[ "$mode" =~ ^100(644|755)$ && "$blob" =~ ^[0-9a-f]{40}$ \
        && "$bytes" =~ ^[1-9][0-9]*$ && "$lf_bytes" =~ ^[1-9][0-9]*$ \
        && "$sha" =~ ^[0-9a-f]{64}$ ]] ||
        fail "source identity is invalid: $relative_file"
    jq -cnS --arg path "$relative_file" --arg mode "$mode" \
        --arg git_blob "$blob" --argjson byte_count "$bytes" \
        --argjson lf_byte_count "$lf_bytes" --arg sha256 "$sha" \
        '{byte_count:$byte_count,git_blob:$git_blob,lf_byte_count:$lf_byte_count,mode:$mode,path:$path,sha256:$sha256}'
}

assert_pinned_file() {
    local relative_file="$1" expected_mode="$2" expected_blob="$3"
    local expected_bytes="$4" expected_lf_bytes="$5" expected_sha="$6"
    local observed
    observed="$(source_identity_json "$prime_root" "$relative_file")"
    /usr/bin/printf '%s' "$observed" | jq -e \
        --arg path "$relative_file" --arg mode "$expected_mode" \
        --arg blob "$expected_blob" --argjson bytes "$expected_bytes" \
        --argjson lf_bytes "$expected_lf_bytes" --arg sha "$expected_sha" \
        '. == {byte_count:$bytes,git_blob:$blob,lf_byte_count:$lf_bytes,mode:$mode,path:$path,sha256:$sha}' \
        >/dev/null || fail "pinned file identity changed: $relative_file"
}

[[ "${GITHUB_ACTIONS:-}" == "true" \
    && "${RUNNER_ENVIRONMENT:-}" == "github-hosted" \
    && "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" \
    && "${GITHUB_WORKFLOW:-}" == "Prime active-root quarantine" \
    && "${GITHUB_JOB:-}" == "trusted-main-stage7" \
    && "${GITHUB_EVENT_NAME:-}" == "push" \
    && "${GITHUB_REF:-}" == "refs/heads/main" \
    && "${GITHUB_RUN_ATTEMPT:-}" == "1" \
    && "${RUNNER_OS:-}" == "macOS" \
    && "${RUNNER_ARCH:-}" == "ARM64" ]] ||
    fail "execution is not the first hosted exact-main push attempt"
[[ "${GITHUB_SHA:-}" == "$exact_revision" \
    && "${GITHUB_WORKFLOW_SHA:-}" == "$exact_revision" \
    && "${GITHUB_RUN_ID:-}" =~ ^[1-9][0-9]*$ \
    && "${GITHUB_RUN_NUMBER:-}" =~ ^[1-9][0-9]*$ \
    && "$exact_revision" =~ ^[0-9a-f]{40}$ \
    && "$mlx_revision" == "$required_mlx_revision" ]] ||
    fail "mechanics workflow identity changed"
[[ -d "$runner_temp" && ! -L "$runner_temp" \
    && "$(cd "$runner_temp" && pwd -P)" == "$runner_temp" ]] ||
    fail "RUNNER_TEMP is not an exact physical directory"
assert_regular_file "$stage7_job_epoch_path"
readonly stage7_job_epoch_device_id="$(stat -f %d "$stage7_job_epoch_path")"
readonly stage7_job_epoch_inode="$(stat -f %i "$stage7_job_epoch_path")"
readonly stage7_job_epoch_byte_count="$(stat -f %z "$stage7_job_epoch_path")"
readonly stage7_job_epoch_sha256="$(shasum -a 256 "$stage7_job_epoch_path" | awk '{print $1}')"
readonly stage7_job_epoch_seconds="$(<"$stage7_job_epoch_path")"
[[ "$stage7_job_epoch_device_id" =~ ^[1-9][0-9]*$ \
    && "$stage7_job_epoch_inode" =~ ^[1-9][0-9]*$ \
    && "$(stat -f %u "$stage7_job_epoch_path")" == "$effective_uid" \
    && "$(stat -f %g "$stage7_job_epoch_path")" == "$effective_gid" \
    && "$(stat -f %Lp "$stage7_job_epoch_path")" == "400" \
    && "$stage7_job_epoch_byte_count" == "11" \
    && "$(wc -l <"$stage7_job_epoch_path" | tr -d '[:space:]')" == "1" \
    && "$stage7_job_epoch_sha256" =~ ^[0-9a-f]{64}$ \
    && "$stage7_job_epoch_seconds" =~ ^[1-9][0-9]{9}$ \
    && "$(date +%s)" -ge "$stage7_job_epoch_seconds" ]] ||
    fail "Stage-7 job epoch file is not exact, immutable, or nonfuture"
[[ -f "${GITHUB_EVENT_PATH:-}" && ! -L "${GITHUB_EVENT_PATH:-}" ]] ||
    fail "push event payload is missing or linked"
jq -e --arg revision "$exact_revision" \
    --arg base "$authority_closure_revision" \
    '.ref == "refs/heads/main"
     and .before == $base
     and .after == $revision
     and .head_commit.id == $revision
     and .repository.full_name == "Ergentics/ergentics-prime"
     and .deleted == false
     and .forced == false' "$GITHUB_EVENT_PATH" >/dev/null ||
    fail "push event is not the direct Stage-7 authority successor"
[[ -z "${ERGENTICS_MLX_READ_TOKEN:-}" ]] ||
    fail "dependency credential reached Stage-7 mechanics"

while IFS='=' read -r inherited_key _; do
    case "$inherited_key" in
        MLX_*|DYLD_*|LLVM_PROFILE_*|GIT_CONFIG_COUNT|GIT_CONFIG_KEY_*|GIT_CONFIG_VALUE_*|PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_*)
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
readonly raw_tree_count="$(/usr/bin/printf '%s\n' "$raw_commit_header" | \
    grep -Ec '^tree [0-9a-f]{40}$')"
readonly raw_parent_count="$(/usr/bin/printf '%s\n' "$raw_commit_header" | \
    grep -Ec '^parent [0-9a-f]{40}$')"
readonly raw_tree="$(/usr/bin/printf '%s\n' "$raw_commit_header" | \
    awk '/^tree / { print $2 }')"
readonly first_parent="$(/usr/bin/printf '%s\n' "$raw_commit_header" | \
    awk '/^parent / { count += 1; if (count == 1) print $2 }')"
readonly second_parent="$(/usr/bin/printf '%s\n' "$raw_commit_header" | \
    awk '/^parent / { count += 1; if (count == 2) print $2 }')"
readonly authority_closure_ordered_parents_json="[\"${authority_closure_first_parent}\",\"${authority_closure_second_parent}\"]"
readonly mechanics_ordered_parents_json="[\"${first_parent}\",\"${second_parent}\"]"
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

readonly exact_successor_paths=(
    "$gate_relative_path"
    "$launcher_relative_path"
    "$workflow_relative_path"
    "$provenance_relative_path"
    "$checkpoint_source_relative_path"
    "$training_source_relative_path"
    "$validation_manifest_relative_path"
    "$executable_main_relative_path"
    "$contract_test_relative_path"
)
readonly observed_preserved_index_sha256="$({
    git -C "$prime_root" ls-files -s |
        while IFS= read -r index_record; do
            relative_file="${index_record#*$'\t'}"
            skip_record=false
            for exact_successor_file in "${exact_successor_paths[@]}"; do
                if [[ "$relative_file" == "$exact_successor_file" ]]; then
                    skip_record=true
                    break
                fi
            done
            [[ "$skip_record" == true ]] ||
                /usr/bin/printf '%s\n' "$index_record"
        done
} | LC_ALL=C sort | shasum -a 256 | awk '{print $1}')"
[[ "$observed_preserved_index_sha256" == "$expected_preserved_index_sha256" ]] ||
    fail "Stage-7 mechanics changed a path outside the exact-nine closure"
for exact_successor_file in "${exact_successor_paths[@]}"; do
    expected_mode="100644"
    case "$exact_successor_file" in
        .github/scripts/*) expected_mode="100755" ;;
    esac
    [[ "$(git -C "$prime_root" ls-files -s -- "$exact_successor_file" | \
        awk '{print $1}')" == "$expected_mode" ]] ||
        fail "exact successor path is missing or has wrong mode: $exact_successor_file"
done

assert_pinned_file "$authority_source_relative_path" \
    "100644" "0f61ed60957106eeb25c760a94422a0f7b78f687" "155828" \
    "2784" "8e61957ffeb1fe3aa312a37201ea87bce5e0999430334f454fbd1b4e1125f075"
assert_pinned_file "$authority_test_relative_path" \
    "100644" "505129d3c8ae319389055fec47c26b8fc2c77cbb" "33247" \
    "783" "1c62d518cf8575c9c82765893322b6a4c107c7e7fed8f3a68fcb77364c65687f"
assert_pinned_file "Package.swift" \
    "100644" "8e14c10aded588b3902a042341bca7acc842bcc6" "32843" \
    "934" "fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81"
assert_pinned_file "Package.resolved" \
    "100644" "14d804bb4291720477240c27e24de6fbdc876b3b" "645" \
    "23" "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375"
assert_pinned_file "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved" \
    "100644" "8bf05edf1ea8789e7683e72fe756d79aaaa61320" "645" \
    "23" "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225"

readonly authority_source_identity_json="$(source_identity_json "$prime_root" "$authority_source_relative_path")"
readonly authority_test_identity_json="$(source_identity_json "$prime_root" "$authority_test_relative_path")"
readonly exact_changed_source_identities_json="$(
    for exact_successor_file in "${exact_successor_paths[@]}"; do
        source_identity_json "$prime_root" "$exact_successor_file"
    done | jq -csS 'sort_by(.path)'
)"
[[ "$(/usr/bin/printf '%s' "$exact_changed_source_identities_json" | jq 'length')" == "9" \
    && "$(/usr/bin/printf '%s' "$exact_changed_source_identities_json" | jq -cS .)" \
        == "$exact_changed_source_identities_json" ]] ||
    fail "exact changed source identity array is invalid"

readonly expected_implementation_inventory_json='[{"byte_count":32843,"git_blob":"8e14c10aded588b3902a042341bca7acc842bcc6","git_mode":"100644","lf_byte_count":934,"path_role":"immutable_root_manifest","sha256":"fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81"},{"byte_count":645,"git_blob":"14d804bb4291720477240c27e24de6fbdc876b3b","git_mode":"100644","lf_byte_count":23,"path_role":"immutable_root_lock","sha256":"bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375"},{"byte_count":2778,"git_blob":"08b732f88ce3be0cd86905df8b78f2492c7ca557","git_mode":"100644","lf_byte_count":92,"path_role":"controlled_successor_validation_manifest_base","sha256":"46fca0c696a46ccc9e22180ca5ec80cffc202a43b68b5f8c9568051e8e71348e"},{"byte_count":645,"git_blob":"8bf05edf1ea8789e7683e72fe756d79aaaa61320","git_mode":"100644","lf_byte_count":23,"path_role":"immutable_validation_lock","sha256":"a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225"},{"byte_count":43339,"git_blob":"de6cff4472de55a8fafe2962c3be4ca37c972caf","git_mode":"100644","lf_byte_count":1193,"path_role":"immutable_decoder_and_b_path","sha256":"ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc"},{"byte_count":97449,"git_blob":"4566477e14b4b6cfa06286f384f07f8d452e8724","git_mode":"100644","lf_byte_count":2444,"path_role":"immutable_training_implementation","sha256":"cab64f1e77d6f72bfef971bb8e1e4c40aee6072c1ed21f3b466599328f88fdcb"},{"byte_count":225960,"git_blob":"cf3d743d121f4eaa028e0e392e04587bcd0b93d8","git_mode":"100644","lf_byte_count":5233,"path_role":"immutable_b_resource_predecessor_implementation","sha256":"77fbe6b5e9548d84af30c95ba4ca0cfa2d03d5e1884c74d0a9ae297b109eed8b"},{"byte_count":9228,"git_blob":"7e993df79cc3a7c37d130c9eb5e7f30f63a6c386","git_mode":"100644","lf_byte_count":193,"path_role":"immutable_v2_compatibility_identity","sha256":"2b73886d067015ea65a71944bdc9d0f06025ee65858e9cfccf9a8f0936cf36f3"},{"byte_count":54880,"git_blob":"105af3f93acf9358e7b66c3a327e45a931deab8b","git_mode":"100644","lf_byte_count":1476,"path_role":"immutable_v2_codec_and_writer","sha256":"39f74373923fcbb56eae5da2038795668c3347115c854a219374d1b797c9761d"},{"byte_count":40522,"git_blob":"f0d010959aaf20fddb755aec7a1b61550dec93dd","git_mode":"100644","lf_byte_count":845,"path_role":"immutable_v2_io_authority","sha256":"8d3626aacfce1fd0350b79872b829df4322695981eaebcf88bc4f38ec2973880"},{"byte_count":144993,"git_blob":"e9e462aa17ae1d4393c77cf953b3c7d44abfcd1e","git_mode":"100644","lf_byte_count":4184,"path_role":"immutable_descriptor_bound_artifact_primitives","sha256":"faa8254ee6ecd97f064a6553efba8158fff6a33fc882607444ba117d56328430"},{"byte_count":16985,"git_blob":"da3daa54802b67dc2c8c04a89b388e9927dd8726","git_mode":"100644","lf_byte_count":534,"path_role":"immutable_metal_device_lease","sha256":"edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657"},{"byte_count":66162,"git_blob":"eb0d6d5be6f8a1381006c7487dc5a56674fda510","git_mode":"100644","lf_byte_count":1983,"path_role":"immutable_typed_optimizer_contract","sha256":"65c7fb2678f4a53aba9b0355929626dd56faea7fcfb1995a74a26f3bf144c5e4"},{"byte_count":45949,"git_blob":"26ac4d40573938c51fb78b0c1d0d8ba8e8ad910b","git_mode":"100644","lf_byte_count":1511,"path_role":"immutable_typed_optimizer_restore_implementation","sha256":"7b1cac142f20eb1a643863f113733546b4a386ee2e935d1d2f8fb3ed6f436b25"},{"byte_count":18388,"git_blob":"74129e24c11a742adb11a80a8e454924426c63ee","git_mode":"100644","lf_byte_count":409,"path_role":"inherited_v2_io_proof","sha256":"f910ae77c7ea54d67f751902168b278bd6a45a5c2deb45618c5f0cb0b6952376"},{"byte_count":13257,"git_blob":"05960c8017147f7a3e1d90fb68d2449bc18698b6","git_mode":"100644","lf_byte_count":451,"path_role":"inherited_lease_proof","sha256":"ebdcd5d62d0d0915a63e82822ba58dc954e209bcaf7905b663b99a4687670018"},{"byte_count":30202,"git_blob":"b78613e392ab20df0d11a2546aadf484e419b75c","git_mode":"100644","lf_byte_count":564,"path_role":"inherited_b_resource_contract_proof","sha256":"fb3abc5d6377867d438b8c48fd9cbeab3549f4570ded7570cf4bc9f585c1d8a7"}]'
[[ "$(/usr/bin/printf '%s' "$expected_implementation_inventory_json" | jq -cS .)" \
        == "$expected_implementation_inventory_json" \
    && "$(/usr/bin/printf '%s' "$expected_implementation_inventory_json" | \
        jq 'length')" == "$implementation_inventory_count" ]] ||
    fail "frozen implementation inventory is noncanonical or incomplete"

readonly embedded_source_identity="$(awk '
    /public static let sourceIdentitySHA256/ {
        getline; gsub(/[ "\t]/, ""); print; exit
    }
' "$prime_root/$provenance_relative_path")"
[[ "$embedded_source_identity" =~ ^[0-9a-f]{64}$ ]] ||
    fail "embedded source identity is not finally pinned"

emit_embedded_source_identity_paths() {
    /usr/bin/printf '%s\n' \
        '.gitignore' \
        '.swiftpm/configuration/mirrors.json' \
        'Tests/PrimeTypedOptimizerRestoreMechanicsValidation/.swiftpm/configuration/mirrors.json' \
        'Tests/PrimeNativeNeuralGateMLXValidation/.swiftpm/configuration/mirrors.json' \
        'Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json' \
        'LICENSE' 'Package.swift' 'Package.resolved' 'README.md' \
        'THIRD_PARTY_NOTICES.md'
    git -C "$prime_root" ls-files -- Sources Tests docs
}

readonly embedded_source_identity_record_count="$(
    emit_embedded_source_identity_paths | LC_ALL=C sort -u |
        grep -Fvx -- "$provenance_relative_path" | wc -l |
        tr -d '[:space:]'
)"
readonly recomputed_embedded_source_identity="$(
    emit_embedded_source_identity_paths | LC_ALL=C sort -u |
        grep -Fvx -- "$provenance_relative_path" |
        while IFS= read -r relative_path; do
            absolute_path="$prime_root/$relative_path"
            assert_regular_file "$absolute_path"
            [[ "$(git -C "$prime_root" ls-files -- "$relative_path")" \
                == "$relative_path" ]] ||
                fail "embedded provenance path is not tracked: $relative_path"
            byte_count="$(stat -f %z "$absolute_path")"
            sha256="$(shasum -a 256 "$absolute_path" | awk '{print $1}')"
            jq -cn --arg relative_path "$relative_path" \
                --arg sha256 "$sha256" --argjson byte_count "$byte_count" \
                '{relative_path:$relative_path,sha256:$sha256,byte_count:$byte_count}'
        done | jq -jcsS '.' | shasum -a 256 | awk '{print $1}'
)"
[[ "$embedded_source_identity_record_count" == "494" \
    && "$recomputed_embedded_source_identity" \
        == "$embedded_source_identity" ]] ||
    fail "embedded source identity does not bind the exact admitted source set"

[[ -d "$mlx_bare" && ! -L "$mlx_bare" \
    && "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" \
        == "$mlx_revision" ]] ||
    fail "MLX bare repository changed"
[[ -d "$mlx_source" && ! -L "$mlx_source" \
    && "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" \
    && "$(git -C "$mlx_source" config --get-all remote.origin.url)" \
        == "$required_mlx_origin" \
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
        == "$numerics_revision" ]] ||
    fail "root Swift Numerics cache topology changed"

metallib=""
metallib_count=0
while IFS= read -r candidate_metallib; do
    metallib="$candidate_metallib"
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

for fresh_file in "$scratch_path" "$cache_path" "$config_path" \
    "$security_path" "$private_cwd" "$artifact_root" "$lease_root" \
    "$launcher_contract_log" "$supervisor_stdout" "$supervisor_stderr" \
    "$supervisor_timeout_marker" \
    "$candidate_json_path" "$candidate_canonical_path" \
    "$terminal_json_path" "$terminal_canonical_path" \
    "$trailing_byte_path" "$public_json_path" "$public_canonical_path"; do
    [[ ! -e "$fresh_file" && ! -L "$fresh_file" ]] ||
        fail "Stage-7 path must be initially absent: $fresh_file"
done
mkdir -p "$cache_path" "$config_path" "$security_path"

export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0="url.file://${mlx_bare}/.insteadOf"
export GIT_CONFIG_VALUE_0="$required_mlx_origin"
export GIT_CONFIG_KEY_1="url.file://${root_numerics_cache}/.insteadOf"
export GIT_CONFIG_VALUE_1="https://github.com/apple/swift-numerics"
export GIT_CONFIG_KEY_2="protocol.file.allow"
export GIT_CONFIG_VALUE_2="always"

# Exactly one Release compilation of the validation products and tests.
TMPDIR="$runner_temp" swift build \
    --package-path "$validation_root" --configuration release --build-tests \
    -Xswiftc -enable-testing \
    --scratch-path "$scratch_path" --cache-path "$cache_path" \
    --config-path "$config_path" --security-path "$security_path" \
    --disable-dependency-cache --manifest-cache local \
    --disable-netrc --disable-keychain --force-resolved-versions --jobs 2

# The launcher's sole pure-contract XCTest start reuses that Release build.
set +e
TMPDIR="$runner_temp" swift test \
    --package-path "$validation_root" --configuration release --skip-build \
    -Xswiftc -enable-testing --filter "$contract_filter" \
    --scratch-path "$scratch_path" --cache-path "$cache_path" \
    --config-path "$config_path" --security-path "$security_path" \
    --disable-dependency-cache --manifest-cache local \
    --disable-netrc --disable-keychain --force-resolved-versions \
    2>&1 | tee "$launcher_contract_log"
contract_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${#contract_pipe_status[@]}" -eq 2 \
    && "${contract_pipe_status[0]}" -eq 0 \
    && "${contract_pipe_status[1]}" -eq 0 ]] ||
    fail "Release pure-contract test or log capture failed"
assert_regular_file "$launcher_contract_log"
[[ "$(grep -Ec '^Test Case .* started\.$' "$launcher_contract_log")" == "1" \
    && "$(grep -Ec '^Test Case .* passed \(' "$launcher_contract_log")" == "1" \
    && "$(grep -Ec '^Test Case .* failed \(' "$launcher_contract_log")" == "0" \
    && "$(grep -Eic '^Test Case .* skipped \(' "$launcher_contract_log")" == "0" \
    && "$(grep -Fc -- "$contract_class" "$launcher_contract_log")" -ge 1 \
    && "$(grep -Fc -- "$contract_method" "$launcher_contract_log")" -ge 1 ]] ||
    fail "Release pure-contract XCTest inventory changed"
! xctest_log_has_failure_or_skip "$launcher_contract_log" ||
    fail "Release pure-contract XCTest failed or skipped"

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
readonly executable="$bin_path/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution"
readonly staged_metallib="$bin_path/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
readonly runtime_metallib="$staged_metallib"
[[ -x "$executable" && -f "$executable" && ! -L "$executable" \
    && "$(stat -f %l "$executable")" == "1" ]] ||
    fail "Release Stage-7 executable is missing or aliased"
for framework in CoreGraphics Metal; do
    otool -L "$executable" | grep -Fq "/${framework}.framework/" ||
        fail "Release Stage-7 executable does not link ${framework}"
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

mkdir -p "$private_cwd" "$artifact_root" "$lease_root"
chmod 700 "$private_cwd" "$artifact_root" "$lease_root"
for private_directory in "$private_cwd" "$artifact_root" "$lease_root"; do
    [[ -d "$private_directory" && ! -L "$private_directory" \
        && "$(cd "$private_directory" && pwd -P)" == "$private_directory" \
        && "$(stat -f %u "$private_directory")" == "$effective_uid" \
        && "$(stat -f %Lp "$private_directory")" == "700" \
        && -z "$(find "$private_directory" -mindepth 1 -print)" ]] ||
        fail "private Stage-7 directory is invalid: $private_directory"
done

readonly operating_system_build="$(sw_vers -productVersion)-$(sw_vers -buildVersion)"
readonly kernel_identity="$(uname -srvmp)"
readonly swift_toolchain="$(swift --version | tr '\n' ' ' | awk '{$1=$1; print}')"
readonly xcode_toolchain="$(xcodebuild -version | tr '\n' ' ' | awk '{$1=$1; print}')"
readonly macos_sdk="$(xcrun --sdk macosx --show-sdk-version)"

# The job-level 120-minute boundary starts before the first shell command.
# The workflow authors this read-only epoch file in that first command; the
# 240-second unobserved runner/finalization reserve is part of the 7,200-second
# bound.  Refuse to consume the one-shot unless worst-case external
# containment still completes inside that bound.
assert_regular_file "$stage7_job_epoch_path"
readonly pre_one_shot_epoch_seconds="$(date +%s)"
[[ "$pre_one_shot_epoch_seconds" =~ ^[1-9][0-9]{9}$ \
    && "$pre_one_shot_epoch_seconds" -ge "$stage7_job_epoch_seconds" ]] ||
    fail "pre-one-shot wall clock is invalid"
readonly pre_one_shot_setup_elapsed_seconds="$((
    pre_one_shot_epoch_seconds - stage7_job_epoch_seconds
))"
[[ "$(stat -f %d "$stage7_job_epoch_path")" \
        == "$stage7_job_epoch_device_id" \
    && "$(stat -f %i "$stage7_job_epoch_path")" \
        == "$stage7_job_epoch_inode" \
    && "$(stat -f %u "$stage7_job_epoch_path")" == "$effective_uid" \
    && "$(stat -f %g "$stage7_job_epoch_path")" == "$effective_gid" \
    && "$(stat -f %Lp "$stage7_job_epoch_path")" == "400" \
    && "$(stat -f %z "$stage7_job_epoch_path")" \
        == "$stage7_job_epoch_byte_count" \
    && "$(shasum -a 256 "$stage7_job_epoch_path" | awk '{print $1}')" \
        == "$stage7_job_epoch_sha256" \
    && "$(<"$stage7_job_epoch_path")" == "$stage7_job_epoch_seconds" \
    && "$pre_one_shot_setup_elapsed_seconds" -le \
        "$maximum_pre_one_shot_setup_seconds" \
    && $((pre_one_shot_setup_elapsed_seconds \
            + external_supervisor_failsafe_seconds \
            + (5 * termination_grace_seconds))) -le 6960 \
    && $((pre_one_shot_setup_elapsed_seconds \
            + external_supervisor_failsafe_seconds \
            + (5 * termination_grace_seconds) \
            + runner_start_and_finalization_reserve_seconds)) \
        -le "$outer_workflow_timeout_seconds" ]] ||
    fail "Stage-7 setup consumed the one-shot containment budget"

# The one-shot boundary is immediately before this sole supervisor invocation
# and before any lease acquisition. No retry, rerun, or replacement exists.
descendant_process_groups() {
    local root_pid="$1"
    ps -axo pid=,ppid=,pgid= | awk -v root="$root_pid" '
      {
        parent[$1] = $2
        process_group[$1] = $3
        ordered_pid[++count] = $1
      }
      END {
        for (index = 1; index <= count; index += 1) {
          pid = ordered_pid[index]
          cursor = pid
          depth = 0
          while (cursor != root && (cursor in parent) && depth <= count) {
            cursor = parent[cursor]
            depth += 1
          }
          if (pid != root && cursor == root) {
            print pid, process_group[pid]
          }
        }
      }
    '
}

process_group_exists() {
    local process_group_id="$1"
    ps -axo pgid= | awk -v expected="$process_group_id" '
      $1 == expected { found = 1 }
      END { exit(found ? 0 : 1) }
    '
}

process_group_has_live_process() {
    local process_group_id="$1"
    ps -axo pgid=,state= | awk -v expected="$process_group_id" '
      $1 == expected && $2 !~ /^Z/ { found = 1 }
      END { exit(found ? 0 : 1) }
    '
}

set +e
(
    cd "$private_cwd"
    exec env \
        TMPDIR="$runner_temp" \
        MLX_ENABLE_TF32=0 \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_EXECUTABLE_PATH="$executable" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_LEASE_ROOT="$lease_root" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_ARTIFACT_ROOT="$artifact_root" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_STAGED_METALLIB_PATH="$staged_metallib" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_STAGED_METALLIB_BYTES="$metallib_byte_count" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_STAGED_METALLIB_SHA256="$metallib_sha256" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RUNTIME_METALLIB_PATH="$runtime_metallib" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RUNTIME_METALLIB_BYTES="$metallib_byte_count" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RUNTIME_METALLIB_SHA256="$metallib_sha256" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_OPERATING_SYSTEM_BUILD="$operating_system_build" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_XCODE_BUILD="$xcode_toolchain" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_SWIFT_DRIVER="$swift_toolchain" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_SWIFT_SDK="$macos_sdk" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_BUILD_CONFIGURATION="release" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_EXACT_MLX_ORIGIN="$required_mlx_origin" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_EXACT_MLX_REVISION="$mlx_revision" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_ID="$authority_id" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CANONICAL_SHA256="$authority_canonical_sha256" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_REVISION="$authority_closure_revision" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_TREE="$authority_closure_tree" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_ORDERED_PARENTS_JSON="$authority_closure_ordered_parents_json" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_RUN_ID="$authority_closure_run_id" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_RUN_NUMBER="$authority_closure_run_number" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_RUN_ATTEMPT="$authority_closure_run_attempt" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_CHECK_SUITE_ID="$authority_closure_check_suite_id" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_ACTIVE_JOB_ID="$authority_closure_active_job_id" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_REVIEWED_JOB_ID="$authority_closure_reviewed_job_id" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_REVISION="$exact_revision" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_TREE="$exact_tree" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_ORDERED_PARENTS_JSON="$mechanics_ordered_parents_json" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_RUN_ID="$GITHUB_RUN_ID" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_RUN_NUMBER="$GITHUB_RUN_NUMBER" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_RUN_ATTEMPT="$GITHUB_RUN_ATTEMPT" \
        PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_IMPLEMENTATION_INVENTORY_JSON="$expected_implementation_inventory_json" \
        "$executable"
) >"$supervisor_stdout" 2>"$supervisor_stderr" &
readonly supervisor_pid="$!"
(
    sleep "$external_supervisor_failsafe_seconds"
    if kill -0 "$supervisor_pid" 2>/dev/null; then
        /usr/bin/printf '%s\n' \
            "external_supervisor_failsafe_containment_started" \
            >"$supervisor_timeout_marker"

        child_process_groups=()
        containment_invalid=0
        supervisor_process_group_id="$(
            ps -o pgid= -p "$supervisor_pid" | awk '{$1=$1; print}'
        )"
        [[ "$supervisor_process_group_id" =~ ^[1-9][0-9]*$ ]] ||
            containment_invalid=1
        capture_descendant_process_groups() {
            local descendant_pid descendant_group observed_group
            local known_group
            while read -r descendant_pid descendant_group; do
                [[ "$descendant_pid" =~ ^[1-9][0-9]*$ \
                    && "$descendant_group" =~ ^[1-9][0-9]*$ \
                    && "$descendant_pid" != "$supervisor_pid" \
                    && "$descendant_group" \
                        != "$supervisor_process_group_id" ]] || {
                    containment_invalid=1
                    continue
                }
                known_group=false
                for observed_group in "${child_process_groups[@]}"; do
                    if [[ "$observed_group" == "$descendant_group" ]]; then
                        known_group=true
                        break
                    fi
                done
                if [[ "$known_group" == false ]]; then
                    child_process_groups+=("$descendant_group")
                fi
            done < <(descendant_process_groups "$supervisor_pid")
        }
        stop_captured_child_process_groups() {
            local child_process_group
            for child_process_group in "${child_process_groups[@]}"; do
                kill -STOP -- "-$child_process_group" 2>/dev/null || true
            done
        }

        # Capture once to preserve an existing child group across a possible
        # supervisor-exit race. Then freeze the supervisor before signaling
        # any child group and repeatedly close its exact PPID descendant set.
        # Each Swift child is a separate process-group leader.
        capture_descendant_process_groups
        kill -STOP "$supervisor_pid" 2>/dev/null || containment_invalid=1
        supervisor_stopped=false
        supervisor_observed_state=""
        for stop_observation_attempt in 0 1 2 3 4 5 6 7 8 9 10; do
            supervisor_observed_state="$(
                ps -o state= -p "$supervisor_pid" 2>/dev/null |
                    awk '{$1=$1; print}'
            )"
            if [[ "$supervisor_observed_state" =~ ^T ]]; then
                supervisor_stopped=true
                break
            fi
            if [[ "$stop_observation_attempt" -eq 10 ]] ||
                ! kill -0 "$supervisor_pid" 2>/dev/null; then
                break
            fi
            sleep 1
        done
        [[ "$supervisor_stopped" == true ]] || containment_invalid=1
        capture_descendant_process_groups
        capture_descendant_process_groups
        stop_captured_child_process_groups
        capture_descendant_process_groups
        stop_captured_child_process_groups

        for child_process_group in "${child_process_groups[@]}"; do
            kill -TERM -- "-$child_process_group" 2>/dev/null || true
            kill -CONT -- "-$child_process_group" 2>/dev/null || true
        done
        sleep "$termination_grace_seconds"
        capture_descendant_process_groups
        stop_captured_child_process_groups
        for child_process_group in "${child_process_groups[@]}"; do
            kill -KILL -- "-$child_process_group" 2>/dev/null || true
        done

        # With the supervisor still frozen, no non-zombie child may remain.
        # A killed child can remain as a stopped-parent-owned zombie until the
        # supervisor is resumed or killed, so that state is proved separately
        # from the final all-process-group absence proof below.
        for proof_attempt in 1 2 3 4 5 6 7 8 9 10; do
            remaining_live_child=false
            for child_process_group in "${child_process_groups[@]}"; do
                if process_group_has_live_process "$child_process_group"; then
                    remaining_live_child=true
                    break
                fi
            done
            [[ "$remaining_live_child" == false ]] && break
            sleep 1
        done
        for child_process_group in "${child_process_groups[@]}"; do
            if process_group_has_live_process "$child_process_group"; then
                containment_invalid=1
            fi
        done

        # Only after every captured child group has received KILL and has no
        # live process may the stopped supervisor be terminated and resumed.
        kill -TERM "$supervisor_pid" 2>/dev/null || true
        kill -CONT "$supervisor_pid" 2>/dev/null || true
        sleep "$termination_grace_seconds"
        kill -KILL "$supervisor_pid" 2>/dev/null || true

        for proof_attempt in 1 2 3 4 5 6 7 8 9 10; do
            remaining_group=false
            for child_process_group in "${child_process_groups[@]}"; do
                if process_group_exists "$child_process_group"; then
                    remaining_group=true
                    break
                fi
            done
            [[ "$remaining_group" == false ]] && break
            sleep 1
        done
        for child_process_group in "${child_process_groups[@]}"; do
            if process_group_exists "$child_process_group"; then
                containment_invalid=1
            fi
        done
        [[ "$containment_invalid" -eq 0 ]] ||
            /usr/bin/printf '%s\n' \
                "external_supervisor_failsafe_containment_failed" \
                >>"$supervisor_timeout_marker"
    fi
) &
readonly supervisor_watchdog_pid="$!"
wait "$supervisor_pid"
supervisor_status="$?"
if [[ -e "$supervisor_timeout_marker" \
    || -L "$supervisor_timeout_marker" ]]; then
    wait "$supervisor_watchdog_pid" 2>/dev/null || true
else
    kill -TERM "$supervisor_watchdog_pid" 2>/dev/null || true
    wait "$supervisor_watchdog_pid" 2>/dev/null || true
fi
set -e

[[ ! -e "$supervisor_timeout_marker" \
    && ! -L "$supervisor_timeout_marker" ]] ||
    fail "sole supervisor exceeded its operational timeout"
[[ "$supervisor_status" -eq 0 ]] ||
    fail "sole supervisor invocation did not exit zero"
assert_regular_file "$supervisor_stdout"
assert_regular_file "$supervisor_stderr"
[[ "$(occurrence_count "$receipt_prefix" "$supervisor_stdout")" == "0" \
    && "$(occurrence_count "$receipt_prefix" "$supervisor_stderr")" == "0" \
    && "$(occurrence_count "$receipt_prefix" "$launcher_contract_log")" == "0" ]] ||
    fail "Swift or the pure contract emitted a public receipt"
[[ ! -s "$supervisor_stderr" ]] ||
    fail "sole supervisor emitted unexpected stderr"

read_private_frame() {
    local frame_descriptor="$1" destination="$2" canonical_destination="$3"
    local maximum_count="$4" frame_role="$5"
    local declared_count declared_sha remaining chunk_count observed_count
    local previous_count
    local observed_sha

    IFS= read -r -t "$frame_read_deadline_seconds" \
        -u "$frame_descriptor" declared_count ||
        fail "$frame_role frame length is absent or missed its deadline"
    [[ "$declared_count" =~ ^(0|[1-9][0-9]*)$ \
        && "$declared_count" -gt 0 \
        && "$declared_count" -le "$maximum_count" ]] ||
        fail "$frame_role frame length is noncanonical or out of bounds"

    : > "$destination"
    remaining="$declared_count"
    while [[ "$remaining" -gt 0 ]]; do
        chunk_count="$remaining"
        if [[ "$chunk_count" -gt "$maximum_frame_chunk_byte_count" ]]; then
            chunk_count="$maximum_frame_chunk_byte_count"
        fi
        previous_count="$(stat -f %z "$destination")"
        dd bs="$chunk_count" count=1 <&"$frame_descriptor" \
            >>"$destination" 2>/dev/null ||
            fail "$frame_role frame payload read failed"
        observed_count="$(stat -f %z "$destination")"
        [[ "$observed_count" -gt "$previous_count" \
            && "$observed_count" -le "$declared_count" ]] ||
            fail "$frame_role frame ended early or exceeded its declaration"
        remaining=$((declared_count - observed_count))
    done
    [[ "$(stat -f %z "$destination")" == "$declared_count" ]] ||
        fail "$frame_role frame ended before its declared byte count"

    IFS= read -r -t "$frame_read_deadline_seconds" \
        -u "$frame_descriptor" declared_sha ||
        fail "$frame_role frame SHA-256 is absent or missed its deadline"
    [[ "$declared_sha" =~ ^[0-9a-f]{64}$ ]] ||
        fail "$frame_role frame SHA-256 is malformed"
    observed_sha="$(shasum -a 256 "$destination" | awk '{print $1}')"
    [[ "$observed_sha" == "$declared_sha" ]] ||
        fail "$frame_role frame SHA-256 does not match before decode"

    jq -cSj . "$destination" >"$canonical_destination" ||
        fail "$frame_role frame is not JSON"
    cmp -s "$destination" "$canonical_destination" ||
        fail "$frame_role frame JSON is not canonical sorted-key UTF-8"
}

exec 9<"$supervisor_stdout"
read_private_frame 9 "$candidate_json_path" "$candidate_canonical_path" \
    "$candidate_maximum_byte_count" "candidate"
read_private_frame 9 "$terminal_json_path" "$terminal_canonical_path" \
    "$terminal_maximum_byte_count" "terminal"
: > "$trailing_byte_path"
dd bs=1 count=1 <&9 >"$trailing_byte_path" 2>/dev/null || true
exec 9<&-
[[ ! -s "$trailing_byte_path" ]] ||
    fail "private frame stream contains trailing bytes"

readonly candidate_byte_count="$(stat -f %z "$candidate_json_path")"
readonly candidate_sha256="$(shasum -a 256 "$candidate_json_path" | awk '{print $1}')"
readonly terminal_byte_count="$(stat -f %z "$terminal_json_path")"
readonly terminal_sha256="$(shasum -a 256 "$terminal_json_path" | awk '{print $1}')"

sha256_utf8() {
    /usr/bin/printf '%s' "$1" | shasum -a 256 | awk '{print $1}'
}

candidate_configured_memory_limit_bytes="$(
    jq -er '
      .device_and_stream.configured_memory_limit_bytes as $value
      | if ($value | type == "number" and . > 0 and . == floor) then
          ($value | tostring)
        else error("invalid configured memory observation") end
    ' "$candidate_json_path"
)" || fail "candidate configured-memory observation is unavailable"
readonly candidate_configured_memory_limit_bytes
candidate_preflight_filesystem_available_bytes="$(
    jq -er '
      .resource_phases[0].filesystem_available_bytes as $value
      | if ($value | type == "number" and . >= 0 and . == floor) then
          ($value | tostring)
        else error("invalid filesystem availability observation") end
    ' "$candidate_json_path"
)" || fail "candidate filesystem-availability observation is unavailable"
readonly candidate_preflight_filesystem_available_bytes
candidate_last_mlx_peak_bytes="$(
    jq -er '
      (.resource_phases[-1].mlx_peak_bytes // 0) as $value
      | if ($value | type == "number" and . >= 0 and . == floor) then
          ($value | tostring)
        else error("invalid final MLX peak observation") end
    ' "$candidate_json_path"
)" || fail "candidate final MLX-peak observation is unavailable"
readonly candidate_last_mlx_peak_bytes
candidate_last_elapsed_nanoseconds="$(
    jq -er '
      (.resource_phases[-1].cumulative_elapsed_nanoseconds // 0) as $value
      | if ($value | type == "number" and . >= 0 and . == floor) then
          ($value | tostring)
        else error("invalid final elapsed-time observation") end
    ' "$candidate_json_path"
)" || fail "candidate final elapsed-time observation is unavailable"
readonly candidate_last_elapsed_nanoseconds
readonly memory_floor_expected_binding="$(
    sha256_utf8 'minimum_memory_limit_floor_bytes=4337713152'
)"
readonly memory_floor_observed_binding="$(
    sha256_utf8 \
        "configured_memory_limit_bytes=${candidate_configured_memory_limit_bytes}"
)"
readonly filesystem_floor_expected_binding="$(
    sha256_utf8 'available_filesystem_floor_bytes=12884901888'
)"
readonly filesystem_floor_observed_binding="$(
    sha256_utf8 \
        "filesystem_available_bytes=${candidate_preflight_filesystem_available_bytes}"
)"
readonly enomem_observed_binding="$(sha256_utf8 'errno=12')"
readonly enospc_observed_binding="$(sha256_utf8 'errno=28')"
readonly mlx_memory_limit_observed_binding="$(
    sha256_utf8 \
        "configured_memory_limit_bytes=${candidate_configured_memory_limit_bytes};mlx_peak_bytes=${candidate_last_mlx_peak_bytes};positively_identified_mlx_memory_limit_exhaustion=true"
)"
readonly worker_timeout_observed_binding="$(
    sha256_utf8 \
        "timeout_role=worker;deadline_seconds=${worker_timeout_seconds};elapsed_nanoseconds=${candidate_last_elapsed_nanoseconds};contained=true;cleanup_absence=true"
)"

readonly lease_root_path_sha256="$(sha256_utf8 "$lease_root")"
readonly lease_path_sha256="$(sha256_utf8 "$lease_path")"
readonly artifact_root_path_sha256="$(sha256_utf8 "$artifact_root")"
readonly staged_metallib_path_sha256="$(sha256_utf8 "$staged_metallib")"
readonly runtime_metallib_path_sha256="$(sha256_utf8 "$runtime_metallib")"
readonly exact_operation_counts_json='{"backward_count":3,"checked_read_only_evaluation_count":3,"cross_entropy_count":6,"deferred_optimizer_moment_load_count":1,"dense_b_path_logits_call_count":6,"dense_one_hot_matmul_construction_count":6,"evaluation_forward_pass_count":3,"final_commit_publication_count":3,"forward_loss_count":6,"gradient_catalog_release_count":3,"gradient_evidence_capture_count":2,"leaf_publication_count":12,"maximum_public_receipt_count":1,"model_allocation_and_materialization_count":5,"optimizer_allocation_count":2,"optimizer_moment_publish_count":3,"optimizer_update_count":3,"public_restore_load_count":1,"release_verifier_process_count":1,"resource_measurement_checked_eval_count":8,"resource_measurement_synchronize_count":12,"supervisor_process_count":1,"token_bounds_checked_eval_count":6,"token_bounds_gpu_synchronize_count":6,"token_bounds_host_bool_item_count":6,"token_bounds_validation_count":6,"training_mode_disable_count":3,"training_mode_restore_count":3,"training_step_count":3,"typed_optimizer_state_import_count":1,"v2_internal_verification_load_count":3,"v2_weights_write_count":3,"worker_process_count":1}'
readonly comparison_domain_contracts_json='[{"catalog_preimage_schema":"exact_decoder_parameter_catalog_v1","domain_id":"snapshot_weights","kind":"tensor_catalog","path_count":218},{"catalog_preimage_schema":"role_prefixed_first_moment_parameter_catalog_v1","domain_id":"snapshot_optimizer_first_moments","kind":"tensor_catalog","path_count":218},{"catalog_preimage_schema":"role_prefixed_second_moment_parameter_catalog_v1","domain_id":"snapshot_optimizer_second_moments","kind":"tensor_catalog","path_count":218},{"catalog_preimage_schema":"baseline_control_required_fields_v1","domain_id":"snapshot_full_canonical_control_state_roundtrip","kind":"control","path_count":13},{"catalog_preimage_schema":"frozen_batch2_token_and_mask_sha256_v1","domain_id":"batch2_token_and_mask_digest","kind":"digest","path_count":1},{"catalog_preimage_schema":"loss_scalar_per_target_tensor_whole_logits_shape_1x128x512_float32_v1","domain_id":"successor_loss_per_target_and_whole_logits_bits","kind":"scalar_and_tensor","path_count":3},{"catalog_preimage_schema":"exact_decoder_parameter_catalog_v1","domain_id":"successor_raw_gradient_bytes","kind":"tensor_catalog","path_count":218},{"catalog_preimage_schema":"exact_decoder_parameter_catalog_v1","domain_id":"successor_clipped_gradient_bytes","kind":"tensor_catalog","path_count":218},{"catalog_preimage_schema":"raw_norm_float32_bits_v1","domain_id":"successor_raw_norm_bits","kind":"scalar","path_count":1},{"catalog_preimage_schema":"clipped_global_norm_float32_bits_v1","domain_id":"successor_clipped_global_norm_bits","kind":"scalar","path_count":1},{"catalog_preimage_schema":"clip_scale_float32_bits_v1","domain_id":"successor_clip_scale_bits","kind":"scalar","path_count":1},{"catalog_preimage_schema":"exact_decoder_parameter_catalog_v1","domain_id":"successor_post_update_parameter_bytes","kind":"tensor_catalog","path_count":218},{"catalog_preimage_schema":"role_prefixed_first_moment_parameter_catalog_v1","domain_id":"successor_optimizer_first_moment_bytes","kind":"tensor_catalog","path_count":218},{"catalog_preimage_schema":"role_prefixed_second_moment_parameter_catalog_v1","domain_id":"successor_optimizer_second_moment_bytes","kind":"tensor_catalog","path_count":218},{"catalog_preimage_schema":"evaluation_required_paths_v1","domain_id":"successor_checked_evaluation_state_and_read_only_nonmutation","kind":"scalar_and_tensor","path_count":8},{"catalog_preimage_schema":"optimizer_terminal_control_fields_v1","domain_id":"optimizer_global_step_schedule_and_current_learning_rate_bits","kind":"control","path_count":5},{"catalog_preimage_schema":"four_explicit_rng_domain_records_v1","domain_id":"explicit_rng_algorithm_domain_key_counter_and_consumption_digest","kind":"control","path_count":4},{"catalog_preimage_schema":"terminal_cursor_and_zero_state_fields_v1","domain_id":"cursor_and_snapshot_boundary_zero_state","kind":"control","path_count":8}]'
readonly fixed_comparison_member_paths_json='{"batch2_token_and_mask_digest":["token_and_mask_sha256"],"cursor_and_snapshot_boundary_zero_state":["terminal_data_cursor","accumulation_phase","pending_gradient_count","pending_prefetch_count","kv_cache_entry_count","snapshot_boundary_consumed_once","evaluation_did_not_advance_cursor","decoder_training_mode_true"],"explicit_rng_algorithm_domain_key_counter_and_consumption_digest":["rng_domains.model_initialization_v1","rng_domains.training_data_order_v1","rng_domains.augmentation_v1","rng_domains.evaluation_v1"],"optimizer_global_step_schedule_and_current_learning_rate_bits":["global_step","initial_global_step","snapshot_global_step","schedule_id","current_learning_rate_float32_bits"],"snapshot_full_canonical_control_state_roundtrip":["role","global_step","schedule_id","current_learning_rate_float32_bits","rng_domains","data_cursor","snapshot_boundary","checked_evaluation_complete","accumulation_phase","pending_gradient_count","pending_prefetch_count","kv_cache_entry_count","decoder_training_mode_true"],"successor_checked_evaluation_state_and_read_only_nonmutation":["loss_float32_bits","per_target_loss_tensor_shape_1x127_float32","whole_logits_tensor_shape_1x128x512_float32","pre_model_catalog_binding","post_model_catalog_binding","pre_post_optimizer_catalog_binding","pre_post_control_binding","training_mode_restored_true"],"successor_clip_scale_bits":["clip_scale_float32_bits"],"successor_clipped_global_norm_bits":["clipped_global_norm_float32_bits"],"successor_loss_per_target_and_whole_logits_bits":["loss_float32_bits","per_target_loss_tensor_shape_1x127_float32","whole_logits_tensor_shape_1x128x512_float32"],"successor_raw_norm_bits":["raw_norm_float32_bits"]}'
[[ "$(/usr/bin/printf '%s' "$exact_operation_counts_json" | jq -cS .)" \
        == "$exact_operation_counts_json" \
    && "$(/usr/bin/printf '%s' "$exact_operation_counts_json" | \
        jq 'keys | length')" == "33" \
    && "$(/usr/bin/printf '%s' "$comparison_domain_contracts_json" | \
        jq -cS .)" == "$comparison_domain_contracts_json" \
    && "$(/usr/bin/printf '%s' "$comparison_domain_contracts_json" | \
        jq 'length')" == "$comparison_domain_count" ]] ||
    fail "frozen operation-count or comparison-domain contract is invalid"
[[ "$(/usr/bin/printf '%s' "$fixed_comparison_member_paths_json" | \
        jq -cS .)" == "$fixed_comparison_member_paths_json" \
    && "$(/usr/bin/printf '%s' "$fixed_comparison_member_paths_json" | \
        jq 'keys | length')" == "10" ]] ||
    fail "frozen fixed comparison-member contract is invalid"

# The launcher independently validates the complete private candidate before
# reading or trusting any field for public projection.
/usr/bin/printf '%s' "$(<"$candidate_json_path")" | jq -e \
    --arg schema "$candidate_schema_id" \
    --arg authority "$authority_id" \
    --arg canonical "$authority_canonical_sha256" \
    --arg predecessor "$authority_closure_first_parent" \
    --arg closure_revision "$authority_closure_revision" \
    --arg closure_tree "$authority_closure_tree" \
    --argjson closure_parents "$authority_closure_ordered_parents_json" \
    --argjson closure_run_id "$authority_closure_run_id" \
    --argjson closure_run_number "$authority_closure_run_number" \
    --argjson closure_attempt "$authority_closure_run_attempt" \
    --argjson closure_suite "$authority_closure_check_suite_id" \
    --argjson closure_active_job "$authority_closure_active_job_id" \
    --argjson closure_reviewed_job "$authority_closure_reviewed_job_id" \
    --arg mechanics_revision "$exact_revision" \
    --arg mechanics_tree "$exact_tree" \
    --argjson mechanics_parents "$mechanics_ordered_parents_json" \
    --argjson mechanics_run_id "$GITHUB_RUN_ID" \
    --argjson mechanics_run_number "$GITHUB_RUN_NUMBER" \
    --argjson mechanics_attempt "$GITHUB_RUN_ATTEMPT" \
    --argjson inventory "$expected_implementation_inventory_json" \
    --argjson exact_counts "$exact_operation_counts_json" \
    --argjson domain_contracts "$comparison_domain_contracts_json" \
    --argjson fixed_member_paths "$fixed_comparison_member_paths_json" \
    --arg mlx_origin "$required_mlx_origin" \
    --arg mlx_revision "$mlx_revision" \
    --arg os_build "$operating_system_build" \
    --arg xcode_build "$xcode_toolchain" \
    --arg swift_driver "$swift_toolchain" \
    --arg swift_sdk "$macos_sdk" \
    --arg staged_path_sha "$staged_metallib_path_sha256" \
    --arg runtime_path_sha "$runtime_metallib_path_sha256" \
    --arg artifact_root_sha "$artifact_root_path_sha256" \
    --argjson metallib_bytes "$metallib_byte_count" \
    --arg metallib_sha "$metallib_sha256" \
    --arg lease_root "$lease_root" \
    --arg lease_path "$lease_path" \
    --arg artifact_root "$artifact_root" \
    --arg staged_path "$staged_metallib" \
    --arg runtime_path "$runtime_metallib" \
    --arg memory_floor_expected "$memory_floor_expected_binding" \
    --arg memory_floor_observed "$memory_floor_observed_binding" \
    --arg filesystem_floor_expected "$filesystem_floor_expected_binding" \
    --arg filesystem_floor_observed "$filesystem_floor_observed_binding" \
    --arg enomem_observed "$enomem_observed_binding" \
    --arg enospc_observed "$enospc_observed_binding" \
    --arg mlx_memory_limit_observed "$mlx_memory_limit_observed_binding" \
    --arg worker_timeout_observed "$worker_timeout_observed_binding" \
    '
      def exact_keys($expected): keys == ($expected | sort);
      def uint:
        type == "number" and . >= 0 and . == floor;
      def positive_uint: uint and . > 0;
      def hex40:
        type == "string" and test("^[0-9a-f]{40}$");
      def hex64:
        type == "string" and test("^[0-9a-f]{64}$");
      def nullable_hex64: . == null or hex64;
      def bool: type == "boolean";
      def native300_parameter_path:
        type == "string" and test(
          "^(token_embedding\\.weight|final_norm\\.weight|layers\\.(0|[1-9]|1[0-9]|2[0-3])\\.(attention\\.(key_projection|output_projection|query_projection|value_projection)\\.weight|attention_norm\\.weight|feed_forward\\.(down_projection|gate_projection|up_projection)\\.weight|feed_forward_norm\\.weight))$");
      def exact_catalog_member_path($domain; $path):
        if ([
              "snapshot_weights","successor_raw_gradient_bytes",
              "successor_clipped_gradient_bytes",
              "successor_post_update_parameter_bytes"
            ] | index($domain)) != null then
          ($path | native300_parameter_path)
        elif ([
              "snapshot_optimizer_first_moments",
              "successor_optimizer_first_moment_bytes"
            ] | index($domain)) != null then
          ($path | startswith("first_moment."))
          and ($path | ltrimstr("first_moment.")
            | native300_parameter_path)
        elif ([
              "snapshot_optimizer_second_moments",
              "successor_optimizer_second_moment_bytes"
            ] | index($domain)) != null then
          ($path | startswith("second_moment."))
          and ($path | ltrimstr("second_moment.")
            | native300_parameter_path)
        else false end;
      def exact_or_null($keys):
        . == null or (type == "object" and exact_keys($keys));
      def metallib_binding($role; $path_sha):
        exact_keys([
          "semantic_role","path_sha256","byte_count","content_sha256"
        ])
        and .semantic_role == $role
        and .path_sha256 == $path_sha
        and .byte_count == $metallib_bytes
        and .content_sha256 == $metallib_sha;
      def leaf_binding:
        exact_keys(["role","publication_ordinal","byte_count","sha256"])
        and (.role == "weights_v2"
          or .role == "optimizer_moments"
          or .role == "control_state_manifest"
          or .role == "commit_manifest")
        and (.publication_ordinal | positive_uint)
        and (.byte_count | positive_uint)
        and (.sha256 | hex64);
      def external_v2:
        exact_keys([
          "schema_id","compatibility_identity_sha256",
          "artifact_semantic_role","artifact_path_sha256",
          "container_byte_count","container_sha256","manifest_sha256"
        ])
        and (.schema_id | type == "string" and length > 0)
        and (.compatibility_identity_sha256 | hex64)
        and .artifact_semantic_role == "weights_v2"
        and (.artifact_path_sha256 | hex64)
        and (.container_byte_count | positive_uint)
        and (.container_sha256 | hex64)
        and (.manifest_sha256 | hex64);
      def control_projection:
        exact_keys(["schema_id","canonical_byte_count","sha256"])
        and (.schema_id | type == "string" and length > 0)
        and (.canonical_byte_count | positive_uint)
        and (.sha256 | hex64);
      def checkpoint($role; $load_authoritative):
        exact_keys([
          "set_role","load_authoritative","commit_schema",
          "commit_byte_count","commit_sha256","leaf_count",
          "ordered_leaf_roles","each_leaf_byte_count_and_sha256",
          "external_v2_binding","control_schema_and_sha256"
        ])
        and .set_role == $role
        and .load_authoritative == $load_authoritative
        and .commit_schema
          == "ergentics_prime_native_decoder_trajectory_exact_resume_checkpoint_v1"
        and (.commit_byte_count | positive_uint)
        and (.commit_sha256 | hex64)
        and .leaf_count == 4
        and .ordered_leaf_roles == [
          "weights_v2","optimizer_moments",
          "control_state_manifest","commit_manifest"
        ]
        and (.each_leaf_byte_count_and_sha256 | type == "array"
          and length == 4 and all(.[]; leaf_binding))
        and ([.each_leaf_byte_count_and_sha256[].publication_ordinal]
          == [1,2,3,4])
        and ([.each_leaf_byte_count_and_sha256[].role]
          == .ordered_leaf_roles)
        and (.external_v2_binding | external_v2)
        and (.control_schema_and_sha256 | control_projection);
      def tensor_projection($expected; $domain):
        exact_keys([
          "algorithm_id","sorted_unique_path_count",
          "shape_dtype_element_and_byte_count_preimage_sha256",
          "canonical_logical_bytes_preimage_sha256",
          "total_element_count","total_logical_byte_count",
          "first_mismatch_path_if_any"
        ])
        and .algorithm_id
          == "prime_stage7_sorted_path_shape_dtype_element_and_byte_count_sha256_v1"
        and .sorted_unique_path_count == $expected.path_count
        and .shape_dtype_element_and_byte_count_preimage_sha256
          == $domain.catalog_sha256
        and .canonical_logical_bytes_preimage_sha256
          == $domain.left_sha256
        and (.total_element_count | positive_uint)
        and .total_logical_byte_count == $domain.left_total_bytes
        and .total_logical_byte_count == $domain.right_total_bytes
        and .first_mismatch_path_if_any == $domain.first_mismatch_path;
      def comparison_result($expected):
        . as $domain
        | exact_keys([
          "domain_id","kind","path_count","catalog_preimage_schema",
          "catalog_sha256","left_total_bytes","left_sha256",
          "right_total_bytes","right_sha256","exact",
          "first_mismatch_path","first_mismatch_expected_binding",
          "first_mismatch_observed_binding","tensor_catalog_projection"
        ])
        and .domain_id == $expected.domain_id
        and .kind == $expected.kind
        and .path_count == $expected.path_count
        and .catalog_preimage_schema == $expected.catalog_preimage_schema
        and (if .exact == null then
               .catalog_sha256 == null
               and .left_total_bytes == null and .left_sha256 == null
               and .right_total_bytes == null and .right_sha256 == null
               and .first_mismatch_path == null
               and .first_mismatch_expected_binding == null
               and .first_mismatch_observed_binding == null
               and .tensor_catalog_projection == null
             else
               (.exact | bool)
               and (.catalog_sha256 | hex64)
               and (.left_total_bytes | positive_uint)
               and (.left_sha256 | hex64)
               and (.right_total_bytes | positive_uint)
               and (.right_sha256 | hex64)
               and (if .kind == "tensor_catalog"
                       or .kind == "scalar_and_tensor" then
                      (.tensor_catalog_projection
                        | tensor_projection($expected; $domain))
                    else .tensor_catalog_projection == null end)
               and (if .exact then
                      .left_total_bytes == .right_total_bytes
                      and .left_sha256 == .right_sha256
                      and .first_mismatch_path == null
                      and .first_mismatch_expected_binding == null
                      and .first_mismatch_observed_binding == null
                    else
                      (.first_mismatch_path
                        | type == "string" and length > 0)
                      and (.first_mismatch_expected_binding | hex64)
                      and (.first_mismatch_observed_binding | hex64)
                      and .first_mismatch_expected_binding
                        != .first_mismatch_observed_binding
                      and (.left_total_bytes != .right_total_bytes
                        or .left_sha256 != .right_sha256)
                      and (if $fixed_member_paths[$domain.domain_id]
                               != null then
                             ($fixed_member_paths[$domain.domain_id]
                               | index($domain.first_mismatch_path)) != null
                           else exact_catalog_member_path(
                             $domain.domain_id;
                             $domain.first_mismatch_path) end)
                    end)
             end);
      def phase_record:
        exact_keys([
          "phase_id","cumulative_elapsed_nanoseconds",
          "physical_memory_capacity_bytes","task_resident_bytes",
          "task_physical_footprint_bytes","getrusage_max_rss_bytes",
          "mlx_active_bytes","mlx_cache_bytes","mlx_peak_bytes",
          "metal_current_allocated_bytes","filesystem_fsid",
          "filesystem_semantic_role","filesystem_path_sha256",
          "filesystem_capacity_bytes","filesystem_available_bytes",
          "verified_configured_memory_limit_copied_from_preflight_bytes",
          "verified_configured_cache_limit_copied_from_preflight_bytes"
        ])
        and (.phase_id | type == "string")
        and (.cumulative_elapsed_nanoseconds | uint)
        and (.physical_memory_capacity_bytes | positive_uint)
        and (.task_resident_bytes | uint)
        and (.task_physical_footprint_bytes | uint)
        and (.getrusage_max_rss_bytes | uint)
        and (.mlx_active_bytes | uint)
        and (.mlx_cache_bytes | uint)
        and (.mlx_peak_bytes | uint)
        and (.metal_current_allocated_bytes | uint)
        and (.filesystem_fsid
          | exact_keys(["word0","word1"])
            and (.word0 | uint) and (.word1 | uint))
        and .filesystem_semantic_role == "artifact_root"
        and .filesystem_path_sha256 == $artifact_root_sha
        and (.filesystem_capacity_bytes | positive_uint)
        and (.filesystem_available_bytes | uint)
        and .filesystem_available_bytes <= .filesystem_capacity_bytes
        and (.verified_configured_memory_limit_copied_from_preflight_bytes
          | positive_uint)
        and .verified_configured_cache_limit_copied_from_preflight_bytes
          == 0;
      def artifact_cleanup:
        exact_keys([
          "initial_inventory_empty","known_inventory_before_cleanup",
          "unknown_inventory_count","deleted_known_leaf_count",
          "deleted_private_comparator_count",
          "post_cleanup_inventory_empty","absence_proved",
          "recursive_cleanup_used","artifact_upload_count",
          "retained_artifact_count"
        ])
        and .initial_inventory_empty == true
        and (.known_inventory_before_cleanup | uint)
        and .unknown_inventory_count == 0
        and (.deleted_known_leaf_count | uint)
        and (.deleted_private_comparator_count | uint)
        and .post_cleanup_inventory_empty == true
        and .absence_proved == true
        and .recursive_cleanup_used == false
        and .artifact_upload_count == 0
        and .retained_artifact_count == 0;
      def first_mismatch:
        exact_keys([
          "availability","domain_id","path",
          "expected_binding","observed_binding"
        ])
        and (.availability == "available"
          or .availability == "not_applicable"
          or .availability == "unavailable")
        and (.domain_id == null or (.domain_id | type == "string"))
        and (.path == null or (.path | type == "string" and length > 0))
        and (.expected_binding | nullable_hex64)
        and (.observed_binding | nullable_hex64);
      def prefix_counts($actual; $maximum):
        ($actual | exact_keys($maximum | keys))
        and ([$maximum | keys[] as $key
          | ($actual[$key] | uint)
            and $actual[$key] <= $maximum[$key]] | all);
      def operation_dependency_prefix($counts):
        $counts.optimizer_update_count <= $counts.backward_count
        and $counts.backward_count <= $counts.training_step_count
        and $counts.checked_read_only_evaluation_count
          == $counts.evaluation_forward_pass_count
        and $counts.checked_read_only_evaluation_count
          <= $counts.training_step_count
        and $counts.training_mode_restore_count
          == $counts.training_mode_disable_count
        and $counts.training_mode_disable_count
          == $counts.checked_read_only_evaluation_count
        and $counts.token_bounds_checked_eval_count
          <= $counts.token_bounds_validation_count
        and $counts.token_bounds_gpu_synchronize_count
          <= $counts.token_bounds_checked_eval_count
        and $counts.token_bounds_host_bool_item_count
          <= $counts.token_bounds_gpu_synchronize_count
        and $counts.dense_b_path_logits_call_count
          <= $counts.token_bounds_host_bool_item_count
        and $counts.dense_one_hot_matmul_construction_count
          == $counts.dense_b_path_logits_call_count
        and $counts.forward_loss_count
          == $counts.dense_b_path_logits_call_count
        and $counts.cross_entropy_count == $counts.forward_loss_count
        and $counts.dense_b_path_logits_call_count
          == ($counts.training_step_count
            + $counts.evaluation_forward_pass_count)
        and $counts.gradient_evidence_capture_count
          <= $counts.backward_count
        and $counts.gradient_catalog_release_count
          <= $counts.backward_count
        and $counts.final_commit_publication_count
          <= $counts.optimizer_moment_publish_count
        and $counts.optimizer_moment_publish_count
          <= $counts.v2_weights_write_count
        and $counts.v2_weights_write_count <= $counts.training_step_count
        and $counts.v2_internal_verification_load_count
          == $counts.v2_weights_write_count
        and $counts.leaf_publication_count
          >= (4 * $counts.final_commit_publication_count)
        and $counts.leaf_publication_count
          <= (4 * $counts.v2_weights_write_count)
        and $counts.public_restore_load_count
          <= $counts.final_commit_publication_count
        and $counts.deferred_optimizer_moment_load_count
          <= $counts.public_restore_load_count
        and $counts.typed_optimizer_state_import_count
          <= $counts.deferred_optimizer_moment_load_count
        and $counts.resource_measurement_checked_eval_count
          <= $counts.resource_measurement_synchronize_count
        and $counts.model_allocation_and_materialization_count
          == ($counts.optimizer_allocation_count
            + $counts.v2_internal_verification_load_count)
        and $counts.optimizer_allocation_count
          == ((if $counts.model_allocation_and_materialization_count > 0
                then 1 else 0 end)
            + $counts.typed_optimizer_state_import_count)
        and (if $counts.training_step_count == 3 then
               $counts.public_restore_load_count == 1
               and $counts.typed_optimizer_state_import_count == 1
             else true end)
        and $counts.worker_process_count <= 1
        and $counts.supervisor_process_count <= 1
        and $counts.release_verifier_process_count <= 1
        and $counts.maximum_public_receipt_count == 1;
      def strictly_increasing:
        . as $values
        | all(range(1; length); . as $index
          | $values[$index] > $values[$index - 1]);
      def nondecreasing:
        . as $values
        | all(range(1; length); . as $index
          | $values[$index] >= $values[$index - 1]);
      def phase_dependency_prefix(
        $counts; $phase_count; $checkpoint_count; $domain_count
      ):
        $counts.resource_measurement_synchronize_count == $phase_count
        and $counts.resource_measurement_checked_eval_count
          == [0,0,1,2,3,4,5,5,6,7,8,8,8][$phase_count]
        and $counts.final_commit_publication_count == $checkpoint_count
        and (if $counts.training_step_count >= 1 then
               $phase_count >= 2
             else true end)
        and (if $counts.training_step_count >= 2 then
               $phase_count >= 4
             else true end)
        and (if $counts.public_restore_load_count == 1 then
               $phase_count >= 7
             else true end)
        and (if $counts.training_step_count == 3 then
               $phase_count >= 8
             else true end)
        and (if $checkpoint_count >= 1 then
               $counts.training_step_count >= 1
             else true end)
        and (if $checkpoint_count >= 2 then
               $counts.training_step_count >= 2
             else true end)
        and (if $checkpoint_count == 3 then
               $counts.training_step_count == 3
             else true end)
        and (if $domain_count > 0 then
               $phase_count >= 10
               and $checkpoint_count == 3
               and $counts.training_step_count == 3
               and $counts.backward_count == 3
               and $counts.optimizer_update_count == 3
             else true end);
      def candidate_contract_v1:
        . as $candidate
        | ([$candidate.baseline_checkpoint_binding,
            $candidate.uninterrupted_comparator_binding,
            $candidate.resumed_comparator_binding]
          | map(select(. != null)) | length) as $checkpoint_count
        | exact_keys([
          "schema","authority_and_predecessor_bindings",
          "implementation_inventory","terminal_scientific_status",
          "one_shot","environment","device_and_stream",
          "operation_counts","baseline_checkpoint_binding",
          "uninterrupted_comparator_binding",
          "resumed_comparator_binding","comparison_domains",
          "first_mismatch","resource_phases",
          "artifact_inventory_and_cleanup","raw_private_paths"
        ])
        and .schema == $schema
        and (.authority_and_predecessor_bindings
          | exact_keys([
              "authority_id","authority_canonical_sha256","repository",
              "predecessor_main_revision","authority_closure_revision",
              "authority_closure_tree",
              "authority_closure_ordered_parents",
              "authority_closure_run_id",
              "authority_closure_run_number",
              "authority_closure_run_attempt",
              "authority_closure_check_suite_id",
              "authority_closure_active_job_id",
              "authority_closure_reviewed_job_id",
              "stage5_b_observation_sha256",
              "b_resource_observation_sha256","mechanics_revision",
              "mechanics_tree","mechanics_ordered_parents",
              "mechanics_run_id","mechanics_run_number",
              "mechanics_run_attempt"
            ])
            and .authority_id == $authority
            and .authority_canonical_sha256 == $canonical
            and .repository == "Ergentics/ergentics-prime"
            and .predecessor_main_revision == $predecessor
            and .authority_closure_revision == $closure_revision
            and .authority_closure_tree == $closure_tree
            and .authority_closure_ordered_parents == $closure_parents
            and .authority_closure_run_id == $closure_run_id
            and .authority_closure_run_number == $closure_run_number
            and .authority_closure_run_attempt == $closure_attempt
            and .authority_closure_check_suite_id == $closure_suite
            and .authority_closure_active_job_id == $closure_active_job
            and .authority_closure_reviewed_job_id
              == $closure_reviewed_job
            and .stage5_b_observation_sha256
              == "7e17cfdc59f63a775aa4ec5b797328e80c0ab75ef65b2b3ddd7f4bf8deb48ef9"
            and .b_resource_observation_sha256
              == "da9edca25faaef6ae6fae38669692603faeb7c29f4995a0fce4a096015a49a88"
            and .mechanics_revision == $mechanics_revision
            and .mechanics_tree == $mechanics_tree
            and .mechanics_ordered_parents == $mechanics_parents
            and .mechanics_run_id == $mechanics_run_id
            and .mechanics_run_number == $mechanics_run_number
            and .mechanics_run_attempt == $mechanics_attempt)
        and .implementation_inventory == $inventory
        and (.terminal_scientific_status
          == "PASS_EXACT"
          or .terminal_scientific_status == "MEASURED_EXACT_MISMATCH"
          or .terminal_scientific_status == "ABSTAIN_RESOURCE"
          or .terminal_scientific_status == "ABSTAIN_INTEGRITY")
        and (.one_shot
          | exact_keys([
              "consumed","opportunity_count","retry_authorized",
              "rerun_authorized","replacement_authorized"
            ])
            and .consumed == true and .opportunity_count == 1
            and .retry_authorized == false
            and .rerun_authorized == false
            and .replacement_authorized == false)
        and (.environment
          | exact_keys([
              "mlx_enable_tf32","mlx_checkout_origin","mlx_revision",
              "swiftpm_configuration","graph_mode",
              "compile_transform_count","operating_system_build",
              "xcode_build","swift_driver","swift_sdk",
              "staged_metallib","runtime_metallib"
            ])
            and .mlx_enable_tf32 == "0"
            and .mlx_checkout_origin == $mlx_origin
            and .mlx_revision == $mlx_revision
            and .swiftpm_configuration == "release"
            and .graph_mode == "eager_uncompiled_no_compile_transform"
            and .compile_transform_count == 0
            and .operating_system_build == $os_build
            and .xcode_build == $xcode_build
            and .swift_driver == $swift_driver
            and .swift_sdk == $swift_sdk
            and (.staged_metallib
              | metallib_binding("staged_metallib"; $staged_path_sha))
            and (.runtime_metallib
              | metallib_binding("runtime_metallib"; $runtime_path_sha)))
        and (.device_and_stream
          | exact_keys([
              "metal_device_count","metal_device_index",
              "metal_device_name","metal_device_registry_id",
              "metal_device_is_default",
              "metal_device_has_unified_memory",
              "metal_device_max_buffer_length_bytes",
              "metal_device_recommended_max_working_set_bytes",
              "mlx_device_type","mlx_device_index",
              "mlx_default_device_is_supplied_device",
              "mlx_default_stream_is_gpu","cpu_fallback_used",
              "stream_order","evaluation_order",
              "configured_memory_limit_bytes",
              "configured_cache_limit_bytes",
              "pre_post_identity_and_policy_equal"
            ])
            and .metal_device_count == 1
            and .metal_device_index == 0
            and (.metal_device_name | type == "string" and length > 0)
            and (.metal_device_registry_id | uint)
            and .metal_device_is_default == true
            and .metal_device_has_unified_memory == true
            and (.metal_device_max_buffer_length_bytes | positive_uint)
            and (.metal_device_recommended_max_working_set_bytes
              | positive_uint)
            and .mlx_device_type == "gpu"
            and .mlx_device_index == 0
            and .mlx_default_device_is_supplied_device == true
            and .mlx_default_stream_is_gpu == true
            and .cpu_fallback_used == false
            and (.stream_order | type == "string" and length > 0)
            and (.evaluation_order | type == "string" and length > 0)
            and (.configured_memory_limit_bytes
              | positive_uint)
            and .configured_cache_limit_bytes == 0
            and .pre_post_identity_and_policy_equal == true)
        and prefix_counts(.operation_counts; $exact_counts)
        and operation_dependency_prefix(.operation_counts)
        and (.baseline_checkpoint_binding
          | exact_or_null([
              "set_role","load_authoritative","commit_schema",
              "commit_byte_count","commit_sha256","leaf_count",
              "ordered_leaf_roles","each_leaf_byte_count_and_sha256",
              "external_v2_binding","control_schema_and_sha256"
            ]))
        and (.uninterrupted_comparator_binding
          | exact_or_null([
              "set_role","load_authoritative","commit_schema",
              "commit_byte_count","commit_sha256","leaf_count",
              "ordered_leaf_roles","each_leaf_byte_count_and_sha256",
              "external_v2_binding","control_schema_and_sha256"
            ]))
        and (.resumed_comparator_binding
          | exact_or_null([
              "set_role","load_authoritative","commit_schema",
              "commit_byte_count","commit_sha256","leaf_count",
              "ordered_leaf_roles","each_leaf_byte_count_and_sha256",
              "external_v2_binding","control_schema_and_sha256"
            ]))
        and (if .baseline_checkpoint_binding == null then
               .uninterrupted_comparator_binding == null
               and .resumed_comparator_binding == null
             elif .uninterrupted_comparator_binding == null then
               (.baseline_checkpoint_binding
                 | checkpoint("baseline_checkpoint"; true))
               and .resumed_comparator_binding == null
             elif .resumed_comparator_binding == null then
               (.baseline_checkpoint_binding
                 | checkpoint("baseline_checkpoint"; true))
               and (.uninterrupted_comparator_binding
                 | checkpoint(
                     "uninterrupted_n_plus_1_comparator"; false))
             else
               (.baseline_checkpoint_binding
                 | checkpoint("baseline_checkpoint"; true))
               and (.uninterrupted_comparator_binding
                 | checkpoint(
                     "uninterrupted_n_plus_1_comparator"; false))
               and (.resumed_comparator_binding
                 | checkpoint("resumed_n_plus_1_comparator"; false))
             end)
        and .operation_counts.final_commit_publication_count
          == $checkpoint_count
        and (.comparison_domains | type == "array" and length <= 18)
        and ([range(0; .comparison_domains | length) as $index
          | (.comparison_domains[$index]
              | .domain_id == $domain_contracts[$index].domain_id
                and .kind == $domain_contracts[$index].kind
                and .path_count == $domain_contracts[$index].path_count
                and .catalog_preimage_schema
                  == $domain_contracts[$index].catalog_preimage_schema)]
          | all)
        and ([range(0; .comparison_domains | length) as $index
          | (.comparison_domains[$index]
              | comparison_result($domain_contracts[$index]))] | all)
        and (.first_mismatch | first_mismatch)
        and (.resource_phases | type == "array" and length <= 12)
        and ([.resource_phases[] | phase_record] | all)
        and ([range(0; .resource_phases | length) as $index
          | .resource_phases[$index].phase_id == [
              "preflight","post_initial_model_materialization",
              "post_baseline_step_and_evaluation",
              "post_baseline_gradient_release_and_baseline_four_leaf_publication",
              "post_uninterrupted_successor_step_and_evaluation",
              "post_uninterrupted_comparator_publication",
              "post_uninterrupted_state_deallocation_and_cache_clear",
              "post_fresh_weight_moment_and_control_restore",
              "post_resumed_successor_step_and_evaluation",
              "post_resumed_comparator_publication",
              "post_streaming_compare_artifact_cleanup_and_absence",
              "postflight"
            ][$index]] | all)
        and ([.resource_phases[].cumulative_elapsed_nanoseconds]
          | strictly_increasing)
        and ([.resource_phases[].mlx_peak_bytes] | nondecreasing)
        and ([.resource_phases[].getrusage_max_rss_bytes] | nondecreasing)
        and .device_and_stream.configured_memory_limit_bytes
          == ([
            17179869184,
            .device_and_stream
              .metal_device_recommended_max_working_set_bytes
          ] | min)
        and (if (.resource_phases | length) == 0 then true else
               ([.resource_phases[].physical_memory_capacity_bytes]
                 | . as $values | all($values[]; . == $values[0]))
               and ([.resource_phases[].filesystem_fsid]
                 | . as $values | all($values[]; . == $values[0]))
               and ([.resource_phases[]
                   .verified_configured_memory_limit_copied_from_preflight_bytes]
                 | all(.[];
                     . == $candidate.device_and_stream
                       .configured_memory_limit_bytes))
               and ([.resource_phases[]
                   .verified_configured_cache_limit_copied_from_preflight_bytes]
                 | all(.[];
                     . == $candidate.device_and_stream
                       .configured_cache_limit_bytes))
             end)
        and .operation_counts.resource_measurement_synchronize_count
          == (.resource_phases | length)
        and .operation_counts.resource_measurement_checked_eval_count
          == [0,0,1,2,3,4,5,5,6,7,8,8,8][
            (.resource_phases | length)]
        and (.artifact_inventory_and_cleanup | artifact_cleanup)
        and (.artifact_inventory_and_cleanup as $cleanup
          | $cleanup.known_inventory_before_cleanup as $known
          | $known <= 12
            and $checkpoint_count == (($known / 4) | floor)
            and $cleanup.deleted_known_leaf_count == $known
            and $cleanup.deleted_private_comparator_count
              == (if $known == 0 then 0
                  else (($known - 1) / 4) | floor end))
        and phase_dependency_prefix(
          .operation_counts; (.resource_phases | length);
          $checkpoint_count; (.comparison_domains | length))
        and (.raw_private_paths
          | exact_keys([
              "lease_root","lease_path","artifact_root",
              "staged_metallib_path","runtime_metallib_path"
            ])
            and .lease_root == $lease_root
            and .lease_path == $lease_path
            and .artifact_root == $artifact_root
            and .staged_metallib_path == $staged_path
            and .runtime_metallib_path == $runtime_path)
        and (if .terminal_scientific_status == "PASS_EXACT" then
               .operation_counts == $exact_counts
               and (.resource_phases | length) == 12
               and .resource_phases[-1].cumulative_elapsed_nanoseconds
                 < 4800000000000
               and .device_and_stream.configured_memory_limit_bytes
                 >= 4337713152
               and .resource_phases[0].filesystem_available_bytes
                 >= 12884901888
               and .baseline_checkpoint_binding != null
               and .uninterrupted_comparator_binding != null
               and .resumed_comparator_binding != null
               and (.comparison_domains | length) == 18
               and ([.comparison_domains[].exact] | all(. == true))
               and .first_mismatch.availability == "not_applicable"
               and .first_mismatch.domain_id == null
               and .first_mismatch.path == null
               and .first_mismatch.expected_binding == null
               and .first_mismatch.observed_binding == null
             elif .terminal_scientific_status
                    == "MEASURED_EXACT_MISMATCH" then
               .operation_counts == $exact_counts
               and (.resource_phases | length) == 12
               and .resource_phases[-1].cumulative_elapsed_nanoseconds
                 < 4800000000000
               and .device_and_stream.configured_memory_limit_bytes
                 >= 4337713152
               and .resource_phases[0].filesystem_available_bytes
                 >= 12884901888
               and .baseline_checkpoint_binding != null
               and .uninterrupted_comparator_binding != null
               and .resumed_comparator_binding != null
               and (.comparison_domains | length) == 18
               and ([.comparison_domains[].exact]
                 | all(. == true or . == false))
               and ([.comparison_domains[].exact]
                 | any(. == false))
               and .first_mismatch.availability == "available"
               and .first_mismatch.domain_id
                 == ([.comparison_domains[]
                      | select(.exact == false)][0].domain_id)
               and .first_mismatch.path
                 == ([.comparison_domains[]
                      | select(.exact == false)][0].first_mismatch_path)
               and .first_mismatch.expected_binding
                 == ([.comparison_domains[]
                      | select(.exact == false)][0]
                       .first_mismatch_expected_binding)
               and .first_mismatch.observed_binding
                 == ([.comparison_domains[]
                      | select(.exact == false)][0]
                       .first_mismatch_observed_binding)
             elif .terminal_scientific_status
                    == "ABSTAIN_RESOURCE" then
               (if .first_mismatch.domain_id
                       == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure" then
                      (.resource_phases | length) >= 1
                      and (.resource_phases | length) <= 12
                      and (if (.resource_phases | length) >= 11 then
                             (.comparison_domains | length) == 18
                             and .operation_counts
                               == ($exact_counts
                                 | .resource_measurement_synchronize_count
                                   = ($candidate.resource_phases | length))
                             and ([.comparison_domains[].exact]
                               | all(. == true or . == false))
                           else
                             (.comparison_domains | length) < 18
                             and ([.comparison_domains[].exact]
                               | all(. == true))
                           end)
                    else
                      (.resource_phases | length) >= 1
                      and (.resource_phases | length) < 12
                      and (.comparison_domains | length) < 18
                      and ([.comparison_domains[].exact] | all(. == true))
                    end)
               and .first_mismatch.availability == "unavailable"
               and (.first_mismatch.domain_id
                 == "memory_limit_below_minimum_floor"
                 or .first_mismatch.domain_id
                   == "filesystem_available_below_three_set_floor"
                 or .first_mismatch.domain_id
                   == "positively_identified_enomem"
                 or .first_mismatch.domain_id
                   == "positively_identified_enospc"
                 or .first_mismatch.domain_id
                   == "positively_identified_mlx_memory_limit_exhaustion"
                 or .first_mismatch.domain_id
                   == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure")
               and (if .first_mismatch.domain_id
                       == "memory_limit_below_minimum_floor"
                       or .first_mismatch.domain_id
                         == "filesystem_available_below_three_set_floor" then
                      true
                    else
                      .device_and_stream.configured_memory_limit_bytes
                        >= 4337713152
                      and .resource_phases[0].filesystem_available_bytes
                        >= 12884901888
                    end)
               and (if .first_mismatch.domain_id
                       == "memory_limit_below_minimum_floor" then
                      .device_and_stream.configured_memory_limit_bytes
                        < 4337713152
                      and .first_mismatch.path
                        == "device_and_stream.configured_memory_limit_bytes"
                      and .first_mismatch.expected_binding
                        == $memory_floor_expected
                      and .first_mismatch.observed_binding
                        == $memory_floor_observed
                    elif .first_mismatch.domain_id
                       == "filesystem_available_below_three_set_floor" then
                      .resource_phases[0].filesystem_available_bytes
                        < 12884901888
                      and .first_mismatch.path
                        == "resource_phases[0].filesystem_available_bytes"
                      and .first_mismatch.expected_binding
                        == $filesystem_floor_expected
                      and .first_mismatch.observed_binding
                        == $filesystem_floor_observed
                    elif .first_mismatch.domain_id
                       == "positively_identified_enomem" then
                      .first_mismatch.path == "errno"
                      and .first_mismatch.expected_binding == null
                      and .first_mismatch.observed_binding
                        == $enomem_observed
                    elif .first_mismatch.domain_id
                       == "positively_identified_enospc" then
                      .first_mismatch.path == "errno"
                      and .first_mismatch.expected_binding == null
                      and .first_mismatch.observed_binding
                        == $enospc_observed
                    elif .first_mismatch.domain_id
                       == "positively_identified_mlx_memory_limit_exhaustion" then
                      .first_mismatch.path
                        == "resource_phases[last].mlx_peak_bytes"
                      and .resource_phases[-1].mlx_peak_bytes
                        >= .device_and_stream.configured_memory_limit_bytes
                      and .first_mismatch.expected_binding == null
                      and .first_mismatch.observed_binding
                        == $mlx_memory_limit_observed
                    else
                      .first_mismatch.path
                        == "resource_phases[last].cumulative_elapsed_nanoseconds"
                      and .first_mismatch.expected_binding == null
                      and .resource_phases[-1]
                          .cumulative_elapsed_nanoseconds
                        >= 4800000000000
                      and .first_mismatch.observed_binding
                        == $worker_timeout_observed
                    end)
             else
               (.comparison_domains | length) >= 1
               and ([range(0; (.comparison_domains | length) - 1)
                 as $index | .comparison_domains[$index].exact == true]
                 | all)
               and .comparison_domains[-1].exact == null
               and .first_mismatch.availability == "unavailable"
               and (.first_mismatch.domain_id
                 == .comparison_domains[-1].domain_id)
               and (.first_mismatch.path
                 | type == "string" and length > 0)
               and (.first_mismatch.expected_binding | hex64)
               and (.first_mismatch.observed_binding | hex64)
               and .first_mismatch.expected_binding
                 != .first_mismatch.observed_binding
               and (if $fixed_member_paths[.first_mismatch.domain_id]
                        != null then
                      ($fixed_member_paths[.first_mismatch.domain_id]
                        | index($candidate.first_mismatch.path)) != null
                    else exact_catalog_member_path(
                      .first_mismatch.domain_id;
                      $candidate.first_mismatch.path) end)
             end);
      def safely_candidate_contract_v1:
        try candidate_contract_v1 catch false;
      . as $candidate
      | ($candidate | safely_candidate_contract_v1)
      and ([
        ($candidate + {unexpected_schema_key:true}
          | safely_candidate_contract_v1),
        ($candidate | .schema = "mutated"
          | safely_candidate_contract_v1),
        ($candidate
          | .authority_and_predecessor_bindings.mechanics_tree =
              "0000000000000000000000000000000000000000"
          | safely_candidate_contract_v1),
        ($candidate
          | .terminal_scientific_status = "ABSTAIN_INTEGRITY"
          | .operation_counts.v2_internal_verification_load_count = 0
          | .first_mismatch = {
              availability:"unavailable",domain_id:"topology_drift",
              path:"snapshot_weights",
              expected_binding:
                "0000000000000000000000000000000000000000000000000000000000000000",
              observed_binding:
                "1111111111111111111111111111111111111111111111111111111111111111"
            }
          | safely_candidate_contract_v1),
        ($candidate
          | .terminal_scientific_status = "ABSTAIN_INTEGRITY"
          | .operation_counts.forward_loss_count = 5
          | .first_mismatch = {
              availability:"unavailable",domain_id:"topology_drift",
              path:"snapshot_weights",
              expected_binding:
                "0000000000000000000000000000000000000000000000000000000000000000",
              observed_binding:
                "1111111111111111111111111111111111111111111111111111111111111111"
            }
          | safely_candidate_contract_v1),
        ($candidate | .one_shot.retry_authorized = true
          | safely_candidate_contract_v1),
        ($candidate | .implementation_inventory = []
          | safely_candidate_contract_v1),
        ($candidate
          | .environment.staged_metallib.content_sha256 =
              "0000000000000000000000000000000000000000000000000000000000000000"
          | safely_candidate_contract_v1),
        ($candidate | .device_and_stream.cpu_fallback_used = true
          | safely_candidate_contract_v1),
        ($candidate | .operation_counts.training_step_count = 4
          | safely_candidate_contract_v1),
        ($candidate
          | .terminal_scientific_status = "ABSTAIN_RESOURCE"
          | .operation_counts = ($exact_counts
              | with_entries(.value = 0))
          | .operation_counts.optimizer_update_count = 1
          | .operation_counts.maximum_public_receipt_count = 1
          | .operation_counts.resource_measurement_synchronize_count = 1
          | .comparison_domains = []
          | .resource_phases = [.resource_phases[0]]
          | .baseline_checkpoint_binding = null
          | .uninterrupted_comparator_binding = null
          | .resumed_comparator_binding = null
          | .first_mismatch = {
              availability:"unavailable",
              domain_id:"memory_limit_below_minimum_floor",
              path:"preflight",
              expected_binding:null,
              observed_binding:
                "0000000000000000000000000000000000000000000000000000000000000000"
            }
          | safely_candidate_contract_v1),
        ($candidate
          | .terminal_scientific_status = "ABSTAIN_RESOURCE"
          | .operation_counts = ($exact_counts
              | with_entries(.value = 0))
          | .operation_counts.maximum_public_receipt_count = 1
          | .operation_counts.resource_measurement_synchronize_count = 1
          | .comparison_domains = ($domain_contracts | map({
              domain_id:.domain_id,kind:.kind,path_count:.path_count,
              catalog_preimage_schema:.catalog_preimage_schema,
              catalog_sha256:null,left_total_bytes:null,left_sha256:null,
              right_total_bytes:null,right_sha256:null,exact:true,
              first_mismatch_path:null,
              first_mismatch_expected_binding:null,
              first_mismatch_observed_binding:null,
              tensor_catalog_projection:null
            }))
          | .resource_phases = [.resource_phases[0]]
          | .baseline_checkpoint_binding = null
          | .uninterrupted_comparator_binding = null
          | .resumed_comparator_binding = null
          | .first_mismatch = {
              availability:"unavailable",
              domain_id:"memory_limit_below_minimum_floor",
              path:"preflight",
              expected_binding:null,
              observed_binding:
                "0000000000000000000000000000000000000000000000000000000000000000"
            }
          | safely_candidate_contract_v1),
        ($candidate
          | .terminal_scientific_status = "ABSTAIN_INTEGRITY"
          | .comparison_domains = []
          | .resource_phases = []
          | .baseline_checkpoint_binding = null
          | .uninterrupted_comparator_binding = null
          | .resumed_comparator_binding = null
          | .first_mismatch = {
              availability:"unavailable",domain_id:null,path:null,
              expected_binding:null,observed_binding:null
            }
          | safely_candidate_contract_v1),
        ($candidate | .comparison_domains |= reverse
          | safely_candidate_contract_v1),
        ($candidate | .resource_phases[0].phase_id = "mutated"
          | safely_candidate_contract_v1),
        ($candidate
          | .artifact_inventory_and_cleanup.unknown_inventory_count = 1
          | safely_candidate_contract_v1),
        ($candidate | .raw_private_paths.artifact_root = "/mutated"
          | safely_candidate_contract_v1)
      ] | all(. == false))
    ' >/dev/null ||
    fail "private candidate contract, binding, or synthetic mutations changed"

# The terminal must cross-bind the already authenticated candidate and prove
# cleanup, explicit lease release, and a distinct successful exec verifier.
/usr/bin/printf '%s' "$(<"$terminal_json_path")" | jq -e \
    --slurpfile validated_candidate "$candidate_json_path" \
    --arg schema "$terminal_schema_id" \
    --arg candidate_status "$(/usr/bin/printf '%s' "$(<"$candidate_json_path")" | jq -r '.terminal_scientific_status')" \
    --argjson candidate_bytes "$candidate_byte_count" \
    --arg candidate_sha "$candidate_sha256" \
    --arg lease_root "$lease_root" \
    --argjson effective_uid "$effective_uid" \
    --argjson effective_gid "$effective_gid" \
    '
      def exact_keys($expected): keys == ($expected | sort);
      def uint:
        type == "number" and . >= 0 and . == floor;
      def positive_uint: uint and . > 0;
      def hex64:
        type == "string" and test("^[0-9a-f]{64}$");
      def allowed_xattrs:
        type == "array" and . == (sort | unique)
        and all(.[]; . == "com.apple.provenance");
      def parent_descriptor($path):
        exact_keys([
          "physical_path","device_id","inode","uid","gid","mode",
          "acl","xattr_names","security_flags","file_type",
          "observed_nlink"
        ])
        and .physical_path == $path
        and (.device_id | uint)
        and (.inode | positive_uint)
        and .uid == $effective_uid
        and .gid == $effective_gid
        and .mode == "0700"
        and .acl == 0
        and (.xattr_names | allowed_xattrs)
        and .security_flags == 0
        and .file_type == "directory"
        and (.observed_nlink | uint);
      def lease_descriptor:
        exact_keys([
          "device_id","inode","uid","gid","mode","acl",
          "xattr_names","security_flags","file_type","byte_count",
          "observed_nlink"
        ])
        and (.device_id | uint)
        and (.inode | positive_uint)
        and .uid == $effective_uid
        and .gid == $effective_gid
        and .mode == "0600"
        and .acl == 0
        and (.xattr_names | allowed_xattrs)
        and .security_flags == 0
        and .file_type == "regular_file"
        and .byte_count == 0
        and .observed_nlink == 1;
      def first_failed_guard:
        exact_keys([
          "availability","guard_id","classification","errno","detail"
        ])
        and (.availability == "available"
          or .availability == "not_applicable")
        and (.guard_id == null
          or (.guard_id | type == "string" and length > 0))
        and (.classification == null
          or (.classification | type == "string" and length > 0))
        and (.errno == null or (.errno | positive_uint))
        and (.detail == null
          or (.detail | type == "string" and length > 0));
      def terminal_contract_v1:
        $validated_candidate[0] as $candidate
        | exact_keys([
          "schema","candidate_byte_count","candidate_sha256",
          "candidate_status","first_failed_guard","lease_acquisition",
          "cleanup_and_absence","release_verifier",
          "supervisor_integrity","private_raw_descriptor_tuples"
        ])
        and .schema == $schema
        and .candidate_byte_count == $candidate_bytes
        and .candidate_sha256 == $candidate_sha
        and (.candidate_sha256 | hex64)
        and .candidate_status == $candidate_status
        and (.candidate_status == "PASS_EXACT"
          or .candidate_status == "MEASURED_EXACT_MISMATCH"
          or .candidate_status == "ABSTAIN_RESOURCE"
          or .candidate_status == "ABSTAIN_INTEGRITY")
        and (.first_failed_guard | first_failed_guard)
        and (.lease_acquisition
          | exact_keys([
              "acquired","nonblocking","supervisor_owned",
              "worker_inherited_descriptor_count",
              "held_through_cleanup_and_postflight"
            ])
            and .acquired == true
            and .nonblocking == true
            and .supervisor_owned == true
            and .worker_inherited_descriptor_count == 0
            and .held_through_cleanup_and_postflight == true)
        and (.cleanup_and_absence
          | exact_keys([
              "known_leaf_count","deleted_leaf_count",
              "unknown_inventory_count","post_cleanup_empty",
              "absence_proved","recursive_cleanup_used"
            ])
            and (.known_leaf_count | uint)
            and .deleted_leaf_count == .known_leaf_count
            and .known_leaf_count
              == $candidate.artifact_inventory_and_cleanup
                .known_inventory_before_cleanup
            and .deleted_leaf_count
              == $candidate.artifact_inventory_and_cleanup
                .deleted_known_leaf_count
            and .unknown_inventory_count == 0
            and .unknown_inventory_count
              == $candidate.artifact_inventory_and_cleanup
                .unknown_inventory_count
            and .post_cleanup_empty == true
            and .absence_proved == true
            and .recursive_cleanup_used == false)
        and (.release_verifier
          | exact_keys([
              "executed","exit_zero","supervisor_alive",
              "acquire_count","release_count"
            ])
            and .executed == true
            and .exit_zero == true
            and .supervisor_alive == true
            and .acquire_count == 1
            and .release_count == 1)
        and (.supervisor_integrity
          | exact_keys([
              "candidate_validated","stdout_candidate_then_terminal",
              "post_candidate_inventory_exact",
              "lease_released_explicitly","terminal_canonical"
            ])
            and .candidate_validated == true
            and .stdout_candidate_then_terminal == true
            and .post_candidate_inventory_exact == true
            and .lease_released_explicitly == true
            and .terminal_canonical == true)
        and (.private_raw_descriptor_tuples
          | exact_keys([
              "preflight_parent","post_candidate_parent",
              "post_candidate_leaf","verifier_parent","verifier_leaf"
            ])
            and (.preflight_parent
              | parent_descriptor($lease_root))
            and (.post_candidate_parent
              | parent_descriptor($lease_root))
            and (.post_candidate_leaf
              | lease_descriptor)
            and (.verifier_parent
              | parent_descriptor($lease_root))
            and (.verifier_leaf
              | lease_descriptor)
            and (.preflight_parent
              | del(.observed_nlink))
              == (.post_candidate_parent | del(.observed_nlink))
            and (.post_candidate_parent
              | del(.observed_nlink))
              == (.verifier_parent | del(.observed_nlink))
            and .post_candidate_leaf == .verifier_leaf)
        and (if .candidate_status == "PASS_EXACT"
                  or .candidate_status == "MEASURED_EXACT_MISMATCH" then
               .first_failed_guard.availability == "not_applicable"
               and .first_failed_guard.guard_id == null
               and .first_failed_guard.classification == null
               and .first_failed_guard.errno == null
               and .first_failed_guard.detail == null
             elif .candidate_status == "ABSTAIN_RESOURCE" then
               .first_failed_guard.availability == "available"
               and (.first_failed_guard.guard_id
                 == "memory_limit_below_minimum_floor"
                 or .first_failed_guard.guard_id
                   == "filesystem_available_below_three_set_floor"
                 or .first_failed_guard.guard_id
                   == "positively_identified_enomem"
                 or .first_failed_guard.guard_id
                   == "positively_identified_enospc"
                 or .first_failed_guard.guard_id
                   == "positively_identified_mlx_memory_limit_exhaustion"
                 or .first_failed_guard.guard_id
                   == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure")
               and .first_failed_guard.guard_id
                 == $candidate.first_mismatch.domain_id
               and .first_failed_guard.classification == .candidate_status
               and (if .first_failed_guard.guard_id
                       == "positively_identified_enomem" then
                      .first_failed_guard.errno == 12
                    elif .first_failed_guard.guard_id
                       == "positively_identified_enospc" then
                      .first_failed_guard.errno == 28
                    else .first_failed_guard.errno == null end)
               and .first_failed_guard.detail
                 == $candidate.first_mismatch.observed_binding
             else
               .first_failed_guard.availability == "available"
               and .first_failed_guard.guard_id
                 == $candidate.first_mismatch.domain_id
               and .first_failed_guard.classification == .candidate_status
               and .first_failed_guard.errno == null
               and .first_failed_guard.detail
                 == $candidate.first_mismatch.observed_binding
             end);
      def safely_terminal_contract_v1:
        try terminal_contract_v1 catch false;
      . as $terminal
      | ($terminal | safely_terminal_contract_v1)
      and ($terminal
        | .private_raw_descriptor_tuples.preflight_parent.observed_nlink = 0
        | .private_raw_descriptor_tuples.post_candidate_parent
            .observed_nlink = 1
        | .private_raw_descriptor_tuples.verifier_parent.observed_nlink = 2
        | safely_terminal_contract_v1)
      and ($terminal
        | .private_raw_descriptor_tuples.preflight_parent.xattr_names = []
        | .private_raw_descriptor_tuples.post_candidate_parent.xattr_names = []
        | .private_raw_descriptor_tuples.verifier_parent.xattr_names = []
        | .private_raw_descriptor_tuples.post_candidate_leaf.xattr_names = []
        | .private_raw_descriptor_tuples.verifier_leaf.xattr_names = []
        | safely_terminal_contract_v1)
      and ($terminal
        | .private_raw_descriptor_tuples.preflight_parent.xattr_names =
            ["com.apple.provenance"]
        | .private_raw_descriptor_tuples.post_candidate_parent.xattr_names =
            ["com.apple.provenance"]
        | .private_raw_descriptor_tuples.verifier_parent.xattr_names =
            ["com.apple.provenance"]
        | .private_raw_descriptor_tuples.post_candidate_leaf.xattr_names =
            ["com.apple.provenance"]
        | .private_raw_descriptor_tuples.verifier_leaf.xattr_names =
            ["com.apple.provenance"]
        | safely_terminal_contract_v1)
      and ([
        ($terminal + {unexpected_schema_key:true}
          | safely_terminal_contract_v1),
        ($terminal | .schema = "mutated"
          | safely_terminal_contract_v1),
        ($terminal | .candidate_byte_count += 1
          | safely_terminal_contract_v1),
        ($terminal
          | .candidate_sha256 =
              "0000000000000000000000000000000000000000000000000000000000000000"
          | safely_terminal_contract_v1),
        ($terminal | .lease_acquisition.supervisor_owned = false
          | safely_terminal_contract_v1),
        ($terminal | .cleanup_and_absence.unknown_inventory_count = 1
          | safely_terminal_contract_v1),
        ($terminal | .release_verifier.exit_zero = false
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_integrity.stdout_candidate_then_terminal = false
          | safely_terminal_contract_v1),
        ($terminal
          | .private_raw_descriptor_tuples.post_candidate_leaf
              .mode = "0644"
          | safely_terminal_contract_v1),
        ($terminal
          | .private_raw_descriptor_tuples.post_candidate_leaf.xattr_names =
              ["com.apple.quarantine"]
          | safely_terminal_contract_v1)
      ] | all(. == false))
    ' >/dev/null ||
    fail "private terminal contract, cross-binding, or synthetic mutations changed"

readonly terminal_status="$(
    /usr/bin/printf '%s' "$(<"$terminal_json_path")" |
        jq -r '.candidate_status'
)"
[[ "$(occurrence_count "$receipt_prefix" "$launcher_contract_log")" == "0" ]] ||
    fail "the execution-pure launcher contract emitted a Stage-7 receipt"

# Re-prove the filesystem and source boundary after the one-shot mechanics.
# The sole durable lease leaf is intentionally retained; every trajectory
# artifact and every private working-directory entry must already be absent.
[[ -d "$artifact_root" && ! -L "$artifact_root" \
    && -z "$(find "$artifact_root" -mindepth 1 -print)" ]] ||
    fail "artifact cleanup or absence proof changed"
[[ -d "$private_cwd" && ! -L "$private_cwd" \
    && -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private execution working directory is not empty"
[[ "$(find "$lease_root" -mindepth 1 -maxdepth 1 -print)" \
        == "$lease_path" \
    && -f "$lease_path" && ! -L "$lease_path" \
    && "$(stat -f %l "$lease_path")" == "1" ]] ||
    fail "persistent lease inventory changed"
[[ "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
    && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
        == "$metallib_sha256" \
    && "$(stat -f %z "$runtime_metallib")" == "$metallib_byte_count" \
    && "$(shasum -a 256 "$runtime_metallib" | awk '{print $1}')" \
        == "$metallib_sha256" ]] ||
    fail "staged or runtime metallib changed during mechanics"
[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && "$(git -C "$prime_root" rev-parse 'HEAD^{tree}')" == "$exact_tree" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime checkout changed during mechanics"

# Project only semantic path identities from the validated private objects.
# In particular, no raw path or private artifact byte can enter this object.
jq -cjnS \
    --slurpfile candidate "$candidate_json_path" \
    --slurpfile terminal "$terminal_json_path" \
    --arg schema "$receipt_schema_id" \
    --arg authority "$authority_id" \
    --arg canonical "$authority_canonical_sha256" \
    --arg revision "$exact_revision" \
    --arg tree "$exact_tree" \
    --argjson parents "$mechanics_ordered_parents_json" \
    --argjson run_id "$GITHUB_RUN_ID" \
    --argjson run_number "$GITHUB_RUN_NUMBER" \
    --argjson run_attempt "$GITHUB_RUN_ATTEMPT" \
    --argjson candidate_bytes "$candidate_byte_count" \
    --arg candidate_sha "$candidate_sha256" \
    --argjson terminal_bytes "$terminal_byte_count" \
    --arg terminal_sha "$terminal_sha256" \
    --argjson domain_contracts "$comparison_domain_contracts_json" \
    --arg lease_root_sha "$lease_root_path_sha256" \
    --arg lease_path_sha "$lease_path_sha256" \
    --arg artifact_root_sha "$artifact_root_path_sha256" \
    --arg staged_path_sha "$staged_metallib_path_sha256" \
    --arg runtime_path_sha "$runtime_metallib_path_sha256" \
    '
      def public_descriptor($private; $role; $path_sha; $is_parent):
        ($private
          | .acl_entry_count = .acl
          | del(.acl, .physical_path))
          + {semantic_role:$role,path_sha256:$path_sha}
          + (if $is_parent then {byte_count:null} else {} end);
      def unmeasured_domain($contract):
        {
          domain_id:$contract.domain_id,
          kind:$contract.kind,
          path_count:$contract.path_count,
          catalog_preimage_schema:$contract.catalog_preimage_schema,
          catalog_sha256:null,left_total_bytes:null,left_sha256:null,
          right_total_bytes:null,right_sha256:null,exact:null,
          first_mismatch_path:null,
          first_mismatch_expected_binding:null,
          first_mismatch_observed_binding:null,
          tensor_catalog_projection:null
        };
      $candidate[0] as $c
      | $terminal[0] as $t
      | {
          schema:$schema,
          authority_and_exact_main_bindings:{
            authority_id:$authority,
            authority_canonical_sha256:$canonical,
            repository:"Ergentics/ergentics-prime",
            revision:$revision,
            tree:$tree,
            ordered_parents:$parents,
            workflow_run_id:$run_id,
            workflow_run_number:$run_number,
            run_attempt:$run_attempt
          },
          implementation_inventory:$c.implementation_inventory,
          terminal_status:$t.candidate_status,
          one_shot_consumed:$c.one_shot.consumed,
          candidate_byte_count:$candidate_bytes,
          candidate_sha256:$candidate_sha,
          terminal_byte_count:$terminal_bytes,
          terminal_sha256:$terminal_sha,
          environment_and_device_bindings:{
            mlx_enable_tf32:$c.environment.mlx_enable_tf32,
            mlx_checkout_origin:$c.environment.mlx_checkout_origin,
            mlx_revision:$c.environment.mlx_revision,
            swiftpm_configuration:$c.environment.swiftpm_configuration,
            graph_mode:$c.environment.graph_mode,
            compile_transform_count:$c.environment.compile_transform_count,
            os_build:$c.environment.operating_system_build,
            xcode_build:$c.environment.xcode_build,
            swift_driver:$c.environment.swift_driver,
            swift_sdk:$c.environment.swift_sdk,
            staged_metallib_role:
              $c.environment.staged_metallib.semantic_role,
            staged_metallib_path_sha256:
              $c.environment.staged_metallib.path_sha256,
            staged_metallib_byte_count_and_content_sha256:{
              byte_count:$c.environment.staged_metallib.byte_count,
              sha256:$c.environment.staged_metallib.content_sha256
            },
            runtime_metallib_role:
              $c.environment.runtime_metallib.semantic_role,
            runtime_metallib_path_sha256:
              $c.environment.runtime_metallib.path_sha256,
            runtime_metallib_byte_count_and_content_sha256:{
              byte_count:$c.environment.runtime_metallib.byte_count,
              sha256:$c.environment.runtime_metallib.content_sha256
            },
            metal_name_registry_unified_max_buffer_recommended_set:{
              name:$c.device_and_stream.metal_device_name,
              registry_id:$c.device_and_stream.metal_device_registry_id,
              has_unified_memory:
                $c.device_and_stream.metal_device_has_unified_memory,
              max_buffer_length:
                $c.device_and_stream.metal_device_max_buffer_length_bytes,
              recommended_max_working_set_size:
                $c.device_and_stream
                  .metal_device_recommended_max_working_set_bytes
            },
            mlx_device_and_default_gpu_stream:{
              device:($c.device_and_stream.mlx_device_type + ":"
                + ($c.device_and_stream.mlx_device_index | tostring)),
              default_stream:(if
                  $c.device_and_stream.mlx_default_stream_is_gpu
                then "gpu" else "invalid" end)
            },
            stream_order:$c.device_and_stream.stream_order,
            evaluation_order:$c.device_and_stream.evaluation_order,
            pre_post_identity_and_policy_equal:
              $c.device_and_stream.pre_post_identity_and_policy_equal,
            root_and_validation_lock_bindings:
              ($c.implementation_inventory
                | map(select(
                    .path_role == "immutable_root_lock"
                    or .path_role == "immutable_validation_lock"))
                | map({path_role,git_blob,byte_count,sha256}))
          },
          operation_counts:$c.operation_counts,
          comparison_domain_results:([
            range(0; $domain_contracts | length) as $index
            | if $index < ($c.comparison_domains | length) then
                $c.comparison_domains[$index]
              else unmeasured_domain($domain_contracts[$index]) end
          ]),
          first_mismatch_if_any:$c.first_mismatch,
          resource_phases:$c.resource_phases,
          checkpoint_and_comparator_bindings:([
            $c.baseline_checkpoint_binding,
            $c.uninterrupted_comparator_binding,
            $c.resumed_comparator_binding
          ] | map(select(. != null))),
          artifact_cleanup_and_absence:
            $c.artifact_inventory_and_cleanup,
          lease_and_verifier:{
            lease_acquired:$t.lease_acquisition.acquired,
            lease_release_count:
              (1 + $t.release_verifier.release_count),
            verifier_executed:$t.release_verifier.executed,
            verifier_exit_zero:$t.release_verifier.exit_zero,
            supervisor_alive_during_verifier:
              $t.release_verifier.supervisor_alive,
            preflight_parent:public_descriptor(
              $t.private_raw_descriptor_tuples.preflight_parent;
              "preflight_parent";$lease_root_sha;true),
            post_candidate_parent:public_descriptor(
              $t.private_raw_descriptor_tuples.post_candidate_parent;
              "post_candidate_parent";$lease_root_sha;true),
            post_candidate_leaf:public_descriptor(
              $t.private_raw_descriptor_tuples.post_candidate_leaf;
              "post_candidate_leaf";$lease_path_sha;false),
            verifier_parent:public_descriptor(
              $t.private_raw_descriptor_tuples.verifier_parent;
              "verifier_parent";$lease_root_sha;true),
            verifier_leaf:public_descriptor(
              $t.private_raw_descriptor_tuples.verifier_leaf;
              "verifier_leaf";$lease_path_sha;false),
            inventory_exact:
              $t.supervisor_integrity.post_candidate_inventory_exact
          },
          semantic_path_roles_and_path_sha256:[
            {
              semantic_role:"lease_root",path_sha256:$lease_root_sha,
              byte_count:null,content_sha256:null,
              raw_absolute_path_present:false
            },
            {
              semantic_role:"lease_path",path_sha256:$lease_path_sha,
              byte_count:null,content_sha256:null,
              raw_absolute_path_present:false
            },
            {
              semantic_role:"artifact_root",path_sha256:$artifact_root_sha,
              byte_count:null,content_sha256:null,
              raw_absolute_path_present:false
            },
            {
              semantic_role:"staged_metallib",
              path_sha256:$staged_path_sha,
              byte_count:$c.environment.staged_metallib.byte_count,
              content_sha256:$c.environment.staged_metallib.content_sha256,
              raw_absolute_path_present:false
            },
            {
              semantic_role:"runtime_metallib",
              path_sha256:$runtime_path_sha,
              byte_count:$c.environment.runtime_metallib.byte_count,
              content_sha256:$c.environment.runtime_metallib.content_sha256,
              raw_absolute_path_present:false
            }
          ]
        }
    ' >"$public_json_path" ||
    fail "validated private projection could not be constructed"

readonly expected_lock_bindings_json="$(
    /usr/bin/printf '%s' "$expected_implementation_inventory_json" |
        jq -cS '[.[] | select(
          .path_role == "immutable_root_lock"
          or .path_role == "immutable_validation_lock")
          | {path_role,git_blob,byte_count,sha256}]'
)"
[[ "$(/usr/bin/printf '%s' "$expected_lock_bindings_json" | jq 'length')" \
        == "2" ]] ||
    fail "root and validation lock projection changed"

# This validator is intentionally independent of the construction expression.
# It binds every public field to the authenticated frames, enforces all nested
# schemas and outcome rules, and proves representative mutations fail closed.
/usr/bin/printf '%s' "$(<"$public_json_path")" | jq -e \
    --slurpfile private_candidate "$candidate_json_path" \
    --slurpfile private_terminal "$terminal_json_path" \
    --arg schema "$receipt_schema_id" \
    --arg authority "$authority_id" \
    --arg canonical "$authority_canonical_sha256" \
    --arg revision "$exact_revision" \
    --arg tree "$exact_tree" \
    --argjson parents "$mechanics_ordered_parents_json" \
    --argjson run_id "$GITHUB_RUN_ID" \
    --argjson run_number "$GITHUB_RUN_NUMBER" \
    --argjson run_attempt "$GITHUB_RUN_ATTEMPT" \
    --argjson inventory "$expected_implementation_inventory_json" \
    --argjson locks "$expected_lock_bindings_json" \
    --argjson exact_counts "$exact_operation_counts_json" \
    --argjson domain_contracts "$comparison_domain_contracts_json" \
    --argjson fixed_member_paths "$fixed_comparison_member_paths_json" \
    --arg mlx_origin "$required_mlx_origin" \
    --arg mlx_revision "$mlx_revision" \
    --arg os_build "$operating_system_build" \
    --arg xcode_build "$xcode_toolchain" \
    --arg swift_driver "$swift_toolchain" \
    --arg swift_sdk "$macos_sdk" \
    --argjson metallib_bytes "$metallib_byte_count" \
    --arg metallib_sha "$metallib_sha256" \
    --arg lease_root_sha "$lease_root_path_sha256" \
    --arg lease_path_sha "$lease_path_sha256" \
    --arg artifact_root_sha "$artifact_root_path_sha256" \
    --arg staged_path_sha "$staged_metallib_path_sha256" \
    --arg runtime_path_sha "$runtime_metallib_path_sha256" \
    --argjson effective_uid "$effective_uid" \
    --argjson effective_gid "$effective_gid" \
    --argjson candidate_bytes "$candidate_byte_count" \
    --arg candidate_sha "$candidate_sha256" \
    --argjson terminal_bytes "$terminal_byte_count" \
    --arg terminal_sha "$terminal_sha256" \
    --arg memory_floor_expected "$memory_floor_expected_binding" \
    --arg memory_floor_observed "$memory_floor_observed_binding" \
    --arg filesystem_floor_expected "$filesystem_floor_expected_binding" \
    --arg filesystem_floor_observed "$filesystem_floor_observed_binding" \
    --arg enomem_observed "$enomem_observed_binding" \
    --arg enospc_observed "$enospc_observed_binding" \
    --arg mlx_memory_limit_observed "$mlx_memory_limit_observed_binding" \
    --arg worker_timeout_observed "$worker_timeout_observed_binding" \
    '
      def exact_keys($expected): keys == ($expected | sort);
      def uint: type == "number" and . >= 0 and . == floor;
      def positive_uint: uint and . > 0;
      def hex40: type == "string" and test("^[0-9a-f]{40}$");
      def hex64: type == "string" and test("^[0-9a-f]{64}$");
      def bool: type == "boolean";
      def nullable_hex64: . == null or hex64;
      def native300_parameter_path:
        type == "string" and test(
          "^(token_embedding\\.weight|final_norm\\.weight|layers\\.(0|[1-9]|1[0-9]|2[0-3])\\.(attention\\.(key_projection|output_projection|query_projection|value_projection)\\.weight|attention_norm\\.weight|feed_forward\\.(down_projection|gate_projection|up_projection)\\.weight|feed_forward_norm\\.weight))$");
      def exact_catalog_member_path($domain; $path):
        if ([
              "snapshot_weights","successor_raw_gradient_bytes",
              "successor_clipped_gradient_bytes",
              "successor_post_update_parameter_bytes"
            ] | index($domain)) != null then
          ($path | native300_parameter_path)
        elif ([
              "snapshot_optimizer_first_moments",
              "successor_optimizer_first_moment_bytes"
            ] | index($domain)) != null then
          ($path | startswith("first_moment."))
          and ($path | ltrimstr("first_moment.")
            | native300_parameter_path)
        elif ([
              "snapshot_optimizer_second_moments",
              "successor_optimizer_second_moment_bytes"
            ] | index($domain)) != null then
          ($path | startswith("second_moment."))
          and ($path | ltrimstr("second_moment.")
            | native300_parameter_path)
        else false end;
      def allowed_xattrs:
        type == "array" and . == (sort | unique)
        and all(.[]; . == "com.apple.provenance");
      def implementation_identity:
        exact_keys([
          "path_role","git_mode","git_blob","byte_count",
          "lf_byte_count","sha256"
        ])
        and (.path_role | type == "string" and length > 0)
        and (.git_mode == "100644" or .git_mode == "100755")
        and (.git_blob | hex40)
        and (.byte_count | positive_uint)
        and (.lf_byte_count | positive_uint)
        and (.lf_byte_count <= .byte_count)
        and (.sha256 | hex64);
      def lock_binding:
        exact_keys(["path_role","git_blob","byte_count","sha256"])
        and (.path_role == "immutable_root_lock"
          or .path_role == "immutable_validation_lock")
        and (.git_blob | hex40)
        and (.byte_count | positive_uint)
        and (.sha256 | hex64);
      def operation_dependency_prefix($counts):
        $counts.optimizer_update_count <= $counts.backward_count
        and $counts.backward_count <= $counts.training_step_count
        and $counts.checked_read_only_evaluation_count
          == $counts.evaluation_forward_pass_count
        and $counts.checked_read_only_evaluation_count
          <= $counts.training_step_count
        and $counts.training_mode_restore_count
          == $counts.training_mode_disable_count
        and $counts.training_mode_disable_count
          == $counts.checked_read_only_evaluation_count
        and $counts.token_bounds_checked_eval_count
          <= $counts.token_bounds_validation_count
        and $counts.token_bounds_gpu_synchronize_count
          <= $counts.token_bounds_checked_eval_count
        and $counts.token_bounds_host_bool_item_count
          <= $counts.token_bounds_gpu_synchronize_count
        and $counts.dense_b_path_logits_call_count
          <= $counts.token_bounds_host_bool_item_count
        and $counts.dense_one_hot_matmul_construction_count
          == $counts.dense_b_path_logits_call_count
        and $counts.forward_loss_count
          == $counts.dense_b_path_logits_call_count
        and $counts.cross_entropy_count == $counts.forward_loss_count
        and $counts.dense_b_path_logits_call_count
          == ($counts.training_step_count
            + $counts.evaluation_forward_pass_count)
        and $counts.gradient_evidence_capture_count
          <= $counts.backward_count
        and $counts.gradient_catalog_release_count
          <= $counts.backward_count
        and $counts.final_commit_publication_count
          <= $counts.optimizer_moment_publish_count
        and $counts.optimizer_moment_publish_count
          <= $counts.v2_weights_write_count
        and $counts.v2_weights_write_count <= $counts.training_step_count
        and $counts.v2_internal_verification_load_count
          == $counts.v2_weights_write_count
        and $counts.leaf_publication_count
          >= (4 * $counts.final_commit_publication_count)
        and $counts.leaf_publication_count
          <= (4 * $counts.v2_weights_write_count)
        and $counts.public_restore_load_count
          <= $counts.final_commit_publication_count
        and $counts.deferred_optimizer_moment_load_count
          <= $counts.public_restore_load_count
        and $counts.typed_optimizer_state_import_count
          <= $counts.deferred_optimizer_moment_load_count
        and $counts.resource_measurement_checked_eval_count
          <= $counts.resource_measurement_synchronize_count
        and $counts.model_allocation_and_materialization_count
          == ($counts.optimizer_allocation_count
            + $counts.v2_internal_verification_load_count)
        and $counts.optimizer_allocation_count
          == ((if $counts.model_allocation_and_materialization_count > 0
                then 1 else 0 end)
            + $counts.typed_optimizer_state_import_count)
        and (if $counts.training_step_count == 3 then
               $counts.public_restore_load_count == 1
               and $counts.typed_optimizer_state_import_count == 1
             else true end)
        and $counts.worker_process_count <= 1
        and $counts.supervisor_process_count <= 1
        and $counts.release_verifier_process_count <= 1
        and $counts.maximum_public_receipt_count == 1;
      def tensor_projection($expected; $domain):
        exact_keys([
          "algorithm_id","sorted_unique_path_count",
          "shape_dtype_element_and_byte_count_preimage_sha256",
          "canonical_logical_bytes_preimage_sha256",
          "total_element_count","total_logical_byte_count",
          "first_mismatch_path_if_any"
        ])
        and .algorithm_id
          == "prime_stage7_sorted_path_shape_dtype_element_and_byte_count_sha256_v1"
        and .sorted_unique_path_count == $expected.path_count
        and .shape_dtype_element_and_byte_count_preimage_sha256
          == $domain.catalog_sha256
        and .canonical_logical_bytes_preimage_sha256
          == $domain.left_sha256
        and (.total_element_count | positive_uint)
        and .total_logical_byte_count == $domain.left_total_bytes
        and .total_logical_byte_count == $domain.right_total_bytes
        and .first_mismatch_path_if_any == $domain.first_mismatch_path;
      def domain_result($expected):
        . as $domain
        | exact_keys([
            "domain_id","kind","path_count","catalog_preimage_schema",
            "catalog_sha256","left_total_bytes","left_sha256",
            "right_total_bytes","right_sha256","exact",
            "first_mismatch_path","first_mismatch_expected_binding",
            "first_mismatch_observed_binding","tensor_catalog_projection"
          ])
        and .domain_id == $expected.domain_id
        and .kind == $expected.kind
        and .path_count == $expected.path_count
        and .catalog_preimage_schema == $expected.catalog_preimage_schema
        and (if .exact == null then
               .catalog_sha256 == null
               and .left_total_bytes == null and .left_sha256 == null
               and .right_total_bytes == null and .right_sha256 == null
               and .first_mismatch_path == null
               and .first_mismatch_expected_binding == null
               and .first_mismatch_observed_binding == null
               and .tensor_catalog_projection == null
             else
               (.exact | bool)
               and (.catalog_sha256 | hex64)
               and (.left_total_bytes | positive_uint)
               and (.left_sha256 | hex64)
               and (.right_total_bytes | positive_uint)
               and (.right_sha256 | hex64)
               and (if .kind == "tensor_catalog"
                       or .kind == "scalar_and_tensor" then
                      (.tensor_catalog_projection
                        | tensor_projection($expected; $domain))
                    else .tensor_catalog_projection == null end)
               and (if .exact then
                      .left_total_bytes == .right_total_bytes
                      and .left_sha256 == .right_sha256
                      and .first_mismatch_path == null
                      and .first_mismatch_expected_binding == null
                      and .first_mismatch_observed_binding == null
                    else
                      (.first_mismatch_path
                        | type == "string" and length > 0)
                      and (.first_mismatch_expected_binding | hex64)
                      and (.first_mismatch_observed_binding | hex64)
                      and .first_mismatch_expected_binding
                        != .first_mismatch_observed_binding
                      and (.left_total_bytes != .right_total_bytes
                        or .left_sha256 != .right_sha256)
                      and (if $fixed_member_paths[$domain.domain_id]
                               != null then
                             ($fixed_member_paths[$domain.domain_id]
                               | index($domain.first_mismatch_path)) != null
                           else exact_catalog_member_path(
                             $domain.domain_id;
                             $domain.first_mismatch_path) end)
                    end)
             end);
      def phase_record:
        exact_keys([
          "phase_id","cumulative_elapsed_nanoseconds",
          "physical_memory_capacity_bytes","task_resident_bytes",
          "task_physical_footprint_bytes","getrusage_max_rss_bytes",
          "mlx_active_bytes","mlx_cache_bytes","mlx_peak_bytes",
          "metal_current_allocated_bytes","filesystem_fsid",
          "filesystem_semantic_role","filesystem_path_sha256",
          "filesystem_capacity_bytes","filesystem_available_bytes",
          "verified_configured_memory_limit_copied_from_preflight_bytes",
          "verified_configured_cache_limit_copied_from_preflight_bytes"
        ])
        and (.phase_id | type == "string" and length > 0)
        and (.cumulative_elapsed_nanoseconds | positive_uint)
        and (.physical_memory_capacity_bytes | positive_uint)
        and (.task_resident_bytes | uint)
        and (.task_physical_footprint_bytes | uint)
        and (.getrusage_max_rss_bytes | uint)
        and (.mlx_active_bytes | uint)
        and (.mlx_cache_bytes | uint)
        and (.mlx_peak_bytes | uint)
        and (.metal_current_allocated_bytes | uint)
        and (.filesystem_fsid
          | exact_keys(["word0","word1"])
            and (.word0 | uint) and (.word1 | uint))
        and .filesystem_semantic_role == "artifact_root"
        and .filesystem_path_sha256 == $artifact_root_sha
        and (.filesystem_capacity_bytes | positive_uint)
        and (.filesystem_available_bytes | uint)
        and .filesystem_available_bytes <= .filesystem_capacity_bytes
        and (.verified_configured_memory_limit_copied_from_preflight_bytes
          | positive_uint)
        and .verified_configured_cache_limit_copied_from_preflight_bytes == 0;
      def strictly_increasing:
        . as $values
        | all(range(1; length); . as $index
          | $values[$index] > $values[$index - 1]);
      def nondecreasing:
        . as $values
        | all(range(1; length); . as $index
          | $values[$index] >= $values[$index - 1]);
      def checkpoint_binding($role; $load_authoritative):
        exact_keys([
          "set_role","load_authoritative","commit_schema",
          "commit_byte_count","commit_sha256","leaf_count",
          "ordered_leaf_roles","each_leaf_byte_count_and_sha256",
          "external_v2_binding","control_schema_and_sha256"
        ])
        and .set_role == $role
        and .load_authoritative == $load_authoritative
        and .commit_schema
          == "ergentics_prime_native_decoder_trajectory_exact_resume_checkpoint_v1"
        and (.commit_byte_count | positive_uint)
        and (.commit_sha256 | hex64)
        and .leaf_count == 4
        and .ordered_leaf_roles == [
          "weights_v2","optimizer_moments",
          "control_state_manifest","commit_manifest"
        ]
        and (.each_leaf_byte_count_and_sha256
          | type == "array" and length == 4
            and ([range(0; 4) as $index
              | .[$index]
              | exact_keys([
                  "role","publication_ordinal","byte_count","sha256"
                ])
                and .role == [
                  "weights_v2","optimizer_moments",
                  "control_state_manifest","commit_manifest"
                ][$index]
                and .publication_ordinal == ($index + 1)
                and (.byte_count | positive_uint)
                and (.sha256 | hex64)] | all))
        and (.external_v2_binding
          | exact_keys([
              "schema_id","compatibility_identity_sha256",
              "artifact_semantic_role","artifact_path_sha256",
              "container_byte_count","container_sha256","manifest_sha256"
            ])
            and (.schema_id | type == "string" and length > 0)
            and (.compatibility_identity_sha256 | hex64)
            and .artifact_semantic_role == "weights_v2"
            and (.artifact_path_sha256 | hex64)
            and (.container_byte_count | positive_uint)
            and (.container_sha256 | hex64)
            and (.manifest_sha256 | hex64))
        and (.control_schema_and_sha256
          | exact_keys(["schema_id","canonical_byte_count","sha256"])
            and (.schema_id | type == "string" and length > 0)
            and (.canonical_byte_count | positive_uint)
            and (.sha256 | hex64));
      def cleanup_contract:
        exact_keys([
          "initial_inventory_empty","known_inventory_before_cleanup",
          "unknown_inventory_count","deleted_known_leaf_count",
          "deleted_private_comparator_count",
          "post_cleanup_inventory_empty","absence_proved",
          "recursive_cleanup_used","artifact_upload_count",
          "retained_artifact_count"
        ])
        and .initial_inventory_empty == true
        and (.known_inventory_before_cleanup | uint)
        and .unknown_inventory_count == 0
        and .deleted_known_leaf_count == .known_inventory_before_cleanup
        and (.deleted_private_comparator_count | uint and . <= 2)
        and .post_cleanup_inventory_empty == true
        and .absence_proved == true
        and .recursive_cleanup_used == false
        and .artifact_upload_count == 0
        and .retained_artifact_count == 0;
      def public_descriptor($role; $path_sha; $kind; $mode; $byte_count):
        exact_keys([
          "semantic_role","path_sha256","device_id","inode","uid","gid",
          "mode","acl_entry_count","xattr_names","security_flags",
          "file_type","byte_count","observed_nlink"
        ])
        and .semantic_role == $role
        and .path_sha256 == $path_sha
        and (.device_id | uint)
        and (.inode | positive_uint)
        and .uid == $effective_uid and .gid == $effective_gid
        and .mode == $mode
        and .acl_entry_count == 0 and (.xattr_names | allowed_xattrs)
        and .security_flags == 0 and .file_type == $kind
        and .byte_count == $byte_count
        and (if $kind == "regular_file" then
               .observed_nlink == 1
             else (.observed_nlink | uint) end);
      def projected_private_descriptor(
        $private; $role; $path_sha; $is_parent
      ):
        ($private
          | .acl_entry_count = .acl
          | del(.acl, .physical_path))
          + {semantic_role:$role,path_sha256:$path_sha}
          + (if $is_parent then {byte_count:null} else {} end);
      def environment_contract:
        exact_keys([
          "mlx_enable_tf32","mlx_checkout_origin","mlx_revision",
          "swiftpm_configuration","graph_mode","compile_transform_count",
          "os_build","xcode_build","swift_driver","swift_sdk",
          "staged_metallib_role","staged_metallib_path_sha256",
          "staged_metallib_byte_count_and_content_sha256",
          "runtime_metallib_role","runtime_metallib_path_sha256",
          "runtime_metallib_byte_count_and_content_sha256",
          "metal_name_registry_unified_max_buffer_recommended_set",
          "mlx_device_and_default_gpu_stream","stream_order",
          "evaluation_order","pre_post_identity_and_policy_equal",
          "root_and_validation_lock_bindings"
        ])
        and .mlx_enable_tf32 == "0"
        and .mlx_checkout_origin == $mlx_origin
        and .mlx_revision == $mlx_revision
        and .swiftpm_configuration == "release"
        and .graph_mode == "eager_uncompiled_no_compile_transform"
        and .compile_transform_count == 0
        and .os_build == $os_build
        and .xcode_build == $xcode_build
        and .swift_driver == $swift_driver
        and .swift_sdk == $swift_sdk
        and .staged_metallib_role == "staged_metallib"
        and .staged_metallib_path_sha256 == $staged_path_sha
        and (.staged_metallib_byte_count_and_content_sha256
          | exact_keys(["byte_count","sha256"])
            and .byte_count == $metallib_bytes
            and .sha256 == $metallib_sha)
        and .runtime_metallib_role == "runtime_metallib"
        and .runtime_metallib_path_sha256 == $runtime_path_sha
        and (.runtime_metallib_byte_count_and_content_sha256
          | exact_keys(["byte_count","sha256"])
            and .byte_count == $metallib_bytes
            and .sha256 == $metallib_sha)
        and (.metal_name_registry_unified_max_buffer_recommended_set
          | exact_keys([
              "name","registry_id","has_unified_memory",
              "max_buffer_length","recommended_max_working_set_size"
            ])
            and (.name | type == "string" and length > 0)
            and (.registry_id | uint)
            and .has_unified_memory == true
            and (.max_buffer_length | positive_uint)
            and (.recommended_max_working_set_size
              | positive_uint))
        and (.mlx_device_and_default_gpu_stream
          | exact_keys(["device","default_stream"])
            and .device == "gpu:0" and .default_stream == "gpu")
        and (.stream_order | type == "string" and length > 0)
        and (.evaluation_order | type == "string" and length > 0)
        and .pre_post_identity_and_policy_equal == true
        and .root_and_validation_lock_bindings == $locks
        and ([.root_and_validation_lock_bindings[] | lock_binding] | all);
      def phase_dependency_prefix(
        $counts; $phase_count; $checkpoint_count; $domain_count
      ):
        $counts.resource_measurement_synchronize_count == $phase_count
        and $counts.resource_measurement_checked_eval_count
          == [0,0,1,2,3,4,5,5,6,7,8,8,8][$phase_count]
        and $counts.final_commit_publication_count == $checkpoint_count
        and (if $counts.training_step_count >= 1 then
               $phase_count >= 2
             else true end)
        and (if $counts.training_step_count >= 2 then
               $phase_count >= 4
             else true end)
        and (if $counts.public_restore_load_count == 1 then
               $phase_count >= 7
             else true end)
        and (if $counts.training_step_count == 3 then
               $phase_count >= 8
             else true end)
        and (if $checkpoint_count >= 1 then
               $counts.training_step_count >= 1
             else true end)
        and (if $checkpoint_count >= 2 then
               $counts.training_step_count >= 2
             else true end)
        and (if $checkpoint_count == 3 then
               $counts.training_step_count == 3
             else true end)
        and (if $domain_count > 0 then
               $phase_count >= 10
               and $checkpoint_count == 3
               and $counts.training_step_count == 3
               and $counts.backward_count == 3
               and $counts.optimizer_update_count == 3
             else true end);
      def first_mismatch_shape:
        exact_keys([
          "availability","domain_id","path",
          "expected_binding","observed_binding"
        ])
        and (.availability == "available"
          or .availability == "not_applicable"
          or .availability == "unavailable")
        and (.domain_id == null
          or (.domain_id | type == "string" and length > 0))
        and (.path == null
          or (.path | type == "string" and length > 0))
        and (.expected_binding | nullable_hex64)
        and (.observed_binding | nullable_hex64);
      def public_contract_v1:
        $private_candidate[0] as $candidate
        | $private_terminal[0] as $terminal
        | . as $public
        | ($candidate.comparison_domains | length) as $candidate_domain_count
        | ($public.resource_phases | length) as $phase_count
        | ($public.checkpoint_and_comparator_bindings | length)
            as $checkpoint_count
        | exact_keys([
            "schema","authority_and_exact_main_bindings",
            "implementation_inventory","terminal_status",
            "one_shot_consumed","candidate_byte_count","candidate_sha256",
            "terminal_byte_count","terminal_sha256",
            "environment_and_device_bindings","operation_counts",
            "comparison_domain_results","first_mismatch_if_any",
            "resource_phases","checkpoint_and_comparator_bindings",
            "artifact_cleanup_and_absence","lease_and_verifier",
            "semantic_path_roles_and_path_sha256"
          ])
        and .schema == $schema
        and (.authority_and_exact_main_bindings
          | exact_keys([
              "authority_id","authority_canonical_sha256","repository",
              "revision","tree","ordered_parents","workflow_run_id",
              "workflow_run_number","run_attempt"
            ])
            and .authority_id == $authority
            and .authority_canonical_sha256 == $canonical
            and .repository == "Ergentics/ergentics-prime"
            and .revision == $revision and (.revision | hex40)
            and .tree == $tree and (.tree | hex40)
            and .ordered_parents == $parents
            and (.ordered_parents | length == 2 and all(.[]; hex40))
            and .workflow_run_id == $run_id
            and .workflow_run_number == $run_number
            and .run_attempt == $run_attempt and .run_attempt == 1)
        and .implementation_inventory == $inventory
        and (.implementation_inventory | length == 17)
        and ([.implementation_inventory[] | implementation_identity] | all)
        and .terminal_status == $candidate.terminal_scientific_status
        and .terminal_status == $terminal.candidate_status
        and (.terminal_status == "PASS_EXACT"
          or .terminal_status == "MEASURED_EXACT_MISMATCH"
          or .terminal_status == "ABSTAIN_RESOURCE"
          or .terminal_status == "ABSTAIN_INTEGRITY")
        and .one_shot_consumed == true
        and .one_shot_consumed == $candidate.one_shot.consumed
        and .candidate_byte_count == $candidate_bytes
        and (.candidate_byte_count | positive_uint and . <= 262144)
        and .candidate_sha256 == $candidate_sha
        and .candidate_sha256 == $terminal.candidate_sha256
        and (.candidate_sha256 | hex64)
        and .terminal_byte_count == $terminal_bytes
        and (.terminal_byte_count | positive_uint and . <= 65536)
        and .terminal_sha256 == $terminal_sha
        and (.terminal_sha256 | hex64)
        and (.environment_and_device_bindings | environment_contract)
        and .operation_counts == $candidate.operation_counts
        and (.operation_counts | exact_keys($exact_counts | keys))
        and ([$exact_counts | keys[] as $key
          | (.operation_counts[$key] | uint)
            and .operation_counts[$key] <= $exact_counts[$key]] | all)
        and operation_dependency_prefix(.operation_counts)
        and (.comparison_domain_results
          | type == "array" and length == 18)
        and ([range(0; 18) as $index
          | .comparison_domain_results[$index]
          | domain_result($domain_contracts[$index])] | all)
        and .comparison_domain_results[0:$candidate_domain_count]
          == $candidate.comparison_domains
        and (.comparison_domain_results[$candidate_domain_count:]
          | all(.[]; .exact == null))
        and ([.comparison_domain_results[].exact != null]
          | . == (sort | reverse))
        and (.first_mismatch_if_any | first_mismatch_shape)
        and .first_mismatch_if_any == $candidate.first_mismatch
        and .resource_phases == $candidate.resource_phases
        and (.resource_phases | type == "array" and length <= 12)
        and ([.resource_phases[] | phase_record] | all)
        and ([.resource_phases[].phase_id]
          == ([
            "preflight","post_initial_model_materialization",
            "post_baseline_step_and_evaluation",
            "post_baseline_gradient_release_and_baseline_four_leaf_publication",
            "post_uninterrupted_successor_step_and_evaluation",
            "post_uninterrupted_comparator_publication",
            "post_uninterrupted_state_deallocation_and_cache_clear",
            "post_fresh_weight_moment_and_control_restore",
            "post_resumed_successor_step_and_evaluation",
            "post_resumed_comparator_publication",
            "post_streaming_compare_artifact_cleanup_and_absence",
            "postflight"
          ][0:$phase_count]))
        and ([.resource_phases[].cumulative_elapsed_nanoseconds]
          | strictly_increasing)
        and ([.resource_phases[].mlx_peak_bytes] | nondecreasing)
        and ([.resource_phases[].getrusage_max_rss_bytes]
          | nondecreasing)
        and (if $phase_count == 0 then true else
               ([.resource_phases[].physical_memory_capacity_bytes]
                 | . as $values | all($values[]; . == $values[0]))
               and ([.resource_phases[].filesystem_fsid]
                 | . as $values | all($values[]; . == $values[0]))
               and ([.resource_phases[]
                 .verified_configured_memory_limit_copied_from_preflight_bytes]
                 | . as $values | all($values[]; . == $values[0]))
               and .resource_phases[0]
                   .verified_configured_memory_limit_copied_from_preflight_bytes
                 == ([
                   17179869184,
                   .environment_and_device_bindings
                     .metal_name_registry_unified_max_buffer_recommended_set
                     .recommended_max_working_set_size
                 ] | min)
             end)
        and .checkpoint_and_comparator_bindings == ([
            $candidate.baseline_checkpoint_binding,
            $candidate.uninterrupted_comparator_binding,
            $candidate.resumed_comparator_binding
          ] | map(select(. != null)))
        and (.checkpoint_and_comparator_bindings
          | type == "array" and length <= 3)
        and ([range(0; $checkpoint_count) as $index
          | .checkpoint_and_comparator_bindings[$index]
          | checkpoint_binding([
              "baseline_checkpoint",
              "uninterrupted_n_plus_1_comparator",
              "resumed_n_plus_1_comparator"
            ][$index]; $index == 0)] | all)
        and (.artifact_cleanup_and_absence | cleanup_contract)
        and (.artifact_cleanup_and_absence as $cleanup
          | $cleanup.known_inventory_before_cleanup as $known
          | $known <= 12
            and $checkpoint_count == (($known / 4) | floor)
            and $cleanup.deleted_known_leaf_count == $known
            and $cleanup.deleted_private_comparator_count
              == (if $known == 0 then 0
                  else (($known - 1) / 4) | floor end))
        and .artifact_cleanup_and_absence
          == $candidate.artifact_inventory_and_cleanup
        and (.lease_and_verifier
          | exact_keys([
              "lease_acquired","lease_release_count","verifier_executed",
              "verifier_exit_zero","supervisor_alive_during_verifier",
              "preflight_parent","post_candidate_parent",
              "post_candidate_leaf","verifier_parent","verifier_leaf",
              "inventory_exact"
            ])
            and .lease_acquired == true
            and .lease_release_count == 2
            and .verifier_executed == true
            and .verifier_exit_zero == true
            and .supervisor_alive_during_verifier == true
            and .inventory_exact == true
            and (.preflight_parent
              | public_descriptor(
                  "preflight_parent";$lease_root_sha;
                  "directory";"0700";null))
            and (.post_candidate_parent
              | public_descriptor(
                  "post_candidate_parent";$lease_root_sha;
                  "directory";"0700";null))
            and (.post_candidate_leaf
              | public_descriptor(
                  "post_candidate_leaf";$lease_path_sha;
                  "regular_file";"0600";0))
            and (.verifier_parent
              | public_descriptor(
                  "verifier_parent";$lease_root_sha;
                  "directory";"0700";null))
            and (.verifier_leaf
              | public_descriptor(
                  "verifier_leaf";$lease_path_sha;
                  "regular_file";"0600";0))
            and .preflight_parent == projected_private_descriptor(
              $terminal.private_raw_descriptor_tuples.preflight_parent;
              "preflight_parent";$lease_root_sha;true)
            and .post_candidate_parent == projected_private_descriptor(
              $terminal.private_raw_descriptor_tuples.post_candidate_parent;
              "post_candidate_parent";$lease_root_sha;true)
            and .post_candidate_leaf == projected_private_descriptor(
              $terminal.private_raw_descriptor_tuples.post_candidate_leaf;
              "post_candidate_leaf";$lease_path_sha;false)
            and .verifier_parent == projected_private_descriptor(
              $terminal.private_raw_descriptor_tuples.verifier_parent;
              "verifier_parent";$lease_root_sha;true)
            and .verifier_leaf == projected_private_descriptor(
              $terminal.private_raw_descriptor_tuples.verifier_leaf;
              "verifier_leaf";$lease_path_sha;false)
            and ((.preflight_parent
              | del(.semantic_role,.observed_nlink))
              == (.post_candidate_parent
                | del(.semantic_role,.observed_nlink)))
            and ((.post_candidate_parent
              | del(.semantic_role,.observed_nlink))
              == (.verifier_parent
                | del(.semantic_role,.observed_nlink)))
            and ((.post_candidate_leaf | del(.semantic_role))
              == (.verifier_leaf | del(.semantic_role))))
        and .semantic_path_roles_and_path_sha256 == [
          {
            semantic_role:"lease_root",path_sha256:$lease_root_sha,
            byte_count:null,content_sha256:null,
            raw_absolute_path_present:false
          },
          {
            semantic_role:"lease_path",path_sha256:$lease_path_sha,
            byte_count:null,content_sha256:null,
            raw_absolute_path_present:false
          },
          {
            semantic_role:"artifact_root",path_sha256:$artifact_root_sha,
            byte_count:null,content_sha256:null,
            raw_absolute_path_present:false
          },
          {
            semantic_role:"staged_metallib",path_sha256:$staged_path_sha,
            byte_count:$metallib_bytes,content_sha256:$metallib_sha,
            raw_absolute_path_present:false
          },
          {
            semantic_role:"runtime_metallib",path_sha256:$runtime_path_sha,
            byte_count:$metallib_bytes,content_sha256:$metallib_sha,
            raw_absolute_path_present:false
          }
        ]
        and ([.semantic_path_roles_and_path_sha256[]
          | exact_keys([
              "semantic_role","path_sha256","byte_count",
              "content_sha256","raw_absolute_path_present"
            ])
            and (.path_sha256 | hex64)
            and .raw_absolute_path_present == false] | all)
        and phase_dependency_prefix(
          .operation_counts;$phase_count;$checkpoint_count;
          $candidate_domain_count)
        and (if .terminal_status == "PASS_EXACT" then
               .operation_counts == $exact_counts
               and $phase_count == 12 and $checkpoint_count == 3
               and $candidate_domain_count == 18
               and .resource_phases[-1].cumulative_elapsed_nanoseconds
                 < 4800000000000
               and ([.resource_phases[]
                   .verified_configured_memory_limit_copied_from_preflight_bytes]
                 | all(.[]; . >= 4337713152))
               and .resource_phases[0].filesystem_available_bytes
                 >= 12884901888
               and ([.comparison_domain_results[].exact]
                 | all(. == true))
               and .first_mismatch_if_any == {
                 availability:"not_applicable",domain_id:null,path:null,
                 expected_binding:null,observed_binding:null
               }
             elif .terminal_status == "MEASURED_EXACT_MISMATCH" then
               .operation_counts == $exact_counts
               and $phase_count == 12 and $checkpoint_count == 3
               and $candidate_domain_count == 18
               and .resource_phases[-1].cumulative_elapsed_nanoseconds
                 < 4800000000000
               and ([.resource_phases[]
                   .verified_configured_memory_limit_copied_from_preflight_bytes]
                 | all(.[]; . >= 4337713152))
               and .resource_phases[0].filesystem_available_bytes
                 >= 12884901888
               and ([.comparison_domain_results[].exact]
                 | all(. == true or . == false))
               and ([.comparison_domain_results[].exact]
                 | any(. == false))
               and .first_mismatch_if_any.availability == "available"
               and .first_mismatch_if_any.domain_id
                 == ([.comparison_domain_results[]
                      | select(.exact == false)][0].domain_id)
               and .first_mismatch_if_any.path
                 == ([.comparison_domain_results[]
                      | select(.exact == false)][0].first_mismatch_path)
               and .first_mismatch_if_any.expected_binding
                 == ([.comparison_domain_results[]
                      | select(.exact == false)][0]
                        .first_mismatch_expected_binding)
               and .first_mismatch_if_any.observed_binding
                 == ([.comparison_domain_results[]
                      | select(.exact == false)][0]
                        .first_mismatch_observed_binding)
             elif .terminal_status == "ABSTAIN_RESOURCE" then
               (if .first_mismatch_if_any.domain_id
                       == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure" then
                      $phase_count >= 1 and $phase_count <= 12
                      and (if $phase_count >= 11 then
                             $candidate_domain_count == 18
                             and .operation_counts
                               == ($exact_counts
                                 | .resource_measurement_synchronize_count
                                   = $phase_count)
                             and ([.comparison_domain_results[].exact]
                               | all(. == true or . == false))
                           else
                             $candidate_domain_count < 18
                             and ([.comparison_domain_results[
                                 0:$candidate_domain_count][].exact]
                               | all(. == true))
                           end)
                    else
                      $phase_count >= 1 and $phase_count < 12
                      and $candidate_domain_count < 18
                      and ([.comparison_domain_results[
                          0:$candidate_domain_count][].exact]
                        | all(. == true))
                    end)
               and .first_mismatch_if_any.availability == "unavailable"
               and (.first_mismatch_if_any.domain_id
                 == "memory_limit_below_minimum_floor"
                 or .first_mismatch_if_any.domain_id
                   == "filesystem_available_below_three_set_floor"
                 or .first_mismatch_if_any.domain_id
                   == "positively_identified_enomem"
                 or .first_mismatch_if_any.domain_id
                   == "positively_identified_enospc"
                 or .first_mismatch_if_any.domain_id
                   == "positively_identified_mlx_memory_limit_exhaustion"
                 or .first_mismatch_if_any.domain_id
                   == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure")
               and (if .first_mismatch_if_any.domain_id
                       == "memory_limit_below_minimum_floor"
                       or .first_mismatch_if_any.domain_id
                         == "filesystem_available_below_three_set_floor" then
                      true
                    else
                      .resource_phases[0]
                          .verified_configured_memory_limit_copied_from_preflight_bytes
                        >= 4337713152
                      and .resource_phases[0].filesystem_available_bytes
                        >= 12884901888
                    end)
               and (if .first_mismatch_if_any.domain_id
                       == "memory_limit_below_minimum_floor" then
                      .environment_and_device_bindings
                          .metal_name_registry_unified_max_buffer_recommended_set
                          .recommended_max_working_set_size > 0
                      and .resource_phases[0]
                          .verified_configured_memory_limit_copied_from_preflight_bytes
                        < 4337713152
                      and .first_mismatch_if_any.path
                        == "device_and_stream.configured_memory_limit_bytes"
                      and .first_mismatch_if_any.expected_binding
                        == $memory_floor_expected
                      and .first_mismatch_if_any.observed_binding
                        == $memory_floor_observed
                    elif .first_mismatch_if_any.domain_id
                       == "filesystem_available_below_three_set_floor" then
                      .resource_phases[0].filesystem_available_bytes
                        < 12884901888
                      and .first_mismatch_if_any.path
                        == "resource_phases[0].filesystem_available_bytes"
                      and .first_mismatch_if_any.expected_binding
                        == $filesystem_floor_expected
                      and .first_mismatch_if_any.observed_binding
                        == $filesystem_floor_observed
                    elif .first_mismatch_if_any.domain_id
                       == "positively_identified_enomem" then
                      .first_mismatch_if_any.path == "errno"
                      and .first_mismatch_if_any.expected_binding == null
                      and .first_mismatch_if_any.observed_binding
                        == $enomem_observed
                    elif .first_mismatch_if_any.domain_id
                       == "positively_identified_enospc" then
                      .first_mismatch_if_any.path == "errno"
                      and .first_mismatch_if_any.expected_binding == null
                      and .first_mismatch_if_any.observed_binding
                        == $enospc_observed
                    elif .first_mismatch_if_any.domain_id
                       == "positively_identified_mlx_memory_limit_exhaustion" then
                      .first_mismatch_if_any.path
                        == "resource_phases[last].mlx_peak_bytes"
                      and .resource_phases[-1].mlx_peak_bytes
                        >= .resource_phases[0]
                          .verified_configured_memory_limit_copied_from_preflight_bytes
                      and .first_mismatch_if_any.expected_binding == null
                      and .first_mismatch_if_any.observed_binding
                        == $mlx_memory_limit_observed
                    else
                      .first_mismatch_if_any.path
                        == "resource_phases[last].cumulative_elapsed_nanoseconds"
                      and .first_mismatch_if_any.expected_binding == null
                      and .resource_phases[-1]
                          .cumulative_elapsed_nanoseconds
                        >= 4800000000000
                      and .first_mismatch_if_any.observed_binding
                        == $worker_timeout_observed
                    end)
             else
               $candidate_domain_count >= 1
               and ([.comparison_domain_results[
                   0:($candidate_domain_count - 1)][]
                 .exact] | all(. == true))
               and .comparison_domain_results[
                 $candidate_domain_count - 1].exact == null
               and .first_mismatch_if_any.availability == "unavailable"
               and .first_mismatch_if_any.domain_id
                 == .comparison_domain_results[
                   $candidate_domain_count - 1].domain_id
               and (.first_mismatch_if_any.path
                 | type == "string" and length > 0)
               and (.first_mismatch_if_any.expected_binding | hex64)
               and (.first_mismatch_if_any.observed_binding | hex64)
               and .first_mismatch_if_any.expected_binding
                 != .first_mismatch_if_any.observed_binding
               and $terminal.first_failed_guard.classification
                 == "ABSTAIN_INTEGRITY"
               and $terminal.first_failed_guard.guard_id
                 == .first_mismatch_if_any.domain_id
               and (if $fixed_member_paths[
                          .first_mismatch_if_any.domain_id] != null then
                      ($fixed_member_paths[
                          .first_mismatch_if_any.domain_id]
                        | index($public.first_mismatch_if_any.path)) != null
                    else exact_catalog_member_path(
                      .first_mismatch_if_any.domain_id;
                      $public.first_mismatch_if_any.path) end)
             end)
        and ([.. | strings | select(startswith("/"))] | length) == 0;
      def safely_public_contract_v1:
        try public_contract_v1 catch false;
      . as $public
      | ($public | safely_public_contract_v1)
      and ([
        ($public + {unexpected_schema_key:true}
          | safely_public_contract_v1),
        ($public | .schema = "mutated"
          | safely_public_contract_v1),
        ($public | .authority_and_exact_main_bindings.revision = "mutated"
          | safely_public_contract_v1),
        ($public | .implementation_inventory = []
          | safely_public_contract_v1),
        ($public | .candidate_byte_count = 0
          | safely_public_contract_v1),
        ($public
          | .environment_and_device_bindings
              .mlx_device_and_default_gpu_stream.device = "cpu:0"
          | safely_public_contract_v1),
        ($public
          | .environment_and_device_bindings
              .root_and_validation_lock_bindings |= reverse
          | safely_public_contract_v1),
        ($public
          | .operation_counts.training_step_count = 0
          | .operation_counts.optimizer_update_count = 1
          | safely_public_contract_v1),
        ($public | .comparison_domain_results |= reverse
          | safely_public_contract_v1),
        ($public
          | .comparison_domain_results[0].catalog_preimage_schema = "mutated"
          | safely_public_contract_v1),
        ($public | .resource_phases[0].phase_id = "mutated"
          | safely_public_contract_v1),
        ($public
          | .checkpoint_and_comparator_bindings[0].set_role = "mutated"
          | safely_public_contract_v1),
        ($public | .artifact_cleanup_and_absence.unknown_inventory_count = 1
          | safely_public_contract_v1),
        ($public | .lease_and_verifier.verifier_exit_zero = false
          | safely_public_contract_v1),
        ($public
          | .lease_and_verifier.post_candidate_leaf.byte_count = 1
          | safely_public_contract_v1),
        ($public
          | .lease_and_verifier.post_candidate_leaf.xattr_names =
              ["com.apple.quarantine"]
          | safely_public_contract_v1),
        ($public
          | .semantic_path_roles_and_path_sha256[0]
              .raw_absolute_path_present = true
          | safely_public_contract_v1),
        ($public | .environment_and_device_bindings.swift_driver = "/raw"
          | safely_public_contract_v1)
      ] | all(. == false))
    ' >/dev/null ||
    fail "public receipt projection, outcome, or synthetic mutation changed"

jq -cSj . "$public_json_path" >"$public_canonical_path" ||
    fail "public receipt canonicalization failed"
assert_regular_file "$public_json_path"
assert_regular_file "$public_canonical_path"
cmp -s "$public_json_path" "$public_canonical_path" ||
    fail "public receipt was not constructed as canonical sorted-key JSON"
readonly public_receipt_byte_count="$(stat -f %z "$public_canonical_path")"
[[ "$public_receipt_byte_count" -gt 0 \
    && "$public_receipt_byte_count" -le "$public_receipt_maximum_byte_count" \
    && "$(LC_ALL=C tr -cd '\n\r' <"$public_canonical_path" | wc -c | \
        tr -d '[:space:]')" == "0" \
    && "$(occurrence_count "$receipt_prefix" "$public_canonical_path")" \
        == "0" ]] ||
    fail "public receipt encoding, byte ceiling, or prefix boundary changed"
[[ "$maximal_public_receipt_fixture_byte_count" -le \
        "$public_receipt_maximum_byte_count" ]] ||
    fail "pure maximal-receipt ceiling exceeds the publication ceiling"

readonly public_json="$(<"$public_canonical_path")"
readonly public_line="${receipt_prefix}${public_json}"
trap - EXIT HUP INT TERM
exec /usr/bin/printf '%s\n' "$public_line"
