#!/bin/bash
# SPDX-FileCopyrightText: 2026 Ergentics, LLC
# SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

[[ "$-" == *p* ]] || return 97
builtin unset BASH_ENV ENV

# Trap definitions that predate sourcing are observable only in the caller's
# top-level trap table. Preserve presence, never handler bytes, for the later
# pre-witness admission check.
[[ -z "${prime_topology_source_probe_frozen_v1+x}" \
    && -z "${prime_topology_source_had_debug_trap+x}" \
    && -z "${prime_topology_source_had_return_trap+x}" \
    && -z "${prime_topology_source_had_err_trap+x}" \
    && -z "${prime_topology_source_had_functrace+x}" \
    && -z "${prime_topology_source_bash_subshell_depth_v1+x}" \
    && -z "${prime_topology_source_trap_probe+x}" \
    && -z "${prime_topology_trusted_trace_trap_representation_v1+x}" \
    && -z "${prime_topology_after_source_trap_presence_v1+x}" \
    && -z "${prime_topology_internal_watcher_entry_seen_v1+x}" \
    && -z "${prime_topology_closed_child_v1+x}" \
    && -z "${prime_topology_closed_child_depth_v1+x}" \
    && -z "${prime_topology_watched_command_v1+x}" ]] || return 96
prime_topology_source_had_debug_trap=false
prime_topology_source_had_return_trap=false
prime_topology_source_had_err_trap=false
prime_topology_source_had_functrace=false
prime_topology_internal_watcher_entry_seen_v1=false
prime_topology_source_bash_subshell_depth_v1="$BASH_SUBSHELL"
if [[ -o functrace ]]; then
    prime_topology_source_had_functrace=true
fi
prime_topology_source_trap_probe=""
IFS= builtin read -r prime_topology_source_trap_probe \
    < <(builtin trap -p DEBUG) || true
[[ -z "$prime_topology_source_trap_probe" ]] \
    || prime_topology_source_had_debug_trap=true
prime_topology_source_trap_probe=""
IFS= builtin read -r prime_topology_source_trap_probe \
    < <(builtin trap -p RETURN) || true
[[ -z "$prime_topology_source_trap_probe" ]] \
    || prime_topology_source_had_return_trap=true
prime_topology_source_trap_probe=""
IFS= builtin read -r prime_topology_source_trap_probe \
    < <(builtin trap -p ERR) || true
[[ -z "$prime_topology_source_trap_probe" ]] \
    || prime_topology_source_had_err_trap=true
builtin unset prime_topology_source_trap_probe
# Only presence is retained. No caller handler bytes survive into the trusted
# watcher representation or any later state that can hold a private witness.
builtin trap - RETURN ERR
prime_topology_source_probe_frozen_v1=true
builtin readonly \
    prime_topology_source_had_debug_trap \
    prime_topology_source_had_return_trap \
    prime_topology_source_had_err_trap \
    prime_topology_source_had_functrace \
    prime_topology_source_bash_subshell_depth_v1 \
    prime_topology_source_probe_frozen_v1

prime_topology_is_oid_v1() {
    local LC_ALL=C
    [[ "$1" =~ ^[0-9a-f]{40}$ ]]
}

prime_topology_is_role_v1() {
    local LC_ALL=C
    [[ "${#1}" -le 64 && "$1" =~ ^[a-z][a-z0-9_]{0,63}$ ]]
}

prime_topology_is_canonical_decimal_v1() {
    local LC_ALL=C
    [[ "$1" =~ ^(0|[1-9][0-9]*)$ ]]
}

prime_topology_is_canonical_absolute_path_v1() {
    local path="$1"
    local LC_ALL=C
    [[ -n "$path" && "${#path}" -le 1024 && "$path" == /* \
        && "$path" != *//* && "$path" != */./* && "$path" != */../* \
        && "$path" != */. && "$path" != */.. \
        && ! "$path" =~ [[:cntrl:]] ]]
}

prime_topology_begin_closed_trace_entry_v1() {
    # The trusted watcher sets this again immediately before its own removal.
    # A caller DEBUG trap cannot counterfeit that closed entry transition.
    prime_topology_internal_watcher_entry_seen_v1=false
    builtin trap - DEBUG
    builtin trap - RETURN ERR
    builtin set +T
    if [[ "$prime_topology_internal_watcher_entry_seen_v1" != true \
        && -z "${prime_topology_after_source_trap_presence_v1+x}" ]]; then
        prime_topology_after_source_trap_presence_v1=true
        builtin readonly prime_topology_after_source_trap_presence_v1
    fi
    prime_topology_internal_watcher_entry_seen_v1=false
    [[ "$-" != *x* && "$-" != *v* \
        && ! -o errtrace && ! -o functrace \
        && -z "${BASH_XTRACEFD+x}" \
        && "${PS4-+ }" == "+ " \
        && "$prime_topology_source_had_debug_trap" == false \
        && "$prime_topology_source_had_return_trap" == false \
        && "$prime_topology_source_had_err_trap" == false \
        && "$prime_topology_source_had_functrace" == false \
        && -z "${prime_topology_after_source_trap_presence_v1+x}" ]]
}

prime_topology_admit_closed_child_state_v1() {
    local LC_ALL=C
    [[ "${prime_topology_closed_child_v1-}" \
            == prime_exact_revision_topology_closed_child_v1 \
        && "${prime_topology_closed_child_depth_v1-}" \
            == "$BASH_SUBSHELL" \
        && "$BASH_SUBSHELL" \
            -gt "$prime_topology_source_bash_subshell_depth_v1" \
        && "$prime_topology_internal_watcher_entry_seen_v1" == false \
        && -z "${prime_topology_watched_command_v1+x}" \
        && "$-" != *x* && "$-" != *v* \
        && ! -o errtrace && ! -o functrace \
        && -z "${BASH_XTRACEFD+x}" \
        && "${PS4-}" == "" \
        && "$prime_topology_source_had_debug_trap" == false \
        && "$prime_topology_source_had_return_trap" == false \
        && "$prime_topology_source_had_err_trap" == false \
        && "$prime_topology_source_had_functrace" == false \
        && -z "${prime_topology_after_source_trap_presence_v1+x}" ]]
}

# This is deliberately one-way. The caller must execute the complete bounded
# PIPESTATUS capture and every operation that can hold a private parent2 in
# this child, then let the child exit. The parent shell's watcher is inherited
# by value and is therefore never disarmed or rearmed by this boundary.
prime_enter_exact_revision_topology_closed_child_v1() {
    local prime_topology_entry_trace_trap_representation_v1=""
    [[ "$#" -eq 0 \
        && "$BASH_SUBSHELL" \
            -gt "$prime_topology_source_bash_subshell_depth_v1" \
        && -z "${prime_topology_closed_child_v1+x}" \
        && -z "${prime_topology_closed_child_depth_v1+x}" ]] \
        || return 2
    prime_topology_entry_trace_trap_representation_v1="$(
        builtin trap -p DEBUG RETURN ERR 2>/dev/null
    )" || return 1
    if [[ "$prime_topology_entry_trace_trap_representation_v1" \
            != "$prime_topology_trusted_trace_trap_representation_v1" ]]; then
        prime_topology_entry_trace_trap_representation_v1=""
        builtin trap - DEBUG RETURN ERR
        builtin set +T
        return 1
    fi
    prime_topology_entry_trace_trap_representation_v1=""
    if ! ( PS4='' ) 2>/dev/null; then
        builtin trap - DEBUG RETURN ERR
        builtin set +T
        return 1
    fi
    prime_topology_begin_closed_trace_entry_v1 || return 1
    PS4=''
    prime_topology_closed_child_v1=prime_exact_revision_topology_closed_child_v1
    prime_topology_closed_child_depth_v1="$BASH_SUBSHELL"
    builtin readonly \
        prime_topology_closed_child_v1 \
        prime_topology_closed_child_depth_v1
    prime_topology_admit_closed_child_state_v1 || return 1
}

prime_topology_reset_candidates_v1() {
    prime_topology_candidate_phases=()
    prime_topology_candidate_ordinals=()
    prime_topology_candidate_result_codes=()
    prime_topology_candidate_guard_ids=()
    prime_topology_candidate_missing_roles=()
    prime_topology_best_phase=""
    prime_topology_best_ordinal=""
    prime_topology_best_result_code=""
    prime_topology_best_guard_id=""
    prime_topology_best_missing_role=""
}

prime_topology_add_candidate_v1() {
    prime_topology_candidate_phases+=( "$1" )
    prime_topology_candidate_ordinals+=( "$2" )
    prime_topology_candidate_result_codes+=( "$3" )
    prime_topology_candidate_guard_ids+=( "$4" )
    prime_topology_candidate_missing_roles+=( "$5" )
}

# Compatibility name retained for the frozen flat parser and fixture adapter.
prime_topology_set_failure_v1() {
    prime_topology_add_candidate_v1 "$@"
}

prime_select_exact_revision_topology_result_v1() {
    local index phase ordinal
    prime_topology_best_phase=""
    prime_topology_best_ordinal=""
    prime_topology_best_result_code=""
    prime_topology_best_guard_id=""
    prime_topology_best_missing_role=""
    for (( index = 0; index < ${#prime_topology_candidate_phases[@]}; index += 1 )); do
        phase="${prime_topology_candidate_phases[index]}"
        ordinal="${prime_topology_candidate_ordinals[index]}"
        if [[ -z "$prime_topology_best_phase" \
            || "$phase" -lt "$prime_topology_best_phase" \
            || ( "$phase" -eq "$prime_topology_best_phase" \
                && "$ordinal" -lt "$prime_topology_best_ordinal" ) ]]; then
            prime_topology_best_phase="$phase"
            prime_topology_best_ordinal="$ordinal"
            prime_topology_best_result_code="${prime_topology_candidate_result_codes[index]}"
            prime_topology_best_guard_id="${prime_topology_candidate_guard_ids[index]}"
            prime_topology_best_missing_role="${prime_topology_candidate_missing_roles[index]}"
        fi
    done
}

prime_topology_has_candidate_in_phase_range_v1() {
    local lower="$1"
    local upper="$2"
    local phase index
    for (( index = 0; index < ${#prime_topology_candidate_phases[@]}; index += 1 )); do
        phase="${prime_topology_candidate_phases[index]}"
        if [[ "$phase" -ge "$lower" && "$phase" -le "$upper" ]]; then
            return 0
        fi
    done
    return 1
}

prime_topology_flat_phase_for_relation_v1() {
    case "$1" in
        1) prime_topology_mapped_phase=1 ;;
        2) prime_topology_mapped_phase=2 ;;
        3) prime_topology_mapped_phase=4 ;;
        4) prime_topology_mapped_phase=5 ;;
        5) prime_topology_mapped_phase=6 ;;
        6) prime_topology_mapped_phase=7 ;;
        7) prime_topology_mapped_phase=8 ;;
        8) prime_topology_mapped_phase=9 ;;
        9) prime_topology_mapped_phase=10 ;;
        10) prime_topology_mapped_phase=11 ;;
        11) prime_topology_mapped_phase=12 ;;
        12) prime_topology_mapped_phase=13 ;;
        13) prime_topology_mapped_phase=14 ;;
        14) prime_topology_mapped_phase=15 ;;
        15) prime_topology_mapped_phase=16 ;;
        16) prime_topology_mapped_phase=17 ;;
        17) prime_topology_mapped_phase=18 ;;
        18) prime_topology_mapped_phase=19 ;;
        19) prime_topology_mapped_phase=20 ;;
        20) prime_topology_mapped_phase=21 ;;
        21) prime_topology_mapped_phase=22 ;;
        22) prime_topology_mapped_phase=24 ;;
        23) prime_topology_mapped_phase=25 ;;
        24) prime_topology_mapped_phase=26 ;;
        25) prime_topology_mapped_phase=27 ;;
        26) prime_topology_mapped_phase=28 ;;
        27) prime_topology_mapped_phase=29 ;;
        28) prime_topology_mapped_phase=30 ;;
        29) prime_topology_mapped_phase=31 ;;
        30) prime_topology_mapped_phase=32 ;;
        31) prime_topology_mapped_phase=33 ;;
        32) prime_topology_mapped_phase=34 ;;
        33) prime_topology_mapped_phase=35 ;;
        34) prime_topology_mapped_phase=37 ;;
        35) prime_topology_mapped_phase=38 ;;
        *) return 1 ;;
    esac
}

prime_topology_phase_v1() {
    local flat_phase="$1"
    local schedule="$2"
    if [[ "$schedule" == relation ]]; then
        prime_topology_flat_phase_for_relation_v1 "$flat_phase"
    else
        prime_topology_mapped_phase="$flat_phase"
    fi
}

prime_topology_find_terminal_mode_v1() {
    local -a tokens=( "$@" )
    local count_token="${tokens[1]:-}"
    local token_count="${#tokens[@]}"
    local scan_start=2
    local position=2
    local ordinal parent_count
    local declared_count=-1

    if prime_topology_is_canonical_decimal_v1 "$count_token" \
        && [[ "${#count_token}" -le 1 ]]; then
        declared_count="$count_token"
        for (( ordinal = 1; ordinal <= declared_count; ordinal += 1 )); do
            scan_start="$position"
            if [[ $((token_count - position)) -lt 4 ]]; then
                break
            fi
            parent_count="${tokens[position + 3]}"
            if ! prime_topology_is_canonical_decimal_v1 "$parent_count" \
                || [[ "${#parent_count}" -gt 1 || "$parent_count" -gt 8 ]]; then
                if [[ "${tokens[position]}" \
                        == "--ordered-merge-child-relation" \
                    || "${tokens[position]}" \
                        == "--current-index-exact-revision" ]]; then
                    scan_start="$position"
                else
                    position=$((position + 4))
                    scan_start="$position"
                fi
                break
            fi
            if [[ $((token_count - position - 4)) -lt "$parent_count" ]]; then
                position="$token_count"
                scan_start="$position"
                break
            fi
            position=$((position + 4 + parent_count))
            scan_start="$position"
        done
    fi

    prime_topology_relation_marker_index=-1
    prime_topology_relation_marker_count=0
    prime_topology_current_marker_index=-1
    prime_topology_current_marker_count=0
    for (( position = scan_start; position < token_count; position += 1 )); do
        case "${tokens[position]}" in
            --ordered-merge-child-relation)
                if [[ "$prime_topology_relation_marker_index" -lt 0 ]]; then
                    prime_topology_relation_marker_index="$position"
                fi
                prime_topology_relation_marker_count=$((prime_topology_relation_marker_count + 1))
                ;;
            --current-index-exact-revision)
                if [[ "$prime_topology_current_marker_index" -lt 0 ]]; then
                    prime_topology_current_marker_index="$position"
                fi
                prime_topology_current_marker_count=$((prime_topology_current_marker_count + 1))
                ;;
        esac
    done
    if [[ "$prime_topology_relation_marker_count" -gt 0 ]]; then
        prime_topology_mode=relation
    elif [[ "$prime_topology_current_marker_count" -gt 0 ]]; then
        prime_topology_mode=current_index
    else
        prime_topology_mode=ordinary
    fi
}

prime_parse_exact_revision_topology_relation_suffix_v1() {
    local -a tokens=( "$@" )
    local token_count="${#tokens[@]}"
    local index="$prime_topology_relation_marker_index"
    local merge_ordinal=$((prime_topology_request_count_numeric + 1))
    local relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids=true
    prime_topology_relation_suffix_operand_count=$((token_count - index - 1))
    if [[ "$prime_topology_relation_suffix_operand_count" -lt 0 ]]; then
        prime_topology_relation_suffix_operand_count=0
    elif [[ "$prime_topology_relation_suffix_operand_count" -gt 5 ]]; then
        prime_topology_relation_suffix_operand_count=5
    fi

    prime_topology_relation_merge_role="${tokens[index + 1]:-}"
    prime_topology_relation_merge_oid="${tokens[index + 2]:-}"
    prime_topology_relation_index_tree="${tokens[index + 3]:-}"
    prime_topology_relation_fixed_parent="${tokens[index + 4]:-}"
    prime_topology_relation_child_role="${tokens[index + 5]:-}"

    if [[ "$prime_topology_relation_suffix_operand_count" -ge 2 ]] \
        && ! prime_topology_is_oid_v1 "$prime_topology_relation_merge_oid"; then
        prime_topology_add_candidate_v1 1 "$merge_ordinal" \
            TOPOLOGY_INVOCATION_INVALID \
            literal_commit_oid_is_lowercase_40hex ""
    fi
    if [[ "$prime_topology_relation_suffix_operand_count" -ge 3 ]] \
        && ! prime_topology_is_oid_v1 "$prime_topology_relation_index_tree"; then
        prime_topology_add_candidate_v1 2 "$merge_ordinal" \
            TOPOLOGY_INVOCATION_INVALID \
            expected_topology_oids_are_lowercase_40hex ""
    fi
    if [[ "$prime_topology_relation_suffix_operand_count" -ge 4 ]] \
        && ! prime_topology_is_oid_v1 "$prime_topology_relation_fixed_parent"; then
        prime_topology_add_candidate_v1 2 "$merge_ordinal" \
            TOPOLOGY_INVOCATION_INVALID \
            expected_topology_oids_are_lowercase_40hex ""
    fi
    if [[ "$prime_topology_relation_suffix_operand_count" -ge 4 \
        && "$prime_topology_relation_merge_oid" \
            == "$prime_topology_relation_fixed_parent" ]]; then
        relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids=false
    fi
    local explicit_oid explicit_index
    for (( explicit_index = 0; \
        prime_topology_relation_suffix_operand_count >= 2 \
            && explicit_index < ${#prime_topology_request_oids[@]}; \
        explicit_index += 1 )); do
        explicit_oid="${prime_topology_request_oids[explicit_index]}"
        if [[ "$prime_topology_relation_merge_oid" == "$explicit_oid" ]]; then
            relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids=false
        fi
    done
    if [[ "$prime_topology_relation_suffix_operand_count" -ge 4 \
        && "$relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids" \
            != true ]]; then
        prime_topology_add_candidate_v1 3 "$merge_ordinal" \
            TOPOLOGY_INVOCATION_INVALID \
            relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids ""
    fi

    if [[ "$prime_topology_relation_marker_count" -ne 1 \
        || "$prime_topology_current_marker_count" -ne 0 \
        || "$index" -lt 0 || $((token_count - index)) -ne 6 \
        || "$index" -ne "$prime_topology_explicit_end_index" ]]; then
        prime_topology_add_candidate_v1 9 0 TOPOLOGY_INVOCATION_INVALID \
            expected_parent_count_within_bound ""
    fi
}

prime_topology_collect_explicit_requests_v1() {
    local -a tokens=( "$@" )
    local token_count="${#tokens[@]}"
    local position=2
    local ordinal role oid tree parent_count parent_index
    local parse_count="$prime_topology_request_count_numeric"
    prime_topology_request_roles=()
    prime_topology_request_oids=()
    prime_topology_request_trees=()
    prime_topology_request_parent_counts=()
    prime_topology_request_parent_offsets=()
    prime_topology_request_parents=()
    prime_topology_request_shape_valid=true

    if [[ "$parse_count" -gt 8 ]]; then parse_count=8; fi
    for (( ordinal = 1; ordinal <= parse_count; ordinal += 1 )); do
        if [[ "$position" -eq "$prime_topology_relation_marker_index" \
            || "$position" -eq "$prime_topology_current_marker_index" ]]; then
            prime_topology_request_shape_valid=false
            break
        fi
        role="${tokens[position]:-}"
        oid="${tokens[position + 1]:-}"
        tree="${tokens[position + 2]:-}"
        parent_count="${tokens[position + 3]:-}"
        prime_topology_request_roles+=( "$role" )
        prime_topology_request_oids+=( "$oid" )
        prime_topology_request_trees+=( "$tree" )
        prime_topology_request_parent_offsets+=( "${#prime_topology_request_parents[@]}" )
        if [[ $((token_count - position)) -lt 4 ]] \
            || ! prime_topology_is_canonical_decimal_v1 "$parent_count" \
            || [[ "${#parent_count}" -gt 1 || "$parent_count" -gt 8 ]] \
            || [[ $((token_count - position - 4)) -lt "$parent_count" ]]; then
            prime_topology_request_parent_counts+=( 0 )
            prime_topology_request_shape_valid=false
            position=$((position + 4))
            break
        fi
        prime_topology_request_parent_counts+=( "$parent_count" )
        position=$((position + 4))
        for (( parent_index = 0; parent_index < parent_count; parent_index += 1 )); do
            prime_topology_request_parents+=( "${tokens[position]}" )
            position=$((position + 1))
        done
    done
    if [[ "${#prime_topology_request_roles[@]}" -ne "$prime_topology_request_count_numeric" ]]; then
        prime_topology_request_shape_valid=false
    fi
    prime_topology_explicit_end_index="$position"
}

prime_topology_validate_explicit_values_v1() {
    local schedule="$1"
    local ordinal oid tree parent_count parent_index limit role earlier
    local oid_phase=1 expected_phase=2 role_phase=6 unique_phase=7 shape_phase=8
    if [[ "$schedule" == relation ]]; then
        role_phase=7
        unique_phase=8
        shape_phase=9
    fi
    for (( ordinal = 1; ordinal <= ${#prime_topology_request_oids[@]}; ordinal += 1 )); do
        oid="${prime_topology_request_oids[ordinal - 1]}"
        if ! prime_topology_is_oid_v1 "$oid"; then
            prime_topology_add_candidate_v1 "$oid_phase" "$ordinal" \
                TOPOLOGY_INVOCATION_INVALID \
                literal_commit_oid_is_lowercase_40hex ""
        fi
        tree="${prime_topology_request_trees[ordinal - 1]}"
        if ! prime_topology_is_oid_v1 "$tree"; then
            prime_topology_add_candidate_v1 "$expected_phase" "$ordinal" \
                TOPOLOGY_INVOCATION_INVALID \
                expected_topology_oids_are_lowercase_40hex ""
        fi
        parent_count="${prime_topology_request_parent_counts[ordinal - 1]:-0}"
        parent_index="${prime_topology_request_parent_offsets[ordinal - 1]:-0}"
        limit=$((parent_index + parent_count))
        while [[ "$parent_index" -lt "$limit" ]]; do
            if ! prime_topology_is_oid_v1 \
                    "${prime_topology_request_parents[parent_index]}"; then
                prime_topology_add_candidate_v1 "$expected_phase" "$ordinal" \
                    TOPOLOGY_INVOCATION_INVALID \
                    expected_topology_oids_are_lowercase_40hex ""
            fi
            parent_index=$((parent_index + 1))
        done
    done
    for (( ordinal = 1; ordinal <= ${#prime_topology_request_roles[@]}; ordinal += 1 )); do
        role="${prime_topology_request_roles[ordinal - 1]}"
        if ! prime_topology_is_role_v1 "$role"; then
            prime_topology_add_candidate_v1 "$role_phase" "$ordinal" \
                TOPOLOGY_INVOCATION_INVALID \
                request_role_matches_ascii_allowlist_grammar ""
        fi
    done
    prime_topology_all_roles=()
    for (( ordinal = 1; ordinal <= ${#prime_topology_request_roles[@]}; ordinal += 1 )); do
        prime_topology_all_roles+=( "${prime_topology_request_roles[ordinal - 1]}" )
    done
    if [[ "$schedule" == relation \
        && "$prime_topology_relation_suffix_operand_count" -ge 1 ]]; then
        prime_topology_all_roles+=( "$prime_topology_relation_merge_role" )
    fi
    if [[ "$schedule" == relation \
        && "$prime_topology_relation_suffix_operand_count" -ge 5 ]]; then
        prime_topology_all_roles+=( "$prime_topology_relation_child_role" )
    fi
    for (( ordinal = 1; ordinal <= ${#prime_topology_all_roles[@]}; ordinal += 1 )); do
        role="${prime_topology_all_roles[ordinal - 1]}"
        if ! prime_topology_is_role_v1 "$role"; then
            prime_topology_add_candidate_v1 "$role_phase" "$ordinal" \
                TOPOLOGY_INVOCATION_INVALID \
                request_role_matches_ascii_allowlist_grammar ""
        fi
        for (( earlier = 1; earlier < ordinal; earlier += 1 )); do
            if [[ "$role" == "${prime_topology_all_roles[earlier - 1]}" ]]; then
                prime_topology_add_candidate_v1 "$unique_phase" "$ordinal" \
                    TOPOLOGY_INVOCATION_INVALID request_roles_are_unique ""
            fi
        done
    done
    if [[ "$prime_topology_request_shape_valid" != true ]]; then
        prime_topology_add_candidate_v1 "$shape_phase" 0 \
            TOPOLOGY_INVOCATION_INVALID expected_parent_count_within_bound ""
    fi
}

prime_parse_exact_revision_topology_invocation_v1() {
    local -r zero_operand_terminal_marker_selects_explicit_request_ordinal1_and_no_marker_flat_calls_are_legacy=true
    local -a tokens=( "$@" )
    local token_count="${#tokens[@]}"
    prime_topology_repository="${tokens[0]:-}"
    prime_topology_request_count_token="${tokens[1]:-}"
    prime_topology_request_count_numeric=0
    prime_topology_find_terminal_mode_v1 "$@"

    if prime_topology_is_canonical_decimal_v1 \
            "$prime_topology_request_count_token" \
        && [[ "${#prime_topology_request_count_token}" -le 1 ]]; then
        prime_topology_request_count_numeric="$prime_topology_request_count_token"
    fi
    prime_topology_request_count="$prime_topology_request_count_numeric"
    prime_topology_collect_explicit_requests_v1 "$@"

    if [[ "$prime_topology_mode" == relation ]]; then
        prime_parse_exact_revision_topology_relation_suffix_v1 "$@"
        if ! prime_topology_is_canonical_decimal_v1 \
                "$prime_topology_request_count_token" \
            || [[ "$prime_topology_request_count_token" == 0 \
                || "${#prime_topology_request_count_token}" -ne 1 ]]; then
            prime_topology_add_candidate_v1 4 0 TOPOLOGY_INVOCATION_INVALID \
                verification_request_count_nonzero ""
        elif [[ "$prime_topology_request_count_token" -gt 6 ]]; then
            prime_topology_add_candidate_v1 5 0 TOPOLOGY_INVOCATION_INVALID \
                verification_request_count_within_bound ""
        fi
        if ! prime_topology_is_canonical_absolute_path_v1 \
                "$prime_topology_repository" \
            && [[ "${prime_topology_pure_repository_placeholder_admitted:-false}" \
                    != true \
                || "$prime_topology_repository" != "<private_repository>" ]]; then
            prime_topology_add_candidate_v1 6 0 TOPOLOGY_INVOCATION_INVALID \
                repository_argument_is_canonical_absolute_admitted_git_worktree ""
        fi
        prime_topology_validate_explicit_values_v1 relation
    else
        if [[ "$prime_topology_request_count_token" == 0 ]]; then
            prime_topology_add_candidate_v1 3 0 TOPOLOGY_INVOCATION_INVALID \
                verification_request_count_nonzero ""
        elif ! prime_topology_is_canonical_decimal_v1 \
                "$prime_topology_request_count_token" \
            || [[ "${#prime_topology_request_count_token}" -ne 1 \
                || "$prime_topology_request_count_token" -gt 8 ]]; then
            prime_topology_add_candidate_v1 4 0 TOPOLOGY_INVOCATION_INVALID \
                verification_request_count_within_bound ""
        fi
        if ! prime_topology_is_canonical_absolute_path_v1 \
                "$prime_topology_repository" \
            && [[ "${prime_topology_pure_repository_placeholder_admitted:-false}" \
                    != true \
                || "$prime_topology_repository" != "<private_repository>" ]]; then
            prime_topology_add_candidate_v1 5 0 TOPOLOGY_INVOCATION_INVALID \
                repository_argument_is_canonical_absolute_admitted_git_worktree ""
        fi
        if [[ "$prime_topology_mode" == current_index ]]; then
            if [[ "$zero_operand_terminal_marker_selects_explicit_request_ordinal1_and_no_marker_flat_calls_are_legacy" \
                    != true \
                || "$prime_topology_current_marker_count" -ne 1 \
                || "$prime_topology_relation_marker_count" -ne 0 \
                || "$prime_topology_current_marker_index" -lt 0 \
                || $((token_count - prime_topology_current_marker_index)) -ne 1 \
                || "$prime_topology_current_marker_index" \
                    -ne "$prime_topology_explicit_end_index" ]]; then
                prime_topology_add_candidate_v1 8 0 \
                    TOPOLOGY_INVOCATION_INVALID \
                    expected_parent_count_within_bound ""
            fi
        elif [[ "$prime_topology_explicit_end_index" -ne "$token_count" ]]; then
            prime_topology_add_candidate_v1 8 0 TOPOLOGY_INVOCATION_INVALID \
                expected_parent_count_within_bound ""
        fi
        prime_topology_validate_explicit_values_v1 ordinary
    fi
    prime_select_exact_revision_topology_result_v1
    [[ -z "$prime_topology_best_phase" ]]
}

# Frozen compatibility name used by the predecessor direct parser matrix.
prime_topology_parse_flat_requests_v1() {
    prime_parse_exact_revision_topology_invocation_v1 "$@"
    [[ "$prime_topology_mode" == ordinary ]]
}

prime_topology_classify_repository_format_observation_v1() {
    local saved_status="$1"
    local observation="$2"
    local schedule="${3:-ordinary}"
    prime_topology_phase_v1 11 "$schedule"
    if [[ "$saved_status" != 0 ]]; then
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" 0 \
            TOPOLOGY_OBSERVATION_FAILED \
            repository_object_format_observation_succeeded ""
        return 0
    fi
    if [[ "$observation" != $'sha1\n' ]]; then
        prime_topology_phase_v1 12 "$schedule"
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" 0 \
            TOPOLOGY_REPOSITORY_UNSUPPORTED repository_object_format_sha1 ""
    fi
}

prime_topology_classifier_mapping_v1() {
    local classifier_status="$1"
    local ordinal="$2"
    local schedule="${3:-ordinary}"
    local flat_phase result guard
    case "$classifier_status" in
        0) return 0 ;;
        20) flat_phase=21; result=TOPOLOGY_OBSERVATION_FAILED; guard=classifier_arguments_match_helper_protocol ;;
        27) flat_phase=22; result=TOPOLOGY_OBSERVATION_FAILED; guard=classifier_inherited_file_descriptors_closed ;;
        21) flat_phase=23; result=TOPOLOGY_OBSERVATION_FAILED; guard=classifier_stdin_read_succeeded ;;
        22) flat_phase=24; result=TOPOLOGY_OBSERVATION_FAILED; guard=classifier_actual_size_within_bound ;;
        23) flat_phase=25; result=TOPOLOGY_OBSERVATION_FAILED; guard=classifier_actual_size_equals_advertised_size ;;
        24) flat_phase=26; result=TOPOLOGY_OBSERVATION_FAILED; guard=classifier_computed_oid_equals_literal_oid ;;
        25) flat_phase=27; result=TOPOLOGY_OBJECT_UNSUPPORTED; guard=classifier_input_is_nul_free ;;
        26) flat_phase=28; result=TOPOLOGY_OBSERVATION_FAILED; guard=classifier_parser_internal_state_valid ;;
        30) flat_phase=29; result=TOPOLOGY_HEADER_MALFORMED; guard=header_lines_and_separator_are_well_formed ;;
        31) flat_phase=30; result=TOPOLOGY_HEADER_MALFORMED; guard=tree_header_is_first_and_unique ;;
        32) flat_phase=31; result=TOPOLOGY_HEADER_MALFORMED; guard=ordered_parent_headers_are_contiguous ;;
        33) flat_phase=32; result=TOPOLOGY_HEADER_MALFORMED; guard=topology_header_oids_are_lowercase_40hex ;;
        34) flat_phase=33; result=TOPOLOGY_HEADER_MALFORMED; guard=signed_header_continuations_are_allowed_and_attached ;;
        41) flat_phase=34; result=TOPOLOGY_MISMATCH; guard=tree_oid_equals_expected ;;
        42) flat_phase=35; result=TOPOLOGY_MISMATCH; guard=ordered_parent_oids_equal_expected ;;
        *) flat_phase=20; result=TOPOLOGY_OBSERVATION_FAILED; guard=classifier_exit_status_known ;;
    esac
    prime_topology_phase_v1 "$flat_phase" "$schedule"
    prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" "$ordinal" \
        "$result" "$guard" ""
}

prime_parse_bounded_status_capture_v1() {
    local capture_kind="${1:-}"
    local outer_status="${2:-}"
    local capture="${3:-}"
    local LC_ALL=C
    [[ "$#" -eq 3 ]] || return 2
    case "$capture_kind" in
        HEAD|clean_status|write_tree|ordinary|relation) ;;
        *) return 2 ;;
    esac
    prime_topology_is_canonical_decimal_v1 "$outer_status" \
        && [[ "${#outer_status}" -le 3 && "$outer_status" -le 255 ]] \
        || return 2

    prime_topology_frame_accepted=false
    prime_topology_capture_body=""
    prime_topology_capture_producer_status=""
    prime_topology_capture_consumer_status=""
    prime_topology_capture_classifier_status=""
    prime_topology_capture_candidate_oid=""
    prime_topology_capture_frame_syntax_valid=false
    prime_topology_capture_payload_valid=false
    prime_topology_capture_known_status=false
    prime_topology_capture_outer_status="$outer_status"

    local maximum_capture_bytes
    case "$capture_kind" in
        HEAD|write_tree) maximum_capture_bytes=64 ;;
        clean_status) maximum_capture_bytes=23 ;;
        ordinary) maximum_capture_bytes=63 ;;
        relation) maximum_capture_bytes=63 ;;
    esac
    if [[ "$outer_status" -ne 0 || "${#capture}" -lt 22 \
        || "${#capture}" -gt "$maximum_capture_bytes" ]]; then
        return 0
    fi
    local trailer="${capture: -22}"
    if [[ ! "$trailer" =~ ^$'\036'prime_status:([0-9]{3}):([0-9]{3})$'\037'$ ]]; then
        return 0
    fi
    prime_topology_capture_producer_status="$((10#${BASH_REMATCH[1]}))"
    prime_topology_capture_consumer_status="$((10#${BASH_REMATCH[2]}))"
    if [[ "$prime_topology_capture_producer_status" -gt 255 \
        || "$prime_topology_capture_consumer_status" -gt 255 ]]; then
        return 0
    fi
    prime_topology_capture_classifier_status="$prime_topology_capture_consumer_status"
    prime_topology_capture_body="${capture:0:${#capture}-22}"
    prime_topology_capture_frame_syntax_valid=true

    case "$capture_kind" in
        HEAD|write_tree)
            if [[ "$prime_topology_capture_producer_status" == 0 \
                && "$prime_topology_capture_consumer_status" == 0 \
                && "${#prime_topology_capture_body}" -eq 41 \
                && "$prime_topology_capture_body" == *$'\n' ]] \
                && prime_topology_is_oid_v1 \
                    "${prime_topology_capture_body%$'\n'}"; then
                prime_topology_frame_accepted=true
                prime_topology_capture_payload_valid=true
            fi
            ;;
        clean_status)
            if [[ "$prime_topology_capture_producer_status" == 0 \
                && "$prime_topology_capture_consumer_status" == 0 \
                && -z "$prime_topology_capture_body" ]]; then
                prime_topology_frame_accepted=true
                prime_topology_capture_payload_valid=true
            fi
            ;;
        ordinary)
            case "$prime_topology_capture_classifier_status" in
                0|20|21|22|23|24|25|26|27|30|31|32|33|34|41|42)
                    prime_topology_capture_known_status=true ;;
            esac
            if [[ "$prime_topology_capture_known_status" == true \
                && -z "$prime_topology_capture_body" ]]; then
                prime_topology_frame_accepted=true
                prime_topology_capture_payload_valid=true
            fi
            ;;
        relation)
            case "$prime_topology_capture_classifier_status" in
                0|20|21|22|23|24|25|26|27|28|30|31|32|33|34|41|42)
                    prime_topology_capture_known_status=true ;;
            esac
            local body_count="${#prime_topology_capture_body}"
            local witness=""
            if [[ "$body_count" -eq 41 \
                && "$prime_topology_capture_body" == *$'\n' ]]; then
                witness="${prime_topology_capture_body%$'\n'}"
            fi
            case "$prime_topology_capture_classifier_status" in
                0)
                    if [[ "$body_count" -eq 41 ]] \
                        && prime_topology_is_oid_v1 "$witness"; then
                        prime_topology_capture_payload_valid=true
                    fi
                    ;;
                41|42)
                    if [[ "$body_count" -eq 0 ]]; then
                        prime_topology_capture_payload_valid=true
                    elif [[ "$body_count" -eq 41 ]] \
                        && prime_topology_is_oid_v1 "$witness"; then
                        prime_topology_capture_payload_valid=true
                    fi
                    ;;
                28)
                    if [[ "$body_count" -le 40 ]]; then
                        prime_topology_capture_payload_valid=true
                    fi
                    ;;
                20|21|22|23|24|25|26|27|30|31|32|33|34)
                    if [[ "$body_count" -eq 0 ]]; then
                        prime_topology_capture_payload_valid=true
                    fi
                    ;;
            esac
            if [[ "$prime_topology_capture_known_status" == true \
                && "$prime_topology_capture_payload_valid" == true ]]; then
                prime_topology_frame_accepted=true
                if [[ "$prime_topology_capture_producer_status" -eq 0 \
                    && "$prime_topology_capture_classifier_status" \
                        =~ ^(0|41|42)$ \
                    && "$body_count" -eq 41 ]]; then
                    prime_topology_capture_candidate_oid="$witness"
                fi
            fi
            ;;
    esac
    return 0
}

prime_topology_classify_framed_raw_observation_v1() {
    local classifier_mode="$1"
    local schedule="$2"
    local ordinal="$3"

    if [[ "$prime_topology_capture_frame_syntax_valid" != true ]]; then
        if [[ "$classifier_mode" == relation ]]; then
            prime_topology_add_candidate_v1 23 "$ordinal" \
                TOPOLOGY_OBSERVATION_FAILED \
                classifier_relation_witness_frame_is_exact ""
        else
            prime_topology_phase_v1 21 "$schedule"
            prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" \
                "$ordinal" TOPOLOGY_OBSERVATION_FAILED \
                classifier_arguments_match_helper_protocol ""
        fi
        return 0
    fi
    if [[ "$prime_topology_capture_producer_status" -ne 0 ]]; then
        prime_topology_phase_v1 19 "$schedule"
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" \
            "$ordinal" TOPOLOGY_OBSERVATION_FAILED \
            git_cat_file_transport_succeeded ""
        return 0
    fi
    if [[ "$prime_topology_capture_known_status" != true ]]; then
        prime_topology_phase_v1 20 "$schedule"
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" \
            "$ordinal" TOPOLOGY_OBSERVATION_FAILED \
            classifier_exit_status_known ""
        return 0
    fi
    if [[ "$prime_topology_capture_payload_valid" != true ]]; then
        if [[ "$classifier_mode" == relation ]]; then
            prime_topology_add_candidate_v1 23 "$ordinal" \
                TOPOLOGY_OBSERVATION_FAILED \
                classifier_relation_witness_frame_is_exact ""
        else
            prime_topology_phase_v1 21 "$schedule"
            prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" \
                "$ordinal" TOPOLOGY_OBSERVATION_FAILED \
                classifier_arguments_match_helper_protocol ""
        fi
        return 0
    fi
    if [[ "$classifier_mode" == relation \
        && "$prime_topology_capture_classifier_status" == 28 ]]; then
        prime_topology_add_candidate_v1 23 "$ordinal" \
            TOPOLOGY_OBSERVATION_FAILED \
            classifier_relation_witness_frame_is_exact ""
        return 0
    fi
    prime_topology_classifier_mapping_v1 \
        "$prime_topology_capture_classifier_status" "$ordinal" "$schedule"
}

prime_topology_classify_pipeline_observation_v1() {
    local git_status="$1"
    local classifier_status="$2"
    local ordinal="$3"
    local schedule="${4:-ordinary}"
    if [[ "$git_status" != 0 ]]; then
        prime_topology_phase_v1 19 "$schedule"
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" \
            "$ordinal" TOPOLOGY_OBSERVATION_FAILED \
            git_cat_file_transport_succeeded ""
    else
        prime_topology_classifier_mapping_v1 \
            "$classifier_status" "$ordinal" "$schedule"
    fi
}

prime_topology_classify_preprobe_lines_v1() {
    local saved_status="$1"
    local observation="$2"
    local schedule="$3"
    local LC_ALL=C
    local -a oids=()
    local -a roles=()
    local -a ordinals=()
    local copy_index
    for (( copy_index = 0; copy_index < ${#prime_topology_wave_oids[@]}; copy_index += 1 )); do
        oids+=( "${prime_topology_wave_oids[copy_index]}" )
        roles+=( "${prime_topology_wave_roles[copy_index]}" )
        ordinals+=( "${prime_topology_wave_ordinals[copy_index]}" )
    done
    local remainder="$observation"
    local index line oid token_oid token_type token_size token_extra ordinal
    prime_topology_wave_sizes=()
    prime_topology_phase_v1 13 "$schedule"
    local availability_observation_phase="$prime_topology_mapped_phase"
    prime_topology_phase_v1 14 "$schedule"
    local required_availability_phase="$prime_topology_mapped_phase"
    prime_topology_phase_v1 15 "$schedule"
    local type_observation_phase="$prime_topology_mapped_phase"
    prime_topology_phase_v1 16 "$schedule"
    local required_type_phase="$prime_topology_mapped_phase"
    prime_topology_phase_v1 17 "$schedule"
    local size_observation_phase="$prime_topology_mapped_phase"
    prime_topology_phase_v1 18 "$schedule"
    local size_bound_phase="$prime_topology_mapped_phase"

    if [[ "$saved_status" != 0 || "${#observation}" -gt 1024 ]]; then
        prime_topology_add_candidate_v1 "$availability_observation_phase" \
            "${ordinals[0]:-0}" TOPOLOGY_OBSERVATION_FAILED \
            object_availability_observation_succeeded ""
        return 0
    fi
    for (( index = 0; index < ${#oids[@]}; index += 1 )); do
        ordinal="${ordinals[index]}"
        oid="${oids[index]}"
        if [[ "$remainder" != *$'\n'* ]]; then
            line=""
            prime_topology_add_candidate_v1 "$availability_observation_phase" \
                "$ordinal" TOPOLOGY_OBSERVATION_FAILED \
                object_availability_observation_succeeded ""
        else
            line="${remainder%%$'\n'*}"
            remainder="${remainder#*$'\n'}"
        fi
        if [[ "$line" == "$oid missing" ]]; then
            prime_topology_add_candidate_v1 "$required_availability_phase" \
                "$ordinal" TOPOLOGY_OBJECT_UNAVAILABLE \
                required_object_availability "${roles[index]}"
            prime_topology_wave_sizes+=( 0 )
            continue
        fi
        IFS=' ' builtin read -r token_oid token_type token_size token_extra \
            <<< "$line"
        if [[ "$token_oid" != "$oid" || -z "$token_type" \
            || -z "$token_size" || -n "$token_extra" \
            || "$line" != "$token_oid $token_type $token_size" ]]; then
            prime_topology_add_candidate_v1 "$availability_observation_phase" \
                "$ordinal" TOPOLOGY_OBSERVATION_FAILED \
                object_availability_observation_succeeded ""
            prime_topology_wave_sizes+=( 0 )
            continue
        fi
        case "$token_type" in
            blob|commit|tag|tree) ;;
            *)
                prime_topology_add_candidate_v1 "$type_observation_phase" \
                    "$ordinal" TOPOLOGY_OBSERVATION_FAILED \
                    object_type_observation_succeeded ""
                ;;
        esac
        if [[ "$token_type" != commit \
            && "$token_type" =~ ^(blob|commit|tag|tree)$ ]]; then
            prime_topology_add_candidate_v1 "$required_type_phase" \
                "$ordinal" TOPOLOGY_OBJECT_NOT_COMMIT \
                required_object_type_commit ""
        fi
        if ! prime_topology_is_canonical_decimal_v1 "$token_size"; then
            prime_topology_add_candidate_v1 "$size_observation_phase" \
                "$ordinal" TOPOLOGY_OBSERVATION_FAILED \
                object_size_observation_succeeded ""
            prime_topology_wave_sizes+=( 0 )
            continue
        fi
        if [[ "${#token_size}" -gt 7 \
            || ( "${#token_size}" -eq 7 && "$token_size" > 1048576 ) ]]; then
            prime_topology_add_candidate_v1 "$size_bound_phase" "$ordinal" \
                TOPOLOGY_OBJECT_UNSUPPORTED object_size_within_bound ""
        fi
        prime_topology_wave_sizes+=( "$token_size" )
    done
    if [[ -n "$remainder" ]]; then
        prime_topology_add_candidate_v1 "$availability_observation_phase" \
            "${ordinals[0]:-0}" TOPOLOGY_OBSERVATION_FAILED \
            object_availability_observation_succeeded ""
    fi
}

# Frozen predecessor adapter. It is pure, process-free, and flat-only.
prime_test_classify_exact_revision_topology_observation_v1() {
    local observation_kind="${1:-}"
    local saved_git_status="${2:-}"
    local saved_classifier_status="${3:-}"
    local observation="${4:-}"
    [[ "${5:-}" == -- ]] || return 2
    shift 5

    local prime_topology_repository=""
    local prime_topology_request_count=""
    local prime_topology_request_count_token=""
    local prime_topology_request_count_numeric=0
    local prime_topology_mode=ordinary
    local prime_topology_relation_marker_index=-1
    local prime_topology_relation_marker_count=0
    local prime_topology_current_marker_index=-1
    local prime_topology_current_marker_count=0
    local prime_topology_relation_suffix_operand_count=0
    local prime_topology_pure_repository_placeholder_admitted=true
    local prime_topology_explicit_end_index=0
    local prime_topology_request_shape_valid=true
    local -a prime_topology_request_roles=()
    local -a prime_topology_request_oids=()
    local -a prime_topology_request_trees=()
    local -a prime_topology_request_parent_counts=()
    local -a prime_topology_request_parent_offsets=()
    local -a prime_topology_request_parents=()
    local -a prime_topology_all_roles=()
    local -a prime_topology_candidate_phases=()
    local -a prime_topology_candidate_ordinals=()
    local -a prime_topology_candidate_result_codes=()
    local -a prime_topology_candidate_guard_ids=()
    local -a prime_topology_candidate_missing_roles=()
    local prime_topology_best_phase=""
    local prime_topology_best_ordinal=""
    local prime_topology_best_result_code=""
    local prime_topology_best_guard_id=""
    local prime_topology_best_missing_role=""
    local -a prime_topology_wave_oids=()
    local -a prime_topology_wave_roles=()
    local -a prime_topology_wave_ordinals=()
    local -a prime_topology_wave_sizes=()

    prime_parse_exact_revision_topology_invocation_v1 "$@" || true
    if [[ "$prime_topology_mode" != ordinary ]]; then return 2; fi
    if [[ -z "$prime_topology_best_phase" ]]; then
        case "$observation_kind" in
            invocation) ;;
            repository_format)
                [[ "$saved_classifier_status" == null ]] || return 2
                prime_topology_classify_repository_format_observation_v1 \
                    "$saved_git_status" "$observation" ordinary
                ;;
            batch_preprobe)
                [[ "$saved_classifier_status" == null ]] || return 2
                local adapter_index
                for (( adapter_index = 1; adapter_index <= prime_topology_request_count; adapter_index += 1 )); do
                    prime_topology_wave_oids+=(
                        "${prime_topology_request_oids[adapter_index - 1]}"
                    )
                    prime_topology_wave_roles+=(
                        "${prime_topology_request_roles[adapter_index - 1]}"
                    )
                    prime_topology_wave_ordinals+=( "$adapter_index" )
                done
                prime_topology_classify_preprobe_lines_v1 \
                    "$saved_git_status" "$observation" ordinary
                ;;
            pipeline_status)
                prime_topology_classify_pipeline_observation_v1 \
                    "$saved_git_status" "$saved_classifier_status" 1 ordinary
                ;;
            *) return 2 ;;
        esac
    fi
    prime_select_exact_revision_topology_result_v1
    if [[ -z "$prime_topology_best_phase" ]]; then
        prime_topology_test_result_code=TOPOLOGY_VERIFIED
        prime_topology_test_first_failed_guard_id=""
    else
        prime_topology_test_result_code="$prime_topology_best_result_code"
        prime_topology_test_first_failed_guard_id="$prime_topology_best_guard_id"
    fi
    return 0
}

prime_test_exact_revision_topology_hook_core_v1() {
    PRIME_TEST_MODE=""
    PRIME_TEST_ACCEPTED=false
    PRIME_TEST_RESULT_CODE=""
    PRIME_TEST_GUARD_ID=""
    PRIME_TEST_PHASE_ORDINAL=""
    PRIME_TEST_OBJECT_ORDINAL=""
    PRIME_TEST_CLASSIFIER_STATUS=""
    PRIME_TEST_CANDIDATE_PRESENT=false
    PRIME_TEST_MISSING_ROLE=""
    PRIME_TEST_PRIVATE_CANDIDATE_OID=""

    local hook_mode="${1:-}"
    [[ "$#" -ge 1 ]] || return 2
    shift
    case "$hook_mode" in
        invocation)
            [[ "$#" -ge 1 ]] || return 2
            local token_count="$1"
            shift
            prime_topology_is_canonical_decimal_v1 "$token_count" \
                && [[ "${#token_count}" -le 3 \
                    && "$token_count" -eq "$#" ]] || return 2

            local prime_topology_repository=""
            local prime_topology_request_count=""
            local prime_topology_request_count_token=""
            local prime_topology_request_count_numeric=0
            local prime_topology_mode=ordinary
            local prime_topology_relation_marker_index=-1
            local prime_topology_relation_marker_count=0
            local prime_topology_current_marker_index=-1
            local prime_topology_current_marker_count=0
            local prime_topology_relation_suffix_operand_count=0
            local prime_topology_pure_repository_placeholder_admitted=true
            local prime_topology_explicit_end_index=0
            local prime_topology_request_shape_valid=true
            local prime_topology_relation_merge_role=""
            local prime_topology_relation_merge_oid=""
            local prime_topology_relation_index_tree=""
            local prime_topology_relation_fixed_parent=""
            local prime_topology_relation_child_role=""
            local -a prime_topology_request_roles=()
            local -a prime_topology_request_oids=()
            local -a prime_topology_request_trees=()
            local -a prime_topology_request_parent_counts=()
            local -a prime_topology_request_parent_offsets=()
            local -a prime_topology_request_parents=()
            local -a prime_topology_all_roles=()
            local -a prime_topology_candidate_phases=()
            local -a prime_topology_candidate_ordinals=()
            local -a prime_topology_candidate_result_codes=()
            local -a prime_topology_candidate_guard_ids=()
            local -a prime_topology_candidate_missing_roles=()
            local prime_topology_best_phase=""
            local prime_topology_best_ordinal=""
            local prime_topology_best_result_code=""
            local prime_topology_best_guard_id=""
            local prime_topology_best_missing_role=""
            prime_parse_exact_revision_topology_invocation_v1 "$@" || true
            PRIME_TEST_MODE="$prime_topology_mode"
            if [[ -z "$prime_topology_best_phase" ]]; then
                PRIME_TEST_ACCEPTED=true
                PRIME_TEST_RESULT_CODE=PARSER_ACCEPTED
            else
                PRIME_TEST_RESULT_CODE="$prime_topology_best_result_code"
                PRIME_TEST_GUARD_ID="$prime_topology_best_guard_id"
                PRIME_TEST_PHASE_ORDINAL="$prime_topology_best_phase"
                if [[ "$prime_topology_best_ordinal" != 0 ]]; then
                    PRIME_TEST_OBJECT_ORDINAL="$prime_topology_best_ordinal"
                fi
                PRIME_TEST_MISSING_ROLE="$prime_topology_best_missing_role"
            fi
            ;;
        probe)
            [[ "$#" -eq 3 ]] || return 2
            local probe_kind="$1"
            local outer_status="$2"
            local raw_capture="$3"
            case "$probe_kind" in HEAD|clean_status|write_tree) ;; *) return 2 ;; esac
            prime_parse_bounded_status_capture_v1 \
                "$probe_kind" "$outer_status" "$raw_capture" || return 2
            PRIME_TEST_MODE=probe
            PRIME_TEST_ACCEPTED="$prime_topology_frame_accepted"
            ;;
        relation_frame)
            [[ "$#" -eq 3 ]] || return 2
            local classifier_mode="$1"
            local frame_outer_status="$2"
            local frame_capture="$3"
            case "$classifier_mode" in ordinary|relation) ;; *) return 2 ;; esac
            local -a prime_topology_candidate_phases=()
            local -a prime_topology_candidate_ordinals=()
            local -a prime_topology_candidate_result_codes=()
            local -a prime_topology_candidate_guard_ids=()
            local -a prime_topology_candidate_missing_roles=()
            local prime_topology_best_phase=""
            local prime_topology_best_ordinal=""
            local prime_topology_best_result_code=""
            local prime_topology_best_guard_id=""
            local prime_topology_best_missing_role=""
            prime_parse_bounded_status_capture_v1 \
                "$classifier_mode" "$frame_outer_status" "$frame_capture" \
                || return 2
            prime_topology_classify_framed_raw_observation_v1 \
                "$classifier_mode" relation 1
            prime_select_exact_revision_topology_result_v1
            PRIME_TEST_MODE=relation_frame
            PRIME_TEST_ACCEPTED="$prime_topology_frame_accepted"
            PRIME_TEST_CLASSIFIER_STATUS="$prime_topology_capture_classifier_status"
            if [[ -n "$prime_topology_capture_candidate_oid" ]]; then
                PRIME_TEST_CANDIDATE_PRESENT=true
                PRIME_TEST_PRIVATE_CANDIDATE_OID="$prime_topology_capture_candidate_oid"
            fi
            if [[ -z "$prime_topology_best_phase" ]]; then
                PRIME_TEST_RESULT_CODE=TOPOLOGY_VERIFIED
            else
                PRIME_TEST_RESULT_CODE="$prime_topology_best_result_code"
                PRIME_TEST_GUARD_ID="$prime_topology_best_guard_id"
                PRIME_TEST_PHASE_ORDINAL="$prime_topology_best_phase"
                PRIME_TEST_OBJECT_ORDINAL="$prime_topology_best_ordinal"
                PRIME_TEST_MISSING_ROLE="$prime_topology_best_missing_role"
            fi
            # A sealed one-way child may retain the candidate only until its
            # immediate in-memory cross-binding assertion and explicit scrub.
            # Ordinary parent hook calls never return a private candidate.
            if [[ -z "${prime_topology_closed_child_v1+x}" ]]; then
                PRIME_TEST_PRIVATE_CANDIDATE_OID=""
            fi
            ;;
        selector)
            [[ "$#" -ge 1 ]] || return 2
            local candidate_count="$1"
            shift
            prime_topology_is_canonical_decimal_v1 "$candidate_count" \
                && [[ "${#candidate_count}" -le 2 \
                    && "$candidate_count" -le 32 \
                    && "$#" -eq $((candidate_count * 5)) ]] || return 2
            local -a prime_topology_candidate_phases=()
            local -a prime_topology_candidate_ordinals=()
            local -a prime_topology_candidate_result_codes=()
            local -a prime_topology_candidate_guard_ids=()
            local -a prime_topology_candidate_missing_roles=()
            local prime_topology_best_phase=""
            local prime_topology_best_ordinal=""
            local prime_topology_best_result_code=""
            local prime_topology_best_guard_id=""
            local prime_topology_best_missing_role=""
            local index phase ordinal result guard missing
            for (( index = 0; index < candidate_count; index += 1 )); do
                phase="$1"; ordinal="$2"; result="$3"; guard="$4"; missing="$5"
                shift 5
                prime_topology_is_canonical_decimal_v1 "$phase" \
                    && [[ "$phase" -ge 1 && "$phase" -le 38 ]] \
                    && prime_topology_is_canonical_decimal_v1 "$ordinal" \
                    && [[ "$ordinal" -le 8 ]] \
                    && prime_topology_is_guard_id_v1 "$guard" \
                    || return 2
                case "$result" in
                    TOPOLOGY_INVOCATION_INVALID|TOPOLOGY_VERIFIER_UNAVAILABLE|\
                    TOPOLOGY_OBJECT_UNAVAILABLE|TOPOLOGY_OBJECT_NOT_COMMIT|\
                    TOPOLOGY_OBJECT_UNSUPPORTED|TOPOLOGY_REPOSITORY_UNSUPPORTED|\
                    TOPOLOGY_OBSERVATION_FAILED|TOPOLOGY_HEADER_MALFORMED|\
                    TOPOLOGY_MISMATCH) ;;
                    *) return 2 ;;
                esac
                if [[ "$result" == TOPOLOGY_OBJECT_UNAVAILABLE ]]; then
                    prime_topology_is_role_v1 "$missing" || return 2
                elif [[ -n "$missing" ]]; then
                    return 2
                fi
                prime_topology_add_candidate_v1 \
                    "$phase" "$ordinal" "$result" "$guard" "$missing"
            done
            prime_select_exact_revision_topology_result_v1
            PRIME_TEST_MODE=selector
            PRIME_TEST_ACCEPTED=true
            if [[ -n "$prime_topology_best_phase" ]]; then
                PRIME_TEST_CANDIDATE_PRESENT=true
                PRIME_TEST_RESULT_CODE="$prime_topology_best_result_code"
                PRIME_TEST_GUARD_ID="$prime_topology_best_guard_id"
                PRIME_TEST_PHASE_ORDINAL="$prime_topology_best_phase"
                PRIME_TEST_OBJECT_ORDINAL="$prime_topology_best_ordinal"
                PRIME_TEST_MISSING_ROLE="$prime_topology_best_missing_role"
            else
                PRIME_TEST_RESULT_CODE=TOPOLOGY_VERIFIED
            fi
            ;;
        *) return 2 ;;
    esac
    return 0
}

prime_test_exact_revision_topology_v1() {
    PRIME_TEST_MODE=""
    PRIME_TEST_ACCEPTED=false
    PRIME_TEST_RESULT_CODE=""
    PRIME_TEST_GUARD_ID=""
    PRIME_TEST_PHASE_ORDINAL=""
    PRIME_TEST_OBJECT_ORDINAL=""
    PRIME_TEST_CLASSIFIER_STATUS=""
    PRIME_TEST_CANDIDATE_PRESENT=false
    PRIME_TEST_MISSING_ROLE=""
    PRIME_TEST_PRIVATE_CANDIDATE_OID=""

    local hook_mode="${1:-}"
    local hook_status
    local hook_runs_in_closed_child=false
    if [[ "$hook_mode" == relation_frame ]]; then
        if [[ -n "${prime_topology_closed_child_v1+x}" ]]; then
            hook_runs_in_closed_child=true
            prime_topology_admit_closed_child_state_v1 || return 2
        elif ! prime_topology_begin_closed_trace_entry_v1; then
            prime_topology_arm_trace_watcher_v1
            return 2
        fi
    fi
    if prime_test_exact_revision_topology_hook_core_v1 "$@"; then
        hook_status=0
    else
        hook_status="$?"
    fi
    if [[ "$hook_mode" == relation_frame \
        && "$hook_runs_in_closed_child" == false \
        && ! -o functrace ]]; then
        prime_topology_arm_trace_watcher_v1
    fi
    return "$hook_status"
}

prime_clear_exact_revision_topology_private_candidate_v1() {
    [[ -n "${prime_topology_closed_child_v1+x}" ]] || return 2
    # Scrub before validating any remaining caller-controlled state so misuse
    # cannot strand a previously cross-bound private candidate in the child.
    PRIME_TEST_PRIVATE_CANDIDATE_OID=""
    [[ "$#" -eq 0 ]] || return 2
    prime_topology_admit_closed_child_state_v1 || return 2
}

prime_topology_capture_text_v1() {
    local maximum_body_bytes="$1"
    shift
    local capture command_status trailer
    local LC_ALL=C
    capture="$(
        "$@" 2>/dev/null
        command_status="$?"
        builtin printf '\036prime_status:%03d\037' "$command_status"
    )" || return 1
    [[ "${#capture}" -ge 18 ]] || return 1
    trailer="${capture: -18}"
    [[ "$trailer" =~ ^$'\036'prime_status:([0-9]{3})$'\037'$ ]] || return 1
    prime_topology_capture_status="$((10#${BASH_REMATCH[1]}))"
    [[ "$prime_topology_capture_status" -le 255 ]] || return 1
    prime_topology_capture_body="${capture:0:${#capture}-18}"
    [[ "${#prime_topology_capture_body}" -le "$maximum_body_bytes" ]]
}

prime_admit_exact_revision_topology_tools_v1() {
    local -r every_fixed_tool_path_mode_and_owner_admission_succeeds=true
    local -r any_fixed_tool_admission_failure_selects_fixed_verifier_tools_admitted=TOPOLOGY_VERIFIER_UNAVAILABLE
    local tool metadata
    for tool in /bin/bash /usr/bin/git /usr/bin/env /usr/bin/head \
            /usr/bin/mktemp /usr/bin/stat /usr/bin/xcrun; do
        [[ -f "$tool" && ! -L "$tool" && -x "$tool" ]] || return 1
    done
    [[ -c /dev/null && ! -L /dev/null ]] || return 1
    for tool in /bin/bash /usr/bin/git /usr/bin/env /usr/bin/head \
            /usr/bin/mktemp /usr/bin/stat /usr/bin/xcrun; do
        metadata="$(LC_ALL=C /usr/bin/stat -f '%u %p %HT' -- "$tool" 2>/dev/null)" \
            || return 1
        [[ "$metadata" =~ ^0[[:space:]]100[0-7]{3}[[:space:]]Regular[[:space:]]File$ ]] \
            || return 1
    done
    [[ "$every_fixed_tool_path_mode_and_owner_admission_succeeds" == true \
        && "$any_fixed_tool_admission_failure_selects_fixed_verifier_tools_admitted" \
            == TOPOLOGY_VERIFIER_UNAVAILABLE ]]
}

prime_topology_admit_runner_temp_v1() {
    local admitted_runner_temp="$1"
    prime_topology_is_canonical_absolute_path_v1 "$admitted_runner_temp" \
        || return 1
    [[ -d "$admitted_runner_temp" && ! -L "$admitted_runner_temp" \
        && -w "$admitted_runner_temp" && -O "$admitted_runner_temp" ]] \
        || return 1
    local physical metadata
    physical="$(builtin cd "$admitted_runner_temp" 2>/dev/null \
        && builtin pwd -P)" || return 1
    [[ "$physical" == "$admitted_runner_temp" ]] || return 1
    prime_topology_capture_text_v1 128 \
        /usr/bin/stat -f '%u %p %HT' -- "$admitted_runner_temp" || return 1
    metadata="$prime_topology_capture_body"
    [[ "$prime_topology_capture_status" == 0 \
        && "$metadata" =~ ^${EUID}[[:space:]]40[0-7]{3}[[:space:]]Directory$'\n'$ ]]
}

prime_topology_admit_repository_builtin_v1() {
    local repository="$1"
    prime_topology_is_canonical_absolute_path_v1 "$repository" || return 1
    [[ -d "$repository" && ! -L "$repository" && -w "$repository" \
        && -O "$repository" ]] || return 1
    local physical
    physical="$(builtin cd "$repository" 2>/dev/null && builtin pwd -P)" \
        || return 1
    [[ "$physical" == "$repository" ]] || return 1
    [[ ( -d "$repository/.git" || -f "$repository/.git" ) \
        && ! -L "$repository/.git" ]]
}

prime_topology_bootstrap_git_v1() {
    local bootstrap_temp="$1"
    shift
    /usr/bin/env -i LC_ALL=C TMPDIR="$bootstrap_temp" \
        GIT_NO_REPLACE_OBJECTS=1 GIT_NO_LAZY_FETCH=1 \
        GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null \
        GIT_TERMINAL_PROMPT=0 GIT_OPTIONAL_LOCKS=0 \
        /usr/bin/git "$@"
}

prime_topology_admit_source_root_v1() {
    local source_root="$1"
    local admitted_runner_temp="$2"
    prime_topology_is_canonical_absolute_path_v1 "$source_root" || return 1
    [[ -d "$source_root" && ! -L "$source_root" ]] || return 1
    local physical
    physical="$(builtin cd "$source_root" 2>/dev/null && builtin pwd -P)" \
        || return 1
    [[ "$physical" == "$source_root" && "$PWD" == "$source_root" ]] \
        || return 1

    local metadata
    metadata="$(LC_ALL=C /usr/bin/stat -f '%u %p %HT' -- "$source_root" 2>/dev/null)" \
        || return 1
    [[ "$metadata" =~ ^${EUID}[[:space:]]40[0-7]{3}[[:space:]]Directory$ ]] \
        || return 1

    prime_topology_bootstrap_git_v1 "$admitted_runner_temp" \
        -C "$source_root" diff --quiet --no-ext-diff --no-textconv -- \
        >/dev/null 2>&1 || return 1
    prime_topology_bootstrap_git_v1 "$admitted_runner_temp" \
        -C "$source_root" diff --cached --quiet --no-ext-diff --no-textconv -- \
        >/dev/null 2>&1 || return 1
    prime_topology_capture_text_v1 4096 \
        prime_topology_bootstrap_git_v1 "$admitted_runner_temp" \
        -C "$source_root" status --porcelain=v1 --untracked-files=normal \
        || return 1
    [[ "$prime_topology_capture_status" == 0 \
        && -z "$prime_topology_capture_body" ]] || return 1

    local path expected_mode stage index_blob worktree_blob head_blob index
    local -a paths=(
        .github/scripts/PrimeExactRevisionTopologyClassifier.swift
        .github/scripts/prime-ci-exact-revision-topology-verifier.sh
        .github/scripts/prime-ci-exact-revision-topology-verifier-test.sh
    )
    local -a modes=( 100644 100755 100755 )
    for (( index = 0; index < 3; index += 1 )); do
        path="${paths[index]}"
        expected_mode="${modes[index]}"
        [[ -f "$source_root/$path" && ! -L "$source_root/$path" ]] \
            || return 1
        prime_topology_capture_text_v1 256 \
            prime_topology_bootstrap_git_v1 "$admitted_runner_temp" \
            -C "$source_root" ls-files --stage -- "$path" || return 1
        [[ "$prime_topology_capture_status" == 0 \
            && "$prime_topology_capture_body" \
                == "$expected_mode "[0-9a-f][0-9a-f][0-9a-f][0-9a-f]*$' 0\t'"$path"$'\n' ]] \
            || return 1
        stage="${prime_topology_capture_body%$'\n'}"
        index_blob="${stage#* }"
        index_blob="${index_blob%% *}"
        prime_topology_is_oid_v1 "$index_blob" || return 1
        prime_topology_capture_text_v1 64 \
            prime_topology_bootstrap_git_v1 "$admitted_runner_temp" \
            -C "$source_root" hash-object --no-filters -- "$path" || return 1
        [[ "$prime_topology_capture_status" == 0 \
            && "$prime_topology_capture_body" == "$index_blob"$'\n' ]] \
            || return 1
        worktree_blob="${prime_topology_capture_body%$'\n'}"
        prime_topology_capture_text_v1 64 \
            prime_topology_bootstrap_git_v1 "$admitted_runner_temp" \
            -C "$source_root" rev-parse --verify "HEAD:$path" || return 1
        [[ "$prime_topology_capture_status" == 0 ]] || return 1
        head_blob="${prime_topology_capture_body%$'\n'}"
        [[ "$head_blob" == "$index_blob" && "$worktree_blob" == "$index_blob" ]] \
            || return 1
    done
}

prime_topology_create_private_root_v1() {
    local capture command_status trailer body root metadata
    local LC_ALL=C
    capture="$(
        builtin umask 0077
        /usr/bin/mktemp -d \
            "$prime_topology_admitted_runner_temp/prime-topology-classifier.XXXXXXXX" \
            2>/dev/null
        command_status="$?"
        builtin printf '\036prime_status:%03d\037' "$command_status"
    )" || return 1
    [[ "${#capture}" -ge 18 && "${#capture}" -le 1078 ]] || return 1
    trailer="${capture: -18}"
    [[ "$trailer" =~ ^$'\036'prime_status:([0-9]{3})$'\037'$ \
        && "$((10#${BASH_REMATCH[1]}))" == 0 ]] || return 1
    body="${capture:0:${#capture}-18}"
    [[ "${#body}" -le 1060 ]] || return 1
    root="${body%$'\n'}"
    local leaf="${root##*/}"
    [[ "$body" == "$root"$'\n' \
        && "$root" == "$prime_topology_admitted_runner_temp"/prime-topology-classifier.* \
        && "$leaf" =~ ^prime-topology-classifier\.[A-Za-z0-9]{8}$ \
        && -d "$root" && ! -L "$root" && -O "$root" && -w "$root" ]] \
        || return 1
    prime_topology_capture_text_v1 128 \
        /usr/bin/stat -f '%u %p %HT' -- "$root" || return 1
    metadata="$prime_topology_capture_body"
    [[ "$prime_topology_capture_status" == 0 \
        && "$metadata" == "$EUID 40700 Directory"$'\n' ]] || return 1
    prime_topology_private_root="$root"
}

prime_build_exact_revision_topology_classifier_v1() {
    local -r swiftc_binary_admission_and_empty_stdin_self_test_all_succeed=true
    local -r compile_import_binary_admission_or_self_test_failure_selects_classifier_build_and_self_test_admitted=TOPOLOGY_VERIFIER_UNAVAILABLE
    local source_root="$1"
    local override
    for override in DEVELOPER_DIR SDKROOT SWIFT_DRIVER_SWIFT_EXEC \
            SWIFT_DRIVER_SWIFT_FRONTEND_EXEC SWIFT_EXEC TOOLCHAINS; do
        [[ -z "${!override+x}" ]] || return 1
    done
    prime_topology_create_private_root_v1 || return 1

    local executable="$prime_topology_private_root/prime-exact-revision-topology-classifier"
    local compile_stdout="$prime_topology_private_root/compiler.stdout"
    local compile_stderr="$prime_topology_private_root/compiler.stderr"
    [[ ! -e "$executable" && ! -L "$executable" ]] || return 1
    (
        builtin umask 0077
        builtin cd "$source_root" || exit 1
        /usr/bin/env -i LC_ALL=C TMPDIR="$prime_topology_private_root" \
            CLANG_MODULE_CACHE_PATH="$prime_topology_private_root/clang-module-cache" \
            /usr/bin/xcrun swiftc \
            .github/scripts/PrimeExactRevisionTopologyClassifier.swift \
            -o "$executable"
    ) >"$compile_stdout" 2>"$compile_stderr"
    local compile_status="$?"
    [[ "$compile_status" == 0 && ! -s "$compile_stdout" \
        && ! -s "$compile_stderr" && -f "$executable" \
        && ! -L "$executable" && -x "$executable" ]] || return 1

    prime_topology_capture_text_v1 128 \
        /usr/bin/stat -f '%u %p %HT' -- "$executable" || return 1
    [[ "$prime_topology_capture_status" == 0 \
        && "$prime_topology_capture_body" \
            =~ ^${EUID}[[:space:]]100700[[:space:]]Regular[[:space:]]File$'\n'$ ]] \
        || return 1

    local self_test_stdout="$prime_topology_private_root/self-test.stdout"
    local self_test_stderr="$prime_topology_private_root/self-test.stderr"
    /usr/bin/env -i LC_ALL=C TMPDIR="$prime_topology_private_root" \
        "$executable" --self-test </dev/null \
        >"$self_test_stdout" 2>"$self_test_stderr"
    local self_test_status="$?"
    [[ "$self_test_status" == 0 && ! -s "$self_test_stdout" \
        && ! -s "$self_test_stderr" \
        && "$swiftc_binary_admission_and_empty_stdin_self_test_all_succeed" == true \
        && "$compile_import_binary_admission_or_self_test_failure_selects_classifier_build_and_self_test_admitted" \
            == TOPOLOGY_VERIFIER_UNAVAILABLE ]] || return 1
    prime_topology_classifier_executable="$executable"
}

prime_topology_git_v1() {
    /usr/bin/env -i LC_ALL=C TMPDIR="$prime_topology_private_root" \
        GIT_NO_REPLACE_OBJECTS=1 GIT_NO_LAZY_FETCH=1 \
        GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null \
        GIT_TERMINAL_PROMPT=0 GIT_OPTIONAL_LOCKS=0 \
        /usr/bin/git "$@"
}

prime_admit_exact_revision_topology_trace_state_v1() {
    local -r private_parent2_never_enters_xtrace_verbose_DEBUG_RETURN_ERR_errtrace_functrace_BASH_XTRACEFD_or_PS4_output=true
    if [[ -n "${prime_topology_closed_child_v1+x}" ]]; then
        prime_topology_admit_closed_child_state_v1
        return "$?"
    fi
    [[ "$-" != *x* && "$-" != *v* ]] || return 1
    [[ ! -o errtrace && ! -o functrace ]] || return 1
    [[ -z "${BASH_XTRACEFD+x}" ]] || return 1
    [[ "${PS4-+ }" == "+ " ]] || return 1
    [[ "$prime_topology_source_had_debug_trap" == false \
        && "$prime_topology_source_had_return_trap" == false \
        && "$prime_topology_source_had_err_trap" == false \
        && "$prime_topology_source_had_functrace" == false ]] || return 1
    [[ -z "${prime_topology_after_source_trap_presence_v1+x}" ]] \
        || return 1
    local trace_scratch="$prime_topology_private_root/trace-state.scratch"
    local saved_umask
    saved_umask="$(builtin umask)" || return 1
    builtin umask 0077
    builtin trap -p DEBUG RETURN ERR >"$trace_scratch" || {
        builtin umask "$saved_umask"
        return 1
    }
    builtin umask "$saved_umask"
    [[ -f "$trace_scratch" && ! -L "$trace_scratch" \
        && ! -s "$trace_scratch" ]] || {
        : >"$trace_scratch"
        return 1
    }
    : >"$trace_scratch"
    [[ ! -s "$trace_scratch" \
        && "$private_parent2_never_enters_xtrace_verbose_DEBUG_RETURN_ERR_errtrace_functrace_BASH_XTRACEFD_or_PS4_output" \
            == true ]]
}

prime_capture_exact_revision_topology_probe_v1() {
    local probe_kind="$1"
    local repository="$2"
    local capture cap outer_status
    local -a git_arguments
    case "$probe_kind" in
        HEAD)
            cap=42
            git_arguments=( -C "$repository" rev-parse --verify HEAD )
            ;;
        clean_status)
            cap=1
            git_arguments=( -C "$repository" status --porcelain=v1 --untracked-files=all )
            ;;
        write_tree)
            cap=42
            git_arguments=( -C "$repository" write-tree )
            ;;
        *) return 2 ;;
    esac
    capture="$(
        local restore_errexit=false
        local -a probe_statuses
        if [[ "$-" == *e* ]]; then
            restore_errexit=true
            set +e
        fi
        prime_topology_git_v1 "${git_arguments[@]}" 2>&1 \
            | /usr/bin/env -i LC_ALL=C /usr/bin/head -c "$cap" 2>/dev/null
        probe_statuses=( "${PIPESTATUS[@]}" )
        if [[ "$restore_errexit" == true ]]; then set -e; fi
        if [[ "${#probe_statuses[@]}" == 2 ]]; then
            builtin printf '\036prime_status:%03d:%03d\037' \
                "${probe_statuses[0]}" "${probe_statuses[1]}"
        else
            builtin printf '\036prime_status:255:255\037'
        fi
    )"
    outer_status="$?"
    prime_parse_bounded_status_capture_v1 \
        "$probe_kind" "$outer_status" "$capture" || return 2
    [[ "$prime_topology_frame_accepted" == true ]]
}

prime_preprobe_exact_revision_topology_objects_v1() {
    local schedule="$1"
    local -r relation_two_wave_preprobe_phase14_through19_before_phase20_plus_selection=true
    local capture trailer body outer_status
    local LC_ALL=C
    capture="$(
        local restore_errexit=false
        local -a preprobe_statuses
        if [[ "$-" == *e* ]]; then
            restore_errexit=true
            set +e
        fi
        {
            local oid
            for oid in "${prime_topology_wave_oids[@]}"; do
                builtin printf '%s\n' "$oid" || exit 255
            done
        } | prime_topology_git_v1 -C "$prime_topology_repository" \
            cat-file '--batch-check=%(objectname) %(objecttype) %(objectsize)' \
            2>"$prime_topology_private_root/preprobe-${prime_topology_preprobe_wave_id}.stderr"
        preprobe_statuses=( "${PIPESTATUS[@]}" )
        if [[ "$restore_errexit" == true ]]; then set -e; fi
        if [[ "${#preprobe_statuses[@]}" == 2 ]]; then
            builtin printf '\036prime_status:%03d:%03d\037' \
                "${preprobe_statuses[0]}" "${preprobe_statuses[1]}"
        else
            builtin printf '\036prime_status:255:255\037'
        fi
    )"
    outer_status="$?"
    prime_topology_preprobe_status=255
    body=""
    if [[ "$outer_status" == 0 && "${#capture}" -ge 22 \
        && "${#capture}" -le 1046 ]]; then
        trailer="${capture: -22}"
        if [[ "$trailer" \
            =~ ^$'\036'prime_status:([0-9]{3}):([0-9]{3})$'\037'$ ]]; then
            if [[ "$((10#${BASH_REMATCH[1]}))" == 0 ]]; then
                prime_topology_preprobe_status="$((10#${BASH_REMATCH[2]}))"
            fi
            body="${capture:0:${#capture}-22}"
        fi
    fi
    prime_topology_classify_preprobe_lines_v1 \
        "$prime_topology_preprobe_status" "$body" "$schedule"
    [[ "$relation_two_wave_preprobe_phase14_through19_before_phase20_plus_selection" \
        == true ]]
}

prime_capture_exact_revision_topology_relation_witness_v1() {
    local classifier_mode="$1"
    local schedule="$2"
    local ordinal="$3"
    local oid="$4"
    local size="$5"
    local tree="$6"
    local parent_count="$7"
    local parent_offset="$8"
    local fixed_parent="${9:-}"
    local -r classifier_relation_witness_frame_is_exact=true
    local -a classifier_arguments
    local parent_limit capture outer_status

    if [[ "$classifier_mode" == relation ]]; then
        classifier_arguments=(
            --ordered-merge-child-relation
            "$oid" "$size" "$tree" "$fixed_parent"
        )
    else
        classifier_arguments=( "$oid" "$size" "$tree" "$parent_count" )
        parent_limit=$((parent_offset + parent_count))
        while [[ "$parent_offset" -lt "$parent_limit" ]]; do
            classifier_arguments+=(
                "${prime_topology_observation_parents[parent_offset]}"
            )
            parent_offset=$((parent_offset + 1))
        done
    fi

    capture="$(
        local restore_errexit=false
        local -a raw_statuses
        if [[ "$-" == *e* ]]; then
            restore_errexit=true
            set +e
        fi
        prime_topology_git_v1 -C "$prime_topology_repository" \
            cat-file commit "$oid" \
            2>"$prime_topology_private_root/raw-git-$ordinal.stderr" \
            | /usr/bin/env -i LC_ALL=C TMPDIR="$prime_topology_private_root" \
                "$prime_topology_classifier_executable" \
                "${classifier_arguments[@]}" 2>/dev/null
        raw_statuses=( "${PIPESTATUS[@]}" )
        if [[ "$restore_errexit" == true ]]; then set -e; fi
        if [[ "${#raw_statuses[@]}" == 2 ]]; then
            builtin printf '\036prime_status:%03d:%03d\037' \
                "${raw_statuses[0]}" "${raw_statuses[1]}"
        else
            builtin printf '\036prime_status:255:255\037'
        fi
    )"
    outer_status="$?"
    prime_parse_bounded_status_capture_v1 \
        "$classifier_mode" "$outer_status" "$capture" || return 2
    prime_topology_classify_framed_raw_observation_v1 \
        "$classifier_mode" "$schedule" "$ordinal"
    prime_topology_last_classifier_status="$prime_topology_capture_classifier_status"
    prime_topology_last_private_candidate_oid="$prime_topology_capture_candidate_oid"
    [[ "$classifier_relation_witness_frame_is_exact" == true ]]
}

prime_topology_is_guard_id_v1() {
    case "$1" in
        literal_commit_oid_is_lowercase_40hex|\
        expected_topology_oids_are_lowercase_40hex|\
        relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids|\
        verification_request_count_nonzero|\
        verification_request_count_within_bound|\
        repository_argument_is_canonical_absolute_admitted_git_worktree|\
        request_role_matches_ascii_allowlist_grammar|\
        request_roles_are_unique|\
        expected_parent_count_within_bound|\
        fixed_verifier_tools_admitted|\
        classifier_build_and_self_test_admitted|\
        repository_object_format_observation_succeeded|\
        repository_object_format_sha1|\
        object_availability_observation_succeeded|\
        required_object_availability|\
        object_type_observation_succeeded|\
        required_object_type_commit|\
        object_size_observation_succeeded|\
        object_size_within_bound|\
        git_cat_file_transport_succeeded|\
        classifier_exit_status_known|\
        classifier_arguments_match_helper_protocol|\
        classifier_relation_witness_frame_is_exact|\
        classifier_inherited_file_descriptors_closed|\
        classifier_stdin_read_succeeded|\
        classifier_actual_size_within_bound|\
        classifier_actual_size_equals_advertised_size|\
        classifier_computed_oid_equals_literal_oid|\
        classifier_input_is_nul_free|\
        classifier_parser_internal_state_valid|\
        header_lines_and_separator_are_well_formed|\
        tree_header_is_first_and_unique|\
        ordered_parent_headers_are_contiguous|\
        topology_header_oids_are_lowercase_40hex|\
        signed_header_continuations_are_allowed_and_attached|\
        discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids|\
        tree_oid_equals_expected|\
        ordered_parent_oids_equal_expected) return 0 ;;
        *) return 1 ;;
    esac
}

prime_topology_project_result_v1() {
    local result_code="$1"
    local guard_id="$2"
    local missing_role="$3"
    local shallow_state="$4"
    local guard_json=null
    local missing_json=null
    [[ "$result_code" == TOPOLOGY_VERIFIED \
        || "$result_code" == TOPOLOGY_INVOCATION_INVALID \
        || "$result_code" == TOPOLOGY_VERIFIER_UNAVAILABLE \
        || "$result_code" == TOPOLOGY_OBJECT_UNAVAILABLE \
        || "$result_code" == TOPOLOGY_OBJECT_NOT_COMMIT \
        || "$result_code" == TOPOLOGY_OBJECT_UNSUPPORTED \
        || "$result_code" == TOPOLOGY_REPOSITORY_UNSUPPORTED \
        || "$result_code" == TOPOLOGY_OBSERVATION_FAILED \
        || "$result_code" == TOPOLOGY_HEADER_MALFORMED \
        || "$result_code" == TOPOLOGY_MISMATCH ]] || return 1
    [[ "$shallow_state" == complete || "$shallow_state" == shallow \
        || "$shallow_state" == unavailable ]] || return 1
    if [[ "$result_code" == TOPOLOGY_VERIFIED ]]; then
        [[ -z "$guard_id" && -z "$missing_role" ]] || return 1
    else
        prime_topology_is_guard_id_v1 "$guard_id" || return 1
        guard_json="\"$guard_id\""
    fi
    if [[ "$result_code" == TOPOLOGY_OBJECT_UNAVAILABLE ]]; then
        prime_topology_is_role_v1 "$missing_role" || return 1
        missing_json="\"$missing_role\""
    else
        [[ -z "$missing_role" ]] || return 1
    fi
    local json
    json="{\"first_failed_guard_id\":$guard_json,\"missing_object_role\":$missing_json,\"result_code\":\"$result_code\",\"schema_id\":\"prime_exact_revision_topology_verifier_result_v1\",\"schema_version\":1,\"shallow_state\":\"$shallow_state\"}"
    local LC_ALL=C
    [[ "${#json}" -le 512 ]] || return 1
    builtin printf '%s' '' || return 1
    builtin printf '%s\n' "$json" || return 1
    [[ "$result_code" == TOPOLOGY_VERIFIED ]]
}

prime_verify_exact_revision_topology_core_v1() {
    local prime_exact_revision_topology_post_raw_mutation_mode="${1:-}"
    shift "$(( $# > 0 ? 1 : 0 ))"
    local -r prime_exact_revision_topology_post_raw_mutation_mode_none_or_post_raw_read_tree_alternate=true
    case "$prime_exact_revision_topology_post_raw_mutation_mode" in
        none|post_raw_read_tree_alternate) ;;
        *) return 2 ;;
    esac

    local prime_topology_repository=""
    local prime_topology_request_count=""
    local prime_topology_request_count_token=""
    local prime_topology_request_count_numeric=0
    local prime_topology_mode=ordinary
    local prime_topology_relation_marker_index=-1
    local prime_topology_relation_marker_count=0
    local prime_topology_current_marker_index=-1
    local prime_topology_current_marker_count=0
    local prime_topology_relation_suffix_operand_count=0
    local prime_topology_pure_repository_placeholder_admitted=false
    local prime_topology_explicit_end_index=0
    local prime_topology_request_shape_valid=true
    local prime_topology_relation_merge_role=""
    local prime_topology_relation_merge_oid=""
    local prime_topology_relation_index_tree=""
    local prime_topology_relation_fixed_parent=""
    local prime_topology_relation_child_role=""
    local -a prime_topology_request_roles=()
    local -a prime_topology_request_oids=()
    local -a prime_topology_request_trees=()
    local -a prime_topology_request_parent_counts=()
    local -a prime_topology_request_parent_offsets=()
    local -a prime_topology_request_parents=()
    local -a prime_topology_all_roles=()
    local -a prime_topology_candidate_phases=()
    local -a prime_topology_candidate_ordinals=()
    local -a prime_topology_candidate_result_codes=()
    local -a prime_topology_candidate_guard_ids=()
    local -a prime_topology_candidate_missing_roles=()
    local prime_topology_best_phase=""
    local prime_topology_best_ordinal=""
    local prime_topology_best_result_code=""
    local prime_topology_best_guard_id=""
    local prime_topology_best_missing_role=""
    local -a prime_topology_wave_oids=()
    local -a prime_topology_wave_roles=()
    local -a prime_topology_wave_ordinals=()
    local -a prime_topology_wave_sizes=()
    local -a prime_topology_explicit_sizes=()
    local -a prime_topology_observation_parents=()
    local prime_topology_preprobe_wave_id=""
    local prime_topology_preprobe_status=""
    local prime_topology_private_root=""
    local prime_topology_classifier_executable=""
    local prime_topology_capture_body=""
    local prime_topology_capture_status=""
    local prime_topology_frame_accepted=false
    local prime_topology_capture_producer_status=""
    local prime_topology_capture_consumer_status=""
    local prime_topology_capture_classifier_status=""
    local prime_topology_capture_candidate_oid=""
    local prime_topology_capture_frame_syntax_valid=false
    local prime_topology_capture_payload_valid=false
    local prime_topology_capture_known_status=false
    local prime_topology_capture_outer_status=""
    local prime_topology_last_classifier_status=""
    local prime_topology_last_private_candidate_oid=""
    local prime_topology_mapped_phase=""
    local shallow_state=unavailable
    local schedule=ordinary
    local activated_index_barrier=false
    local prime_topology_admitted_runner_temp=""

    prime_parse_exact_revision_topology_invocation_v1 "$@" || true
    if [[ "$prime_topology_mode" == relation ]]; then
        schedule=relation
    fi
    if [[ -n "$prime_topology_best_phase" ]]; then
        prime_topology_project_result_v1 "$prime_topology_best_result_code" \
            "$prime_topology_best_guard_id" "$prime_topology_best_missing_role" \
            "$shallow_state"
        return "$?"
    fi

    if [[ "$prime_topology_mode" == relation \
        || "$prime_topology_mode" == current_index ]]; then
        activated_index_barrier=true
    fi
    if [[ -n "${prime_topology_closed_child_v1+x}" ]]; then
        if ! prime_topology_admit_closed_child_state_v1 \
            && [[ "$activated_index_barrier" == true ]]; then
            return 2
        fi
    elif ! prime_topology_begin_closed_trace_entry_v1 \
            && [[ "$activated_index_barrier" == true ]]; then
        return 2
    fi

    if ! prime_topology_admit_repository_builtin_v1 \
            "$prime_topology_repository"; then
        prime_topology_phase_v1 5 "$schedule"
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" 0 \
            TOPOLOGY_INVOCATION_INVALID \
            repository_argument_is_canonical_absolute_admitted_git_worktree ""
        prime_select_exact_revision_topology_result_v1
        prime_topology_project_result_v1 "$prime_topology_best_result_code" \
            "$prime_topology_best_guard_id" "" "$shallow_state"
        return "$?"
    fi

    if ! prime_admit_exact_revision_topology_tools_v1; then
        prime_topology_phase_v1 9 "$schedule"
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" 0 \
            TOPOLOGY_VERIFIER_UNAVAILABLE fixed_verifier_tools_admitted ""
        prime_select_exact_revision_topology_result_v1
        prime_topology_project_result_v1 "$prime_topology_best_result_code" \
            "$prime_topology_best_guard_id" "" "$shallow_state"
        return "$?"
    fi

    # This copied gate-admitted value is the helper's sole private-root parent.
    prime_topology_admitted_runner_temp="${PRIME_EXACT_REVISION_TOPOLOGY_ADMITTED_RUNNER_TEMP_V1-}"
    if ! prime_topology_admit_runner_temp_v1 \
            "$prime_topology_admitted_runner_temp"; then
        if [[ "$activated_index_barrier" == true ]]; then
            return 2
        fi
        prime_topology_phase_v1 10 "$schedule"
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" 0 \
            TOPOLOGY_VERIFIER_UNAVAILABLE \
            classifier_build_and_self_test_admitted ""
        prime_select_exact_revision_topology_result_v1
        prime_topology_project_result_v1 "$prime_topology_best_result_code" \
            "$prime_topology_best_guard_id" "" "$shallow_state"
        return "$?"
    fi

    local source_root
    source_root="$(builtin pwd -P 2>/dev/null)" || source_root=""
    if ! prime_topology_admit_source_root_v1 \
            "$source_root" "$prime_topology_admitted_runner_temp"; then
        prime_topology_phase_v1 10 "$schedule"
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" 0 \
            TOPOLOGY_VERIFIER_UNAVAILABLE \
            classifier_build_and_self_test_admitted ""
        prime_select_exact_revision_topology_result_v1
        prime_topology_project_result_v1 "$prime_topology_best_result_code" \
            "$prime_topology_best_guard_id" "" "$shallow_state"
        return "$?"
    fi
    if ! prime_build_exact_revision_topology_classifier_v1 "$source_root"; then
        prime_topology_phase_v1 10 "$schedule"
        prime_topology_add_candidate_v1 "$prime_topology_mapped_phase" 0 \
            TOPOLOGY_VERIFIER_UNAVAILABLE \
            classifier_build_and_self_test_admitted ""
        prime_select_exact_revision_topology_result_v1
        prime_topology_project_result_v1 "$prime_topology_best_result_code" \
            "$prime_topology_best_guard_id" "" "$shallow_state"
        return "$?"
    fi

    if [[ "$activated_index_barrier" == true ]]; then
        if ! prime_admit_exact_revision_topology_trace_state_v1; then
            return 2
        fi
        local PS4=''
    fi

    prime_topology_capture_text_v1 16 prime_topology_git_v1 \
        -C "$prime_topology_repository" rev-parse --show-object-format=storage \
        || {
            prime_topology_capture_status=255
            prime_topology_capture_body=""
        }
    prime_topology_classify_repository_format_observation_v1 \
        "$prime_topology_capture_status" "$prime_topology_capture_body" \
        "$schedule"
    prime_select_exact_revision_topology_result_v1
    if [[ -n "$prime_topology_best_phase" ]]; then
        prime_topology_project_result_v1 "$prime_topology_best_result_code" \
            "$prime_topology_best_guard_id" "" "$shallow_state"
        return "$?"
    fi

    prime_topology_capture_text_v1 6 prime_topology_git_v1 \
        -C "$prime_topology_repository" rev-parse --is-shallow-repository
    if [[ "$?" == 0 && "$prime_topology_capture_status" == 0 ]]; then
        case "$prime_topology_capture_body" in
            $'true\n') shallow_state=shallow ;;
            $'false\n') shallow_state=complete ;;
            *) shallow_state=unavailable ;;
        esac
    fi

    local expected_head=""
    local expected_index_tree=""
    if [[ "$activated_index_barrier" == true ]]; then
        if [[ "$prime_topology_mode" == relation ]]; then
            expected_head="$prime_topology_relation_merge_oid"
            expected_index_tree="$prime_topology_relation_index_tree"
        else
            expected_head="${prime_topology_request_oids[0]}"
            expected_index_tree="${prime_topology_request_trees[0]}"
        fi
        prime_capture_exact_revision_topology_probe_v1 \
            HEAD "$prime_topology_repository" || return 2
        [[ "$prime_topology_capture_body" == "$expected_head"$'\n' ]] \
            || return 2
        prime_capture_exact_revision_topology_probe_v1 \
            clean_status "$prime_topology_repository" || return 2
        prime_capture_exact_revision_topology_probe_v1 \
            write_tree "$prime_topology_repository" || return 2
        [[ "$prime_topology_capture_body" == "$expected_index_tree"$'\n' ]] \
            || return 2
    fi

    local index ordinal explicit_count merge_ordinal child_ordinal
    explicit_count="$prime_topology_request_count_numeric"
    merge_ordinal=$((explicit_count + 1))
    child_ordinal=$((explicit_count + 2))
    prime_topology_wave_oids=()
    prime_topology_wave_roles=()
    prime_topology_wave_ordinals=()
    for (( ordinal = 1; ordinal <= explicit_count; ordinal += 1 )); do
        prime_topology_wave_oids+=(
            "${prime_topology_request_oids[ordinal - 1]}"
        )
        prime_topology_wave_roles+=(
            "${prime_topology_request_roles[ordinal - 1]}"
        )
        prime_topology_wave_ordinals+=( "$ordinal" )
    done
    if [[ "$prime_topology_mode" == relation ]]; then
        prime_topology_wave_oids+=( "$prime_topology_relation_merge_oid" )
        prime_topology_wave_roles+=( "$prime_topology_relation_merge_role" )
        prime_topology_wave_ordinals+=( "$merge_ordinal" )
    fi
    prime_topology_preprobe_wave_id=wave1
    prime_preprobe_exact_revision_topology_objects_v1 "$schedule"
    prime_topology_explicit_sizes=()
    for (( index = 0; index < explicit_count; index += 1 )); do
        prime_topology_explicit_sizes+=( "${prime_topology_wave_sizes[index]:-0}" )
    done
    local merge_size="${prime_topology_wave_sizes[explicit_count]:-0}"

    local preprobe_lower=13 preprobe_upper=18
    if [[ "$schedule" == relation ]]; then
        preprobe_lower=14
        preprobe_upper=19
    fi
    if ! prime_topology_has_candidate_in_phase_range_v1 \
            "$preprobe_lower" "$preprobe_upper"; then
        prime_topology_observation_parents=()
        for (( index = 0; index < ${#prime_topology_request_parents[@]}; index += 1 )); do
            prime_topology_observation_parents+=(
                "${prime_topology_request_parents[index]}"
            )
        done
        local parent_count parent_offset tree oid size
        for (( ordinal = 1; ordinal <= explicit_count; ordinal += 1 )); do
            oid="${prime_topology_request_oids[ordinal - 1]}"
            tree="${prime_topology_request_trees[ordinal - 1]}"
            size="${prime_topology_explicit_sizes[ordinal - 1]}"
            parent_count="${prime_topology_request_parent_counts[ordinal - 1]}"
            parent_offset="${prime_topology_request_parent_offsets[ordinal - 1]}"
            prime_capture_exact_revision_topology_relation_witness_v1 \
                ordinary "$schedule" "$ordinal" "$oid" "$size" "$tree" \
                "$parent_count" "$parent_offset" "" || return 2
        done

        if [[ "$prime_topology_mode" == relation ]]; then
            prime_topology_last_private_candidate_oid=""
            prime_capture_exact_revision_topology_relation_witness_v1 \
                relation relation "$merge_ordinal" \
                "$prime_topology_relation_merge_oid" "$merge_size" \
                "$prime_topology_relation_index_tree" 0 0 \
                "$prime_topology_relation_fixed_parent" || return 2
            local discovered_child_oid="$prime_topology_last_private_candidate_oid"
            if [[ -n "$discovered_child_oid" ]]; then
                local child_distinct=true compared_oid
                if [[ "$discovered_child_oid" \
                        == "$prime_topology_relation_merge_oid" \
                    || "$discovered_child_oid" \
                        == "$prime_topology_relation_fixed_parent" ]]; then
                    child_distinct=false
                fi
                for (( index = 0; index < ${#prime_topology_request_oids[@]}; index += 1 )); do
                    compared_oid="${prime_topology_request_oids[index]}"
                    if [[ "$discovered_child_oid" == "$compared_oid" ]]; then
                        child_distinct=false
                    fi
                done
                local -r validated_caller_suffix_child_role_preprobe_occurs_only_after_exact_safe_distinct_witness=true
                if [[ "$child_distinct" != true ]]; then
                    prime_topology_add_candidate_v1 36 "$child_ordinal" \
                        TOPOLOGY_MISMATCH \
                        discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids ""
                elif [[ "$validated_caller_suffix_child_role_preprobe_occurs_only_after_exact_safe_distinct_witness" \
                        == true ]]; then
                    prime_topology_wave_oids=( "$discovered_child_oid" )
                    prime_topology_wave_roles=( "$prime_topology_relation_child_role" )
                    prime_topology_wave_ordinals=( "$child_ordinal" )
                    prime_topology_preprobe_wave_id=wave2
                    prime_preprobe_exact_revision_topology_objects_v1 relation
                    if ! prime_topology_has_candidate_in_phase_range_v1 14 19; then
                        local child_size="${prime_topology_wave_sizes[0]:-0}"
                        prime_topology_observation_parents=(
                            "$prime_topology_relation_fixed_parent"
                        )
                        prime_capture_exact_revision_topology_relation_witness_v1 \
                            ordinary relation "$child_ordinal" \
                            "$discovered_child_oid" "$child_size" \
                            "$prime_topology_relation_index_tree" 1 0 "" \
                            || return 2
                    fi
                fi
            fi
        fi
    fi

    if [[ "$activated_index_barrier" == true \
        && "$prime_exact_revision_topology_post_raw_mutation_mode" \
            == post_raw_read_tree_alternate ]]; then
        prime_topology_git_v1 -C "$prime_topology_repository" read-tree \
            a8b941f979c6752d954e44f12986dcda9dd54417 \
            </dev/null >/dev/null 2>/dev/null || return 2
    fi

    if [[ "$activated_index_barrier" == true ]]; then
        prime_capture_exact_revision_topology_probe_v1 \
            HEAD "$prime_topology_repository" || return 2
        [[ "$prime_topology_capture_body" == "$expected_head"$'\n' ]] \
            || return 2
        prime_capture_exact_revision_topology_probe_v1 \
            clean_status "$prime_topology_repository" || return 2
        prime_capture_exact_revision_topology_probe_v1 \
            write_tree "$prime_topology_repository" || return 2
        [[ "$prime_topology_capture_body" == "$expected_index_tree"$'\n' ]] \
            || return 2
    fi

    prime_select_exact_revision_topology_result_v1
    if [[ -z "$prime_topology_best_phase" ]]; then
        prime_topology_project_result_v1 TOPOLOGY_VERIFIED "" "" \
            "$shallow_state"
    else
        prime_topology_project_result_v1 "$prime_topology_best_result_code" \
            "$prime_topology_best_guard_id" "$prime_topology_best_missing_role" \
            "$shallow_state"
    fi
}

prime_verify_exact_revision_topology_v1() {
    local verification_status
    if prime_verify_exact_revision_topology_core_v1 none "$@"; then
        verification_status=0
    else
        verification_status="$?"
    fi
    if [[ -z "${prime_topology_closed_child_v1+x}" \
        && ! -o functrace ]]; then
        prime_topology_arm_trace_watcher_v1
    fi
    return "$verification_status"
}

prime_test_exact_revision_topology_post_raw_index_mutation_v1() {
    local verification_status
    if prime_verify_exact_revision_topology_core_v1 \
            post_raw_read_tree_alternate "$@"; then
        verification_status=0
    else
        verification_status="$?"
    fi
    if [[ -z "${prime_topology_closed_child_v1+x}" \
        && ! -o functrace ]]; then
        prime_topology_arm_trace_watcher_v1
    fi
    return "$verification_status"
}

# Trace attributes make caller DEBUG/RETURN definitions visible to the closed
# entry chain solely so admission can reject them before a private witness.
builtin declare -ft \
    prime_verify_exact_revision_topology_v1 \
    prime_test_exact_revision_topology_post_raw_index_mutation_v1 \
    prime_verify_exact_revision_topology_core_v1 \
    prime_admit_exact_revision_topology_trace_state_v1

# Bash 3 does not expose an ERR trap from an untraced caller function to a
# callee. The silent watcher therefore owns functrace only between helper
# calls, observes trace mutations across intermediary functions, and is
# removed together with that option at the closed entry before any witness.
prime_topology_arm_trace_watcher_v1() {
    [[ -z "${prime_topology_closed_child_v1+x}" ]] || return 2
    builtin set -T
    builtin trap '
        prime_topology_watched_command_v1="$BASH_COMMAND"
        if [[ "${FUNCNAME[0]-}" \
            == prime_topology_begin_closed_trace_entry_v1 ]]; then
            prime_topology_internal_watcher_entry_seen_v1=true
        fi
        case "$prime_topology_watched_command_v1" in
            "builtin trap - DEBUG")
                case "${FUNCNAME[0]-}" in
                    prime_topology_begin_closed_trace_entry_v1) ;;
                    *)
                        if [[ -z "${prime_topology_after_source_trap_presence_v1+x}" ]]; then
                            prime_topology_after_source_trap_presence_v1=true
                            builtin readonly prime_topology_after_source_trap_presence_v1
                        fi
                        ;;
                esac
                ;;
            trap\ -p*|builtin\ trap\ -p*|command\ trap\ -p*) ;;
            trap\ *|builtin\ trap\ *|command\ trap\ *|\
            set\ *+T*|builtin\ set\ *+T*|command\ set\ *+T*|\
            set\ *functrace*|builtin\ set\ *functrace*|\
            command\ set\ *functrace*|shopt\ *functrace*|\
            builtin\ shopt\ *functrace*|command\ shopt\ *functrace*)
                if [[ -z "${prime_topology_after_source_trap_presence_v1+x}" ]]; then
                    prime_topology_after_source_trap_presence_v1=true
                    builtin readonly prime_topology_after_source_trap_presence_v1
                fi
                ;;
        esac
        builtin unset prime_topology_watched_command_v1
    ' DEBUG
}

prime_topology_arm_trace_watcher_v1
prime_topology_trusted_trace_trap_representation_v1="$(
    builtin trap -p DEBUG RETURN ERR 2>/dev/null
)" || return 95
[[ -n "$prime_topology_trusted_trace_trap_representation_v1" ]] || return 95
builtin readonly prime_topology_trusted_trace_trap_representation_v1
