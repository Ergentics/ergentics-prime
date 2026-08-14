#!/usr/bin/env bash
# Sole exact-main Stage-5 A/B replacement assay. Candidate A is diagnostic
# only. Candidate B is the package-only flattened dense one-hot input path.
# The one direct XCTest owns the full Metal lease, completes all measurements,
# and emits exactly one canonical green PASS_CLEARANCE or
# MEASURED_EXACT_MISMATCH receipt. Either green outcome consumes the one-shot.
set -euo pipefail
IFS=$'\n\t'
umask 077

fail() {
    echo "prime-native-decoder-stage5-repeated-trajectory-replacement: $*" >&2
    exit 2
}

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"

readonly authority_closure_revision="a0ce9561bdbc867b12f13aed7a7f54846faf3020"
readonly authority_closure_tree="e7f85dcecbc82b7e74065cc1991175152f53c13f"
readonly authority_closure_run_id="31824087086"
readonly authority_closure_run_number="115"
readonly authority_closure_run_attempt="1"
readonly authority_closure_check_suite_id="86338204723"
readonly authority_closure_active_job_id="94843969773"
readonly authority_closure_reviewed_job_id="94844683376"
readonly authority_id="prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_authority_v1"
readonly authority_canonical_sha256="e0b1fadf4075765078ba3cf29e7cce85be930791651020d45cba1b5b91466252"
readonly required_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly required_mlx_c_revision="0726ca922fc902c4c61ef9c27d94132be418e945"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly preserved_index_sha256="8742966c9f6322aa353facd846f4bcfab546cff6ab7997fac86b76249c56dcbb"
readonly receipt_prefix="PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_RECEIPT_V1="

readonly validation_root="$prime_root/Tests/PrimeNativeDecoderTrainingValidation"
readonly validation_manifest="$validation_root/Package.swift"
readonly validation_lock="$validation_root/Package.resolved"
readonly assay_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift"
readonly authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthority.swift"
readonly authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityTests.swift"
readonly embedded_provenance="$prime_root/Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift"

readonly mlx_bare="$runner_temp/ergentics-mlx-swift.git"
readonly mlx_source="$runner_temp/ergentics-mlx-swift"
readonly frozen_metallib_root="$runner_temp/prime-native-decoder-metallib"
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

readonly scratch_path="$runner_temp/prime-native-decoder-stage5-replacement-build"
readonly cache_path="$runner_temp/prime-native-decoder-stage5-replacement-cache"
readonly config_path="$runner_temp/prime-native-decoder-stage5-replacement-config"
readonly security_path="$runner_temp/prime-native-decoder-stage5-replacement-security"
readonly private_cwd="$runner_temp/prime-native-decoder-stage5-replacement-cwd"
readonly lease_root="$runner_temp/prime-native-decoder-stage5-replacement-metal-lease"
readonly lease_path="$lease_root/device-0.lock"
readonly test_log="$runner_temp/prime-native-decoder-stage5-replacement-tests.log"
readonly test_class="PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests"
readonly test_method="testMaintainedGatherDiagnosticAndFlattenedDenseOneHotMatmulExactResume"
readonly test_filter="$test_class/$test_method"

for command_name in awk bash chmod cmp cp dirname env find git grep id jq \
    mkdir otool pwd rm rmdir shasum sort stat swift sw_vers tee tr uname wc \
    xcodebuild xcrun; do
    command -v "$command_name" >/dev/null 2>&1 ||
        fail "missing command: $command_name"
done

readonly xctest_failure_or_skip_regex="^Test Case '[^']+' failed \\(|^Test Suite '[^']+' failed at |^error:|^Test Case '[^']+' skipped \\(| : Test skipped - "
xctest_log_has_failure_or_skip() {
    grep -Eq "$xctest_failure_or_skip_regex" "$1"
}

assert_regular_file() {
    [[ -f "$1" && ! -L "$1" && "$(stat -f %l "$1")" == "1" ]] ||
        fail "required file is missing or aliased: $1"
}

assert_pinned_file() {
    local relative_path="$1" expected_mode="$2" expected_blob="$3"
    local expected_bytes="$4" expected_lf="$5" expected_sha256="$6"
    local absolute_path="$prime_root/$relative_path"
    assert_regular_file "$absolute_path"
    [[ "$(git -C "$prime_root" ls-files -s -- "$relative_path" | awk '{print $1}')" \
            == "$expected_mode" \
        && "$(git -C "$prime_root" hash-object -- "$relative_path")" \
            == "$expected_blob" \
        && "$(stat -f %z "$absolute_path")" == "$expected_bytes" \
        && "$(wc -l < "$absolute_path" | awk '{print $1}')" == "$expected_lf" \
        && "$(shasum -a 256 "$absolute_path" | awk '{print $1}')" \
            == "$expected_sha256" ]] ||
        fail "pinned file identity changed: $relative_path"
}

source_identity_json() {
    local relative_path="$1" role="$2"
    local index_record mode blob byte_count sha256
    index_record="$(git -C "$prime_root" ls-files -s -- "$relative_path")"
    [[ "$(printf '%s\n' "$index_record" | awk 'NF { count += 1 } END { print count + 0 }')" \
            == "1" ]] ||
        fail "source identity index record is not singular: $relative_path"
    mode="$(printf '%s\n' "$index_record" | awk '{print $1}')"
    blob="$(printf '%s\n' "$index_record" | awk '{print $2}')"
    assert_regular_file "$prime_root/$relative_path"
    byte_count="$(stat -f %z "$prime_root/$relative_path")"
    sha256="$(shasum -a 256 "$prime_root/$relative_path" | awk '{print $1}')"
    [[ "$mode" =~ ^100(644|755)$ \
        && "$blob" =~ ^[0-9a-f]{40}$ \
        && "$byte_count" =~ ^[1-9][0-9]*$ \
        && "$sha256" =~ ^[0-9a-f]{64}$ ]] ||
        fail "source identity is invalid: $relative_path"
    jq -cnS \
        --arg path "$relative_path" --arg git_mode "$mode" \
        --arg git_blob "$blob" --argjson byte_count "$byte_count" \
        --arg sha256 "$sha256" --arg role "$role" \
        '{path:$path,git_mode:$git_mode,git_blob:$git_blob,
          byte_count:$byte_count,sha256:$sha256,role:$role}'
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
    && "$exact_revision" =~ ^[0-9a-f]{40}$ \
    && "$mlx_revision" == "$required_mlx_revision" ]] ||
    fail "revision binding changed"
[[ -d "$runner_temp" && ! -L "$runner_temp" \
    && "$(cd "$runner_temp" && pwd -P)" == "$runner_temp" ]] ||
    fail "RUNNER_TEMP is not an exact physical directory"
[[ -f "${GITHUB_EVENT_PATH:-}" \
    && ! -L "${GITHUB_EVENT_PATH:-}" ]] ||
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
    fail "push event is not the exact direct-main mechanics successor"
[[ -z "${ERGENTICS_MLX_READ_TOKEN:-}" ]] ||
    fail "dependency credential reached Stage-5 replacement"

while IFS='=' read -r inherited_key _; do
    case "$inherited_key" in
        MLX_*|DYLD_*|LLVM_PROFILE_*|GIT_CONFIG_COUNT|GIT_CONFIG_KEY_*|GIT_CONFIG_VALUE_*|PRIME_NATIVE_DECODER_STAGE5_*)
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
readonly raw_tree="$(printf '%s\n' "$raw_commit_header" | \
    awk '/^tree / { print $2 }')"
readonly first_parent="$(printf '%s\n' "$raw_commit_header" | \
    awk '/^parent / { count += 1; if (count == 1) print $2 }')"
readonly second_parent="$(printf '%s\n' "$raw_commit_header" | \
    awk '/^parent / { count += 1; if (count == 2) print $2 }')"
[[ "$(printf '%s\n' "$raw_commit_header" | grep -Ec '^tree [0-9a-f]{40}$')" \
        == "1" \
    && "$(printf '%s\n' "$raw_commit_header" | grep -Ec '^parent [0-9a-f]{40}$')" \
        == "2" \
    && "$raw_tree" == "$exact_tree" \
    && "$first_parent" == "$authority_closure_revision" \
    && "$second_parent" =~ ^[0-9a-f]{40}$ \
    && "$second_parent" != "$first_parent" \
    && "$second_parent" != "$exact_revision" ]] ||
    fail "exact-main mechanics topology is not the direct two-parent successor"
readonly shallow_path="$prime_root/.git/shallow"
[[ "$(git -C "$prime_root" rev-parse --is-shallow-repository)" == "true" \
    && -f "$shallow_path" && ! -L "$shallow_path" \
    && "$(stat -f %l "$shallow_path")" == "1" \
    && "$(wc -l < "$shallow_path" | awk '{print $1}')" == "1" \
    && "$(grep -Fxc -- "$exact_revision" "$shallow_path")" == "1" ]] ||
    fail "reviewed mechanics checkout is not preserved at exact depth one"

readonly exact_changed_paths=(
    '.github/scripts/prime-ci-active-root-quarantine.sh'
    '.github/scripts/prime-ci-native-decoder-stage5-repeated-trajectory-replacement.sh'
    '.github/workflows/prime-active-root-quarantine.yml'
    'Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift'
    'Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift'
    'Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift'
    'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift'
    'Tests/PrimeCoreTests/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests.swift'
    'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift'
    'Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift'
)
readonly exact_changed_roles=(
    'active_root_gate'
    'replacement_launcher'
    'workflow'
    'embedded_provenance'
    'current_decoder_identity_source'
    'decoder_source'
    'training_source'
    'current_decoder_identity_test'
    'replacement_assay_test'
    'retained_decoder_authority_test'
)
readonly observed_preserved_index_sha256="$({
    git -C "$prime_root" ls-files -s |
        while IFS= read -r index_record; do
            relative_path="${index_record#*$'\t'}"
            skip_record=false
            for exact_path in "${exact_changed_paths[@]}"; do
                if [[ "$relative_path" == "$exact_path" ]]; then
                    skip_record=true
                    break
                fi
            done
            [[ "$skip_record" == true ]] || printf '%s\n' "$index_record"
        done
} | LC_ALL=C sort | shasum -a 256 | awk '{print $1}')"
[[ "$observed_preserved_index_sha256" == "$preserved_index_sha256" ]] ||
    fail "mechanics changed a path outside the exact ten-path closure"
for exact_index in "${!exact_changed_paths[@]}"; do
    expected_mode="100644"
    case "${exact_changed_paths[$exact_index]}" in
        '.github/scripts/'*) expected_mode="100755" ;;
    esac
    [[ "$(git -C "$prime_root" ls-files -s -- \
        "${exact_changed_paths[$exact_index]}" | awk '{print $1}')" \
        == "$expected_mode" ]] ||
        fail "exact changed path is missing or has the wrong mode: ${exact_changed_paths[$exact_index]}"
done
readonly exact_changed_source_identities_json="$(
    for exact_index in "${!exact_changed_paths[@]}"; do
        source_identity_json \
            "${exact_changed_paths[$exact_index]}" \
            "${exact_changed_roles[$exact_index]}"
    done | jq -csS .
)"
[[ "$(printf '%s' "$exact_changed_source_identities_json" | jq 'length')" \
        == "10" ]] ||
    fail "exact changed identity inventory is not ten"

readonly embedded_source_identity="$(awk '
    /public static let sourceIdentitySHA256/ {
        getline
        gsub(/[ "\t]/, "")
        print
        exit
    }
' "$embedded_provenance")"
[[ "$embedded_source_identity" =~ ^[0-9a-f]{64}$ ]] ||
    fail "embedded source identity is not finally pinned"

assert_pinned_file \
    'Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthority.swift' \
    '100644' 'ded305476edfc832ae4e910b1985da77c7a10cd0' \
    '144935' '2728' \
    '634eabe81f63a570cfe2f565d95befbd8c77ea98ba7864a212f45511c7f8b5fc'
assert_pinned_file \
    'Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityTests.swift' \
    '100644' 'e7e240f6bb6e037f0b41f28d925ce0fcd38c42a7' \
    '49796' '1017' \
    '71506cbc21fb8d03886bdc95500e6249f5d61a59f84569dfda95875289435e08'
assert_pinned_file \
    'Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift' \
    '100644' 'de6cff4472de55a8fafe2962c3be4ca37c972caf' \
    '43339' '1193' \
    'ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc'
assert_pinned_file \
    'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift' \
    '100644' '4566477e14b4b6cfa06286f384f07f8d452e8724' \
    '97449' '2444' \
    'cab64f1e77d6f72bfef971bb8e1e4c40aee6072c1ed21f3b466599328f88fdcb'
assert_pinned_file \
    'Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift' \
    '100644' '68a711c708eecff01b9d63795cdcb03c127d64b8' \
    '23783' '526' \
    '88451317772e9ec05a1bb59362c4d2c3e953cb9284a3b9db65ee1892222f88c9'
assert_pinned_file \
    'Tests/PrimeCoreTests/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests.swift' \
    '100644' 'f5b8e7787616d650b0a990227e2744b84d8b5e4c' \
    '23283' '570' \
    'b0bdb47454adc6f9d69ec6e47f1cbc2df7c3c5aa8ccb1ac9d68a4ab593d605aa'
assert_pinned_file \
    'Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift' \
    '100644' '9dbb273db5532ad5bf0c7eea502ec92204220bbd' \
    '35521' '761' \
    'f9a7cd1ff68065a53fd6fdf653010ebad74ff99b48fe437f43c41f2d417c7938'
assert_pinned_file \
    'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift' \
    '100644' '1ed960a79c397cebcdfd3e9b62ab9acc67c894d7' \
    '142985' '3845' \
    '62aa2bdd1ac68c83630f771fe58ac36fa2e4a885e5e657cbcc56efe33b4ac836'
assert_pinned_file \
    'Tests/PrimeNativeDecoderTrainingValidation/Package.swift' \
    '100644' '1bce54baedf4293fcba01238228105f987fd43d3' \
    '1993' '69' \
    '8488fbd194efcd6900604923a922485f72c2ce4b870c6efd2267564f3bff43a9'
assert_pinned_file \
    'Tests/PrimeNativeDecoderTrainingValidation/Package.resolved' \
    '100644' '8bf05edf1ea8789e7683e72fe756d79aaaa61320' \
    '645' '23' \
    'a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225'
assert_pinned_file \
    '.github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh' \
    '100755' '6547ee06663c1ea409a6256e48f6111245056020' \
    '48869' '830' \
    'c639cfcb4d1d0a103b285ed38849565f16b00932fc3b9d921febbf798c30d5f9'
assert_pinned_file \
    '.github/scripts/prime-ci-native-decoder-stage6-native300m-resource-only-one-step.sh' \
    '100755' '9e8f7ca0c6fa6c02bc4b0f40cc2185d2e6d46d13' \
    '108576' '2016' \
    '8801c46f54eaee475f3a2fdb697b2184af4233b9cdf7a66ddd9867d14eb4f349'
grep -Fq "$authority_canonical_sha256" "$authority_source" ||
    fail "replacement authority canonical digest changed"
readonly authority_source_identity_json="$(
    source_identity_json \
        'Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthority.swift' \
        'replacement_execution_authority_source'
)"
readonly authority_test_identity_json="$(
    source_identity_json \
        'Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityTests.swift' \
        'replacement_execution_authority_test'
)"

[[ -d "$mlx_bare" && ! -L "$mlx_bare" \
    && "$(git --git-dir="$mlx_bare" rev-parse refs/heads/prime-pinned)" \
        == "$mlx_revision" ]] ||
    fail "MLX bare repository changed"
[[ -d "$mlx_source" && ! -L "$mlx_source" \
    && "$(git -C "$mlx_source" rev-parse HEAD)" == "$mlx_revision" \
    && -z "$(git -C "$mlx_source" status --porcelain=v1 --untracked-files=all)" \
    && "$(git -C "$mlx_source" submodule status --recursive | \
        grep -Ec "^[ +-]$required_mlx_c_revision Source/Cmlx/mlx-c")" == "1" ]] ||
    fail "MLX source worktree or mlx-c revision changed"

readonly predecessor_test_logs=(
    "$active_root_log"
    "$checkpoint_v2_log"
    "$checkpoint_v2_io_log"
    "$checkpoint_v2_io_execution_log"
    "$checkpoint_v2_io_root_repair_log"
    "$metal_log"
    "$runtime_test_log"
    "$tokenizer_test_log"
)
readonly predecessor_receipt_logs=("$runtime_probe_log" "$tokenizer_probe_log")
for predecessor_log in "${predecessor_test_logs[@]}" \
    "${predecessor_receipt_logs[@]}"; do
    assert_regular_file "$predecessor_log"
done
grep -Fq 'Executed 58 tests, with 0 failures' "$active_root_log" ||
    fail "root-58 contracts did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_log" ||
    fail "checkpoint compatibility predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$checkpoint_v2_io_log" ||
    fail "checkpoint I/O predecessor did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' "$checkpoint_v2_io_execution_log" ||
    fail "checkpoint I/O execution predecessor did not complete"
grep -Fq 'Executed 2 tests, with 0 failures' "$checkpoint_v2_io_root_repair_log" ||
    fail "checkpoint root-repair predecessor did not complete"
grep -Fq 'Executed 44 tests, with 0 failures' "$metal_log" ||
    fail "Metal-44 predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$runtime_test_log" ||
    fail "runtime predecessor did not complete"
grep -Fq 'Executed 1 test, with 0 failures' "$tokenizer_test_log" ||
    fail "tokenizer predecessor did not complete"
for predecessor_test_log in "${predecessor_test_logs[@]}"; do
    ! xctest_log_has_failure_or_skip "$predecessor_test_log" ||
        fail "predecessor test log failed or skipped: $predecessor_test_log"
done
[[ "$(grep -Ec '^PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=' \
        "$runtime_probe_log")" == "1" \
    && "$(grep -Ec '^PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=' \
        "$tokenizer_probe_log")" == "1" ]] ||
    fail "predecessor receipt inventory changed"
for predecessor_log in "${predecessor_test_logs[@]}" \
    "${predecessor_receipt_logs[@]}"; do
    for forbidden_prefix in \
        'PRIME_NATIVE_DECODER_STAGE5_TINY_REPEATED_METAL_TRAJECTORY_DETERMINISM_RECEIPT=' \
        "$receipt_prefix" \
        'PRIME_NATIVE_DECODER_STAGE6_NATIVE300M_RESOURCE_ONLY_ONE_STEP_RECEIPT_V1='; do
        [[ "$(awk -v needle="$forbidden_prefix" '
            { line = $0; while ((position = index(line, needle)) > 0) {
                count += 1
                line = substr(line, position + length(needle))
            }} END { print count + 0 }
        ' "$predecessor_log")" == "0" ]] ||
            fail "retired or replacement receipt prefix existed in predecessor log"
    done
done

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
    "$security_path" "$private_cwd" "$lease_root" "$lease_path" "$test_log"; do
    [[ ! -e "$fresh_path" && ! -L "$fresh_path" ]] ||
        fail "replacement path must be initially absent: $fresh_path"
done
mkdir -p "$scratch_path" "$cache_path" "$config_path" "$security_path" \
    "$private_cwd" "$lease_root"
chmod 700 "$private_cwd" "$lease_root"
readonly effective_uid="$(id -u)"
[[ -d "$lease_root" && ! -L "$lease_root" \
    && "$(cd "$lease_root" && pwd -P)" == "$lease_root" \
    && "$(stat -f %u "$lease_root")" == "$effective_uid" \
    && "$(stat -f %Lp "$lease_root")" == "700" \
    && "$(stat -f %l "$lease_root")" == "2" \
    && -z "$(find "$lease_root" -mindepth 1 -print)" ]] ||
    fail "replacement lease parent is not an empty owner-only directory"
[[ -d "$private_cwd" && ! -L "$private_cwd" \
    && "$(cd "$private_cwd" && pwd -P)" == "$private_cwd" \
    && "$(stat -f %u "$private_cwd")" == "$effective_uid" \
    && "$(stat -f %Lp "$private_cwd")" == "700" \
    && -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private replacement working directory is invalid"

readonly root_numerics_checkout="$runner_temp/prime-active-root-build/checkouts/swift-numerics"
readonly root_numerics_cache="$runner_temp/prime-active-root-build/repositories/swift-numerics-d936ec6c"
[[ -d "$root_numerics_checkout" && ! -L "$root_numerics_checkout" \
    && "$(git -C "$root_numerics_checkout" rev-parse HEAD)" \
        == "$numerics_revision" \
    && -z "$(git -C "$root_numerics_checkout" status \
        --porcelain=v1 --untracked-files=all)" ]] ||
    fail "root Swift Numerics checkout changed"
[[ -d "$root_numerics_cache" && ! -L "$root_numerics_cache" \
    && "$(git -C "$root_numerics_cache" rev-parse --is-bare-repository)" \
        == "true" \
    && "$(git -C "$root_numerics_cache" rev-parse \
        "$numerics_revision^{commit}")" == "$numerics_revision" \
    && "$(git -C "$root_numerics_cache" rev-parse \
        'refs/tags/1.1.1^{commit}')" == "$numerics_revision" ]] ||
    fail "root Swift Numerics cache topology changed"

export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0="url.file://$mlx_bare/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/Ergentics/ergentics-mlx-swift"
export GIT_CONFIG_KEY_1="url.file://$root_numerics_cache/.insteadOf"
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
    fail "replacement XCTest executable is missing"
for framework in CoreGraphics Metal; do
    otool -L "$test_executable" | grep -Fq "/$framework.framework/" ||
        fail "replacement XCTest executable does not link $framework"
done
[[ -z "$(find "$bin_path" \
    \( -name default.metallib -o -name mlx.metallib \) -print)" ]] ||
    fail "replacement build already contains a metallib candidate"
mkdir -p "$(dirname "$cli_metallib")" "$(dirname "$test_resource_metallib")"
cp -X "$metallib" "$cli_metallib"
cp -X "$metallib" "$test_resource_metallib"
chmod 444 "$cli_metallib" "$test_resource_metallib"
for staged_metallib in "$cli_metallib" "$test_resource_metallib"; do
    assert_regular_file "$staged_metallib"
    [[ "$(stat -f %Lp "$staged_metallib")" == "444" \
        && "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
        && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
            == "$metallib_sha256" ]] ||
        fail "staged metallib identity changed"
    cmp -s "$metallib" "$staged_metallib" ||
        fail "staged metallib bytes changed"
done

readonly operating_system_build="$(sw_vers -productVersion)-$(sw_vers -buildVersion)"
readonly swift_version="$(swift --version | tr '\n' ' ' | awk '{$1=$1; print}')"
readonly xcode_version="$(xcodebuild -version | tr '\n' ' ' | awk '{$1=$1; print}')"
readonly swift_sdk="$(xcrun --sdk macosx --show-sdk-version)"

set +e
(
    cd "$private_cwd"
    env \
        TMPDIR="$runner_temp" \
        MLX_ENABLE_TF32=0 \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_METAL_LEASE_PATH="$lease_path" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_ID="$authority_id" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CANONICAL_SHA256="$authority_canonical_sha256" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_SOURCE_IDENTITY_JSON="$authority_source_identity_json" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_TEST_IDENTITY_JSON="$authority_test_identity_json" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_REVISION="$authority_closure_revision" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_TREE="$authority_closure_tree" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_RUN_ID="$authority_closure_run_id" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_RUN_NUMBER="$authority_closure_run_number" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_RUN_ATTEMPT="$authority_closure_run_attempt" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_CHECK_SUITE_ID="$authority_closure_check_suite_id" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_ACTIVE_JOB_ID="$authority_closure_active_job_id" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_ACTIVE_JOB_CONCLUSION="success" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_REVIEWED_JOB_ID="$authority_closure_reviewed_job_id" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_REVIEWED_JOB_CONCLUSION="success" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_CONCLUSION="success" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_ARTIFACT_COUNT="0" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_RERUN_COUNT="0" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_AUTHORITY_CLOSURE_RETRY_COUNT="0" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_MECHANICS_HEAD_REVISION="$exact_revision" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_MECHANICS_HEAD_TREE="$exact_tree" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_MECHANICS_HEAD_FIRST_PARENT="$first_parent" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_MECHANICS_HEAD_SECOND_PARENT="$second_parent" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_MECHANICS_EVENT="push" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_MECHANICS_REF="refs/heads/main" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_MECHANICS_RUN_ATTEMPT="1" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_EXACT_MAIN_REVISION="$exact_revision" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_EXACT_MAIN_TREE="$exact_tree" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_EXACT_CHANGED_SOURCE_IDENTITIES_JSON="$exact_changed_source_identities_json" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_EMBEDDED_SOURCE_IDENTITY_SHA256="$embedded_source_identity" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_EXACT_MLX_REVISION="$mlx_revision" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_EXACT_MLX_C_REVISION="$required_mlx_c_revision" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_METALLIB_PATH="$test_resource_metallib" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_METALLIB_BYTES="$metallib_byte_count" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_METALLIB_SHA256="$metallib_sha256" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_OPERATING_SYSTEM_BUILD="$operating_system_build" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_SWIFT_VERSION="$swift_version" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_XCODE_VERSION="$xcode_version" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_SWIFT_SDK="$swift_sdk" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_BUILD_CONFIGURATION="debug" \
        PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_MLX_GRAPH_COMPILE_MODE="eager_uncompiled_no_compile_transform" \
        xcrun xctest -XCTest "$test_filter" "$test_bundle"
) 2>&1 | tee "$test_log"
test_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${#test_pipe_status[@]}" -eq 2 \
    && "${test_pipe_status[0]}" -eq 0 \
    && "${test_pipe_status[1]}" -eq 0 ]] ||
    fail "replacement direct XCTest or log capture failed"
assert_regular_file "$test_log"
[[ "$(grep -Ec '^Test Case .* started\.$' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* passed \(' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* failed \(' "$test_log")" == "0" \
    && "$(grep -Eic '^Test Case .* skipped \(' "$test_log")" == "0" ]] ||
    fail "replacement test counts are not 1/1/0/0"
grep -Fq "$test_method" "$test_log" ||
    fail "exact replacement method did not execute"
grep -Eq 'Executed 1 test, with 0 failures' "$test_log" ||
    fail "replacement test summary changed"
! xctest_log_has_failure_or_skip "$test_log" ||
    fail "replacement test reported a failure or skip"

readonly anchored_receipt_count="$(grep -Ec "^$receipt_prefix" "$test_log")"
readonly total_receipt_occurrence_count="$(awk -v needle="$receipt_prefix" '
    { line = $0; while ((position = index(line, needle)) > 0) {
        count += 1
        line = substr(line, position + length(needle))
    }} END { print count + 0 }
' "$test_log")"
[[ "$anchored_receipt_count" == "1" \
    && "$total_receipt_occurrence_count" == "1" ]] ||
    fail "replacement direct XCTest did not emit exactly one anchored receipt"
readonly receipt_json="$(awk -v prefix="$receipt_prefix" '
    index($0, prefix) == 1 { print substr($0, length(prefix) + 1) }
' "$test_log")"
[[ -n "$receipt_json" \
    && "$(printf '%s' "$receipt_json" | jq -cS .)" == "$receipt_json" ]] ||
    fail "replacement receipt is not one canonical JSON object"

printf '%s' "$receipt_json" | jq -e \
    --arg authority_id "$authority_id" \
    --arg authority_sha "$authority_canonical_sha256" \
    --arg authority_source_blob "ded305476edfc832ae4e910b1985da77c7a10cd0" \
    --arg authority_source_sha "634eabe81f63a570cfe2f565d95befbd8c77ea98ba7864a212f45511c7f8b5fc" \
    --arg authority_test_blob "e7e240f6bb6e037f0b41f28d925ce0fcd38c42a7" \
    --arg authority_test_sha "71506cbc21fb8d03886bdc95500e6249f5d61a59f84569dfda95875289435e08" \
    --arg closure_revision "$authority_closure_revision" \
    --arg closure_tree "$authority_closure_tree" \
    --argjson closure_run_id "$authority_closure_run_id" \
    --argjson closure_run_number "$authority_closure_run_number" \
    --argjson closure_suite_id "$authority_closure_check_suite_id" \
    --argjson closure_active_job_id "$authority_closure_active_job_id" \
    --argjson closure_reviewed_job_id "$authority_closure_reviewed_job_id" \
    --arg revision "$exact_revision" --arg tree "$exact_tree" \
    --arg first_parent "$first_parent" --arg second_parent "$second_parent" \
    --argjson changed_identities "$exact_changed_source_identities_json" \
    --arg embedded_identity "$embedded_source_identity" \
    --arg mlx_revision "$mlx_revision" \
    --arg mlx_c_revision "$required_mlx_c_revision" \
    --arg metallib_path "$test_resource_metallib" \
    --argjson metallib_bytes "$metallib_byte_count" \
    --arg metallib_sha "$metallib_sha256" \
    --arg lease_path "$lease_path" \
    --arg os_build "$operating_system_build" \
    --arg swift "$swift_version" --arg xcode "$xcode_version" \
    --arg sdk "$swift_sdk" --arg test_filter "$test_filter" '
      def exact_keys($expected): keys == ($expected | sort);
      def mismatch_keys:
        ["arm","branch","byte_offset","comparison_domain","component","dtype",
         "forward_boundary","observed_branch",
         "observed_scalar_float32_bits","observed_sha256",
         "parameter_or_tensor_path","reference_branch",
         "reference_scalar_float32_bits","reference_sha256","scalar_name",
         "shape","trial_ordinal"];
      def lower_hex($count):
        type == "string"
        and length == $count
        and test("^[0-9a-f]+$");
      def mismatch_common($arm):
        type == "object"
        and exact_keys(mismatch_keys)
        and .arm == $arm
        and (.trial_ordinal | type == "number" and floor == .
          and . >= 1 and . <= 3)
        and (.comparison_domain | type == "string")
        and (.branch | type == "string")
        and (.reference_branch | type == "string")
        and (.observed_branch | type == "string");
      def scalar_mismatch($arm):
        mismatch_common($arm)
        and .component == "scalar_float32_bits"
        and .byte_offset == null
        and .dtype == null
        and .observed_sha256 == null
        and .parameter_or_tensor_path == null
        and .reference_sha256 == null
        and .shape == null
        and (.scalar_name | type == "string" and length > 0)
        and (.observed_scalar_float32_bits |
          type == "number" and floor == .
          and . >= 0 and . <= 4294967295)
        and (.reference_scalar_float32_bits |
          type == "number" and floor == .
          and . >= 0 and . <= 4294967295)
        and .observed_scalar_float32_bits !=
          .reference_scalar_float32_bits;
      def tensor_byte_count:
        . as $mismatch
        | (if $mismatch.dtype == "float32" then 4
          elif $mismatch.dtype == "uint8" then 1
          else empty
          end) as $width
        | reduce $mismatch.shape[] as $dimension (
            {valid:true,product:1};
            if .valid
              and $dimension <=
                (9007199254740991 / (.product * $width) | floor)
            then
              .product *= $dimension
            else
              .valid = false
            end)
        | select(.valid)
        | .product * $width;
      def tensor_mismatch($arm):
        mismatch_common($arm)
        and (.component | type == "string" and
          . != "scalar_float32_bits" and length > 0)
        and (.byte_offset | type == "number" and floor == . and . >= 0)
        and (.dtype == "float32" or .dtype == "uint8")
        and (.observed_sha256 | lower_hex(64))
        and (.parameter_or_tensor_path | type == "string" and length > 0)
        and (.reference_sha256 | lower_hex(64))
        and .observed_sha256 != .reference_sha256
        and .observed_scalar_float32_bits == null
        and .reference_scalar_float32_bits == null
        and .scalar_name == null
        and (.shape | type == "array" and length > 0
          and all(.[]; type == "number" and floor == . and . > 0))
        and (.byte_offset < tensor_byte_count);
      def forward_domain:
        .comparison_domain ==
          "arm_b_embedding_forward_bytes_against_arm_a"
        or .comparison_domain ==
          "arm_b_whole_logits_forward_bytes_against_arm_a";
      def valid_arm_a_tensor_mismatch($receipt):
        tensor_mismatch("arm_a")
        and .forward_boundary == null
        and .comparison_domain ==
          "maintained_gather_source_step_tensor_bytes"
        and .branch == "source_snapshot"
        and .reference_branch == "uninterrupted"
        and .observed_branch == "source_snapshot"
        and (. as $mismatch |
          any($receipt.arm_a.source_step_equal_by_pair[];
            .trial_ordinal == $mismatch.trial_ordinal
              and .exact == false));
      def valid_arm_a_scalar_mismatch($receipt):
        scalar_mismatch("arm_a")
        and .forward_boundary == null
        and .comparison_domain ==
          "maintained_gather_source_step_scalar_bits"
        and (.branch == "uninterrupted" or .branch == "source_snapshot")
        and (. as $mismatch |
          if $mismatch.reference_branch == "expected_fixture" then
            $mismatch.observed_branch == $mismatch.branch
            and (if $mismatch.scalar_name == "global_step" then
              any($receipt.arm_a.global_step_one_by_pair[];
                .trial_ordinal == $mismatch.trial_ordinal
                  and .exact == false)
            elif $mismatch.scalar_name == "selected_target_count" then
              any($receipt.arm_a.selected_target_count_six_by_pair[];
                .trial_ordinal == $mismatch.trial_ordinal
                  and .exact == false)
            else
              false
            end)
          else
            $mismatch.branch == "source_snapshot"
            and $mismatch.reference_branch == "uninterrupted"
            and $mismatch.observed_branch == "source_snapshot"
            and any($receipt.arm_a.source_step_equal_by_pair[];
              .trial_ordinal == $mismatch.trial_ordinal
                and .exact == false)
          end);
      def valid_arm_b_mismatch($receipt):
        (if forward_domain then
          tensor_mismatch("arm_b")
          and .reference_branch == "maintained_gather_v1"
          and .observed_branch ==
            "flattened_dense_one_hot_matmul_input_embedding_v1"
          and (.forward_boundary | type == "string"
            and (. == "initial"
              or . == "source_boundary"
              or . == "terminal"))
          and .branch ==
            (if .forward_boundary == "initial" then
              "uninterrupted"
            elif .forward_boundary == "source_boundary" then
              "source_snapshot"
            else
              "fresh_restored_from_source_snapshot"
            end)
          and (if .comparison_domain ==
              "arm_b_embedding_forward_bytes_against_arm_a"
            then
              .component == "input_embedding_forward_bytes"
              and .dtype == "float32"
              and .parameter_or_tensor_path ==
                (.forward_boundary + "/input_embedding")
              and .shape == [2,6,16]
            else
              .component == "whole_logits_forward_bytes"
              and .dtype == "float32"
              and .parameter_or_tensor_path ==
                (.forward_boundary + "/whole_logits")
              and .shape == [2,6,32]
            end)
        else
          (scalar_mismatch("arm_b") or tensor_mismatch("arm_b"))
            and .forward_boundary == null
            and (.branch == "uninterrupted"
              or .branch == "source_snapshot"
              or .branch == "fresh_restored_from_source_snapshot")
            and .observed_branch == .branch
            and (if .reference_branch == .branch then
              .trial_ordinal >= 2
            else
              .reference_branch == "uninterrupted"
              and (.branch == "source_snapshot"
                or .branch ==
                  "fresh_restored_from_source_snapshot")
            end)
        end)
        and (. as $mismatch |
          if $mismatch.comparison_domain ==
              "arm_b_embedding_forward_bytes_against_arm_a"
          then
            any(
              $receipt.forward_equivalence
                .embedding_forward_exact_by_boundary[];
              .trial_ordinal == $mismatch.trial_ordinal
                and .boundary == $mismatch.forward_boundary
                and .exact == false)
          elif $mismatch.comparison_domain ==
              "arm_b_whole_logits_forward_bytes_against_arm_a"
          then
            any(
              $receipt.forward_equivalence
                .whole_logits_exact_by_boundary[];
              .trial_ordinal == $mismatch.trial_ordinal
                and .boundary == $mismatch.forward_boundary
                and .exact == false)
          else
            any($receipt.arm_b.comparison_domain_results[];
              .comparison_domain == $mismatch.comparison_domain
                and .exact == false)
          end);
      . as $receipt
      | type == "object"
      and exact_keys(["arm_a","arm_b","authority","ceiling","environment",
        "execution","forward_equivalence","operation_counts","receipt_id",
        "schema_version","status"])
      and .schema_version == 1
      and .receipt_id ==
        "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_receipt_v1"
      and (.status == "PASS_CLEARANCE"
        or .status == "MEASURED_EXACT_MISMATCH")
      and .authority == {
        authority_canonical_sha256:$authority_sha,
        authority_id:$authority_id,
        authority_source_git_blob:$authority_source_blob,
        authority_source_sha256:$authority_source_sha,
        authority_test_git_blob:$authority_test_blob,
        authority_test_sha256:$authority_test_sha}
      and (.execution | exact_keys([
        "artifact_count","authority_closure_active_job_conclusion",
        "authority_closure_active_job_id","authority_closure_check_suite_id",
        "authority_closure_conclusion",
        "authority_closure_reviewed_job_conclusion",
        "authority_closure_reviewed_job_id","authority_closure_revision",
        "authority_closure_run_attempt","authority_closure_run_id",
        "authority_closure_run_number","authority_closure_tree","build_count",
        "direct_xctest_count","embedded_source_identity_sha256",
        "exact_changed_source_identities","exact_main_revision",
        "exact_main_tree","launcher_invocation_count",
        "lease_acquired_before_coregraphics_metal_or_mlx","lease_path",
        "mechanics_event","mechanics_head_ordered_parent_revisions",
        "mechanics_head_revision","mechanics_head_tree","mechanics_ref",
        "mechanics_run_attempt","one_shot_consumed",
        "original_stage5_launcher_invocation_count","rerun_count",
        "retained_metal_device_identity","retry_count",
        "stage6_launcher_invocation_count","test_filter"]))
      and .execution.authority_closure_revision == $closure_revision
      and .execution.authority_closure_tree == $closure_tree
      and .execution.authority_closure_run_id == $closure_run_id
      and .execution.authority_closure_run_number == $closure_run_number
      and .execution.authority_closure_run_attempt == 1
      and .execution.authority_closure_check_suite_id == $closure_suite_id
      and .execution.authority_closure_active_job_id == $closure_active_job_id
      and .execution.authority_closure_reviewed_job_id ==
        $closure_reviewed_job_id
      and .execution.authority_closure_active_job_conclusion == "success"
      and .execution.authority_closure_reviewed_job_conclusion == "success"
      and .execution.authority_closure_conclusion == "success"
      and .execution.exact_main_revision == $revision
      and .execution.exact_main_tree == $tree
      and .execution.mechanics_head_revision == $revision
      and .execution.mechanics_head_tree == $tree
      and .execution.mechanics_head_ordered_parent_revisions ==
        [$first_parent,$second_parent]
      and .execution.mechanics_event == "push"
      and .execution.mechanics_ref == "refs/heads/main"
      and .execution.mechanics_run_attempt == 1
      and .execution.exact_changed_source_identities == $changed_identities
      and .execution.embedded_source_identity_sha256 == $embedded_identity
      and .execution.build_count == 1
      and .execution.direct_xctest_count == 1
      and .execution.launcher_invocation_count == 1
      and .execution.original_stage5_launcher_invocation_count == 0
      and .execution.stage6_launcher_invocation_count == 0
      and .execution.artifact_count == 0
      and .execution.rerun_count == 0
      and .execution.retry_count == 0
      and .execution.one_shot_consumed == true
      and .execution.lease_acquired_before_coregraphics_metal_or_mlx == true
      and .execution.lease_path == $lease_path
      and .execution.test_filter == $test_filter
      and (.execution.retained_metal_device_identity |
        exact_keys(["name","registry_id"])
        and (.name | type == "string" and length > 0)
        and (.registry_id | type == "number" and floor == .
          and . >= 0 and . <= 18446744073709551615))
      and (.environment | exact_keys([
        "exact_metallib_byte_count","exact_metallib_path",
        "exact_metallib_sha256","exact_mlx_c_revision","exact_mlx_revision",
        "lease_path","lease_type","metal_device_count","metal_device_index",
        "metal_device_is_default","metal_device_name",
        "metal_device_registry_id","mlx_compile_transform_invocation_count",
        "mlx_default_stream_is_gpu","mlx_enable_tf32",
        "mlx_graph_compile_mode","operating_system_build","swift_sdk",
        "swift_version","swiftpm_build_configuration","xcode_version"]))
      and .environment.exact_metallib_byte_count == $metallib_bytes
      and .environment.exact_metallib_path == $metallib_path
      and .environment.exact_metallib_sha256 == $metallib_sha
      and .environment.exact_mlx_revision == $mlx_revision
      and .environment.exact_mlx_c_revision == $mlx_c_revision
      and .environment.lease_path == $lease_path
      and .environment.lease_type == "PrimeMetalDeviceLease"
      and .environment.metal_device_count == 1
      and .environment.metal_device_index == 0
      and .environment.metal_device_is_default == true
      and .environment.mlx_compile_transform_invocation_count == 0
      and .environment.mlx_default_stream_is_gpu == true
      and .environment.mlx_enable_tf32 == "0"
      and .environment.mlx_graph_compile_mode ==
        "eager_uncompiled_no_compile_transform"
      and .environment.operating_system_build == $os_build
      and .environment.swift_version == $swift
      and .environment.xcode_version == $xcode
      and .environment.swift_sdk == $sdk
      and .environment.swiftpm_build_configuration == "debug"
      and (.environment.metal_device_name |
        type == "string" and length > 0)
      and (.environment.metal_device_registry_id |
        type == "number" and floor == .
        and . >= 0 and . <= 18446744073709551615)
      and .environment.metal_device_name ==
        .execution.retained_metal_device_identity.name
      and .environment.metal_device_registry_id ==
        .execution.retained_metal_device_identity.registry_id
      and (.arm_a | exact_keys([
        "completed_diagnostic_pair_count","first_scalar_mismatch",
        "first_tensor_mismatch","global_step_one_by_pair",
        "measured_mismatch","pair_branch_names",
        "selected_target_count_six_by_pair","source_step_equal_by_pair",
        "trial_count"]))
      and .arm_a.completed_diagnostic_pair_count == 3
      and .arm_a.trial_count == 3
      and .arm_a.pair_branch_names == ["uninterrupted","source_snapshot"]
      and ([.arm_a.global_step_one_by_pair,
            .arm_a.selected_target_count_six_by_pair,
            .arm_a.source_step_equal_by_pair] |
        all(.[]; length == 3
          and all(.[];
            exact_keys(["exact","observed_branch","reference_branch",
              "trial_ordinal"])
            and (.exact | type == "boolean")
            and (.trial_ordinal >= 1 and .trial_ordinal <= 3)
            and .reference_branch == "uninterrupted"
            and .observed_branch == "source_snapshot")))
      and ([.arm_a.global_step_one_by_pair[].trial_ordinal,
            .arm_a.selected_target_count_six_by_pair[].trial_ordinal,
            .arm_a.source_step_equal_by_pair[].trial_ordinal] |
        .[0:3] == [1,2,3]
        and .[3:6] == [1,2,3]
        and .[6:9] == [1,2,3])
      and .arm_a.measured_mismatch ==
        ([.arm_a.global_step_one_by_pair[].exact,
          .arm_a.selected_target_count_six_by_pair[].exact,
          .arm_a.source_step_equal_by_pair[].exact] |
          any(. == false))
      and (.arm_a.first_scalar_mismatch == null
        or (.arm_a.first_scalar_mismatch |
          valid_arm_a_scalar_mismatch($receipt)))
      and (.arm_a.first_tensor_mismatch == null
        or (.arm_a.first_tensor_mismatch |
          valid_arm_a_tensor_mismatch($receipt)))
      and (if .arm_a.measured_mismatch then
        (.arm_a.first_scalar_mismatch != null
          or .arm_a.first_tensor_mismatch != null)
      else
        (.arm_a.first_scalar_mismatch == null
          and .arm_a.first_tensor_mismatch == null)
      end)
      and (.arm_b | exact_keys([
        "all_exact_comparisons_passed",
        "all_forward_equivalence_checks_passed","branch_names",
        "comparison_domain_results","first_mismatch","fresh_constructor",
        "restore_constructor","selector_id_by_branch","status",
        "trajectory_branch_count","trial_count"]))
      and .arm_b.branch_names == ["uninterrupted","source_snapshot",
        "fresh_restored_from_source_snapshot"]
      and .arm_b.trial_count == 3
      and .arm_b.trajectory_branch_count == 9
      and .arm_b.fresh_constructor ==
        "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(metalGPUIndexZero:stage5ReplacementTrainingInputPath:)"
      and .arm_b.restore_constructor ==
        "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(restoring:metalGPUIndexZero:stage5ReplacementTrainingInputPath:)"
      and (.arm_b.comparison_domain_results | length == 7
        and all(.[];
          exact_keys(["comparison_domain","exact"])
          and (.comparison_domain | type == "string")
          and (.exact | type == "boolean")))
      and [.arm_b.comparison_domain_results[].comparison_domain] == [
        "control_rng_and_cursor_state",
        "evaluation_loss_and_logits_bytes",
        "global_step_and_selected_target_count",
        "model_parameter_bytes",
        "optimizer_first_and_second_moment_bytes",
        "raw_and_clipped_gradient_bytes",
        "training_loss_norm_and_clip_scalar_bits"]
      and .arm_b.comparison_domain_results[2].exact == true
      and .arm_b.all_exact_comparisons_passed ==
        ([.arm_b.comparison_domain_results[].exact] | all)
      and (.arm_b.selector_id_by_branch | length == 9
        and all(.[];
          exact_keys(["branch","selector_id","trial_ordinal"])
          and (.trial_ordinal | type == "number" and floor == .)
          and (.branch | type == "string")
          and (.selector_id | type == "string")))
      and ([.arm_b.selector_id_by_branch[].selector_id] |
        all(. == "flattened_dense_one_hot_matmul_input_embedding_v1"))
      and [.arm_b.selector_id_by_branch[].trial_ordinal] ==
        [1,1,1,2,2,2,3,3,3]
      and [.arm_b.selector_id_by_branch[].branch] ==
        ["uninterrupted","source_snapshot",
         "fresh_restored_from_source_snapshot",
         "uninterrupted","source_snapshot",
         "fresh_restored_from_source_snapshot",
         "uninterrupted","source_snapshot",
         "fresh_restored_from_source_snapshot"]
      and (.forward_equivalence | exact_keys([
        "boundary_names","embedding_forward_exact_by_boundary",
        "same_model_pre_mutation","whole_logits_exact_by_boundary"]))
      and .forward_equivalence.boundary_names ==
        ["initial","source_boundary","terminal"]
      and .forward_equivalence.same_model_pre_mutation == true
      and ([.forward_equivalence.embedding_forward_exact_by_boundary,
            .forward_equivalence.whole_logits_exact_by_boundary] |
        all(.[]; length == 9
          and all(.[];
            exact_keys(["boundary","exact","trial_ordinal"])
            and (.exact | type == "boolean")
            and (.trial_ordinal >= 1 and .trial_ordinal <= 3)
            and (.boundary == "initial"
              or .boundary == "source_boundary"
              or .boundary == "terminal"))))
      and ([.forward_equivalence.embedding_forward_exact_by_boundary,
            .forward_equivalence.whole_logits_exact_by_boundary] |
        all(.[];
          [.[].trial_ordinal] == [1,1,1,2,2,2,3,3,3]
          and [.[].boundary] == [
            "initial","source_boundary","terminal",
            "initial","source_boundary","terminal",
            "initial","source_boundary","terminal"]))
      and .arm_b.all_forward_equivalence_checks_passed ==
        ([.forward_equivalence.embedding_forward_exact_by_boundary[].exact,
          .forward_equivalence.whole_logits_exact_by_boundary[].exact] | all)
      and .arm_b.status == .status
      and (if .status == "PASS_CLEARANCE" then
        .arm_b.all_exact_comparisons_passed == true
        and .arm_b.all_forward_equivalence_checks_passed == true
        and .arm_b.first_mismatch == null
      else
        (.arm_b.all_exact_comparisons_passed == false
          or .arm_b.all_forward_equivalence_checks_passed == false)
        and (.arm_b.first_mismatch | valid_arm_b_mismatch($receipt))
      end)
      and .operation_counts == {
        arm_a_source_step_count:6,
        arm_b_dense_embedding_construction_count:66,
        arm_b_dense_whole_logits_call_count:57,
        arm_b_evaluate_count:18,
        arm_b_forward_equivalence_check_count:9,
        arm_b_input_embedding_pair_seam_count:9,
        arm_b_restore_count:3,
        arm_b_snapshot_count:3,
        arm_b_token_bounds_checked_eval_count:66,
        arm_b_token_bounds_gpu_synchronize_count:66,
        arm_b_token_bounds_host_bool_item_count:66,
        arm_b_token_bounds_validation_count:66,
        arm_b_training_step_count:15,
        receipt_count:1,
        synchronize_count:75}
      and .ceiling == {
        additional_execution_or_rerun_authorized:false,
        arbitrary_token_determinism_established:false,
        artifact_upload_authorized:false,
        b_specific_native300_resource_witness_authorized:false,
        b_specific_native300_resource_witness_established:false,
        b_specific_native300_resource_witness_requires_separate_authority:true,
        candidate_admission_granted:false,
        cross_device_determinism_established:false,
        default_gather_determinism_established:false,
        durable_checkpoint_io_authorized:false,
        exact_same_device_b_path_gradient_bytes_established:
          (.status == "PASS_CLEARANCE"),
        model_quality_established:false,
        one_shot_consumed:true,
        repeated_same_device_b_path_determinism_established:
          (.status == "PASS_CLEARANCE"),
        retained_artifact_authorized:false,
        stage5_assay_clearance_established:(.status == "PASS_CLEARANCE"),
        stage5_mechanics_success_established:true,
        stage5_result_established:true,
        stage6_historical_resource_clearance_applies_to_b_path:false,
        stage6_resource_clearance_remains_historical:true,
        stage7_authority_established:false,
        stage7_authorized:false,
        stage7_requires_new_b_specific_native300_resource_witness:true,
        stage7_requires_separate_authority_after_witness:true}
    ' >/dev/null ||
    fail "replacement receipt is invalid or not exact-execution-bound"

readonly replacement_status="$(printf '%s' "$receipt_json" | jq -r .status)"
[[ "$replacement_status" == "PASS_CLEARANCE" \
    || "$replacement_status" == "MEASURED_EXACT_MISMATCH" ]] ||
    fail "replacement terminal status is not green"

[[ -d "$lease_root" && ! -L "$lease_root" \
    && "$(cd "$lease_root" && pwd -P)" == "$lease_root" \
    && "$(stat -f %u "$lease_root")" == "$effective_uid" \
    && "$(stat -f %Lp "$lease_root")" == "700" \
    && "$(stat -f %l "$lease_root")" == "2" ]] ||
    fail "replacement lease parent identity changed"
[[ -f "$lease_path" && ! -L "$lease_path" \
    && "$(stat -f %u "$lease_path")" == "$effective_uid" \
    && "$(stat -f %Lp "$lease_path")" == "600" \
    && "$(stat -f %l "$lease_path")" == "1" \
    && "$(stat -f %z "$lease_path")" == "0" ]] ||
    fail "replacement test did not leave the exact secure lease file"
[[ "$(find "$lease_root" -mindepth 1 -maxdepth 1 -print)" == "$lease_path" ]] ||
    fail "replacement lease parent contains an unexpected entry"
rm -- "$lease_path"
rmdir -- "$lease_root"
[[ ! -e "$lease_path" && ! -L "$lease_path" \
    && ! -e "$lease_root" && ! -L "$lease_root" ]] ||
    fail "replacement lease file or parent survived exact cleanup"

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && "$(git -C "$prime_root" rev-parse 'HEAD^{tree}')" == "$exact_tree" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime repository changed during Stage-5 replacement"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private replacement working directory changed"
for staged_metallib in "$cli_metallib" "$test_resource_metallib"; do
    [[ "$(stat -f %Lp "$staged_metallib")" == "444" \
        && "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
        && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" \
            == "$metallib_sha256" ]] ||
        fail "staged metallib changed during replacement execution"
    cmp -s "$metallib" "$staged_metallib" ||
        fail "staged metallib bytes changed during replacement execution"
done

echo "OK: exact-main Stage-5 replacement completed once with $replacement_status; Stage 7 remains unauthorized"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo "The sole Stage-5 replacement assay completed with $replacement_status after retained root 58, isolated 6, Metal 44, maintained runtime 1, and tokenizer 1 predecessors."
        echo 'Candidate A was diagnostic only. Candidate B completed three trials and nine branches with 66 dense token-bound barriers plus nine four-array forward-comparison barriers, for replacement synchronization count 75.'
        echo 'The one-shot is consumed. No artifact, retry, rerun, Stage-6 applicability to B, B-specific Native-300M witness, Stage-7 authority, candidate admission, quality, trial, canary, quantization, product, or publication is authorized.'
    } >> "$GITHUB_STEP_SUMMARY"
fi
