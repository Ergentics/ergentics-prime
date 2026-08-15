#!/usr/bin/env bash
# One exact-main B-specific Native-300M resource witness. The Release
# executable owns the bounded supervisor, resource-worker, and distinct
# release-verifier topology. Candidate and terminal framing stays private;
# their validated canonical evidence is nested in the sole public receipt.
# This launcher alone may publish one final canonical PASS, ABSTAIN, or
# ABSTAIN_INTEGRITY receipt, and it never retries the consumed opportunity.
set -euo pipefail
IFS=$'\n\t'
umask 077

fail() {
    /usr/bin/printf '%s\n' \
        "prime-ci-native-decoder-b-specific-native300m-resource-witness: $*" \
        >&2
    exit 2
}

trap 'exit 130' HUP INT TERM

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"

readonly required_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly authority_id="prime_native_decoder_b_specific_native300m_resource_witness_authority_v1"
readonly authority_canonical_sha256="15e00a65594a69e380e93362dc22103ccf3ae42de2676ef9e459b4603af887ba"
readonly candidate_schema_id="ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_candidate_v1"
readonly terminal_schema_id="ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_terminal_v1"
readonly receipt_schema_id="ergentics_prime_native_decoder_b_specific_native300m_resource_witness_receipt_v1"
readonly candidate_prefix="PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_INTERNAL_CANDIDATE_V1="
readonly terminal_prefix="PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_INTERNAL_TERMINAL_V1="
readonly receipt_prefix="PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_RECEIPT_V1="
readonly original_stage5_receipt_prefix="PRIME_NATIVE_DECODER_STAGE5_TINY_REPEATED_METAL_TRAJECTORY_DETERMINISM_RECEIPT="
readonly replacement_stage5_receipt_prefix="PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_RECEIPT_V1="
readonly historical_stage6_receipt_prefix="PRIME_NATIVE_DECODER_STAGE6_NATIVE300M_RESOURCE_ONLY_ONE_STEP_RECEIPT="
readonly candidate_maximum_count="1"
readonly terminal_exact_count="1"
readonly public_receipt_maximum_count="1"
readonly candidate_schema_key_count="8"
readonly terminal_schema_key_count="26"
readonly public_receipt_schema_key_count="39"
readonly public_receipt_maximum_byte_count="1048576"
readonly launcher_environment_binding_count="54"
readonly integrity_guard_count="18"

# Terminal green pure-authority closure: exact main merge / PR 112 / run 121.
readonly authority_closure_revision="b1695b17523068e2b720066d84c422cbe2e67975"
readonly authority_closure_tree="3b910fe8bbdec008cf9665b6208292f7c1c0c7f3"
readonly authority_closure_first_parent="7be3d77ad3ed3ae3ec7ec10d0aed6231c1083be4"
readonly authority_closure_second_parent="ff612ddc6420bc7db0f4993b7aeff7e17fb3f9bc"
readonly authority_closure_reviewed_head="$authority_closure_second_parent"
readonly authority_closure_pull_request_number="112"
readonly authority_closure_run_id="31850975271"
readonly authority_closure_run_number="121"
readonly authority_closure_run_attempt="1"
readonly authority_closure_check_suite_id="86410537152"
readonly authority_closure_active_job_id="94926582838"
readonly authority_closure_active_job_image="macos-15"
readonly authority_closure_active_job_conclusion="success"
readonly authority_closure_reviewed_job_id="94927151419"
readonly authority_closure_reviewed_job_image="macos-26"
readonly authority_closure_reviewed_job_conclusion="success"
readonly authority_closure_event="push"
readonly authority_closure_ref="refs/heads/main"
readonly authority_closure_status="completed"
readonly authority_closure_conclusion="success"
readonly authority_closure_artifact_count="0"
readonly authority_closure_rerun_count="0"

readonly authority_source_relative_path="Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthority.swift"
readonly authority_test_relative_path="Tests/PrimeCoreTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityTests.swift"
readonly launcher_relative_path=".github/scripts/prime-ci-native-decoder-b-specific-native300m-resource-witness.sh"
readonly gate_relative_path=".github/scripts/prime-ci-active-root-quarantine.sh"
readonly workflow_relative_path=".github/workflows/prime-active-root-quarantine.yml"
readonly provenance_relative_path="Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"
readonly training_probe_relative_path="Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift"
readonly validation_manifest_relative_path="Tests/PrimeNativeDecoderTrainingValidation/Package.swift"
readonly executable_main_relative_path="Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MResourceWitness/main.swift"
readonly contract_test_relative_path="Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests.swift"
readonly model_source_relative_path="Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift"
readonly lease_source_relative_path="Sources/PrimeCore/PrimeMetalDeviceLease.swift"
readonly existing_training_source_relative_path="Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"
readonly expected_preserved_index_sha256="de530cb1b5e6c2d8612d97ca1d22a0378fe530a6915dab88648a5caf3dae056d"

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
readonly focused_contract_log="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-focused-contract-tests.log"
readonly metal_log="$runner_temp/prime-native-decoder-metal-tests.log"
readonly runtime_test_log="$runner_temp/prime-native-decoder-runtime-closure-authority-tests.log"
readonly runtime_probe_log="$runner_temp/prime-native-decoder-runtime-closure-probe.log"
readonly tokenizer_test_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-authority-tests.log"
readonly tokenizer_probe_log="$runner_temp/prime-native-decoder-tokenizer-compatibility-probe.log"

readonly scratch_path="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-build"
readonly cache_path="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-cache"
readonly config_path="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-config"
readonly security_path="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-security"
readonly private_cwd="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-cwd"
readonly lease_root="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-metal-lease"
readonly lease_path="$lease_root/device-0.lock"
readonly launcher_contract_log="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-launcher-contract-tests.log"
readonly supervisor_log="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-supervisor.log"
readonly supervisor_stderr_log="$runner_temp/prime-native-decoder-b-specific-native300m-resource-witness-supervisor-stderr.log"
readonly contract_class="PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests"
readonly contract_method="testBSpecificNative300MResourceWitnessContractIsExactAndExecutionPure"
readonly contract_filter="${contract_class}/${contract_method}"
readonly expected_root_test_count="60"
readonly expected_isolated_test_count="6"
readonly expected_focused_contract_test_count="1"
readonly expected_focused_whole_test_count="67"
readonly expected_metal_test_count="44"
readonly expected_maintained_runtime_test_count="1"
readonly expected_tokenizer_test_count="1"
readonly expected_launcher_contract_test_count="1"
readonly expected_live_xctest_count="47"
readonly expected_total_xctest_count="114"
readonly expected_original_stage5_launcher_invocation_count="0"
readonly expected_replacement_stage5_launcher_invocation_count="0"
readonly expected_historical_stage6_launcher_invocation_count="0"

[[ "$expected_focused_whole_test_count" -eq \
        $((expected_root_test_count + expected_isolated_test_count \
            + expected_focused_contract_test_count)) \
    && "$expected_live_xctest_count" -eq \
        $((expected_metal_test_count \
            + expected_maintained_runtime_test_count \
            + expected_tokenizer_test_count \
            + expected_launcher_contract_test_count)) \
    && "$expected_total_xctest_count" -eq \
        $((expected_focused_whole_test_count \
            + expected_live_xctest_count)) ]] ||
    fail "frozen successor XCTest accounting changed"

for command_name in awk bash chmod cmp cp dirname env find git grep id jq \
    ls mkdir otool pwd shasum sort stat swift sw_vers tee tr uname wc \
    xattr xcodebuild xcrun; do
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
    [[ "$(/usr/bin/printf '%s\n' "$index_record" | wc -l | tr -d '[:space:]')" == "1" ]] ||
        fail "source identity index record is not singular: $relative_path"
    mode="$(/usr/bin/printf '%s\n' "$index_record" | awk '{print $1}')"
    blob="$(/usr/bin/printf '%s\n' "$index_record" | awk '{print $2}')"
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
    local expected_bytes="$4" expected_sha="$5" observed
    observed="$(source_identity_json "$prime_root" "$relative_path")"
    /usr/bin/printf '%s' "$observed" | jq -e \
        --arg path "$relative_path" --arg mode "$expected_mode" \
        --arg blob "$expected_blob" --argjson bytes "$expected_bytes" \
        --arg sha "$expected_sha" \
        '. == {byte_count:$bytes,git_blob:$blob,mode:$mode,path:$path,sha256:$sha}' \
        >/dev/null || fail "pinned file identity changed: $relative_path"
}

occurrence_count() {
    local needle="$1" path="$2"
    awk -v needle="$needle" '
        { line = $0; while ((position = index(line, needle)) > 0) {
            count += 1; line = substr(line, position + length(needle))
        }} END { print count + 0 }
    ' "$path"
}

anchored_prefix_count() {
    local needle="$1" path="$2"
    awk -v needle="$needle" 'index($0, needle) == 1 { count += 1 }
        END { print count + 0 }' "$path"
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
    fail "push event is not the direct B-witness mechanics successor"
[[ -z "${ERGENTICS_MLX_READ_TOKEN:-}" ]] ||
    fail "dependency credential reached the B resource witness"

while IFS='=' read -r inherited_key _; do
    case "$inherited_key" in
        MLX_*|DYLD_*|LLVM_PROFILE_*|GIT_CONFIG_COUNT|GIT_CONFIG_KEY_*|GIT_CONFIG_VALUE_*|PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_*)
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
            for exact_successor_path in "${exact_successor_paths[@]}"; do
                if [[ "$relative_path" == "$exact_successor_path" ]]; then
                    skip_record=true
                    break
                fi
            done
            [[ "$skip_record" == true ]] || /usr/bin/printf '%s\n' "$index_record"
        done
} | LC_ALL=C sort | shasum -a 256 | awk '{print $1}')"
[[ "$observed_preserved_index_sha256" == "$expected_preserved_index_sha256" ]] ||
    fail "B-witness mechanics changed a path outside the exact eight-path closure"
for exact_successor_path in "${exact_successor_paths[@]}"; do
    expected_mode="100644"
    case "$exact_successor_path" in
        .github/scripts/*) expected_mode="100755" ;;
    esac
    [[ "$(git -C "$prime_root" ls-files -s -- "$exact_successor_path" | \
        awk '{print $1}')" == "$expected_mode" ]] ||
        fail "exact successor path is missing or has wrong mode: $exact_successor_path"
done

assert_pinned_file "$authority_source_relative_path" \
    "100644" "6712e7951d282b2a7169484b618584904e72e9a6" "144770" \
    "f5d23cd0a3cf6c5d0c60ab9bb1b80eb2a15a49f61f002c3dbc89609b2d9d58c4"
assert_pinned_file "$authority_test_relative_path" \
    "100644" "97fa185a0afc9aab8b83cbdd4f7f78f0a14d8433" "28919" \
    "d1ed3fb89c310ea1d38b1eca8485cf7c3d071a3f5815887415914c40dc3a0543"
assert_pinned_file "$model_source_relative_path" \
    "100644" "de6cff4472de55a8fafe2962c3be4ca37c972caf" "43339" \
    "ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc"
assert_pinned_file "$lease_source_relative_path" \
    "100644" "da3daa54802b67dc2c8c04a89b388e9927dd8726" "16985" \
    "edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657"
assert_pinned_file "$existing_training_source_relative_path" \
    "100644" "4566477e14b4b6cfa06286f384f07f8d452e8724" "97449" \
    "cab64f1e77d6f72bfef971bb8e1e4c40aee6072c1ed21f3b466599328f88fdcb"
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
    for exact_successor_path in "${exact_successor_paths[@]}"; do
        source_identity_json "$prime_root" "$exact_successor_path"
    done | jq -csS 'sort_by(.path)'
)"
[[ "$(/usr/bin/printf '%s' "$exact_changed_source_identities_json" | jq 'length')" == "8" \
    && "$(/usr/bin/printf '%s' "$exact_changed_source_identities_json" | jq -cS .)" \
        == "$exact_changed_source_identities_json" ]] ||
    fail "exact changed source identity array is invalid"

readonly embedded_source_identity="$(awk '
    /public static let sourceIdentitySHA256/ { getline; gsub(/[ "\t]/, ""); print; exit }
' "$prime_root/$provenance_relative_path")"
[[ "$embedded_source_identity" =~ ^[0-9a-f]{64}$ ]] ||
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
grep -Fq 'Executed 60 tests, with 0 failures' "$active_root_log" ||
    fail "root-60 contracts did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_log" ||
    fail "checkpoint compatibility predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_io_log" ||
    fail "checkpoint I/O predecessor did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' "$checkpoint_v2_io_execution_log" ||
    fail "checkpoint I/O execution predecessor did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' "$checkpoint_v2_io_root_repair_log" ||
    fail "checkpoint root-repair predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$focused_contract_log" ||
    fail "focused B-witness pure contract did not complete"
grep -Fq "$contract_class" "$focused_contract_log" ||
    fail "focused B-witness pure contract identity changed"
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
    [[ "$(occurrence_count "$candidate_prefix" "$predecessor_log")" == "0" \
        && "$(occurrence_count "$terminal_prefix" "$predecessor_log")" == "0" \
        && "$(occurrence_count "$receipt_prefix" "$predecessor_log")" == "0" \
        && "$(occurrence_count "$original_stage5_receipt_prefix" "$predecessor_log")" == "0" \
        && "$(occurrence_count "$replacement_stage5_receipt_prefix" "$predecessor_log")" == "0" \
        && "$(occurrence_count "$historical_stage6_receipt_prefix" "$predecessor_log")" == "0" ]] ||
        fail "retired or B-witness receipt prefix existed before the one-shot launcher"
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
        == "$numerics_revision" ]] ||
    fail "root Swift Numerics cache topology changed"

assert_pinned_mlx_source() {
    local relative_path="$1" expected_blob="$2" expected_bytes="$3"
    local expected_sha="$4" observed
    observed="$(source_identity_json "$mlx_source" "$relative_path")"
    /usr/bin/printf '%s' "$observed" | jq -e --arg path "$relative_path" \
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
[[ "$(/usr/bin/printf '%s' "$provenance_source_identities_json" | jq -cS .)" \
    == "$provenance_source_identities_json" \
    && "$(/usr/bin/printf '%s' "$provenance_source_identities_json" | \
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
    "$launcher_contract_log" "$supervisor_log" "$supervisor_stderr_log"; do
    [[ ! -e "$fresh_path" && ! -L "$fresh_path" ]] ||
        fail "B-witness path must be initially absent: $fresh_path"
done
mkdir -p "$cache_path" "$config_path" "$security_path"

export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0="url.file://${mlx_bare}/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/Ergentics/ergentics-mlx-swift"
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

# The launcher's one pure-contract XCTest start reuses the Release build.
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
readonly executable="$bin_path/PrimeNativeDecoderBSpecificNative300MResourceWitness"
readonly staged_metallib="$bin_path/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
[[ -x "$executable" && -f "$executable" && ! -L "$executable" \
    && "$(stat -f %l "$executable")" == "1" ]] ||
    fail "Release B-witness executable is missing or aliased"
for framework in CoreGraphics Metal; do
    otool -L "$executable" | grep -Fq "/${framework}.framework/" ||
        fail "Release B-witness executable does not link ${framework}"
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
readonly effective_gid="$(id -g)"
for private_directory in "$private_cwd" "$lease_root"; do
    [[ -d "$private_directory" && ! -L "$private_directory" \
        && "$(cd "$private_directory" && pwd -P)" == "$private_directory" \
        && "$(stat -f %u "$private_directory")" == "$effective_uid" \
        && "$(stat -f %Lp "$private_directory")" == "700" \
        && -z "$(find "$private_directory" -mindepth 1 -print)" ]] ||
        fail "private B-witness directory is invalid: $private_directory"
done

readonly operating_system_build="$(sw_vers -productVersion)-$(sw_vers -buildVersion)"
readonly kernel_identity="$(uname -srvmp)"
readonly swift_toolchain="$(swift --version | tr '\n' ' ' | awk '{$1=$1; print}')"
readonly xcode_toolchain="$(xcodebuild -version | tr '\n' ' ' | awk '{$1=$1; print}')"
readonly macos_sdk="$(xcrun --sdk macosx --show-sdk-version)"

# Mechanics begins here and consumes the sole opportunity even if no safe
# terminal publication can later be formed. There is no second invocation.
set +e
(
    cd "$private_cwd"
    env \
        TMPDIR="$runner_temp" \
        MLX_ENABLE_TF32=0 \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_EXECUTABLE_PATH="$executable" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_LEASE_ROOT="$lease_root" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_PRIVATE_WORKING_DIRECTORY="$private_cwd" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_ID="$authority_id" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CANONICAL_SHA256="$authority_canonical_sha256" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_SOURCE_IDENTITY_JSON="$authority_source_identity_json" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_TEST_IDENTITY_JSON="$authority_test_identity_json" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_BASE_REVISION="7be3d77ad3ed3ae3ec7ec10d0aed6231c1083be4" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_BASE_TREE="428097e2bf01276b91c9f4d7023a3c6ad496c4ca" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVISION="$authority_closure_revision" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_TREE="$authority_closure_tree" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_FIRST_PARENT="$authority_closure_first_parent" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_SECOND_PARENT="$authority_closure_second_parent" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVIEWED_HEAD="$authority_closure_reviewed_head" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_PULL_REQUEST_NUMBER="$authority_closure_pull_request_number" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_RUN_ID="$authority_closure_run_id" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_RUN_NUMBER="$authority_closure_run_number" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_RUN_ATTEMPT="$authority_closure_run_attempt" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_CHECK_SUITE_ID="$authority_closure_check_suite_id" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_ACTIVE_JOB_ID="$authority_closure_active_job_id" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_ACTIVE_JOB_IMAGE="$authority_closure_active_job_image" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_ACTIVE_JOB_CONCLUSION="$authority_closure_active_job_conclusion" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVIEWED_JOB_ID="$authority_closure_reviewed_job_id" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVIEWED_JOB_IMAGE="$authority_closure_reviewed_job_image" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REVIEWED_JOB_CONCLUSION="$authority_closure_reviewed_job_conclusion" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_EVENT="$authority_closure_event" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_REF="$authority_closure_ref" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_STATUS="$authority_closure_status" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_CONCLUSION="$authority_closure_conclusion" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_ARTIFACT_COUNT="$authority_closure_artifact_count" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_AUTHORITY_CLOSURE_RERUN_COUNT="$authority_closure_rerun_count" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_EXECUTED_REVISION="$exact_revision" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_EXECUTED_TREE="$exact_tree" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_FIRST_PARENT="$first_parent" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_SECOND_PARENT="$second_parent" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_EVENT="$GITHUB_EVENT_NAME" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_REF="$GITHUB_REF" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_RUN_ID="$GITHUB_RUN_ID" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_RUN_NUMBER="$GITHUB_RUN_NUMBER" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MECHANICS_RUN_ATTEMPT="$GITHUB_RUN_ATTEMPT" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_EXACT_CHANGED_SOURCE_IDENTITIES_JSON="$exact_changed_source_identities_json" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_PROVENANCE_SOURCE_IDENTITIES_JSON="$provenance_source_identities_json" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_EMBEDDED_SOURCE_IDENTITY_SHA256="$embedded_source_identity" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_EXACT_MLX_REVISION="$mlx_revision" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_METALLIB_PATH="$staged_metallib" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_METALLIB_BYTES="$metallib_byte_count" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_METALLIB_SHA256="$metallib_sha256" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_OPERATING_SYSTEM_BUILD="$operating_system_build" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_KERNEL_IDENTITY="$kernel_identity" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_SWIFT_TOOLCHAIN="$swift_toolchain" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_XCODE_TOOLCHAIN="$xcode_toolchain" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MACOS_SDK="$macos_sdk" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_BUILD_CONFIGURATION="release" \
        PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_MLX_GRAPH_COMPILE_MODE="eager_uncompiled_no_compile_transform" \
        "$executable"
) >"$supervisor_log" 2>"$supervisor_stderr_log"
supervisor_status=$?
set -e

assert_regular_file "$supervisor_log"
assert_regular_file "$supervisor_stderr_log"
[[ "$(occurrence_count "$receipt_prefix" "$supervisor_log")" == "0" \
    && "$(occurrence_count "$receipt_prefix" "$supervisor_stderr_log")" == "0" ]] ||
    fail "worker or supervisor emitted a public receipt"
readonly candidate_count="$(anchored_prefix_count "$candidate_prefix" "$supervisor_log")"
readonly terminal_count="$(anchored_prefix_count "$terminal_prefix" "$supervisor_log")"
readonly packet_line_count="$(wc -l < "$supervisor_log" | awk '{print $1}')"
[[ "$candidate_count" =~ ^[01]$ \
    && "$candidate_count" -le "$candidate_maximum_count" \
    && "$terminal_count" == "$terminal_exact_count" \
    && "$packet_line_count" -eq $((candidate_count + 1)) \
    && "$(occurrence_count "$candidate_prefix" "$supervisor_log")" == "$candidate_count" \
    && "$(occurrence_count "$terminal_prefix" "$supervisor_log")" == "1" \
    && "$(occurrence_count "$candidate_prefix" "$supervisor_stderr_log")" == "0" \
    && "$(occurrence_count "$terminal_prefix" "$supervisor_stderr_log")" == "0" ]] ||
    fail "supervisor private packet framing is malformed or duplicate"
if [[ "$candidate_count" == "1" ]]; then
    [[ "$(sed -n '1p' "$supervisor_log")" == "${candidate_prefix}"* \
        && "$(sed -n '2p' "$supervisor_log")" == "${terminal_prefix}"* ]] ||
        fail "candidate and terminal packet order changed"
else
    [[ "$(sed -n '1p' "$supervisor_log")" == "${terminal_prefix}"* ]] ||
        fail "candidate-free terminal packet order changed"
fi

candidate_json="null"
candidate_sha256="null"
candidate_canonical_byte_count="null"
candidate_scientific_status="null"
candidate_classification="null"
if [[ "$candidate_count" == "1" ]]; then
    candidate_json="$(awk -v prefix="$candidate_prefix" '
        index($0, prefix) == 1 { print substr($0, length(prefix) + 1) }
    ' "$supervisor_log")"
    candidate_canonical_byte_count="$(printf '%s' \
        "$candidate_json" | wc -c | awk '{print $1}')"
    [[ "$candidate_canonical_byte_count" -le 1048576 \
        && "$(printf '%s' "$candidate_json" | jq -cS .)" == "$candidate_json" ]] ||
        fail "private candidate is oversized or noncanonical"
    printf '%s' "$candidate_json" | jq -e \
        --arg schema "$candidate_schema_id" \
        --arg authority "$authority_id" \
        --arg canonical "$authority_canonical_sha256" \
        --arg mlx_revision "$mlx_revision" \
        --arg metallib_path "$staged_metallib" \
        --argjson metallib_bytes "$metallib_byte_count" \
        --arg metallib_sha "$metallib_sha256" \
        --arg lease_path "$lease_path" \
        --arg operating_system_build "$operating_system_build" \
        --arg swift_sdk "$macos_sdk" \
        --arg swift_version "$swift_toolchain" \
        --arg xcode_version "$xcode_toolchain" \
        '
         def exact_keys($expected): keys == ($expected | sort);
         def nonnegative_integer:
           type == "number" and . >= 0 and . == floor;
         def positive_integer: nonnegative_integer and . > 0;
         def uint32: nonnegative_integer and . <= 4294967295;
         def hex64:
           type == "string" and test("^[0-9a-f]{64}$");
         def finite_float32_bits:
           uint32 and (((. / 8388608) | floor) % 256) != 255;
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
           | if $exponent == 0 then $fraction * pow(2; -149)
             else (1 + ($fraction / 8388608))
               * pow(2; $exponent - 127) end;
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
                 else ($unbiased + 127) * 8388608 + $rounded_fraction end
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
         def resource_class:
           . == "worker_spawn_failure" or . == "preflight_floor"
           or . == "lease_busy" or . == "oom" or . == "timeout"
           or . == "signal" or . == "nonfinite"
           or . == "topology_dtype" or . == "no_update";
         def metal_observation_keys: [
           "metal_device_count","metal_device_has_unified_memory",
           "metal_device_index","metal_device_is_default",
           "metal_device_max_buffer_length_bytes",
           "metal_device_max_recommended_working_set_bytes",
           "metal_device_name","metal_device_registry_id"
         ];
         def mlx_policy_observation_keys: [
           "mlx_cpu_fallback_used",
           "mlx_default_device_is_supplied_device",
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
         def postflight_outcome_observation_keys: [
           "postflight_device_identity_matches_preflight",
           "postflight_mlx_policy_and_limits_match_preflight"
         ];
         def numeric_phase_metric_keys: [
           "cumulative_worker_probe_elapsed_nanoseconds",
           "filesystem_available_bytes","filesystem_capacity_bytes",
           "getrusage_max_rss_bytes","metal_current_allocated_bytes",
           "mlx_active_bytes","mlx_cache_bytes","mlx_peak_bytes",
           "physical_memory_capacity_bytes","task_physical_footprint_bytes",
           "task_resident_bytes"
         ];
         def pass_measured_mlx_peak_below_configured_limit:
           . as $payload
           | ($payload.phase_metrics
             | all(.mlx_peak_bytes
               < $payload.limits.configured_memory_limit_bytes));
         def operation_keys: [
           "adamw_update_count","backward_count",
           "checked_evaluation_barrier_count","cross_entropy_count",
           "dense_embedding_construction_count",
           "direct_package_b_training_logits_api_call_count",
           "evaluation_forward_pass_count","forward_loss_count",
           "full_graph_evaluation_count",
           "gpu_synchronization_barrier_count","gradient_clip_count",
           "gradient_norm_count","kv_cache_allocation_count",
           "input_embedding_forward_pair_diagnostic_invocation_count",
           "maintained_gather_training_logits_count",
           "memory_clear_cache_count","mlx_peak_memory_reset_count",
           "model_allocation_count","model_materialization_count",
           "optimizer_step_count","postflight_device_reenumeration_count",
           "tiny_training_selector_invocation_count",
           "token_bounds_checked_eval_count",
           "token_bounds_gpu_synchronization_count",
           "token_bounds_host_bool_item_count",
           "token_bounds_validation_count","value_and_grad_count"
         ];
         def phase_keys: [
           "availability","cumulative_worker_probe_elapsed_nanoseconds",
           "filesystem_available_bytes","filesystem_capacity_bytes",
           "getrusage_max_rss_bytes","metal_current_allocated_bytes",
           "mlx_active_bytes","mlx_cache_bytes","mlx_peak_bytes","phase",
           "physical_memory_capacity_bytes","task_physical_footprint_bytes",
           "task_resident_bytes","unavailable_reason"
         ];
         def pass_counts:
           .model_allocation_count == 1
           and .model_materialization_count == 1
           and .value_and_grad_count == 1
           and .direct_package_b_training_logits_api_call_count == 1
           and .dense_embedding_construction_count == 1
           and .token_bounds_validation_count == 1
           and .token_bounds_checked_eval_count == 1
           and .token_bounds_gpu_synchronization_count == 1
           and .token_bounds_host_bool_item_count == 1
           and .cross_entropy_count == 1 and .forward_loss_count == 1
           and .backward_count == 1 and .gradient_norm_count == 1
           and .gradient_clip_count == 1 and .optimizer_step_count == 1
           and .adamw_update_count == 1
           and .full_graph_evaluation_count == 1
           and .checked_evaluation_barrier_count == 6
           and .gpu_synchronization_barrier_count == 6
           and .memory_clear_cache_count == 1
           and .mlx_peak_memory_reset_count == 1
           and .postflight_device_reenumeration_count == 1
           and .maintained_gather_training_logits_count == 0
           and .tiny_training_selector_invocation_count == 0
           and .input_embedding_forward_pair_diagnostic_invocation_count == 0
           and .kv_cache_allocation_count == 0
           and .evaluation_forward_pass_count == 0;
         def attempted_prefix_counts:
           .model_allocation_count <= 1
           and .model_materialization_count <= 1
           and .value_and_grad_count <= 1
           and .direct_package_b_training_logits_api_call_count <= 1
           and .dense_embedding_construction_count <= 1
           and .token_bounds_validation_count <= 1
           and .token_bounds_checked_eval_count <= 1
           and .token_bounds_gpu_synchronization_count <= 1
           and .token_bounds_host_bool_item_count <= 1
           and .cross_entropy_count <= 1 and .forward_loss_count <= 1
           and .backward_count <= 1 and .gradient_norm_count <= 1
           and .gradient_clip_count <= 1 and .optimizer_step_count <= 1
           and .adamw_update_count <= 1
           and .full_graph_evaluation_count <= 1
           and .checked_evaluation_barrier_count <= 6
           and .gpu_synchronization_barrier_count <= 6
           and .memory_clear_cache_count <= 1
           and .mlx_peak_memory_reset_count <= 1
           and .postflight_device_reenumeration_count <= 1
           and .maintained_gather_training_logits_count == 0
           and .tiny_training_selector_invocation_count == 0
           and .input_embedding_forward_pair_diagnostic_invocation_count == 0
           and .kv_cache_allocation_count == 0
           and .evaluation_forward_pass_count == 0;
         def candidate_contract_v1:
         . as $candidate
         | ([.payload.phase_metrics[]
             | select(.availability == "observed")] | length)
             as $observed_phase_count
         | (keys == (["authority_canonical_sha256","authority_id","classification","one_shot_consumed","payload","schema_id","schema_version","scientific_status"] | sort))
         and (keys | length) == 8
         and .schema_id == $schema
         and .schema_version == 1
         and .authority_id == $authority
         and .authority_canonical_sha256 == $canonical
         and (.scientific_status == "PASS" or .scientific_status == "ABSTAIN")
         and (.classification | type == "string")
         and .one_shot_consumed == true
         and (.payload | exact_keys([
           "environment","lease","limits","outcome","phase_metrics"
         ]))
         and (.payload.environment | exact_keys([
           "filesystem_observation_fsid","filesystem_observation_path",
           "metal_device_count","metal_device_has_unified_memory",
           "metal_device_index","metal_device_is_default",
           "metal_device_max_buffer_length_bytes",
           "metal_device_max_recommended_working_set_bytes",
           "metal_device_name","metal_device_registry_id",
           "mlx_compile_transform_invocation_count","mlx_cpu_fallback_used",
           "mlx_default_device_is_supplied_device",
           "mlx_default_stream_is_gpu","mlx_device_constructor_index",
           "mlx_device_type","mlx_enable_tf32","mlx_revision",
           "operating_system_build","runtime_metallib_byte_count",
           "runtime_metallib_path","runtime_metallib_sha256","swift_sdk",
           "swift_version","swiftpm_build_configuration","xcode_version"
         ]))
         and .payload.environment.mlx_enable_tf32 == "0"
         and .payload.environment.mlx_revision == $mlx_revision
         and .payload.environment.mlx_compile_transform_invocation_count == 0
         and .payload.environment.operating_system_build
             == $operating_system_build
         and .payload.environment.runtime_metallib_path == $metallib_path
         and .payload.environment.runtime_metallib_byte_count == $metallib_bytes
         and .payload.environment.runtime_metallib_sha256 == $metallib_sha
         and .payload.environment.swift_sdk == $swift_sdk
         and .payload.environment.swift_version == $swift_version
         and .payload.environment.swiftpm_build_configuration == "release"
         and .payload.environment.xcode_version == $xcode_version
         and fields_atomic_nullable(
           .payload.environment; metal_observation_keys)
         and fields_atomic_nullable(
           .payload.environment; mlx_policy_observation_keys)
         and fields_atomic_nullable(
           .payload.environment; filesystem_observation_keys)
         and (fields_all_null(
                .payload.environment; metal_observation_keys)
              or ((.payload.environment.metal_device_count
                    | nonnegative_integer)
                  and (.payload.environment.metal_device_index
                    | nonnegative_integer)
                  and (.payload.environment.metal_device_is_default
                    | type == "boolean")
                  and (.payload.environment
                    .metal_device_max_buffer_length_bytes | positive_integer)
                  and (.payload.environment
                    .metal_device_max_recommended_working_set_bytes
                    | positive_integer)
                  and (.payload.environment.metal_device_has_unified_memory
                    | type == "boolean")
                  and (.payload.environment.metal_device_name
                    | type == "string" and length > 0)
                  and (.payload.environment.metal_device_registry_id
                    | nonnegative_integer)))
         and (fields_all_null(
                .payload.environment; mlx_policy_observation_keys)
              or ((.payload.environment.mlx_cpu_fallback_used
                    | type == "boolean")
                  and (.payload.environment
                    .mlx_default_device_is_supplied_device
                    | type == "boolean")
                  and (.payload.environment.mlx_default_stream_is_gpu
                    | type == "boolean")
                  and (.payload.environment.mlx_device_constructor_index
                    | nonnegative_integer)
                  and (.payload.environment.mlx_device_type
                    | type == "string" and length > 0)))
         and (fields_all_null(
                .payload.environment; filesystem_observation_keys)
              or ((.payload.environment.filesystem_observation_path
                    | type == "string" and startswith("/") and . != "/"
                      and (endswith("/") | not)
                      and (test("(^|/)\\.\\.?(/|$)") | not))
                  and (.payload.environment.filesystem_observation_fsid
                    | type == "array" and length == 2
                      and all(.[]; type == "number" and . == floor
                        and . >= -2147483648 and . <= 2147483647))))
         and (.payload.lease | exact_keys([
           "acquired_before_coregraphics_metal_or_mlx","acquired_nonblocking",
           "held_through_candidate_flush","held_through_postflight",
           "lease_path","supervisor_owned",
           "supervisor_release_verifier_proved","type",
           "worker_inherited_lease_descriptor_count","worker_owned"
         ]))
         and .payload.lease.lease_path == $lease_path
         and .payload.lease.type == "PrimeMetalDeviceLease"
         and .payload.lease.acquired_nonblocking == true
         and (.payload.lease.acquired_before_coregraphics_metal_or_mlx
              | type == "boolean")
         and (.payload.lease.held_through_candidate_flush
              | type == "boolean")
         and (.payload.lease.held_through_postflight | type == "boolean")
         and .payload.lease.supervisor_release_verifier_proved == false
         and .payload.lease.supervisor_owned == true
         and .payload.lease.worker_owned == false
         and .payload.lease.acquired_before_coregraphics_metal_or_mlx == true
         and .payload.lease.worker_inherited_lease_descriptor_count == 0
         and (.payload.limits | exact_keys([
           "available_filesystem_floor_bytes","configured_cache_limit_bytes",
           "configured_cache_limit_readback_bytes",
           "configured_memory_limit_bytes","configured_memory_limit_formula",
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
         and .payload.limits.minimum_committed_tensor_state_bytes == 3253284864
         and .payload.limits.minimum_state_plus_gradient_bytes == 4337713152
         and .payload.limits.minimum_memory_limit_floor_bytes == 4337713152
         and .payload.limits.available_filesystem_floor_bytes == 12884901888
         and .payload.limits.configured_cache_limit_bytes == 0
         and .payload.limits.gradient_logical_bytes == 1084428288
         and .payload.limits.optimizer_moment_logical_bytes == 2168856576
         and .payload.limits.optimizer_moment_tensor_count == 436
         and .payload.limits.three_times_committed_state_disk_comparator_bytes
             == 9759854592
         and .payload.limits.weights_logical_bytes == 1084428288
         and .payload.limits.configured_memory_limit_formula
             == "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)"
         and .payload.limits.container_headers_and_manifests_included_in_minimum
             == false
         and .payload.limits
             .duplicate_materializations_graphs_and_temporary_buffers_included_in_minimum
             == false
         and .payload.limits.mlx_limit_is_not_rss_limit == true
         and .payload.limits.statfs_is_observational_only == true
         and .payload.limits.worker_active_timeout_seconds == 1200
         and .payload.limits.supervisor_end_to_end_timeout_seconds == 1500
         and .payload.limits.termination_grace_seconds == 10
         and fields_atomic_nullable(
           .payload.limits; configured_limit_observation_keys)
         and fields_atomic_nullable(
           .payload.limits; validated_model_observation_keys)
         and fields_atomic_nullable(
           .payload.limits; validated_gradient_observation_keys)
         and fields_atomic_nullable(
           .payload.limits; validated_moment_observation_keys)
         and ([[configured_limit_observation_keys,
                validated_model_observation_keys,
                validated_gradient_observation_keys,
                validated_moment_observation_keys][] as $group
               | (fields_all_null($candidate.payload.limits; $group)
                  or ($group | all(. as $key
                     | $candidate.payload.limits[$key]
                     | nonnegative_integer)))] | all)
         and (fields_all_null(
                .payload.limits; configured_limit_observation_keys)
              or (.payload.limits.configured_cache_limit_readback_bytes == 0
                  and .payload.limits.configured_memory_limit_readback_bytes
                    == .payload.limits.configured_memory_limit_bytes
                  and (if .payload.environment
                        .metal_device_max_recommended_working_set_bytes == null
                       then true
                       else .payload.limits.configured_memory_limit_bytes
                         == (if .payload.environment
                              .metal_device_max_recommended_working_set_bytes
                              < 17179869184
                             then .payload.environment
                              .metal_device_max_recommended_working_set_bytes
                             else 17179869184 end)
                       end)))
         and (fields_all_null(
                .payload.limits; validated_model_observation_keys)
              or (.payload.limits.validated_parameter_path_count == 218
                  and .payload.limits.validated_unique_parameter_count
                    == 271107072
                  and .payload.limits.validated_weights_logical_bytes
                    == 1084428288))
         and (fields_all_null(
                .payload.limits; validated_gradient_observation_keys)
              or (.payload.limits.validated_gradient_path_count == 218
                  and .payload.limits.validated_gradient_logical_bytes
                    == 1084428288))
         and (fields_all_null(
                .payload.limits; validated_moment_observation_keys)
              or (.payload.limits.validated_first_moment_tensor_count == 218
                  and .payload.limits.validated_second_moment_tensor_count
                    == 218
                  and .payload.limits
                    .validated_optimizer_moment_logical_bytes == 2168856576))
         and (.payload.outcome | exact_keys([
           "classification","gradient_clip_scale_float32_bits",
           "loss_float32_bits","one_shot_consumed","operation_counts",
           "parameter_fingerprint_after","parameter_fingerprint_before",
           "parameter_fingerprint_sample_count",
           "parameter_fingerprint_sample_plan_sha256",
           "postflight_device_identity_matches_preflight",
           "postflight_mlx_policy_and_limits_match_preflight",
           "raw_gradient_norm_float32_bits",
           "resource_clearance_established","resource_envelope_established",
           "resource_probe_executed","runner_memory_capacity_established",
           "status","update_occurred","worker_candidate_present"
         ]))
         and .payload.outcome.status == .scientific_status
         and .payload.outcome.classification == .classification
         and .payload.outcome.one_shot_consumed == true
         and (.payload.outcome.resource_clearance_established
              | type == "boolean")
         and (.payload.outcome.resource_envelope_established
              | type == "boolean")
         and (.payload.outcome.resource_probe_executed | type == "boolean")
         and (.payload.outcome.runner_memory_capacity_established
              | type == "boolean")
         and (.payload.outcome.worker_candidate_present | type == "boolean")
         and (.payload.outcome.loss_float32_bits == null
              or (.payload.outcome.loss_float32_bits | uint32))
         and (.payload.outcome.raw_gradient_norm_float32_bits == null
              or (.payload.outcome.raw_gradient_norm_float32_bits | uint32))
         and (.payload.outcome.gradient_clip_scale_float32_bits == null
              or (.payload.outcome.gradient_clip_scale_float32_bits | uint32))
         and (.payload.outcome.parameter_fingerprint_before == null
              or (.payload.outcome.parameter_fingerprint_before | hex64))
         and (.payload.outcome.parameter_fingerprint_after == null
              or (.payload.outcome.parameter_fingerprint_after | hex64))
         and (.payload.outcome.parameter_fingerprint_sample_plan_sha256
                == null
              or (.payload.outcome.parameter_fingerprint_sample_plan_sha256
                | hex64))
         and (.payload.outcome.parameter_fingerprint_sample_count == null
              or (.payload.outcome.parameter_fingerprint_sample_count
                | nonnegative_integer))
         and (.payload.outcome.update_occurred == null
              or (.payload.outcome.update_occurred | type == "boolean"))
         and fields_atomic_nullable(
           .payload.outcome; postflight_outcome_observation_keys)
         and (.payload.outcome.operation_counts | exact_keys(operation_keys))
         and ([.payload.outcome.operation_counts[]]
              | all(nonnegative_integer))
         and .payload.outcome.operation_counts
             .direct_package_b_training_logits_api_call_count
             == .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts
             .dense_embedding_construction_count
             == .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts.token_bounds_validation_count
             == .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts.token_bounds_checked_eval_count
             == .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts
             .token_bounds_gpu_synchronization_count
             == .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts
             .token_bounds_host_bool_item_count
             == .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts.cross_entropy_count
             == .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts.forward_loss_count
             == .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts.backward_count
             == .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts.adamw_update_count
             == .payload.outcome.operation_counts.optimizer_step_count
         and .payload.outcome.operation_counts.gradient_clip_count
             <= .payload.outcome.operation_counts.gradient_norm_count
         and .payload.outcome.operation_counts.gradient_norm_count
             <= .payload.outcome.operation_counts.value_and_grad_count
         and .payload.outcome.operation_counts.model_materialization_count
             <= .payload.outcome.operation_counts.model_allocation_count
         and .payload.outcome.operation_counts.full_graph_evaluation_count
             <= .payload.outcome.operation_counts.adamw_update_count
         and .payload.outcome.operation_counts.memory_clear_cache_count
             <= .payload.outcome.operation_counts.full_graph_evaluation_count
         and .payload.outcome.operation_counts
             .postflight_device_reenumeration_count
             <= .payload.outcome.operation_counts.memory_clear_cache_count
         and .payload.outcome.operation_counts
             .gpu_synchronization_barrier_count
             <= .payload.outcome.operation_counts
                .checked_evaluation_barrier_count
         and (.payload.phase_metrics | length) == 6
         and ([.payload.phase_metrics[].phase] == [
           "preflight","post_model_materialization",
           "post_b_forward_backward","post_norm_clip",
           "post_adam_update_full_evaluation",
           "post_lexical_deallocation_and_clear_cache"
         ])
         and ([.payload.phase_metrics[] | exact_keys(phase_keys)] | all)
         and ([.payload.phase_metrics[].availability]
              | all(. == "observed"
                    or . == "unavailable_after_classification"
                    or . == "unavailable_after_fatal"
                    or . == "unavailable_before_probe_start"))
         and ([.payload.phase_metrics[] as $phase
               | if $phase.availability == "observed" then
                   $phase.unavailable_reason == null
                   and (numeric_phase_metric_keys
                     | all(. as $key
                       | $phase[$key] | nonnegative_integer))
                   and ($phase.physical_memory_capacity_bytes
                     | positive_integer)
                   and ($phase.filesystem_capacity_bytes | positive_integer)
                   and $phase.filesystem_available_bytes
                     <= $phase.filesystem_capacity_bytes
                 else
                   $phase.unavailable_reason == .classification
                   and (numeric_phase_metric_keys
                     | all(. as $key | $phase[$key] == null))
                 end] | all)
         and (reduce .payload.phase_metrics[] as $phase
               ({unavailable_seen:false,valid:true};
                if $phase.availability == "observed" then
                  .valid = (.valid and (.unavailable_seen | not))
                else .unavailable_seen = true end) | .valid)
         and ([.payload.phase_metrics[]
               | select(.availability == "observed")
               | .cumulative_worker_probe_elapsed_nanoseconds]
              | strictly_increasing)
         and ([.payload.phase_metrics[]
               | select(.availability == "observed") | .mlx_peak_bytes]
              | nondecreasing)
         and ([.payload.phase_metrics[]
               | select(.availability == "observed")
               | .getrusage_max_rss_bytes] | nondecreasing)
         and (if $observed_phase_count >= 1 then
                (metal_observation_keys
                  | all(. as $key
                    | $candidate.payload.environment[$key] != null))
                and (mlx_policy_observation_keys
                  | all(. as $key
                    | $candidate.payload.environment[$key] != null))
                and (filesystem_observation_keys
                  | all(. as $key
                    | $candidate.payload.environment[$key] != null))
                and (configured_limit_observation_keys
                  | all(. as $key
                    | $candidate.payload.limits[$key] != null))
                and .payload.outcome.operation_counts
                    .mlx_peak_memory_reset_count >= 1
              else true end)
         and (if $observed_phase_count >= 2 then
                (validated_model_observation_keys
                  | all(. as $key
                    | $candidate.payload.limits[$key] != null))
                and .payload.outcome.operation_counts
                    .model_materialization_count >= 1
                and .payload.outcome.operation_counts
                    .checked_evaluation_barrier_count >= 1
                and .payload.outcome.operation_counts
                    .gpu_synchronization_barrier_count >= 1
              else true end)
         and (if $observed_phase_count >= 3 then
                (validated_gradient_observation_keys
                  | all(. as $key
                    | $candidate.payload.limits[$key] != null))
                and .payload.outcome.operation_counts.backward_count >= 1
                and .payload.outcome.operation_counts
                    .checked_evaluation_barrier_count >= 3
                and .payload.outcome.operation_counts
                    .gpu_synchronization_barrier_count >= 3
              else true end)
         and (if $observed_phase_count >= 4 then
                .payload.outcome.operation_counts.gradient_clip_count >= 1
                and .payload.outcome.operation_counts
                    .checked_evaluation_barrier_count >= 5
                and .payload.outcome.operation_counts
                    .gpu_synchronization_barrier_count >= 5
              else true end)
         and (if $observed_phase_count >= 5 then
                (validated_moment_observation_keys
                  | all(. as $key
                    | $candidate.payload.limits[$key] != null))
                and .payload.outcome.operation_counts
                    .full_graph_evaluation_count >= 1
                and .payload.outcome.operation_counts
                    .checked_evaluation_barrier_count >= 6
                and .payload.outcome.operation_counts
                    .gpu_synchronization_barrier_count >= 6
              else true end)
         and (if $observed_phase_count >= 6 then
                .payload.outcome.operation_counts.memory_clear_cache_count >= 1
              else true end)
         and (if $observed_phase_count >= 2 then
                .payload.outcome.parameter_fingerprint_before != null
                and .payload.outcome
                    .parameter_fingerprint_sample_plan_sha256 != null
                and .payload.outcome.parameter_fingerprint_sample_count != null
              else
                .payload.outcome.parameter_fingerprint_before == null
                and .payload.outcome
                    .parameter_fingerprint_sample_plan_sha256 == null
                and .payload.outcome.parameter_fingerprint_sample_count == null
              end)
         and (if $observed_phase_count >= 3 then
                .payload.outcome.loss_float32_bits != null
              else .payload.outcome.loss_float32_bits == null end)
         and (if $observed_phase_count >= 4 then
                .payload.outcome.raw_gradient_norm_float32_bits != null
                and .payload.outcome.gradient_clip_scale_float32_bits != null
              else
                .payload.outcome.raw_gradient_norm_float32_bits == null
                and .payload.outcome.gradient_clip_scale_float32_bits == null
              end)
         and (if $observed_phase_count >= 5 then
                .payload.outcome.parameter_fingerprint_after != null
                and .payload.outcome.update_occurred != null
              else
                .payload.outcome.parameter_fingerprint_after == null
                and .payload.outcome.update_occurred == null
              end)
         and .payload.outcome.runner_memory_capacity_established
             == (.payload.environment.metal_device_has_unified_memory == true
                 and $observed_phase_count > 0)
         and .payload.outcome.resource_probe_executed
             == (.payload.outcome.operation_counts.model_allocation_count == 1)
         and (if .classification == "worker_spawn_failure"
                  or .classification == "lease_busy" then
                $observed_phase_count == 0
                and (.payload.phase_metrics
                  | all(.availability == "unavailable_before_probe_start"))
              elif .classification == "preflight_floor" then
                $observed_phase_count == 1
                and (.payload.phase_metrics[1:]
                  | all(.availability
                    == "unavailable_after_classification"))
                and (.payload.limits.configured_memory_limit_bytes
                      < 4337713152
                  or .payload.phase_metrics[0].filesystem_available_bytes
                      < 12884901888)
              elif .classification == "oom"
                  or .classification == "timeout"
                  or .classification == "signal" then
                (.payload.phase_metrics[$observed_phase_count:]
                  | all(.availability == "unavailable_after_fatal"))
              elif .classification == "nonfinite" then
                ($observed_phase_count == 2 or $observed_phase_count == 3)
                and (.payload.phase_metrics[$observed_phase_count:]
                  | all(.availability
                    == "unavailable_after_classification"))
              elif .classification == "no_update" then
                $observed_phase_count == 6
                and .payload.outcome.update_occurred == false
              elif .classification == "topology_dtype" then
                (.payload.phase_metrics[$observed_phase_count:]
                  | all(.availability
                    == "unavailable_after_classification"))
              else true end)
         and (if .scientific_status == "PASS" then
                .classification == "pass"
                and .payload.outcome.resource_clearance_established == true
                and .payload.outcome.resource_envelope_established == true
                and .payload.outcome.resource_probe_executed == true
                and .payload.outcome.worker_candidate_present == true
                and .payload.outcome.runner_memory_capacity_established == true
                and .payload.lease.held_through_candidate_flush == true
                and .payload.lease.held_through_postflight == true
                and .payload.outcome.update_occurred == true
                and (.payload.outcome.parameter_fingerprint_before | hex64)
                and (.payload.outcome.parameter_fingerprint_after | hex64)
                and .payload.outcome.parameter_fingerprint_before
                    != .payload.outcome.parameter_fingerprint_after
                and (.payload.outcome
                    .parameter_fingerprint_sample_plan_sha256 | hex64)
                and .payload.outcome.parameter_fingerprint_sample_count == 654
                and (.payload.outcome.loss_float32_bits
                    | finite_float32_bits)
                and (.payload.outcome.raw_gradient_norm_float32_bits
                    | finite_positive_float32_bits)
                and .payload.outcome.gradient_clip_scale_float32_bits
                    == (.payload.outcome.raw_gradient_norm_float32_bits
                      | expected_gradient_clip_scale_bits)
                and .payload.outcome
                    .postflight_device_identity_matches_preflight == true
                and .payload.outcome
                    .postflight_mlx_policy_and_limits_match_preflight == true
                and .payload.environment.metal_device_count == 1
                and .payload.environment.metal_device_index == 0
                and .payload.environment.metal_device_is_default == true
                and .payload.environment.metal_device_has_unified_memory == true
                and .payload.environment.mlx_cpu_fallback_used == false
                and .payload.environment
                    .mlx_default_device_is_supplied_device == true
                and .payload.environment.mlx_default_stream_is_gpu == true
                and .payload.environment.mlx_device_constructor_index == 0
                and .payload.environment.mlx_device_type == "gpu"
                and .payload.limits.configured_cache_limit_readback_bytes == 0
                and .payload.limits.configured_memory_limit_bytes >= 4337713152
                and .payload.limits.configured_memory_limit_readback_bytes
                    == .payload.limits.configured_memory_limit_bytes
                and (.payload
                  | pass_measured_mlx_peak_below_configured_limit)
                and .payload.limits.validated_parameter_path_count == 218
                and .payload.limits.validated_unique_parameter_count
                    == 271107072
                and .payload.limits.validated_weights_logical_bytes
                    == 1084428288
                and .payload.limits.validated_gradient_path_count == 218
                and .payload.limits.validated_gradient_logical_bytes
                    == 1084428288
                and .payload.limits.validated_first_moment_tensor_count == 218
                and .payload.limits.validated_second_moment_tensor_count == 218
                and .payload.limits
                    .validated_optimizer_moment_logical_bytes == 2168856576
                and (.payload.phase_metrics
                     | all(.availability == "observed"))
                and .payload.phase_metrics[0].filesystem_available_bytes
                    >= 12884901888
                and (.payload.outcome.operation_counts | pass_counts)
              else
                (.classification | resource_class)
                and .payload.outcome.resource_clearance_established == false
                and .payload.outcome.resource_envelope_established == false
                and .payload.outcome.worker_candidate_present == false
                and (.payload.outcome.operation_counts
                     | attempted_prefix_counts)
              end)
         and ([.payload | .. | objects
               | (has("mechanics_success") or has("workflow_success"))]
              | any | not)
         and (.mechanics_success? == null)
         and (.workflow_success? == null);
         def safely_candidate_contract_v1:
           try candidate_contract_v1 catch false;
         . as $candidate
         | ($candidate | safely_candidate_contract_v1)
         and ([
           ($candidate + {unexpected_schema_key:true}
             | safely_candidate_contract_v1),
           ($candidate
             | del(.payload.environment.mlx_revision)
             | safely_candidate_contract_v1),
           ($candidate
             | .payload.limits.unexpected_limit = 0
             | safely_candidate_contract_v1),
           ($candidate
             | .payload.outcome.unexpected_outcome = false
             | safely_candidate_contract_v1),
           ($candidate
             | .payload.lease.supervisor_owned = false
             | safely_candidate_contract_v1),
           ($candidate
             | .payload.outcome.operation_counts.model_allocation_count = 2
             | safely_candidate_contract_v1),
           ($candidate
             | .payload.phase_metrics[0].phase =
                 "post_model_materialization"
             | safely_candidate_contract_v1),
           ($candidate
             | .payload.phase_metrics[0]
                 .cumulative_worker_probe_elapsed_nanoseconds = "not_numeric"
             | safely_candidate_contract_v1),
           ($candidate
             | .payload.outcome.status =
                 (if .scientific_status == "PASS" then "ABSTAIN"
                  else "PASS" end)
             | safely_candidate_contract_v1)
         ] | all(. == false))
         and (if $candidate.scientific_status == "PASS" then
                $candidate.payload.limits.configured_memory_limit_bytes
                  as $configured_limit
                | ($candidate
                  | .payload.phase_metrics[0].mlx_peak_bytes =
                      $configured_limit
                  | safely_candidate_contract_v1
                  | not)
              else true end)
        ' >/dev/null ||
        fail "private candidate schema or authority binding changed"
    candidate_sha256="$(printf '%s' "$candidate_json" | shasum -a 256 | awk '{print $1}')"
    candidate_scientific_status="$(printf '%s' "$candidate_json" | jq -r '.scientific_status')"
    candidate_classification="$(printf '%s' "$candidate_json" | jq -r '.classification')"
fi
readonly candidate_json candidate_sha256 candidate_canonical_byte_count
readonly candidate_scientific_status candidate_classification

readonly terminal_json="$(awk -v prefix="$terminal_prefix" '
    index($0, prefix) == 1 { print substr($0, length(prefix) + 1) }
' "$supervisor_log")"
[[ "$(printf '%s' "$terminal_json" | wc -c | awk '{print $1}')" -le 1048576 \
    && "$(printf '%s' "$terminal_json" | jq -cS .)" == "$terminal_json" ]] ||
    fail "private terminal packet is oversized or noncanonical"
readonly terminal_canonical_byte_count="$(printf '%s' \
    "$terminal_json" | wc -c | awk '{print $1}')"
readonly terminal_sha256="$(printf '%s' "$terminal_json" | shasum -a 256 | awk '{print $1}')"

printf '%s' "$terminal_json" | jq -e \
    --arg schema "$terminal_schema_id" \
    --arg authority "$authority_id" \
    --arg canonical "$authority_canonical_sha256" \
    --argjson candidate_present "$([[ "$candidate_count" == "1" ]] && /usr/bin/printf true || /usr/bin/printf false)" \
    --arg candidate_status "$candidate_scientific_status" \
    --arg candidate_classification "$candidate_classification" \
    --arg candidate_sha "$candidate_sha256" \
    --arg lease_root "$lease_root" \
    --argjson effective_uid "$effective_uid" \
    --argjson effective_gid "$effective_gid" \
    '
      def nonnegative_integer:
        type == "number" and . >= 0 and . == floor;
      def typed_descriptor_evidence:
        (.device_id | nonnegative_integer)
        and (.inode | nonnegative_integer)
        and (.uid | nonnegative_integer)
        and (.gid | nonnegative_integer)
        and (.mode | type == "string" and test("^0[0-7]{3}$"))
        and (.security_flags | nonnegative_integer)
        and (.acl_entry_count | nonnegative_integer)
        and (.observed_nlink | nonnegative_integer)
        and (.observed_extended_attribute_names | type == "array"
             and . == (sort | unique)
             and all(.[]; type == "string"));
      def parent_tuple_or_null: . == null or (
        type == "object"
        and (keys == (["acl_entry_count","device_id","file_type","gid","inode","mode","observed_extended_attribute_names","observed_nlink","physical_path","security_flags","uid"] | sort))
        and .file_type == "directory"
        and (.physical_path | type == "string" and startswith("/")
             and . != "/" and (endswith("/") | not))
        and typed_descriptor_evidence);
      def lease_tuple_or_null: . == null or (
        type == "object"
        and (keys == (["acl_entry_count","byte_count","device_id","file_type","gid","inode","mode","observed_extended_attribute_names","observed_nlink","security_flags","uid"] | sort))
        and .file_type == "regular_file"
        and (.byte_count | nonnegative_integer)
        and typed_descriptor_evidence);
      def allowed_resource_xattrs:
        (.observed_extended_attribute_names
          - ["com.apple.provenance"] | length) == 0;
      def clean_parent_policy($lease_root; $effective_uid):
        .physical_path == $lease_root
        and .file_type == "directory" and .uid == $effective_uid
        and .mode == "0700" and .security_flags == 0
        and .acl_entry_count == 0 and allowed_resource_xattrs;
      def clean_lease_policy($parent; $effective_uid; $effective_gid):
        .file_type == "regular_file" and .uid == $effective_uid
        and .gid == $effective_gid and .mode == "0600"
        and .security_flags == 0 and .acl_entry_count == 0
        and .observed_nlink == 1 and .byte_count == 0
        and .device_id == $parent.device_id and allowed_resource_xattrs;
      def parent_preflight_stable_fields:
        del(.observed_nlink, .observed_extended_attribute_names);
      def parent_verifier_stable_fields:
        del(.observed_nlink);
      def clean_terminal_identity_closure(
        $lease_root; $effective_uid; $effective_gid
      ):
        . as $terminal
        | ($terminal.supervisor_preflight_parent_tuple
            | clean_parent_policy($lease_root; $effective_uid))
        and ($terminal.supervisor_post_candidate_parent_tuple
            | clean_parent_policy($lease_root; $effective_uid))
        and ($terminal.verifier_parent_tuple
            | clean_parent_policy($lease_root; $effective_uid))
        and (($terminal.supervisor_preflight_parent_tuple
              | parent_preflight_stable_fields)
            == ($terminal.supervisor_post_candidate_parent_tuple
              | parent_preflight_stable_fields))
        and (($terminal.supervisor_post_candidate_parent_tuple
              | parent_verifier_stable_fields)
            == ($terminal.verifier_parent_tuple
              | parent_verifier_stable_fields))
        and ($terminal.supervisor_post_candidate_lease_tuple
            | clean_lease_policy(
                $terminal.supervisor_post_candidate_parent_tuple;
                $effective_uid; $effective_gid))
        and ($terminal.verifier_lease_tuple
            | clean_lease_policy(
                $terminal.verifier_parent_tuple;
                $effective_uid; $effective_gid))
        and $terminal.supervisor_post_candidate_lease_tuple
            == $terminal.verifier_lease_tuple
        and $terminal.supervisor_post_candidate_inventory
            == ["device-0.lock"]
        and $terminal.verifier_inventory == ["device-0.lock"];
      def integrity_guard_prefix_count_matches_first_failure($ordered):
        . as $terminal
        | ($ordered | index($terminal.first_failed_guard_id)) as $index
        | $index != null
          and $terminal.supervisor_integrity_guard_count
            == (if $index < 13 then $index else 13 end);
      def resource_class:
        . == "worker_spawn_failure" or . == "preflight_floor"
        or . == "lease_busy" or . == "oom" or . == "timeout"
        or . == "signal" or . == "nonfinite"
        or . == "topology_dtype" or . == "no_update";
      def terminal_contract_v1:
      (keys == (["actual_metadata","actual_metadata_availability","actual_metadata_unavailable_reason","authority_canonical_sha256","authority_id","candidate_present","candidate_scientific_status","candidate_sha256","classification","errno","errno_availability","first_failed_guard_id","lease_acquired","one_shot_consumed","release_verifier_exit_zero","schema_id","schema_version","supervisor_integrity_guard_count","supervisor_post_candidate_inventory","supervisor_post_candidate_lease_tuple","supervisor_post_candidate_parent_tuple","supervisor_preflight_parent_tuple","terminal_status","verifier_inventory","verifier_lease_tuple","verifier_parent_tuple"] | sort))
      and (keys | length) == 26
      and .schema_id == $schema
      and .schema_version == 1
      and .authority_id == $authority
      and .authority_canonical_sha256 == $canonical
      and .candidate_present == $candidate_present
      and .one_shot_consumed == true
      and (.terminal_status == "PASS" or .terminal_status == "ABSTAIN"
           or .terminal_status == "ABSTAIN_INTEGRITY")
      and (.classification == "pass" or (.classification | resource_class)
           or .classification == "integrity_failure")
      and (.lease_acquired | type == "boolean")
      and (.release_verifier_exit_zero | type == "boolean")
      and (.supervisor_integrity_guard_count | type == "number"
           and . >= 0 and . <= 13 and . == floor)
      and .supervisor_preflight_parent_tuple != null
      and (.supervisor_preflight_parent_tuple | parent_tuple_or_null)
      and (.supervisor_preflight_parent_tuple
        | clean_parent_policy($lease_root; $effective_uid))
      and (.supervisor_post_candidate_parent_tuple | parent_tuple_or_null)
      and (.supervisor_post_candidate_lease_tuple | lease_tuple_or_null)
      and (.verifier_parent_tuple | parent_tuple_or_null)
      and (.verifier_lease_tuple | lease_tuple_or_null)
      and (.supervisor_post_candidate_inventory == null
           or .supervisor_post_candidate_inventory == ["device-0.lock"])
      and (.verifier_inventory == null
           or .verifier_inventory == ["device-0.lock"])
      and (if $candidate_present then
             .candidate_scientific_status == $candidate_status
             and .candidate_sha256 == $candidate_sha
             and ($candidate_sha | test("^[0-9a-f]{64}$"))
           else
             .candidate_scientific_status == null
             and .candidate_sha256 == null
           end)
      and (if .terminal_status == "PASS" then
             $candidate_present and $candidate_status == "PASS"
             and $candidate_classification == "pass"
             and .classification == "pass" and .lease_acquired
             and .release_verifier_exit_zero
             and .first_failed_guard_id == null
           elif .terminal_status == "ABSTAIN" then
             (.classification | resource_class)
             and (if $candidate_present then
                    $candidate_status == "ABSTAIN"
                    and $candidate_classification == .classification
                  else true end)
             and (if .lease_acquired then .release_verifier_exit_zero else true end)
             and .first_failed_guard_id == null
           else
             $candidate_present and .classification == "integrity_failure"
             and (.first_failed_guard_id | type == "string")
           end)
      and (if .terminal_status == "ABSTAIN_INTEGRITY" then
             (.errno_availability == "available"
              or .errno_availability == "unavailable")
             and (.actual_metadata_availability == "available"
              or .actual_metadata_availability == "unavailable")
             and integrity_guard_prefix_count_matches_first_failure([
               "supervisor_preflight_parent_physical_path",
               "supervisor_preflight_parent_descriptor_policy",
               "supervisor_preflight_parent_empty_inventory",
               "supervisor_lease_acquire",
               "supervisor_private_candidate_validation",
               "supervisor_post_candidate_parent_stable_fields",
               "supervisor_post_candidate_exact_child_inventory",
               "supervisor_post_candidate_lease_file_policy",
               "supervisor_device_and_mlx_postflight",
               "supervisor_void_release_call","verifier_parent_identity",
               "verifier_lease_file_identity",
               "verifier_acquire_release_and_exit_zero",
               "supervisor_exit_zero",
               "outer_private_working_directory_postflight",
               "outer_repository_postflight","outer_metallib_postflight",
               "outer_parent_and_lease_file_rebind"
             ])
             and (if .release_verifier_exit_zero then
                    clean_terminal_identity_closure(
                      $lease_root; $effective_uid; $effective_gid)
                  else
                    .verifier_parent_tuple == null
                    and .verifier_lease_tuple == null
                    and .verifier_inventory == null
                  end)
           else
             .errno_availability == "not_applicable" and .errno == null
             and .actual_metadata_availability == "not_applicable"
             and .actual_metadata == null
             and .actual_metadata_unavailable_reason == null
           end)
      and (if .lease_acquired then
             (if .terminal_status == "ABSTAIN_INTEGRITY" then true else
                .supervisor_integrity_guard_count == 13
                and .supervisor_post_candidate_parent_tuple != null
                and .supervisor_post_candidate_lease_tuple != null
                and .supervisor_post_candidate_inventory == ["device-0.lock"]
                and .verifier_parent_tuple != null
                and .verifier_lease_tuple != null
                and .verifier_inventory == ["device-0.lock"]
                and .release_verifier_exit_zero == true
                and clean_terminal_identity_closure(
                  $lease_root; $effective_uid; $effective_gid)
              end)
           else
             .terminal_status == "ABSTAIN"
             and .classification == "lease_busy"
             and .supervisor_integrity_guard_count == 3
             and .release_verifier_exit_zero == false
             and .supervisor_post_candidate_parent_tuple == null
             and .supervisor_post_candidate_lease_tuple == null
             and .supervisor_post_candidate_inventory == null
             and .verifier_parent_tuple == null
             and .verifier_lease_tuple == null
             and .verifier_inventory == null
             and (.supervisor_preflight_parent_tuple
               | clean_parent_policy($lease_root; $effective_uid))
           end)
      and (.errno_availability == "available"
           or .errno_availability == "unavailable"
           or .errno_availability == "not_applicable")
      and (.actual_metadata_availability == "available"
           or .actual_metadata_availability == "unavailable"
           or .actual_metadata_availability == "not_applicable")
      and (if .errno_availability == "available" then
             (.errno | type == "number" and . > 0 and . == floor)
           else .errno == null end)
      and (if .actual_metadata_availability == "available" then
             .actual_metadata != null
             and .actual_metadata_unavailable_reason == null
           elif .actual_metadata_availability == "unavailable" then
             .actual_metadata == null
             and ((.actual_metadata_unavailable_reason
                    | type == "string" and length > 0)
                  or .errno_availability == "available")
           else
             .actual_metadata == null
             and .actual_metadata_unavailable_reason == null
           end)
      and (.mechanics_success? == null)
      and (.workflow_success? == null);
      def safely_terminal_contract_v1:
        try terminal_contract_v1 catch false;
      . as $terminal
      | ($terminal | safely_terminal_contract_v1)
      and ([
        ($terminal + {unexpected_schema_key:true}
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_preflight_parent_tuple.uid =
              ($effective_uid + 1)
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_preflight_parent_tuple.mode = "0755"
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_preflight_parent_tuple.security_flags = 1
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_preflight_parent_tuple.acl_entry_count = 1
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_preflight_parent_tuple
              .observed_extended_attribute_names = ["untrusted.xattr"]
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_preflight_parent_tuple.observed_nlink = "not_numeric"
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_post_candidate_lease_tuple.observed_nlink = 2
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_post_candidate_lease_tuple.byte_count = 1
          | safely_terminal_contract_v1),
        ($terminal
          | .verifier_inventory = ["unexpected.lock"]
          | safely_terminal_contract_v1),
        ($terminal
          | .supervisor_integrity_guard_count += 1
          | safely_terminal_contract_v1),
        ($terminal
          | .first_failed_guard_id = "unknown_integrity_guard"
          | safely_terminal_contract_v1),
        ($terminal
          | .candidate_present = (.candidate_present | not)
          | safely_terminal_contract_v1),
        ($terminal
          | .release_verifier_exit_zero =
              (.release_verifier_exit_zero | not)
          | safely_terminal_contract_v1)
      ] | all(. == false))
    ' >/dev/null ||
    fail "private terminal packet schema or classification closure changed"

terminal_status="$(printf '%s' "$terminal_json" | jq -r '.terminal_status')"
classification="$(printf '%s' "$terminal_json" | jq -r '.classification')"
readonly lease_acquired="$(printf '%s' "$terminal_json" | jq -r '.lease_acquired')"
readonly release_verifier_exit_zero="$(printf '%s' "$terminal_json" | jq -r '.release_verifier_exit_zero')"
readonly supervisor_integrity_guard_count="$(printf '%s' "$terminal_json" | jq -r '.supervisor_integrity_guard_count')"
first_failed_guard_id="$(printf '%s' "$terminal_json" | jq -r '.first_failed_guard_id // ""')"
errno_availability="$(printf '%s' "$terminal_json" | jq -r '.errno_availability')"
errno_json="$(printf '%s' "$terminal_json" | jq -c '.errno')"
actual_metadata_availability="$(printf '%s' "$terminal_json" | jq -r '.actual_metadata_availability')"
actual_metadata_json="$(printf '%s' "$terminal_json" | jq -cS '.actual_metadata')"
actual_metadata_unavailable_reason="$(printf '%s' "$terminal_json" | jq -r '.actual_metadata_unavailable_reason // ""')"

readonly ordered_integrity_guard_ids_json='["supervisor_preflight_parent_physical_path","supervisor_preflight_parent_descriptor_policy","supervisor_preflight_parent_empty_inventory","supervisor_lease_acquire","supervisor_private_candidate_validation","supervisor_post_candidate_parent_stable_fields","supervisor_post_candidate_exact_child_inventory","supervisor_post_candidate_lease_file_policy","supervisor_device_and_mlx_postflight","supervisor_void_release_call","verifier_parent_identity","verifier_lease_file_identity","verifier_acquire_release_and_exit_zero","supervisor_exit_zero","outer_private_working_directory_postflight","outer_repository_postflight","outer_metallib_postflight","outer_parent_and_lease_file_rebind"]'
if [[ -n "$first_failed_guard_id" ]]; then
    /usr/bin/printf '%s' "$ordered_integrity_guard_ids_json" | jq -e \
        --arg guard "$first_failed_guard_id" 'index($guard) != null' >/dev/null ||
        fail "private terminal packet named an unknown integrity guard"
fi

record_outer_integrity_failure() {
    local guard_id="$1" reason="$2" metadata_json="${3:-null}"
    [[ "$candidate_count" == "1" ]] ||
        fail "outer integrity failure has no validated candidate"
    if [[ "$terminal_status" != "ABSTAIN_INTEGRITY" ]]; then
        terminal_status="ABSTAIN_INTEGRITY"
        classification="integrity_failure"
        first_failed_guard_id="$guard_id"
        errno_availability="unavailable"
        errno_json="null"
        if [[ "$metadata_json" == "null" ]]; then
            actual_metadata_availability="unavailable"
            actual_metadata_json="null"
            actual_metadata_unavailable_reason="$reason"
        else
            actual_metadata_availability="available"
            actual_metadata_json="$metadata_json"
            actual_metadata_unavailable_reason=""
        fi
    fi
}

if [[ "$supervisor_status" -ne 0 ]]; then
    record_outer_integrity_failure \
        "supervisor_exit_zero" "supervisor_exit_status_${supervisor_status}" \
        "$(jq -cnS --argjson exit_status "$supervisor_status" '{supervisor_exit_status:$exit_status}')"
fi

if [[ -n "$(find "$private_cwd" -mindepth 1 -print)" ]]; then
    readonly private_cwd_inventory_json="$(find "$private_cwd" -mindepth 1 -print | LC_ALL=C sort | jq -Rsc 'split("\n") | map(select(length > 0))')"
    record_outer_integrity_failure \
        "outer_private_working_directory_postflight" \
        "private_working_directory_not_empty" \
        "$(jq -cnS --argjson inventory "$private_cwd_inventory_json" '{inventory:$inventory}')"
fi

if [[ "$(git -C "$prime_root" rev-parse HEAD)" != "$exact_revision" \
    || "$(git -C "$prime_root" rev-parse 'HEAD^{tree}')" != "$exact_tree" \
    || -n "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]]; then
    readonly repository_postflight_json="$(jq -cnS \
        --arg head "$(git -C "$prime_root" rev-parse HEAD 2>/dev/null || /usr/bin/printf unavailable)" \
        --arg tree "$(git -C "$prime_root" rev-parse 'HEAD^{tree}' 2>/dev/null || /usr/bin/printf unavailable)" \
        --arg status "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all 2>/dev/null || /usr/bin/printf unavailable)" \
        '{head:$head,status:$status,tree:$tree}')"
    record_outer_integrity_failure \
        "outer_repository_postflight" "repository_identity_changed" \
        "$repository_postflight_json"
fi

if { [[ ! -f "$staged_metallib" || -L "$staged_metallib" \
        || "$(stat -f %Lp "$staged_metallib" 2>/dev/null || /usr/bin/printf unavailable)" != "444" \
        || "$(stat -f %z "$staged_metallib" 2>/dev/null || /usr/bin/printf unavailable)" != "$metallib_byte_count" \
        || "$(shasum -a 256 "$staged_metallib" 2>/dev/null | awk '{print $1}')" != "$metallib_sha256" ]] \
        || ! cmp -s "$metallib" "$staged_metallib"; }; then
    record_outer_integrity_failure \
        "outer_metallib_postflight" "staged_metallib_identity_changed"
fi

path_tuple_json() {
    local path="$1" expected_type="$2" physical file_type device inode uid gid
    local mode mode_raw flags acl_count nlink observed_xattrs byte_count
    [[ -e "$path" && ! -L "$path" ]] || return 1
    if [[ "$expected_type" == "directory" ]]; then
        [[ -d "$path" ]] || return 1
        physical="$(cd "$path" && pwd -P)" || return 1
        file_type="directory"
    else
        [[ -f "$path" ]] || return 1
        physical="$(cd "$(dirname "$path")" && pwd -P)/${path##*/}" || return 1
        file_type="regular_file"
        byte_count="$(stat -f %z "$path")" || return 1
    fi
    device="$(stat -f %d "$path")" || return 1
    inode="$(stat -f %i "$path")" || return 1
    uid="$(stat -f %u "$path")" || return 1
    gid="$(stat -f %g "$path")" || return 1
    mode_raw="$(stat -f %Lp "$path")" || return 1
    case "$mode_raw" in
        [0-7][0-7][0-7]) mode="0${mode_raw}" ;;
        0[0-7][0-7][0-7]) mode="$mode_raw" ;;
        *) return 1 ;;
    esac
    flags="$(stat -f %f "$path")" || return 1
    nlink="$(stat -f %l "$path")" || return 1
    acl_count="$(ls -lde "$path" | awk 'NR > 1 && /^[[:space:]]*[0-9]+:/ { count += 1 } END { print count + 0 }')" || return 1
    observed_xattrs="$(xattr "$path" | LC_ALL=C sort | jq -Rsc 'split("\n") | map(select(length > 0)) | sort')" || return 1
    if [[ "$expected_type" == "directory" ]]; then
        jq -cnS --arg physical_path "$physical" --arg file_type "$file_type" \
            --argjson device_id "$device" --argjson inode "$inode" \
            --argjson uid "$uid" --argjson gid "$gid" --arg mode "$mode" \
            --argjson security_flags "$flags" --argjson acl_entry_count "$acl_count" \
            --argjson observed_nlink "$nlink" \
            --argjson observed_extended_attribute_names "$observed_xattrs" \
            '{acl_entry_count:$acl_entry_count,device_id:$device_id,file_type:$file_type,gid:$gid,inode:$inode,mode:$mode,observed_extended_attribute_names:$observed_extended_attribute_names,observed_nlink:$observed_nlink,physical_path:$physical_path,security_flags:$security_flags,uid:$uid}'
    else
        jq -cnS --arg file_type "$file_type" \
            --argjson byte_count "$byte_count" \
            --argjson device_id "$device" --argjson inode "$inode" \
            --argjson uid "$uid" --argjson gid "$gid" --arg mode "$mode" \
            --argjson security_flags "$flags" --argjson acl_entry_count "$acl_count" \
            --argjson observed_nlink "$nlink" \
            --argjson observed_extended_attribute_names "$observed_xattrs" \
            '{acl_entry_count:$acl_entry_count,byte_count:$byte_count,device_id:$device_id,file_type:$file_type,gid:$gid,inode:$inode,mode:$mode,observed_extended_attribute_names:$observed_extended_attribute_names,observed_nlink:$observed_nlink,security_flags:$security_flags,uid:$uid}'
    fi
}

outer_parent_tuple="null"
outer_lease_tuple="null"
outer_inventory="null"
if [[ -d "$lease_root" && ! -L "$lease_root" ]]; then
    if outer_parent_tuple="$(path_tuple_json "$lease_root" directory)" \
        && [[ -f "$lease_path" && ! -L "$lease_path" ]] \
        && outer_lease_tuple="$(path_tuple_json "$lease_path" regular_file)"; then
        outer_inventory="$(find "$lease_root" -mindepth 1 -maxdepth 1 -print | \
            awk -F/ '{print $NF}' | LC_ALL=C sort | jq -Rsc 'split("\n") | map(select(length > 0))')"
    fi
fi
readonly verifier_parent_tuple="$(printf '%s' "$terminal_json" | jq -cS '.verifier_parent_tuple')"
readonly verifier_lease_tuple="$(printf '%s' "$terminal_json" | jq -cS '.verifier_lease_tuple')"
readonly verifier_inventory="$(printf '%s' "$terminal_json" | jq -cS '.verifier_inventory')"
readonly supervisor_preflight_parent_tuple="$(printf '%s' "$terminal_json" | jq -cS '.supervisor_preflight_parent_tuple')"
readonly outer_parent_stable_tuple="$(/usr/bin/printf '%s' "$outer_parent_tuple" | jq -cS 'if . == null then null else del(.observed_nlink) end')"
readonly verifier_parent_stable_tuple="$(/usr/bin/printf '%s' "$verifier_parent_tuple" | jq -cS 'if . == null then null else del(.observed_nlink) end')"
readonly supervisor_preflight_parent_stable_tuple="$(/usr/bin/printf '%s' "$supervisor_preflight_parent_tuple" | jq -cS 'if . == null then null else del(.observed_nlink) end')"
if [[ "$lease_acquired" == "true" ]]; then
    if [[ "$outer_parent_tuple" == "null" || "$outer_lease_tuple" == "null" \
        || "$outer_inventory" != '["device-0.lock"]' \
        || "$outer_parent_stable_tuple" != "$verifier_parent_stable_tuple" \
        || "$outer_lease_tuple" != "$verifier_lease_tuple" \
        || "$outer_inventory" != "$verifier_inventory" ]] \
        || ! /usr/bin/printf '%s\n%s\n' "$outer_parent_tuple" "$outer_lease_tuple" | \
            jq -es 'all(.[];
                .security_flags == 0 and .acl_entry_count == 0
                and ((.observed_extended_attribute_names - ["com.apple.provenance"]) | length == 0))
                and .[0].file_type == "directory" and .[0].mode == "0700"
                and .[1].file_type == "regular_file" and .[1].mode == "0600"
                and .[1].observed_nlink == 1
                and .[1].byte_count == 0
                and .[0].device_id == .[1].device_id' >/dev/null; then
        record_outer_integrity_failure \
            "outer_parent_and_lease_file_rebind" \
            "outer_rebind_did_not_match_verifier" \
            "$(jq -cnS --argjson inventory "$outer_inventory" \
                --argjson lease "$outer_lease_tuple" \
                --argjson parent "$outer_parent_tuple" \
                '{inventory:$inventory,lease_tuple:$lease,parent_tuple:$parent}')"
    fi
else
    if [[ "$outer_parent_tuple" == "null" \
        || "$supervisor_preflight_parent_tuple" == "null" \
        || "$outer_parent_stable_tuple" \
            != "$supervisor_preflight_parent_stable_tuple" ]] \
        || ! /usr/bin/printf '%s' "$outer_parent_tuple" | jq -e '
            .file_type == "directory" and .mode == "0700"
            and .security_flags == 0 and .acl_entry_count == 0
            and ((.observed_extended_attribute_names - ["com.apple.provenance"]) | length == 0)' >/dev/null; then
        record_outer_integrity_failure \
            "outer_parent_and_lease_file_rebind" \
            "candidate_free_parent_rebind_did_not_match_preflight" \
            "$(jq -cnS --argjson inventory "$outer_inventory" \
                --argjson parent "$outer_parent_tuple" \
                '{inventory:$inventory,parent_tuple:$parent}')"
    fi
fi

# Once a core integrity failure is already the first failure, outer checks do
# not replace it. Every published integrity guard remains from the frozen list.
if [[ -n "$first_failed_guard_id" ]]; then
    /usr/bin/printf '%s' "$ordered_integrity_guard_ids_json" | jq -e \
        --arg guard "$first_failed_guard_id" 'index($guard) != null' >/dev/null ||
        fail "terminal classification has an unknown first failed guard"
    readonly first_failed_guard_index="$(/usr/bin/printf '%s' \
        "$ordered_integrity_guard_ids_json" | jq -r \
        --arg guard "$first_failed_guard_id" 'index($guard)')"
    expected_completed_guard_count="$first_failed_guard_index"
    if [[ "$expected_completed_guard_count" -gt 13 ]]; then
        expected_completed_guard_count=13
    fi
    [[ "$supervisor_integrity_guard_count" \
        == "$expected_completed_guard_count" ]] ||
        fail "first failed guard does not bind the completed guard prefix"
fi

case "$terminal_status" in
    PASS)
        [[ "$candidate_count" == "1" \
            && "$candidate_scientific_status" == "PASS" \
            && "$classification" == "pass" \
            && -z "$first_failed_guard_id" ]] ||
            fail "PASS publication closure is inconsistent"
        b_resource_witness=true
        b_resource_clearance=true
        ;;
    ABSTAIN)
        [[ "$classification" != "pass" \
            && "$classification" != "integrity_failure" \
            && -z "$first_failed_guard_id" ]] ||
            fail "ABSTAIN publication closure is inconsistent"
        b_resource_witness=false
        b_resource_clearance=false
        ;;
    ABSTAIN_INTEGRITY)
        [[ "$candidate_count" == "1" \
            && "$candidate_scientific_status" =~ ^(PASS|ABSTAIN)$ \
            && "$classification" == "integrity_failure" \
            && -n "$first_failed_guard_id" ]] ||
            fail "ABSTAIN_INTEGRITY publication closure is inconsistent"
        b_resource_witness=false
        b_resource_clearance=false
        ;;
    *)
        fail "unknown terminal status"
        ;;
esac

if [[ "$errno_availability" == "available" ]]; then
    [[ "$errno_json" =~ ^[1-9][0-9]*$ ]] ||
        fail "available errno binding is not a positive integer"
else
    [[ "$errno_json" == "null" ]] ||
        fail "unavailable errno binding is not null"
fi
if [[ "$actual_metadata_availability" == "available" ]]; then
    [[ "$actual_metadata_json" != "null" ]] ||
        fail "available actual metadata is null"
else
    [[ "$actual_metadata_json" == "null" ]] ||
        fail "unavailable actual metadata is nonnull"
    if [[ "$terminal_status" == "ABSTAIN_INTEGRITY" \
        && "$errno_availability" != "available" ]]; then
        [[ -n "$actual_metadata_unavailable_reason" ]] ||
            fail "integrity metadata absence has no reason or errno"
    fi
fi

# The nested terminal is the validated supervisor terminal before any outer
# guard can upgrade only the public classification to ABSTAIN_INTEGRITY.
readonly public_json="$(jq -cnS \
    --arg schema_id "$receipt_schema_id" \
    --arg authority_id "$authority_id" \
    --arg authority_canonical_sha256 "$authority_canonical_sha256" \
    --arg status "$terminal_status" \
    --arg classification "$classification" \
    --argjson candidate_present "$([[ "$candidate_count" == "1" ]] && /usr/bin/printf true || /usr/bin/printf false)" \
    --arg candidate_scientific_status "$candidate_scientific_status" \
    --arg candidate_sha256 "$candidate_sha256" \
    --argjson candidate_canonical_byte_count "$candidate_canonical_byte_count" \
    --arg terminal_sha256 "$terminal_sha256" \
    --argjson terminal_canonical_byte_count "$terminal_canonical_byte_count" \
    --slurpfile validated_private_candidate <(printf '%s\n' "$candidate_json") \
    --slurpfile validated_private_terminal <(printf '%s\n' "$terminal_json") \
    --arg first_failed_guard_id "$first_failed_guard_id" \
    --arg errno_availability "$errno_availability" \
    --argjson errno "$errno_json" \
    --arg actual_metadata_availability "$actual_metadata_availability" \
    --argjson actual_metadata "$actual_metadata_json" \
    --arg actual_metadata_unavailable_reason "$actual_metadata_unavailable_reason" \
    --arg mechanics_revision "$exact_revision" \
    --arg mechanics_tree "$exact_tree" \
    --argjson mechanics_run_id "$GITHUB_RUN_ID" \
    --argjson mechanics_run_number "$GITHUB_RUN_NUMBER" \
    --argjson mechanics_run_attempt "$GITHUB_RUN_ATTEMPT" \
    --argjson source_identities "$exact_changed_source_identities_json" \
    --argjson b_resource_witness "$b_resource_witness" \
    --argjson b_resource_clearance "$b_resource_clearance" \
    --argjson lease_acquired "$lease_acquired" \
    --argjson release_verifier_exit_zero "$release_verifier_exit_zero" \
    --argjson supervisor_integrity_guard_count "$supervisor_integrity_guard_count" \
    '{actual_metadata:$actual_metadata,
      actual_metadata_availability:$actual_metadata_availability,
      actual_metadata_unavailable_reason:(if $actual_metadata_unavailable_reason == "" then null else $actual_metadata_unavailable_reason end),
      artifact_upload_authorized:false,
      authority_canonical_sha256:$authority_canonical_sha256,
      authority_id:$authority_id,
      b_specific_native300m_resource_clearance:$b_resource_clearance,
      b_specific_native300m_resource_witness:$b_resource_witness,
      candidate_canonical_byte_count:$candidate_canonical_byte_count,
      candidate_present:$candidate_present,
      candidate_scientific_status:(if $candidate_present then $candidate_scientific_status else null end),
      candidate_sha256:(if $candidate_present then $candidate_sha256 else null end),
      classification:$classification,
      errno:$errno,
      errno_availability:$errno_availability,
      exact_changed_source_identities:$source_identities,
      first_failed_guard_id:(if $first_failed_guard_id == "" then null else $first_failed_guard_id end),
      historical_stage6_resource_clearance_applies_to_b_path:false,
      lease_acquired:$lease_acquired,
      mechanics_revision:$mechanics_revision,
      mechanics_run_attempt:$mechanics_run_attempt,
      mechanics_run_id:$mechanics_run_id,
      mechanics_run_number:$mechanics_run_number,
      mechanics_tree:$mechanics_tree,
      one_shot_consumed:true,
      ordinary_job_fit_established:false,
      retained_artifact_authorized:false,
      release_verifier_exit_zero:$release_verifier_exit_zero,
      retry_authorized:false,
      rerun_authorized:false,
      schema_id:$schema_id,
      schema_version:1,
      stage7_authorized:false,
      status:$status,
      supervisor_integrity_guard_count:$supervisor_integrity_guard_count,
      terminal_canonical_byte_count:$terminal_canonical_byte_count,
      terminal_sha256:$terminal_sha256,
      validated_private_candidate:$validated_private_candidate[0],
      validated_private_terminal:$validated_private_terminal[0]}'
)"
[[ "$(printf '%s' "$public_json" | jq -cS .)" == "$public_json" ]] ||
    fail "public receipt canonicalization failed"
printf '%s' "$public_json" | jq -e \
    --arg expected_schema_id "$receipt_schema_id" \
    --arg expected_authority_id "$authority_id" \
    --arg expected_authority_canonical_sha256 "$authority_canonical_sha256" \
    --arg expected_status "$terminal_status" \
    --arg expected_classification "$classification" \
    --argjson expected_candidate_present "$([[ "$candidate_count" == "1" ]] && /usr/bin/printf true || /usr/bin/printf false)" \
    --arg expected_candidate_status "$candidate_scientific_status" \
    --arg expected_candidate_sha "$candidate_sha256" \
    --argjson expected_candidate_canonical_byte_count "$candidate_canonical_byte_count" \
    --arg expected_terminal_sha "$terminal_sha256" \
    --argjson expected_terminal_canonical_byte_count "$terminal_canonical_byte_count" \
    --slurpfile expected_candidate <(printf '%s\n' "$candidate_json") \
    --slurpfile expected_terminal <(printf '%s\n' "$terminal_json") \
    --arg expected_guard "$first_failed_guard_id" \
    --arg expected_errno_availability "$errno_availability" \
    --argjson expected_errno "$errno_json" \
    --arg expected_actual_metadata_availability "$actual_metadata_availability" \
    --argjson expected_actual_metadata "$actual_metadata_json" \
    --arg expected_actual_metadata_unavailable_reason "$actual_metadata_unavailable_reason" \
    --arg expected_mechanics_revision "$exact_revision" \
    --arg expected_mechanics_tree "$exact_tree" \
    --argjson expected_mechanics_run_id "$GITHUB_RUN_ID" \
    --argjson expected_mechanics_run_number "$GITHUB_RUN_NUMBER" \
    --argjson expected_mechanics_run_attempt "$GITHUB_RUN_ATTEMPT" \
    --argjson expected_source_identities "$exact_changed_source_identities_json" \
    --argjson expected_lease_acquired "$lease_acquired" \
    --argjson expected_release_verifier_exit_zero "$release_verifier_exit_zero" \
    --argjson expected_supervisor_integrity_guard_count "$supervisor_integrity_guard_count" \
    '
      def positive_integer:
        type == "number" and . > 0 and . == floor;
      def hex64:
        type == "string" and test("^[0-9a-f]{64}$");
      def hex40:
        type == "string" and test("^[0-9a-f]{40}$");
      def resource_class:
        . == "worker_spawn_failure" or . == "preflight_floor"
        or . == "lease_busy" or . == "oom" or . == "timeout"
        or . == "signal" or . == "nonfinite"
        or . == "topology_dtype" or . == "no_update";
      def outer_guard:
        . == "supervisor_exit_zero"
        or . == "outer_private_working_directory_postflight"
        or . == "outer_repository_postflight"
        or . == "outer_metallib_postflight"
        or . == "outer_parent_and_lease_file_rebind";
      def public_contract_v1:
        (keys == (["actual_metadata","actual_metadata_availability","actual_metadata_unavailable_reason","artifact_upload_authorized","authority_canonical_sha256","authority_id","b_specific_native300m_resource_clearance","b_specific_native300m_resource_witness","candidate_canonical_byte_count","candidate_present","candidate_scientific_status","candidate_sha256","classification","errno","errno_availability","exact_changed_source_identities","first_failed_guard_id","historical_stage6_resource_clearance_applies_to_b_path","lease_acquired","mechanics_revision","mechanics_run_attempt","mechanics_run_id","mechanics_run_number","mechanics_tree","one_shot_consumed","ordinary_job_fit_established","release_verifier_exit_zero","rerun_authorized","retained_artifact_authorized","retry_authorized","schema_id","schema_version","stage7_authorized","status","supervisor_integrity_guard_count","terminal_canonical_byte_count","terminal_sha256","validated_private_candidate","validated_private_terminal"] | sort))
        and (keys | length) == 39
        and .schema_id == $expected_schema_id
        and .schema_version == 1
        and .authority_id == $expected_authority_id
        and .authority_canonical_sha256
            == $expected_authority_canonical_sha256
        and .status == $expected_status
        and .classification == $expected_classification
        and .candidate_present == $expected_candidate_present
        and .validated_private_candidate == $expected_candidate[0]
        and .validated_private_terminal == $expected_terminal[0]
        and (.validated_private_terminal | type == "object")
        and .terminal_sha256 == $expected_terminal_sha
        and (.terminal_sha256 | hex64)
        and .terminal_canonical_byte_count
            == $expected_terminal_canonical_byte_count
        and (.terminal_canonical_byte_count | positive_integer)
        and .validated_private_terminal.schema_id
            == "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_terminal_v1"
        and .validated_private_terminal.schema_version == 1
        and .validated_private_terminal.authority_id == .authority_id
        and .validated_private_terminal.authority_canonical_sha256
            == .authority_canonical_sha256
        and .validated_private_terminal.candidate_present
            == .candidate_present
        and .validated_private_terminal.candidate_scientific_status
            == .candidate_scientific_status
        and .validated_private_terminal.candidate_sha256
            == .candidate_sha256
        and .validated_private_terminal.one_shot_consumed
            == .one_shot_consumed
        and .validated_private_terminal.lease_acquired == .lease_acquired
        and .validated_private_terminal.release_verifier_exit_zero
            == .release_verifier_exit_zero
        and .validated_private_terminal.supervisor_integrity_guard_count
            == .supervisor_integrity_guard_count
        and (if $expected_candidate_present then
               (.validated_private_candidate | type == "object")
               and .validated_private_candidate.schema_id
                 == "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_candidate_v1"
               and .validated_private_candidate.schema_version == 1
               and .validated_private_candidate.authority_id == .authority_id
               and .validated_private_candidate.authority_canonical_sha256
                 == .authority_canonical_sha256
               and .validated_private_candidate.one_shot_consumed == true
               and .validated_private_candidate.scientific_status
                 == $expected_candidate_status
               and .candidate_scientific_status
                 == $expected_candidate_status
               and .candidate_sha256 == $expected_candidate_sha
               and (.candidate_sha256 | hex64)
               and .candidate_canonical_byte_count
                 == $expected_candidate_canonical_byte_count
               and (.candidate_canonical_byte_count | positive_integer)
             else
               .validated_private_candidate == null
               and .candidate_scientific_status == null
               and .candidate_sha256 == null
               and .candidate_canonical_byte_count == null
             end)
        and .first_failed_guard_id
            == (if $expected_guard == "" then null else $expected_guard end)
        and .errno_availability == $expected_errno_availability
        and .errno == $expected_errno
        and .actual_metadata_availability
            == $expected_actual_metadata_availability
        and .actual_metadata == $expected_actual_metadata
        and .actual_metadata_unavailable_reason
            == (if $expected_actual_metadata_unavailable_reason == ""
                then null else $expected_actual_metadata_unavailable_reason end)
        and .lease_acquired == $expected_lease_acquired
        and .release_verifier_exit_zero
            == $expected_release_verifier_exit_zero
        and .supervisor_integrity_guard_count
            == $expected_supervisor_integrity_guard_count
        and .one_shot_consumed == true
        and .artifact_upload_authorized == false
        and .retained_artifact_authorized == false
        and .ordinary_job_fit_established == false
        and .historical_stage6_resource_clearance_applies_to_b_path == false
        and .stage7_authorized == false
        and .retry_authorized == false
        and .rerun_authorized == false
        and (.status == "PASS" or .status == "ABSTAIN"
             or .status == "ABSTAIN_INTEGRITY")
        and (.classification == "pass" or (.classification | resource_class)
             or .classification == "integrity_failure")
        and .b_specific_native300m_resource_clearance == (.status == "PASS")
        and .b_specific_native300m_resource_witness == (.status == "PASS")
        and (if .status == "PASS" then
               .classification == "pass" and .candidate_present
               and .candidate_scientific_status == "PASS"
               and .first_failed_guard_id == null
             elif .status == "ABSTAIN" then
               (.classification | resource_class)
               and .first_failed_guard_id == null
             else
               .classification == "integrity_failure"
               and .candidate_present
               and (.first_failed_guard_id | type == "string"
                    and length > 0)
             end)
        and (if .status == .validated_private_terminal.terminal_status then
               .classification == .validated_private_terminal.classification
               and .first_failed_guard_id
                 == .validated_private_terminal.first_failed_guard_id
               and .errno_availability
                 == .validated_private_terminal.errno_availability
               and .errno == .validated_private_terminal.errno
               and .actual_metadata_availability
                 == .validated_private_terminal.actual_metadata_availability
               and .actual_metadata
                 == .validated_private_terminal.actual_metadata
               and .actual_metadata_unavailable_reason
                 == .validated_private_terminal.actual_metadata_unavailable_reason
             else
               .status == "ABSTAIN_INTEGRITY"
               and .classification == "integrity_failure"
               and (.validated_private_terminal.terminal_status == "PASS"
                    or .validated_private_terminal.terminal_status == "ABSTAIN")
               and (.first_failed_guard_id | outer_guard)
             end)
        and (.lease_acquired | type == "boolean")
        and (.release_verifier_exit_zero | type == "boolean")
        and (.supervisor_integrity_guard_count | type == "number"
             and . >= 0 and . <= 13 and . == floor)
        and (.errno_availability == "available"
             or .errno_availability == "unavailable"
             or .errno_availability == "not_applicable")
        and (if .errno_availability == "available" then
               (.errno | positive_integer)
             else .errno == null end)
        and (.actual_metadata_availability == "available"
             or .actual_metadata_availability == "unavailable"
             or .actual_metadata_availability == "not_applicable")
        and (if .actual_metadata_availability == "available" then
               .actual_metadata != null
               and .actual_metadata_unavailable_reason == null
             elif .actual_metadata_availability == "unavailable" then
               .actual_metadata == null
               and ((.actual_metadata_unavailable_reason
                      | type == "string" and length > 0)
                    or .errno_availability == "available")
             else
               .actual_metadata == null
               and .actual_metadata_unavailable_reason == null
             end)
        and .exact_changed_source_identities == $expected_source_identities
        and (.exact_changed_source_identities | type == "array"
             and length == 8)
        and .mechanics_revision == $expected_mechanics_revision
        and (.mechanics_revision | hex40)
        and .mechanics_tree == $expected_mechanics_tree
        and (.mechanics_tree | hex40)
        and .mechanics_run_id == $expected_mechanics_run_id
        and (.mechanics_run_id | positive_integer)
        and .mechanics_run_number == $expected_mechanics_run_number
        and (.mechanics_run_number | positive_integer)
        and .mechanics_run_attempt == $expected_mechanics_run_attempt
        and .mechanics_run_attempt == 1
        and (.mechanics_success? == null)
        and (.workflow_success? == null);
      def safely_public_contract_v1:
        try public_contract_v1 catch false;
      . as $public
      | ($public | safely_public_contract_v1)
      and ([
        ($public + {unexpected_schema_key:true}
          | safely_public_contract_v1),
        ($public | .schema_version = 2 | safely_public_contract_v1),
        ($public
          | .candidate_present = (.candidate_present | not)
          | safely_public_contract_v1),
        ($public
          | .candidate_canonical_byte_count =
              (if .candidate_present then
                 .candidate_canonical_byte_count + 1
               else 1 end)
          | safely_public_contract_v1),
        ($public
          | .candidate_sha256 =
              (if .candidate_present then
                 "0000000000000000000000000000000000000000000000000000000000000000"
               else "unexpected" end)
          | safely_public_contract_v1),
        ($public
          | .validated_private_candidate =
              (if .candidate_present then null else {} end)
          | safely_public_contract_v1),
        ($public
          | .validated_private_terminal.terminal_status =
              (if .validated_private_terminal.terminal_status == "PASS"
               then "ABSTAIN" else "PASS" end)
          | safely_public_contract_v1),
        ($public
          | .terminal_canonical_byte_count += 1
          | safely_public_contract_v1),
        ($public
          | .terminal_sha256 =
              "0000000000000000000000000000000000000000000000000000000000000000"
          | safely_public_contract_v1),
        ($public
          | .first_failed_guard_id = "unknown_integrity_guard"
          | safely_public_contract_v1),
        ($public
          | .mechanics_revision =
              "0000000000000000000000000000000000000000000000000000000000000000"
          | safely_public_contract_v1),
        ($public
          | .exact_changed_source_identities = []
          | safely_public_contract_v1)
      ] | all(. == false))
    ' >/dev/null ||
    fail "final public receipt schema or required bindings changed"

readonly embedded_terminal_json="$(printf '%s' "$public_json" | \
    jq -cS '.validated_private_terminal')"
[[ "$embedded_terminal_json" == "$terminal_json" \
    && "$(printf '%s' "$embedded_terminal_json" | wc -c | awk '{print $1}')" \
        == "$terminal_canonical_byte_count" \
    && "$(printf '%s' "$embedded_terminal_json" | shasum -a 256 | awk '{print $1}')" \
        == "$terminal_sha256" ]] ||
    fail "embedded validated private terminal is not canonically cross-bound"
readonly embedded_candidate_json="$(printf '%s' "$public_json" | \
    jq -cS '.validated_private_candidate')"
if [[ "$candidate_count" == "1" ]]; then
    [[ "$embedded_candidate_json" == "$candidate_json" \
        && "$(printf '%s' "$embedded_candidate_json" | wc -c | awk '{print $1}')" \
            == "$candidate_canonical_byte_count" \
        && "$(printf '%s' "$embedded_candidate_json" | shasum -a 256 | awk '{print $1}')" \
            == "$candidate_sha256" ]] ||
        fail "embedded validated private candidate is not canonically cross-bound"
else
    [[ "$embedded_candidate_json" == "null" \
        && "$candidate_canonical_byte_count" == "null" \
        && "$candidate_sha256" == "null" ]] ||
        fail "candidate-free public receipt retained candidate evidence"
fi
[[ "$(occurrence_count "$receipt_prefix" "$supervisor_log")" == "0" \
    && "$(occurrence_count "$receipt_prefix" "$supervisor_stderr_log")" == "0" \
    && "$(occurrence_count "$receipt_prefix" "$launcher_contract_log")" == "0" ]] ||
    fail "public receipt prefix existed before final publication"

readonly public_line="${receipt_prefix}${public_json}"
readonly public_line_byte_count="$(printf '%s\n' "$public_line" | \
    wc -c | awk '{print $1}')"
[[ "$public_line_byte_count" -le "$public_receipt_maximum_byte_count" ]] ||
    fail "final public receipt exceeds the one-mebibyte publication ceiling"
trap - EXIT HUP INT TERM
exec /usr/bin/printf '%s\n' "$public_line"
