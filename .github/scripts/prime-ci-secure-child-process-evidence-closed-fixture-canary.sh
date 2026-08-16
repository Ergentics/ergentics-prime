#!/bin/bash -p

# This launcher is the single, closed hosted compatibility canary authorized by
# PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1.  Sourcing this
# file defines pure helpers only.  The production path runs only when the file
# itself is invoked, and it never accepts a caller command or argument surface.

readonly PRIME_CANARY_AUTHORITY_ID="prime_secure_child_process_evidence_closed_fixture_canary_authority_v1"
readonly PRIME_CANARY_AUTHORITY_CANONICAL_SHA256="29cd7cb18001da845021bc60f8f250a920f927cdc302e5d5071e95f049c3351f"
readonly PRIME_CANARY_AUTHORITY_CLOSURE_REVISION="b3402efd96d3ff893a0c2b73897cf48c9b313c8c"
readonly PRIME_CANARY_AUTHORITY_CLOSURE_TREE="7fb3f5505796a43c9db1537ca72f81e19367365f"
readonly PRIME_CANARY_AUTHORITY_CLOSURE_FIRST_PARENT="232a17e8f58a297919366d963ee1d7bc38cdbaee"
readonly PRIME_CANARY_AUTHORITY_CLOSURE_SECOND_PARENT="82ae2c2611e62144c066db990be6eaf48fdff47a"
readonly PRIME_CANARY_AUTHORITY_CLOSURE_GITHUB_SIGNATURE_VERIFIED="true"
readonly PRIME_CANARY_AUTHORITY_CLOSURE_GITHUB_SIGNATURE_REASON="valid"
readonly PRIME_CANARY_AUTHORITY_UNIQUE_PUSH_RUN_COUNT="1"
readonly PRIME_CANARY_AUTHORITY_WORKFLOW_CONCLUSION="success"
readonly PRIME_CANARY_AUTHORITY_ACTIVE_FAILURE_COUNT="0"
readonly PRIME_CANARY_AUTHORITY_REVIEWED_FAILURE_COUNT="0"
readonly PRIME_CANARY_AUTHORITY_REVIEWED_SKIP_COUNT="0"
readonly PRIME_CANARY_EMPTY_SHA256="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
readonly PRIME_CANARY_FIXTURE_BYTE_COUNT="89632"
readonly PRIME_CANARY_FIXTURE_SHA256="eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd"
readonly PRIME_CANARY_SUCCESS_STDOUT_BYTE_COUNT="121"
readonly PRIME_CANARY_SUCCESS_STDOUT_SHA256="933bf087c8b15408aef9aaca1447dfbc07c9685ca0fda451d9db7fda4c1198af"
readonly PRIME_CANARY_CAPTURE_BYTE_CAP="131072"
readonly PRIME_CANARY_RECORD_PREFIX="prime-secure-child closed-fixture-canary observation: "
readonly PRIME_CANARY_RECORD_SCHEMA_ID="prime_secure_child_process_evidence_closed_fixture_canary_outer_observation_v1"
readonly PRIME_CANARY_RECORD_MAXIMUM_JSON_BYTES="4041"
readonly PRIME_CANARY_RECORD_MAXIMUM_LINE_BYTES="4096"
readonly PRIME_CANARY_SIGNED_INTEGER_MAX="9223372036854775807"
readonly PRIME_CANARY_EPOCH_LEAF="prime-secure-child-process-evidence-closed-fixture-canary-reviewed-job-epoch"
readonly PRIME_CANARY_CAPTURE_ROOT_LEAF="prime-secure-child-process-evidence-closed-fixture-canary-outer-capture"
readonly PRIME_CANARY_MLX_REVISION="d37885a278f1c37484a94d0f401a418735e66519"
readonly PRIME_CANARY_NUMERICS_REVISION="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly PRIME_CANARY_MLX_ORIGIN="https://github.com/Ergentics/ergentics-mlx-swift"
readonly PRIME_CANARY_NUMERICS_ORIGIN="https://github.com/apple/swift-numerics"
readonly PRIME_CANARY_ADAPTER_FAILURE_PREFIX="prime-validation secure-child integration: FAIL "
readonly PRIME_CANARY_LAYER_A_FAIL_STOP_PREFIX="prime-secure-child fail-stop: "

prime_canary_is_sha256() {
    [[ "$1" =~ ^[0-9a-f]{64}$ ]]
}

prime_canary_is_git_sha() {
    [[ "$1" =~ ^[0-9a-f]{40}$ ]]
}

prime_canary_is_nonnegative_integer() {
    [[ "$1" =~ ^(0|[1-9][0-9]*)$ ]]
}

prime_canary_is_positive_integer() {
    [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

prime_canary_is_nonnegative_integer_at_most() {
    local value="$1"
    local maximum="$2"
    local LC_ALL=C
    prime_canary_is_nonnegative_integer "$value" || return 1
    prime_canary_is_nonnegative_integer "$maximum" || return 1
    if [[ "${#value}" -lt "${#maximum}" ]]; then
        return 0
    fi
    if [[ "${#value}" -gt "${#maximum}" ]]; then
        return 1
    fi
    [[ "$value" == "$maximum" || "$value" < "$maximum" ]]
}

prime_canary_sha256_file() {
    local path="$1"
    local digest
    digest="$(shasum -a 256 "$path" 2>/dev/null | awk 'NF == 2 { print $1 }')" || return 1
    prime_canary_is_sha256 "$digest" || return 1
    printf '%s\n' "$digest"
}

prime_canary_file_byte_count() {
    local path="$1"
    local count
    count="$(stat -f %z "$path" 2>/dev/null)" || return 1
    prime_canary_is_nonnegative_integer "$count" || return 1
    printf '%s\n' "$count"
}

prime_canary_file_metadata() {
    stat -f '%d:%i:%Lp:%u:%g:%l:%z' "$1" 2>/dev/null
}

prime_canary_file_inode_and_size() {
    stat -f '%i:%z' "$1" 2>/dev/null
}

prime_canary_commit_header() {
    local repository="$1"
    local revision="$2"
    [[ "$(git -C "$repository" cat-file -t "$revision" 2>/dev/null)" == "commit" ]] || return 1
    local header
    header="$(git -C "$repository" cat-file -p "$revision" 2>/dev/null | awk '
        !found_separator && $0 == "" { found_separator = 1; next }
        !found_separator { print }
        END { if (!found_separator) exit 1 }
    ')" || return 1
    awk '
        /^ / {
            if (field != "gpgsig" && field != "gpgsig-sha256" &&
                    field != "mergetag") exit 1
            next
        }
        /^[A-Za-z0-9][A-Za-z0-9-]* .+$/ {
            split($0, words, " ")
            field = words[1]
            next
        }
        { exit 1 }
    ' <<< "$header" || return 1
    local tree_lines tree_count parent_lines parent_count
    tree_lines="$(awk '/^tree/ { print }' <<< "$header")"
    tree_count="$(awk '/^tree/ { count += 1 } END { print count + 0 }' <<< "$header")"
    [[ "$tree_count" == "1" && "$tree_lines" =~ ^tree\ [0-9a-f]{40}$ ]] || return 1
    parent_lines="$(awk '/^parent/ { print }' <<< "$header")"
    parent_count="$(awk '/^parent/ { count += 1 } END { print count + 0 }' <<< "$header")"
    if [[ "$parent_count" != "0" ]]; then
        while IFS= read -r parent_line; do
            [[ "$parent_line" =~ ^parent\ [0-9a-f]{40}$ ]] || return 1
        done <<< "$parent_lines"
    fi
    printf '%s\n' "$header"
}

prime_canary_commit_tree() {
    prime_canary_commit_header "$1" "$2" | awk '/^tree / { print $2 }'
}

prime_canary_commit_parents() {
    prime_canary_commit_header "$1" "$2" | awk '/^parent / { print $2 }'
}

prime_canary_exact_result_code() {
    case "$1" in
        PASS|INVOCATION_ADMISSION_REFUSED|EPOCH_REFUSED|PREINVOCATION_CUTOFF|\
        PLATFORM_REFUSED|MIRROR_REFUSED|SWIFTPM_ROOT_REFUSED|\
        ADAPTER_IDENTITY_REFUSED|BUILD_REFUSED|PIN_MISMATCH|\
        CAPTURE_SETUP_REFUSED|ADAPTER_REPORTED_FAILURE|\
        LAYER_A_FAIL_STOP_REPORTED|ADAPTER_NO_REPORT|\
        ADAPTER_UNEXPECTED_REPORT|ADAPTER_OUTPUT_CONTRACT_MISMATCH|\
        CAPTURE_CAP_REACHED|CAPTURE_CLEANUP_FAILED|UNCLASSIFIED)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

prime_canary_prefix_matches() {
    local path="$1"
    local prefix="$2"
    local prefix_bytes="$3"
    local observed_byte_count
    observed_byte_count="$(prime_canary_file_byte_count "$path")" || return 1
    prime_canary_is_nonnegative_integer_at_most \
        "$observed_byte_count" "$PRIME_CANARY_CAPTURE_BYTE_CAP" || return 1
    prime_canary_is_nonnegative_integer_at_most \
        "$prefix_bytes" "$observed_byte_count" || return 1
    dd if="$path" bs=1 count="$prefix_bytes" 2>/dev/null |
        cmp -s - <(printf '%s' "$prefix")
}

prime_canary_exactly_one_terminal_lf() {
    local path="$1"
    [[ "$(wc -l < "$path" | tr -d '[:space:]')" == "1" ]] || return 1
    [[ "$(tail -c 1 "$path" 2>/dev/null | od -An -tuC | tr -d '[:space:]')" == "10" ]]
}

prime_canary_classify_observation() {
    local shell_status="$1"
    local stdout_count="$2"
    local stdout_sha="$3"
    local stdout_cap_reached="$4"
    local stderr_path="$5"
    local stderr_count="$6"
    local stderr_cap_reached="$7"

    if [[ "$stdout_cap_reached" == "true" || "$stderr_cap_reached" == "true" ]]; then
        printf '%s\n' "CAPTURE_CAP_REACHED"
        return 0
    fi
    if [[ "$shell_status" == "0" ]]; then
        if [[ "$stdout_count" == "$PRIME_CANARY_SUCCESS_STDOUT_BYTE_COUNT" \
            && "$stdout_sha" == "$PRIME_CANARY_SUCCESS_STDOUT_SHA256" \
            && "$stderr_count" == "0" ]]; then
            printf '%s\n' "PASS"
        else
            printf '%s\n' "ADAPTER_OUTPUT_CONTRACT_MISMATCH"
        fi
        return 0
    fi
    if [[ "$stdout_count" == "0" && "$stderr_count" == "0" ]]; then
        printf '%s\n' "ADAPTER_NO_REPORT"
        return 0
    fi
    if [[ "$stdout_count" == "0" \
        && ( "$shell_status" == "1" || "$shell_status" == "2" ) ]]; then
        if prime_canary_prefix_matches "$stderr_path" \
                "$PRIME_CANARY_ADAPTER_FAILURE_PREFIX" "48" \
            && prime_canary_exactly_one_terminal_lf "$stderr_path"; then
            printf '%s\n' "ADAPTER_REPORTED_FAILURE"
            return 0
        fi
    fi
    if [[ "$stdout_count" == "0" && "$shell_status" == "70" ]]; then
        if prime_canary_prefix_matches "$stderr_path" \
                "$PRIME_CANARY_LAYER_A_FAIL_STOP_PREFIX" "30" \
            && prime_canary_exactly_one_terminal_lf "$stderr_path"; then
            printf '%s\n' "LAYER_A_FAIL_STOP_REPORTED"
            return 0
        fi
    fi
    printf '%s\n' "ADAPTER_UNEXPECTED_REPORT"
}

prime_canary_projection_values_valid() {
    local result_code="$1"
    prime_canary_exact_result_code "$result_code" || return 1
    [[ "$prime_canary_attempt_consumed" == "true" \
        || "$prime_canary_attempt_consumed" == "false" ]] || return 1
    [[ "$prime_canary_stdout_cap_reached" == "true" \
        || "$prime_canary_stdout_cap_reached" == "false" ]] || return 1
    [[ "$prime_canary_stderr_cap_reached" == "true" \
        || "$prime_canary_stderr_cap_reached" == "false" ]] || return 1
    case "$prime_canary_command_state" in
        not_attempted|shell_command_returned) ;;
        *) return 1 ;;
    esac
    case "$prime_canary_execution_observation" in
        observed_true|observed_false|unavailable) ;;
        *) return 1 ;;
    esac
    case "$prime_canary_cleanup_absence" in
        observed_true|observed_false|unavailable) ;;
        *) return 1 ;;
    esac
    [[ "$prime_canary_stream_measurements_complete" == "true" \
        && "$prime_canary_cleanup_attempt_complete" == "true" ]] || return 1
    prime_canary_is_git_sha "$prime_canary_exact_revision" || return 1
    prime_canary_is_nonnegative_integer_at_most \
        "$prime_canary_stdout_count" "$PRIME_CANARY_CAPTURE_BYTE_CAP" || return 1
    prime_canary_is_nonnegative_integer_at_most \
        "$prime_canary_stderr_count" "$PRIME_CANARY_CAPTURE_BYTE_CAP" || return 1
    prime_canary_is_sha256 "$prime_canary_stdout_sha" || return 1
    prime_canary_is_sha256 "$prime_canary_stderr_sha" || return 1
    [[ ( "$prime_canary_stdout_cap_reached" == "true" \
            && "$prime_canary_stdout_count" == "$PRIME_CANARY_CAPTURE_BYTE_CAP" ) \
        || ( "$prime_canary_stdout_cap_reached" == "false" \
            && "$prime_canary_stdout_count" != "$PRIME_CANARY_CAPTURE_BYTE_CAP" ) ]] || return 1
    [[ ( "$prime_canary_stderr_cap_reached" == "true" \
            && "$prime_canary_stderr_count" == "$PRIME_CANARY_CAPTURE_BYTE_CAP" ) \
        || ( "$prime_canary_stderr_cap_reached" == "false" \
            && "$prime_canary_stderr_count" != "$PRIME_CANARY_CAPTURE_BYTE_CAP" ) ]] || return 1
    [[ "$prime_canary_stdout_count" != "0" \
        || "$prime_canary_stdout_sha" == "$PRIME_CANARY_EMPTY_SHA256" ]] || return 1
    [[ "$prime_canary_stderr_count" != "0" \
        || "$prime_canary_stderr_sha" == "$PRIME_CANARY_EMPTY_SHA256" ]] || return 1
    if [[ "$prime_canary_adapter_bytes" == "null" \
        || "$prime_canary_adapter_sha" == "null" ]]; then
        [[ "$prime_canary_adapter_bytes" == "null" \
            && "$prime_canary_adapter_sha" == "null" ]] || return 1
    else
        prime_canary_is_positive_integer "$prime_canary_adapter_bytes" || return 1
        prime_canary_is_nonnegative_integer_at_most \
            "$prime_canary_adapter_bytes" "$PRIME_CANARY_SIGNED_INTEGER_MAX" || return 1
        prime_canary_is_sha256 "$prime_canary_adapter_sha" || return 1
    fi
    if [[ "$prime_canary_fixture_bytes" == "null" \
        || "$prime_canary_fixture_sha" == "null" ]]; then
        [[ "$prime_canary_fixture_bytes" == "null" \
            && "$prime_canary_fixture_sha" == "null" ]] || return 1
    else
        [[ "$prime_canary_fixture_bytes" == "$PRIME_CANARY_FIXTURE_BYTE_COUNT" \
            && "$prime_canary_fixture_sha" == "$PRIME_CANARY_FIXTURE_SHA256" ]] || return 1
    fi
    if [[ "$prime_canary_command_state" == "not_attempted" ]]; then
        [[ "$prime_canary_attempt_consumed" == "false" \
            && "$prime_canary_shell_status" == "null" \
            && "$prime_canary_execution_observation" == "observed_false" \
            && "$prime_canary_stdout_count" == "0" \
            && "$prime_canary_stderr_count" == "0" \
            && "$prime_canary_stdout_sha" == "$PRIME_CANARY_EMPTY_SHA256" \
            && "$prime_canary_stderr_sha" == "$PRIME_CANARY_EMPTY_SHA256" \
            && "$prime_canary_stdout_cap_reached" == "false" \
            && "$prime_canary_stderr_cap_reached" == "false" ]] || return 1
    else
        [[ "$prime_canary_attempt_consumed" == "true" \
            && "$prime_canary_adapter_bytes" != "null" \
            && "$prime_canary_fixture_bytes" != "null" \
            && "$prime_canary_shell_status" != "null" \
            && ( "$prime_canary_cleanup_absence" == "observed_true" \
                || "$prime_canary_cleanup_absence" == "observed_false" ) ]] || return 1
        prime_canary_is_nonnegative_integer_at_most \
            "$prime_canary_shell_status" "255" || return 1
    fi
    case "$result_code" in
        INVOCATION_ADMISSION_REFUSED|EPOCH_REFUSED|PREINVOCATION_CUTOFF|\
        PLATFORM_REFUSED|MIRROR_REFUSED|SWIFTPM_ROOT_REFUSED|\
        ADAPTER_IDENTITY_REFUSED|BUILD_REFUSED|PIN_MISMATCH|CAPTURE_SETUP_REFUSED)
            [[ "$prime_canary_command_state" == "not_attempted" ]] || return 1
            ;;
        PASS|ADAPTER_REPORTED_FAILURE|LAYER_A_FAIL_STOP_REPORTED|\
        ADAPTER_NO_REPORT|ADAPTER_UNEXPECTED_REPORT|\
        ADAPTER_OUTPUT_CONTRACT_MISMATCH|CAPTURE_CAP_REACHED|\
        CAPTURE_CLEANUP_FAILED)
            [[ "$prime_canary_command_state" == "shell_command_returned" ]] || return 1
            ;;
    esac
    case "$result_code" in
        PIN_MISMATCH)
            [[ "$prime_canary_adapter_bytes" != "null" \
                && "$prime_canary_adapter_sha" != "null" \
                && "$prime_canary_fixture_bytes" == "null" \
                && "$prime_canary_fixture_sha" == "null" ]] || return 1
            ;;
        PASS)
            [[ "$prime_canary_execution_observation" == "observed_true" \
                && "$prime_canary_shell_status" == "0" \
                && "$prime_canary_stdout_count" == "$PRIME_CANARY_SUCCESS_STDOUT_BYTE_COUNT" \
                && "$prime_canary_stdout_sha" == "$PRIME_CANARY_SUCCESS_STDOUT_SHA256" \
                && "$prime_canary_stderr_count" == "0" \
                && "$prime_canary_cleanup_absence" == "observed_true" ]] || return 1
            ;;
        ADAPTER_REPORTED_FAILURE)
            [[ "$prime_canary_execution_observation" == "observed_true" \
                && ( "$prime_canary_shell_status" == "1" \
                    || "$prime_canary_shell_status" == "2" ) \
                && "$prime_canary_stdout_count" == "0" \
                && "$prime_canary_stderr_count" -gt "0" \
                && "$prime_canary_stdout_cap_reached" == "false" \
                && "$prime_canary_stderr_cap_reached" == "false" ]] || return 1
            ;;
        LAYER_A_FAIL_STOP_REPORTED)
            [[ "$prime_canary_execution_observation" == "observed_true" \
                && "$prime_canary_shell_status" == "70" \
                && "$prime_canary_stdout_count" == "0" \
                && "$prime_canary_stderr_count" -gt "0" \
                && "$prime_canary_stdout_cap_reached" == "false" \
                && "$prime_canary_stderr_cap_reached" == "false" ]] || return 1
            ;;
        ADAPTER_NO_REPORT)
            [[ "$prime_canary_execution_observation" == "unavailable" \
                && "$prime_canary_shell_status" != "0" \
                && "$prime_canary_stdout_count" == "0" \
                && "$prime_canary_stderr_count" == "0" ]] || return 1
            ;;
        ADAPTER_UNEXPECTED_REPORT)
            [[ "$prime_canary_execution_observation" == "unavailable" \
                && "$prime_canary_shell_status" != "0" \
                && ( "$prime_canary_stdout_count" != "0" \
                    || "$prime_canary_stderr_count" != "0" ) \
                && "$prime_canary_stdout_cap_reached" == "false" \
                && "$prime_canary_stderr_cap_reached" == "false" ]] || return 1
            ;;
        ADAPTER_OUTPUT_CONTRACT_MISMATCH)
            [[ "$prime_canary_execution_observation" == "unavailable" \
                && "$prime_canary_shell_status" == "0" \
                && "$prime_canary_stdout_cap_reached" == "false" \
                && "$prime_canary_stderr_cap_reached" == "false" \
                && ( "$prime_canary_stdout_count" != "$PRIME_CANARY_SUCCESS_STDOUT_BYTE_COUNT" \
                    || "$prime_canary_stdout_sha" != "$PRIME_CANARY_SUCCESS_STDOUT_SHA256" \
                    || "$prime_canary_stderr_count" != "0" ) ]] || return 1
            ;;
        CAPTURE_CAP_REACHED)
            [[ "$prime_canary_execution_observation" == "unavailable" \
                && ( "$prime_canary_stdout_cap_reached" == "true" \
                    || "$prime_canary_stderr_cap_reached" == "true" ) ]] || return 1
            ;;
        CAPTURE_CLEANUP_FAILED)
            [[ "$prime_canary_execution_observation" == "observed_true" \
                && "$prime_canary_shell_status" == "0" \
                && "$prime_canary_stdout_count" == "$PRIME_CANARY_SUCCESS_STDOUT_BYTE_COUNT" \
                && "$prime_canary_stdout_sha" == "$PRIME_CANARY_SUCCESS_STDOUT_SHA256" \
                && "$prime_canary_stderr_count" == "0" \
                && "$prime_canary_stdout_cap_reached" == "false" \
                && "$prime_canary_stderr_cap_reached" == "false" \
                && "$prime_canary_cleanup_absence" == "observed_false" ]] || return 1
            ;;
    esac
    case "$result_code" in
        PASS|ADAPTER_REPORTED_FAILURE|LAYER_A_FAIL_STOP_REPORTED|\
        ADAPTER_NO_REPORT|ADAPTER_UNEXPECTED_REPORT|\
        ADAPTER_OUTPUT_CONTRACT_MISMATCH|CAPTURE_CAP_REACHED)
            [[ "$prime_canary_classification_complete" == "true" \
                && "$prime_canary_classified_result_code" == "$result_code" ]] || return 1
            ;;
        CAPTURE_CLEANUP_FAILED)
            [[ "$prime_canary_classification_complete" == "true" \
                && "$prime_canary_classified_result_code" == "PASS" ]] || return 1
            ;;
    esac
}

prime_canary_emit_record() {
    local result_code="$1"
    prime_canary_projection_values_valid "$result_code" || return 1
    local json
    json="$(jq -cnS \
        --arg attempt "$prime_canary_attempt_consumed" \
        --arg command_state "$prime_canary_command_state" \
        --arg execution "$prime_canary_execution_observation" \
        --arg adapter_bytes "$prime_canary_adapter_bytes" \
        --arg adapter_sha "$prime_canary_adapter_sha" \
        --arg authority_sha "$PRIME_CANARY_AUTHORITY_CANONICAL_SHA256" \
        --arg authority_id "$PRIME_CANARY_AUTHORITY_ID" \
        --arg cleanup "$prime_canary_cleanup_absence" \
        --arg revision "$prime_canary_exact_revision" \
        --arg fixture_bytes "$prime_canary_fixture_bytes" \
        --arg fixture_sha "$prime_canary_fixture_sha" \
        --arg result_code "$result_code" \
        --arg schema_id "$PRIME_CANARY_RECORD_SCHEMA_ID" \
        --arg shell_status "$prime_canary_shell_status" \
        --arg stderr_count "$prime_canary_stderr_count" \
        --arg stderr_cap "$prime_canary_stderr_cap_reached" \
        --arg stderr_sha "$prime_canary_stderr_sha" \
        --arg stdout_count "$prime_canary_stdout_count" \
        --arg stdout_cap "$prime_canary_stdout_cap_reached" \
        --arg stdout_sha "$prime_canary_stdout_sha" '
        {
          actions_artifact: false,
          adapter_command_attempt_one_shot_consumed: ($attempt == "true"),
          adapter_command_state: $command_state,
          adapter_execution_observation: $execution,
          adapter_executable_byte_count: (if $adapter_bytes == "null" then null else ($adapter_bytes | tonumber) end),
          adapter_executable_sha256: (if $adapter_sha == "null" then null else $adapter_sha end),
          authority_canonical_sha256: $authority_sha,
          authority_id: $authority_id,
          capture_cleanup_absence: $cleanup,
          durable_evidence: false,
          exact_revision: $revision,
          fixture_executable_byte_count: (if $fixture_bytes == "null" then null else ($fixture_bytes | tonumber) end),
          fixture_executable_sha256: (if $fixture_sha == "null" then null else $fixture_sha end),
          opportunity_state: "retired",
          result_code: $result_code,
          schema_id: $schema_id,
          schema_version: 1,
          scientific_outcome: "not_established",
          shell_wait_status: (if $shell_status == "null" then null else ($shell_status | tonumber) end),
          standard_error_byte_cap: 131072,
          standard_error_captured_byte_count: ($stderr_count | tonumber),
          standard_error_capture_cap_reached: ($stderr_cap == "true"),
          standard_error_sha256: $stderr_sha,
          standard_output_byte_cap: 131072,
          standard_output_captured_byte_count: ($stdout_count | tonumber),
          standard_output_capture_cap_reached: ($stdout_cap == "true"),
          standard_output_sha256: $stdout_sha
        }
    ')" || return 1
    local expected_keys observed_keys
    expected_keys=$'actions_artifact\nadapter_command_attempt_one_shot_consumed\nadapter_command_state\nadapter_executable_byte_count\nadapter_executable_sha256\nadapter_execution_observation\nauthority_canonical_sha256\nauthority_id\ncapture_cleanup_absence\ndurable_evidence\nexact_revision\nfixture_executable_byte_count\nfixture_executable_sha256\nopportunity_state\nresult_code\nschema_id\nschema_version\nscientific_outcome\nshell_wait_status\nstandard_error_byte_cap\nstandard_error_capture_cap_reached\nstandard_error_captured_byte_count\nstandard_error_sha256\nstandard_output_byte_cap\nstandard_output_capture_cap_reached\nstandard_output_captured_byte_count\nstandard_output_sha256'
    observed_keys="$(printf '%s' "$json" | jq -r 'keys[]' 2>/dev/null)" || return 1
    [[ "$observed_keys" == "$expected_keys" ]] || return 1
    [[ "$(printf '%s' "$json" | jq -cS . 2>/dev/null)" == "$json" ]] || return 1
    local json_bytes
    json_bytes="$(LC_ALL=C printf '%s' "$json" | wc -c | tr -d '[:space:]')" || return 1
    prime_canary_is_positive_integer "$json_bytes" || return 1
    [[ "$json_bytes" -le "$PRIME_CANARY_RECORD_MAXIMUM_JSON_BYTES" ]] || return 1
    local prefix_bytes line_bytes
    prefix_bytes="$(LC_ALL=C printf '%s' "$PRIME_CANARY_RECORD_PREFIX" | wc -c | tr -d '[:space:]')" || return 1
    [[ "$prefix_bytes" == "54" ]] || return 1
    line_bytes=$((prefix_bytes + json_bytes + 1))
    [[ "$line_bytes" -le "$PRIME_CANARY_RECORD_MAXIMUM_LINE_BYTES" ]] || return 1
    printf '%s%s\n' "$PRIME_CANARY_RECORD_PREFIX" "$json" >&3 || return 1
    prime_canary_record_emitted=true
}

prime_canary_refuse() {
    local result_code="$1"
    prime_canary_emit_record "$result_code"
    return 1
}

prime_canary_initialize_state() {
    prime_canary_record_emitted=false
    prime_canary_projection_ready=true
    prime_canary_attempt_consumed=false
    prime_canary_command_state="not_attempted"
    prime_canary_execution_observation="observed_false"
    prime_canary_adapter_bytes="null"
    prime_canary_adapter_sha="null"
    prime_canary_fixture_bytes="null"
    prime_canary_fixture_sha="null"
    prime_canary_cleanup_absence="unavailable"
    prime_canary_classification_complete=false
    prime_canary_classified_result_code="null"
    prime_canary_stream_measurements_complete=true
    prime_canary_cleanup_attempt_complete=true
    prime_canary_shell_status="null"
    prime_canary_stdout_count="0"
    prime_canary_stdout_sha="$PRIME_CANARY_EMPTY_SHA256"
    prime_canary_stdout_cap_reached=false
    prime_canary_stderr_count="0"
    prime_canary_stderr_sha="$PRIME_CANARY_EMPTY_SHA256"
    prime_canary_stderr_cap_reached=false
    prime_canary_capture_root_owned=false
    prime_canary_exact_revision="${GITHUB_SHA:-}"
}

prime_canary_exit_trap() {
    local original_status="$?"
    trap - EXIT
    exec 7<&- 8<&- 9<&- 2>/dev/null || true
    if [[ "${prime_canary_capture_root_owned:-false}" == "true" \
        && "${prime_canary_cleanup_attempt_complete:-false}" != "true" ]]; then
        prime_canary_cleanup_capture || true
    fi
    if [[ "${prime_canary_record_emitted:-false}" != "true" ]]; then
        prime_canary_emit_record "UNCLASSIFIED" || true
    fi
    if [[ "$original_status" == "0" \
        && "${prime_canary_record_emitted:-false}" != "true" ]]; then
        original_status=1
    fi
    exit "$original_status"
}

prime_canary_authority_environment_matches() {
    [[ "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_CLOSURE_REVISION:-}" \
            == "$PRIME_CANARY_AUTHORITY_CLOSURE_REVISION" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_CLOSURE_TREE:-}" \
            == "$PRIME_CANARY_AUTHORITY_CLOSURE_TREE" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_WORKFLOW_RUN_ID:-}" \
            == "31957009710" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_WORKFLOW_RUN_NUMBER:-}" \
            == "141" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_WORKFLOW_ATTEMPT:-}" \
            == "1" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_CHECK_SUITE_ID:-}" \
            == "86653677663" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_PREVIOUS_ATTEMPT_URL_IS_NULL:-}" \
            == "true" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_WORKFLOW_RERUN_COUNT:-}" \
            == "0" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_ACTIVE_JOB_ID:-}" \
            == "95189063495" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_ACTIVE_JOB_CONCLUSION:-}" \
            == "success" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_ACTIVE_LATIN_TEST_COUNT:-}" \
            == "116" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_REVIEWED_JOB_ID:-}" \
            == "95189438167" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_REVIEWED_JOB_CONCLUSION:-}" \
            == "success" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_ROOT_TEST_COUNT:-}" \
            == "78" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_ISOLATED_TEST_COUNT:-}" \
            == "6" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_FOCUSED_WHOLE_TEST_COUNT:-}" \
            == "84" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_RETAINED_LIVE_TEST_COUNT:-}" \
            == "46" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_AGGREGATE_TEST_COUNT:-}" \
            == "130" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_TEST_METHOD_COUNT:-}" \
            == "1" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_ACTIONS_ARTIFACT_COUNT:-}" \
            == "0" \
        && "${PRIME_SECURE_CHILD_PROCESS_EVIDENCE_CLOSED_FIXTURE_CANARY_AUTHORITY_CANARY_MECHANICS_INVOCATION_COUNT:-}" \
            == "0" ]]
}

prime_canary_bound_closure_evidence_matches() {
    [[ "$PRIME_CANARY_AUTHORITY_CLOSURE_GITHUB_SIGNATURE_VERIFIED" == "true" \
        && "$PRIME_CANARY_AUTHORITY_CLOSURE_GITHUB_SIGNATURE_REASON" == "valid" \
        && "$PRIME_CANARY_AUTHORITY_UNIQUE_PUSH_RUN_COUNT" == "1" \
        && "$PRIME_CANARY_AUTHORITY_WORKFLOW_CONCLUSION" == "success" \
        && "$PRIME_CANARY_AUTHORITY_ACTIVE_FAILURE_COUNT" == "0" \
        && "$PRIME_CANARY_AUTHORITY_REVIEWED_FAILURE_COUNT" == "0" \
        && "$PRIME_CANARY_AUTHORITY_REVIEWED_SKIP_COUNT" == "0" ]]
}

prime_canary_validate_topology() {
    local repository="$1"
    local closure_tree closure_parents head_tree head_parents second_parent
    closure_tree="$(prime_canary_commit_tree "$repository" \
        "$PRIME_CANARY_AUTHORITY_CLOSURE_REVISION")" || return 1
    closure_parents="$(prime_canary_commit_parents "$repository" \
        "$PRIME_CANARY_AUTHORITY_CLOSURE_REVISION")" || return 1
    [[ "$closure_tree" == "$PRIME_CANARY_AUTHORITY_CLOSURE_TREE" \
        && "$closure_parents" == "$PRIME_CANARY_AUTHORITY_CLOSURE_FIRST_PARENT
$PRIME_CANARY_AUTHORITY_CLOSURE_SECOND_PARENT" ]] || return 1
    head_tree="$(prime_canary_commit_tree "$repository" HEAD)" || return 1
    head_parents="$(prime_canary_commit_parents "$repository" HEAD)" || return 1
    [[ "$(awk 'NF { count += 1 } END { print count + 0 }' <<< "$head_parents")" == "2" ]] || return 1
    [[ "$(head -n 1 <<< "$head_parents")" == "$PRIME_CANARY_AUTHORITY_CLOSURE_REVISION" ]] || return 1
    second_parent="$(awk 'NR == 2 { print }' <<< "$head_parents")"
    prime_canary_is_git_sha "$second_parent" || return 1
    [[ "$(prime_canary_commit_parents "$repository" "$second_parent")" \
            == "$PRIME_CANARY_AUTHORITY_CLOSURE_REVISION" \
        && "$(prime_canary_commit_tree "$repository" "$second_parent")" \
            == "$head_tree" ]] || return 1
    local expected_status
    expected_status=$'M\t.github/scripts/prime-ci-active-root-quarantine.sh\nA\t.github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh\nM\t.github/workflows/prime-active-root-quarantine.yml'
    [[ "$(git -C "$repository" diff --name-status --no-renames \
            "$PRIME_CANARY_AUTHORITY_CLOSURE_REVISION" HEAD 2>/dev/null)" \
            == "$expected_status" ]] || return 1
    [[ "$(git -C "$repository" ls-files -s -- \
            '.github/scripts/prime-ci-active-root-quarantine.sh' | awk '{print $1}')" == "100755" \
        && "$(git -C "$repository" ls-files -s -- \
            '.github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh' | awk '{print $1}')" == "100755" \
        && "$(git -C "$repository" ls-files -s -- \
            '.github/workflows/prime-active-root-quarantine.yml' | awk '{print $1}')" == "100644" ]]
}

prime_canary_validate_admission() {
    local argument_count="$1"
    local repository="$2"
    local observed_head observed_status symbolic_status
    observed_head="$(git -C "$repository" rev-parse HEAD 2>/dev/null)" || return 1
    observed_status="$(git -C "$repository" status \
        --porcelain=v1 --untracked-files=all 2>/dev/null)" || return 1
    [[ "$argument_count" == "0" \
        && "${GITHUB_ACTIONS:-}" == "true" \
        && "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" \
        && "${GITHUB_EVENT_NAME:-}" == "push" \
        && "${GITHUB_REF:-}" == "refs/heads/main" \
        && "${GITHUB_JOB:-}" == "trusted-main-compile" \
        && "${GITHUB_RUN_ATTEMPT:-}" == "1" \
        && "${EXACT_REVISION:-}" == "$prime_canary_exact_revision" \
        && "$observed_head" == "$prime_canary_exact_revision" \
        && -z "$observed_status" ]] || return 1
    if git -C "$repository" symbolic-ref -q HEAD >/dev/null 2>&1; then
        return 1
    else
        symbolic_status="$?"
    fi
    [[ "$symbolic_status" == "1" ]] || return 1
    prime_canary_authority_environment_matches || return 1
    prime_canary_bound_closure_evidence_matches || return 1
    prime_canary_validate_topology "$repository"
}

prime_canary_validate_epoch() {
    local epoch_path="$1"
    [[ -f "$epoch_path" && ! -L "$epoch_path" ]] || return 1
    prime_canary_epoch_path_metadata="$(prime_canary_file_metadata "$epoch_path")" || return 1
    local epoch_mode epoch_uid epoch_gid epoch_links
    epoch_mode="$(stat -f %Lp "$epoch_path" 2>/dev/null)" || return 1
    epoch_uid="$(stat -f %u "$epoch_path" 2>/dev/null)" || return 1
    epoch_gid="$(stat -f %g "$epoch_path" 2>/dev/null)" || return 1
    epoch_links="$(stat -f %l "$epoch_path" 2>/dev/null)" || return 1
    [[ "$epoch_mode" == "400" \
        && "$epoch_uid" == "$(id -u)" \
        && "$epoch_gid" == "$(id -g)" \
        && "$epoch_links" == "1" \
        && "$(wc -l < "$epoch_path" | tr -d '[:space:]')" == "1" ]] || return 1
    local extra_line=""
    {
        IFS= read -r prime_canary_epoch_value || return 1
        ! IFS= read -r extra_line || return 1
    } < "$epoch_path"
    [[ -z "$extra_line" ]] || return 1
    prime_canary_is_positive_integer "$prime_canary_epoch_value" || return 1
    prime_canary_is_nonnegative_integer_at_most \
        "$prime_canary_epoch_value" "$PRIME_CANARY_SIGNED_INTEGER_MAX" || return 1
    local expected_epoch_byte_count
    expected_epoch_byte_count=$((${#prime_canary_epoch_value} + 1))
    [[ "$(prime_canary_file_byte_count "$epoch_path")" == "$expected_epoch_byte_count" ]] || return 1
    cmp -s "$epoch_path" <(printf '%s\n' "$prime_canary_epoch_value") || return 1
    prime_canary_epoch_sha="$(prime_canary_sha256_file "$epoch_path")" || return 1
}

prime_canary_revalidate_epoch() {
    local epoch_path="$1"
    [[ -f "$epoch_path" && ! -L "$epoch_path" \
        && "$(prime_canary_file_metadata "$epoch_path")" == "$prime_canary_epoch_path_metadata" \
        && "$(prime_canary_sha256_file "$epoch_path")" == "$prime_canary_epoch_sha" \
        && "$(< "$epoch_path")" == "$prime_canary_epoch_value" ]] || return 1
    exec 9< "$epoch_path" || return 1
    prime_canary_epoch_fd_metadata="$(prime_canary_file_metadata /dev/fd/9)" || return 1
    [[ "$(prime_canary_file_inode_and_size "$epoch_path")" \
            == "$(prime_canary_file_inode_and_size /dev/fd/9)" \
        && "$(prime_canary_sha256_file /dev/fd/9)" == "$prime_canary_epoch_sha" ]] || return 1
    exec 9<&-
}

prime_canary_cutoff_valid() {
    local now elapsed
    now="$(date +%s 2>/dev/null)" || return 1
    prime_canary_is_positive_integer "$now" || return 1
    prime_canary_is_nonnegative_integer_at_most \
        "$now" "$PRIME_CANARY_SIGNED_INTEGER_MAX" || return 1
    prime_canary_is_nonnegative_integer_at_most \
        "$prime_canary_epoch_value" "$now" || return 1
    elapsed=$((now - prime_canary_epoch_value))
    [[ "$elapsed" -le "4200" \
        && $((4500 - elapsed)) -ge "300" ]]
}

prime_canary_validate_platform() {
    local product_version product_major
    [[ "$(uname -s 2>/dev/null)" == "Darwin" \
        && "$(uname -m 2>/dev/null)" == "arm64" ]] || return 1
    product_version="$(sw_vers -productVersion 2>/dev/null)" || return 1
    product_major="${product_version%%.*}"
    [[ "$product_major" == "26" ]]
}

prime_canary_physical_directory() {
    local path="$1"
    [[ "$path" == /* && -d "$path" && ! -L "$path" ]] || return 1
    (cd "$path" 2>/dev/null && pwd -P)
}

prime_canary_validate_bare_mirror() {
    local path="$1"
    local origin="$2"
    local revision="$3"
    local pinned_expression="$4"
    local physical remote_names remote_urls
    physical="$(prime_canary_physical_directory "$path")" || return 1
    [[ "$physical" == "$path" \
        && "$(git --git-dir="$path" rev-parse --absolute-git-dir 2>/dev/null)" == "$path" \
        && "$(git --git-dir="$path" rev-parse --is-bare-repository 2>/dev/null)" == "true" ]] || return 1
    remote_names="$(git --git-dir="$path" remote 2>/dev/null)" || return 1
    remote_urls="$(git --git-dir="$path" remote get-url --all origin 2>/dev/null)" || return 1
    [[ "$remote_names" == "origin" \
        && "$remote_urls" == "$origin" \
        && "$(git --git-dir="$path" cat-file -t "$revision" 2>/dev/null)" == "commit" \
        && "$(git --git-dir="$path" rev-parse "$revision^{commit}" 2>/dev/null)" == "$revision" \
        && "$(git --git-dir="$path" rev-parse "$pinned_expression" 2>/dev/null)" == "$revision" ]]
}

prime_canary_validate_mirrors() {
    local runner_temp="$1"
    local runner_physical
    runner_physical="$(prime_canary_physical_directory "$runner_temp")" || return 1
    [[ "$runner_physical" == "$runner_temp" ]] || return 1
    prime_canary_validate_bare_mirror \
        "$runner_temp/ergentics-mlx-swift.git" \
        "$PRIME_CANARY_MLX_ORIGIN" \
        "$PRIME_CANARY_MLX_REVISION" \
        'refs/heads/prime-pinned^{commit}' || return 1
    prime_canary_validate_bare_mirror \
        "$runner_temp/prime-active-root-build/repositories/swift-numerics-d936ec6c" \
        "$PRIME_CANARY_NUMERICS_ORIGIN" \
        "$PRIME_CANARY_NUMERICS_REVISION" \
        'refs/tags/1.1.1^{commit}'
}

prime_canary_create_swiftpm_roots() {
    local runner_temp="$1"
    prime_canary_scratch="$runner_temp/prime-secure-child-process-evidence-closed-fixture-canary-scratch"
    prime_canary_cache="$runner_temp/prime-secure-child-process-evidence-closed-fixture-canary-cache"
    prime_canary_config="$runner_temp/prime-secure-child-process-evidence-closed-fixture-canary-config"
    prime_canary_security="$runner_temp/prime-secure-child-process-evidence-closed-fixture-canary-security"
    local root
    for root in "$prime_canary_scratch" "$prime_canary_cache" \
            "$prime_canary_config" "$prime_canary_security"; do
        [[ ! -e "$root" && ! -L "$root" ]] || return 1
    done
    (umask 0077; mkdir "$prime_canary_scratch") || return 1
    (umask 0077; mkdir "$prime_canary_cache") || return 1
    (umask 0077; mkdir "$prime_canary_config") || return 1
    (umask 0077; mkdir "$prime_canary_security") || return 1
    for root in "$prime_canary_scratch" "$prime_canary_cache" \
            "$prime_canary_config" "$prime_canary_security"; do
        [[ "$(prime_canary_physical_directory "$root")" == "$root" \
            && "$(stat -f %Lp "$root" 2>/dev/null)" == "700" ]] || return 1
    done
}

prime_canary_build_products() {
    local package_path="$1"
    local runner_temp="$2"
    local mlx_url="file://$runner_temp/ergentics-mlx-swift.git/"
    local numerics_url="file://$runner_temp/prime-active-root-build/repositories/swift-numerics-d936ec6c/"
    TMPDIR="$runner_temp" \
    GIT_CONFIG_COUNT=3 \
    GIT_CONFIG_KEY_0="url.${mlx_url}.insteadOf" \
    GIT_CONFIG_VALUE_0="$PRIME_CANARY_MLX_ORIGIN" \
    GIT_CONFIG_KEY_1="url.${numerics_url}.insteadOf" \
    GIT_CONFIG_VALUE_1="$PRIME_CANARY_NUMERICS_ORIGIN" \
    GIT_CONFIG_KEY_2='protocol.file.allow' \
    GIT_CONFIG_VALUE_2='always' \
        swift build \
            --package-path "$package_path" \
            --configuration release \
            --scratch-path "$prime_canary_scratch" \
            --cache-path "$prime_canary_cache" \
            --config-path "$prime_canary_config" \
            --security-path "$prime_canary_security" \
            --disable-dependency-cache \
            --manifest-cache local \
            --disable-netrc \
            --disable-keychain \
            --force-resolved-versions \
            --product PrimeValidationWorkflowFixtureChild \
            >/dev/null 2>&1 3>&- 9<&- || return 1
    TMPDIR="$runner_temp" \
    GIT_CONFIG_COUNT=3 \
    GIT_CONFIG_KEY_0="url.${mlx_url}.insteadOf" \
    GIT_CONFIG_VALUE_0="$PRIME_CANARY_MLX_ORIGIN" \
    GIT_CONFIG_KEY_1="url.${numerics_url}.insteadOf" \
    GIT_CONFIG_VALUE_1="$PRIME_CANARY_NUMERICS_ORIGIN" \
    GIT_CONFIG_KEY_2='protocol.file.allow' \
    GIT_CONFIG_VALUE_2='always' \
        swift build \
            --package-path "$package_path" \
            --configuration release \
            --scratch-path "$prime_canary_scratch" \
            --cache-path "$prime_canary_cache" \
            --config-path "$prime_canary_config" \
            --security-path "$prime_canary_security" \
            --disable-dependency-cache \
            --manifest-cache local \
            --disable-netrc \
            --disable-keychain \
            --force-resolved-versions \
            --product PrimeValidationWorkflowSecureChildIntegration \
            >/dev/null 2>&1 3>&- 9<&- || return 1
    local show_raw sentinel payload bin_path
    sentinel='prime_closed_fixture_canary_show_bin_path_sentinel'
    show_raw="$(
        TMPDIR="$runner_temp" \
        GIT_CONFIG_COUNT=3 \
        GIT_CONFIG_KEY_0="url.${mlx_url}.insteadOf" \
        GIT_CONFIG_VALUE_0="$PRIME_CANARY_MLX_ORIGIN" \
        GIT_CONFIG_KEY_1="url.${numerics_url}.insteadOf" \
        GIT_CONFIG_VALUE_1="$PRIME_CANARY_NUMERICS_ORIGIN" \
        GIT_CONFIG_KEY_2='protocol.file.allow' \
        GIT_CONFIG_VALUE_2='always' \
            swift build \
                --package-path "$package_path" \
                --configuration release \
                --scratch-path "$prime_canary_scratch" \
                --cache-path "$prime_canary_cache" \
                --config-path "$prime_canary_config" \
                --security-path "$prime_canary_security" \
                --disable-dependency-cache \
                --manifest-cache local \
                --disable-netrc \
                --disable-keychain \
                --force-resolved-versions \
                --show-bin-path 2>/dev/null 3>&- 9<&-
        build_status=$?
        printf '%s' "$sentinel"
        exit "$build_status"
    )" || return 1
    [[ "$show_raw" == *"$sentinel" ]] || return 1
    payload="${show_raw%$sentinel}"
    [[ "$payload" == *$'\n' ]] || return 1
    bin_path="${payload%$'\n'}"
    [[ -n "$bin_path" && "$payload" == "$bin_path"$'\n' \
        && "$bin_path" != *$'\n'* ]] || return 1
    printf '%s\n' "$bin_path"
}

prime_canary_validate_executable_leaf() {
    local path="$1"
    [[ "$path" == /* && -f "$path" && ! -L "$path" && -x "$path" \
        && "$(stat -f %l "$path" 2>/dev/null)" == "1" ]]
}

prime_canary_bind_executables() {
    local bin_path="$1"
    local bin_physical
    bin_physical="$(prime_canary_physical_directory "$bin_path")" || return 1
    [[ "$bin_physical" == "$bin_path" \
        && "$bin_path/" == "$prime_canary_scratch/"* ]] || return 1
    prime_canary_fixture_path="$bin_path/PrimeValidationWorkflowFixtureChild"
    prime_canary_adapter_path="$bin_path/PrimeValidationWorkflowSecureChildIntegration"
    prime_canary_validate_executable_leaf "$prime_canary_fixture_path" || return 1
    prime_canary_validate_executable_leaf "$prime_canary_adapter_path" || return 1
    exec 7< "$prime_canary_adapter_path" || return 1
    exec 8< "$prime_canary_fixture_path" || return 1
    prime_canary_adapter_metadata="$(prime_canary_file_metadata "$prime_canary_adapter_path")" || return 1
    prime_canary_fixture_metadata="$(prime_canary_file_metadata "$prime_canary_fixture_path")" || return 1
    prime_canary_adapter_fd_metadata="$(prime_canary_file_metadata /dev/fd/7)" || return 1
    prime_canary_fixture_fd_metadata="$(prime_canary_file_metadata /dev/fd/8)" || return 1
    [[ "$(prime_canary_file_inode_and_size "$prime_canary_adapter_path")" \
            == "$(prime_canary_file_inode_and_size /dev/fd/7)" \
        && "$(prime_canary_file_inode_and_size "$prime_canary_fixture_path")" \
            == "$(prime_canary_file_inode_and_size /dev/fd/8)" ]] || return 1
    local measured_adapter_bytes measured_adapter_sha
    measured_adapter_bytes="$(prime_canary_file_byte_count /dev/fd/7)" || return 1
    measured_adapter_sha="$(prime_canary_sha256_file /dev/fd/7)" || return 1
    prime_canary_adapter_bytes="$measured_adapter_bytes"
    prime_canary_adapter_sha="$measured_adapter_sha"
    local measured_fixture_bytes measured_fixture_sha
    measured_fixture_bytes="$(prime_canary_file_byte_count /dev/fd/8)" || return 1
    measured_fixture_sha="$(prime_canary_sha256_file /dev/fd/8)" || return 1
    if [[ "$measured_fixture_bytes" != "$PRIME_CANARY_FIXTURE_BYTE_COUNT" \
        || "$measured_fixture_sha" != "$PRIME_CANARY_FIXTURE_SHA256" ]]; then
        prime_canary_fixture_bytes="null"
        prime_canary_fixture_sha="null"
        return 2
    fi
    prime_canary_fixture_bytes="$measured_fixture_bytes"
    prime_canary_fixture_sha="$measured_fixture_sha"
    exec 7<&-
    exec 8<&-
}

prime_canary_revalidate_executables() {
    exec 7< "$prime_canary_adapter_path" || return 1
    exec 8< "$prime_canary_fixture_path" || return 1
    prime_canary_validate_executable_leaf "$prime_canary_fixture_path" || return 1
    prime_canary_validate_executable_leaf "$prime_canary_adapter_path" || return 1
    [[ "$(prime_canary_file_metadata "$prime_canary_adapter_path")" == "$prime_canary_adapter_metadata" \
        && "$(prime_canary_file_metadata /dev/fd/7)" == "$prime_canary_adapter_fd_metadata" \
        && "$(prime_canary_file_inode_and_size "$prime_canary_adapter_path")" \
            == "$(prime_canary_file_inode_and_size /dev/fd/7)" \
        && "$(prime_canary_file_byte_count /dev/fd/7)" == "$prime_canary_adapter_bytes" \
        && "$(prime_canary_sha256_file /dev/fd/7)" == "$prime_canary_adapter_sha" \
        && "$(prime_canary_file_metadata "$prime_canary_fixture_path")" == "$prime_canary_fixture_metadata" \
        && "$(prime_canary_file_metadata /dev/fd/8)" == "$prime_canary_fixture_fd_metadata" \
        && "$(prime_canary_file_inode_and_size "$prime_canary_fixture_path")" \
            == "$(prime_canary_file_inode_and_size /dev/fd/8)" \
        && "$(prime_canary_file_byte_count /dev/fd/8)" == "$prime_canary_fixture_bytes" \
        && "$(prime_canary_sha256_file /dev/fd/8)" == "$prime_canary_fixture_sha" ]]
}

prime_canary_cleanup_capture() {
    if [[ "$prime_canary_capture_root_owned" != "true" ]]; then
        prime_canary_cleanup_attempt_complete=true
        prime_canary_cleanup_absence="unavailable"
        return 0
    fi
    /bin/unlink "$prime_canary_stdout_path" >/dev/null 2>&1 || true
    /bin/unlink "$prime_canary_stderr_path" >/dev/null 2>&1 || true
    /bin/rmdir "$prime_canary_capture_root" >/dev/null 2>&1 || true
    prime_canary_cleanup_attempt_complete=true
    if [[ ! -e "$prime_canary_stdout_path" && ! -L "$prime_canary_stdout_path" \
        && ! -e "$prime_canary_stderr_path" && ! -L "$prime_canary_stderr_path" \
        && ! -e "$prime_canary_capture_root" && ! -L "$prime_canary_capture_root" ]]; then
        prime_canary_cleanup_absence="observed_true"
        return 0
    fi
    prime_canary_cleanup_absence="observed_false"
    return 1
}

prime_canary_create_capture() {
    local runner_temp="$1"
    prime_canary_capture_root="$runner_temp/$PRIME_CANARY_CAPTURE_ROOT_LEAF"
    prime_canary_stdout_path="$prime_canary_capture_root/standard-output.capture"
    prime_canary_stderr_path="$prime_canary_capture_root/standard-error.capture"
    [[ ! -e "$prime_canary_capture_root" && ! -L "$prime_canary_capture_root" ]] || return 1
    (umask 0077; mkdir "$prime_canary_capture_root") || return 1
    prime_canary_capture_root_owned=true
    prime_canary_cleanup_attempt_complete=false
    [[ "$(prime_canary_physical_directory "$prime_canary_capture_root")" \
            == "$prime_canary_capture_root" \
        && "$(stat -f %Lp "$prime_canary_capture_root" 2>/dev/null)" == "700" ]] || return 1
    (umask 0177; set -o noclobber; : > "$prime_canary_stdout_path") || return 1
    (umask 0177; set -o noclobber; : > "$prime_canary_stderr_path") || return 1
    [[ -f "$prime_canary_stdout_path" && ! -L "$prime_canary_stdout_path" \
        && "$(stat -f %Lp "$prime_canary_stdout_path" 2>/dev/null)" == "600" \
        && "$(stat -f %l "$prime_canary_stdout_path" 2>/dev/null)" == "1" \
        && -f "$prime_canary_stderr_path" && ! -L "$prime_canary_stderr_path" \
        && "$(stat -f %Lp "$prime_canary_stderr_path" 2>/dev/null)" == "600" \
        && "$(stat -f %l "$prime_canary_stderr_path" 2>/dev/null)" == "1" ]]
}

prime_canary_refuse_after_capture() {
    local result_code="$1"
    prime_canary_cleanup_capture || true
    prime_canary_refuse "$result_code"
}

prime_canary_close_adapter_environment() {
    local fixed_tmpdir="$1"
    local function_name
    while IFS= read -r function_name; do
        builtin export -n -f "$function_name" 2>/dev/null || return 1
    done < <(builtin compgen -A function)
    local environment_name
    while IFS= read -r environment_name; do
        builtin export -n "$environment_name" 2>/dev/null || return 1
    done < <(builtin compgen -e)
    builtin export TMPDIR="$fixed_tmpdir"
}

prime_canary_measure_streams() {
    prime_canary_stdout_count="$(prime_canary_file_byte_count "$prime_canary_stdout_path")" || return 1
    prime_canary_stderr_count="$(prime_canary_file_byte_count "$prime_canary_stderr_path")" || return 1
    prime_canary_is_nonnegative_integer_at_most \
        "$prime_canary_stdout_count" "$PRIME_CANARY_CAPTURE_BYTE_CAP" || return 1
    prime_canary_is_nonnegative_integer_at_most \
        "$prime_canary_stderr_count" "$PRIME_CANARY_CAPTURE_BYTE_CAP" || return 1
    prime_canary_stdout_sha="$(prime_canary_sha256_file "$prime_canary_stdout_path")" || return 1
    prime_canary_stderr_sha="$(prime_canary_sha256_file "$prime_canary_stderr_path")" || return 1
    if [[ "$prime_canary_stdout_count" == "$PRIME_CANARY_CAPTURE_BYTE_CAP" ]]; then
        prime_canary_stdout_cap_reached=true
    else
        prime_canary_stdout_cap_reached=false
    fi
    if [[ "$prime_canary_stderr_count" == "$PRIME_CANARY_CAPTURE_BYTE_CAP" ]]; then
        prime_canary_stderr_cap_reached=true
    else
        prime_canary_stderr_cap_reached=false
    fi
    prime_canary_stream_measurements_complete=true
}

prime_canary_stream_measurements_still_match() {
    [[ "$(prime_canary_file_byte_count "$prime_canary_stdout_path")" \
            == "$prime_canary_stdout_count" \
        && "$(prime_canary_sha256_file "$prime_canary_stdout_path")" \
            == "$prime_canary_stdout_sha" \
        && "$(prime_canary_file_byte_count "$prime_canary_stderr_path")" \
            == "$prime_canary_stderr_count" \
        && "$(prime_canary_sha256_file "$prime_canary_stderr_path")" \
            == "$prime_canary_stderr_sha" ]]
}

prime_canary_main() {
    [[ "$-" == *p* ]] || return 1
    local argument_count="$#"
    set -u -o pipefail
    exec 3>&1 || return 1
    if ! exec >/dev/null 2>/dev/null; then
        exec 3>&- 2>/dev/null || true
        return 1
    fi
    prime_canary_initialize_state
    trap prime_canary_exit_trap EXIT || {
        exec 3>&- 2>/dev/null || true
        return 1
    }

    if ! prime_canary_is_git_sha "$prime_canary_exact_revision"; then
        prime_canary_projection_ready=false
        return 1
    fi
    local repository
    repository="$(pwd -P)" || return 1
    if [[ "${GITHUB_WORKSPACE:-}" != /* \
        || "$repository" != "${GITHUB_WORKSPACE:-}/ergentics-prime" ]]; then
        prime_canary_refuse "INVOCATION_ADMISSION_REFUSED"
        return 1
    fi
    if ! prime_canary_validate_admission "$argument_count" "$repository"; then
        prime_canary_refuse "INVOCATION_ADMISSION_REFUSED"
        return 1
    fi

    local runner_temp epoch_path
    runner_temp="${RUNNER_TEMP:-}"
    epoch_path="$runner_temp/$PRIME_CANARY_EPOCH_LEAF"
    if ! prime_canary_validate_epoch "$epoch_path"; then
        prime_canary_refuse "EPOCH_REFUSED"
        return 1
    fi
    if ! prime_canary_cutoff_valid; then
        prime_canary_refuse "PREINVOCATION_CUTOFF"
        return 1
    fi
    if ! prime_canary_validate_platform; then
        prime_canary_refuse "PLATFORM_REFUSED"
        return 1
    fi
    local runner_temp_physical
    runner_temp_physical="$(prime_canary_physical_directory "$runner_temp")" || {
        prime_canary_refuse "MIRROR_REFUSED"
        return 1
    }
    if [[ "$runner_temp_physical" != "$runner_temp" ]]; then
        prime_canary_refuse "MIRROR_REFUSED"
        return 1
    fi
    if ! prime_canary_create_swiftpm_roots "$runner_temp"; then
        prime_canary_refuse "SWIFTPM_ROOT_REFUSED"
        return 1
    fi
    if ! prime_canary_validate_mirrors "$runner_temp"; then
        prime_canary_refuse "MIRROR_REFUSED"
        return 1
    fi

    local package_path package_argument expected_package_path
    package_argument="Tests/PrimeValidationWorkflow"
    package_path="$repository/$package_argument"
    expected_package_path="${GITHUB_WORKSPACE:-}/ergentics-prime/Tests/PrimeValidationWorkflow"
    if [[ "$package_path" != "$expected_package_path" \
        || "$(prime_canary_physical_directory "$package_path")" != "$package_path" ]]; then
        prime_canary_refuse "ADAPTER_IDENTITY_REFUSED"
        return 1
    fi
    local bin_path
    bin_path="$(prime_canary_build_products "$package_argument" "$runner_temp")" || {
        prime_canary_refuse "BUILD_REFUSED"
        return 1
    }
    prime_canary_bind_executables "$bin_path"
    local bind_status="$?"
    exec 7<&- 8<&- 2>/dev/null || true
    if [[ "$bind_status" == "2" ]]; then
        prime_canary_refuse "PIN_MISMATCH"
        return 1
    elif [[ "$bind_status" != "0" ]]; then
        prime_canary_refuse "ADAPTER_IDENTITY_REFUSED"
        return 1
    fi

    if ! prime_canary_create_capture "$runner_temp"; then
        if [[ "$prime_canary_capture_root_owned" == "true" ]]; then
            prime_canary_refuse_after_capture "CAPTURE_SETUP_REFUSED"
        else
            prime_canary_refuse "CAPTURE_SETUP_REFUSED"
        fi
        return 1
    fi
    if ! prime_canary_close_adapter_environment "$runner_temp"; then
        prime_canary_refuse_after_capture "INVOCATION_ADMISSION_REFUSED"
        return 1
    fi
    if ! prime_canary_revalidate_epoch "$epoch_path"; then
        exec 9<&- 2>/dev/null || true
        prime_canary_refuse_after_capture "EPOCH_REFUSED"
        return 1
    fi
    if ! prime_canary_cutoff_valid; then
        exec 9<&- 2>/dev/null || true
        prime_canary_refuse_after_capture "PREINVOCATION_CUTOFF"
        return 1
    fi
    if ! prime_canary_revalidate_executables; then
        exec 7<&- 8<&- 9<&- 2>/dev/null || true
        prime_canary_refuse_after_capture "ADAPTER_IDENTITY_REFUSED"
        return 1
    fi
    if ! ulimit -f 128; then
        exec 7<&- 8<&- 9<&- 2>/dev/null || true
        prime_canary_refuse_after_capture "CAPTURE_SETUP_REFUSED"
        return 1
    fi

    prime_canary_projection_ready=false
    prime_canary_stream_measurements_complete=false
    prime_canary_cleanup_attempt_complete=false
    prime_canary_attempt_consumed=true
    "$prime_canary_adapter_path" "$prime_canary_fixture_path" \
        </dev/null >"$prime_canary_stdout_path" 2>"$prime_canary_stderr_path" \
        3>&- 7<&- 8<&- 9<&-
    prime_canary_shell_status="$?"
    prime_canary_command_state="shell_command_returned"
    exec 7<&- 8<&- 9<&- 2>/dev/null || true
    if ! prime_canary_measure_streams; then
        prime_canary_cleanup_capture || true
        return 1
    fi
    if ! prime_canary_stream_measurements_still_match; then
        prime_canary_stream_measurements_complete=false
        prime_canary_execution_observation="unavailable"
        prime_canary_cleanup_capture || true
        return 1
    fi
    local result_code
    result_code="$(prime_canary_classify_observation \
        "$prime_canary_shell_status" \
        "$prime_canary_stdout_count" \
        "$prime_canary_stdout_sha" \
        "$prime_canary_stdout_cap_reached" \
        "$prime_canary_stderr_path" \
        "$prime_canary_stderr_count" \
        "$prime_canary_stderr_cap_reached")" || {
        if ! prime_canary_stream_measurements_still_match; then
            prime_canary_stream_measurements_complete=false
        fi
        prime_canary_cleanup_capture || true
        prime_canary_execution_observation="unavailable"
        prime_canary_projection_ready=true
        return 1
    }
    if ! prime_canary_stream_measurements_still_match; then
        prime_canary_stream_measurements_complete=false
        prime_canary_execution_observation="unavailable"
        prime_canary_cleanup_capture || true
        return 1
    fi
    prime_canary_classification_complete=true
    prime_canary_classified_result_code="$result_code"
    case "$result_code" in
        PASS|ADAPTER_REPORTED_FAILURE|LAYER_A_FAIL_STOP_REPORTED)
            prime_canary_execution_observation="observed_true"
            ;;
        *)
            prime_canary_execution_observation="unavailable"
            ;;
    esac
    prime_canary_cleanup_capture || true
    if [[ "$result_code" == "PASS" \
        && "$prime_canary_cleanup_absence" != "observed_true" ]]; then
        result_code="CAPTURE_CLEANUP_FAILED"
    fi
    prime_canary_projection_ready=true
    prime_canary_emit_record "$result_code" || return 1
    [[ "$result_code" == "PASS" ]]
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    prime_canary_main "$@"
fi
