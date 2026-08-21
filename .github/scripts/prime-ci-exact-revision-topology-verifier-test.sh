#!/bin/bash
[[ "$-" == *p* ]] || exit 97
builtin unset BASH_ENV ENV
set -euo pipefail
IFS=$'\n\t'

readonly expected_gate_admission_token="prime_exact_revision_topology_matrix_admitted_v1"
[[ "${PRIME_EXACT_REVISION_TOPOLOGY_MATRIX_ADMITTED_V1:-}" \
        == "$expected_gate_admission_token" ]] || exit 98

fail() {
    builtin printf '%s\n' "prime-ci-exact-revision-topology-verifier-test: $*" >&2
    exit 1
}

for fixed_tool in \
    /bin/bash /bin/dd /bin/mkdir /bin/rm /usr/bin/awk /usr/bin/base64 \
    /usr/bin/cmp /usr/bin/env /usr/bin/git /usr/bin/grep /usr/bin/jq \
    /usr/bin/head /usr/bin/mkfifo /usr/bin/mktemp /usr/bin/shasum \
    /usr/bin/sort /usr/bin/stat /usr/bin/tail \
    /usr/bin/tr /usr/bin/wc /usr/bin/xcrun; do
    [[ -f "$fixed_tool" && ! -L "$fixed_tool" && -x "$fixed_tool" ]] ||
        fail "fixed test tool is unavailable: $fixed_tool"
done

readonly repository_root="$PWD"
[[ "$repository_root" == /* \
    && "$repository_root" != *$'\n'* \
    && "$repository_root" != *$'\r'* \
    && "$repository_root" != *'/./'* \
    && "$repository_root" != *'/../'* \
    && "$repository_root" != */. \
    && "$repository_root" != */.. \
    && "$repository_root" \
        == "$(/usr/bin/git -C "$repository_root" rev-parse --show-toplevel)" ]] ||
    fail "matrix test requires the canonical repository root as its working directory"

readonly authority_path="$repository_root/Sources/PrimeCore/PrimeExactRevisionTopologyVerifierAuthority.swift"
readonly relation_authority_path="$repository_root/Sources/PrimeCore/PrimeExactRevisionTopologyRelationAmendmentAuthority.swift"
readonly classifier_path="$repository_root/.github/scripts/PrimeExactRevisionTopologyClassifier.swift"
readonly helper_path="$repository_root/.github/scripts/prime-ci-exact-revision-topology-verifier.sh"
readonly test_path="$repository_root/.github/scripts/prime-ci-exact-revision-topology-verifier-test.sh"
readonly gate_path="$repository_root/.github/scripts/prime-ci-active-root-quarantine.sh"
readonly workflow_path="$repository_root/.github/workflows/prime-active-root-quarantine.yml"
for admitted_source in \
    "$authority_path" "$relation_authority_path" "$classifier_path" \
    "$helper_path" "$test_path" "$gate_path" "$workflow_path"; do
    [[ -f "$admitted_source" && ! -L "$admitted_source" ]] ||
        fail "matrix source is not a regular nonlink: $admitted_source"
done

readonly runner_temp="${PRIME_EXACT_REVISION_TOPOLOGY_ADMITTED_RUNNER_TEMP_V1:?gate-admitted RUNNER_TEMP is required}"
[[ "$runner_temp" == /* \
    && "$runner_temp" != *$'\n'* \
    && "$runner_temp" != *$'\r'* \
    && "$runner_temp" != *'/./'* \
    && "$runner_temp" != *'/../'* \
    && "$runner_temp" != */. \
    && "$runner_temp" != */.. \
    && -d "$runner_temp" \
    && ! -L "$runner_temp" \
    && -O "$runner_temp" \
    && -w "$runner_temp" ]] ||
    fail "gate-exported admitted runner temp is not a private compiler base"

umask 0077
test_root="$(/usr/bin/mktemp -d \
    "$runner_temp/prime-exact-revision-topology-matrix.XXXXXXXX")" ||
    fail "could not create the private matrix root"
readonly test_root
[[ "$test_root" == "$runner_temp"/* \
    && -d "$test_root" \
    && ! -L "$test_root" \
    && -O "$test_root" \
    && "$(/usr/bin/stat -f '%Lp' -- "$test_root")" == "700" ]] ||
    fail "private matrix root admission failed"
cleanup() {
    [[ -n "${test_root:-}" \
        && "$test_root" == "$runner_temp"/prime-exact-revision-topology-matrix.* \
        && -d "$test_root" \
        && ! -L "$test_root" ]] || return 1
    /bin/rm -rf -- "$test_root"
}
trap cleanup EXIT HUP INT TERM

readonly authority_emitter_source="$test_root/AuthorityEmitter.swift"
readonly authority_emitter="$test_root/authority-emitter"
readonly authority_json="$test_root/authority.json"
builtin printf '%s\n' \
    'import Foundation' \
    '@main' \
    'struct AuthorityEmitter {' \
    '    static func main() throws {' \
    '        FileHandle.standardOutput.write(' \
    '            try PrimeExactRevisionTopologyVerifierAuthorityV1.frozenV1.canonicalData())' \
    '    }' \
    '}' > "$authority_emitter_source"
/usr/bin/env -i \
    LC_ALL=C \
    TMPDIR="$test_root" \
    CLANG_MODULE_CACHE_PATH="$test_root/authority-clang-module-cache" \
    /usr/bin/xcrun swiftc \
    "$authority_path" "$authority_emitter_source" \
    -o "$authority_emitter" \
    > "$test_root/authority-compile.stdout" \
    2> "$test_root/authority-compile.stderr" ||
    fail "could not compile the frozen authority emitter"
[[ ! -s "$test_root/authority-compile.stdout" \
    && ! -s "$test_root/authority-compile.stderr" \
    && -f "$authority_emitter" \
    && ! -L "$authority_emitter" \
    && -x "$authority_emitter" ]] ||
    fail "authority emitter compilation was not silent and private"
/usr/bin/env -i LC_ALL=C TMPDIR="$test_root" \
    "$authority_emitter" > "$authority_json" 2> "$test_root/authority.stderr" ||
    fail "could not emit the frozen authority"
[[ ! -s "$test_root/authority.stderr" \
    && "$(/usr/bin/wc -c < "$authority_json" | /usr/bin/awk '{print $1}')" \
        == "410281" \
    && "$(/usr/bin/shasum -a 256 "$authority_json" | /usr/bin/awk '{print $1}')" \
        == "58409182a2be35e7d7874c0b672d4dbf53ab4bd0abc5574cbd598ad8849197d2" ]] ||
    fail "frozen authority identity changed"

authority_jq() {
    /usr/bin/jq "$@" "$authority_json"
}

# Preserve the predecessor authority and all of its matrix consumers above,
# while independently binding the additive relation-amendment authority used
# by the remainder of this test.
readonly relation_authority_emitter_source="$test_root/RelationAuthorityEmitter.swift"
readonly relation_authority_emitter="$test_root/relation-authority-emitter"
readonly relation_authority_json="$test_root/relation-authority.json"
builtin printf '%s\n' \
    'import Foundation' \
    '@main' \
    'struct RelationAuthorityEmitter {' \
    '    static func main() throws {' \
    '        FileHandle.standardOutput.write(' \
    '            try PrimeExactRevisionTopologyRelationAmendmentAuthorityV1.frozenV1.canonicalData())' \
    '    }' \
    '}' > "$relation_authority_emitter_source"
/usr/bin/env -i \
    LC_ALL=C \
    TMPDIR="$test_root" \
    CLANG_MODULE_CACHE_PATH="$test_root/relation-authority-clang-module-cache" \
    /usr/bin/xcrun swiftc \
    "$relation_authority_path" "$relation_authority_emitter_source" \
    -o "$relation_authority_emitter" \
    > "$test_root/relation-authority-compile.stdout" \
    2> "$test_root/relation-authority-compile.stderr" ||
    fail "could not compile the frozen relation-amendment authority emitter"
[[ ! -s "$test_root/relation-authority-compile.stdout" \
    && ! -s "$test_root/relation-authority-compile.stderr" \
    && -f "$relation_authority_emitter" \
    && ! -L "$relation_authority_emitter" \
    && -x "$relation_authority_emitter" ]] ||
    fail "relation-amendment authority emitter compilation was not silent and private"
/usr/bin/env -i LC_ALL=C TMPDIR="$test_root" \
    "$relation_authority_emitter" \
    > "$relation_authority_json" \
    2> "$test_root/relation-authority.stderr" ||
    fail "could not emit the frozen relation-amendment authority"
[[ ! -s "$test_root/relation-authority.stderr" \
    && "$(/usr/bin/wc -c < "$relation_authority_json" | /usr/bin/awk '{print $1}')" \
        == "467184" \
    && "$(/usr/bin/shasum -a 256 "$relation_authority_json" | /usr/bin/awk '{print $1}')" \
        == "ae13d26870b73515bf76018d2f0c1f10d13edf0a59c38857e5767f1abc668a98" ]] ||
    fail "frozen relation-amendment authority identity changed"

relation_authority_jq() {
    /usr/bin/jq "$@" "$relation_authority_json"
}

git_clean() {
    /usr/bin/env -i \
        LC_ALL=C \
        TMPDIR="$test_root" \
        GIT_NO_REPLACE_OBJECTS=1 \
        GIT_NO_LAZY_FETCH=1 \
        GIT_CONFIG_NOSYSTEM=1 \
        GIT_CONFIG_GLOBAL=/dev/null \
        GIT_TERMINAL_PROMPT=0 \
        GIT_OPTIONAL_LOCKS=0 \
        GIT_ALLOW_PROTOCOL=file \
        /usr/bin/git "$@"
}

materialize_fixture() {
    local fixture_json="$1"
    local destination="$2"
    local object_type="${3:-commit}"
    local encoding recipe expected_bytes expected_sha expected_oid
    encoding="$(/usr/bin/jq -r '.payloadEncoding' <<< "$fixture_json")"
    recipe="$(/usr/bin/jq -r '.payloadRecipe' <<< "$fixture_json")"
    expected_bytes="$(/usr/bin/jq -r '.payloadByteCount' <<< "$fixture_json")"
    expected_sha="$(/usr/bin/jq -r '.payloadSHA256' <<< "$fixture_json")"
    expected_oid="$(/usr/bin/jq -r '.literalObjectOID' <<< "$fixture_json")"
    case "$encoding" in
        base64_exact_bytes)
            builtin printf '%s' "$recipe" | /usr/bin/base64 -D > "$destination" ||
                fail "could not decode exact fixture bytes"
            ;;
        base64_prefix_plus_ascii_x_repeat)
            local prefix repeated_count
            prefix="${recipe%%_then_*}"
            repeated_count="${recipe#*_then_}"
            repeated_count="${repeated_count%%_ascii_x_bytes}"
            [[ "$repeated_count" =~ ^[1-9][0-9]*$ ]] ||
                fail "oversized fixture repeat count is not canonical"
            builtin printf '%s' "$prefix" | /usr/bin/base64 -D > "$destination" ||
                fail "could not decode oversized fixture prefix"
            /bin/dd if=/dev/zero bs="$repeated_count" count=1 2>/dev/null |
                /usr/bin/tr '\000' x >> "$destination" ||
                fail "could not construct oversized fixture suffix"
            ;;
        *)
            fail "unsupported frozen fixture encoding: $encoding"
            ;;
    esac
    [[ -f "$destination" \
        && ! -L "$destination" \
        && "$(/usr/bin/wc -c < "$destination" | /usr/bin/awk '{print $1}')" \
            == "$expected_bytes" \
        && "$(/usr/bin/shasum -a 256 "$destination" | /usr/bin/awk '{print $1}')" \
            == "$expected_sha" \
        && "$(git_clean hash-object --literally -t "$object_type" --stdin \
            < "$destination")" == "$expected_oid" ]] ||
        fail "fixture bytes do not prove their declared byte/SHA-256/Git-OID identity"
}

classifier_result_for_status() {
    case "$1" in
        0) builtin printf '%s\t%s\n' TOPOLOGY_VERIFIED null ;;
        20) builtin printf '%s\t%s\n' TOPOLOGY_OBSERVATION_FAILED classifier_arguments_match_helper_protocol ;;
        21) builtin printf '%s\t%s\n' TOPOLOGY_OBSERVATION_FAILED classifier_stdin_read_succeeded ;;
        22) builtin printf '%s\t%s\n' TOPOLOGY_OBSERVATION_FAILED classifier_actual_size_within_bound ;;
        23) builtin printf '%s\t%s\n' TOPOLOGY_OBSERVATION_FAILED classifier_actual_size_equals_advertised_size ;;
        24) builtin printf '%s\t%s\n' TOPOLOGY_OBSERVATION_FAILED classifier_computed_oid_equals_literal_oid ;;
        25) builtin printf '%s\t%s\n' TOPOLOGY_OBJECT_UNSUPPORTED classifier_input_is_nul_free ;;
        26) builtin printf '%s\t%s\n' TOPOLOGY_OBSERVATION_FAILED classifier_parser_internal_state_valid ;;
        27) builtin printf '%s\t%s\n' TOPOLOGY_OBSERVATION_FAILED classifier_inherited_file_descriptors_closed ;;
        30) builtin printf '%s\t%s\n' TOPOLOGY_HEADER_MALFORMED header_lines_and_separator_are_well_formed ;;
        31) builtin printf '%s\t%s\n' TOPOLOGY_HEADER_MALFORMED tree_header_is_first_and_unique ;;
        32) builtin printf '%s\t%s\n' TOPOLOGY_HEADER_MALFORMED ordered_parent_headers_are_contiguous ;;
        33) builtin printf '%s\t%s\n' TOPOLOGY_HEADER_MALFORMED topology_header_oids_are_lowercase_40hex ;;
        34) builtin printf '%s\t%s\n' TOPOLOGY_HEADER_MALFORMED signed_header_continuations_are_allowed_and_attached ;;
        41) builtin printf '%s\t%s\n' TOPOLOGY_MISMATCH tree_oid_equals_expected ;;
        42) builtin printf '%s\t%s\n' TOPOLOGY_MISMATCH ordered_parent_oids_equal_expected ;;
        *) builtin printf '%s\t%s\n' TOPOLOGY_OBSERVATION_FAILED classifier_exit_status_known ;;
    esac
}

validate_result_record() {
    local record_path="$1"
    local observed_status="$2"
    local expected_result="$3"
    local expected_guard="$4"
    local expected_missing_role="$5"
    local expected_shallow="$6"
    [[ -f "$record_path" \
        && ! -L "$record_path" \
        && "$(/usr/bin/wc -l < "$record_path" | /usr/bin/awk '{print $1}')" == "1" \
        && "$(/usr/bin/wc -c < "$record_path" | /usr/bin/awk '{print $1}')" -le 513 \
        && "$(/usr/bin/tail -c 1 "$record_path" | /usr/bin/wc -l | /usr/bin/awk '{print $1}')" == "1" ]] ||
        fail "helper did not emit exactly one bounded terminal-LF record"
    local canonical_record
    canonical_record="$(/usr/bin/jq -cS . "$record_path")" ||
        fail "helper result is not JSON"
    builtin printf '%s\n' "$canonical_record" |
        /usr/bin/cmp -s - "$record_path" ||
        fail "helper result is not canonical sorted JSON"
    /usr/bin/jq -e \
        --arg result "$expected_result" \
        --arg guard "$expected_guard" \
        --arg missing "$expected_missing_role" \
        --arg shallow "$expected_shallow" '
            keys == [
                "first_failed_guard_id", "missing_object_role", "result_code",
                "schema_id", "schema_version", "shallow_state"
            ]
            and .schema_id == "prime_exact_revision_topology_verifier_result_v1"
            and .schema_version == 1
            and .result_code == $result
            and .first_failed_guard_id == (if $guard == "null" then null else $guard end)
            and .missing_object_role == (if $missing == "null" then null else $missing end)
            and .shallow_state == $shallow
        ' "$record_path" >/dev/null ||
        fail "helper result does not match the frozen expected classification"
    if [[ "$expected_result" == "TOPOLOGY_VERIFIED" ]]; then
        [[ "$observed_status" == "0" ]] ||
            fail "verified helper result returned nonzero"
    else
        [[ "$observed_status" == "1" ]] ||
            fail "non-success helper result did not return exactly one"
    fi
}

readonly classifier_root="$test_root/classifier"
/bin/mkdir -m 700 "$classifier_root"
readonly classifier_executable="$classifier_root/prime-exact-revision-topology-classifier"
/usr/bin/env -i \
    LC_ALL=C \
    TMPDIR="$classifier_root" \
    CLANG_MODULE_CACHE_PATH="$classifier_root/clang-module-cache" \
    /usr/bin/xcrun swiftc \
    .github/scripts/PrimeExactRevisionTopologyClassifier.swift \
    -o "$classifier_executable" \
    > "$classifier_root/compile.stdout" \
    2> "$classifier_root/compile.stderr" ||
    fail "classifier did not compile"
[[ ! -s "$classifier_root/compile.stdout" \
    && ! -s "$classifier_root/compile.stderr" \
    && -f "$classifier_executable" \
    && ! -L "$classifier_executable" \
    && -x "$classifier_executable" ]] ||
    fail "classifier build was not silent, private, regular, and executable"
/usr/bin/env -i LC_ALL=C TMPDIR="$classifier_root" \
    "$classifier_executable" --self-test \
    < /dev/null \
    > "$classifier_root/self-test.stdout" \
    2> "$classifier_root/self-test.stderr" ||
    fail "classifier self-test failed"
[[ ! -s "$classifier_root/self-test.stdout" \
    && ! -s "$classifier_root/self-test.stderr" ]] ||
    fail "classifier self-test emitted bytes"

readonly classifier_witness_registry="$test_root/classifier-witnesses"
: > "$classifier_witness_registry"
readonly direct_fixture_count="$(authority_jq -r '.classifierDirectFixtureMatrix | length')"
[[ "$direct_fixture_count" -gt 0 ]] || fail "authority has no direct classifier fixtures"
direct_index=0
while [[ "$direct_index" -lt "$direct_fixture_count" ]]; do
    direct_case="$(authority_jq -c ".classifierDirectFixtureMatrix[$direct_index]")"
    case_id="$(/usr/bin/jq -r '.caseID' <<< "$direct_case")"
    guard_id="$(/usr/bin/jq -r '.guardID' <<< "$direct_case")"
    predicate_value="$(/usr/bin/jq -r '.predicateValue' <<< "$direct_case")"
    expected_status="$(/usr/bin/jq -r '.expectedExitStatus' <<< "$direct_case")"
    expected_result="$(/usr/bin/jq -r '.expectedResultCode' <<< "$direct_case")"
    expected_guard="$(/usr/bin/jq -r '.expectedFirstFailedGuardID // "null"' <<< "$direct_case")"
    fixture_json="$(/usr/bin/jq -c '.fixture' <<< "$direct_case")"
    payload_path="$classifier_root/direct-$direct_index.payload"
    materialize_fixture "$fixture_json" "$payload_path"
    argument_count="$(/usr/bin/jq -r '.exactArgumentVector | length' <<< "$direct_case")"
    classifier_arguments=()
    argument_index=0
    while [[ "$argument_index" -lt "$argument_count" ]]; do
        argument="$(/usr/bin/jq -r ".exactArgumentVector[$argument_index]" <<< "$direct_case")"
        if [[ "$argument_index" == "0" ]]; then
            argument="$classifier_executable"
        fi
        classifier_arguments+=("$argument")
        argument_index=$((argument_index + 1))
    done
    stdout_path="$classifier_root/direct-$direct_index.stdout"
    stderr_path="$classifier_root/direct-$direct_index.stderr"
    harness="$(/usr/bin/jq -r '.harnessSetupContract // ""' <<< "$direct_case")"
    set +e
    if [[ "$harness" \
            == "invoke_with_fd0_open_read_only_on_private_directory_to_induce_Darwin_read_EISDIR" ]]; then
        /usr/bin/env -i LC_ALL=C TMPDIR="$classifier_root" \
            "${classifier_arguments[@]}" \
            < "$classifier_root" > "$stdout_path" 2> "$stderr_path"
    elif [[ "$harness" \
            == "fixture_parent_opens_private_fd9_without_cloexec_before_direct_invocation" ]]; then
        /usr/bin/env -i LC_ALL=C TMPDIR="$classifier_root" \
            "${classifier_arguments[@]}" \
            < "$payload_path" > "$stdout_path" 2> "$stderr_path" \
            9< "$payload_path"
    else
        /usr/bin/env -i LC_ALL=C TMPDIR="$classifier_root" \
            "${classifier_arguments[@]}" \
            < "$payload_path" > "$stdout_path" 2> "$stderr_path"
    fi
    observed_status="$?"
    set -e
    observed_mapping="$(classifier_result_for_status "$observed_status")"
    observed_result="${observed_mapping%%$'\t'*}"
    observed_guard="${observed_mapping#*$'\t'}"
    [[ "$observed_status" == "$expected_status" \
        && "$observed_result" == "$expected_result" \
        && "$observed_guard" == "$expected_guard" \
        && ! -s "$stdout_path" \
        && ! -s "$stderr_path" ]] ||
        fail "direct classifier fixture failed: $case_id"
    builtin printf '%s\t%s\t%s\n' \
        "$case_id" "$guard_id" "$predicate_value" >> "$classifier_witness_registry"
    direct_index=$((direct_index + 1))
done

readonly classifier_ast="$test_root/classifier.ast"
/usr/bin/xcrun swiftc -frontend -dump-parse "$classifier_path" \
    > "$classifier_ast" 2> "$test_root/classifier-ast.stderr" ||
    fail "classifier source did not parse into a Swift AST"
/bin/bash -p -n "$helper_path"
/bin/bash -p -n "$test_path"
readonly static_witness_registry="$test_root/static-witnesses"
: > "$static_witness_registry"
readonly static_check_count="$(authority_jq -r '.staticSourceContractRegistry | length')"
[[ "$static_check_count" == "8" ]] || fail "static source registry count changed"
static_index=0
while [[ "$static_index" -lt "$static_check_count" ]]; do
    static_case="$(authority_jq -c ".staticSourceContractRegistry[$static_index]")"
    check_id="$(/usr/bin/jq -r '.checkID' <<< "$static_case")"
    guard_id="$(/usr/bin/jq -r '.guardID' <<< "$static_case")"
    predicate_value="$(/usr/bin/jq -r '.predicateValue' <<< "$static_case")"
    component_relative="$(/usr/bin/jq -r '.futureComponentPath' <<< "$static_case")"
    symbol_anchor="$(/usr/bin/jq -r '.exactSymbolOrSourceAnchor' <<< "$static_case")"
    branch_anchor="$(/usr/bin/jq -r '.exactInvariantOrBranchAnchor' <<< "$static_case")"
    component_path="$repository_root/$component_relative"
    [[ -f "$component_path" && ! -L "$component_path" ]] ||
        fail "static source witness component is unavailable: $check_id"
    if [[ "$component_relative" \
            == ".github/scripts/PrimeExactRevisionTopologyClassifier.swift" ]]; then
        /usr/bin/grep -Fq -- "$symbol_anchor" "$classifier_ast" ||
            fail "classifier static witness function is absent from AST: $check_id"
        /usr/bin/grep -Fq -- "$branch_anchor" "$classifier_ast" ||
            fail "classifier static witness branch is absent from AST: $check_id"
    else
        helper_function_slice="$(/usr/bin/awk \
            -v opening="$symbol_anchor() {" '
                $0 == opening { inside = 1 }
                inside { print }
                inside && $0 == "}" { exit }
            ' "$component_path")"
        [[ "$helper_function_slice" == "$symbol_anchor() {"$'\n'* \
            && "$helper_function_slice" == *$'\n}' \
            && "$helper_function_slice" == *"$branch_anchor"* \
            && "$helper_function_slice" == *"$guard_id"* ]] ||
            fail "helper static witness is not an executable delimited function branch: $check_id"
    fi
    builtin printf '%s\t%s\t%s\n' \
        "$check_id" "$guard_id" "$predicate_value" >> "$static_witness_registry"
    static_index=$((static_index + 1))
done

# The shared library is sourced only after its gate-owned tracked identity was
# admitted. It must define the sole live topology-verification entry point.
source "$helper_path"
[[ "$(type -t prime_verify_exact_revision_topology_v1)" == "function" ]] ||
    fail "shared helper API is unavailable after source"
[[ "$(type -t prime_test_classify_exact_revision_topology_observation_v1)" \
        == "function" ]] ||
    fail "shared helper pure observation adapter is unavailable after source"
[[ "$(type -t prime_test_exact_revision_topology_v1)" == "function" ]] ||
    fail "relation production pure hook is unavailable after source"
[[ "$(type -t prime_verify_exact_revision_topology_core_v1)" == "function" ]] ||
    fail "closed relation helper core is unavailable after source"
[[ "$(type -t prime_test_exact_revision_topology_post_raw_index_mutation_v1)" \
        == "function" ]] ||
    fail "closed post-raw mutation wrapper is unavailable after source"
[[ "$(type -t prime_enter_exact_revision_topology_closed_child_v1)" \
        == "function" ]] ||
    fail "one-way closed-child trace boundary is unavailable after source"
[[ "$(type -t prime_clear_exact_revision_topology_private_candidate_v1)" \
        == "function" ]] ||
    fail "closed-child private-candidate clear API is unavailable after source"

readonly private_object_count="$(authority_jq -r '.privateGitObjectFixtures | length')"
[[ "$private_object_count" == "9" ]] || fail "private object fixture count changed"

substitute_recipe_argument() {
    local argument="$1"
    local private_origin="$2"
    local private_destination="$3"
    case "$argument" in
        'TMPDIR=<validated_private_compiler_root>')
            builtin printf '%s\n' "TMPDIR=$test_root"
            ;;
        'CLANG_MODULE_CACHE_PATH=<validated_private_compiler_root>/clang-module-cache')
            builtin printf '%s\n' \
                "CLANG_MODULE_CACHE_PATH=$test_root/recipe-clang-module-cache"
            ;;
        '<private_bare_origin>') builtin printf '%s\n' "$private_origin" ;;
        '<private_destination>') builtin printf '%s\n' "$private_destination" ;;
        '<canonical_absolute_private_repository>')
            builtin printf '%s\n' "$private_destination"
            ;;
        *) builtin printf '%s\n' "$argument" ;;
    esac
}

execute_private_git_recipe() {
    local matrix_case="$1"
    local private_origin="$2"
    local private_destination="$3"
    local case_id recipe_id recipe operation_count operation_index
    case_id="$(/usr/bin/jq -r '.caseID' <<< "$matrix_case")"
    recipe_id="$(/usr/bin/jq -r '.privateGitRecipeID' <<< "$matrix_case")"
    recipe="$(authority_jq -c \
        --arg recipe_id "$recipe_id" \
        '.privateGitConstructionRecipes[] | select(.recipeID == $recipe_id)')"
    [[ -n "$recipe" \
        && "$(/usr/bin/jq -r '.recipeKind' <<< "$recipe")" \
            == "fully_concrete_private_sha1_graph_depth_want_case" \
        && "$(/usr/bin/jq -r '.noNetwork' <<< "$recipe")" == "true" \
        && "$(/usr/bin/jq -r '.usesOnlyPrivateTemporaryRepositories' <<< "$recipe")" \
            == "true" \
        && "$(/usr/bin/jq -r '.historicalEvidenceClaimedDynamicallyReplayed' <<< "$recipe")" \
            == "false" ]] ||
        fail "private Git construction recipe contract changed: $case_id"

    # Materialize and validate all nine typed source objects before executing
    # any recipe command that can write them into a repository.
    local private_object_index object_case fixture_id object_type fixture_json
    local fixture_path
    private_object_index=0
    while [[ "$private_object_index" -lt "$private_object_count" ]]; do
        object_case="$(authority_jq -c \
            ".privateGitObjectFixtures[$private_object_index]")"
        fixture_id="$(/usr/bin/jq -r '.fixtureID' <<< "$object_case")"
        object_type="$(/usr/bin/jq -r '.objectType' <<< "$object_case")"
        fixture_json="$(/usr/bin/jq -c '.fixture' <<< "$object_case")"
        fixture_path="$test_root/$case_id.$fixture_id.payload"
        materialize_fixture "$fixture_json" "$fixture_path" "$object_type"
        private_object_index=$((private_object_index + 1))
    done

    operation_count="$(/usr/bin/jq -r '.exactArgumentVectors | length' <<< "$recipe")"
    [[ "$operation_count" \
            == "$(/usr/bin/jq -r '.exactExpectedStatuses | length' <<< "$recipe")" \
        && "$operation_count" \
            == "$(/usr/bin/jq -r '.exactStandardInputDescriptors | length' <<< "$recipe")" \
        && "$operation_count" \
            == "$(/usr/bin/jq -r '.exactStdoutBase64 | length' <<< "$recipe")" ]] ||
        fail "private recipe vector cardinalities differ: $case_id"
    operation_index=0
    while [[ "$operation_index" -lt "$operation_count" ]]; do
        local argument_count argument_index argument stdin_descriptor stdin_path
        local expected_status observed_status stdout_path stderr_path expected_stdout_base64
        argument_count="$(/usr/bin/jq -r \
            ".exactArgumentVectors[$operation_index] | length" <<< "$recipe")"
        recipe_arguments=()
        argument_index=0
        while [[ "$argument_index" -lt "$argument_count" ]]; do
            argument="$(/usr/bin/jq -r \
                ".exactArgumentVectors[$operation_index][$argument_index]" \
                <<< "$recipe")"
            recipe_arguments+=("$(substitute_recipe_argument \
                "$argument" "$private_origin" "$private_destination")")
            argument_index=$((argument_index + 1))
        done
        [[ "${recipe_arguments[0]}" == "/usr/bin/env" \
            && "${recipe_arguments[1]}" == "-i" ]] ||
            fail "private recipe is not an exact empty-environment argv: $case_id/$operation_index"

        stdin_descriptor="$(/usr/bin/jq -r \
            ".exactStandardInputDescriptors[$operation_index]" <<< "$recipe")"
        case "$stdin_descriptor" in
            none|empty) stdin_path=/dev/null ;;
            fixture:*)
                fixture_id="${stdin_descriptor#fixture:}"
                stdin_path="$test_root/$case_id.$fixture_id.payload"
                [[ -f "$stdin_path" && ! -L "$stdin_path" ]] ||
                    fail "private recipe fixture stdin is unavailable: $case_id/$fixture_id"
                ;;
            *) fail "unknown private recipe stdin descriptor: $stdin_descriptor" ;;
        esac
        stdout_path="$test_root/$case_id.recipe-$operation_index.stdout"
        stderr_path="$test_root/$case_id.recipe-$operation_index.stderr"
        expected_status="$(/usr/bin/jq -r \
            ".exactExpectedStatuses[$operation_index]" <<< "$recipe")"
        set +e
        "${recipe_arguments[@]}" < "$stdin_path" \
            > "$stdout_path" 2> "$stderr_path"
        observed_status="$?"
        set -e
        [[ "$observed_status" == "$expected_status" ]] ||
            fail "private recipe operation status changed: $case_id/$operation_index"
        expected_stdout_base64="$(/usr/bin/jq -r \
            ".exactStdoutBase64[$operation_index] // empty" <<< "$recipe")"
        if [[ -n "$expected_stdout_base64" ]]; then
            builtin printf '%s' "$expected_stdout_base64" | /usr/bin/base64 -D \
                > "$test_root/$case_id.recipe-$operation_index.expected" ||
                fail "could not decode private recipe expected stdout"
            /usr/bin/cmp -s \
                "$stdout_path" "$test_root/$case_id.recipe-$operation_index.expected" ||
                fail "private recipe exact stdout changed: $case_id/$operation_index"
        fi
        operation_index=$((operation_index + 1))
    done

    local preprobe_count preprobe_index preprobe_input preprobe_output
    local expected_preprobe preprobe_argument_count
    preprobe_input="$test_root/$case_id.source-preprobe.input"
    preprobe_output="$test_root/$case_id.source-preprobe.output"
    expected_preprobe="$test_root/$case_id.source-preprobe.expected"
    authority_jq -r --arg recipe_id "$recipe_id" \
        '.privateGitConstructionRecipes[] | select(.recipeID == $recipe_id) | .exactSourceObjectOIDs[]' \
        > "$preprobe_input"
    authority_jq -r --arg recipe_id "$recipe_id" \
        '.privateGitConstructionRecipes[] | select(.recipeID == $recipe_id) | .exactSourceAvailabilityExpectedLines[]' \
        > "$expected_preprobe"
    preprobe_argument_count="$(/usr/bin/jq -r \
        '.exactSourceAvailabilityPreprobeArgumentVector | length' <<< "$recipe")"
    recipe_arguments=()
    preprobe_index=0
    while [[ "$preprobe_index" -lt "$preprobe_argument_count" ]]; do
        argument="$(/usr/bin/jq -r \
            ".exactSourceAvailabilityPreprobeArgumentVector[$preprobe_index]" \
            <<< "$recipe")"
        recipe_arguments+=("$(substitute_recipe_argument \
            "$argument" "$private_origin" "$private_destination")")
        preprobe_index=$((preprobe_index + 1))
    done
    "${recipe_arguments[@]}" < "$preprobe_input" > "$preprobe_output" \
        2> "$test_root/$case_id.source-preprobe.stderr" ||
        fail "private recipe exact source preprobe failed: $case_id"
    /usr/bin/cmp -s "$preprobe_output" "$expected_preprobe" ||
        fail "private recipe source object inventory changed: $case_id"
}

build_helper_arguments() {
    local matrix_case="$1"
    local repository="$2"
    helper_arguments=("$repository")
    local request_count request_index
    request_count="$(/usr/bin/jq -r '.verificationRequests | length' <<< "$matrix_case")"
    helper_arguments+=("$request_count")
    request_index=0
    while [[ "$request_index" -lt "$request_count" ]]; do
        local request role oid tree parent_count parent_index
        request="$(/usr/bin/jq -c ".verificationRequests[$request_index]" <<< "$matrix_case")"
        role="$(/usr/bin/jq -r '.objectRole' <<< "$request")"
        oid="$(/usr/bin/jq -r '.literalCommitOID' <<< "$request")"
        tree="$(/usr/bin/jq -r '.expectedTreeOID' <<< "$request")"
        parent_count="$(/usr/bin/jq -r '.expectedOrderedParentOIDs | length' <<< "$request")"
        helper_arguments+=("$role" "$oid" "$tree" "$parent_count")
        parent_index=0
        while [[ "$parent_index" -lt "$parent_count" ]]; do
            helper_arguments+=("$(/usr/bin/jq -r \
                ".expectedOrderedParentOIDs[$parent_index]" <<< "$request")")
            parent_index=$((parent_index + 1))
        done
        request_index=$((request_index + 1))
    done
}

invoke_helper() {
    local record_path="$1"
    local stderr_path="$2"
    shift 2
    set +e
    prime_verify_exact_revision_topology_v1 "$@" \
        > "$record_path" 2> "$stderr_path"
    helper_status="$?"
    set -e
    [[ ! -s "$stderr_path" ]] || fail "shared helper published stderr"
}

readonly private_matrix_witness_registry="$test_root/private-matrix-witnesses"
: > "$private_matrix_witness_registry"
readonly live_case_count="$(authority_jq -r \
    '[.githubDepthTwoMultiWantMatrix[] | select(.executionKind == "live_private_repository")] | length')"
[[ "$live_case_count" == "8" ]] || fail "live private-Git matrix count changed"
live_index=0
while [[ "$live_index" -lt "$live_case_count" ]]; do
    matrix_case="$(authority_jq -c \
        "[.githubDepthTwoMultiWantMatrix[] | select(.executionKind == \"live_private_repository\")][$live_index]")"
    case_id="$(/usr/bin/jq -r '.caseID' <<< "$matrix_case")"
    private_origin="$test_root/private-case-$live_index-origin.git"
    repository="$test_root/private-case-$live_index"
    execute_private_git_recipe "$matrix_case" "$private_origin" "$repository"
    [[ -z "$(git_clean -C "$repository" status --porcelain=v1 --untracked-files=all)" ]] ||
        fail "private matrix repository is dirty: $case_id"

    expected_shallow="$(/usr/bin/jq -r '.shallowState' <<< "$matrix_case")"
    observed_shallow="$(git_clean -C "$repository" rev-parse --is-shallow-repository)"
    case "$expected_shallow" in
        shallow) [[ "$observed_shallow" == "true" ]] ;;
        complete) [[ "$observed_shallow" == "false" ]] ;;
        *) false ;;
    esac || fail "private matrix shallow state changed: $case_id"

    if [[ "$(/usr/bin/jq -r '.legacyPorcelainAncestryProbeExecuted' <<< "$matrix_case")" \
            == "true" ]]; then
        mechanics_merge="$(authority_jq -r \
            '.privateGitObjectFixtures[] | select(.fixtureID == "private_git_object_mechanics_merge") | .fixture.literalObjectOID')"
        private_base="$(authority_jq -r \
            '.privateGitObjectFixtures[] | select(.fixtureID == "private_git_object_base") | .fixture.literalObjectOID')"
        set +e
        git_clean -C "$repository" merge-base --is-ancestor \
            "$mechanics_merge^2^1" "$private_base" >/dev/null 2>&1
        legacy_forward_status="$?"
        git_clean -C "$repository" merge-base --is-ancestor \
            "$private_base" "$mechanics_merge^2^1" >/dev/null 2>&1
        legacy_reverse_status="$?"
        set -e
        [[ "$legacy_forward_status" -ne 0 && "$legacy_reverse_status" -ne 0 ]] ||
            fail "legacy shallow multi-hop porcelain unexpectedly resolved"
    fi

    build_helper_arguments "$matrix_case" "$repository"
    record_path="$test_root/private-case-$live_index.record"
    stderr_path="$test_root/private-case-$live_index.helper.stderr"
    invoke_helper "$record_path" "$stderr_path" "${helper_arguments[@]}"
    expected_result="$(/usr/bin/jq -r '.expectedResultCode' <<< "$matrix_case")"
    expected_guard="$(/usr/bin/jq -r '.expectedFirstFailedGuardID // "null"' <<< "$matrix_case")"
    expected_missing="$(/usr/bin/jq -r '.expectedMissingObjectRole // "null"' <<< "$matrix_case")"
    validate_result_record \
        "$record_path" "$helper_status" "$expected_result" \
        "$expected_guard" "$expected_missing" "$expected_shallow"
    builtin printf '%s\t%s\n' "$case_id" "$expected_guard" \
        >> "$private_matrix_witness_registry"
    live_index=$((live_index + 1))
done

# Exercise the frozen verified baseline through the same helper. This is the
# positive witness shared by every predicate pair; its bytes prove both their
# SHA-256 digest and repository-native Git OID before the helper sees them.
baseline_repository="$test_root/verified-baseline"
baseline_init_count="$(authority_jq -r \
    '.verifiedEndToEndBaseline.exactPrivateRepositoryInitArgumentVector | length')"
baseline_init_arguments=()
baseline_argument_index=0
while [[ "$baseline_argument_index" -lt "$baseline_init_count" ]]; do
    baseline_argument="$(authority_jq -r \
        ".verifiedEndToEndBaseline.exactPrivateRepositoryInitArgumentVector[$baseline_argument_index]")"
    baseline_init_arguments+=("$(substitute_recipe_argument \
        "$baseline_argument" "$test_root/unused-baseline-origin" "$baseline_repository")")
    baseline_argument_index=$((baseline_argument_index + 1))
done
set +e
"${baseline_init_arguments[@]}" \
    > "$test_root/baseline-init.stdout" 2> "$test_root/baseline-init.stderr"
baseline_init_status="$?"
set -e
[[ "$baseline_init_status" \
        == "$(authority_jq -r '.verifiedEndToEndBaseline.exactPrivateRepositoryInitStatus')" ]] ||
    fail "verified baseline exact init vector failed"
baseline_fixture="$(authority_jq -c '.verifiedEndToEndBaseline.commitFixture')"
baseline_payload="$test_root/baseline.payload"
materialize_fixture "$baseline_fixture" "$baseline_payload"
baseline_write_count="$(authority_jq -r \
    '.verifiedEndToEndBaseline.exactCommitWriteArgumentVector | length')"
baseline_write_arguments=()
baseline_argument_index=0
while [[ "$baseline_argument_index" -lt "$baseline_write_count" ]]; do
    baseline_argument="$(authority_jq -r \
        ".verifiedEndToEndBaseline.exactCommitWriteArgumentVector[$baseline_argument_index]")"
    baseline_write_arguments+=("$(substitute_recipe_argument \
        "$baseline_argument" "$test_root/unused-baseline-origin" "$baseline_repository")")
    baseline_argument_index=$((baseline_argument_index + 1))
done
set +e
"${baseline_write_arguments[@]}" < "$baseline_payload" \
    > "$test_root/baseline-write.stdout" 2> "$test_root/baseline-write.stderr"
baseline_write_status="$?"
set -e
builtin printf '%s' "$(authority_jq -r \
    '.verifiedEndToEndBaseline.exactCommitWriteStdoutBase64')" | \
    /usr/bin/base64 -D > "$test_root/baseline-write.expected"
[[ "$baseline_write_status" \
        == "$(authority_jq -r '.verifiedEndToEndBaseline.exactCommitWriteStatus')" \
    && ! -s "$test_root/baseline-write.stderr" ]] \
    && /usr/bin/cmp -s \
        "$test_root/baseline-write.stdout" "$test_root/baseline-write.expected" ||
    fail "verified baseline exact write vector/stdout changed"
[[ -z "$(git_clean -C "$baseline_repository" \
        status --porcelain=v1 --untracked-files=all)" ]] ||
    fail "verified baseline repository is not clean after its sole object write"
baseline_case="$(authority_jq -c \
    '{verificationRequests: .verifiedEndToEndBaseline.requestVector}')"
build_helper_arguments "$baseline_case" "$baseline_repository"
invoke_helper "$test_root/baseline.record" "$test_root/baseline.helper.stderr" \
    "${helper_arguments[@]}"
validate_result_record \
    "$test_root/baseline.record" "$helper_status" TOPOLOGY_VERIFIED \
    null null complete

# Every pure-source matrix row remains dynamically bound to reproducible bytes
# when it owns a fixture, and otherwise to one direct helper/static witness.
readonly pure_matrix_witness_registry="$test_root/pure-matrix-witnesses"
: > "$pure_matrix_witness_registry"
readonly pure_case_count="$(authority_jq -r \
    '[.githubDepthTwoMultiWantMatrix[] | select(.executionKind == "pure_source_contract")] | length')"
[[ "$pure_case_count" == "10" ]] || fail "pure-source matrix count changed"
pure_index=0
while [[ "$pure_index" -lt "$pure_case_count" ]]; do
    matrix_case="$(authority_jq -c \
        "[.githubDepthTwoMultiWantMatrix[] | select(.executionKind == \"pure_source_contract\")][$pure_index]")"
    case_id="$(/usr/bin/jq -r '.caseID' <<< "$matrix_case")"
    fixture_present="$(/usr/bin/jq -r '.syntheticFixture != null' <<< "$matrix_case")"
    if [[ "$fixture_present" == "true" ]]; then
        fixture_json="$(/usr/bin/jq -c '.syntheticFixture' <<< "$matrix_case")"
        payload_path="$test_root/pure-matrix-$pure_index.payload"
        materialize_fixture "$fixture_json" "$payload_path"
    fi
    case "$case_id" in
        available_commit_has_reordered_parent_headers|available_commit_has_extra_parent_header|available_commit_has_wrong_tree_oid|malformed_header_tree_is_not_first|nul_byte_in_commit_object_is_rejected_before_shell_parse|oversized_commit_object_is_rejected_before_raw_content_stream)
            [[ "$fixture_present" == "true" ]] ||
                fail "byte-classified pure matrix row lost its fixture: $case_id"
            ;;
        invalid_symbolic_ref_token_is_rejected_before_git)
            [[ "$(/usr/bin/jq -r '.verificationRequests[0].literalCommitOID' <<< "$matrix_case")" \
                    == "HEAD" ]] \
                && /usr/bin/grep -Fq -- \
                    'literal_commit_oid_is_lowercase_40hex' "$helper_path" ||
                fail "invalid symbolic-ref pure contract is not represented"
            ;;
        fixed_git_verifier_is_unavailable)
            /usr/bin/grep -Fq -- \
                    'prime_admit_exact_revision_topology_tools_v1' "$helper_path" ||
                fail "fixed-tool unavailable pure contract is not represented"
            ;;
        cat_file_observation_pipeline_fails)
            [[ "$fixture_present" == "true" ]] \
                && /usr/bin/grep -Fq -- \
                    'git_cat_file_transport_succeeded' "$helper_path" ||
                fail "cat-file transport pure contract is not represented"
            ;;
        non_sha1_repository_object_format_is_unsupported)
            /usr/bin/grep -Fq -- \
                    'repository_object_format_sha1' "$helper_path" ||
                fail "non-SHA-1 pure contract is not represented"
            ;;
        *) fail "unknown pure-source matrix row: $case_id" ;;
    esac
    builtin printf '%s\n' "$case_id" >> "$pure_matrix_witness_registry"
    pure_index=$((pure_index + 1))
done

# Drive every helper-parser fixture through the sourced helper's pure internal
# observation adapter. The adapter consumes the frozen exact decoded bytes,
# statuses, repository token, and request vector without a process or Git call.
readonly helper_parser_witness_registry="$test_root/helper-parser-witnesses"
: > "$helper_parser_witness_registry"
readonly helper_parser_observation_byte_registry="$test_root/helper-parser-observation-bytes"
: > "$helper_parser_observation_byte_registry"
readonly helper_parser_count="$(authority_jq -r '.helperParserFixtureMatrix | length')"
[[ "$helper_parser_count" == "32" ]] || fail "helper parser fixture matrix count changed"
helper_parser_nul_free_count=0
helper_parser_lossless_read_count=0
helper_parser_single_trailing_lf_count=0
helper_parser_maximum_observation_byte_count=0
helper_parser_index=0
while [[ "$helper_parser_index" -lt "$helper_parser_count" ]]; do
    helper_case="$(authority_jq -c ".helperParserFixtureMatrix[$helper_parser_index]")"
    case_id="$(/usr/bin/jq -r '.caseID' <<< "$helper_case")"
    guard_id="$(/usr/bin/jq -r '.guardID' <<< "$helper_case")"
    predicate_value="$(/usr/bin/jq -r '.predicateValue' <<< "$helper_case")"
    observation="$test_root/helper-parser-$helper_parser_index.observation"
    observation_base64="$(/usr/bin/jq -r '.boundedObservationStdoutBase64' <<< "$helper_case")"
    builtin printf '%s' "$observation_base64" | /usr/bin/base64 -D > "$observation" ||
        fail "could not decode helper-parser fixture: $case_id"
    observation_byte_count="$(/usr/bin/wc -c < "$observation" | /usr/bin/awk '{print $1}')"
    observation_non_nul_byte_count="$(LC_ALL=C /usr/bin/tr -d '\000' \
        < "$observation" | /usr/bin/wc -c | /usr/bin/awk '{print $1}')"
    [[ "$observation_non_nul_byte_count" == "$observation_byte_count" ]] ||
        fail "helper-parser fixture contains a NUL byte: $case_id"
    helper_parser_nul_free_count=$((helper_parser_nul_free_count + 1))
    if [[ "$observation_byte_count" -gt "$helper_parser_maximum_observation_byte_count" ]]; then
        helper_parser_maximum_observation_byte_count="$observation_byte_count"
    fi
    observation_last_byte_base64="$(/usr/bin/tail -c 1 "$observation" | /usr/bin/base64)"
    observation_last_two_bytes_base64="$(/usr/bin/tail -c 2 "$observation" | /usr/bin/base64)"
    if [[ "$observation_last_byte_base64" == "Cg==" ]]; then
        [[ "$observation_last_two_bytes_base64" != "Cgo=" ]] ||
            fail "helper-parser fixture has more than one trailing LF: $case_id"
        helper_parser_single_trailing_lf_count=$((helper_parser_single_trailing_lf_count + 1))
    fi

    # Bash command substitution removes trailing LFs, and its `$(<file)`
    # fast-path emits no file bytes when another command shares the same
    # substitution.  A NUL-delimited builtin read reaches EOF here because the
    # complete frozen corpus was admitted as NUL-free immediately above.  The
    # replay comparison proves that every byte, including every trailing LF,
    # reached the helper adapter unchanged.
    observation_text=""
    IFS= builtin read -r -d '' observation_text < "$observation" || true
    observation_replay="$test_root/helper-parser-$helper_parser_index.observation-replay"
    builtin printf '%s' "$observation_text" > "$observation_replay"
    /usr/bin/cmp -s "$observation" "$observation_replay" ||
        fail "helper-parser EOF read changed observation bytes: $case_id"
    helper_parser_lossless_read_count=$((helper_parser_lossless_read_count + 1))
    builtin printf '%s\t%s\t%s\n' \
        "$case_id" "$observation_byte_count" \
        "$(/usr/bin/shasum -a 256 "$observation" | /usr/bin/awk '{print $1}')" \
        >> "$helper_parser_observation_byte_registry"
    observation_kind="$(/usr/bin/jq -r '.observationKind' <<< "$helper_case")"
    saved_git_status="$(/usr/bin/jq -r \
        '.savedGitStatus | if . == null then "null" else tostring end' \
        <<< "$helper_case")"
    saved_classifier_status="$(/usr/bin/jq -r \
        '.savedClassifierStatus | if . == null then "null" else tostring end' \
        <<< "$helper_case")"
    repository_argument="$(/usr/bin/jq -r '.repositoryArgument' <<< "$helper_case")"
    helper_fixture_vector="$(/usr/bin/jq -c \
        '{verificationRequests: .requestVector}' <<< "$helper_case")"
    build_helper_arguments "$helper_fixture_vector" "$repository_argument"
    set +e
    prime_test_classify_exact_revision_topology_observation_v1 \
        "$observation_kind" \
        "$saved_git_status" \
        "$saved_classifier_status" \
        "$observation_text" \
        -- \
        "${helper_arguments[@]}" \
        > "$test_root/helper-parser-$helper_parser_index.stdout" \
        2> "$test_root/helper-parser-$helper_parser_index.stderr"
    helper_parser_status="$?"
    set -e
    expected_result="$(/usr/bin/jq -r \
        '.expectedResultCode // "TOPOLOGY_VERIFIED"' <<< "$helper_case")"
    expected_guard="$(/usr/bin/jq -r \
        '.expectedFirstFailedGuardID // ""' <<< "$helper_case")"
    [[ "$helper_parser_status" == "0" \
        && ! -s "$test_root/helper-parser-$helper_parser_index.stdout" \
        && ! -s "$test_root/helper-parser-$helper_parser_index.stderr" \
        && "$prime_topology_test_result_code" == "$expected_result" \
        && "$prime_topology_test_first_failed_guard_id" == "$expected_guard" ]] ||
        fail "direct helper parser fixture failed: $case_id"
    builtin printf '%s\t%s\t%s\n' \
        "$case_id" "$guard_id" "$predicate_value" >> "$helper_parser_witness_registry"
    helper_parser_index=$((helper_parser_index + 1))
done
[[ "$helper_parser_nul_free_count" == "$helper_parser_count" \
    && "$helper_parser_lossless_read_count" == "$helper_parser_count" \
    && "$helper_parser_single_trailing_lf_count" == "11" \
    && "$helper_parser_maximum_observation_byte_count" == "58" \
    && "$(/usr/bin/wc -l < "$helper_parser_observation_byte_registry" | /usr/bin/awk '{print $1}')" \
        == "$helper_parser_count" ]] ||
    fail "helper-parser NUL-free/lossless-read accounting changed"

# Resolve each frozen negative witness to an executed direct/private case or a
# parsed exact helper/static source witness. Positive witnesses all resolve to
# the one end-to-end verified baseline above.
authority_jq -e '
    .verifiedEndToEndBaseline.deterministicAndDynamicallyExecutable
    and (.verifierPredicateProofPairs | length) == 35
    and ([.verifierPredicateProofPairs[].guardID] | unique | length) == 35
    and ([.verifierPredicateWitnesses[] | select(.predicateValue == true)] | length) == 35
    and ([.verifierPredicateWitnesses[] | select(.predicateValue == false)] | length) == 35
    and all(.verifierPredicateWitnesses[] | select(.predicateValue == true);
        .verifiedBaselineID == "private_git_end_to_end_verified_baseline")
    and all(.verifierPredicateWitnesses[] | select(.predicateValue == false);
        ([.classifierCaseID, .helperParserCaseID, .privateGitMatrixCaseID, .staticCheckID]
            | map(select(. != null)) | length) == 1)
' >/dev/null || fail "predicate proof/witness ontology changed"

readonly observed_live_case_ids="$(/usr/bin/awk -F '\t' '{print $1}' \
    "$private_matrix_witness_registry")"
readonly expected_live_case_ids="$(authority_jq -r \
    '.futureImplementationPatch.liveTestMustExerciseExactMatrixCaseIDs[]')"
[[ "$observed_live_case_ids" == "$expected_live_case_ids" ]] ||
    fail "live private-Git matrix case coverage is not exact"
readonly observed_pure_case_ids="$(< "$pure_matrix_witness_registry")"
readonly expected_pure_case_ids="$(authority_jq -r \
    '.futureImplementationPatch.pureSourceContractMustExerciseExactMatrixCaseIDs[]')"
[[ "$observed_pure_case_ids" == "$expected_pure_case_ids" ]] ||
    fail "pure-source matrix case coverage is not exact"
readonly observed_classifier_case_ids="$(/usr/bin/awk -F '\t' '{print $1}' \
    "$classifier_witness_registry")"
readonly expected_classifier_case_ids="$(authority_jq -r \
    '.futureImplementationPatch.classifierDirectFixtureCaseIDs[]')"
[[ "$observed_classifier_case_ids" == "$expected_classifier_case_ids" ]] ||
    fail "direct classifier fixture coverage is not exact"

# Materialize the additive authority's complete object registry independently of
# every destination repository. The withheld child is decoded and identity-
# rebound here but is deliberately never written by any destination recipe.
readonly relation_fixture_root="$test_root/relation-fixtures"
/bin/mkdir -m 700 "$relation_fixture_root"
readonly relation_object_count="$(relation_authority_jq -r \
    '.syntheticGitObjectFixtures | length')"
[[ "$relation_object_count" == "24" ]] ||
    fail "relation object fixture count changed"
relation_object_index=0
while [[ "$relation_object_index" -lt "$relation_object_count" ]]; do
    relation_object="$(relation_authority_jq -c \
        ".syntheticGitObjectFixtures[$relation_object_index]")"
    relation_fixture_id="$(/usr/bin/jq -r '.fixtureID' <<< "$relation_object")"
    relation_object_type="$(/usr/bin/jq -r '.objectType' <<< "$relation_object")"
    relation_object_path="$relation_fixture_root/$relation_fixture_id.payload"
    builtin printf '%s' "$(/usr/bin/jq -r '.payloadBase64' \
        <<< "$relation_object")" | /usr/bin/base64 -D \
        > "$relation_object_path" ||
        fail "could not decode relation object fixture: $relation_fixture_id"
    [[ -f "$relation_object_path" \
        && ! -L "$relation_object_path" \
        && "$(/usr/bin/base64 < "$relation_object_path" | /usr/bin/tr -d '\n')" \
            == "$(/usr/bin/jq -r '.payloadBase64' <<< "$relation_object")" \
        && "$(/usr/bin/wc -c < "$relation_object_path" | /usr/bin/awk '{print $1}')" \
            == "$(/usr/bin/jq -r '.payloadByteCount' <<< "$relation_object")" \
        && "$(/usr/bin/shasum -a 256 "$relation_object_path" | /usr/bin/awk '{print $1}')" \
            == "$(/usr/bin/jq -r '.payloadSHA256' <<< "$relation_object")" \
        && "$(git_clean hash-object --literally -t "$relation_object_type" --stdin \
            < "$relation_object_path")" \
            == "$(/usr/bin/jq -r '.literalObjectOID' <<< "$relation_object")" ]] ||
        fail "relation object bytes did not reproduce identity: $relation_fixture_id"
    relation_object_index=$((relation_object_index + 1))
done

relation_decode_exact_field() {
    local fixture_json="$1"
    local base64_field="$2"
    local byte_count_field="$3"
    local sha256_field="$4"
    local destination="$5"
    local encoded
    encoded="$(/usr/bin/jq -r ".$base64_field" <<< "$fixture_json")"
    builtin printf '%s' "$encoded" | /usr/bin/base64 -D > "$destination" ||
        fail "could not decode exact relation field: $base64_field"
    [[ "$(/usr/bin/base64 < "$destination" | /usr/bin/tr -d '\n')" \
            == "$encoded" \
        && "$(/usr/bin/wc -c < "$destination" | /usr/bin/awk '{print $1}')" \
            == "$(/usr/bin/jq -r ".$byte_count_field" <<< "$fixture_json")" \
        && "$(/usr/bin/shasum -a 256 "$destination" | /usr/bin/awk '{print $1}')" \
            == "$(/usr/bin/jq -r ".$sha256_field" <<< "$fixture_json")" ]] ||
        fail "decoded relation field identity changed: $base64_field"
}

relation_capture_as_argument() {
    local capture_path="$1"
    relation_raw_capture=""
    IFS= builtin read -r -d '' relation_raw_capture < "$capture_path" || true
    [[ "${#relation_raw_capture}" \
            == "$(/usr/bin/wc -c < "$capture_path" | /usr/bin/awk '{print $1}')" ]] ||
        fail "lossless NUL-free capture argument changed"
}

relation_substitute_argument() {
    local argument="$1"
    local private_repository="${2:-$test_root/relation-pure-repository}"
    local object_type="${3:-}"
    case "$argument" in
        '<private_repository>'|'<canonical_absolute_private_repository>')
            builtin printf '%s\n' "$private_repository"
            ;;
        '<actor_validated_private_root>'|'<validated_private_compiler_root>')
            builtin printf '%s\n' "$test_root"
            ;;
        '<validated_private_compiler_root>/prime-exact-revision-topology-classifier')
            builtin printf '%s\n' "$classifier_executable"
            ;;
        '<object_type>')
            [[ -n "$object_type" ]] ||
                fail "object-type placeholder has no exact replacement"
            builtin printf '%s\n' "$object_type"
            ;;
        *) builtin printf '%s\n' "$argument" ;;
    esac
}

relation_load_rendered_arguments() {
    local compact_array_json="$1"
    local private_repository="${2:-$test_root/relation-pure-repository}"
    local object_type="${3:-}"
    local count index argument
    relation_arguments=()
    count="$(/usr/bin/jq -r 'length' <<< "$compact_array_json")"
    index=0
    while [[ "$index" -lt "$count" ]]; do
        argument="$(/usr/bin/jq -r ".[$index]" <<< "$compact_array_json")"
        relation_arguments+=("$(relation_substitute_argument \
            "$argument" "$private_repository" "$object_type")")
        index=$((index + 1))
    done
}

relation_prepare_private_repository() {
    local recipe_id="$1"
    local private_repository="$2"
    local recipe case_id operation_stdout operation_stderr observed_status
    local expected_status fixture_count fixture_index fixture_id fixture_json
    local object_type object_oid object_path inventory_contract inventory_input
    local inventory_expected inventory_observed
    recipe="$(relation_authority_jq -c --arg recipe_id "$recipe_id" \
        '.privateRepositoryExecutionRecipes[] | select(.recipeID == $recipe_id)')"
    [[ -n "$recipe" ]] || fail "unknown relation private recipe: $recipe_id"
    case_id="$(/usr/bin/jq -r '.ontologyCaseID' <<< "$recipe")"

    relation_load_rendered_arguments \
        "$(/usr/bin/jq -c '.exactInitArgumentVector' <<< "$recipe")" \
        "$private_repository"
    operation_stdout="$test_root/$case_id.init.stdout"
    operation_stderr="$test_root/$case_id.init.stderr"
    set +e
    "${relation_arguments[@]}" < /dev/null \
        > "$operation_stdout" 2> "$operation_stderr"
    observed_status="$?"
    set -e
    [[ "$observed_status" == "$(/usr/bin/jq -r '.initExpectedStatus' <<< "$recipe")" \
        && ! -s "$operation_stdout" && ! -s "$operation_stderr" ]] ||
        fail "relation private repository init failed: $case_id"

    fixture_count="$(/usr/bin/jq -r '.exactWrittenFixtureIDs | length' \
        <<< "$recipe")"
    fixture_index=0
    while [[ "$fixture_index" -lt "$fixture_count" ]]; do
        fixture_id="$(/usr/bin/jq -r ".exactWrittenFixtureIDs[$fixture_index]" \
            <<< "$recipe")"
        fixture_json="$(relation_authority_jq -c --arg fixture_id "$fixture_id" \
            '.syntheticGitObjectFixtures[] | select(.fixtureID == $fixture_id)')"
        object_type="$(/usr/bin/jq -r '.objectType' <<< "$fixture_json")"
        object_oid="$(/usr/bin/jq -r '.literalObjectOID' <<< "$fixture_json")"
        object_path="$relation_fixture_root/$fixture_id.payload"
        relation_load_rendered_arguments \
            "$(/usr/bin/jq -c '.exactObjectWriteArgumentVectorTemplate' \
                <<< "$recipe")" "$private_repository" "$object_type"
        operation_stdout="$test_root/$case_id.write-$fixture_index.stdout"
        operation_stderr="$test_root/$case_id.write-$fixture_index.stderr"
        set +e
        "${relation_arguments[@]}" < "$object_path" \
            > "$operation_stdout" 2> "$operation_stderr"
        observed_status="$?"
        set -e
        [[ "$observed_status" \
                == "$(/usr/bin/jq -r '.everyObjectWriteExpectedStatus' \
                    <<< "$recipe")" \
            && ! -s "$operation_stderr" \
            && "$(< "$operation_stdout")" == "$object_oid" \
            && "$(/usr/bin/wc -c < "$operation_stdout" | /usr/bin/awk '{print $1}')" \
                == "41" ]] ||
            fail "relation private object write failed: $case_id/$fixture_id"
        fixture_index=$((fixture_index + 1))
    done

    inventory_contract="$(relation_authority_jq -c \
        '.privateFixtureRepositoryContract')"
    inventory_input="$test_root/$case_id.inventory.stdin"
    inventory_expected="$test_root/$case_id.inventory.expected"
    inventory_observed="$test_root/$case_id.inventory.stdout"
    relation_decode_exact_field "$inventory_contract" inventoryStdinBase64 \
        inventoryStdinByteCount inventoryStdinSHA256 "$inventory_input"
    relation_decode_exact_field "$inventory_contract" inventoryExpectedStdoutBase64 \
        inventoryExpectedStdoutByteCount inventoryExpectedStdoutSHA256 \
        "$inventory_expected"
    relation_load_rendered_arguments \
        "$(/usr/bin/jq -c '.exactInventoryArgumentVector' \
            <<< "$inventory_contract")" "$private_repository"
    set +e
    "${relation_arguments[@]}" < "$inventory_input" \
        > "$inventory_observed" 2> "$test_root/$case_id.inventory.stderr"
    observed_status="$?"
    set -e
    [[ "$observed_status" \
            == "$(/usr/bin/jq -r '.inventoryExpectedStatus' \
                <<< "$inventory_contract")" \
        && ! -s "$test_root/$case_id.inventory.stderr" ]] \
        && /usr/bin/cmp -s "$inventory_observed" "$inventory_expected" ||
        fail "relation destination inventory changed: $case_id"

    relation_load_rendered_arguments \
        "$(/usr/bin/jq -c '.exactUpdateRefHEADArgumentVector' <<< "$recipe")" \
        "$private_repository"
    set +e
    "${relation_arguments[@]}" < /dev/null \
        > "$test_root/$case_id.update-ref.stdout" \
        2> "$test_root/$case_id.update-ref.stderr"
    observed_status="$?"
    set -e
    [[ "$observed_status" \
            == "$(/usr/bin/jq -r '.updateRefExpectedStatus' <<< "$recipe")" \
        && ! -s "$test_root/$case_id.update-ref.stdout" \
        && ! -s "$test_root/$case_id.update-ref.stderr" ]] ||
        fail "relation private HEAD setup failed: $case_id"

    relation_load_rendered_arguments \
        "$(/usr/bin/jq -c '.exactReadTreeArgumentVector' <<< "$recipe")" \
        "$private_repository"
    set +e
    "${relation_arguments[@]}" < /dev/null \
        > "$test_root/$case_id.read-tree.stdout" \
        2> "$test_root/$case_id.read-tree.stderr"
    observed_status="$?"
    set -e
    [[ "$observed_status" \
            == "$(/usr/bin/jq -r '.readTreeExpectedStatus' <<< "$recipe")" \
        && ! -s "$test_root/$case_id.read-tree.stdout" \
        && ! -s "$test_root/$case_id.read-tree.stderr" ]] ||
        fail "relation private index setup failed: $case_id"
}

# Six gate-root vectors use the gate's same production framed-capture parser,
# through its private privileged entry, exactly once apiece. They are pure
# injections: no mktemp or stat lifecycle call is credited here.
readonly relation_hook_witness_registry="$test_root/relation-hook-witnesses"
: > "$relation_hook_witness_registry"
readonly relation_hook_invocation_registry="$test_root/relation-hook-invocations"
: > "$relation_hook_invocation_registry"
relation_helper_hook_attempt_count=0
gate_root_hook_call_count=0
readonly gate_root_capture_count="$(relation_authority_jq -r \
    '.gatePrivateRootContract.exactCaptureVectors | length')"
[[ "$gate_root_capture_count" == "6" ]] ||
    fail "gate-root pure capture fixture count changed"
[[ "$EUID" == "501" ]] ||
    fail "gate-root exact synthetic metadata requires decimal effective uid 501"
gate_root_capture_index=0
while [[ "$gate_root_capture_index" -lt "$gate_root_capture_count" ]]; do
    gate_root_capture="$(relation_authority_jq -c \
        ".gatePrivateRootContract.exactCaptureVectors[$gate_root_capture_index]")"
    gate_root_fixture_id="$(/usr/bin/jq -r '.fixtureID' \
        <<< "$gate_root_capture")"
    gate_root_capture_path="$test_root/gate-root-$gate_root_capture_index.capture"
    relation_decode_exact_field "$gate_root_capture" captureBase64 \
        captureByteCount captureSHA256 "$gate_root_capture_path"
    relation_capture_as_argument "$gate_root_capture_path"
    set +e
    /bin/bash -p .github/scripts/prime-ci-active-root-quarantine.sh \
        --prime-internal-test-gate-root-capture-v1 \
        "$(/usr/bin/jq -r '.probeKind' <<< "$gate_root_capture")" \
        /private/tmp 501 \
        "$(/usr/bin/jq -r '.outerSubstitutionStatus' <<< "$gate_root_capture")" \
        "$relation_raw_capture" \
        "$(/usr/bin/jq -r '.expectedSanitizedClassification' \
            <<< "$gate_root_capture")" \
        "$(/usr/bin/jq -r '.expectedParsedValue' <<< "$gate_root_capture")" \
        > "$test_root/gate-root-$gate_root_capture_index.stdout" \
        2> "$test_root/gate-root-$gate_root_capture_index.stderr"
    gate_root_hook_status="$?"
    set -e
    [[ "$gate_root_hook_status" == "0" \
        && ! -s "$test_root/gate-root-$gate_root_capture_index.stdout" \
        && ! -s "$test_root/gate-root-$gate_root_capture_index.stderr" ]] ||
        fail "gate-root production capture hook failed: $gate_root_fixture_id"
    gate_root_hook_call_count=$((gate_root_hook_call_count + 1))
    binding_ordinal="$(relation_authority_jq -r \
        --arg fixture_id "$gate_root_fixture_id" \
        '.pureTestHookContract.exactFixtureBindings[]
            | select(.fixtureRegistry == "gatePrivateRootContract.exactCaptureVectors"
                and .fixtureID == $fixture_id) | .ordinal')"
    builtin printf '%s\t%s\t%s\n' "$binding_ordinal" \
        gatePrivateRootContract.exactCaptureVectors "$gate_root_fixture_id" \
        >> "$relation_hook_witness_registry"
    gate_root_capture_index=$((gate_root_capture_index + 1))
done

relation_invoke_helper_hook() {
    local label="$1"
    shift
    local hook_mode="$1"
    relation_helper_hook_attempt_count=$((relation_helper_hook_attempt_count + 1))
    relation_hook_call_serial=$((relation_hook_call_serial + 1))
    local stdout_path="$test_root/relation-hook-$relation_hook_call_serial.stdout"
    local stderr_path="$test_root/relation-hook-$relation_hook_call_serial.stderr"
    if prime_test_exact_revision_topology_v1 "$@" \
            > "$stdout_path" 2> "$stderr_path"; then
        relation_hook_status=0
    else
        relation_hook_status="$?"
    fi
    [[ "$relation_hook_status" == "0" \
        && ! -s "$stdout_path" && ! -s "$stderr_path" ]] ||
        fail "relation production pure hook failed: $label"
    builtin printf '%s\t%s\t%s\n' "$relation_hook_call_serial" \
        "$label" "$hook_mode" >> "$relation_hook_invocation_registry"
}
relation_hook_call_serial=0

# A marked component child may retain one private frame candidate just through
# the production hook return.  Compare it only with the already-derived raw
# witness and authority child literal, clear it unconditionally, and only then
# inspect files or append the sanitized invocation registry.
relation_invoke_component_frame_hook_and_crossbind() {
    [[ "$#" == "6" ]] || return 2
    local label="$1" frame_mode="$2" outer_status="$3" raw_capture="$4"
    local expected_witness="$5" expected_child_oid="$6"
    local hook_status clear_status candidate_cross_bound=false
    local stdout_path stderr_path
    relation_helper_hook_attempt_count=$((relation_helper_hook_attempt_count + 1))
    relation_hook_call_serial=$((relation_hook_call_serial + 1))
    stdout_path="$test_root/relation-hook-$relation_hook_call_serial.stdout"
    stderr_path="$test_root/relation-hook-$relation_hook_call_serial.stderr"
    if prime_test_exact_revision_topology_v1 relation_frame \
            "$frame_mode" "$outer_status" "$raw_capture" \
            > "$stdout_path" 2> "$stderr_path"; then
        hook_status=0
    else
        hook_status="$?"
    fi
    if [[ "${PRIME_TEST_PRIVATE_CANDIDATE_OID:-}" == "$expected_witness" \
        && ( -z "$expected_witness" \
            || "$expected_witness" == "$expected_child_oid" ) ]]; then
        candidate_cross_bound=true
    fi
    if prime_clear_exact_revision_topology_private_candidate_v1; then
        clear_status=0
    else
        clear_status="$?"
    fi
    [[ "$hook_status" == "0" \
        && "$candidate_cross_bound" == true \
        && "$clear_status" == "0" \
        && -z "${PRIME_TEST_PRIVATE_CANDIDATE_OID:-}" \
        && ! -s "$stdout_path" && ! -s "$stderr_path" ]] ||
        fail "component production frame candidate did not cross-bind and clear: $label"
    builtin printf '%s\t%s\t%s\n' "$relation_hook_call_serial" \
        "$label" relation_frame >> "$relation_hook_invocation_registry"
}

relation_assert_frame_hook_globals() {
    local fixture_json="$1"
    local label="$2"
    local expected_private_candidate="${3:-}"
    local expected_accepted expected_candidate expected_status expected_result
    local expected_guard fixture_id mode git_status mapping capture_byte_count
    fixture_id="$(/usr/bin/jq -r '.fixtureID' <<< "$fixture_json")"
    mode="$(/usr/bin/jq -r '.mode' <<< "$fixture_json")"
    git_status="$(/usr/bin/jq -r '.gitStatus' <<< "$fixture_json")"
    capture_byte_count="$(/usr/bin/jq -r '.captureByteCount' \
        <<< "$fixture_json")"
    expected_accepted="$(/usr/bin/jq -r '.statusPayloadPairAdmitted' \
        <<< "$fixture_json")"
    expected_candidate="$(/usr/bin/jq -r '.bodyConsumedAsChildOID' \
        <<< "$fixture_json")"
    expected_status="$(/usr/bin/jq -r '.classifierStatus' <<< "$fixture_json")"
    if [[ "$capture_byte_count" -gt 63 \
        || "$fixture_id" == "relation_malformed_trailer_magic" \
        || "$fixture_id" \
            == "relation_malformed_trailer_with_valid_witness_not_consumed" ]]; then
        expected_status=""
        expected_result="TOPOLOGY_OBSERVATION_FAILED"
        expected_guard="classifier_relation_witness_frame_is_exact"
    elif [[ "$git_status" != "0" ]]; then
        expected_result="TOPOLOGY_OBSERVATION_FAILED"
        expected_guard="git_cat_file_transport_succeeded"
    elif [[ "$expected_status" == "29" ]]; then
        expected_result="TOPOLOGY_OBSERVATION_FAILED"
        expected_guard="classifier_exit_status_known"
    elif [[ "$expected_accepted" != "true" ]]; then
        expected_result="TOPOLOGY_OBSERVATION_FAILED"
        if [[ "$mode" == "relation" ]]; then
            expected_guard="classifier_relation_witness_frame_is_exact"
        else
            expected_guard="classifier_arguments_match_helper_protocol"
        fi
    elif [[ "$mode" == "relation" && "$expected_status" == "28" ]]; then
        expected_result="TOPOLOGY_OBSERVATION_FAILED"
        expected_guard="classifier_relation_witness_frame_is_exact"
    else
        mapping="$(classifier_result_for_status "$expected_status")"
        expected_result="${mapping%%$'\t'*}"
        expected_guard="${mapping#*$'\t'}"
        [[ "$expected_guard" != "null" ]] || expected_guard=""
    fi
    [[ "${PRIME_TEST_MODE:-}" == "relation_frame" \
        && "${PRIME_TEST_ACCEPTED:-}" == "$expected_accepted" \
        && "${PRIME_TEST_RESULT_CODE:-}" == "$expected_result" \
        && "${PRIME_TEST_GUARD_ID:-}" == "$expected_guard" \
        && "${PRIME_TEST_CLASSIFIER_STATUS:-}" == "$expected_status" \
        && "${PRIME_TEST_CANDIDATE_PRESENT:-}" == "$expected_candidate" \
        && "${PRIME_TEST_PRIVATE_CANDIDATE_OID:-}" \
            == "$expected_private_candidate" ]] ||
        fail "relation frame hook globals changed: $label"
}

relation_call_selector_hook() {
    local label="$1"
    local tuple_array_json="$2"
    local expected_result="$3"
    local expected_guard="$4"
    local expected_phase="$5"
    local expected_object="$6"
    local expected_missing="$7"
    local tuple_count tuple_index tuple row_phase row_object row_result
    local row_guard row_missing expected_candidate_present
    relation_selector_arguments=()
    tuple_count="$(/usr/bin/jq -r 'length' <<< "$tuple_array_json")"
    expected_candidate_present=false
    [[ "$tuple_count" -eq 0 ]] || expected_candidate_present=true
    relation_selector_arguments+=("$tuple_count")
    tuple_index=0
    while [[ "$tuple_index" -lt "$tuple_count" ]]; do
        tuple="$(/usr/bin/jq -r ".[$tuple_index]" <<< "$tuple_array_json")"
        IFS='|' builtin read -r row_phase row_object row_result row_guard row_missing \
            <<< "$tuple"
        relation_selector_arguments+=(
            "$row_phase" "$row_object" "$row_result" "$row_guard" "$row_missing"
        )
        tuple_index=$((tuple_index + 1))
    done
    relation_invoke_helper_hook "$label" selector \
        "${relation_selector_arguments[@]}"
    [[ "${PRIME_TEST_MODE:-}" == "selector" \
        && "${PRIME_TEST_ACCEPTED:-}" == "true" \
        && "${PRIME_TEST_RESULT_CODE:-}" == "$expected_result" \
        && "${PRIME_TEST_GUARD_ID:-}" == "$expected_guard" \
        && "${PRIME_TEST_PHASE_ORDINAL:-}" == "$expected_phase" \
        && "${PRIME_TEST_OBJECT_ORDINAL:-}" == "$expected_object" \
        && "${PRIME_TEST_MISSING_ROLE:-}" == "$expected_missing" \
        && "${PRIME_TEST_CANDIDATE_PRESENT:-}" \
            == "$expected_candidate_present" \
        && -z "${PRIME_TEST_PRIVATE_CANDIDATE_OID:-}" ]] ||
        fail "production selector hook outcome changed: $label"
}

readonly relation_component_witness_registry="$test_root/relation-components"
: > "$relation_component_witness_registry"
prime_test_exact_revision_topology_component_harness_v1() {
    [[ "$#" == "1" ]] || return 2
    local recipe_id="$1"
    local recipe ontology_case case_id repository_recipe_id private_repository
    local step_count step_index step step_kind step_label stdin_path stdout_path
    local stderr_path observed_status expected_status expected_line_path capture_id
    local capture_fixture capture_path outer_status expected_component_capture
    local expected_component_capture_base64 expected_component_capture_sha256
    local component_capture component_body component_witness
    local discovered_child_fixture_id component_expected_child_oid
    local literal_oid comparison_count comparison_index comparison_oid
    local expected_result expected_guard expected_phase expected_object
    local expected_missing recipe_ordinal component_closed_child_entered
    local component_closed_child_entry_count component_raw_pipeline_count
    local component_hook_call_count expected_component_hook_call_count
    recipe="$(relation_authority_jq -c --arg recipe_id "$recipe_id" \
        '.componentHarnessRecipes[] | select(.recipeID == $recipe_id)')"
    [[ -n "$recipe" ]] || return 2
    recipe_ordinal="$(/usr/bin/jq -r '.ordinal' <<< "$recipe")"
    case_id="$(/usr/bin/jq -r '.ontologyCaseID' <<< "$recipe")"
    ontology_case="$(relation_authority_jq -c --arg case_id "$case_id" \
        '.relationOntologyCases[] | select(.caseID == $case_id)')"
    discovered_child_fixture_id="$(/usr/bin/jq -r \
        '.discoveredChildFixtureID // empty' <<< "$ontology_case")"
    component_expected_child_oid=""
    if [[ -n "$discovered_child_fixture_id" ]]; then
        component_expected_child_oid="$(relation_authority_jq -r \
            --arg fixture_id "$discovered_child_fixture_id" \
            '.syntheticGitObjectFixtures[]
                | select(.fixtureID == $fixture_id) | .literalObjectOID')"
        [[ "$component_expected_child_oid" =~ ^[0-9a-f]{40}$ ]] ||
            fail "component discovered-child literal is unavailable: $case_id"
    fi
    repository_recipe_id="$(/usr/bin/jq -r '.privateRepositoryRecipeID' \
        <<< "$recipe")"
    private_repository="$test_root/component-$case_id"
    relation_prepare_private_repository "$repository_recipe_id" \
        "$private_repository"

    component_cross_bound_oid=""
    component_selector_call_count=0
    component_closed_child_entered=false
    component_closed_child_entry_count=0
    component_raw_pipeline_count=0
    component_hook_call_count=0
    relation_hook_call_serial=$((1000 + recipe_ordinal * 100))
    step_count="$(/usr/bin/jq -r '.exactOrderedSteps | length' <<< "$recipe")"
    step_index=0
    while [[ "$step_index" -lt "$step_count" ]]; do
        step="$(/usr/bin/jq -c ".exactOrderedSteps[$step_index]" <<< "$recipe")"
        step_kind="$(/usr/bin/jq -r '.stepKind' <<< "$step")"
        step_label="$case_id/$step_kind/$step_index"
        case "$step_kind" in
            merge_preprobe|child_preprobe)
                relation_load_rendered_arguments \
                    "$(/usr/bin/jq -c '.exactGitArgumentVector' <<< "$step")" \
                    "$private_repository"
                component_git_arguments=("${relation_arguments[@]}")
                stdin_path="$test_root/$case_id.step-$step_index.stdin"
                expected_line_path="$test_root/$case_id.step-$step_index.expected"
                stdout_path="$test_root/$case_id.step-$step_index.stdout"
                stderr_path="$test_root/$case_id.step-$step_index.stderr"
                /usr/bin/jq -j '.exactPreprobeStdin' <<< "$step" \
                    > "$stdin_path"
                /usr/bin/jq -j '.exactPreprobeLine' <<< "$step" \
                    > "$expected_line_path"
                if "${component_git_arguments[@]}" < "$stdin_path" \
                        > "$stdout_path" 2> "$stderr_path"; then
                    observed_status=0
                else
                    observed_status="$?"
                fi
                expected_status="$(/usr/bin/jq -r '.producerStatus' <<< "$step")"
                [[ "$observed_status" == "$expected_status" \
                    && ! -s "$stderr_path" \
                    && "$(/usr/bin/wc -c < "$stdin_path" | /usr/bin/awk '{print $1}')" \
                        == "41" ]] \
                    && /usr/bin/cmp -s "$expected_line_path" "$stdout_path" ||
                    fail "component live preprobe changed: $step_label"
                if [[ "$step_kind" == "child_preprobe" ]]; then
                    literal_oid="$(/usr/bin/jq -r '.literalObjectOID' <<< "$step")"
                    if [[ -n "$component_cross_bound_oid" \
                        && "$component_cross_bound_oid" != "$literal_oid" ]]; then
                        fail "component parent2/child preprobe OIDs differ: $case_id"
                    fi
                fi
                ;;
            merge_relation_raw|child_ordinary_raw)
                relation_load_rendered_arguments \
                    "$(/usr/bin/jq -c '.exactGitArgumentVector' <<< "$step")" \
                    "$private_repository"
                component_git_arguments=("${relation_arguments[@]}")
                relation_load_rendered_arguments \
                    "$(/usr/bin/jq -c '.exactClassifierArgumentVector' \
                        <<< "$step")" "$private_repository"
                component_classifier_arguments=("${relation_arguments[@]}")
                stdout_path="$test_root/$case_id.step-$step_index.git.stderr"
                stderr_path="$test_root/$case_id.step-$step_index.classifier.stderr"
                if [[ "$component_closed_child_entered" == false ]]; then
                    prime_enter_exact_revision_topology_closed_child_v1 ||
                        fail "component raw child trace admission failed: $step_label"
                    component_closed_child_entered=true
                    component_closed_child_entry_count=1
                fi
                [[ "${prime_topology_closed_child_v1:-}" \
                        == prime_exact_revision_topology_closed_child_v1 \
                    && "${prime_topology_closed_child_depth_v1:-}" \
                        == "$BASH_SUBSHELL" \
                    && "$BASH_SUBSHELL" \
                        -gt "$prime_topology_source_bash_subshell_depth_v1" \
                    && "$-" != *x* && "$-" != *v* \
                    && ! -o errtrace && ! -o functrace \
                    && -z "${BASH_XTRACEFD+x}" \
                    && "${PS4-}" == "" \
                    && -z "${prime_topology_after_source_trap_presence_v1+x}" ]] ||
                    fail "component raw pipeline child is not closed: $step_label"
                component_raw_pipeline_count=$((component_raw_pipeline_count + 1))
                if component_capture="$(
                    "${component_git_arguments[@]}" 2> "$stdout_path" |
                        "${component_classifier_arguments[@]}" 2> "$stderr_path"
                    component_pipeline_statuses=("${PIPESTATUS[@]}")
                    [[ "${#component_pipeline_statuses[@]}" == "2" ]] || exit 99
                    builtin printf '\036prime_status:%03d:%03d\037' \
                        "${component_pipeline_statuses[0]}" \
                        "${component_pipeline_statuses[1]}"
                )"; then
                    outer_status=0
                else
                    outer_status="$?"
                fi
                [[ "$outer_status" == "0" \
                    && "${#component_capture}" -le 63 \
                    && ! -s "$stdout_path" && ! -s "$stderr_path" ]] ||
                    fail "component raw pipeline transport changed: $step_label"
                capture_id="$(/usr/bin/jq -r '.captureFixtureID' <<< "$step")"
                capture_fixture="$(relation_authority_jq -c \
                    --arg fixture_id "$capture_id" \
                    '.captureFixtures[] | select(.fixtureID == $fixture_id)')"
                expected_component_capture_base64="$(/usr/bin/jq -r \
                    '.captureBase64' <<< "$capture_fixture")"
                expected_component_capture="$(
                    builtin printf '%s' "$expected_component_capture_base64" |
                        /usr/bin/base64 -D
                )" || fail "could not decode in-memory component capture: $step_label"
                expected_component_capture_sha256="$(
                    builtin printf '%s' "$expected_component_capture" |
                        /usr/bin/shasum -a 256 | /usr/bin/awk '{print $1}'
                )"
                [[ "${#expected_component_capture}" \
                        == "$(/usr/bin/jq -r '.captureByteCount' \
                            <<< "$capture_fixture")" \
                    && "$expected_component_capture_sha256" \
                        == "$(/usr/bin/jq -r '.captureSHA256' \
                            <<< "$capture_fixture")" \
                    && "$(builtin printf '%s' "$expected_component_capture" |
                        /usr/bin/base64 | /usr/bin/tr -d '\n')" \
                        == "$expected_component_capture_base64" \
                    && "$component_capture" == "$expected_component_capture" ]] ||
                    fail "component raw capture differs from exact fixture: $step_label"
                [[ ! -e "$test_root/$case_id.step-$step_index.capture" \
                    && ! -L "$test_root/$case_id.step-$step_index.capture" ]] ||
                    fail "component live raw capture was persisted: $step_label"
                expected_component_capture=""
                expected_component_capture_base64=""
                expected_component_capture_sha256=""
                component_body="${component_capture:0:${#component_capture}-22}"
                component_witness=""
                if [[ "$component_body" =~ ^([0-9a-f]{40})$'\n'$ ]]; then
                    component_witness="${BASH_REMATCH[1]}"
                fi
                relation_invoke_component_frame_hook_and_crossbind \
                    "$step_label" \
                    "$(/usr/bin/jq -r '.classifierMode' <<< "$step")" \
                    "$outer_status" "$component_capture" \
                    "$component_witness" "$component_expected_child_oid"
                component_hook_call_count=$((component_hook_call_count + 1))
                relation_assert_frame_hook_globals "$capture_fixture" "$step_label"
                if [[ -n "$component_witness" ]]; then
                    if [[ -n "$component_cross_bound_oid" \
                        && "$component_cross_bound_oid" != "$component_witness" ]]; then
                        fail "component relation witness cross-binding changed: $case_id"
                    fi
                    component_cross_bound_oid="$component_witness"
                fi
                if [[ "$step_kind" == "child_ordinary_raw" ]]; then
                    literal_oid="$(/usr/bin/jq -r '.literalObjectOID' <<< "$step")"
                    [[ -z "$component_cross_bound_oid" \
                        || "$component_cross_bound_oid" == "$literal_oid" ]] ||
                        fail "component child raw literal differs from parent2: $case_id"
                fi
                ;;
            explicit_ordinary_transport_frame_injection)
                capture_id="$(/usr/bin/jq -r '.captureFixtureID' <<< "$step")"
                capture_fixture="$(relation_authority_jq -c \
                    --arg fixture_id "$capture_id" \
                    '.captureFixtures[] | select(.fixtureID == $fixture_id)')"
                capture_path="$test_root/$case_id.step-$step_index.capture"
                relation_decode_exact_field "$capture_fixture" captureBase64 \
                    captureByteCount captureSHA256 "$capture_path"
                relation_capture_as_argument "$capture_path"
                relation_invoke_helper_hook "$step_label" relation_frame ordinary 0 \
                    "$relation_raw_capture"
                component_hook_call_count=$((component_hook_call_count + 1))
                relation_assert_frame_hook_globals "$capture_fixture" "$step_label"
                ;;
            child_distinctness_guard)
                literal_oid="$(/usr/bin/jq -r '.literalObjectOID' <<< "$step")"
                [[ -n "$component_cross_bound_oid" \
                    && "$component_cross_bound_oid" == "$literal_oid" ]] ||
                    fail "component distinctness child is not the captured parent2: $case_id"
                comparison_count="$(/usr/bin/jq -r \
                    '.exactDistinctnessComparisonOIDs | length' <<< "$step")"
                [[ "$comparison_count" -gt 0 ]] ||
                    fail "component distinctness comparison set is empty: $case_id"
                comparison_index=0
                while [[ "$comparison_index" -lt "$comparison_count" ]]; do
                    comparison_oid="$(/usr/bin/jq -r \
                        ".exactDistinctnessComparisonOIDs[$comparison_index]" \
                        <<< "$step")"
                    [[ "$literal_oid" != "$comparison_oid" ]] ||
                        fail "component child distinctness failed: $case_id"
                    comparison_index=$((comparison_index + 1))
                done
                ;;
            selector_hook)
                expected_result="$(/usr/bin/jq -r '.expectedResultCode' \
                    <<< "$recipe")"
                expected_guard="$(/usr/bin/jq -r \
                    '.expectedFirstFailedGuardID // ""' <<< "$recipe")"
                expected_phase="$(/usr/bin/jq -r \
                    '.expectedFirstFailedPhaseOrdinal
                        | if . == null then "" else tostring end' <<< "$recipe")"
                expected_object="$(/usr/bin/jq -r \
                    '.expectedFirstFailureObjectOrdinal
                        | if . == null then "" else tostring end' <<< "$recipe")"
                expected_missing="$(/usr/bin/jq -r \
                    '.expectedMissingObjectRole // ""' <<< "$recipe")"
                relation_call_selector_hook "$step_label" \
                    "$(/usr/bin/jq -c '.exactSelectorCandidateTuples' \
                        <<< "$recipe")" \
                    "$expected_result" "$expected_guard" "$expected_phase" \
                    "$expected_object" "$expected_missing"
                component_selector_call_count=$((component_selector_call_count + 1))
                component_hook_call_count=$((component_hook_call_count + 1))
                ;;
            *) fail "unknown typed component step: $step_label" ;;
        esac
        step_index=$((step_index + 1))
    done
    [[ "$component_selector_call_count" \
            == "$(/usr/bin/jq -r '.selectorHookInvocationCount' <<< "$recipe")" ]] ||
        fail "component selector invocation count changed: $case_id"
    expected_component_hook_call_count="$(/usr/bin/jq -r '
        [.exactOrderedSteps[]
            | select(.stepKind == "merge_relation_raw"
                or .stepKind == "child_ordinary_raw"
                or .stepKind == "explicit_ordinary_transport_frame_injection"
                or .stepKind == "selector_hook")]
        | length' <<< "$recipe")"
    [[ "$component_hook_call_count" == "$expected_component_hook_call_count" ]] ||
        fail "component production-hook call count changed: $case_id"
    if [[ "$component_raw_pipeline_count" -eq 0 ]]; then
        [[ "$component_closed_child_entry_count" == "0" ]] ||
            fail "raw-free component unexpectedly entered a closed child: $case_id"
    else
        [[ "$component_closed_child_entry_count" == "1" \
            && "$component_closed_child_entered" == true \
            && "${prime_topology_closed_child_v1:-}" \
                == prime_exact_revision_topology_closed_child_v1 ]] ||
            fail "raw-owning component did not remain in one closed child: $case_id"
    fi
    # No parent2-bearing value is written to the sanitized component verdict.
    component_capture=""
    component_body=""
    component_witness=""
    component_cross_bound_oid=""
    builtin printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$recipe_id" "$case_id" "$component_raw_pipeline_count" \
        "$component_closed_child_entry_count" "$component_hook_call_count" \
        "$component_selector_call_count" \
        >> "$relation_component_witness_registry"
}

readonly prime_component_harness_matrix_exact_call_count_6_cases_8_11_22_27_37_40="6"
# Each complete component recipe owns a distinct child. Bash resets inherited
# EXIT/HUP/INT/TERM traps on entry to the subshell; the helper's trusted DEBUG
# watcher remains armed until the first raw step enters its one-way closed
# boundary. Any parent2, raw frame, or private hook state therefore dies with
# this child. Only the bounded six-field verdict appended by the recipe is
# retained, and the parent watcher is never disarmed.
relation_run_component_recipe_child_v1() {
    [[ "$#" == "2" ]] || return 2
    local recipe_id="$1"
    local child_ordinal="$2"
    local child_stdout="$test_root/component-child-$child_ordinal.stdout"
    local child_stderr="$test_root/component-child-$child_ordinal.stderr"
    local child_status
    if (
        [[ -z "$(builtin trap -p EXIT HUP INT TERM)" \
            && "$-" != *x* && "$-" != *v* \
            && ! -o errtrace && -o functrace \
            && -z "${BASH_XTRACEFD+x}" \
            && "${PS4-+ }" == "+ " \
            && -z "${prime_topology_closed_child_v1+x}" \
            && -z "${prime_topology_closed_child_depth_v1+x}" ]] || exit 98
        prime_test_exact_revision_topology_component_harness_v1 "$recipe_id"
    ) > "$child_stdout" 2> "$child_stderr"; then
        child_status=0
    else
        child_status="$?"
    fi
    [[ "$child_status" == "0" \
        && ! -s "$child_stdout" && ! -s "$child_stderr" \
        && -o functrace \
        && -z "${prime_topology_closed_child_v1+x}" \
        && -z "${prime_topology_closed_child_depth_v1+x}" \
        && -z "${prime_topology_after_source_trap_presence_v1+x}" ]] ||
        fail "isolated component recipe child failed: $recipe_id"
}
relation_run_component_recipe_child_v1 \
    "component_harness_wave1_missing_merge_stops_all_raw" 1
relation_run_component_recipe_child_v1 \
    "component_harness_merge_wrong_tree_isolated" 2
relation_run_component_recipe_child_v1 \
    "component_harness_wave2_phase15_outweighs_earlier_explicit_raw_failure" 3
relation_run_component_recipe_child_v1 \
    "component_harness_wrong_tree_one_parent_selects_tree_without_witness" 4
relation_run_component_recipe_child_v1 \
    "component_harness_child_phase15_beats_merge_phase37" 5
relation_run_component_recipe_child_v1 \
    "component_harness_alternate_valid_merge_role_missing_is_selected" 6
[[ "$(/usr/bin/wc -l < "$relation_component_witness_registry" | \
        /usr/bin/awk '{print $1}')" \
        == "$prime_component_harness_matrix_exact_call_count_6_cases_8_11_22_27_37_40" ]] ||
    fail "typed component harness call count changed"
readonly relation_expected_component_raw_pipeline_count="$(relation_authority_jq -r '
    [.componentHarnessRecipes[].exactOrderedSteps[]
        | select(.stepKind == "merge_relation_raw"
            or .stepKind == "child_ordinary_raw")]
    | length')"
readonly relation_observed_component_raw_pipeline_count="$(
    /usr/bin/awk -F '\t' '{ count += $3 } END { print count + 0 }' \
        "$relation_component_witness_registry"
)"
readonly relation_observed_component_closed_child_entry_count="$(
    /usr/bin/awk -F '\t' '{ count += $4 } END { print count + 0 }' \
        "$relation_component_witness_registry"
)"
readonly relation_observed_component_hook_call_count="$(
    /usr/bin/awk -F '\t' '{ count += $5 } END { print count + 0 }' \
        "$relation_component_witness_registry"
)"
readonly relation_observed_component_selector_call_count="$(
    /usr/bin/awk -F '\t' '{ count += $6 } END { print count + 0 }' \
        "$relation_component_witness_registry"
)"
[[ "$relation_expected_component_raw_pipeline_count" == "5" \
    && "$relation_observed_component_raw_pipeline_count" == "5" \
    && "$relation_observed_component_closed_child_entry_count" == "4" \
    && "$relation_observed_component_hook_call_count" == "12" \
    && "$relation_observed_component_selector_call_count" == "6" ]] ||
    fail "component child/raw/hook runtime accounting changed"
relation_component_publication_paths=("$relation_component_witness_registry")
relation_component_child_index=1
while [[ "$relation_component_child_index" -le 6 ]]; do
    relation_component_publication_paths+=(
        "$test_root/component-child-$relation_component_child_index.stdout"
        "$test_root/component-child-$relation_component_child_index.stderr"
    )
    relation_component_child_index=$((relation_component_child_index + 1))
done
for relation_private_fixture_id in valid_child withheld_child; do
    relation_component_private_oid="$(relation_authority_jq -r \
        --arg fixture_id "$relation_private_fixture_id" \
        '.syntheticGitObjectFixtures[]
            | select(.fixtureID == $fixture_id) | .literalObjectOID')"
    if /usr/bin/grep -Fq -- "$relation_component_private_oid" \
            "${relation_component_publication_paths[@]}"; then
        fail "component child published a private parent2: $relation_private_fixture_id"
    fi
done

# Hostile state must be rejected by the one-way entry itself. These two
# children deliberately hold an exact private-OID canary before the isolated
# mutation; neither executes a raw stream. The RETURN handler would publish
# that canary on function return if entry did not neutralize it, while xtrace
# would expose any later expansion. Both complete only after observing status1,
# and the parent retains solely two fixed labels.
readonly relation_closed_child_hostile_registry="$test_root/relation-closed-child-hostile"
: > "$relation_closed_child_hostile_registry"
readonly relation_closed_child_private_canary="$(relation_authority_jq -r '
    .syntheticGitObjectFixtures[]
        | select(.fixtureID == "valid_child") | .literalObjectOID')"
relation_closed_child_return_stdout="$test_root/closed-child-return.stdout"
relation_closed_child_return_stderr="$test_root/closed-child-return.stderr"
if (
    [[ -z "$(builtin trap -p EXIT HUP INT TERM)" \
        && "$-" != *x* && "$-" != *v* \
        && ! -o errtrace && -o functrace \
        && -z "${prime_topology_after_source_trap_presence_v1+x}" ]] || exit 98
    component_capture="$relation_closed_child_private_canary"
    builtin trap 'builtin printf '\''%s\n'\'' "$component_capture"' RETURN
    [[ "${prime_topology_after_source_trap_presence_v1:-}" == true ]] || exit 97
    if prime_enter_exact_revision_topology_closed_child_v1; then
        hostile_entry_status=0
    else
        hostile_entry_status="$?"
    fi
    [[ "$hostile_entry_status" == "1" \
        && -z "$(builtin trap -p DEBUG RETURN ERR)" \
        && ! -o functrace \
        && -z "${prime_topology_closed_child_v1+x}" ]] || exit 96
    component_capture=""
) > "$relation_closed_child_return_stdout" \
    2> "$relation_closed_child_return_stderr"; then
    relation_closed_child_return_outer=0
else
    relation_closed_child_return_outer="$?"
fi
[[ "$relation_closed_child_return_outer" == "0" \
    && ! -s "$relation_closed_child_return_stdout" \
    && ! -s "$relation_closed_child_return_stderr" ]] ||
    fail "RETURN-hostile closed-child entry did not reject without publication"
builtin printf '%s\n' return_trap_rejected_before_closed_child \
    >> "$relation_closed_child_hostile_registry"

relation_closed_child_xtrace_stdout="$test_root/closed-child-xtrace.stdout"
relation_closed_child_xtrace_stderr="$test_root/closed-child-xtrace.stderr"
if (
    [[ -z "$(builtin trap -p EXIT HUP INT TERM)" \
        && "$-" != *x* && "$-" != *v* \
        && ! -o errtrace && -o functrace \
        && -z "${prime_topology_after_source_trap_presence_v1+x}" ]] || exit 98
    component_capture="$relation_closed_child_private_canary"
    set -x
    if prime_enter_exact_revision_topology_closed_child_v1; then
        hostile_entry_status=0
    else
        hostile_entry_status="$?"
    fi
    set +x
    [[ "$hostile_entry_status" == "1" \
        && ! -o functrace \
        && -z "${prime_topology_closed_child_v1+x}" ]] || exit 96
    component_capture=""
) > "$relation_closed_child_xtrace_stdout" \
    2> "$relation_closed_child_xtrace_stderr"; then
    relation_closed_child_xtrace_outer=0
else
    relation_closed_child_xtrace_outer="$?"
fi
[[ "$relation_closed_child_xtrace_outer" == "0" \
    && ! -s "$relation_closed_child_xtrace_stdout" \
    && -s "$relation_closed_child_xtrace_stderr" ]] ||
    fail "xtrace-hostile closed-child entry did not reject privately"
builtin printf '%s\n' xtrace_rejected_before_closed_child \
    >> "$relation_closed_child_hostile_registry"
[[ "$(/usr/bin/wc -l < "$relation_closed_child_hostile_registry" | \
        /usr/bin/awk '{print $1}')" == "2" ]] ||
    fail "closed-child hostile-entry regression count changed"
if /usr/bin/grep -Fq -- "$relation_closed_child_private_canary" \
        "$relation_closed_child_return_stdout" \
        "$relation_closed_child_return_stderr" \
        "$relation_closed_child_xtrace_stdout" \
        "$relation_closed_child_xtrace_stderr" \
        "$relation_closed_child_hostile_registry"; then
    fail "hostile closed-child entry exposed the private-OID canary"
fi

# Bind all 47 parser vectors to the production invocation parser. Expected
# mode/result data is read only after the exact argv tokens are supplied; the
# matrix never chooses a parse branch from expectedMode.
readonly relation_parser_vector_count="$(relation_authority_jq -r \
    '.invocationParserVectors | length')"
[[ "$relation_parser_vector_count" == "47" ]] ||
    fail "relation invocation parser vector count changed"
/bin/mkdir -m 700 "$test_root/relation-pure-repository"
relation_parser_index=0
while [[ "$relation_parser_index" -lt "$relation_parser_vector_count" ]]; do
    relation_parser_vector="$(relation_authority_jq -c \
        ".invocationParserVectors[$relation_parser_index]")"
    relation_parser_fixture_id="$(/usr/bin/jq -r '.fixtureID' \
        <<< "$relation_parser_vector")"
    relation_load_rendered_arguments \
        "$(/usr/bin/jq -c '.exactArgumentTokens' <<< "$relation_parser_vector")"
    relation_parser_arguments=("${relation_arguments[@]}")
    relation_invoke_helper_hook \
        "binding:invocationParserVectors:$relation_parser_fixture_id" invocation \
        "${#relation_parser_arguments[@]}" "${relation_parser_arguments[@]}"
    relation_parser_expected_accepted="$(/usr/bin/jq -r '.expectedAccepted' \
        <<< "$relation_parser_vector")"
    relation_parser_expected_guard="$(/usr/bin/jq -r \
        '.expectedFirstFailedGuardID // ""' <<< "$relation_parser_vector")"
    relation_parser_expected_phase="$(/usr/bin/jq -r \
        '.expectedFirstFailedPhaseOrdinal
            | if . == null then "" else tostring end' <<< "$relation_parser_vector")"
    relation_parser_expected_object="$(/usr/bin/jq -r \
        '.expectedFirstFailureObjectOrdinal
            | if . == null then "" else tostring end' \
        <<< "$relation_parser_vector")"
    [[ "${PRIME_TEST_MODE:-}" \
            == "$(/usr/bin/jq -r '.expectedMode' <<< "$relation_parser_vector")" \
        && "${PRIME_TEST_ACCEPTED:-}" == "$relation_parser_expected_accepted" \
        && "${PRIME_TEST_RESULT_CODE:-}" \
            == "$(/usr/bin/jq -r '.expectedResultCode' \
                <<< "$relation_parser_vector")" \
        && "${PRIME_TEST_GUARD_ID:-}" == "$relation_parser_expected_guard" \
        && "${PRIME_TEST_PHASE_ORDINAL:-}" == "$relation_parser_expected_phase" \
        && "${PRIME_TEST_OBJECT_ORDINAL:-}" == "$relation_parser_expected_object" \
        && -z "${PRIME_TEST_CLASSIFIER_STATUS:-}" \
        && "${PRIME_TEST_CANDIDATE_PRESENT:-}" == "false" \
        && -z "${PRIME_TEST_MISSING_ROLE:-}" \
        && -z "${PRIME_TEST_PRIVATE_CANDIDATE_OID:-}" ]] ||
        fail "production invocation parser outcome changed: $relation_parser_fixture_id"
    binding_ordinal="$(relation_authority_jq -r \
        --arg fixture_id "$relation_parser_fixture_id" \
        '.pureTestHookContract.exactFixtureBindings[]
            | select(.fixtureRegistry == "invocationParserVectors"
                and .fixtureID == $fixture_id) | .ordinal')"
    builtin printf '%s\t%s\t%s\n' "$binding_ordinal" invocationParserVectors \
        "$relation_parser_fixture_id" >> "$relation_hook_witness_registry"
    relation_parser_index=$((relation_parser_index + 1))
done

# Bind every framed HEAD/status/write-tree observation to the shared production
# bounded-status parser, including producer, consumer, trailer, cap, and outer-
# substitution failures.
readonly relation_probe_vector_count="$(relation_authority_jq -r \
    '.indexObservationContract.exactProbeCaptureVectors | length')"
[[ "$relation_probe_vector_count" == "11" ]] ||
    fail "relation probe capture vector count changed"
relation_probe_index=0
while [[ "$relation_probe_index" -lt "$relation_probe_vector_count" ]]; do
    relation_probe_vector="$(relation_authority_jq -c \
        ".indexObservationContract.exactProbeCaptureVectors[$relation_probe_index]")"
    relation_probe_fixture_id="$(/usr/bin/jq -r '.fixtureID' \
        <<< "$relation_probe_vector")"
    relation_probe_capture_path="$test_root/relation-probe-$relation_probe_index.capture"
    relation_decode_exact_field "$relation_probe_vector" captureBase64 \
        captureByteCount captureSHA256 "$relation_probe_capture_path"
    relation_capture_as_argument "$relation_probe_capture_path"
    relation_invoke_helper_hook \
        "binding:indexObservationContract.exactProbeCaptureVectors:$relation_probe_fixture_id" \
        probe \
        "$(/usr/bin/jq -r '.probeKind' <<< "$relation_probe_vector")" \
        "$(/usr/bin/jq -r '.outerSubstitutionStatus' \
            <<< "$relation_probe_vector")" "$relation_raw_capture"
    [[ "${PRIME_TEST_MODE:-}" == "probe" \
        && "${PRIME_TEST_ACCEPTED:-}" \
            == "$(/usr/bin/jq -r '.accepted' <<< "$relation_probe_vector")" \
        && -z "${PRIME_TEST_RESULT_CODE:-}" \
        && -z "${PRIME_TEST_GUARD_ID:-}" \
        && -z "${PRIME_TEST_PHASE_ORDINAL:-}" \
        && -z "${PRIME_TEST_OBJECT_ORDINAL:-}" \
        && -z "${PRIME_TEST_CLASSIFIER_STATUS:-}" \
        && "${PRIME_TEST_CANDIDATE_PRESENT:-}" == "false" \
        && -z "${PRIME_TEST_MISSING_ROLE:-}" \
        && -z "${PRIME_TEST_PRIVATE_CANDIDATE_OID:-}" ]] ||
        fail "production index probe parser outcome changed: $relation_probe_fixture_id"
    binding_ordinal="$(relation_authority_jq -r \
        --arg fixture_id "$relation_probe_fixture_id" \
        '.pureTestHookContract.exactFixtureBindings[]
            | select(.fixtureRegistry == "indexObservationContract.exactProbeCaptureVectors"
                and .fixtureID == $fixture_id) | .ordinal')"
    builtin printf '%s\t%s\t%s\n' "$binding_ordinal" \
        indexObservationContract.exactProbeCaptureVectors \
        "$relation_probe_fixture_id" >> "$relation_hook_witness_registry"
    relation_probe_index=$((relation_probe_index + 1))
done

# Decode and cross-bind all relation/ordinary status-payload captures, then run
# each exact raw frame once through the same production parser used by live raw
# pipelines. Exit-28 prefixes remain admitted pairs but never child candidates.
readonly relation_frame_fixture_count="$(relation_authority_jq -r \
    '.captureFixtures | length')"
[[ "$relation_frame_fixture_count" == "30" ]] ||
    fail "relation frame fixture count changed"
relation_frame_index=0
while [[ "$relation_frame_index" -lt "$relation_frame_fixture_count" ]]; do
    relation_frame_fixture="$(relation_authority_jq -c \
        ".captureFixtures[$relation_frame_index]")"
    relation_frame_fixture_id="$(/usr/bin/jq -r '.fixtureID' \
        <<< "$relation_frame_fixture")"
    relation_frame_body_path="$test_root/relation-frame-$relation_frame_index.body"
    relation_frame_trailer_path="$test_root/relation-frame-$relation_frame_index.trailer"
    relation_frame_capture_path="$test_root/relation-frame-$relation_frame_index.capture"
    relation_decode_exact_field "$relation_frame_fixture" bodyBase64 \
        bodyByteCount bodySHA256 "$relation_frame_body_path"
    relation_decode_exact_field "$relation_frame_fixture" trailerBase64 \
        trailerByteCount trailerSHA256 "$relation_frame_trailer_path"
    relation_decode_exact_field "$relation_frame_fixture" captureBase64 \
        captureByteCount captureSHA256 "$relation_frame_capture_path"
    relation_capture_as_argument "$relation_frame_body_path"
    relation_frame_body="$relation_raw_capture"
    relation_capture_as_argument "$relation_frame_trailer_path"
    relation_frame_trailer="$relation_raw_capture"
    relation_capture_as_argument "$relation_frame_capture_path"
    [[ "$relation_raw_capture" == "$relation_frame_body$relation_frame_trailer" ]] ||
        fail "relation body plus trailer does not equal capture: $relation_frame_fixture_id"
    relation_invoke_helper_hook \
        "binding:captureFixtures:$relation_frame_fixture_id" relation_frame \
        "$(/usr/bin/jq -r '.mode' <<< "$relation_frame_fixture")" 0 \
        "$relation_raw_capture"
    relation_assert_frame_hook_globals "$relation_frame_fixture" \
        "$relation_frame_fixture_id"
    binding_ordinal="$(relation_authority_jq -r \
        --arg fixture_id "$relation_frame_fixture_id" \
        '.pureTestHookContract.exactFixtureBindings[]
            | select(.fixtureRegistry == "captureFixtures"
                and .fixtureID == $fixture_id) | .ordinal')"
    builtin printf '%s\t%s\t%s\n' "$binding_ordinal" captureFixtures \
        "$relation_frame_fixture_id" >> "$relation_hook_witness_registry"
    relation_frame_index=$((relation_frame_index + 1))
done

# A caller ERR trap installed after sourcing must stop the pure frame hook at
# its same closed trace admission, before the exact 41-byte parent2 can enter
# hook state. Keep this attempt outside the frozen 135 fixture bindings. The
# clean replay in the parent shell proves every preceding frame call rearmed
# the watcher and the isolated hostile process did not disable later hooks.
readonly relation_hostile_frame_fixture_id="relation_success_exact_witness"
relation_hostile_frame_fixture="$(relation_authority_jq -c \
    --arg fixture_id "$relation_hostile_frame_fixture_id" \
    '.captureFixtures[] | select(.fixtureID == $fixture_id)')"
relation_hostile_frame_capture_path="$test_root/relation-hostile-frame.capture"
relation_decode_exact_field "$relation_hostile_frame_fixture" captureBase64 \
    captureByteCount captureSHA256 "$relation_hostile_frame_capture_path"
relation_capture_as_argument "$relation_hostile_frame_capture_path"
relation_hostile_frame_capture="$relation_raw_capture"
relation_hostile_frame_private_oid="$(relation_authority_jq -r \
    '.syntheticGitObjectFixtures[]
        | select(.fixtureID == "valid_child") | .literalObjectOID')"
relation_hostile_frame_stdout="$test_root/relation-hostile-frame.stdout"
relation_hostile_frame_stderr="$test_root/relation-hostile-frame.stderr"
relation_hostile_frame_status_path="$test_root/relation-hostile-frame.status"
relation_helper_hook_attempt_count=$((relation_helper_hook_attempt_count + 1))
(
    set +e
    [[ "$-" != *x* && "$-" != *v* \
        && ! -o errtrace && -o functrace \
        && -z "${prime_topology_after_source_trap_presence_v1+x}" ]] || exit 98
    builtin trap ':' ERR
    [[ "${prime_topology_after_source_trap_presence_v1:-}" == true ]] || exit 97
    prime_test_exact_revision_topology_v1 relation_frame relation 0 \
        "$relation_hostile_frame_capture" \
        > "$relation_hostile_frame_stdout" \
        2> "$relation_hostile_frame_stderr"
    relation_hostile_frame_status="$?"
    [[ "$relation_hostile_frame_status" == "2" \
        && -z "${PRIME_TEST_MODE:-}" \
        && "${PRIME_TEST_ACCEPTED:-}" == "false" \
        && -z "${PRIME_TEST_RESULT_CODE:-}" \
        && -z "${PRIME_TEST_GUARD_ID:-}" \
        && -z "${PRIME_TEST_PHASE_ORDINAL:-}" \
        && -z "${PRIME_TEST_OBJECT_ORDINAL:-}" \
        && -z "${PRIME_TEST_CLASSIFIER_STATUS:-}" \
        && "${PRIME_TEST_CANDIDATE_PRESENT:-}" == "false" \
        && -z "${PRIME_TEST_MISSING_ROLE:-}" \
        && -z "${PRIME_TEST_PRIVATE_CANDIDATE_OID:-}" ]] || exit 99
    builtin printf '%s\n' "$relation_hostile_frame_status" \
        > "$relation_hostile_frame_status_path"
)
[[ "$(< "$relation_hostile_frame_status_path")" == "2" \
    && ! -s "$relation_hostile_frame_stdout" \
    && ! -s "$relation_hostile_frame_stderr" ]] ||
    fail "hostile relation-frame hook was not rejected before candidate state"
if /usr/bin/grep -Fq -- "$relation_hostile_frame_private_oid" \
        "$relation_hostile_frame_stdout" \
    || /usr/bin/grep -Fq -- "$relation_hostile_frame_private_oid" \
        "$relation_hostile_frame_stderr"; then
    fail "hostile relation-frame hook published the private child witness"
fi
builtin printf '%s\t%s\t%s\n' hostile \
    trace:relation_frame_ERR_after_source_rejected relation_frame \
    >> "$relation_hook_invocation_registry"
relation_invoke_helper_hook trace:relation_frame_clean_replay_after_hostile \
    relation_frame relation 0 "$relation_hostile_frame_capture"
relation_assert_frame_hook_globals "$relation_hostile_frame_fixture" \
    relation_frame_clean_replay_after_hostile

# Every ontology row independently reaches the production selector. Verified
# rows supply no failure candidates; every negative supplies exactly its frozen
# phase/object/result/guard/missing-role candidate and must round-trip through
# production selection, including caller-supplied alternate roles.
readonly relation_ontology_case_count="$(relation_authority_jq -r \
    '.relationOntologyCases | length')"
[[ "$relation_ontology_case_count" == "41" ]] ||
    fail "relation ontology case count changed"
relation_ontology_index=0
while [[ "$relation_ontology_index" -lt "$relation_ontology_case_count" ]]; do
    relation_ontology_case="$(relation_authority_jq -c \
        ".relationOntologyCases[$relation_ontology_index]")"
    relation_ontology_case_id="$(/usr/bin/jq -r '.caseID' \
        <<< "$relation_ontology_case")"
    relation_ontology_expected_result="$(/usr/bin/jq -r '.expectedResultCode' \
        <<< "$relation_ontology_case")"
    relation_ontology_expected_guard="$(/usr/bin/jq -r \
        '.expectedFirstFailedGuardID // ""' <<< "$relation_ontology_case")"
    relation_ontology_expected_phase="$(/usr/bin/jq -r \
        '.expectedFirstFailedPhaseOrdinal
            | if . == null then "" else tostring end' <<< "$relation_ontology_case")"
    relation_ontology_expected_object="$(/usr/bin/jq -r \
        '.expectedFirstFailureObjectOrdinal
            | if . == null then "" else tostring end' <<< "$relation_ontology_case")"
    relation_ontology_expected_missing="$(/usr/bin/jq -r \
        '.expectedMissingObjectRole // ""' <<< "$relation_ontology_case")"
    relation_ontology_hook_result="$relation_ontology_expected_result"
    relation_ontology_hook_guard="$relation_ontology_expected_guard"
    relation_ontology_hook_phase="$relation_ontology_expected_phase"
    relation_ontology_hook_object="$relation_ontology_expected_object"
    relation_ontology_hook_missing="$relation_ontology_expected_missing"
    if [[ "$relation_ontology_expected_result" == "TOPOLOGY_VERIFIED" ]]; then
        relation_ontology_tuples='[]'
    elif [[ -z "$relation_ontology_expected_phase" ]]; then
        [[ "$relation_ontology_expected_result" \
                == "EXTERNAL_ADMISSION_FAILURE" ]] ||
            fail "phase-free ontology row is not an external admission: $relation_ontology_case_id"
        case "$relation_ontology_case_id" in
            post_index_change_emits_zero_helper_records|workflow_dispatch_terminates_before_relation_call|hostile_trace_state_fails_before_private_witness|current_index_marker_nonHEAD_dirty_repository_rejected) ;;
            *) fail "unrecognized external ontology selector binding: $relation_ontology_case_id" ;;
        esac
        # The production selector is deliberately closed to topology-result
        # candidates. Bind this fixture once with its truthful empty candidate
        # set; the external actor outcome is exercised independently below.
        relation_ontology_tuples='[]'
        relation_ontology_hook_result=TOPOLOGY_VERIFIED
        relation_ontology_hook_guard=""
        relation_ontology_hook_phase=""
        relation_ontology_hook_object=""
        relation_ontology_hook_missing=""
    else
        relation_ontology_tuple_phase="${relation_ontology_expected_phase:-0}"
        relation_ontology_tuple_object="${relation_ontology_expected_object:-0}"
        relation_ontology_hook_object="$relation_ontology_tuple_object"
        relation_ontology_tuples="$(/usr/bin/jq -cn \
            --arg phase "$relation_ontology_tuple_phase" \
            --arg object "$relation_ontology_tuple_object" \
            --arg result "$relation_ontology_expected_result" \
            --arg guard "$relation_ontology_expected_guard" \
            --arg missing "$relation_ontology_expected_missing" \
            '[($phase + "|" + $object + "|" + $result + "|" + $guard + "|" + $missing)]')"
    fi
    relation_call_selector_hook \
        "binding:relationOntologyCases:$relation_ontology_case_id" \
        "$relation_ontology_tuples" "$relation_ontology_hook_result" \
        "$relation_ontology_hook_guard" "$relation_ontology_hook_phase" \
        "$relation_ontology_hook_object" "$relation_ontology_hook_missing"
    binding_ordinal="$(relation_authority_jq -r \
        --arg fixture_id "$relation_ontology_case_id" \
        '.pureTestHookContract.exactFixtureBindings[]
            | select(.fixtureRegistry == "relationOntologyCases"
                and .fixtureID == $fixture_id) | .ordinal')"
    builtin printf '%s\t%s\t%s\n' "$binding_ordinal" relationOntologyCases \
        "$relation_ontology_case_id" >> "$relation_hook_witness_registry"
    relation_ontology_index=$((relation_ontology_index + 1))
done

readonly relation_expected_hook_bindings="$test_root/relation-hook-bindings.expected"
readonly relation_observed_hook_bindings="$test_root/relation-hook-bindings.observed"
relation_authority_jq -r \
    '.pureTestHookContract.exactFixtureBindings[]
        | [.ordinal, .fixtureRegistry, .fixtureID] | @tsv' \
    > "$relation_expected_hook_bindings"
/usr/bin/sort -n -k1,1 "$relation_hook_witness_registry" \
    > "$relation_observed_hook_bindings"
[[ "$(/usr/bin/wc -l < "$relation_observed_hook_bindings" | \
        /usr/bin/awk '{print $1}')" == "135" ]] \
    && /usr/bin/cmp -s \
        "$relation_observed_hook_bindings" "$relation_expected_hook_bindings" ||
    fail "exact 135 production-hook fixture bindings are incomplete or duplicated"

# The fixture registry accounts for exactly 129 sourced-helper calls plus six
# private gate calls. Component executions and trace-admission regression calls
# are deliberately additional and have their own exact totals.
readonly relation_expected_helper_binding_calls="$test_root/relation-helper-bindings.expected"
readonly relation_observed_helper_binding_calls="$test_root/relation-helper-bindings.observed"
relation_authority_jq -r \
    '.pureTestHookContract.exactFixtureBindings[]
        | select(.hookFunctionName == "prime_test_exact_revision_topology_v1")
        | ("binding:" + .fixtureRegistry + ":" + .fixtureID)' \
    | /usr/bin/sort > "$relation_expected_helper_binding_calls"
/usr/bin/awk -F '\t' '$2 ~ /^binding:/ { print $2 }' \
    "$relation_hook_invocation_registry" \
    | /usr/bin/sort > "$relation_observed_helper_binding_calls"
[[ "$gate_root_hook_call_count" == "6" \
    && "$(/usr/bin/wc -l < "$relation_observed_helper_binding_calls" \
        | /usr/bin/awk '{print $1}')" == "129" \
    && "$relation_helper_hook_attempt_count" == "131" \
    && "$(/usr/bin/wc -l < "$relation_hook_invocation_registry" \
        | /usr/bin/awk '{print $1}')" == "143" \
    && "$(/usr/bin/awk -F '\t' '$2 ~ /\// { count += 1 } END { print count + 0 }' \
        "$relation_hook_invocation_registry")" == "12" \
    && "$(/usr/bin/awk -F '\t' '$2 ~ /^trace:/ { count += 1 } END { print count + 0 }' \
        "$relation_hook_invocation_registry")" == "2" ]] \
    && /usr/bin/cmp -s "$relation_observed_helper_binding_calls" \
        "$relation_expected_helper_binding_calls" ||
    fail "bound, component, or trace-admission hook call accounting changed"

# One deterministic live FIFO execution reaches the classifier's real
# F_SETNOSIGPIPE/write path. The reader/writer open handshake completes first;
# the reader is then waited closed, leaving fd1 as a pipe with zero readers.
prime_test_live_relation_classifier_epipe_v1() {
    [[ "$#" == "2" ]] || return 2
    local private_matrix_root="$1"
    local admitted_classifier_path="$2"
    local recipe fifo_path mkfifo_status stat_status stat_output reader_pid
    local reader_status classifier_status cleanup_status stdin_fixture_id
    local stdin_fixture_path stderr_path
    recipe="$(relation_authority_jq -c '.deterministicLiveEPIPERecipe')"
    [[ "$private_matrix_root" == "$test_root" \
        && "$admitted_classifier_path" == "$classifier_executable" \
        && -d "$private_matrix_root" && ! -L "$private_matrix_root" \
        && -f "$admitted_classifier_path" \
        && ! -L "$admitted_classifier_path" \
        && -x "$admitted_classifier_path" ]] || return 2
    fifo_path="$private_matrix_root/prime-topology-epipe.fifo"
    [[ ! -e "$fifo_path" && ! -L "$fifo_path" ]] ||
        fail "live EPIPE FIFO leaf already exists"
    set +e
    /usr/bin/mkfifo -m 0600 "$fifo_path" \
        > "$test_root/live-epipe.mkfifo.stdout" \
        2> "$test_root/live-epipe.mkfifo.stderr"
    mkfifo_status="$?"
    set -e
    [[ "$mkfifo_status" == "$(/usr/bin/jq -r '.mkfifoExpectedStatus' \
            <<< "$recipe")" \
        && ! -s "$test_root/live-epipe.mkfifo.stdout" \
        && ! -s "$test_root/live-epipe.mkfifo.stderr" \
        && -p "$fifo_path" && ! -L "$fifo_path" ]] ||
        fail "live EPIPE FIFO creation changed"
    set +e
    /usr/bin/env -i LC_ALL=C /usr/bin/stat -f '%u %p %HT' -- "$fifo_path" \
        > "$test_root/live-epipe.stat.stdout" \
        2> "$test_root/live-epipe.stat.stderr"
    stat_status="$?"
    set -e
    [[ "$stat_status" == "$(/usr/bin/jq -r '.fifoStatExpectedStatus' \
            <<< "$recipe")" \
        && ! -s "$test_root/live-epipe.stat.stderr" \
        && "$(< "$test_root/live-epipe.stat.stdout")" \
            == "$EUID 10600 Fifo File" ]] ||
        fail "live EPIPE FIFO owner/mode/type admission changed"

    /bin/bash -p -c 'exec 3<"$1"; exec 3<&-' \
        prime-epipe-reader "$fifo_path" &
    reader_pid="$!"
    exec 4> "$fifo_path"
    set +e
    wait "$reader_pid"
    reader_status="$?"
    set -e
    [[ "$reader_status" == "$(/usr/bin/jq -r '.readerExpectedStatus' \
        <<< "$recipe")" ]] || fail "live EPIPE reader handshake changed"

    relation_load_rendered_arguments \
        "$(/usr/bin/jq -c '.exactClassifierArgumentVector' <<< "$recipe")"
    component_classifier_arguments=("${relation_arguments[@]}")
    stdin_fixture_id="$(/usr/bin/jq -r '.stdinFixtureID' <<< "$recipe")"
    stdin_fixture_path="$relation_fixture_root/$stdin_fixture_id.payload"
    stderr_path="$test_root/live-epipe.classifier.stderr"
    set +e
    "${component_classifier_arguments[@]}" \
        < "$stdin_fixture_path" 1>&4 2> "$stderr_path"
    classifier_status="$?"
    set -e
    exec 4>&-
    [[ "$classifier_status" \
            == "$(/usr/bin/jq -r '.exactExpectedClassifierStatus' \
                <<< "$recipe")" \
        && ! -s "$stderr_path" ]] ||
        fail "live relation classifier did not return exact EPIPE status28"
    set +e
    /bin/rm -f -- "$fifo_path" \
        > "$test_root/live-epipe.cleanup.stdout" \
        2> "$test_root/live-epipe.cleanup.stderr"
    cleanup_status="$?"
    set -e
    [[ "$cleanup_status" == "$(/usr/bin/jq -r '.cleanupExpectedStatus' \
            <<< "$recipe")" \
        && ! -s "$test_root/live-epipe.cleanup.stdout" \
        && ! -s "$test_root/live-epipe.cleanup.stderr" \
        && ! -e "$fifo_path" && ! -L "$fifo_path" ]] ||
        fail "live EPIPE FIFO cleanup changed"
}

readonly prime_private_matrix_root="$test_root"
readonly prime_classifier_path="$classifier_executable"
prime_test_live_relation_classifier_epipe_v1 "${prime_private_matrix_root}" "${prime_classifier_path}"

relation_load_public_helper_arguments() {
    local ontology_case="$1"
    local private_repository="$2"
    relation_load_rendered_arguments \
        "$(/usr/bin/jq -c '.invocationRecipe.exactHelperArgumentTokens' \
            <<< "$ontology_case")" "$private_repository"
    relation_public_helper_arguments=("${relation_arguments[@]}")
}

readonly relation_public_witness_registry="$test_root/relation-public-witnesses"
: > "$relation_public_witness_registry"
readonly relation_normal_public_case_count="$(relation_authority_jq -r '
    [.relationOntologyCases[]
        | select(.expectedPublicHelperInvocationCount == 1)
        | select(.caseID != "post_index_change_emits_zero_helper_records")
        | select(.caseID != "hostile_trace_state_fails_before_private_witness")]
    | length')"
[[ "$relation_normal_public_case_count" == "20" ]] ||
    fail "normal public relation-helper case count changed"
relation_public_index=0
while [[ "$relation_public_index" -lt "$relation_normal_public_case_count" ]]; do
    relation_public_case="$(relation_authority_jq -c "
        [.relationOntologyCases[]
            | select(.expectedPublicHelperInvocationCount == 1)
            | select(.caseID != \"post_index_change_emits_zero_helper_records\")
            | select(.caseID != \"hostile_trace_state_fails_before_private_witness\")]
        | .[$relation_public_index]")"
    relation_public_case_id="$(/usr/bin/jq -r '.caseID' \
        <<< "$relation_public_case")"
    relation_public_recipe_id="$(/usr/bin/jq -r '.privateRepositoryRecipeID' \
        <<< "$relation_public_case")"
    relation_public_repository="$test_root/public-$relation_public_case_id"
    relation_prepare_private_repository "$relation_public_recipe_id" \
        "$relation_public_repository"
    case "$relation_public_case_id" in
        legacy_flat_nonHEAD_dirty_repository_remains_legacy|current_index_marker_nonHEAD_dirty_repository_rejected)
            : > "$relation_public_repository/prime-dirty-probe"
            [[ "$(git_clean -C "$relation_public_repository" \
                    status --porcelain=v1 --untracked-files=all)" \
                    == "?? prime-dirty-probe" ]] ||
                fail "typed dirty legacy/current-index state changed: $relation_public_case_id"
            ;;
    esac
    relation_load_public_helper_arguments "$relation_public_case" \
        "$relation_public_repository"
    relation_public_record="$test_root/$relation_public_case_id.public.record"
    relation_public_stderr="$test_root/$relation_public_case_id.public.stderr"
    invoke_helper "$relation_public_record" "$relation_public_stderr" \
        "${relation_public_helper_arguments[@]}"
    relation_public_expected_valid="$(/usr/bin/jq -r \
        '.expectedValidHelperRecordCount' <<< "$relation_public_case")"
    if [[ "$relation_public_expected_valid" == "1" ]]; then
        validate_result_record "$relation_public_record" "$helper_status" \
            "$(/usr/bin/jq -r '.expectedResultCode' <<< "$relation_public_case")" \
            "$(/usr/bin/jq -r '.expectedFirstFailedGuardID // "null"' \
                <<< "$relation_public_case")" \
            "$(/usr/bin/jq -r '.expectedMissingObjectRole // "null"' \
                <<< "$relation_public_case")" complete
    else
        [[ "$helper_status" == "2" \
            && ! -s "$relation_public_record" \
            && ! -s "$relation_public_stderr" ]] ||
            fail "public external-admission failure changed: $relation_public_case_id"
    fi
    builtin printf '%s\t%s\t%s\n' "$relation_public_case_id" \
        "$(/usr/bin/jq -r '.eventKind' <<< "$relation_public_case")" \
        "$(/usr/bin/jq -r '.expectedResultCode' <<< "$relation_public_case")" \
        >> "$relation_public_witness_registry"
    relation_public_index=$((relation_public_index + 1))
done

# The hostile state is one public helper attempt with every frozen ambient
# trace vector active together. Trace bytes are private diagnostics; the exact
# discovered child must never appear in either trace or helper stderr.
readonly relation_hostile_case_id="hostile_trace_state_fails_before_private_witness"
relation_hostile_case="$(relation_authority_jq -c --arg case_id \
    "$relation_hostile_case_id" \
    '.relationOntologyCases[] | select(.caseID == $case_id)')"
relation_hostile_recipe_id="$(/usr/bin/jq -r '.privateRepositoryRecipeID' \
    <<< "$relation_hostile_case")"
relation_hostile_repository="$test_root/public-$relation_hostile_case_id"
relation_prepare_private_repository "$relation_hostile_recipe_id" \
    "$relation_hostile_repository"
relation_load_public_helper_arguments "$relation_hostile_case" \
    "$relation_hostile_repository"
relation_hostile_helper_arguments=("${relation_public_helper_arguments[@]}")
relation_hostile_record="$test_root/$relation_hostile_case_id.public.record"
relation_hostile_stderr="$test_root/$relation_hostile_case_id.public.stderr"
relation_hostile_trace="$test_root/$relation_hostile_case_id.trace"
relation_hostile_status_path="$test_root/$relation_hostile_case_id.status"
relation_hostile_outer_stdout="$test_root/$relation_hostile_case_id.outer.stdout"
relation_hostile_outer_stderr="$test_root/$relation_hostile_case_id.outer.stderr"
(
    set +e
    exec 9> "$relation_hostile_trace"
    BASH_XTRACEFD=9
    PS4='prime-hostile-trace:${BASH_SOURCE[0]-unset}:${LINENO}:'
    trap ':' DEBUG
    trap ':' RETURN
    trap ':' ERR
    set -xvET
    prime_verify_exact_revision_topology_v1 \
        "${relation_hostile_helper_arguments[@]}" \
        > "$relation_hostile_record" 2> "$relation_hostile_stderr"
    relation_hostile_status="$?"
    set +x +v +E +T
    trap - DEBUG RETURN ERR
    builtin unset BASH_XTRACEFD
    builtin printf '%s\n' "$relation_hostile_status" \
        > "$relation_hostile_status_path"
) > "$relation_hostile_outer_stdout" 2> "$relation_hostile_outer_stderr"
relation_hostile_child_oid="$(relation_authority_jq -r \
    '.syntheticGitObjectFixtures[]
        | select(.fixtureID == "valid_child") | .literalObjectOID')"
[[ "$(< "$relation_hostile_status_path")" == "2" \
    && ! -s "$relation_hostile_record" \
    && ! -s "$relation_hostile_outer_stdout" ]] ||
    fail "hostile trace state admitted or published the private child witness"
if /usr/bin/grep -Fq -- "$relation_hostile_child_oid" \
        "$relation_hostile_stderr" \
    || /usr/bin/grep -Fq -- "$relation_hostile_child_oid" \
        "$relation_hostile_trace" \
    || /usr/bin/grep -Fq -- "$relation_hostile_child_oid" \
        "$relation_hostile_outer_stdout" \
    || /usr/bin/grep -Fq -- "$relation_hostile_child_oid" \
        "$relation_hostile_outer_stderr"; then
    fail "hostile trace state published the private child witness"
fi
builtin printf '%s\t%s\t%s\n' "$relation_hostile_case_id" push \
    EXTERNAL_ADMISSION_FAILURE >> "$relation_public_witness_registry"

# Isolate the three caller trap classes after the helper has already been
# sourced. Each call leaves the helper-owned functrace watcher armed while
# xtrace, verbose, and errtrace remain off, so the named trap is the sole caller
# mutation. The watcher must seal that exact mutation before production
# admission rejects it and before a raw stream or private parent2 can exist.
readonly relation_isolated_trace_registry="$test_root/relation-isolated-traces"
: > "$relation_isolated_trace_registry"
relation_run_isolated_after_source_trap_case() {
    [[ "$#" == "1" ]] || return 2
    local trap_name="$1"
    case "$trap_name" in DEBUG|RETURN|ERR) ;; *) return 2 ;; esac
    local label="after_source_${trap_name}_trap_only"
    local record="$test_root/$label.public.record"
    local stderr_path="$test_root/$label.public.stderr"
    local status_path="$test_root/$label.status"
    (
        set +e
        [[ "$-" != *x* && "$-" != *v* \
            && ! -o errtrace && -o functrace \
            && -z "${prime_topology_after_source_trap_presence_v1+x}" ]] || exit 98
        case "$trap_name" in
            ERR) builtin trap ':' ERR ;;
            DEBUG) builtin trap ':' DEBUG ;;
            RETURN) builtin trap ':' RETURN ;;
        esac
        [[ "${prime_topology_after_source_trap_presence_v1:-}" == true ]] \
            || exit 97
        prime_verify_exact_revision_topology_v1 \
            "${relation_hostile_helper_arguments[@]}" \
            > "$record" 2> "$stderr_path"
        isolated_status="$?"
        builtin trap - "$trap_name"
        builtin printf '%s\n' "$isolated_status" > "$status_path"
    )
    [[ "$(< "$status_path")" == "2" \
        && ! -s "$record" && ! -s "$stderr_path" ]] ||
        fail "isolated after-source $trap_name trap was not rejected silently"
    if /usr/bin/grep -Fq -- "$relation_hostile_child_oid" "$record" \
        || /usr/bin/grep -Fq -- "$relation_hostile_child_oid" "$stderr_path"; then
        fail "isolated after-source $trap_name trap published the private child"
    fi
    builtin printf '%s\n' "$label" >> "$relation_isolated_trace_registry"
}
relation_run_isolated_after_source_trap_case ERR
relation_run_isolated_after_source_trap_case DEBUG
relation_run_isolated_after_source_trap_case RETURN
[[ "$(/usr/bin/wc -l < "$relation_isolated_trace_registry" | \
        /usr/bin/awk '{print $1}')" == "3" ]] ||
    fail "isolated after-source trap matrix count changed"

# The sole closed mutation wrapper executes a fixed read-tree of the admitted
# alternate fixture after all raw outcomes and before its first post HEAD. It
# must observe the unchanged HEAD, reject the one-byte dirty-status prefix, and
# emit no helper record.
readonly relation_mutation_case_id="post_index_change_emits_zero_helper_records"
relation_mutation_case="$(relation_authority_jq -c --arg case_id \
    "$relation_mutation_case_id" \
    '.relationOntologyCases[] | select(.caseID == $case_id)')"
relation_mutation_recipe_id="$(/usr/bin/jq -r '.privateRepositoryRecipeID' \
    <<< "$relation_mutation_case")"
relation_mutation_repository="$test_root/public-$relation_mutation_case_id"
relation_prepare_private_repository "$relation_mutation_recipe_id" \
    "$relation_mutation_repository"
relation_load_public_helper_arguments "$relation_mutation_case" \
    "$relation_mutation_repository"
prime_case23_exact_helper_arguments=("${relation_public_helper_arguments[@]}")
set +e
prime_test_exact_revision_topology_post_raw_index_mutation_v1 "${prime_case23_exact_helper_arguments[@]}" \
    > "$test_root/$relation_mutation_case_id.public.record" \
    2> "$test_root/$relation_mutation_case_id.public.stderr"
relation_mutation_status="$?"
set -e
[[ "$relation_mutation_status" == "2" \
    && ! -s "$test_root/$relation_mutation_case_id.public.record" \
    && ! -s "$test_root/$relation_mutation_case_id.public.stderr" \
    && "$(git_clean -C "$relation_mutation_repository" \
        status --porcelain=v1 --untracked-files=all | /usr/bin/head -c 1)" == "A" ]] ||
    fail "closed post-raw alternate-index mutation seam changed"
builtin printf '%s\t%s\t%s\n' "$relation_mutation_case_id" push \
    EXTERNAL_ADMISSION_FAILURE >> "$relation_public_witness_registry"

[[ "$(/usr/bin/wc -l < "$relation_public_witness_registry" | \
        /usr/bin/awk '{print $1}')" == "22" ]] ||
    fail "public PR/push/legacy relation case coverage changed"

# The workflow sources the privileged gate only for its active job. The gate's
# event admission is textually and operationally before both the matrix and the
# single live helper call, so workflow_dispatch reaches neither. Bind the real
# PR/push argument construction, not the authority prose that describes it.
[[ "$(/usr/bin/grep -Fc -- '  workflow_dispatch:' "$workflow_path")" == "1" \
    && "$(/usr/bin/grep -Fc -- \
        'run: source .github/scripts/prime-ci-active-root-quarantine.sh' \
        "$workflow_path")" == "1" \
    && "$(/usr/bin/grep -Fc -- \
        'shell: '\''/bin/bash --noprofile --norc -p -e -o pipefail -- "{0}"'\''' \
        "$workflow_path")" == "1" ]] ||
    fail "workflow dispatch/source/privileged-shell surface changed"
gate_event_admission_line="$(/usr/bin/grep -nF -- \
    'exact-revision topology-verifier implementation is outside the attempt-1 PR or push-main admission' \
    "$gate_path" | /usr/bin/head -n 1)"
gate_event_admission_line="${gate_event_admission_line%%:*}"
gate_matrix_call_line="$(/usr/bin/grep -nF -- \
    '/bin/bash -p "$prime_root/$exact_revision_topology_verifier_test_script_relative_path"' \
    "$gate_path" | /usr/bin/head -n 1)"
gate_matrix_call_line="${gate_matrix_call_line%%:*}"
gate_live_helper_call_line="$(/usr/bin/grep -nF -- \
    '        prime_verify_exact_revision_topology_v1 \' \
    "$gate_path" | /usr/bin/head -n 1)"
gate_live_helper_call_line="${gate_live_helper_call_line%%:*}"
[[ "$gate_event_admission_line" =~ ^[1-9][0-9]*$ \
    && "$gate_matrix_call_line" =~ ^[1-9][0-9]*$ \
    && "$gate_live_helper_call_line" =~ ^[1-9][0-9]*$ \
    && "$gate_event_admission_line" -lt "$gate_matrix_call_line" \
    && "$gate_matrix_call_line" -lt "$gate_live_helper_call_line" ]] ||
    fail "workflow_dispatch is not stopped before matrix/helper execution"
gate_live_argument_slice="$(/usr/bin/awk '
    $0 == "exact_revision_topology_live_arguments=()" { inside = 1 }
    inside && $0 == "set +e" { exit }
    inside { print }
' "$gate_path")"
[[ "$gate_live_argument_slice" == *'case "${GITHUB_EVENT_NAME:-}" in'* \
    && "$gate_live_argument_slice" == *'    pull_request)'* \
    && "$gate_live_argument_slice" == *'            "--current-index-exact-revision"'* \
    && "$gate_live_argument_slice" == *'    push)'* \
    && "$gate_live_argument_slice" == *'            "--ordered-merge-child-relation"'* \
    && "$gate_live_argument_slice" \
        == *'            "$exact_revision_topology_relation_timeout_repair_authority_merge_revision"'* \
    && "$gate_live_argument_slice" != *workflow_dispatch* ]] ||
    fail "gate PR/push exact helper argument construction changed"
for fixed_gate_literal in \
    'readonly exact_revision_topology_relation_timeout_repair_authority_merge_revision="b7808f39815ebf639b183e00d2cd769a29ebad18"' \
    'readonly exact_revision_topology_relation_timeout_repair_authority_merge_tree="93f8b071397dbde3b2031d98d8e8631963311bcd"' \
    'readonly exact_revision_topology_relation_timeout_repair_authority_merge_first_parent="444cd402c966521f6163f4949b4a73f9a5184e29"' \
    'readonly exact_revision_topology_relation_timeout_repair_authority_merge_second_parent="1bc2471d12f034d51ae6eb8c977198635bc37717"'; do
    [[ "$(/usr/bin/grep -Fc -- "$fixed_gate_literal" "$gate_path")" == "1" ]] ||
        fail "gate repair-base topology literal changed"
done
[[ "$(/usr/bin/grep -Fc -- \
        'git -C ergentics-prime fetch --depth=2 --no-tags --no-write-fetch-head origin "$EXACT_REVISION" b7808f39815ebf639b183e00d2cd769a29ebad18 444cd402c966521f6163f4949b4a73f9a5184e29 1bc2471d12f034d51ae6eb8c977198635bc37717' \
        "$workflow_path")" == "2" ]] ||
    fail "both workflow fetches lost the exact successor closure-want prefix"

# The gate owns exactly two no-parent2 closed children (status and tree). The
# matrix component harness owns one looped one-way entry callsite, exercised by
# exactly the four raw-owning recipe children counted above. No resume API may
# exist: every private raw value dies with its owning child.
[[ "$(/usr/bin/grep -Fc -- \
        '    prime_enter_exact_revision_topology_closed_child_v1 || exit 124' \
        "$gate_path")" == "2" \
    && "$(/usr/bin/grep -Ec -- \
        '^[[:space:]]*prime_enter_exact_revision_topology_closed_child_v1 \|\|$' \
        "$test_path")" == "1" ]] ||
    fail "gate or matrix one-way closed-child callsite count changed"
if /usr/bin/grep -Eq -- \
        'prime_(suspend|resume)_exact_revision_topology_trace_watcher_v1' \
        "$gate_path" "$helper_path" "$test_path"; then
    fail "obsolete trace-watcher suspension API survived one-way conversion"
fi
matrix_component_source_slice="$(/usr/bin/awk '
    /^prime_test_exact_revision_topology_component_harness_v1\(\) \{/ { inside = 1 }
    inside { print }
    inside && /^}$/ { exit }
' "$test_path")"
[[ "$(/usr/bin/grep -Ec -- \
        '^[[:space:]]*prime_enter_exact_revision_topology_closed_child_v1 \|\|$' \
        <<< "$matrix_component_source_slice")" == "1" ]] ||
    fail "component harness does not own exactly one looped closed-child entry"
matrix_component_closed_tail="$(/usr/bin/awk '
    /prime_enter_exact_revision_topology_closed_child_v1 \|\|/ { inside = 1 }
    inside { print }
' <<< "$matrix_component_source_slice")"
[[ -n "$matrix_component_closed_tail" ]] ||
    fail "could not isolate the component closed-child source tail"
if /usr/bin/grep -Eq -- \
        '(^|[;&|])[[:space:]]*((builtin|command)[[:space:]]+)?(trap|set|shopt|eval|source)[[:space:]]|\$\([[:space:]]*((builtin|command)[[:space:]]+)?(trap|set|shopt|eval|source)[[:space:]]' \
        <<< "$matrix_component_closed_tail"; then
    fail "component mutates trace/source/dynamic state after closed-child entry"
fi
gate_closed_child_source="$(/usr/bin/awk '
    $0 == "    prime_enter_exact_revision_topology_closed_child_v1 || exit 124" {
        window_count += 1
        inside = 1
        next
    }
    inside && $0 == "})\"" {
        inside = 0
        next
    }
    inside { print }
    END { if (inside || window_count != 2) exit 1 }
' "$gate_path")" || fail "could not isolate the two gate closed children"
[[ "$(/usr/bin/grep -Fc -- '--porcelain=v1 --untracked-files=all 2>&1 |' \
        <<< "$gate_closed_child_source")" == "1" \
    && "$(/usr/bin/grep -Fc -- 'write-tree 2>&1 |' \
        <<< "$gate_closed_child_source")" == "1" ]] ||
    fail "gate closed children no longer contain only the exact status/tree probes"
if /usr/bin/grep -Eq -- \
        'prime_verify_exact_revision_topology|classifier|cat-file|parent2|reviewed_child|relation_frame' \
        <<< "$gate_closed_child_source"; then
    fail "gate closed child could materialize or publish a private parent2"
fi

builtin printf '%s\n' \
    "OK: exact-revision topology verifier matrix passed ($live_case_count live private-Git, $pure_case_count pure-source, $direct_fixture_count direct classifier, $helper_parser_count helper-parser, $static_check_count static witnesses; relation 135 bound fixture hooks [129 helper + 6 gate], 12 component helper hooks, 2 extra trace-admission frame attempts, 5 component raw pipelines in 4 one-way closed children, 2 gate no-parent2 closed children, 6 components, 22 public cases, 3 isolated traps, 1 live EPIPE, 1 post-raw mutation)"
