#!/usr/bin/env bash
# One-shot exact-main Stage-5 witness for the authorized tiny repeated-Metal
# trajectory-determinism assay. The sole direct XCTest owns the complete
# PrimeMetalDeviceLease lifetime, executes three same-process trials with
# three branches each, emits and flushes the sole canonical receipt while the
# lease remains held, then explicitly releases it. This launcher captures and
# validates that receipt without re-emitting its prefix. It retains or uploads
# no artifact and grants no retry, cross-device, Stage-6, or downstream scope.
#
# The five run-103 closure bindings below are terminally sealed to the unique
# successful exact-main authority-repair closure. Their guards make this script
# fail closed.
set -euo pipefail
IFS=$'\n\t'
umask 077

fail() {
    echo "prime-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism: $*" >&2
    exit 2
}

readonly prime_root="$(cd "$(dirname "$0")/../.." && pwd -P)"
readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly exact_revision="${EXACT_REVISION:?EXACT_REVISION is required}"
readonly mlx_revision="${PRIME_MLX_REVISION:?PRIME_MLX_REVISION is required}"

# Exact-main Stage-5 Swift-Numerics authority-repair merge and tree. The later
# mechanics merge must be its direct two-parent successor.
readonly expected_base_revision="522e4620596eed909822b80b782d74d282f429c5"
readonly expected_base_tree="d0304aadcf533a341d89df262f8cbe74c1c13b90"
readonly base_revision="522e4620596eed909822b80b782d74d282f429c5"
readonly base_tree="d0304aadcf533a341d89df262f8cbe74c1c13b90"
readonly authority_repair_closure_workflow_run_id="31750678556"
readonly authority_repair_closure_workflow_run_number="103"
readonly authority_repair_closure_check_suite_id="86139786214"

readonly required_mlx_revision="d37885a278f1c37484a94d0f401a418735e66519"
readonly numerics_revision="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly authority_canonical_sha256="00c49e63315b2aacb439204e778f54bcf63c2fdf643282f3bd64e2b3b4094089"
readonly repair_authority_canonical_sha256="a5a8e5300ea8413e738fddd4b8fed930dcc9983d5a29eea102862f9744b50fff"
readonly authority_id="prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_authority_v1"
readonly repair_authority_id="prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_exact_main_swift_numerics_resolution_repair_authority_v1"
readonly receipt_prefix="PRIME_NATIVE_DECODER_STAGE5_TINY_REPEATED_METAL_TRAJECTORY_DETERMINISM_RECEIPT="

readonly validation_root="$prime_root/Tests/PrimeNativeDecoderTrainingValidation"
readonly validation_manifest="$validation_root/Package.swift"
readonly validation_lock="$validation_root/Package.resolved"
readonly retained_stage2_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift"
readonly retained_stage3_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift"
readonly retained_stage4_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionTests.swift"
readonly stage5_test="$validation_root/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift"
readonly training_source="$prime_root/Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"
readonly authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthority.swift"
readonly authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityTests.swift"
readonly repair_authority_source="$prime_root/Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthority.swift"
readonly repair_authority_test="$prime_root/Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityTests.swift"
readonly stage4_launcher="$prime_root/.github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh"
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

readonly scratch_path="$runner_temp/prime-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism-build"
readonly cache_path="$runner_temp/prime-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism-cache"
readonly config_path="$runner_temp/prime-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism-config"
readonly security_path="$runner_temp/prime-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism-security"
readonly private_cwd="$runner_temp/prime-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism-cwd"
readonly lease_root="$runner_temp/prime-native-decoder-stage5-metal-lease"
readonly lease_path="$lease_root/device-0.lock"
readonly test_log="$runner_temp/prime-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism-tests.log"
readonly test_class="PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests"
readonly test_method="testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes"
readonly test_filter="${test_class}/${test_method}"

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
    && "$base_revision" == "$expected_base_revision" \
    && "$base_tree" == "$expected_base_tree" \
    && "$authority_repair_closure_workflow_run_id" =~ ^[1-9][0-9]*$ \
    && "$authority_repair_closure_workflow_run_number" =~ ^[1-9][0-9]*$ \
    && "$authority_repair_closure_workflow_run_number" == "103" \
    && "$authority_repair_closure_check_suite_id" =~ ^[1-9][0-9]*$ ]] ||
    fail "run-103 Stage-5 authority-repair closure placeholders are not terminally pinned"
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
    fail "dependency credential reached Stage-5"

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
[[ "$raw_tree_count" == "1" \
    && "$raw_parent_count" == "2" \
    && "$raw_tree" == "$exact_tree" \
    && "$first_parent" == "$base_revision" \
    && "$second_parent" =~ ^[0-9a-f]{40}$ \
    && "$second_parent" != "$first_parent" \
    && "$second_parent" != "$exact_revision" ]] ||
    fail "raw exact-head commit topology is not the direct two-parent successor"
readonly shallow_path="$prime_root/.git/shallow"
[[ "$(git -C "$prime_root" rev-parse --is-shallow-repository)" == "true" \
    && -f "$shallow_path" && ! -L "$shallow_path" \
    && "$(stat -f %l "$shallow_path")" == "1" \
    && "$(wc -l < "$shallow_path" | awk '{print $1}')" == "1" \
    && "$(grep -Fxc -- "$exact_revision" "$shallow_path")" == "1" ]] ||
    fail "reviewed mechanics checkout is not preserved at exact depth one"

readonly exact_stage5_paths=(
    '.github/scripts/prime-ci-active-root-quarantine.sh'
    '.github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh'
    '.github/workflows/prime-active-root-quarantine.yml'
    'Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift'
    'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift'
    'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift'
)
readonly expected_stage5_preserved_index_sha256="1d1b11d0d5f3cde042d887693dd1222de4ecd7a027654cab734d80247db5e33c"
readonly observed_stage5_preserved_index_sha256="$({
    git -C "$prime_root" ls-files -s |
        while IFS= read -r index_record; do
            relative_path="${index_record#*$'\t'}"
            skip_record=false
            for exact_stage5_path in "${exact_stage5_paths[@]}"; do
                if [[ "$relative_path" == "$exact_stage5_path" ]]; then
                    skip_record=true
                    break
                fi
            done
            [[ "$skip_record" == true ]] || printf '%s\n' "$index_record"
        done
} | LC_ALL=C sort | shasum -a 256 | awk '{print $1}')"
[[ "$observed_stage5_preserved_index_sha256" \
    == "$expected_stage5_preserved_index_sha256" ]] ||
    fail "Stage-5 mechanics changed a path outside the exact six-path closure"
for exact_stage5_path in "${exact_stage5_paths[@]}"; do
    expected_stage5_mode="100644"
    case "$exact_stage5_path" in
        '.github/scripts/prime-ci-active-root-quarantine.sh'|'.github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh')
            expected_stage5_mode="100755"
            ;;
    esac
    [[ "$(git -C "$prime_root" ls-files -s -- "$exact_stage5_path" | \
        awk '{print $1}')" == "$expected_stage5_mode" ]] ||
        fail "Stage-5 mechanics exact path is missing or has the wrong mode: $exact_stage5_path"
done
readonly changed_paths_json="$(printf '%s\n' "${exact_stage5_paths[@]}" | \
    LC_ALL=C sort | jq -Rsc 'split("\n")[:-1]')"

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

assert_pinned_file 'Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthority.swift' \
    '100644' '71c69d89384c5c0878f43da309353093d159d43c' '64741' \
    '367fc5c2759382f5980ceb59d25da27f945bfbff186f61b055bccca4411758ab'
assert_pinned_file 'Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityTests.swift' \
    '100644' '42a2c60b7179f3f8c687b6c697513433a92eac30' '25386' \
    '05f9a766860ea5c35b590b1d813a81eea0b42d1b0d941ee2b054509f0a3e7cdc'
grep -Fq "$authority_canonical_sha256" "$authority_source" ||
    fail "Stage-5 authority canonical digest changed"
assert_pinned_file 'Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthority.swift' \
    '100644' 'b66fabdd18edfa347a62982bc392a7a94b048da5' '44834' \
    '81d576c4f43af56ba3b626339742a135a0c12c2ccfb7b23abf32a125daec9d39'
assert_pinned_file 'Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityTests.swift' \
    '100644' 'f516e1115ccea7973a541f5350437e599bbdadc2' '23310' \
    'ac2bc1cb90ff9c1ea8a75478e90983f1b1f55bee0132c1031692cacb093cbb6f'
grep -Fq "$repair_authority_canonical_sha256" "$repair_authority_source" ||
    fail "Stage-5 Swift-Numerics repair authority canonical digest changed"
assert_pinned_file '.github/scripts/prime-ci-native-decoder-stage4-tiny-durable-multileaf.sh' \
    '100755' '4184e23941460fe397e284e094d782f1265d19d9' '31829' \
    'e3eb8a66340c924bbb579023eee04eaee1242a8a682f17ae668898ee8d36c6a2'
assert_pinned_file 'Package.swift' \
    '100644' '8e14c10aded588b3902a042341bca7acc842bcc6' '32843' \
    'fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81'
assert_pinned_file 'Package.resolved' \
    '100644' '14d804bb4291720477240c27e24de6fbdc876b3b' '645' \
    'bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Package.swift' \
    '100644' '9f05e5a17426f00adf9dad7b55d84057122e98f9' '1054' \
    '0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Package.resolved' \
    '100644' '8bf05edf1ea8789e7683e72fe756d79aaaa61320' '645' \
    'a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225'

assert_pinned_file 'Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift' \
    '100644' '271b7fe4a856a76a00730954c23bdca3b33e761d' '86387' \
    'f49b946e5272992f09ecf7b1dd8439bda15c5ac696a4f6298bafa19994f2b4c2'
assert_pinned_file 'Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift' \
    '100644' '46f91f32e91870d21c46cd318972a857b8ef6e12' '28292' \
    '50b19a0bfe8752d2b80c09527b70731d906e8064c8e2d49a758c8c48b48f4398'

for mechanics_path in "$training_source" "$stage5_test"; do
    [[ -f "$mechanics_path" && ! -L "$mechanics_path" \
        && "$(stat -f %l "$mechanics_path")" == "1" ]] ||
        fail "Stage-5 mechanics path is missing or aliased: $mechanics_path"
done
[[ "$(find "$validation_root" -type f ! -path '*/.*' -print | LC_ALL=C sort)" \
    == "$validation_lock"$'\n'"$validation_manifest"$'\n'"$retained_stage3_test"$'\n'"$retained_stage4_test"$'\n'"$stage5_test"$'\n'"$retained_stage2_test" ]] ||
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
grep -Fq 'Executed 53 tests, with 0 failures' "$active_root_log" ||
    fail "root-53 contracts did not complete"
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
for predecessor_log in "${predecessor_test_logs[@]}" "${predecessor_receipt_logs[@]}"; do
    [[ "$(awk -v needle="$receipt_prefix" '
        { line = $0; while ((position = index(line, needle)) > 0) {
            count += 1; line = substr(line, position + length(needle))
        }} END { print count + 0 }
    ' "$predecessor_log")" == "0" ]] ||
        fail "Stage-5 receipt prefix existed in a predecessor log"
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
[[ "$metallib_count" -eq 1 ]] || fail "fresh metallib candidate count is not one"
assert_regular_file "$metallib"
readonly metallib_byte_count="$(stat -f %z "$metallib")"
readonly metallib_sha256="$(shasum -a 256 "$metallib" | awk '{print $1}')"
[[ "$metallib_byte_count" =~ ^[1-9][0-9]*$ \
    && "$metallib_sha256" =~ ^[0-9a-f]{64}$ ]] ||
    fail "fresh metallib identity is invalid"

for fresh_path in "$scratch_path" "$cache_path" "$config_path" \
    "$security_path" "$private_cwd" "$lease_root" "$lease_path" "$test_log"; do
    [[ ! -e "$fresh_path" && ! -L "$fresh_path" ]] ||
        fail "Stage-5 path must be initially absent: $fresh_path"
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
    fail "Stage-5 lease parent is not an empty physical owner-only directory"
[[ -d "$private_cwd" && ! -L "$private_cwd" \
    && "$(cd "$private_cwd" && pwd -P)" == "$private_cwd" \
    && "$(stat -f %u "$private_cwd")" == "$effective_uid" \
    && "$(stat -f %Lp "$private_cwd")" == "700" \
    && -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "Stage-5 private working directory is invalid"

readonly root_numerics_checkout="$runner_temp/prime-active-root-build/checkouts/swift-numerics"
readonly root_numerics_cache="$runner_temp/prime-active-root-build/repositories/swift-numerics-d936ec6c"
[[ -d "$root_numerics_checkout" && ! -L "$root_numerics_checkout" \
    && "$(cd "$root_numerics_checkout" && pwd -P)" == "$root_numerics_checkout" \
    && "$(git -C "$root_numerics_checkout" rev-parse --show-toplevel)" \
        == "$root_numerics_checkout" \
    && "$(git -C "$root_numerics_checkout" rev-parse --absolute-git-dir)" \
        == "$root_numerics_checkout/.git" \
    && "$(git -C "$root_numerics_checkout" rev-parse --is-bare-repository)" \
        == "false" \
    && "$(git -C "$root_numerics_checkout" rev-parse HEAD)" == "$numerics_revision" \
    && "$(git -C "$root_numerics_checkout" remote)" == "origin" \
    && "$(git -C "$root_numerics_checkout" config --get-all remote.origin.url | \
        wc -l | tr -d '[:space:]')" == "1" \
    && "$(git -C "$root_numerics_checkout" config --get-all remote.origin.url)" \
        == "$root_numerics_cache" \
    && -z "$(git -C "$root_numerics_checkout" status \
        --porcelain=v1 --untracked-files=all)" ]] ||
    fail "root Swift Numerics checkout changed"
[[ -d "$root_numerics_cache" && ! -L "$root_numerics_cache" \
    && "$(cd "$root_numerics_cache" && pwd -P)" == "$root_numerics_cache" \
    && "$(git -C "$root_numerics_cache" rev-parse --absolute-git-dir)" \
        == "$root_numerics_cache" \
    && "$(git -C "$root_numerics_cache" rev-parse --is-bare-repository)" \
        == "true" \
    && "$(git -C "$root_numerics_cache" remote)" == "origin" \
    && "$(git -C "$root_numerics_cache" config --get-all remote.origin.url | \
        wc -l | tr -d '[:space:]')" == "1" \
    && "$(git -C "$root_numerics_cache" config --get-all remote.origin.url)" \
        == "https://github.com/apple/swift-numerics" \
    && "$(git -C "$root_numerics_cache" cat-file -t "$numerics_revision")" \
        == "commit" \
    && "$(git -C "$root_numerics_cache" rev-parse \
        "$numerics_revision^{commit}")" == "$numerics_revision" \
    && "$(git -C "$root_numerics_cache" rev-parse \
        'refs/tags/1.1.1^{commit}')" == "$numerics_revision" ]] ||
    fail "root Swift Numerics cache topology changed"
export GIT_CONFIG_COUNT=3
export GIT_CONFIG_KEY_0="url.file://${mlx_bare}/.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/Ergentics/ergentics-mlx-swift"
export GIT_CONFIG_KEY_1="url.file://${root_numerics_cache}/.insteadOf"
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
    fail "Stage-5 XCTest executable is missing"
for framework in CoreGraphics Metal; do
    otool -L "$test_executable" | grep -Fq "/${framework}.framework/" ||
        fail "Stage-5 XCTest executable does not link ${framework}"
done
[[ -z "$(find "$bin_path" \( -name default.metallib -o -name mlx.metallib \) -print)" ]] ||
    fail "Stage-5 build already contains a metallib candidate"
mkdir -p "$(dirname "$cli_metallib")" "$(dirname "$test_resource_metallib")"
cp -X "$metallib" "$cli_metallib"
cp -X "$metallib" "$test_resource_metallib"
chmod 444 "$cli_metallib" "$test_resource_metallib"
for staged_metallib in "$cli_metallib" "$test_resource_metallib"; do
    assert_regular_file "$staged_metallib"
    [[ "$(stat -f %Lp "$staged_metallib")" == "444" \
        && "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
        && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" == "$metallib_sha256" ]] ||
        fail "Stage-5 staged metallib identity changed"
    cmp -s "$metallib" "$staged_metallib" ||
        fail "Stage-5 staged metallib bytes changed"
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
        PRIME_NATIVE_DECODER_STAGE5_METAL_LEASE_PATH="$lease_path" \
        PRIME_NATIVE_DECODER_STAGE5_EXECUTED_REVISION="$exact_revision" \
        PRIME_NATIVE_DECODER_STAGE5_EXECUTED_TREE="$exact_tree" \
        PRIME_NATIVE_DECODER_STAGE5_FIRST_PARENT="$first_parent" \
        PRIME_NATIVE_DECODER_STAGE5_SECOND_PARENT="$second_parent" \
        PRIME_NATIVE_DECODER_STAGE5_CHANGED_PATHS_JSON="$changed_paths_json" \
        PRIME_NATIVE_DECODER_STAGE5_EMBEDDED_SOURCE_IDENTITY_SHA256="$embedded_source_identity" \
        PRIME_NATIVE_DECODER_STAGE5_AUTHORITY_REPAIR_CLOSURE_WORKFLOW_RUN_ID="$authority_repair_closure_workflow_run_id" \
        PRIME_NATIVE_DECODER_STAGE5_AUTHORITY_REPAIR_CLOSURE_WORKFLOW_RUN_NUMBER="$authority_repair_closure_workflow_run_number" \
        PRIME_NATIVE_DECODER_STAGE5_AUTHORITY_REPAIR_CLOSURE_CHECK_SUITE_ID="$authority_repair_closure_check_suite_id" \
        PRIME_NATIVE_DECODER_STAGE5_EXACT_MLX_REVISION="$mlx_revision" \
        PRIME_NATIVE_DECODER_STAGE5_METALLIB_PATH="$test_resource_metallib" \
        PRIME_NATIVE_DECODER_STAGE5_METALLIB_BYTES="$metallib_byte_count" \
        PRIME_NATIVE_DECODER_STAGE5_METALLIB_SHA256="$metallib_sha256" \
        PRIME_NATIVE_DECODER_STAGE5_OPERATING_SYSTEM_BUILD="$operating_system_build" \
        PRIME_NATIVE_DECODER_STAGE5_KERNEL_IDENTITY="$kernel_identity" \
        PRIME_NATIVE_DECODER_STAGE5_SWIFT_TOOLCHAIN="$swift_toolchain" \
        PRIME_NATIVE_DECODER_STAGE5_XCODE_TOOLCHAIN="$xcode_toolchain" \
        PRIME_NATIVE_DECODER_STAGE5_MACOS_SDK="$macos_sdk" \
        PRIME_NATIVE_DECODER_STAGE5_BUILD_CONFIGURATION="debug" \
        PRIME_NATIVE_DECODER_STAGE5_MLX_GRAPH_COMPILE_MODE="eager_uncompiled_no_compile_transform" \
        xcrun xctest -XCTest "$test_filter" "$test_bundle"
) 2>&1 | tee "$test_log"
test_pipe_status=("${PIPESTATUS[@]}")
set -e
[[ "${#test_pipe_status[@]}" -eq 2 \
    && "${test_pipe_status[0]}" -eq 0 \
    && "${test_pipe_status[1]}" -eq 0 ]] ||
    fail "Stage-5 direct XCTest or log capture failed"
assert_regular_file "$test_log"
[[ "$(grep -Ec '^Test Case .* started\.$' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* passed \(' "$test_log")" == "1" \
    && "$(grep -Ec '^Test Case .* failed \(' "$test_log")" == "0" \
    && "$(grep -Eic '^Test Case .* skipped \(' "$test_log")" == "0" ]] ||
    fail "Stage-5 test counts are not 1/1/0/0"
grep -Fq "$test_method" "$test_log" || fail "exact Stage-5 method did not execute"
grep -Eq 'Executed 1 test, with 0 failures' "$test_log" ||
    fail "Stage-5 test summary changed"
! xctest_log_has_failure_or_skip "$test_log" ||
    fail "Stage-5 test reported a failure or skip"

readonly anchored_receipt_count="$(grep -Ec "^${receipt_prefix}" "$test_log")"
readonly total_receipt_occurrence_count="$(awk -v needle="$receipt_prefix" '
    { line = $0; while ((position = index(line, needle)) > 0) {
        count += 1; line = substr(line, position + length(needle))
    }} END { print count + 0 }
' "$test_log")"
[[ "$anchored_receipt_count" == "1" \
    && "$total_receipt_occurrence_count" == "1" ]] ||
    fail "Stage-5 direct XCTest did not emit exactly one anchored receipt"
readonly receipt_json="$(awk -v prefix="$receipt_prefix" '
    index($0, prefix) == 1 { print substr($0, length(prefix) + 1) }
' "$test_log")"
[[ -n "$receipt_json" \
    && "$(printf '%s' "$receipt_json" | jq -cS .)" == "$receipt_json" ]] ||
    fail "Stage-5 receipt is not one canonical JSON object"

printf '%s' "$receipt_json" | jq -e \
    --arg authority_id "$authority_id" \
    --arg authority_sha "$authority_canonical_sha256" \
    --arg repair_authority_id "$repair_authority_id" \
    --arg repair_authority_sha "$repair_authority_canonical_sha256" \
    --arg revision "$exact_revision" --arg tree "$exact_tree" \
    --arg first_parent "$first_parent" --arg second_parent "$second_parent" \
    --argjson changed_paths "$changed_paths_json" \
    --arg embedded_identity "$embedded_source_identity" \
    --argjson closure_run_id "$authority_repair_closure_workflow_run_id" \
    --argjson closure_run_number "$authority_repair_closure_workflow_run_number" \
    --argjson closure_suite_id "$authority_repair_closure_check_suite_id" \
    --arg mlx_revision "$mlx_revision" \
    --arg metallib_path "$test_resource_metallib" \
    --argjson metallib_bytes "$metallib_byte_count" \
    --arg metallib_sha "$metallib_sha256" \
    --arg lease_root "$lease_root" --arg lease_path "$lease_path" \
    --arg os_build "$operating_system_build" \
    --arg kernel "$kernel_identity" --arg swift "$swift_toolchain" \
    --arg xcode "$xcode_toolchain" --arg sdk "$macos_sdk" \
    --arg test_class "$test_class" --arg test_method "$test_method" \
    --arg test_filter "$test_filter" '
      type == "object"
      and (keys == (["assay","authority","ceiling","environment","equality",
        "execution","lease","metallib","predecessor","receipt_id",
        "repair_closure","schema_version","status"] | sort))
      and ((.authority | keys) == (["authority_canonical_sha256",
        "authority_id","repair_authority_canonical_sha256",
        "repair_authority_id"] | sort))
      and ((.execution | keys) == (["changed_paths",
        "embedded_source_identity_sha256","first_parent_revision",
        "github_event_name","github_run_attempt","parent_count","ref",
        "repository","revision","second_parent_revision","tree"] | sort))
      and ((.repair_closure | keys) == (["artifact_count","check_suite_id",
        "rerun_count","run_attempt","secure_fetch",
        "stage5_launcher_invocation_count","stage5_receipt_count",
        "terminal_conclusion","workflow_run_id","workflow_run_number"] | sort))
      and ((.repair_closure.secure_fetch | keys) == ([
        "authenticated_depth_one_fetch_count","completion_count",
        "custom_ca_installation_count","git_internal_retry_scheduled_count",
        "invocation_count","mlx_c_clone_count","mlx_clone_count",
        "step_conclusion","submodule_update_invocation_count",
        "tls_failure_count","tls_verification_bypass_count",
        "workflow_authored_retry_count"] | sort))
      and ((.predecessor | keys) == (["focused_isolated_test_count",
        "focused_root_test_count","focused_whole_test_count","live_order",
        "maintained_runtime_receipt_count","maintained_runtime_test_count",
        "metal_test_count","pre_stage5_total_test_count",
        "stage5_direct_xctest_count","tokenizer_receipt_count",
        "tokenizer_test_count","total_test_count"] | sort))
      and ((.environment | keys) == (["checked_evaluation_before_every_byte_read",
        "exact_metal_device_count","explicit_default_gpu_stream",
        "explicit_synchronize_before_every_byte_read",
        "exact_mlx_revision",
        "implicit_or_global_mlx_rng_used","index_zero_matches_default_device",
        "kernel_identity","macos_sdk","metal_device_index",
        "metal_device_name","metal_device_registry_id",
        "mlx_compile_transform_invocation_count","mlx_enable_tf32",
        "mlx_graph_compile_mode","operating_system_build",
        "postflight_device_identity_reverified",
        "same_metal_device_across_every_trial_and_branch",
        "swift_toolchain","swiftpm_build_configuration",
        "xcode_toolchain"] | sort))
      and ((.metallib | keys) == (["artifact_provenance_established",
        "byte_count","path","retained_after_job","sha256","source_candidate_count",
        "staged_copy_count","staged_permission_mode"] | sort))
      and ((.assay | keys) == (["all_trials_in_one_process","build_count",
        "direct_xctest_count","every_trial_uses_fresh_objects_and_arrays",
        "exact_branches_per_trial","independent_trial_count",
        "source_snapshot_branch_continues_to_terminal",
        "source_snapshot_exists_only_in_memory","test_class","test_filter",
        "test_method","total_trajectory_branch_execution_count"] | sort))
      and ((.equality | keys) == (["canonical_parameter_shape_dtype_and_little_endian_order",
        "exact_adam_first_moment_bytes","exact_adam_second_moment_bytes",
        "exact_clipped_gradient_bytes",
        "exact_loss_norm_clip_and_evaluation_float32_bit_patterns",
        "exact_model_parameter_bytes","exact_next_unconsumed_cursor_bytes",
        "exact_raw_gradient_bytes",
        "exact_rng_domain_key_counter_and_consumption_bytes",
        "exact_terminal_control_state_bytes","source_step_branches",
        "successor_and_terminal_branches",
        "unordered_or_tolerance_comparison_used"] | sort))
      and ((.lease | keys) == (["acquired_before_coregraphics_metal_or_mlx_access",
        "environment_key","explicit_release_immediately_after_receipt",
        "file_is_physical_regular_nonlink","file_link_count",
        "file_owner_is_effective_user","file_permission_mode",
        "held_across_all_three_trials_and_nine_branches",
        "held_through_postflight_identity_validation",
        "no_fallible_operation_after_receipt","parent_path","path",
        "parent_permission_mode","receipt_emitted_while_held",
        "receipt_flushed_while_held"] | sort))
      and ((.ceiling | keys) == (["additional_execution_or_rerun_authorized",
        "artifact_upload_authorized","canary_authorized",
        "candidate_admission_granted","checkpoint_admission_granted",
        "cross_device_claim_authorized","downstream_trial_authorized",
        "durable_checkpoint_io_authorized","general_training_authorized",
        "general_training_resume_established",
        "model_quality_established","native300m_allocation_authorized",
        "native300m_training_authorized","product_use_authorized",
        "publication_authorized","retained_artifact_authorized",
        "stage4_rerun_authorized",
        "stage6_authorized"] | sort))
      and .schema_version == 1
      and .receipt_id == "prime_native_decoder_stage5_tiny_repeated_metal_trajectory_determinism_receipt_v1"
      and .status == "PASS_exact_main_tiny_same_device_three_trial_nine_branch_exact_metal_trajectory_determinism_one_test_zero_failure_zero_skip"
      and .authority == {authority_id:$authority_id,
        authority_canonical_sha256:$authority_sha,
        repair_authority_id:$repair_authority_id,
        repair_authority_canonical_sha256:$repair_authority_sha}
      and .execution.repository == "Ergentics/ergentics-prime"
      and .execution.ref == "refs/heads/main"
      and .execution.revision == $revision
      and .execution.tree == $tree
      and .execution.first_parent_revision == $first_parent
      and .execution.second_parent_revision == $second_parent
      and .execution.parent_count == 2
      and .execution.changed_paths == $changed_paths
      and .execution.github_event_name == "push"
      and .execution.github_run_attempt == 1
      and .execution.embedded_source_identity_sha256 == $embedded_identity
      and .repair_closure.workflow_run_id == $closure_run_id
      and .repair_closure.workflow_run_number == $closure_run_number
      and .repair_closure.check_suite_id == $closure_suite_id
      and .repair_closure.run_attempt == 1
      and .repair_closure.terminal_conclusion == "success"
      and .repair_closure.stage5_launcher_invocation_count == 0
      and .repair_closure.stage5_receipt_count == 0
      and .repair_closure.artifact_count == 0
      and .repair_closure.rerun_count == 0
      and .repair_closure.secure_fetch == {
        step_conclusion:"success",invocation_count:1,completion_count:1,
        authenticated_depth_one_fetch_count:1,submodule_update_invocation_count:1,
        mlx_clone_count:1,mlx_c_clone_count:1,workflow_authored_retry_count:0,
        git_internal_retry_scheduled_count:0,tls_failure_count:0,
        tls_verification_bypass_count:0,custom_ca_installation_count:0}
      and .predecessor == {focused_root_test_count:53,
        focused_isolated_test_count:6,focused_whole_test_count:59,
        metal_test_count:44,maintained_runtime_test_count:1,
        maintained_runtime_receipt_count:1,tokenizer_test_count:1,
        tokenizer_receipt_count:1,pre_stage5_total_test_count:105,
        stage5_direct_xctest_count:1,total_test_count:106,
        live_order:["root","metal","maintained_runtime","tokenizer","stage5"]}
      and .environment.mlx_enable_tf32 == "0"
      and .environment.exact_mlx_revision == $mlx_revision
      and .environment.swiftpm_build_configuration == "debug"
      and .environment.mlx_graph_compile_mode == "eager_uncompiled_no_compile_transform"
      and .environment.mlx_compile_transform_invocation_count == 0
      and .environment.operating_system_build == $os_build
      and .environment.kernel_identity == $kernel
      and .environment.swift_toolchain == $swift
      and .environment.xcode_toolchain == $xcode
      and .environment.macos_sdk == $sdk
      and .environment.metal_device_index == 0
      and .environment.exact_metal_device_count == 1
      and (.environment.metal_device_name | type == "string" and length > 0)
      and (.environment.metal_device_registry_id | type == "number" and . >= 0)
      and .environment.same_metal_device_across_every_trial_and_branch == true
      and .environment.index_zero_matches_default_device == true
      and .environment.postflight_device_identity_reverified == true
      and .environment.explicit_default_gpu_stream == true
      and .environment.checked_evaluation_before_every_byte_read == true
      and .environment.explicit_synchronize_before_every_byte_read == true
      and .environment.implicit_or_global_mlx_rng_used == false
      and .metallib == {path:$metallib_path,byte_count:$metallib_bytes,sha256:$metallib_sha,
        source_candidate_count:1,staged_copy_count:2,
        staged_permission_mode:"444",retained_after_job:false,
        artifact_provenance_established:false}
      and .assay.test_class == $test_class
      and .assay.test_method == $test_method
      and .assay.test_filter == $test_filter
      and .assay.build_count == 1
      and .assay.direct_xctest_count == 1
      and .assay.independent_trial_count == 3
      and .assay.exact_branches_per_trial == ["uninterrupted","source_snapshot","fresh_restored_from_source_snapshot"]
      and .assay.total_trajectory_branch_execution_count == 9
      and .assay.all_trials_in_one_process == true
      and .assay.every_trial_uses_fresh_objects_and_arrays == true
      and .assay.source_snapshot_exists_only_in_memory == true
      and .assay.source_snapshot_branch_continues_to_terminal == true
      and .equality.source_step_branches == ["uninterrupted","source_snapshot"]
      and .equality.successor_and_terminal_branches == ["uninterrupted","source_snapshot","fresh_restored_from_source_snapshot"]
      and .equality.exact_raw_gradient_bytes == true
      and .equality.exact_clipped_gradient_bytes == true
      and .equality.exact_model_parameter_bytes == true
      and .equality.exact_adam_first_moment_bytes == true
      and .equality.exact_adam_second_moment_bytes == true
      and .equality.exact_terminal_control_state_bytes == true
      and .equality.exact_rng_domain_key_counter_and_consumption_bytes == true
      and .equality.exact_next_unconsumed_cursor_bytes == true
      and .equality.exact_loss_norm_clip_and_evaluation_float32_bit_patterns == true
      and .equality.canonical_parameter_shape_dtype_and_little_endian_order == true
      and .equality.unordered_or_tolerance_comparison_used == false
      and .lease.environment_key == "PRIME_NATIVE_DECODER_STAGE5_METAL_LEASE_PATH"
      and .lease.parent_path == $lease_root
      and .lease.path == $lease_path
      and .lease.parent_permission_mode == "700"
      and .lease.file_permission_mode == "600"
      and .lease.file_owner_is_effective_user == true
      and .lease.file_is_physical_regular_nonlink == true
      and .lease.file_link_count == 1
      and .lease.acquired_before_coregraphics_metal_or_mlx_access == true
      and .lease.held_across_all_three_trials_and_nine_branches == true
      and .lease.held_through_postflight_identity_validation == true
      and .lease.receipt_emitted_while_held == true
      and .lease.receipt_flushed_while_held == true
      and .lease.explicit_release_immediately_after_receipt == true
      and .lease.no_fallible_operation_after_receipt == true
      and .ceiling.additional_execution_or_rerun_authorized == false
      and .ceiling.durable_checkpoint_io_authorized == false
      and .ceiling.retained_artifact_authorized == false
      and .ceiling.artifact_upload_authorized == false
      and .ceiling.cross_device_claim_authorized == false
      and .ceiling.stage6_authorized == false
      and .ceiling.native300m_allocation_authorized == false
      and .ceiling.native300m_training_authorized == false
      and .ceiling.general_training_authorized == false
      and .ceiling.general_training_resume_established == false
      and .ceiling.model_quality_established == false
      and .ceiling.checkpoint_admission_granted == false
      and .ceiling.candidate_admission_granted == false
      and .ceiling.downstream_trial_authorized == false
      and .ceiling.canary_authorized == false
      and .ceiling.product_use_authorized == false
      and .ceiling.publication_authorized == false
      and .ceiling.stage4_rerun_authorized == false
    ' >/dev/null ||
    fail "Stage-5 receipt is invalid or not exact-execution-bound"

[[ -d "$lease_root" && ! -L "$lease_root" \
    && "$(cd "$lease_root" && pwd -P)" == "$lease_root" \
    && "$(stat -f %u "$lease_root")" == "$effective_uid" \
    && "$(stat -f %Lp "$lease_root")" == "700" \
    && "$(stat -f %l "$lease_root")" == "2" ]] ||
    fail "Stage-5 lease parent identity changed"
[[ -f "$lease_path" && ! -L "$lease_path" \
    && "$(stat -f %u "$lease_path")" == "$effective_uid" \
    && "$(stat -f %Lp "$lease_path")" == "600" \
    && "$(stat -f %l "$lease_path")" == "1" \
    && "$(stat -f %z "$lease_path")" == "0" ]] ||
    fail "Stage-5 test did not leave the exact secure Metal lease file"
[[ "$(find "$lease_root" -mindepth 1 -maxdepth 1 -print)" == "$lease_path" ]] ||
    fail "Stage-5 lease parent contains an unexpected entry"
rm -- "$lease_path"
rmdir -- "$lease_root"
[[ ! -e "$lease_path" && ! -L "$lease_path" \
    && ! -e "$lease_root" && ! -L "$lease_root" ]] ||
    fail "Stage-5 lease file or parent survived exact cleanup"

[[ "$(git -C "$prime_root" rev-parse HEAD)" == "$exact_revision" \
    && "$(git -C "$prime_root" rev-parse 'HEAD^{tree}')" == "$exact_tree" \
    && -z "$(git -C "$prime_root" status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "Prime repository changed during Stage-5"
[[ -z "$(find "$private_cwd" -mindepth 1 -print)" ]] ||
    fail "private Stage-5 working directory changed"
for staged_metallib in "$cli_metallib" "$test_resource_metallib"; do
    [[ "$(stat -f %Lp "$staged_metallib")" == "444" \
        && "$(stat -f %z "$staged_metallib")" == "$metallib_byte_count" \
        && "$(shasum -a 256 "$staged_metallib" | awk '{print $1}')" == "$metallib_sha256" ]] ||
        fail "Stage-5 staged metallib changed during execution"
    cmp -s "$metallib" "$staged_metallib" ||
        fail "Stage-5 staged metallib bytes changed during execution"
done

echo "OK: exact-main Stage-5 tiny same-device three-trial/nine-branch trajectory determinism passed once; no artifact retained and Stage 6 remains unauthorized"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo 'The one-shot Stage-5 tiny mechanics witness ran three independent same-process trials with uninterrupted, source-snapshot-continuation, and fresh-restored branches under one full-duration test-owned PrimeMetalDeviceLease.'
        echo 'It established exact raw/clipped-gradient, parameter, Adam-moment, RNG/cursor, scalar, evaluation, and terminal-control bytes on one singleton GPU-index-zero device in SwiftPM debug with eager uncompiled MLX.'
        echo 'The private lease file and parent were exactly reclaimed. No artifact was retained or uploaded, and no retry, cross-device, Stage 6, Native-300M, admission, trial, canary, product, or publication authority is granted.'
    } >> "$GITHUB_STEP_SUMMARY"
fi
