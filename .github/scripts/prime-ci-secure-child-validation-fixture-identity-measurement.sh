#!/bin/bash -p

# One closed, native repeat-build measurement authorized by
# PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityV1. This file
# accepts no caller command surface, never launches the measured fixture, and
# retains no durable artifact. Every launcher-controlled outcome is projected
# once and irrevocably retires this measurement opportunity.

readonly PRIME_MEASUREMENT_AUTHORITY_ID="ergentics_prime_secure_child_validation_fixture_identity_measurement_authority_v1"
readonly PRIME_MEASUREMENT_AUTHORITY_SHA256="67ad7808b54314b7dcd70a86b5504e7321c4c348a0ecb2ec172d5b72ee3f6d43"
readonly PRIME_MEASUREMENT_AUTHORITY_CLOSURE_REVISION="fe0ad36a9163aaa0e03478f5556dfb34b70e24e7"
readonly PRIME_MEASUREMENT_AUTHORITY_CLOSURE_TREE="9b8a784e605967141f159a5f8c953a0096cf1f8d"
readonly PRIME_MEASUREMENT_SCHEMA_ID="prime_secure_child_validation_fixture_identity_measurement_outer_observation_v1"
readonly PRIME_MEASUREMENT_RECORD_PREFIX="prime-secure-child validation-fixture-identity measurement: "
readonly PRIME_MEASUREMENT_PRIVATE_BASE_LEAF="prime-secure-child-validation-fixture-identity-measurement-root-v1"
readonly PRIME_MEASUREMENT_SOURCE_A_LEAF="exact-tree-source-a-v1"
readonly PRIME_MEASUREMENT_SOURCE_B_LEAF="exact-tree-source-b-v1"
readonly PRIME_MEASUREMENT_BUILD_A_LEAF="fixture-build-root-set-a-v1"
readonly PRIME_MEASUREMENT_BUILD_B_LEAF="fixture-build-root-set-b-v1"
readonly PRIME_MEASUREMENT_EVALUATOR_ROOT_LEAF="prime-secure-child-validation-fixture-identity-evaluator-root-v1"
readonly PRIME_MEASUREMENT_EVALUATOR_LEAF="prime-secure-child-validation-fixture-identity-evaluator-v1"
readonly PRIME_MEASUREMENT_EVALUATOR_SOURCE="Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift"
readonly PRIME_MEASUREMENT_EVALUATOR_SOURCE_GIT_BLOB="ead815d5f051ed1308f360aa701a1a5d389556c6"
readonly PRIME_MEASUREMENT_EVALUATOR_SOURCE_BYTE_COUNT="16967"
readonly PRIME_MEASUREMENT_EVALUATOR_SOURCE_SHA256="248ae56786dace0e7b19a9a82ee977b9a4fa705a63b9268e2ee058c180ddaa82"
readonly PRIME_MEASUREMENT_FIXTURE_PRODUCT="PrimeValidationWorkflowFixtureChild"
readonly PRIME_MEASUREMENT_FIXTURE_LEAF="PrimeValidationWorkflowFixtureChild"
readonly PRIME_MEASUREMENT_CURRENT_PIN_BYTE_COUNT="89632"
readonly PRIME_MEASUREMENT_CURRENT_PIN_SHA256="eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd"
readonly PRIME_MEASUREMENT_MLX_REVISION="d37885a278f1c37484a94d0f401a418735e66519"
readonly PRIME_MEASUREMENT_NUMERICS_REVISION="0c0290ff6b24942dadb83a929ffaaa1481df04a2"
readonly PRIME_MEASUREMENT_MLX_ORIGIN="https://github.com/Ergentics/ergentics-mlx-swift"
readonly PRIME_MEASUREMENT_NUMERICS_ORIGIN="https://github.com/apple/swift-numerics"
readonly PRIME_MEASUREMENT_MAX_FIXTURE_BYTES="4194304"
readonly PRIME_MEASUREMENT_MAX_SHOW_BIN_BYTES="1024"
readonly PRIME_MEASUREMENT_SHOW_BIN_READER_BYTES="1025"
readonly PRIME_MEASUREMENT_MAX_SHOW_BIN_CAPTURE_BYTES="4830"
readonly PRIME_MEASUREMENT_MAX_EVALUATOR_BYTES="2048"
readonly PRIME_MEASUREMENT_EVALUATOR_READER_BYTES="2049"
readonly PRIME_MEASUREMENT_MAX_EVALUATOR_CAPTURE_BYTES="9566"
readonly PRIME_MEASUREMENT_MAX_JSON_BYTES="4035"
readonly PRIME_MEASUREMENT_MAX_LINE_BYTES="4096"

prime_measurement_is_git_sha() {
    [[ "$1" =~ ^[0-9a-f]{40}$ ]]
}

prime_measurement_is_sha256() {
    [[ "$1" =~ ^[0-9a-f]{64}$ ]]
}

prime_measurement_is_hex32() {
    [[ "$1" =~ ^[0-9a-f]{32}$ ]]
}

prime_measurement_is_nonnegative_integer() {
    [[ "$1" =~ ^(0|[1-9][0-9]*)$ ]]
}

prime_measurement_integer_at_most() {
    local value="$1"
    local maximum="$2"
    local LC_ALL=C
    prime_measurement_is_nonnegative_integer "$value" || return 1
    prime_measurement_is_nonnegative_integer "$maximum" || return 1
    if [[ "${#value}" -lt "${#maximum}" ]]; then
        return 0
    fi
    if [[ "${#value}" -gt "${#maximum}" ]]; then
        return 1
    fi
    [[ "$value" == "$maximum" || "$value" < "$maximum" ]]
}

prime_measurement_mode_has_owner_execute() {
    local mode="$1"
    [[ "$mode" =~ ^[0-7]{3,4}$ ]] || return 1
    (( (8#$mode & 0100) != 0 ))
}

prime_measurement_is_command_state() {
    case "$1" in
        not_attempted|succeeded|failed|unavailable) return 0 ;;
        *) return 1 ;;
    esac
}

prime_measurement_is_observation_state() {
    case "$1" in
        observed_false|observed_true|unavailable) return 0 ;;
        *) return 1 ;;
    esac
}

prime_measurement_is_comparison_state() {
    case "$1" in
        false|true|unavailable) return 0 ;;
        *) return 1 ;;
    esac
}

prime_measurement_is_result_code() {
    case "$1" in
        PASS_IDENTICAL_CURRENT_PIN|PASS_IDENTICAL_DIFFERENT_PIN|\
        NONDETERMINISTIC_BUILD|INVOCATION_ADMISSION_REFUSED|\
        MEASUREMENT_ROOT_REFUSED|SOURCE_ROOT_REFUSED|BUILD_ROOT_REFUSED|\
        MIRROR_REFUSED|BUILD_A_REFUSED|SHOW_BIN_A_REFUSED|\
        SHOW_BIN_A_TRANSPORT_REFUSED|ARTIFACT_A_ADMISSION_REFUSED|\
        BUILD_B_REFUSED|SHOW_BIN_B_REFUSED|SHOW_BIN_B_TRANSPORT_REFUSED|\
        ARTIFACT_B_ADMISSION_REFUSED|EVALUATOR_ROOT_REFUSED|\
        EVALUATOR_SOURCE_REFUSED|EVALUATOR_COMPILE_REFUSED|\
        EVALUATOR_ADMISSION_REFUSED|EVALUATOR_TRANSPORT_REFUSED|\
        EVALUATOR_COMMAND_REFUSED|EVALUATOR_CONTRACT_REFUSED|\
        CAPTURE_REFUSED|UNCLASSIFIED)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

prime_measurement_initialize_state() {
    prime_measurement_record_projected=false
    prime_measurement_attempt_consumed=false
    prime_measurement_build_a_state="not_attempted"
    prime_measurement_show_a_state="not_attempted"
    prime_measurement_build_b_state="not_attempted"
    prime_measurement_show_b_state="not_attempted"
    prime_measurement_compile_state="not_attempted"
    prime_measurement_evaluator_state="not_attempted"
    prime_measurement_evaluator_observation="observed_false"
    prime_measurement_evaluator_wait="null"
    prime_measurement_fixture_a_count="null"
    prime_measurement_fixture_a_sha="null"
    prime_measurement_fixture_a_uuid="null"
    prime_measurement_fixture_a_platform="null"
    prime_measurement_fixture_a_minos="null"
    prime_measurement_fixture_a_sdk="null"
    prime_measurement_fixture_b_count="null"
    prime_measurement_fixture_b_sha="null"
    prime_measurement_fixture_b_uuid="null"
    prime_measurement_fixture_b_platform="null"
    prime_measurement_fixture_b_minos="null"
    prime_measurement_fixture_b_sdk="null"
    prime_measurement_byte_count_equal="unavailable"
    prime_measurement_sha256_equal="unavailable"
    prime_measurement_full_bytes_equal="unavailable"
    prime_measurement_macho_identity_equal="unavailable"
    prime_measurement_pin_byte_count_match="unavailable"
    prime_measurement_pin_sha256_match="unavailable"
    prime_measurement_pin_full_match="unavailable"
    prime_measurement_registered_root_tuples=""
}

prime_measurement_identity_fields_are_null() {
    [[ "$prime_measurement_fixture_a_count" == "null" \
        && "$prime_measurement_fixture_a_sha" == "null" \
        && "$prime_measurement_fixture_a_uuid" == "null" \
        && "$prime_measurement_fixture_a_platform" == "null" \
        && "$prime_measurement_fixture_a_minos" == "null" \
        && "$prime_measurement_fixture_a_sdk" == "null" \
        && "$prime_measurement_fixture_b_count" == "null" \
        && "$prime_measurement_fixture_b_sha" == "null" \
        && "$prime_measurement_fixture_b_uuid" == "null" \
        && "$prime_measurement_fixture_b_platform" == "null" \
        && "$prime_measurement_fixture_b_minos" == "null" \
        && "$prime_measurement_fixture_b_sdk" == "null" ]]
}

prime_measurement_comparisons_are_unavailable() {
    [[ "$prime_measurement_byte_count_equal" == "unavailable" \
        && "$prime_measurement_sha256_equal" == "unavailable" \
        && "$prime_measurement_full_bytes_equal" == "unavailable" \
        && "$prime_measurement_macho_identity_equal" == "unavailable" \
        && "$prime_measurement_pin_byte_count_match" == "unavailable" \
        && "$prime_measurement_pin_sha256_match" == "unavailable" \
        && "$prime_measurement_pin_full_match" == "unavailable" ]]
}

prime_measurement_complete_identity_valid() {
    prime_measurement_integer_at_most "$prime_measurement_fixture_a_count" \
        "$PRIME_MEASUREMENT_MAX_FIXTURE_BYTES" || return 1
    [[ "$prime_measurement_fixture_a_count" != "0" ]] || return 1
    prime_measurement_is_sha256 "$prime_measurement_fixture_a_sha" || return 1
    prime_measurement_is_hex32 "$prime_measurement_fixture_a_uuid" || return 1
    [[ "$prime_measurement_fixture_a_platform" == "1" ]] || return 1
    prime_measurement_integer_at_most "$prime_measurement_fixture_a_minos" "4294967295" || return 1
    prime_measurement_integer_at_most "$prime_measurement_fixture_a_sdk" "4294967295" || return 1
    prime_measurement_integer_at_most "$prime_measurement_fixture_b_count" \
        "$PRIME_MEASUREMENT_MAX_FIXTURE_BYTES" || return 1
    [[ "$prime_measurement_fixture_b_count" != "0" ]] || return 1
    prime_measurement_is_sha256 "$prime_measurement_fixture_b_sha" || return 1
    prime_measurement_is_hex32 "$prime_measurement_fixture_b_uuid" || return 1
    [[ "$prime_measurement_fixture_b_platform" == "1" ]] || return 1
    prime_measurement_integer_at_most "$prime_measurement_fixture_b_minos" "4294967295" || return 1
    prime_measurement_integer_at_most "$prime_measurement_fixture_b_sdk" "4294967295"
}

prime_measurement_result_invariant_matches() {
    local result_code="$1"
    prime_measurement_is_result_code "$result_code" || return 1
    prime_measurement_is_command_state "$prime_measurement_build_a_state" || return 1
    prime_measurement_is_command_state "$prime_measurement_show_a_state" || return 1
    prime_measurement_is_command_state "$prime_measurement_build_b_state" || return 1
    prime_measurement_is_command_state "$prime_measurement_show_b_state" || return 1
    prime_measurement_is_command_state "$prime_measurement_compile_state" || return 1
    prime_measurement_is_command_state "$prime_measurement_evaluator_state" || return 1
    prime_measurement_is_observation_state "$prime_measurement_evaluator_observation" || return 1
    prime_measurement_is_comparison_state "$prime_measurement_byte_count_equal" || return 1
    prime_measurement_is_comparison_state "$prime_measurement_sha256_equal" || return 1
    prime_measurement_is_comparison_state "$prime_measurement_full_bytes_equal" || return 1
    prime_measurement_is_comparison_state "$prime_measurement_macho_identity_equal" || return 1
    prime_measurement_is_comparison_state "$prime_measurement_pin_byte_count_match" || return 1
    prime_measurement_is_comparison_state "$prime_measurement_pin_sha256_match" || return 1
    prime_measurement_is_comparison_state "$prime_measurement_pin_full_match" || return 1
    if [[ "$prime_measurement_evaluator_wait" != "null" ]]; then
        prime_measurement_integer_at_most "$prime_measurement_evaluator_wait" "255" || return 1
    fi

    local expected_consumed="false"
    local expected_build_a="not_attempted"
    local expected_show_a="not_attempted"
    local expected_build_b="not_attempted"
    local expected_show_b="not_attempted"
    local expected_compile="not_attempted"
    local expected_evaluator="not_attempted"
    local expected_observation="observed_false"
    local expected_wait="null"
    case "$result_code" in
        PASS_IDENTICAL_CURRENT_PIN|PASS_IDENTICAL_DIFFERENT_PIN|\
        NONDETERMINISTIC_BUILD|EVALUATOR_CONTRACT_REFUSED|CAPTURE_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            expected_build_b="succeeded"
            expected_show_b="succeeded"
            expected_compile="succeeded"
            expected_evaluator="succeeded"
            expected_observation="observed_true"
            expected_wait="0"
            ;;
        INVOCATION_ADMISSION_REFUSED|MEASUREMENT_ROOT_REFUSED|\
        SOURCE_ROOT_REFUSED|BUILD_ROOT_REFUSED|MIRROR_REFUSED|UNCLASSIFIED)
            ;;
        BUILD_A_REFUSED)
            expected_consumed="true"
            expected_build_a="failed"
            ;;
        SHOW_BIN_A_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="failed"
            ;;
        SHOW_BIN_A_TRANSPORT_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="unavailable"
            ;;
        ARTIFACT_A_ADMISSION_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            ;;
        BUILD_B_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            expected_build_b="failed"
            ;;
        SHOW_BIN_B_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            expected_build_b="succeeded"
            expected_show_b="failed"
            ;;
        SHOW_BIN_B_TRANSPORT_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            expected_build_b="succeeded"
            expected_show_b="unavailable"
            ;;
        ARTIFACT_B_ADMISSION_REFUSED|EVALUATOR_ROOT_REFUSED|\
        EVALUATOR_SOURCE_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            expected_build_b="succeeded"
            expected_show_b="succeeded"
            ;;
        EVALUATOR_COMPILE_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            expected_build_b="succeeded"
            expected_show_b="succeeded"
            expected_compile="failed"
            ;;
        EVALUATOR_ADMISSION_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            expected_build_b="succeeded"
            expected_show_b="succeeded"
            expected_compile="succeeded"
            ;;
        EVALUATOR_TRANSPORT_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            expected_build_b="succeeded"
            expected_show_b="succeeded"
            expected_compile="succeeded"
            expected_evaluator="unavailable"
            expected_observation="unavailable"
            ;;
        EVALUATOR_COMMAND_REFUSED)
            expected_consumed="true"
            expected_build_a="succeeded"
            expected_show_a="succeeded"
            expected_build_b="succeeded"
            expected_show_b="succeeded"
            expected_compile="succeeded"
            expected_evaluator="failed"
            expected_observation="unavailable"
            expected_wait="$prime_measurement_evaluator_wait"
            [[ "$expected_wait" != "null" && "$expected_wait" != "0" ]] || return 1
            ;;
    esac
    [[ "$prime_measurement_attempt_consumed" == "$expected_consumed" \
        && "$prime_measurement_build_a_state" == "$expected_build_a" \
        && "$prime_measurement_show_a_state" == "$expected_show_a" \
        && "$prime_measurement_build_b_state" == "$expected_build_b" \
        && "$prime_measurement_show_b_state" == "$expected_show_b" \
        && "$prime_measurement_compile_state" == "$expected_compile" \
        && "$prime_measurement_evaluator_state" == "$expected_evaluator" \
        && "$prime_measurement_evaluator_observation" == "$expected_observation" \
        && "$prime_measurement_evaluator_wait" == "$expected_wait" ]] || return 1

    case "$result_code" in
        PASS_IDENTICAL_CURRENT_PIN)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "succeeded" \
                && "$prime_measurement_compile_state" == "succeeded" \
                && "$prime_measurement_evaluator_state" == "succeeded" \
                && "$prime_measurement_evaluator_observation" == "observed_true" \
                && "$prime_measurement_evaluator_wait" == "0" \
                && "$prime_measurement_byte_count_equal" == "true" \
                && "$prime_measurement_sha256_equal" == "true" \
                && "$prime_measurement_full_bytes_equal" == "true" \
                && "$prime_measurement_macho_identity_equal" == "true" \
                && "$prime_measurement_pin_byte_count_match" == "true" \
                && "$prime_measurement_pin_sha256_match" == "true" \
                && "$prime_measurement_pin_full_match" == "true" ]] || return 1
            prime_measurement_complete_identity_valid
            ;;
        PASS_IDENTICAL_DIFFERENT_PIN)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "succeeded" \
                && "$prime_measurement_compile_state" == "succeeded" \
                && "$prime_measurement_evaluator_state" == "succeeded" \
                && "$prime_measurement_evaluator_observation" == "observed_true" \
                && "$prime_measurement_evaluator_wait" == "0" \
                && "$prime_measurement_byte_count_equal" == "true" \
                && "$prime_measurement_sha256_equal" == "true" \
                && "$prime_measurement_full_bytes_equal" == "true" \
                && "$prime_measurement_macho_identity_equal" == "true" \
                && "$prime_measurement_pin_full_match" == "false" \
                && "$prime_measurement_pin_byte_count_match" != "unavailable" \
                && "$prime_measurement_pin_sha256_match" != "unavailable" \
                && ( "$prime_measurement_pin_byte_count_match" == "false" \
                    || "$prime_measurement_pin_sha256_match" == "false" ) ]] || return 1
            prime_measurement_complete_identity_valid
            ;;
        NONDETERMINISTIC_BUILD)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "succeeded" \
                && "$prime_measurement_compile_state" == "succeeded" \
                && "$prime_measurement_evaluator_state" == "succeeded" \
                && "$prime_measurement_evaluator_observation" == "observed_true" \
                && "$prime_measurement_evaluator_wait" == "0" \
                && "$prime_measurement_full_bytes_equal" == "false" \
                && "$prime_measurement_byte_count_equal" != "unavailable" \
                && "$prime_measurement_sha256_equal" != "unavailable" \
                && "$prime_measurement_macho_identity_equal" != "unavailable" \
                && "$prime_measurement_pin_byte_count_match" == "unavailable" \
                && "$prime_measurement_pin_sha256_match" == "unavailable" \
                && "$prime_measurement_pin_full_match" == "unavailable" ]] || return 1
            prime_measurement_complete_identity_valid
            ;;
        INVOCATION_ADMISSION_REFUSED|MEASUREMENT_ROOT_REFUSED|\
        SOURCE_ROOT_REFUSED|BUILD_ROOT_REFUSED|MIRROR_REFUSED|UNCLASSIFIED)
            [[ "$prime_measurement_attempt_consumed" == "false" \
                && "$prime_measurement_build_a_state" == "not_attempted" \
                && "$prime_measurement_show_a_state" == "not_attempted" \
                && "$prime_measurement_build_b_state" == "not_attempted" \
                && "$prime_measurement_show_b_state" == "not_attempted" \
                && "$prime_measurement_compile_state" == "not_attempted" \
                && "$prime_measurement_evaluator_state" == "not_attempted" \
                && "$prime_measurement_evaluator_observation" == "observed_false" \
                && "$prime_measurement_evaluator_wait" == "null" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        BUILD_A_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "failed" \
                && "$prime_measurement_show_a_state" == "not_attempted" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        SHOW_BIN_A_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "failed" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        SHOW_BIN_A_TRANSPORT_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "unavailable" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        ARTIFACT_A_ADMISSION_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "not_attempted" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        BUILD_B_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "failed" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        SHOW_BIN_B_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "failed" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        SHOW_BIN_B_TRANSPORT_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "unavailable" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        ARTIFACT_B_ADMISSION_REFUSED|EVALUATOR_ROOT_REFUSED|\
        EVALUATOR_SOURCE_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "succeeded" \
                && "$prime_measurement_compile_state" == "not_attempted" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        EVALUATOR_COMPILE_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "succeeded" \
                && "$prime_measurement_compile_state" == "failed" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        EVALUATOR_ADMISSION_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "succeeded" \
                && "$prime_measurement_compile_state" == "succeeded" \
                && "$prime_measurement_evaluator_state" == "not_attempted" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        EVALUATOR_TRANSPORT_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "succeeded" \
                && "$prime_measurement_compile_state" == "succeeded" \
                && "$prime_measurement_evaluator_state" == "unavailable" \
                && "$prime_measurement_evaluator_observation" == "unavailable" \
                && "$prime_measurement_evaluator_wait" == "null" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        EVALUATOR_COMMAND_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "succeeded" \
                && "$prime_measurement_compile_state" == "succeeded" \
                && "$prime_measurement_evaluator_state" == "failed" \
                && "$prime_measurement_evaluator_observation" == "unavailable" \
                && "$prime_measurement_evaluator_wait" != "null" \
                && "$prime_measurement_evaluator_wait" != "0" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
        EVALUATOR_CONTRACT_REFUSED|CAPTURE_REFUSED)
            [[ "$prime_measurement_attempt_consumed" == "true" \
                && "$prime_measurement_build_a_state" == "succeeded" \
                && "$prime_measurement_show_a_state" == "succeeded" \
                && "$prime_measurement_build_b_state" == "succeeded" \
                && "$prime_measurement_show_b_state" == "succeeded" \
                && "$prime_measurement_compile_state" == "succeeded" \
                && "$prime_measurement_evaluator_state" == "succeeded" \
                && "$prime_measurement_evaluator_observation" == "observed_true" \
                && "$prime_measurement_evaluator_wait" == "0" ]] || return 1
            prime_measurement_identity_fields_are_null \
                && prime_measurement_comparisons_are_unavailable
            ;;
    esac
}

prime_measurement_json_nullable_string() {
    if [[ "$1" == "null" ]]; then
        prime_measurement_json_value="null"
    else
        prime_measurement_json_value="\"$1\""
    fi
}

prime_measurement_project_and_exit() {
    local result_code="$1"
    local exit_status="1"
    prime_measurement_result_invariant_matches "$result_code" || {
        if [[ "$prime_measurement_attempt_consumed" == "false" ]]; then
            prime_measurement_initialize_state
            result_code="UNCLASSIFIED"
            prime_measurement_result_invariant_matches "$result_code" || exit 1
        else
            exit 1
        fi
    }
    case "$result_code" in
        PASS_IDENTICAL_CURRENT_PIN|PASS_IDENTICAL_DIFFERENT_PIN) exit_status="0" ;;
    esac
    local fixture_a_sha_json fixture_a_uuid_json fixture_b_sha_json fixture_b_uuid_json
    prime_measurement_json_nullable_string "$prime_measurement_fixture_a_sha"
    fixture_a_sha_json="$prime_measurement_json_value"
    prime_measurement_json_nullable_string "$prime_measurement_fixture_a_uuid"
    fixture_a_uuid_json="$prime_measurement_json_value"
    prime_measurement_json_nullable_string "$prime_measurement_fixture_b_sha"
    fixture_b_sha_json="$prime_measurement_json_value"
    prime_measurement_json_nullable_string "$prime_measurement_fixture_b_uuid"
    fixture_b_uuid_json="$prime_measurement_json_value"
    local json
    json="{\"actions_artifact\":false"
    json+=",\"authority_canonical_sha256\":\"$PRIME_MEASUREMENT_AUTHORITY_SHA256\""
    json+=",\"authority_id\":\"$PRIME_MEASUREMENT_AUTHORITY_ID\""
    json+=",\"build_a_command_state\":\"$prime_measurement_build_a_state\""
    json+=",\"build_b_command_state\":\"$prime_measurement_build_b_state\""
    json+=",\"byte_count_equal\":\"$prime_measurement_byte_count_equal\""
    json+=",\"canary_execution_performed\":false"
    json+=",\"current_pin_byte_count_match\":\"$prime_measurement_pin_byte_count_match\""
    json+=",\"current_pin_full_match\":\"$prime_measurement_pin_full_match\""
    json+=",\"current_pin_sha256_match\":\"$prime_measurement_pin_sha256_match\""
    json+=",\"durable_evidence\":false"
    json+=",\"evaluator_command_state\":\"$prime_measurement_evaluator_state\""
    json+=",\"evaluator_compile_state\":\"$prime_measurement_compile_state\""
    json+=",\"evaluator_execution_observation\":\"$prime_measurement_evaluator_observation\""
    json+=",\"evaluator_shell_wait_status\":$prime_measurement_evaluator_wait"
    json+=",\"exact_revision\":\"$prime_measurement_exact_revision\""
    json+=",\"fixture_a_build_platform_packed\":$prime_measurement_fixture_a_platform"
    json+=",\"fixture_a_byte_count\":$prime_measurement_fixture_a_count"
    json+=",\"fixture_a_macho_uuid\":$fixture_a_uuid_json"
    json+=",\"fixture_a_minimum_os_packed\":$prime_measurement_fixture_a_minos"
    json+=",\"fixture_a_sdk_packed\":$prime_measurement_fixture_a_sdk"
    json+=",\"fixture_a_sha256\":$fixture_a_sha_json"
    json+=",\"fixture_b_build_platform_packed\":$prime_measurement_fixture_b_platform"
    json+=",\"fixture_b_byte_count\":$prime_measurement_fixture_b_count"
    json+=",\"fixture_b_macho_uuid\":$fixture_b_uuid_json"
    json+=",\"fixture_b_minimum_os_packed\":$prime_measurement_fixture_b_minos"
    json+=",\"fixture_b_sdk_packed\":$prime_measurement_fixture_b_sdk"
    json+=",\"fixture_b_sha256\":$fixture_b_sha_json"
    json+=",\"fixture_execution_count\":0"
    json+=",\"full_bytes_equal\":\"$prime_measurement_full_bytes_equal\""
    json+=",\"macho_identity_equal\":\"$prime_measurement_macho_identity_equal\""
    json+=",\"measurement_attempt_consumed\":$prime_measurement_attempt_consumed"
    json+=",\"opportunity_state\":\"retired\""
    json+=",\"pin_mutation_performed\":false"
    json+=",\"raw_build_output_or_error_field_count\":0"
    json+=",\"raw_path_count\":0"
    json+=",\"result_code\":\"$result_code\""
    json+=",\"schema_id\":\"$PRIME_MEASUREMENT_SCHEMA_ID\""
    json+=",\"schema_version\":1"
    json+=",\"scientific_outcome\":\"not_established\""
    json+=",\"sha256_equal\":\"$prime_measurement_sha256_equal\""
    json+=",\"show_bin_a_command_state\":\"$prime_measurement_show_a_state\""
    json+=",\"show_bin_b_command_state\":\"$prime_measurement_show_b_state\"}"
    [[ "$json" != *$'\n'* && "$json" != *$'\r'* \
        && "${#json}" -le "$PRIME_MEASUREMENT_MAX_JSON_BYTES" \
        && "${#PRIME_MEASUREMENT_RECORD_PREFIX}" == "60" \
        && $((${#PRIME_MEASUREMENT_RECORD_PREFIX} + ${#json} + 1)) \
            -le "$PRIME_MEASUREMENT_MAX_LINE_BYTES" ]] || exit 1
    prime_measurement_record_projected=true
    trap - EXIT
    builtin printf '%s%s\n' "$PRIME_MEASUREMENT_RECORD_PREFIX" "$json" >&3
    exit "$exit_status"
}

prime_measurement_unexpected_exit() {
    local original_status="$?"
    trap - EXIT
    exec 9<&- 8<&- 2>/dev/null || true
    if [[ "${prime_measurement_record_projected:-false}" != "true" \
        && "${prime_measurement_attempt_consumed:-true}" == "false" \
        && "${prime_measurement_exact_revision:-}" =~ ^[0-9a-f]{40}$ ]]; then
        prime_measurement_initialize_state
        prime_measurement_project_and_exit "UNCLASSIFIED"
    fi
    exit "$original_status"
}

prime_measurement_physical_directory_is_exact() {
    local path="$1"
    [[ "$path" == /* && -d "$path" && ! -L "$path" ]] || return 1
    (cd "$path" 2>/dev/null && [[ "$(pwd -P)" == "$path" ]])
}

prime_measurement_register_directory_join() {
    local path="$1"
    local required_mode="$2"
    local required_device="$3"
    local descriptor_metadata name_metadata descriptor_status name_status
    prime_measurement_physical_directory_is_exact "$path" || return 1
    exec 9< "$path" || return 1
    descriptor_metadata="$(LC_ALL=C /usr/bin/stat -f '%d:%i:%u:%Lp' \
        <&9 9<&- 2>/dev/null)"
    descriptor_status="$?"
    exec 9<&- || return 1
    name_metadata="$(LC_ALL=C /usr/bin/stat -f '%d:%i:%u:%Lp' -- "$path" 2>/dev/null)"
    name_status="$?"
    [[ "$descriptor_status" == "0" && "$name_status" == "0" \
        && "${#descriptor_metadata}" -le "57" \
        && "${#name_metadata}" -le "57" \
        && "$descriptor_metadata" == "$name_metadata" \
        && "$descriptor_metadata" \
            =~ ^(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,9}):([0-7]{3,4})$ ]] || return 1
    local device="${BASH_REMATCH[1]}"
    local inode="${BASH_REMATCH[2]}"
    local owner="${BASH_REMATCH[3]}"
    local mode="${BASH_REMATCH[4]}"
    prime_measurement_integer_at_most "$device" "18446744073709551615" || return 1
    prime_measurement_integer_at_most "$inode" "18446744073709551615" || return 1
    prime_measurement_integer_at_most "$owner" "4294967295" || return 1
    [[ "$owner" == "$EUID" ]] || return 1
    if [[ "$required_mode" != "any" ]]; then
        [[ "$mode" == "$required_mode" ]] || return 1
    fi
    if [[ "$required_device" != "any" ]]; then
        [[ "$device" == "$required_device" ]] || return 1
    fi
    local tuple="$device:$inode"
    if [[ -n "$prime_measurement_registered_root_tuples" ]]; then
        while IFS= read -r registered_tuple; do
            [[ "$tuple" != "$registered_tuple" ]] || return 1
        done <<< "$prime_measurement_registered_root_tuples"
        prime_measurement_registered_root_tuples+=$'\n'
    fi
    prime_measurement_registered_root_tuples+="$tuple"
    prime_measurement_admitted_device="$device"
    prime_measurement_admitted_inode="$inode"
}

prime_measurement_create_directory() {
    local path="$1"
    [[ ! -e "$path" && ! -L "$path" ]] || return 1
    (umask 0077; /bin/mkdir "$path") >/dev/null 2>&1
}

prime_measurement_single_component_leaf() {
    [[ -n "$1" && "$1" != "." && "$1" != ".." && "$1" != */* ]]
}

prime_measurement_admit_null_device() {
    [[ -c /dev/null && ! -L /dev/null ]] || return 1
    local descriptor_metadata name_metadata descriptor_status name_status
    exec 8<> /dev/null || return 1
    descriptor_metadata="$(LC_ALL=C /usr/bin/stat -f '%d:%i' \
        <&8 8<&- 2>/dev/null)"
    descriptor_status="$?"
    exec 8<&- 8>&- || return 1
    name_metadata="$(LC_ALL=C /usr/bin/stat -f '%d:%i' -- /dev/null 2>/dev/null)"
    name_status="$?"
    [[ "$descriptor_status" == "0" && "$name_status" == "0" \
        && "$descriptor_metadata" == "$name_metadata" \
        && "$descriptor_metadata" \
            =~ ^(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,19})$ ]]
}

prime_measurement_git_repository_is_clean() {
    local repository="$1"
    /usr/bin/git -C "$repository" diff --quiet --no-ext-diff --no-textconv -- \
        >/dev/null 2>&1 || return 1
    /usr/bin/git -C "$repository" diff --cached --quiet --no-ext-diff --no-textconv -- \
        >/dev/null 2>&1 || return 1
    /usr/bin/git -C "$repository" ls-files --others --exclude-standard -z 2>/dev/null \
        | /usr/bin/grep -q . >/dev/null 2>&1
    local pipeline_status=( "${PIPESTATUS[@]}" )
    [[ "${#pipeline_status[@]}" == "2" \
        && "${pipeline_status[0]}" == "0" \
        && "${pipeline_status[1]}" == "1" ]]
}

prime_measurement_revisions_equal() {
    local repository="$1"
    local lhs="$2"
    local rhs="$3"
    /usr/bin/git -C "$repository" merge-base --is-ancestor "$lhs" "$rhs" \
        >/dev/null 2>&1 || return 1
    /usr/bin/git -C "$repository" merge-base --is-ancestor "$rhs" "$lhs" \
        >/dev/null 2>&1
}

prime_measurement_validate_exact_topology() {
    local repository="$1"
    local revision="$2"
    /usr/bin/git -C "$repository" cat-file -e "$revision^{commit}" \
        >/dev/null 2>&1 || return 1
    prime_measurement_revisions_equal "$repository" "$revision" HEAD || return 1
    /usr/bin/git -C "$repository" symbolic-ref -q HEAD >/dev/null 2>&1
    [[ "$?" == "1" ]] || return 1
    /usr/bin/git -C "$repository" rev-parse --verify "$revision^1^{commit}" \
        >/dev/null 2>&1 || return 1
    /usr/bin/git -C "$repository" rev-parse --verify "$revision^2^{commit}" \
        >/dev/null 2>&1 || return 1
    if /usr/bin/git -C "$repository" rev-parse --verify "$revision^3^{commit}" \
            >/dev/null 2>&1; then
        return 1
    fi
    prime_measurement_revisions_equal "$repository" "$revision^1" \
        "$PRIME_MEASUREMENT_AUTHORITY_CLOSURE_REVISION" || return 1
    prime_measurement_revisions_equal "$repository" "$revision^2^1" \
        "$PRIME_MEASUREMENT_AUTHORITY_CLOSURE_REVISION" || return 1
    if /usr/bin/git -C "$repository" rev-parse --verify "$revision^2^2^{commit}" \
            >/dev/null 2>&1; then
        return 1
    fi
    /usr/bin/git -C "$repository" diff --quiet --no-ext-diff --no-textconv \
        "$revision" "$revision^2" -- >/dev/null 2>&1 || return 1
    /usr/bin/git -C "$repository" cat-file -e \
        "$PRIME_MEASUREMENT_AUTHORITY_CLOSURE_REVISION^{tree}" \
        >/dev/null 2>&1 || return 1
    /usr/bin/git -C "$repository" cat-file -e \
        "$PRIME_MEASUREMENT_AUTHORITY_CLOSURE_TREE^{tree}" \
        >/dev/null 2>&1 || return 1
    /usr/bin/git -C "$repository" diff --quiet --no-ext-diff --no-textconv \
        "$PRIME_MEASUREMENT_AUTHORITY_CLOSURE_REVISION" \
        "$PRIME_MEASUREMENT_AUTHORITY_CLOSURE_TREE" -- \
        >/dev/null 2>&1 || return 1
    local path
    for path in \
        .github/scripts/prime-ci-active-root-quarantine.sh \
        .github/workflows/prime-active-root-quarantine.yml \
        Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift \
        .github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh \
        Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift; do
        /usr/bin/git -C "$repository" diff --quiet --no-ext-diff --no-textconv \
            "$PRIME_MEASUREMENT_AUTHORITY_CLOSURE_REVISION" "$revision" -- "$path" \
            >/dev/null 2>&1
        [[ "$?" == "1" ]] || return 1
    done
    /usr/bin/git -C "$repository" diff --quiet --no-ext-diff --no-textconv \
        "$PRIME_MEASUREMENT_AUTHORITY_CLOSURE_REVISION" "$revision" -- . \
        ':(exclude).github/scripts/prime-ci-active-root-quarantine.sh' \
        ':(exclude).github/workflows/prime-active-root-quarantine.yml' \
        ':(exclude)Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift' \
        ':(exclude).github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh' \
        ':(exclude)Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift' \
        >/dev/null 2>&1 || return 1
    prime_measurement_git_repository_is_clean "$repository"
}

prime_measurement_validate_invocation() {
    local argument_count="$1"
    local repository="$2"
    [[ "$argument_count" == "0" \
        && "${GITHUB_ACTIONS:-}" == "true" \
        && "${GITHUB_REPOSITORY:-}" == "Ergentics/ergentics-prime" \
        && "${GITHUB_EVENT_NAME:-}" == "push" \
        && "${GITHUB_REF:-}" == "refs/heads/main" \
        && "${GITHUB_RUN_ATTEMPT:-}" == "1" \
        && "${GITHUB_JOB:-}" == "trusted-main-compile" \
        && "${GITHUB_SHA:-}" == "$prime_measurement_exact_revision" \
        && "${EXACT_REVISION:-}" == "$prime_measurement_exact_revision" \
        && "${GITHUB_WORKSPACE:-}" == /* \
        && "$repository" == "${GITHUB_WORKSPACE:-}/ergentics-prime" ]] || return 1
    prime_measurement_validate_exact_topology "$repository" \
        "$prime_measurement_exact_revision"
}

prime_measurement_validate_fixed_tools() {
    local executable
    for executable in /usr/bin/git /usr/bin/head /usr/bin/od /usr/bin/stat \
            /usr/bin/env /usr/bin/xcrun /usr/bin/shasum /usr/bin/grep \
            /usr/bin/awk /bin/cat /bin/mkdir /usr/bin/swift; do
        [[ -f "$executable" && ! -L "$executable" && -x "$executable" ]] || return 1
    done
    prime_measurement_admit_null_device
}

prime_measurement_validate_mirror() {
    local path="$1"
    local origin="$2"
    local revision="$3"
    local pinned_revision="$4"
    prime_measurement_physical_directory_is_exact "$path" || return 1
    /usr/bin/git --git-dir="$path" rev-parse --is-bare-repository 2>/dev/null \
        | /usr/bin/grep -qx true >/dev/null 2>&1 || return 1
    /usr/bin/git --git-dir="$path" remote 2>/dev/null \
        | /usr/bin/awk '$0 == "origin" { count += 1 } END { exit !(count == 1 && NR == 1) }' \
            >/dev/null 2>&1 || return 1
    /usr/bin/git --git-dir="$path" remote get-url --all origin 2>/dev/null \
        | /usr/bin/awk -v expected="$origin" \
            '$0 == expected { count += 1 } END { exit !(count == 1 && NR == 1) }' \
            >/dev/null 2>&1 || return 1
    /usr/bin/git --git-dir="$path" cat-file -e "$revision^{commit}" \
        >/dev/null 2>&1 || return 1
    prime_measurement_revisions_equal_bare "$path" "$revision" "$pinned_revision"
}

prime_measurement_revisions_equal_bare() {
    local git_directory="$1"
    local lhs="$2"
    local rhs="$3"
    /usr/bin/git --git-dir="$git_directory" merge-base --is-ancestor "$lhs" "$rhs" \
        >/dev/null 2>&1 || return 1
    /usr/bin/git --git-dir="$git_directory" merge-base --is-ancestor "$rhs" "$lhs" \
        >/dev/null 2>&1
}

prime_measurement_validate_mirrors() {
    prime_measurement_validate_mirror \
        "$prime_measurement_runner_temp/ergentics-mlx-swift.git" \
        "$PRIME_MEASUREMENT_MLX_ORIGIN" \
        "$PRIME_MEASUREMENT_MLX_REVISION" \
        "refs/heads/prime-pinned^{commit}" || return 1
    prime_measurement_validate_mirror \
        "$prime_measurement_runner_temp/prime-active-root-build/repositories/swift-numerics-d936ec6c" \
        "$PRIME_MEASUREMENT_NUMERICS_ORIGIN" \
        "$PRIME_MEASUREMENT_NUMERICS_REVISION" \
        "refs/tags/1.1.1^{commit}"
}

prime_measurement_materialize_exact_source() {
    local destination="$1"
    prime_measurement_create_directory "$destination" || return 1
    prime_measurement_register_directory_join "$destination" "700" \
        "$prime_measurement_base_device" || return 1
    /usr/bin/git -C "$destination" init -q >/dev/null 2>&1 || return 1
    /usr/bin/git -C "$destination" -c protocol.file.allow=always fetch \
        --no-tags --no-write-fetch-head "$prime_measurement_checkout_root" \
        "$prime_measurement_exact_revision" >/dev/null 2>&1 || return 1
    /usr/bin/git -C "$destination" checkout --detach --quiet \
        "$prime_measurement_exact_revision" >/dev/null 2>&1 || return 1
    prime_measurement_revisions_equal "$destination" \
        "$prime_measurement_exact_revision" HEAD || return 1
    /usr/bin/git -C "$destination" symbolic-ref -q HEAD >/dev/null 2>&1
    [[ "$?" == "1" ]] || return 1
    prime_measurement_git_repository_is_clean "$destination"
}

prime_measurement_create_build_root_set() {
    local root="$1"
    prime_measurement_create_directory "$root" || return 1
    prime_measurement_register_directory_join "$root" "700" \
        "$prime_measurement_base_device" || return 1
    local role path mode
    for role in scratch cache config security; do
        path="$root/$role"
        prime_measurement_create_directory "$path" || return 1
        prime_measurement_physical_directory_is_exact "$path" || return 1
        mode="$(LC_ALL=C /usr/bin/stat -f '%d:%u:%Lp' -- "$path" 2>/dev/null)" || return 1
        [[ "$mode" =~ ^(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,9}):(700)$ ]] || return 1
        local observed_device="${BASH_REMATCH[1]}"
        local observed_owner="${BASH_REMATCH[2]}"
        [[ "$observed_device" == "$prime_measurement_base_device" \
            && "$observed_owner" == "$EUID" ]] || return 1
    done
}

prime_measurement_swift_build() {
    local source_root="$1"
    local build_root="$2"
    local mlx_url="file://$prime_measurement_runner_temp/ergentics-mlx-swift.git/"
    local numerics_url="file://$prime_measurement_runner_temp/prime-active-root-build/repositories/swift-numerics-d936ec6c/"
    (
        cd "$source_root" || exit 1
        TMPDIR="$prime_measurement_runner_temp" \
        GIT_CONFIG_COUNT=3 \
        GIT_CONFIG_KEY_0="url.${mlx_url}.insteadOf" \
        GIT_CONFIG_VALUE_0="$PRIME_MEASUREMENT_MLX_ORIGIN" \
        GIT_CONFIG_KEY_1="url.${numerics_url}.insteadOf" \
        GIT_CONFIG_VALUE_1="$PRIME_MEASUREMENT_NUMERICS_ORIGIN" \
        GIT_CONFIG_KEY_2='protocol.file.allow' \
        GIT_CONFIG_VALUE_2='always' \
            /usr/bin/swift build \
                --package-path Tests/PrimeValidationWorkflow \
                --configuration release \
                --scratch-path "$build_root/scratch" \
                --cache-path "$build_root/cache" \
                --config-path "$build_root/config" \
                --security-path "$build_root/security" \
                --disable-dependency-cache \
                --manifest-cache local \
                --disable-netrc \
                --disable-keychain \
                --force-resolved-versions \
                --product "$PRIME_MEASUREMENT_FIXTURE_PRODUCT" \
                </dev/null >/dev/null 2>/dev/null 3>&- 8>&- 9>&-
    )
}

prime_measurement_swift_show_bin() {
    local source_root="$1"
    local build_root="$2"
    local mlx_url="file://$prime_measurement_runner_temp/ergentics-mlx-swift.git/"
    local numerics_url="file://$prime_measurement_runner_temp/prime-active-root-build/repositories/swift-numerics-d936ec6c/"
    cd "$source_root" || return 1
    TMPDIR="$prime_measurement_runner_temp" \
    GIT_CONFIG_COUNT=3 \
    GIT_CONFIG_KEY_0="url.${mlx_url}.insteadOf" \
    GIT_CONFIG_VALUE_0="$PRIME_MEASUREMENT_MLX_ORIGIN" \
    GIT_CONFIG_KEY_1="url.${numerics_url}.insteadOf" \
    GIT_CONFIG_VALUE_1="$PRIME_MEASUREMENT_NUMERICS_ORIGIN" \
    GIT_CONFIG_KEY_2='protocol.file.allow' \
    GIT_CONFIG_VALUE_2='always' \
        /usr/bin/swift build \
            --package-path Tests/PrimeValidationWorkflow \
            --configuration release \
            --scratch-path "$build_root/scratch" \
            --cache-path "$build_root/cache" \
            --config-path "$build_root/config" \
            --security-path "$build_root/security" \
            --disable-dependency-cache \
            --manifest-cache local \
            --disable-netrc \
            --disable-keychain \
            --force-resolved-versions \
            --show-bin-path 2>/dev/null 3>&- 8>&- 9>&-
}

prime_measurement_parse_pipeline_envelope() {
    local capture="$1"
    local maximum_capture_bytes="$2"
    [[ "${#capture}" -le "$maximum_capture_bytes" \
        && "${#capture}" -ge "19" ]] || return 1
    local envelope="${capture: -19}"
    [[ "$envelope" =~ ^@P:([0-9]{3}),H:([0-9]{3}),O:([0-9]{3})@$ ]] || return 1
    prime_measurement_pipeline_producer="${BASH_REMATCH[1]}"
    prime_measurement_pipeline_head="${BASH_REMATCH[2]}"
    prime_measurement_pipeline_od="${BASH_REMATCH[3]}"
    [[ $((10#$prime_measurement_pipeline_producer)) -le 255 \
        && $((10#$prime_measurement_pipeline_head)) -le 255 \
        && $((10#$prime_measurement_pipeline_od)) -le 255 ]] || return 1
    prime_measurement_pipeline_encoded="${capture:0:${#capture}-19}"
}

prime_measurement_decode_od_payload() {
    local encoded="$1"
    local LC_ALL=C
    [[ "$encoded" != *$'\r'* && "$encoded" != *$'\t'* \
        && "$encoded" != *$'\v'* && "$encoded" != *$'\f'* \
        && "$encoded" =~ ^([[:space:]]*[0-9a-f]{2})*[[:space:]]*$ ]] || return 1
    local hex="${encoded// /}"
    hex="${hex//$'\n'/}"
    [[ "$hex" =~ ^([0-9a-f]{2})*$ ]] || return 1
    local raw_count=$((${#hex} / 2))
    local expected_encoded_count="0"
    if [[ "$raw_count" != "0" ]]; then
        expected_encoded_count=$((74 * ((raw_count + 15) / 16) + 1))
    fi
    [[ "${#encoded}" == "$expected_encoded_count" ]] || return 1
    prime_measurement_decoded_hex="$hex"
    prime_measurement_decoded_byte_count="$raw_count"
}

prime_measurement_hex_to_shell_string() {
    local hex="$1"
    [[ "$hex" != *00* ]] || return 1
    local escapes=""
    local offset=0
    while [[ "$offset" -lt "${#hex}" ]]; do
        escapes+="\\x${hex:$offset:2}"
        offset=$((offset + 2))
    done
    builtin printf -v prime_measurement_decoded_string '%b' "$escapes"
}

prime_measurement_capture_show_bin() {
    local source_root="$1"
    local build_root="$2"
    local capture
    capture="$(
        prime_measurement_swift_show_bin "$source_root" "$build_root" \
            | /usr/bin/head -c "$PRIME_MEASUREMENT_SHOW_BIN_READER_BYTES" \
            | LC_ALL=C /usr/bin/od -An -tx1 -v
        local statuses=( "${PIPESTATUS[@]}" )
        if [[ "${#statuses[@]}" == "3" \
            && "${statuses[0]}" =~ ^[0-9]+$ \
            && "${statuses[1]}" =~ ^[0-9]+$ \
            && "${statuses[2]}" =~ ^[0-9]+$ ]]; then
            builtin printf '@P:%03d,H:%03d,O:%03d@' \
                "${statuses[0]}" "${statuses[1]}" "${statuses[2]}"
        fi
    )"
    prime_measurement_parse_pipeline_envelope "$capture" \
        "$PRIME_MEASUREMENT_MAX_SHOW_BIN_CAPTURE_BYTES" || return 2
    if [[ "$prime_measurement_pipeline_producer" != "000" ]]; then
        return 3
    fi
    if [[ "$prime_measurement_pipeline_head" != "000" \
        || "$prime_measurement_pipeline_od" != "000" ]]; then
        return 4
    fi
    prime_measurement_decode_od_payload "$prime_measurement_pipeline_encoded" || return 4
    [[ "$prime_measurement_decoded_byte_count" -le \
        "$PRIME_MEASUREMENT_MAX_SHOW_BIN_BYTES" \
        && "$prime_measurement_decoded_byte_count" -gt "1" \
        && "$prime_measurement_decoded_hex" == *0a \
        && "${prime_measurement_decoded_hex%0a}" != *0a* \
        && "${prime_measurement_decoded_hex%0a}" != *0d* ]] || return 4
    local body_hex="${prime_measurement_decoded_hex%0a}"
    prime_measurement_hex_to_shell_string "$body_hex" || return 4
    prime_measurement_show_bin_path="$prime_measurement_decoded_string"
    [[ "$prime_measurement_show_bin_path" == /* \
        && -n "$prime_measurement_show_bin_path" \
        && "$prime_measurement_show_bin_path" != *$'\n'* \
        && "$prime_measurement_show_bin_path" != *$'\r'* ]] || return 4
    return 0
}

prime_measurement_admit_fixture_artifact() {
    local bin_path="$1"
    local build_root="$2"
    prime_measurement_physical_directory_is_exact "$bin_path" || return 1
    [[ "$bin_path/" == "$build_root/scratch/"* ]] || return 1
    local fixture_path="$bin_path/$PRIME_MEASUREMENT_FIXTURE_LEAF"
    [[ "$fixture_path" == /* && -f "$fixture_path" && ! -L "$fixture_path" \
        && -x "$fixture_path" ]] || return 1
    local metadata
    metadata="$(LC_ALL=C /usr/bin/stat -f '%d:%i:%u:%l:%Lp:%z' -- "$fixture_path" 2>/dev/null)" || return 1
    [[ "${#metadata}" -le "96" \
        && "$metadata" =~ ^(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,9}):(1):([0-7]{3,4}):([1-9][0-9]{0,6})$ ]] || return 1
    local device="${BASH_REMATCH[1]}"
    local owner="${BASH_REMATCH[3]}"
    local mode="${BASH_REMATCH[5]}"
    local byte_count="${BASH_REMATCH[6]}"
    [[ "$device" == "$prime_measurement_base_device" \
        && "$owner" == "$EUID" ]] || return 1
    prime_measurement_mode_has_owner_execute "$mode" || return 1
    prime_measurement_integer_at_most "$byte_count" \
        "$PRIME_MEASUREMENT_MAX_FIXTURE_BYTES" || return 1
    prime_measurement_admitted_fixture_path="$fixture_path"
}

prime_measurement_source_identity_matches() {
    local source_path="$1"
    [[ -f "$source_path" && ! -L "$source_path" && ! -x "$source_path" ]] || return 1
    local metadata
    metadata="$(LC_ALL=C /usr/bin/stat -f '%d:%u:%l:%Lp:%z' -- "$source_path" 2>/dev/null)" || return 1
    [[ "$metadata" =~ ^(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,9}):(1):(644):([1-9][0-9]*)$ ]] || return 1
    local source_device="${BASH_REMATCH[1]}"
    local source_owner="${BASH_REMATCH[2]}"
    local source_byte_count="${BASH_REMATCH[5]}"
    [[ "$source_device" == "$prime_measurement_checkout_device" \
        && "$source_owner" == "$EUID" \
        && "$source_byte_count" == "$PRIME_MEASUREMENT_EVALUATOR_SOURCE_BYTE_COUNT" ]] || return 1
    local digest
    digest="$(LC_ALL=C /usr/bin/shasum -a 256 < "$source_path" 2>/dev/null)" || return 1
    [[ "$digest" =~ ^([0-9a-f]{64})[[:space:]]+-$ ]] || return 1
    local source_sha256="${BASH_REMATCH[1]}"
    [[ "$source_sha256" == "$PRIME_MEASUREMENT_EVALUATOR_SOURCE_SHA256" ]] || return 1
    local blob_digest
    blob_digest="$(
        {
            builtin printf 'blob %s\0' \
                "$PRIME_MEASUREMENT_EVALUATOR_SOURCE_BYTE_COUNT" || exit 1
            /bin/cat -- "$source_path" || exit 1
        } | LC_ALL=C /usr/bin/shasum -a 1
    )" || return 1
    [[ "$blob_digest" =~ ^([0-9a-f]{40})[[:space:]]+-$ ]] || return 1
    local source_blob="${BASH_REMATCH[1]}"
    [[ "$source_blob" == "$PRIME_MEASUREMENT_EVALUATOR_SOURCE_GIT_BLOB" ]] || return 1
    /usr/bin/git -C "$prime_measurement_checkout_root" diff --quiet \
        --no-ext-diff --no-textconv "$prime_measurement_exact_revision" -- \
        "$PRIME_MEASUREMENT_EVALUATOR_SOURCE" >/dev/null 2>&1
}

prime_measurement_admit_evaluator_executable() {
    local path="$1"
    [[ "$path" == /* && -f "$path" && ! -L "$path" && -x "$path" ]] || return 1
    local metadata
    metadata="$(LC_ALL=C /usr/bin/stat -f '%d:%u:%l:%Lp' -- "$path" 2>/dev/null)" || return 1
    [[ "$metadata" =~ ^(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,9}):(1):([0-7]{3,4})$ ]] || return 1
    local device="${BASH_REMATCH[1]}"
    local owner="${BASH_REMATCH[2]}"
    local mode="${BASH_REMATCH[4]}"
    [[ "$device" == "$prime_measurement_base_device" \
        && "$owner" == "$EUID" ]] || return 1
    prime_measurement_mode_has_owner_execute "$mode"
}

prime_measurement_capture_evaluator() {
    local evaluator_path="$1"
    local fixture_a_path="$2"
    local fixture_b_path="$3"
    local capture
    capture="$(
        /usr/bin/env -i "$evaluator_path" measure_fixture_identity \
            "$fixture_a_path" "$fixture_b_path" \
            </dev/null 2>/dev/null 3>&- 8>&- 9>&- \
            | /usr/bin/head -c "$PRIME_MEASUREMENT_EVALUATOR_READER_BYTES" \
            | LC_ALL=C /usr/bin/od -An -tx1 -v
        local statuses=( "${PIPESTATUS[@]}" )
        if [[ "${#statuses[@]}" == "3" \
            && "${statuses[0]}" =~ ^[0-9]+$ \
            && "${statuses[1]}" =~ ^[0-9]+$ \
            && "${statuses[2]}" =~ ^[0-9]+$ ]]; then
            builtin printf '@P:%03d,H:%03d,O:%03d@' \
                "${statuses[0]}" "${statuses[1]}" "${statuses[2]}"
        fi
    )"
    prime_measurement_parse_pipeline_envelope "$capture" \
        "$PRIME_MEASUREMENT_MAX_EVALUATOR_CAPTURE_BYTES" || return 2
    prime_measurement_evaluator_wait=$((10#$prime_measurement_pipeline_producer))
    if [[ "$prime_measurement_pipeline_producer" != "000" ]]; then
        return 3
    fi
    if [[ "$prime_measurement_pipeline_head" != "000" \
        || "$prime_measurement_pipeline_od" != "000" ]]; then
        return 4
    fi
    prime_measurement_decode_od_payload "$prime_measurement_pipeline_encoded" || return 4
    [[ "$prime_measurement_decoded_byte_count" -le \
        "$PRIME_MEASUREMENT_MAX_EVALUATOR_BYTES" \
        && "$prime_measurement_decoded_hex" != *0a* \
        && "$prime_measurement_decoded_hex" != *0d* ]] || return 4
    prime_measurement_hex_to_shell_string "$prime_measurement_decoded_hex" || return 4
    prime_measurement_evaluator_json="$prime_measurement_decoded_string"
    return 0
}

prime_measurement_parse_evaluator_json() {
    local json="$1"
    local LC_ALL=C
    local regex='^\{"byte_count_equal":(false|true),"fixture_a_build_platform_packed":(1),"fixture_a_byte_count":([1-9][0-9]{0,6}),"fixture_a_macho_uuid":"([0-9a-f]{32})","fixture_a_minimum_os_packed":(0|[1-9][0-9]{0,9}),"fixture_a_sdk_packed":(0|[1-9][0-9]{0,9}),"fixture_a_sha256":"([0-9a-f]{64})","fixture_b_build_platform_packed":(1),"fixture_b_byte_count":([1-9][0-9]{0,6}),"fixture_b_macho_uuid":"([0-9a-f]{32})","fixture_b_minimum_os_packed":(0|[1-9][0-9]{0,9}),"fixture_b_sdk_packed":(0|[1-9][0-9]{0,9}),"fixture_b_sha256":"([0-9a-f]{64})","full_bytes_equal":(false|true),"macho_identity_equal":(false|true),"schema_id":"prime_secure_child_validation_fixture_identity_evaluator_output_v1","schema_version":1,"sha256_equal":(false|true)\}$'
    [[ "$json" =~ $regex ]] || return 1
    local byte_equal="${BASH_REMATCH[1]}"
    local a_platform="${BASH_REMATCH[2]}"
    local a_count="${BASH_REMATCH[3]}"
    local a_uuid="${BASH_REMATCH[4]}"
    local a_minos="${BASH_REMATCH[5]}"
    local a_sdk="${BASH_REMATCH[6]}"
    local a_sha="${BASH_REMATCH[7]}"
    local b_platform="${BASH_REMATCH[8]}"
    local b_count="${BASH_REMATCH[9]}"
    local b_uuid="${BASH_REMATCH[10]}"
    local b_minos="${BASH_REMATCH[11]}"
    local b_sdk="${BASH_REMATCH[12]}"
    local b_sha="${BASH_REMATCH[13]}"
    local full_equal="${BASH_REMATCH[14]}"
    local macho_equal="${BASH_REMATCH[15]}"
    local sha_equal="${BASH_REMATCH[16]}"
    prime_measurement_integer_at_most "$a_count" "$PRIME_MEASUREMENT_MAX_FIXTURE_BYTES" || return 1
    prime_measurement_integer_at_most "$b_count" "$PRIME_MEASUREMENT_MAX_FIXTURE_BYTES" || return 1
    prime_measurement_integer_at_most "$a_minos" "4294967295" || return 1
    prime_measurement_integer_at_most "$a_sdk" "4294967295" || return 1
    prime_measurement_integer_at_most "$b_minos" "4294967295" || return 1
    prime_measurement_integer_at_most "$b_sdk" "4294967295" || return 1
    local reconstructed
    reconstructed="{\"byte_count_equal\":$byte_equal,\"fixture_a_build_platform_packed\":$a_platform,\"fixture_a_byte_count\":$a_count,\"fixture_a_macho_uuid\":\"$a_uuid\",\"fixture_a_minimum_os_packed\":$a_minos,\"fixture_a_sdk_packed\":$a_sdk,\"fixture_a_sha256\":\"$a_sha\",\"fixture_b_build_platform_packed\":$b_platform,\"fixture_b_byte_count\":$b_count,\"fixture_b_macho_uuid\":\"$b_uuid\",\"fixture_b_minimum_os_packed\":$b_minos,\"fixture_b_sdk_packed\":$b_sdk,\"fixture_b_sha256\":\"$b_sha\",\"full_bytes_equal\":$full_equal,\"macho_identity_equal\":$macho_equal,\"schema_id\":\"prime_secure_child_validation_fixture_identity_evaluator_output_v1\",\"schema_version\":1,\"sha256_equal\":$sha_equal}"
    [[ "$reconstructed" == "$json" ]] || return 1
    [[ ( "$byte_equal" == "true" && "$a_count" == "$b_count" ) \
        || ( "$byte_equal" == "false" && "$a_count" != "$b_count" ) ]] || return 1
    [[ ( "$sha_equal" == "true" && "$a_sha" == "$b_sha" ) \
        || ( "$sha_equal" == "false" && "$a_sha" != "$b_sha" ) ]] || return 1
    if [[ "$macho_equal" == "true" ]]; then
        [[ "$a_uuid" == "$b_uuid" && "$a_platform" == "$b_platform" \
            && "$a_minos" == "$b_minos" && "$a_sdk" == "$b_sdk" ]] || return 1
    fi
    if [[ "$a_uuid" != "$b_uuid" || "$a_platform" != "$b_platform" \
        || "$a_minos" != "$b_minos" || "$a_sdk" != "$b_sdk" ]]; then
        [[ "$macho_equal" == "false" ]] || return 1
    fi
    if [[ "$full_equal" == "true" ]]; then
        [[ "$byte_equal" == "true" && "$sha_equal" == "true" \
            && "$macho_equal" == "true" ]] || return 1
    fi
    prime_measurement_fixture_a_count="$a_count"
    prime_measurement_fixture_a_sha="$a_sha"
    prime_measurement_fixture_a_uuid="$a_uuid"
    prime_measurement_fixture_a_platform="$a_platform"
    prime_measurement_fixture_a_minos="$a_minos"
    prime_measurement_fixture_a_sdk="$a_sdk"
    prime_measurement_fixture_b_count="$b_count"
    prime_measurement_fixture_b_sha="$b_sha"
    prime_measurement_fixture_b_uuid="$b_uuid"
    prime_measurement_fixture_b_platform="$b_platform"
    prime_measurement_fixture_b_minos="$b_minos"
    prime_measurement_fixture_b_sdk="$b_sdk"
    prime_measurement_byte_count_equal="$byte_equal"
    prime_measurement_sha256_equal="$sha_equal"
    prime_measurement_full_bytes_equal="$full_equal"
    prime_measurement_macho_identity_equal="$macho_equal"
}

prime_measurement_main() {
    local argument_count="$#"
    set -u -o pipefail
    LC_ALL=C
    builtin export -n LC_ALL
    prime_measurement_initialize_state
    prime_measurement_exact_revision="${GITHUB_SHA:-}"
    prime_measurement_is_git_sha "$prime_measurement_exact_revision" || return 1
    exec 3>&1 || return 1
    trap prime_measurement_unexpected_exit EXIT || return 1
    if ! exec >/dev/null 2>/dev/null; then
        prime_measurement_project_and_exit "INVOCATION_ADMISSION_REFUSED"
    fi
    if [[ "$-" != *p* ]]; then
        prime_measurement_project_and_exit "INVOCATION_ADMISSION_REFUSED"
    fi

    if ! prime_measurement_checkout_root="$(pwd -P)" \
        || [[ -z "$prime_measurement_checkout_root" \
            || "${#prime_measurement_checkout_root}" -gt "1024" ]]; then
        prime_measurement_project_and_exit "MEASUREMENT_ROOT_REFUSED"
    fi
    if ! prime_measurement_validate_invocation "$argument_count" \
            "$prime_measurement_checkout_root"; then
        prime_measurement_project_and_exit "INVOCATION_ADMISSION_REFUSED"
    fi
    if ! prime_measurement_validate_fixed_tools; then
        prime_measurement_project_and_exit "INVOCATION_ADMISSION_REFUSED"
    fi

    prime_measurement_runner_temp="${RUNNER_TEMP:-}"
    if [[ -z "$prime_measurement_runner_temp" \
        || "${#prime_measurement_runner_temp}" -gt "1024" ]]; then
        prime_measurement_project_and_exit "MEASUREMENT_ROOT_REFUSED"
    fi
    if ! prime_measurement_register_directory_join \
            "$prime_measurement_checkout_root" "any" "any"; then
        prime_measurement_project_and_exit "MEASUREMENT_ROOT_REFUSED"
    fi
    prime_measurement_checkout_device="$prime_measurement_admitted_device"
    if ! prime_measurement_register_directory_join \
            "$prime_measurement_runner_temp" "any" \
            "$prime_measurement_checkout_device"; then
        prime_measurement_project_and_exit "MEASUREMENT_ROOT_REFUSED"
    fi
    prime_measurement_runner_device="$prime_measurement_admitted_device"

    prime_measurement_single_component_leaf "$PRIME_MEASUREMENT_PRIVATE_BASE_LEAF" \
        || prime_measurement_project_and_exit "MEASUREMENT_ROOT_REFUSED"
    prime_measurement_private_base="$prime_measurement_runner_temp/$PRIME_MEASUREMENT_PRIVATE_BASE_LEAF"
    if ! prime_measurement_create_directory "$prime_measurement_private_base" \
        || ! prime_measurement_register_directory_join \
            "$prime_measurement_private_base" "700" \
            "$prime_measurement_runner_device"; then
        prime_measurement_project_and_exit "MEASUREMENT_ROOT_REFUSED"
    fi
    prime_measurement_base_device="$prime_measurement_admitted_device"

    local leaf
    for leaf in "$PRIME_MEASUREMENT_SOURCE_A_LEAF" \
            "$PRIME_MEASUREMENT_SOURCE_B_LEAF" \
            "$PRIME_MEASUREMENT_BUILD_A_LEAF" \
            "$PRIME_MEASUREMENT_BUILD_B_LEAF" \
            "$PRIME_MEASUREMENT_EVALUATOR_ROOT_LEAF"; do
        prime_measurement_single_component_leaf "$leaf" \
            || prime_measurement_project_and_exit "MEASUREMENT_ROOT_REFUSED"
    done
    prime_measurement_source_a="$prime_measurement_private_base/$PRIME_MEASUREMENT_SOURCE_A_LEAF"
    prime_measurement_source_b="$prime_measurement_private_base/$PRIME_MEASUREMENT_SOURCE_B_LEAF"
    prime_measurement_build_a="$prime_measurement_private_base/$PRIME_MEASUREMENT_BUILD_A_LEAF"
    prime_measurement_build_b="$prime_measurement_private_base/$PRIME_MEASUREMENT_BUILD_B_LEAF"
    prime_measurement_evaluator_root="$prime_measurement_private_base/$PRIME_MEASUREMENT_EVALUATOR_ROOT_LEAF"

    if ! prime_measurement_materialize_exact_source "$prime_measurement_source_a" \
        || ! prime_measurement_materialize_exact_source "$prime_measurement_source_b"; then
        prime_measurement_project_and_exit "SOURCE_ROOT_REFUSED"
    fi
    if ! prime_measurement_create_build_root_set "$prime_measurement_build_a" \
        || ! prime_measurement_create_build_root_set "$prime_measurement_build_b"; then
        prime_measurement_project_and_exit "BUILD_ROOT_REFUSED"
    fi
    if ! prime_measurement_validate_mirrors; then
        prime_measurement_project_and_exit "MIRROR_REFUSED"
    fi

    prime_measurement_attempt_consumed=true
    if ! prime_measurement_swift_build "$prime_measurement_source_a" \
            "$prime_measurement_build_a"; then
        prime_measurement_build_a_state="failed"
        prime_measurement_project_and_exit "BUILD_A_REFUSED"
    fi
    prime_measurement_build_a_state="succeeded"
    prime_measurement_capture_show_bin "$prime_measurement_source_a" \
        "$prime_measurement_build_a"
    local capture_status="$?"
    case "$capture_status" in
        0) prime_measurement_show_a_state="succeeded" ;;
        2)
            prime_measurement_show_a_state="unavailable"
            prime_measurement_project_and_exit "SHOW_BIN_A_TRANSPORT_REFUSED"
            ;;
        3)
            prime_measurement_show_a_state="failed"
            prime_measurement_project_and_exit "SHOW_BIN_A_REFUSED"
            ;;
        *)
            prime_measurement_show_a_state="succeeded"
            prime_measurement_project_and_exit "ARTIFACT_A_ADMISSION_REFUSED"
            ;;
    esac
    if ! prime_measurement_admit_fixture_artifact \
            "$prime_measurement_show_bin_path" "$prime_measurement_build_a"; then
        prime_measurement_project_and_exit "ARTIFACT_A_ADMISSION_REFUSED"
    fi
    prime_measurement_fixture_a_path="$prime_measurement_admitted_fixture_path"

    if ! prime_measurement_swift_build "$prime_measurement_source_b" \
            "$prime_measurement_build_b"; then
        prime_measurement_build_b_state="failed"
        prime_measurement_project_and_exit "BUILD_B_REFUSED"
    fi
    prime_measurement_build_b_state="succeeded"
    prime_measurement_capture_show_bin "$prime_measurement_source_b" \
        "$prime_measurement_build_b"
    capture_status="$?"
    case "$capture_status" in
        0) prime_measurement_show_b_state="succeeded" ;;
        2)
            prime_measurement_show_b_state="unavailable"
            prime_measurement_project_and_exit "SHOW_BIN_B_TRANSPORT_REFUSED"
            ;;
        3)
            prime_measurement_show_b_state="failed"
            prime_measurement_project_and_exit "SHOW_BIN_B_REFUSED"
            ;;
        *)
            prime_measurement_show_b_state="succeeded"
            prime_measurement_project_and_exit "ARTIFACT_B_ADMISSION_REFUSED"
            ;;
    esac
    if ! prime_measurement_admit_fixture_artifact \
            "$prime_measurement_show_bin_path" "$prime_measurement_build_b"; then
        prime_measurement_project_and_exit "ARTIFACT_B_ADMISSION_REFUSED"
    fi
    prime_measurement_fixture_b_path="$prime_measurement_admitted_fixture_path"

    if ! prime_measurement_create_directory "$prime_measurement_evaluator_root" \
        || ! prime_measurement_register_directory_join \
            "$prime_measurement_evaluator_root" "700" \
            "$prime_measurement_base_device"; then
        prime_measurement_project_and_exit "EVALUATOR_ROOT_REFUSED"
    fi
    local evaluator_path="$prime_measurement_evaluator_root/$PRIME_MEASUREMENT_EVALUATOR_LEAF"
    if [[ -e "$evaluator_path" || -L "$evaluator_path" ]]; then
        prime_measurement_project_and_exit "EVALUATOR_ROOT_REFUSED"
    fi
    local evaluator_source="$prime_measurement_checkout_root/$PRIME_MEASUREMENT_EVALUATOR_SOURCE"
    if ! prime_measurement_source_identity_matches "$evaluator_source"; then
        prime_measurement_project_and_exit "EVALUATOR_SOURCE_REFUSED"
    fi
    /usr/bin/xcrun swiftc "$evaluator_source" -o "$evaluator_path" \
        </dev/null >/dev/null 2>/dev/null 3>&- 8>&- 9>&-
    local compiler_status="$?"
    if [[ "$compiler_status" != "0" ]]; then
        prime_measurement_compile_state="failed"
        prime_measurement_project_and_exit "EVALUATOR_COMPILE_REFUSED"
    fi
    prime_measurement_compile_state="succeeded"
    if ! prime_measurement_admit_evaluator_executable "$evaluator_path"; then
        prime_measurement_project_and_exit "EVALUATOR_ADMISSION_REFUSED"
    fi

    prime_measurement_capture_evaluator "$evaluator_path" \
        "$prime_measurement_fixture_a_path" "$prime_measurement_fixture_b_path"
    capture_status="$?"
    case "$capture_status" in
        0)
            prime_measurement_evaluator_state="succeeded"
            prime_measurement_evaluator_observation="observed_true"
            ;;
        2)
            prime_measurement_evaluator_state="unavailable"
            prime_measurement_evaluator_observation="unavailable"
            prime_measurement_evaluator_wait="null"
            prime_measurement_project_and_exit "EVALUATOR_TRANSPORT_REFUSED"
            ;;
        3)
            prime_measurement_evaluator_state="failed"
            prime_measurement_evaluator_observation="unavailable"
            prime_measurement_project_and_exit "EVALUATOR_COMMAND_REFUSED"
            ;;
        *)
            prime_measurement_evaluator_state="succeeded"
            prime_measurement_evaluator_observation="observed_true"
            prime_measurement_evaluator_wait="0"
            prime_measurement_project_and_exit "CAPTURE_REFUSED"
            ;;
    esac
    if ! prime_measurement_parse_evaluator_json "$prime_measurement_evaluator_json"; then
        prime_measurement_project_and_exit "EVALUATOR_CONTRACT_REFUSED"
    fi

    if [[ "$prime_measurement_full_bytes_equal" == "false" ]]; then
        prime_measurement_project_and_exit "NONDETERMINISTIC_BUILD"
    fi
    if [[ "$prime_measurement_fixture_a_count" == "$PRIME_MEASUREMENT_CURRENT_PIN_BYTE_COUNT" \
        && "$prime_measurement_fixture_b_count" == "$PRIME_MEASUREMENT_CURRENT_PIN_BYTE_COUNT" ]]; then
        prime_measurement_pin_byte_count_match="true"
    else
        prime_measurement_pin_byte_count_match="false"
    fi
    if [[ "$prime_measurement_fixture_a_sha" == "$PRIME_MEASUREMENT_CURRENT_PIN_SHA256" \
        && "$prime_measurement_fixture_b_sha" == "$PRIME_MEASUREMENT_CURRENT_PIN_SHA256" ]]; then
        prime_measurement_pin_sha256_match="true"
    else
        prime_measurement_pin_sha256_match="false"
    fi
    if [[ "$prime_measurement_pin_byte_count_match" == "true" \
        && "$prime_measurement_pin_sha256_match" == "true" ]]; then
        prime_measurement_pin_full_match="true"
        prime_measurement_project_and_exit "PASS_IDENTICAL_CURRENT_PIN"
    fi
    prime_measurement_pin_full_match="false"
    prime_measurement_project_and_exit "PASS_IDENTICAL_DIFFERENT_PIN"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    prime_measurement_main "$@"
fi
