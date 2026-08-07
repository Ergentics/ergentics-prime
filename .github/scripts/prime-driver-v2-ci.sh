#!/bin/bash

# These are transient CI canaries. They are not Driver V2 durable receipts and
# do not grant process, build, inventory, staging, shard, or completion authority.

set -euo pipefail
IFS=$'\n\t'

readonly expected_companion_head="163fc100710ece48119bc25954452d10f6a84f7f"
readonly expected_companion_tree="9009daa4f8a07fbd5897e00b9571cef44ec292db"
readonly expected_mlx_head="d37885a278f1c37484a94d0f401a418735e66519"
readonly expected_mlx_origin="https://github.com/Ergentics/ergentics-mlx-swift"
readonly expected_mlx_tree="5310749549cca107fc1bb07d82dacf043bc02b9e"
readonly expected_mlx_submodule_head="ce45c52505c8158ea48d2a54e8caae05efd86bfe"
readonly expected_mlx_c_submodule_head="0726ca922fc902c4c61ef9c27d94132be418e945"
readonly expected_source_identity="62029c608da674d03beb585f45851d63c15bb71ba334fcf820d51b7c9fd06a4b"
readonly expected_package_sha="04a91e1d38a5aa3a4c3712f09b08665cc8fc8ed7193f1b674ca8f014734585d2"
readonly expected_resolved_sha="59fec61eb25e2d5c464f5bf35434966dea3c8f64da72503d83eb48910c0eab16"
readonly expected_mirrors_sha="b8476f18b4ee05b10e208cc37667d3c69e117bd5eda0162e77804570c5713a6b"
readonly expected_xctest_sha="93ccc091a0343ac4fed35b208447d7460eae27668ddec3e931f54b9a7769212b"
readonly expected_swift_testing_sha="487c601e9693d6a0fbc31d1b683ffd342ba0d10007c780f315af1113d825e8a3"
readonly checkout_companion_origin="https://github.com/Ergentics/pmhnp-companion-ergentics"
readonly frozen_companion_origin="https://github.com/Ergentics/pmhnp-companion-ergentics.git"
readonly metal_toolchain_id="com.apple.dt.toolchain.Metal.32023.883"
readonly expected_metallib_sha="24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b"
readonly expected_metallib_bytes="3817916"
readonly expected_donor_info_sha="124c82bbfd7fe1ea93aa05b5a50d1e5828759fb268556ed119399212726e6a1e"
readonly expected_donor_info_bytes="1130"
readonly expected_runtime_info_sha="62486b35d9253522fe58dba1487d910b3d00d892954558145c553051bd61684d"
readonly expected_runtime_info_bytes="1120"
readonly canonical_runtime_info_template_relative_path="Sources/PrimeMLXRuntimeScaffold/Templates/canonical-swiftpm-runtime/mlx-swift_Cmlx.bundle/Contents/Info.plist"

readonly runner_temp="${RUNNER_TEMP:?RUNNER_TEMP is required}"
readonly expected_prime_head="${GITHUB_SHA:?GITHUB_SHA is required}"
readonly script_directory="$(cd "$(dirname "$0")" && pwd -P)"
readonly prime_root="$(cd "$script_directory/../.." && pwd -P)"
readonly companion_root="$(cd "$prime_root/../companion" && pwd -P)"
readonly mlx_root="$(cd "$prime_root/../mlx" && pwd -P)"
readonly frozen_inventory_root="$prime_root/Tests/PrimeValidationWorkflow/Tests/PrimeValidationWorkflowDriverCoreTests/Resources"
readonly mirrors_file="$prime_root/.swiftpm/configuration/mirrors.json"

prime_initial_tree=""
mlx_rewrite_key=""
last_xctest_events=""
root_pinned_metallib=""

die() {
    echo "prime-driver-v2-ci: $*" >&2
    exit 1
}

remove_mlx_rewrite() {
    if [[ -n "$mlx_rewrite_key" ]]; then
        git config --global --unset-all "$mlx_rewrite_key"
        mlx_rewrite_key=""
    fi
}

cleanup() {
    local prior_status=$?
    local cleanup_status=0
    trap - EXIT
    set +e
    if [[ -n "$mlx_rewrite_key" ]]; then
        git config --global --unset-all "$mlx_rewrite_key"
        cleanup_status=$?
    fi
    if [[ "$prior_status" -eq 0 && "$cleanup_status" -ne 0 ]]; then
        prior_status=$cleanup_status
    fi
    exit "$prior_status"
}

trap cleanup EXIT

assert_command() {
    command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

assert_file_sha() {
    local path="$1"
    local expected="$2"
    local label="$3"
    local digest_file="$runner_temp/$label.sha256"
    local observed remainder

    shasum -a 256 "$path" > "$digest_file"
    IFS=' ' read -r observed remainder < "$digest_file"
    [[ -n "${remainder:-}" ]] || die "$label digest output was incomplete"
    [[ "$(wc -l < "$digest_file")" -eq 1 ]] ||
        die "$label digest output was not singular"
    [[ "$observed" == "$expected" ]] || die "$label digest mismatch"
}

assert_file_bytes() {
    local path="$1"
    local expected="$2"
    local label="$3"
    local observed

    [[ -f "$path" && ! -L "$path" ]] ||
        die "$label is not a regular non-symlink file"
    observed="$(stat -f '%z' "$path")"
    [[ "$observed" == "$expected" ]] ||
        die "$label byte count differs"
}

assert_file_mode() {
    local path="$1"
    local expected="$2"
    local label="$3"
    local observed

    [[ -f "$path" && ! -L "$path" ]] ||
        die "$label is not a regular non-symlink file"
    observed="$(stat -f '%Lp' "$path")"
    [[ "$observed" == "$expected" ]] || die "$label mode differs"
}

assert_directory_mode() {
    local path="$1"
    local expected="$2"
    local label="$3"
    local observed

    [[ -d "$path" && ! -L "$path" ]] ||
        die "$label is not a non-symlink directory"
    observed="$(stat -f '%Lp' "$path")"
    [[ "$observed" == "$expected" ]] || die "$label mode differs"
}

assert_runtime_bundle_tree() {
    local release_bin="$1"
    local metallib_state="$2"
    local label="$3"
    local actual="$runner_temp/$label.actual"
    local expected="$runner_temp/$label.expected"
    local bundle="$release_bin/mlx-swift_Cmlx.bundle"

    [[ -d "$bundle" && ! -L "$bundle" ]] ||
        die "$label root is not a non-symlink directory"
    (
        cd "$release_bin"
        find mlx-swift_Cmlx.bundle -mindepth 0 -print | LC_ALL=C sort
    ) > "$actual"
    case "$metallib_state" in
        absent)
            printf '%s\n' \
                'mlx-swift_Cmlx.bundle' \
                'mlx-swift_Cmlx.bundle/Contents' \
                'mlx-swift_Cmlx.bundle/Contents/Info.plist' \
                'mlx-swift_Cmlx.bundle/Contents/Resources' \
                > "$expected"
            ;;
        present)
            printf '%s\n' \
                'mlx-swift_Cmlx.bundle' \
                'mlx-swift_Cmlx.bundle/Contents' \
                'mlx-swift_Cmlx.bundle/Contents/Info.plist' \
                'mlx-swift_Cmlx.bundle/Contents/Resources' \
                'mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib' \
                > "$expected"
            ;;
        *)
            die "$label requested an invalid metallib state"
            ;;
    esac
    cmp -s "$actual" "$expected" || die "$label tree differs"

    assert_directory_mode "$bundle" 700 "$label-bundle"
    assert_directory_mode "$bundle/Contents" 700 "$label-contents"
    assert_directory_mode \
        "$bundle/Contents/Resources" \
        700 \
        "$label-resources"
    assert_file_mode \
        "$bundle/Contents/Info.plist" \
        444 \
        "$label-info"
    if [[ "$metallib_state" == present ]]; then
        assert_file_mode \
            "$bundle/Contents/Resources/default.metallib" \
            444 \
            "$label-metallib"
    fi
}

assert_empty_directory() {
    local directory="$1"
    local label="$2"
    local entries="$runner_temp/$label.entries"

    [[ -d "$directory" ]] || die "$label is not a directory"
    find "$directory" -mindepth 1 -print > "$entries"
    [[ ! -s "$entries" ]] || die "$label is not empty"
}

assert_lease_directory() {
    local directory="$1"
    local label="$2"
    local expected_file="$directory/prime-validation-swiftpm-build-inventory.lock"
    local actual="$runner_temp/$label.lease.actual"
    local expected="$runner_temp/$label.lease.expected"

    [[ -f "$expected_file" ]] || die "$label lock file is absent"
    [[ ! -L "$expected_file" ]] || die "$label lock file is a symlink"
    find "$directory" -mindepth 1 -print | LC_ALL=C sort > "$actual"
    printf '%s\n' "$expected_file" > "$expected"
    cmp -s "$actual" "$expected" || die "$label lease contents differ"
}

assert_clean_checkout() {
    local repository="$1"
    local label="$2"
    local status_file="$runner_temp/$label.status"

    git -C "$repository" diff --quiet --no-ext-diff ||
        die "$label has unstaged tracked changes"
    git -C "$repository" diff --cached --quiet --no-ext-diff ||
        die "$label has staged changes"
    git -C "$repository" status --porcelain=v2 --untracked-files=all \
        > "$status_file"
    [[ ! -s "$status_file" ]] || die "$label checkout is not clean"
}

assert_no_persisted_credentials() {
    local repository="$1"
    local label="$2"
    local matches="$runner_temp/$label.credentials"
    local grep_status

    set +e
    git -C "$repository" config --local --name-only --get-regexp \
        '^(http\..*\.extraheader|core\.(sshCommand|sshcommand))$' > "$matches"
    grep_status=$?
    set -e
    case "$grep_status" in
        0)
            die "$label retained checkout credentials"
            ;;
        1)
            [[ ! -s "$matches" ]] ||
                die "$label credential probe was inconsistent"
            ;;
        *)
            die "$label credential probe failed with $grep_status"
            ;;
    esac
}

assert_origin() {
    local repository="$1"
    local expected="$2"
    local label="$3"
    local observed

    observed="$(
        git -C "$repository" config --local --get remote.origin.url
    )"
    case "$observed" in
        "$expected"|"$expected.git")
            ;;
        *)
            die "$label origin is unexpected: $observed"
            ;;
    esac
}

assert_exact_origin() {
    local repository="$1"
    local expected="$2"
    local label="$3"
    local actual="$runner_temp/$label.origin.actual"
    local expected_file="$runner_temp/$label.origin.expected"

    git -C "$repository" config --local --get-all remote.origin.url \
        > "$actual"
    printf '%s\n' "$expected" > "$expected_file"
    cmp -s "$actual" "$expected_file" ||
        die "$label exact origin differs"
}

pin_companion_transport_origin() {
    local before="$runner_temp/companion-origin.before"
    local isolated="$runner_temp/companion-origin.isolated"
    local expected="$runner_temp/companion-origin.expected"
    local observed

    assert_git_identity \
        "$companion_root" \
        "$expected_companion_head" \
        "$expected_companion_tree" \
        companion-origin-preflight
    git -C "$companion_root" config --local --get-all remote.origin.url \
        > "$before"
    [[ "$(wc -l < "$before")" -eq 1 ]] ||
        die "companion origin is not singular"
    IFS= read -r observed < "$before"
    case "$observed" in
        "$checkout_companion_origin"|"$frozen_companion_origin")
            ;;
        *)
            die "companion origin cannot be normalized: $observed"
            ;;
    esac

    git -C "$companion_root" remote set-url \
        origin "$frozen_companion_origin"
    /usr/bin/env -i \
        GIT_NO_REPLACE_OBJECTS=1 \
        GIT_OPTIONAL_LOCKS=0 \
        GIT_CONFIG_NOSYSTEM=1 \
        GIT_CONFIG_GLOBAL=/dev/null \
        GIT_CONFIG_SYSTEM=/dev/null \
        GIT_TERMINAL_PROMPT=0 \
        GIT_PAGER=cat \
        GIT_FLUSH=1 \
        LC_ALL=C \
        LANG=C \
        TMPDIR="$runner_temp" \
        /usr/bin/git \
        --no-replace-objects \
        -c core.fsmonitor=false \
        -C "$companion_root" \
        remote get-url origin > "$isolated"
    printf '%s\n' "$frozen_companion_origin" > "$expected"
    cmp -s "$isolated" "$expected" ||
        die "isolated companion origin differs"
    assert_exact_origin \
        "$companion_root" \
        "$frozen_companion_origin" \
        companion
    assert_no_persisted_credentials "$companion_root" companion-origin
}

assert_git_identity() {
    local repository="$1"
    local expected_head="$2"
    local expected_tree="$3"
    local label="$4"
    local observed_head observed_tree

    observed_head="$(git -C "$repository" rev-parse HEAD)"
    observed_tree="$(git -C "$repository" rev-parse 'HEAD^{tree}')"
    [[ "$observed_head" == "$expected_head" ]] ||
        die "$label HEAD mismatch"
    [[ "$observed_tree" == "$expected_tree" ]] ||
        die "$label tree mismatch"
    assert_clean_checkout "$repository" "$label"
    assert_no_persisted_credentials "$repository" "$label"
}

assert_exact_summary() {
    local log="$1"
    local expected="$2"
    local label="$3"

    awk -v expected="$expected" '
        index($0, expected) { count += 1 }
        END { exit count == 1 ? 0 : 1 }
    ' "$log" || die "$label summary was not exact and singular"
}

assert_final_xctest_summary() {
    local log="$1"
    local expected="$2"
    local label="$3"

    awk -v expected="$expected" '
        { sub(/\r$/, "") }
        /^[[:space:]]*Executed [0-9]+ tests?,/ { final = $0 }
        END {
            exit final != "" && index(final, expected) > 0 ? 0 : 1
        }
    ' "$log" || die "$label final XCTest summary differs"
}

parse_xctest_events() {
    local log="$1"
    local label="$2"
    local events="$runner_temp/$label.events"

    awk '
        function test_id(line) {
            sub(/^Test Case \047-\[/, "", line)
            sub(/\]\047 .*/, "", line)
            sub(/ /, "/", line)
            return line
        }
        { sub(/\r$/, "") }
        /^Test Case / {
            if ($0 ~ /^Test Case \047-\[[^ ]+ [^ ]+\]\047 started\.$/) {
                print "started\t" test_id($0)
                next
            }
            if ($0 ~ /^Test Case \047-\[[^ ]+ [^ ]+\]\047 (passed|failed|skipped) \([0-9]+(\.[0-9]+)? seconds\)\.$/) {
                status = $0
                sub(/^.*\]\047 /, "", status)
                sub(/ .*/, "", status)
                print status "\t" test_id($0)
                next
            }
            print "unparsed XCTest event: " $0 > "/dev/stderr"
            bad = 1
        }
        END { if (bad) exit 1 }
    ' "$log" > "$events" || die "$label XCTest transcript was not parseable"
    last_xctest_events="$events"
}

assert_xctest_execution() {
    local log="$1"
    local expected_inventory="$2"
    local label="$3"
    local expected_sorted="$runner_temp/$label.expected.sorted"
    local started="$runner_temp/$label.started"
    local terminal="$runner_temp/$label.terminal"
    local failed="$runner_temp/$label.failed"

    parse_xctest_events "$log" "$label"
    LC_ALL=C sort "$expected_inventory" > "$expected_sorted"
    awk -F '\t' '$1 == "started" { print $2 }' "$last_xctest_events" |
        LC_ALL=C sort > "$started"
    awk -F '\t' \
        '$1 == "passed" || $1 == "failed" || $1 == "skipped" { print $2 }' \
        "$last_xctest_events" | LC_ALL=C sort > "$terminal"
    awk -F '\t' '$1 == "failed" { print $2 }' "$last_xctest_events" \
        > "$failed"

    [[ ! -s "$failed" ]] || die "$label contains failed XCTest cases"
    cmp -s "$started" "$expected_sorted" ||
        die "$label started XCTest set differs from its inventory"
    cmp -s "$terminal" "$expected_sorted" ||
        die "$label terminal XCTest set differs from its inventory"
}

extract_skip_reasons() {
    local log="$1"
    local output="$2"

    awk '
        {
            sub(/\r$/, "")
            marker = " : Test skipped - "
            offset = index($0, marker)
            if (offset > 0) {
                print substr($0, offset + length(marker))
            }
        }
    ' "$log" | LC_ALL=C sort > "$output"
}

assert_exact_skip() {
    local log="$1"
    local label="$2"
    local expected_id="$3"
    local expected_reason="$4"
    local actual_ids="$runner_temp/$label.skip-ids.actual"
    local expected_ids="$runner_temp/$label.skip-ids.expected"
    local actual_reasons="$runner_temp/$label.skip-reasons.actual"
    local expected_reasons="$runner_temp/$label.skip-reasons.expected"

    awk -F '\t' '$1 == "skipped" { print $2 }' "$last_xctest_events" |
        LC_ALL=C sort > "$actual_ids"
    printf '%s\n' "$expected_id" > "$expected_ids"
    cmp -s "$actual_ids" "$expected_ids" ||
        die "$label skip ID differs"

    extract_skip_reasons "$log" "$actual_reasons"
    printf '%s\n' "$expected_reason" > "$expected_reasons"
    cmp -s "$actual_reasons" "$expected_reasons" ||
        die "$label skip reason differs"
}

assert_no_skips() {
    local log="$1"
    local label="$2"
    local actual_ids="$runner_temp/$label.skip-ids"
    local actual_reasons="$runner_temp/$label.skip-reasons"

    awk -F '\t' '$1 == "skipped" { print $2 }' "$last_xctest_events" \
        > "$actual_ids"
    extract_skip_reasons "$log" "$actual_reasons"
    [[ ! -s "$actual_ids" ]] || die "$label contains skipped XCTest cases"
    [[ ! -s "$actual_reasons" ]] || die "$label contains skip reasons"
}

prepare_swift_root() {
    local root="$1"

    mkdir -m 700 \
        "$root/build" \
        "$root/cache" \
        "$root/config" \
        "$root/security" \
        "$root/module-cache"
    cp "$mirrors_file" "$root/config/mirrors.json"
    chmod 600 "$root/config/mirrors.json"
    assert_file_sha \
        "$root/config/mirrors.json" \
        "$expected_mirrors_sha" \
        "$(basename "$root")-mirrors"
}

assert_runner() {
    local selected selected_canonical selector_canonical
    local expected_xcode="$runner_temp/xcode.expected"
    local actual_xcode="$runner_temp/xcode.actual"
    local expected_swift="$runner_temp/swift.expected"
    local actual_swift="$runner_temp/swift.actual"
    local target_info="$runner_temp/swift-target-info.json"
    local xcrun_swift expected_xcrun_swift
    local forbidden forbidden_matches external_actions_matches grep_status

    [[ "$(uname -m)" == "arm64" ]] || die "runner is not arm64"
    for command in awk cmp find git grep jq nm otool shasum sort stat \
        swift uniq wc xcode-select xcodebuild xcrun xmllint; do
        assert_command "$command"
    done

    selector_canonical="$(
        cd /Applications/Xcode.app/Contents/Developer && pwd -P
    )"
    case "$selector_canonical" in
        /Applications/Xcode.app/Contents/Developer|\
        /Applications/Xcode_26.6.app/Contents/Developer)
            ;;
        *)
            die "Xcode.app resolved to an unexpected developer directory"
            ;;
    esac

    selected="$(xcode-select -p)"
    selected_canonical="$(cd "$selected" && pwd -P)"
    [[ "$selected_canonical" == "$selector_canonical" ]] ||
        die "xcode-select and Xcode.app do not resolve identically"

    printf '%s\n' "Xcode 26.6" "Build version 17F113" > "$expected_xcode"
    xcodebuild -version > "$actual_xcode"
    cmp -s "$actual_xcode" "$expected_xcode" ||
        die "Xcode identity differs from the pinned CI image"

    [[ "$(command -v swift)" == "/usr/bin/swift" ]] ||
        die "swift does not resolve through the system Xcode selector"
    xcrun_swift="$(xcrun --find swift)"
    [[ -x "$xcrun_swift" ]] ||
        die "xcrun Swift compiler is not executable"
    xcrun_swift="$(cd "$(dirname "$xcrun_swift")" && pwd -P)/swift"
    expected_xcrun_swift="$selector_canonical/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift"
    [[ "$xcrun_swift" == "$expected_xcrun_swift" ]] ||
        die "xcrun selected an unexpected Swift compiler"
    printf '%s\n' \
        'swift-driver version: 1.148.6 Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)' \
        'Target: arm64-apple-macosx26.0' \
        > "$expected_swift"
    swift --version > "$actual_swift" 2>&1
    cmp -s "$actual_swift" "$expected_swift" ||
        die "Swift compiler identity differs from the pin"
    swift -print-target-info > "$target_info"
    jq -e '
        .compilerVersion ==
            "Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)"
        and .swiftCompilerTag == "swiftlang-6.3.3.1.3"
        and .target.triple == "arm64-apple-macosx26.0"
        and .target.unversionedTriple == "arm64-apple-macosx"
        and .target.moduleTriple == "arm64-apple-macos"
        and .target.platform == "macosx"
        and .target.arch == "arm64"
        and .target.pointerWidthInBits == 64
    ' "$target_info" >/dev/null || die "Swift target identity differs from the pin"

    forbidden="--disable"
    forbidden="${forbidden}-sandbox"
    forbidden_matches="$runner_temp/forbidden-sandbox-bypass.matches"
    set +e
    grep -n -F -- "$forbidden" \
        "$prime_root/.github/workflows/swift.yml" \
        "$prime_root/.github/workflows/swift-strict-promotion.yml" \
        "$prime_root/.github/scripts/prime-driver-v2-ci.sh" \
        > "$forbidden_matches"
    grep_status=$?
    set -e
    case "$grep_status" in
        0)
            cat "$forbidden_matches" >&2
            die "SwiftPM sandbox bypass is forbidden"
            ;;
        1)
            [[ ! -s "$forbidden_matches" ]] ||
                die "sandbox-bypass scan was inconsistent"
            ;;
        *)
            die "sandbox-bypass scan failed with $grep_status"
            ;;
    esac

    external_actions_matches="$runner_temp/external-actions.matches"
    set +e
    grep -n -E '^[[:space:]]*uses:' \
        "$prime_root/.github/workflows/swift.yml" \
        "$prime_root/.github/workflows/swift-strict-promotion.yml" \
        > "$external_actions_matches"
    grep_status=$?
    set -e
    case "$grep_status" in
        0)
            cat "$external_actions_matches" >&2
            die "external Actions are forbidden by the repository local_only policy"
            ;;
        1)
            [[ ! -s "$external_actions_matches" ]] ||
                die "external-Action scan was inconsistent"
            ;;
        *)
            die "external-Action scan failed with $grep_status"
            ;;
    esac
}

assert_mlx_submodules() {
    local mlx_gitlink mlx_c_gitlink
    local mlx_checkout_head mlx_c_checkout_head

    mlx_gitlink="$(git -C "$mlx_root" rev-parse HEAD:Source/Cmlx/mlx)"
    mlx_c_gitlink="$(git -C "$mlx_root" rev-parse HEAD:Source/Cmlx/mlx-c)"
    [[ "$mlx_gitlink" == "$expected_mlx_submodule_head" ]] ||
        die "MLX submodule gitlink differs"
    [[ "$mlx_c_gitlink" == "$expected_mlx_c_submodule_head" ]] ||
        die "MLX-C submodule gitlink differs"

    mlx_checkout_head="$(
        git -C "$mlx_root/Source/Cmlx/mlx" rev-parse HEAD
    )"
    mlx_c_checkout_head="$(
        git -C "$mlx_root/Source/Cmlx/mlx-c" rev-parse HEAD
    )"
    [[ "$mlx_checkout_head" == "$expected_mlx_submodule_head" ]] ||
        die "checked-out MLX submodule differs"
    [[ "$mlx_c_checkout_head" == "$expected_mlx_c_submodule_head" ]] ||
        die "checked-out MLX-C submodule differs"
    assert_clean_checkout "$mlx_root/Source/Cmlx/mlx" mlx-submodule
    assert_no_persisted_credentials \
        "$mlx_root/Source/Cmlx/mlx" \
        mlx-submodule
    assert_origin \
        "$mlx_root/Source/Cmlx/mlx" \
        "https://github.com/ml-explore/mlx" \
        mlx-submodule
    assert_clean_checkout "$mlx_root/Source/Cmlx/mlx-c" mlx-c-submodule
    assert_no_persisted_credentials \
        "$mlx_root/Source/Cmlx/mlx-c" \
        mlx-c-submodule
    assert_origin \
        "$mlx_root/Source/Cmlx/mlx-c" \
        "https://github.com/ml-explore/mlx-c" \
        mlx-c-submodule
}

assert_static_inputs() {
    local prime_head

    prime_head="$(git -C "$prime_root" rev-parse HEAD)"
    [[ "$prime_head" == "$expected_prime_head" ]] ||
        die "Prime checkout is not GITHUB_SHA"
    if [[ -z "$prime_initial_tree" ]]; then
        prime_initial_tree="$(git -C "$prime_root" rev-parse 'HEAD^{tree}')"
    fi

    assert_clean_checkout "$prime_root" prime
    assert_no_persisted_credentials "$prime_root" prime
    assert_origin "$prime_root" "https://github.com/Ergentics/ergentics-prime" prime
    assert_git_identity \
        "$companion_root" \
        "$expected_companion_head" \
        "$expected_companion_tree" \
        companion
    assert_exact_origin \
        "$companion_root" \
        "$frozen_companion_origin" \
        companion
    assert_git_identity \
        "$mlx_root" \
        "$expected_mlx_head" \
        "$expected_mlx_tree" \
        mlx
    assert_origin \
        "$mlx_root" \
        "$expected_mlx_origin" \
        mlx
    assert_mlx_submodules

    assert_file_sha "$prime_root/Package.swift" "$expected_package_sha" package
    assert_file_sha \
        "$prime_root/$canonical_runtime_info_template_relative_path" \
        "$expected_runtime_info_sha" \
        canonical-runtime-info-template
    assert_file_bytes \
        "$prime_root/$canonical_runtime_info_template_relative_path" \
        "$expected_runtime_info_bytes" \
        canonical-runtime-info-template
    assert_file_sha \
        "$prime_root/Package.resolved" \
        "$expected_resolved_sha" \
        package-resolved
    assert_file_sha "$mirrors_file" "$expected_mirrors_sha" mirrors
    assert_file_sha \
        "$frozen_inventory_root/xctest.list" \
        "$expected_xctest_sha" \
        frozen-xctest
    assert_file_sha \
        "$frozen_inventory_root/swift-testing.list" \
        "$expected_swift_testing_sha" \
        frozen-swift-testing

    jq -e '
        .version == 1
        and .object == []
    ' "$mirrors_file" >/dev/null ||
        die "SwiftPM no-remapping contract differs"

    jq -e \
        --arg revision "$expected_mlx_head" \
        --arg location "$expected_mlx_origin" \
        --arg origin "$expected_package_sha" '
        .originHash == $origin
        and ([.pins[] | select(.identity == "ergentics-mlx-swift")] | length) == 1
        and ([.pins[] | select(.identity == "mlx-swift-lm")] | length) == 0
        and ([.pins[] | select(.identity == "ergentics-mlx-swift")][0]
            | .kind == "remoteSourceControl"
            and .location == $location
            and .state == {revision: $revision})
    ' "$prime_root/Package.resolved" >/dev/null ||
        die "resolved first-party MLX pin differs"

    grep -F -x \
        "        \"$expected_source_identity\"" \
        "$prime_root/Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift" \
        > "$runner_temp/embedded-source-identity.matches"
    [[ "$(wc -l < "$runner_temp/embedded-source-identity.matches")" -eq 1 ]] ||
        die "embedded source identity differs"
}

configure_local_mlx_transport() {
    local before="$runner_temp/mlx-rewrite.before"
    local actual="$runner_temp/mlx-rewrite.actual"
    local expected="$runner_temp/mlx-rewrite.expected"
    local probe="$runner_temp/mlx-local-probe"
    local exact_head="$runner_temp/mlx-local-probe.head"
    local candidate_key="url.file://${mlx_root}.insteadOf"
    local config_status observed remainder

    set +e
    git config --global --get-all "$candidate_key" > "$before"
    config_status=$?
    set -e
    case "$config_status" in
        1)
            [[ ! -s "$before" ]] || die "preexisting MLX rewrite probe differed"
            ;;
        0)
            die "an MLX rewrite already existed"
            ;;
        *)
            die "MLX rewrite preflight failed with $config_status"
            ;;
    esac

    mlx_rewrite_key="$candidate_key"
    git config --global --add \
        "$mlx_rewrite_key" \
        "$expected_mlx_origin"
    git config --global --add \
        "$mlx_rewrite_key" \
        "https://github.com/Ergentics/ergentics-mlx-swift.git"
    git config --global --get-all "$mlx_rewrite_key" > "$actual"
    printf '%s\n' \
        "$expected_mlx_origin" \
        "https://github.com/Ergentics/ergentics-mlx-swift.git" \
        > "$expected"
    cmp -s "$actual" "$expected" || die "local MLX rewrite differs"

    git ls-remote \
        "$expected_mlx_origin" \
        HEAD > "$probe"
    awk '$2 == "HEAD" { print }' "$probe" > "$exact_head"
    [[ "$(wc -l < "$exact_head")" -eq 1 ]] ||
        die "credential-free local MLX HEAD probe was not singular"
    read -r observed remainder < "$exact_head"
    [[ "$observed" == "$expected_mlx_head" && "$remainder" == "HEAD" ]] ||
        die "credential-free local MLX transport probe differed"
}

assert_driver_target_graph() {
    local graph_root graph_file

    graph_root="$(mktemp -d "$runner_temp/prime-target-graph.XXXXXX")"
    graph_root="$(cd "$graph_root" && pwd -P)"
    prepare_swift_root "$graph_root"
    graph_file="$graph_root/package.json"

    env \
        CLANG_MODULE_CACHE_PATH="$graph_root/module-cache" \
        SWIFTPM_MODULECACHE_OVERRIDE="$graph_root/module-cache" \
        swift package \
        --package-path "$prime_root" \
        --cache-path "$graph_root/cache" \
        --config-path "$graph_root/config" \
        --security-path "$graph_root/security" \
        --scratch-path "$graph_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        dump-package > "$graph_file"

    jq -e '
        def target($name):
            [.targets[] | select(.name == $name)];
        def dependencies($name):
            [target($name)[0].dependencies[] | .byName[0]];
        (target("PrimeCore") | length) == 1
        and target("PrimeCore")[0].dependencies == []
        and (target("PrimeValidationWorkflowRootContracts") | length) == 1
        and dependencies("PrimeValidationWorkflowRootContracts") == [
            "PrimeCore"
        ]
        and (target("PrimeValidationWorkflowRootDriverCore") | length) == 1
        and dependencies("PrimeValidationWorkflowRootDriverCore") == [
            "PrimeCore",
            "PrimeValidationWorkflowRootContracts"
        ]
        and (target("PrimeValidationWorkflowDriverV2") | length) == 1
        and target("PrimeValidationWorkflowDriverV2")[0].type == "executable"
        and dependencies("PrimeValidationWorkflowDriverV2") == [
            "PrimeCore",
            "PrimeValidationWorkflowRootContracts",
            "PrimeValidationWorkflowRootDriverCore"
        ]
    ' "$graph_file" >/dev/null || die "Driver target graph differs"
}

build_driver() {
    local root="$1"

    env \
        CLANG_MODULE_CACHE_PATH="$root/module-cache" \
        SWIFTPM_MODULECACHE_OVERRIDE="$root/module-cache" \
        swift build \
        --package-path "$prime_root" \
        --configuration release \
        --cache-path "$root/cache" \
        --config-path "$root/config" \
        --security-path "$root/security" \
        --scratch-path "$root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --product PrimeValidationWorkflowDriverV2
}

assert_driver_binary_closure() {
    local binary="$1"
    local expected_loads="$runner_temp/driver-loads.expected"
    local actual_loads="$runner_temp/driver-loads.actual"
    local symbols="$runner_temp/driver-symbols.all"
    local mlx_symbols="$runner_temp/driver-symbols.third-party-mlx"
    local grep_status

    printf '%s\n' \
        '/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation' \
        '/System/Library/Frameworks/CryptoKit.framework/Versions/A/CryptoKit' \
        '/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation' \
        '/usr/lib/libSystem.B.dylib' \
        '/usr/lib/libobjc.A.dylib' \
        '/usr/lib/swift/libswiftCore.dylib' \
        '/usr/lib/swift/libswiftCoreFoundation.dylib' \
        '/usr/lib/swift/libswiftDarwin.dylib' \
        '/usr/lib/swift/libswiftDispatch.dylib' \
        '/usr/lib/swift/libswiftIOKit.dylib' \
        '/usr/lib/swift/libswiftObjectiveC.dylib' \
        '/usr/lib/swift/libswiftXPC.dylib' \
        | LC_ALL=C sort > "$expected_loads"
    otool -L "$binary" | awk 'NR > 1 { print $1 }' |
        LC_ALL=C sort -u > "$actual_loads"
    cmp -s "$actual_loads" "$expected_loads" ||
        die "Driver dynamic load closure differs"

    nm -a "$binary" > "$symbols"
    set +e
    LC_ALL=C grep -E \
        '[[:space:]](_\$s(3MLX|5MLXNN|6MLXLLM|13MLXOptimizers)|__ZN3mlx|_mlx(_|$)|_OBJC_(CLASS|METACLASS)_\$_MLX)' \
        "$symbols" > "$mlx_symbols"
    grep_status=$?
    set -e
    case "$grep_status" in
        0)
            cat "$mlx_symbols" >&2
            die "Driver contains a third-party MLX-family module symbol"
            ;;
        1)
            [[ ! -s "$mlx_symbols" ]] || die "MLX symbol scan was inconsistent"
            ;;
        *)
            die "MLX symbol scan failed with $grep_status"
            ;;
    esac
}

run_positive_canary() {
    local binary="$1"
    local binary_sha="$2"
    local binary_bytes="$3"
    local suffix="$4"
    local root run_id output canonical_record record_digest
    local declaration declaration_digest observed remainder

    root="$(mktemp -d "$runner_temp/prime-canary-positive-$suffix.XXXXXX")"
    root="$(cd "$root" && pwd -P)"
    mkdir -m 700 "$root/workspace" "$root/evidence" "$root/lease"
    run_id="github-${GITHUB_RUN_ID:?}-${GITHUB_RUN_ATTEMPT:?}-$suffix"
    output="$root/stdout.json"

    "$binary" \
        --run-id "$run_id" \
        --prime-root "$prime_root" \
        --companion-root "$companion_root" \
        --workspace-root "$root/workspace" \
        --evidence-root "$root/evidence" \
        --lease-root "$root/lease" \
        --expected-driver-path "$binary" \
        --expected-driver-sha256 "$binary_sha" \
        --expected-driver-byte-count "$binary_bytes" \
        > "$output" \
        2> "$root/stderr"

    [[ ! -s "$root/stderr" ]] || die "positive canary $suffix wrote stderr"
    assert_empty_directory "$root/workspace" "positive-$suffix-workspace"
    assert_empty_directory "$root/evidence" "positive-$suffix-evidence"
    assert_lease_directory "$root/lease" "positive-$suffix"

    jq -e \
        --arg run "$run_id" \
        --arg source "$expected_source_identity" \
        --arg path "$binary" \
        --arg sha "$binary_sha" \
        --argjson bytes "$binary_bytes" \
        '
        (keys == ["record", "recordSHA256"])
        and ((.record | keys) == [
            "artifactKind",
            "artifactStagingObservation",
            "authorityCeiling",
            "buildExecutionObservation",
            "completionAuthorized",
            "declarationSHA256",
            "executableAbsolutePath",
            "executableByteCount",
            "executableSHA256",
            "inventoryExecutionObservation",
            "missingAuthorities",
            "processExecutionObservation",
            "runID",
            "schemaVersion",
            "shardCompletionObservation",
            "sourceIdentitySHA256",
            "statement"
        ])
        and .record.schemaVersion == 1
        and .record.artifactKind ==
            "ergentics_prime_validation_driver_v2_supervisor_image_canary_v1"
        and .record.runID == $run
        and .record.sourceIdentitySHA256 == $source
        and .record.executableAbsolutePath == $path
        and .record.executableSHA256 == $sha
        and .record.executableByteCount == $bytes
        and .record.authorityCeiling ==
            "supervisor_image_bound_pre_execution_only"
        and .record.missingAuthorities == [
            "prime_git_head_and_clean_process_observation",
            "companion_git_head_and_clean_process_observation",
            "swift_version_process_observation",
            "swift_target_info_process_observation",
            "swiftpm_build_execution",
            "xctest_inventory_execution",
            "swift_testing_inventory_execution",
            "artifact_staging"
        ]
        and .record.processExecutionObservation == "unobserved"
        and .record.buildExecutionObservation == "unobserved"
        and .record.inventoryExecutionObservation == "unobserved"
        and .record.artifactStagingObservation == "unobserved"
        and .record.shardCompletionObservation == "unobserved"
        and .record.completionAuthorized == false
        and .record.statement ==
            "supervisor_image_bound_no_process_build_inventory_staging_shard_or_completion_authority"
        ' "$output" >/dev/null || die "positive canary $suffix record differs"

    jq -cS . "$output" > "$root/canonical-envelope.json"
    cmp -s "$output" "$root/canonical-envelope.json" ||
        die "positive canary $suffix envelope is not canonical"

    canonical_record="$root/canonical-record.json"
    jq -cS -j '.record' "$output" > "$canonical_record"
    shasum -a 256 "$canonical_record" > "$root/record.sha256"
    IFS=' ' read -r record_digest remainder < "$root/record.sha256"
    [[ -n "${remainder:-}" ]] || die "positive canary record digest differed"
    [[ "$record_digest" == "$(jq -r '.recordSHA256' "$output")" ]] ||
        die "positive canary $suffix recordSHA256 differs"

    declaration="$root/declaration.json"
    jq -cS -j -n \
        --arg run "$run_id" \
        --arg source "$expected_source_identity" \
        --arg path "$binary" \
        --arg sha "$binary_sha" \
        --argjson bytes "$binary_bytes" \
        '{
            artifactKind:
                "ergentics_prime_validation_driver_v2_supervisor_image_declaration_v1",
            executable: {
                absolutePath: $path,
                content: {
                    byteCount: $bytes,
                    sha256: $sha
                }
            },
            runID: $run,
            schemaVersion: 1,
            sourceIdentitySHA256: $source
        }' > "$declaration"
    shasum -a 256 "$declaration" > "$root/declaration.sha256"
    IFS=' ' read -r declaration_digest remainder < "$root/declaration.sha256"
    [[ -n "${remainder:-}" ]] || die "positive declaration digest differed"
    observed="$(jq -r '.record.declarationSHA256' "$output")"
    [[ "$declaration_digest" == "$observed" ]] ||
        die "positive canary $suffix declarationSHA256 differs"

    jq -cS \
        '.record | del(.runID, .declarationSHA256, .executableAbsolutePath)' \
        "$output" > "$runner_temp/positive-$suffix.normalized"
    echo "Driver V2 transient CI canary $suffix:"
    cat "$output"
}

run_negative_canary() {
    local kind="$1"
    local binary="$2"
    local declared_path="$3"
    local declared_sha="$4"
    local declared_bytes="$5"
    local expected_diagnostic="$6"
    local root status expected_stderr

    root="$(mktemp -d "$runner_temp/prime-canary-negative-$kind.XXXXXX")"
    root="$(cd "$root" && pwd -P)"
    mkdir -m 700 "$root/workspace" "$root/evidence" "$root/lease"

    set +e
    if [[ "$kind" == "closed-stdout" ]]; then
        "$binary" \
            --run-id "github-negative-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}-$kind" \
            --prime-root "$prime_root" \
            --companion-root "$companion_root" \
            --workspace-root "$root/workspace" \
            --evidence-root "$root/evidence" \
            --lease-root "$root/lease" \
            --expected-driver-path "$declared_path" \
            --expected-driver-sha256 "$declared_sha" \
            --expected-driver-byte-count "$declared_bytes" \
            1>&- \
            2> "$root/stderr"
        status=$?
    else
        "$binary" \
            --run-id "github-negative-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}-$kind" \
            --prime-root "$prime_root" \
            --companion-root "$companion_root" \
            --workspace-root "$root/workspace" \
            --evidence-root "$root/evidence" \
            --lease-root "$root/lease" \
            --expected-driver-path "$declared_path" \
            --expected-driver-sha256 "$declared_sha" \
            --expected-driver-byte-count "$declared_bytes" \
            > "$root/stdout" \
            2> "$root/stderr"
        status=$?
    fi
    set -e

    [[ "$status" -eq 1 ]] || die "$kind negative exited $status"
    if [[ "$kind" != "closed-stdout" ]]; then
        [[ ! -s "$root/stdout" ]] || die "$kind negative wrote stdout"
    fi
    expected_stderr="$root/stderr.expected"
    printf '%s\n' "$expected_diagnostic" > "$expected_stderr"
    cmp -s "$root/stderr" "$expected_stderr" ||
        die "$kind negative diagnostic differs"
    assert_empty_directory "$root/workspace" "$kind-negative-workspace"
    assert_empty_directory "$root/evidence" "$kind-negative-evidence"
    assert_lease_directory "$root/lease" "$kind-negative"
}

run_driver_canaries() {
    local root_a root_b binary_a binary_b inode_a inode_b
    local sha_a sha_b bytes_a bytes_b remainder
    local exact_binding_diagnostic output_diagnostic

    root_a="$(mktemp -d "$runner_temp/prime-driver-a.XXXXXX")"
    root_b="$(mktemp -d "$runner_temp/prime-driver-b.XXXXXX")"
    root_a="$(cd "$root_a" && pwd -P)"
    root_b="$(cd "$root_b" && pwd -P)"
    [[ "$root_a" != "$root_b" ]] || die "Driver roots are not disjoint"
    prepare_swift_root "$root_a"
    prepare_swift_root "$root_b"

    build_driver "$root_a"
    build_driver "$root_b"

    binary_a="$root_a/build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2"
    binary_b="$root_b/build/arm64-apple-macosx/release/PrimeValidationWorkflowDriverV2"
    [[ -x "$binary_a" && -x "$binary_b" ]] || die "Driver binary is absent"
    [[ "$binary_a" != "$binary_b" ]] || die "Driver paths are not disjoint"
    inode_a="$(stat -f '%d:%i' "$binary_a")"
    inode_b="$(stat -f '%d:%i' "$binary_b")"
    [[ "$inode_a" != "$inode_b" ]] || die "Driver images share an inode"
    cmp -s "$binary_a" "$binary_b" || die "Driver images differ bytewise"

    shasum -a 256 "$binary_a" > "$runner_temp/driver-a.sha256"
    shasum -a 256 "$binary_b" > "$runner_temp/driver-b.sha256"
    IFS=' ' read -r sha_a remainder < "$runner_temp/driver-a.sha256"
    [[ -n "${remainder:-}" ]] || die "Driver A digest output differs"
    IFS=' ' read -r sha_b remainder < "$runner_temp/driver-b.sha256"
    [[ -n "${remainder:-}" ]] || die "Driver B digest output differs"
    bytes_a="$(stat -f '%z' "$binary_a")"
    bytes_b="$(stat -f '%z' "$binary_b")"
    [[ "$sha_a" == "$sha_b" && "$bytes_a" == "$bytes_b" ]] ||
        die "Driver image identities differ"

    assert_driver_binary_closure "$binary_a"
    run_positive_canary "$binary_a" "$sha_a" "$bytes_a" a
    run_positive_canary "$binary_b" "$sha_b" "$bytes_b" b
    cmp -s \
        "$runner_temp/positive-a.normalized" \
        "$runner_temp/positive-b.normalized" ||
        die "normalized positive canary records differ"

    exact_binding_diagnostic='prime-validation-driver-v2: rejected rejected("expected_supervisor_image_binding")'
    output_diagnostic='prime-validation-driver-v2: rejected rejected("output_write_9")'
    run_negative_canary \
        wrong-path \
        "$binary_a" \
        "$binary_b" \
        "$sha_a" \
        "$bytes_a" \
        "$exact_binding_diagnostic"
    run_negative_canary \
        wrong-sha \
        "$binary_a" \
        "$binary_a" \
        "0000000000000000000000000000000000000000000000000000000000000000" \
        "$bytes_a" \
        "$exact_binding_diagnostic"
    run_negative_canary \
        wrong-byte-count \
        "$binary_a" \
        "$binary_a" \
        "$sha_a" \
        "$((bytes_a + 1))" \
        "$exact_binding_diagnostic"
    run_negative_canary \
        closed-stdout \
        "$binary_a" \
        "$binary_a" \
        "$sha_a" \
        "$bytes_a" \
        "$output_diagnostic"

    echo "Driver A/B bytes: $bytes_a"
    echo "Driver A/B SHA-256: $sha_a"
}

assert_metal_toolchain() {
    local component="$runner_temp/metal-component.txt"
    local status="$runner_temp/metal-component-status.txt"
    local identifier="$runner_temp/metal-component-identifier.txt"
    local metal_path="$runner_temp/metal-path.txt"
    local metal_version="$runner_temp/metal-version.txt"
    local first_line="$runner_temp/metal-version-first-line.txt"
    local expected_first_line="$runner_temp/metal-version.expected.txt"
    local metal_executable

    xcodebuild -showComponent MetalToolchain > "$component"
    grep -F -x 'Status: installed' "$component" > "$status"
    [[ "$(wc -l < "$status")" -eq 1 ]] ||
        die "Metal toolchain component is not installed"
    grep -F -x \
        "Toolchain Identifier: $metal_toolchain_id" \
        "$component" > "$identifier"
    [[ "$(wc -l < "$identifier")" -eq 1 ]] ||
        die "Metal toolchain component identity differs"

    xcrun --toolchain "$metal_toolchain_id" --find metal > "$metal_path"
    [[ "$(wc -l < "$metal_path")" -eq 1 ]] ||
        die "Metal compiler path output differs"
    IFS= read -r metal_executable < "$metal_path"
    [[ -x "$metal_executable" ]] ||
        die "Metal compiler path is not executable"
    xcrun --toolchain "$metal_toolchain_id" metal --version \
        > "$metal_version" 2>&1
    awk 'NR == 1 { print }' "$metal_version" > "$first_line"
    printf '%s\n' \
        'Apple metal version 32023.883 (metalfe-32023.883)' \
        > "$expected_first_line"
    cmp -s "$first_line" "$expected_first_line" ||
        die "Metal compiler version differs"
}

build_root_release_product() {
    local test_root="$1"
    local product="$2"

    env \
        CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
        SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift build \
        --package-path "$prime_root" \
        --configuration release \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --product "$product"
}

build_debug_compiler_canary_inputs() {
    local test_root="$1"
    local support_root="$test_root/debug-compiler-canary"
    local module="$prime_root/.build/arm64-apple-macosx/debug/Modules/PrimeNativeNeuralGateHistoricalFixtureWorker.swiftmodule"
    local accessor="$prime_root/.build/arm64-apple-macosx/debug/PrimeNativeNeuralGateHistoricalFixtureWorker.build/DerivedSources/resource_bundle_accessor.swift"

    [[ ! -e "$prime_root/.build" && ! -L "$prime_root/.build" ]] ||
        die "refusing to replace a pre-existing Prime .build directory"
    mkdir -m 700 "$support_root"
    prepare_swift_root "$support_root"
    env \
        CLANG_MODULE_CACHE_PATH="$support_root/module-cache" \
        SWIFTPM_MODULECACHE_OVERRIDE="$support_root/module-cache" \
        swift build \
        --package-path "$prime_root" \
        --configuration debug \
        --cache-path "$support_root/cache" \
        --config-path "$support_root/config" \
        --security-path "$support_root/security" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --target PrimeNativeNeuralGateHistoricalFixtureWorker
    [[ -f "$module" && ! -L "$module" ]] ||
        die "Debug compiler-canary worker module is absent"
    [[ -f "$accessor" && ! -L "$accessor" ]] ||
        die "Debug compiler-canary resource accessor is absent"
}

stage_root_pinned_metallib() {
    local test_root="$1"
    local xcode_root="$test_root/xcode"
    local xcode_packages="$test_root/xcode-source-packages"
    local xcode_log="$test_root/xcode-donor.log"
    local release_bin="$test_root/build/arm64-apple-macosx/release"
    local donor_host="$xcode_root/Build/Products/Release/PrimeTypedOptimizerRestoreProbe"
    local donor_bundle="$xcode_root/Build/Products/Release/mlx-swift_Cmlx.bundle"
    local donor_info="$donor_bundle/Contents/Info.plist"
    local donor_metallib="$donor_bundle/Contents/Resources/default.metallib"
    local destination_host="$release_bin/PrimeTypedOptimizerRestoreProbe"
    local runtime_bundle="$release_bin/mlx-swift_Cmlx.bundle"
    local runtime_info="$runtime_bundle/Contents/Info.plist"
    local runtime_metallib="$runtime_bundle/Contents/Resources/default.metallib"
    local scaffold_log="$test_root/runtime-scaffold.log"
    local scaffold_expected="$test_root/runtime-scaffold.expected"
    local stage_log="$test_root/metallib-stage.log"
    local stage_expected="$test_root/metallib-stage.expected"

    assert_metal_toolchain
    mkdir -m 700 "$xcode_root" "$xcode_packages"
    (
        cd "$prime_root"
        xcodebuild build \
            -scheme PrimeTypedOptimizerRestoreProbe \
            -configuration Release \
            -destination 'platform=macOS,arch=arm64' \
            -derivedDataPath "$xcode_root" \
            -clonedSourcePackagesDirPath "$xcode_packages" \
            -scmProvider system \
            -disableAutomaticPackageResolution \
            -onlyUsePackageVersionsFromResolvedFile \
            -skipPackageUpdates \
            TOOLCHAINS="$metal_toolchain_id"
    ) 2>&1 | tee "$xcode_log"

    [[ -x "$donor_host" && ! -L "$donor_host" ]] ||
        die "Xcode metallib donor host is absent"
    assert_file_sha "$donor_info" "$expected_donor_info_sha" donor-info
    assert_file_bytes "$donor_info" "$expected_donor_info_bytes" donor-info
    assert_file_sha \
        "$donor_metallib" \
        "$expected_metallib_sha" \
        donor-metallib
    assert_file_bytes \
        "$donor_metallib" \
        "$expected_metallib_bytes" \
        donor-metallib

    build_root_release_product "$test_root" PrimeTypedOptimizerRestoreProbe
    build_root_release_product "$test_root" PrimeMLXRuntimeScaffold
    build_root_release_product "$test_root" PrimeMLXBundleStage
    [[ -x "$destination_host" && ! -L "$destination_host" ]] ||
        die "SwiftPM metallib destination host is absent"
    [[ -x "$release_bin/PrimeMLXRuntimeScaffold" && \
        ! -L "$release_bin/PrimeMLXRuntimeScaffold" ]] ||
        die "SwiftPM runtime scaffold executable is absent"
    [[ -x "$release_bin/PrimeMLXBundleStage" && \
        ! -L "$release_bin/PrimeMLXBundleStage" ]] ||
        die "SwiftPM metallib stage executable is absent"
    [[ ! -e "$runtime_bundle" && ! -L "$runtime_bundle" ]] ||
        die "SwiftPM destination runtime bundle was not initially absent"

    "$release_bin/PrimeMLXRuntimeScaffold" \
        --source-root "$prime_root" \
        --destination-host "$destination_host" \
        --runtime-role typed_optimizer_restore_probe \
        > "$scaffold_log" 2>&1
    printf '%s\n' \
        "Prime MLX runtime scaffold complete: runtime_role=typed_optimizer_restore_probe mlx_swift=0.31.3 destination_bundle_initially_absent=true runtime_info_plist_sha256=$expected_runtime_info_sha metallib_absent=true" \
        > "$scaffold_expected"
    cmp -s "$scaffold_log" "$scaffold_expected" ||
        die "exact runtime scaffold result differs"
    assert_runtime_bundle_tree \
        "$release_bin" \
        absent \
        runtime-scaffold
    assert_file_sha \
        "$runtime_info" \
        "$expected_runtime_info_sha" \
        runtime-info-before-stage
    assert_file_bytes \
        "$runtime_info" \
        "$expected_runtime_info_bytes" \
        runtime-info-before-stage
    [[ ! -e "$runtime_metallib" && ! -L "$runtime_metallib" ]] ||
        die "SwiftPM destination metallib was not initially absent"

    "$release_bin/PrimeMLXBundleStage" \
        --source-host "$donor_host" \
        --destination-host "$destination_host" \
        --runtime-role typed_optimizer_restore_probe \
        > "$stage_log" 2>&1
    printf '%s\n' \
        "Prime MLX bundle exact stage complete: runtime_role=typed_optimizer_restore_probe mlx_swift=0.31.3 destination_metallib_initially_absent=true xcode_donor_info_plist_sha256=$expected_donor_info_sha runtime_info_plist_sha256=$expected_runtime_info_sha metallib_sha256=$expected_metallib_sha" \
        > "$stage_expected"
    cmp -s "$stage_log" "$stage_expected" ||
        die "exact metallib stage result differs"
    assert_file_sha \
        "$runtime_info" \
        "$expected_runtime_info_sha" \
        runtime-info-after-stage
    assert_file_bytes \
        "$runtime_info" \
        "$expected_runtime_info_bytes" \
        runtime-info-after-stage
    assert_runtime_bundle_tree \
        "$release_bin" \
        present \
        staged-runtime
    assert_file_sha \
        "$runtime_metallib" \
        "$expected_metallib_sha" \
        runtime-metallib
    assert_file_bytes \
        "$runtime_metallib" \
        "$expected_metallib_bytes" \
        runtime-metallib
    root_pinned_metallib="$runtime_metallib"
}

run_root_tests() {
    local test_root focused_log full_log large_log swift_log
    local historical_expected large_expected xunit_request xunit_file
    local xunit_ids frozen_swift_sorted index class name
    local xctest_live swift_live xctest_lines xctest_bytes
    local swift_lines swift_bytes
    local historical_filter

    test_root="$(mktemp -d "$runner_temp/prime-root-release.XXXXXX")"
    test_root="$(cd "$test_root" && pwd -P)"
    prepare_swift_root "$test_root"

    historical_filter='testAppendOnlyWorkerSourceAndTransparentHistoricalTestsMatch|testFrozenV22DesignBindsExactV21SourceTopologyAndFiles|testFrozenV23ContractBindsPreservedAuthoritiesAndExactSources|testFrozenV24BindsExactV23AuthoritiesAndPhysicalSources|testFrozenV25BindsPriorAuthoritiesAndExactAdoptedSource|testFrozenV26BindsV25AndExactCurrentSource|testFrozenV27BindsV26AndExactPhysicalReceipt'
    focused_log="$test_root/historical.log"
    PRIME_PMHNP_COMPANION_ROOT="$companion_root" \
    PRIME_NATIVE_COMPANION_ROOT="$companion_root" \
    CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift test \
        --package-path "$prime_root" \
        --configuration release \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --disable-swift-testing \
        --filter "$historical_filter" \
        2>&1 | tee "$focused_log"

    historical_expected="$test_root/historical.expected"
    printf '%s\n' \
        'PrimeCoreTests.PrimeNativeNeuralGateHistoricalWorkerExportedEvidenceProjectionDecodeCompositionCallEdgeSourceContractTests/testAppendOnlyWorkerSourceAndTransparentHistoricalTestsMatch' \
        'PrimeCoreTests.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerDesignContractTests/testFrozenV24BindsExactV23AuthoritiesAndPhysicalSources' \
        'PrimeCoreTests.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamCallerAndResultConsumerSourceContractTests/testFrozenV25BindsPriorAuthoritiesAndExactAdoptedSource' \
        'PrimeCoreTests.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamDesignContractTests/testFrozenV22DesignBindsExactV21SourceTopologyAndFiles' \
        'PrimeCoreTests.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingDesignContractTests/testFrozenV26BindsV25AndExactCurrentSource' \
        'PrimeCoreTests.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamPrivateAccessRebindingSourceContractTests/testFrozenV27BindsV26AndExactPhysicalReceipt' \
        'PrimeCoreTests.PrimeNativeNeuralGateHistoricalWorkerInvocationSeamSourceContractTests/testFrozenV23ContractBindsPreservedAuthoritiesAndExactSources' \
        > "$historical_expected"
    assert_final_xctest_summary \
        "$focused_log" \
        'Executed 7 tests, with 0 failures (0 unexpected)' \
        historical
    assert_xctest_execution "$focused_log" "$historical_expected" historical
    assert_no_skips "$focused_log" historical

    stage_root_pinned_metallib "$test_root"
    build_debug_compiler_canary_inputs "$test_root"
    [[ -n "$root_pinned_metallib" ]] ||
        die "root pinned metallib path is absent"

    full_log="$test_root/full.log"
    PRIME_PMHNP_COMPANION_ROOT="$companion_root" \
    PRIME_NATIVE_COMPANION_ROOT="$companion_root" \
    PRIME_TEST_PINNED_MLX_METALLIB="$root_pinned_metallib" \
    CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift test \
        --package-path "$prime_root" \
        --configuration release \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --skip-build \
        2>&1 | tee "$full_log"

    assert_final_xctest_summary \
        "$full_log" \
        'Executed 892 tests, with 1 test skipped and 0 failures (0 unexpected)' \
        root-full-xctest
    assert_exact_summary \
        "$full_log" \
        'Test run with 12 tests in 2 suites passed' \
        root-full-swift-testing
    assert_xctest_execution \
        "$full_log" \
        "$frozen_inventory_root/xctest.list" \
        root-full
    assert_exact_skip \
        "$full_log" \
        root-full \
        'PrimeCoreTests.PrimeDurableArtifactsTests/testGeneratedDescriptorPublishesSparseMultiGigabyteSafetensors' \
        'set PRIME_RUN_LARGE_ARTIFACT_TESTS=1'
    grep -F -x \
        $'passed\tPrimeCoreTests.PrimeNativeContractMigrationTests/testOptInLivePinnedCompanionTransport' \
        "$last_xctest_events" > "$test_root/native-companion-pass"
    [[ "$(wc -l < "$test_root/native-companion-pass")" -eq 1 ]] ||
        die "native companion transport did not pass exactly once"

    xunit_request="$test_root/root-swift-testing.xml"
    xunit_file="$xunit_request"
    swift_log="$test_root/swift-testing.log"
    PRIME_PMHNP_COMPANION_ROOT="$companion_root" \
    PRIME_NATIVE_COMPANION_ROOT="$companion_root" \
    PRIME_TEST_PINNED_MLX_METALLIB="$root_pinned_metallib" \
    CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift test \
        --package-path "$prime_root" \
        --configuration release \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --skip-build \
        --disable-xctest \
        --xunit-output "$xunit_request" \
        2>&1 | tee "$swift_log"
    assert_exact_summary \
        "$swift_log" \
        'Test run with 12 tests in 2 suites passed' \
        root-swift-testing-xunit
    [[ -f "$xunit_file" && ! -L "$xunit_file" ]] ||
        die "Swift Testing xUnit output is absent"
    [[ "$(xmllint --xpath 'string(/testsuites/testsuite/@tests)' "$xunit_file")" == "12" ]] ||
        die "Swift Testing xUnit test count differs"
    [[ "$(xmllint --xpath 'string(/testsuites/testsuite/@failures)' "$xunit_file")" == "0" ]] ||
        die "Swift Testing xUnit failure count differs"
    [[ "$(xmllint --xpath 'string(/testsuites/testsuite/@errors)' "$xunit_file")" == "0" ]] ||
        die "Swift Testing xUnit error count differs"
    [[ "$(xmllint --xpath 'string(/testsuites/testsuite/@skipped)' "$xunit_file")" == "0" ]] ||
        die "Swift Testing xUnit skip count differs"
    [[ "$(xmllint --xpath 'count(/testsuites/testsuite/testcase)' "$xunit_file")" == "12" ]] ||
        die "Swift Testing xUnit testcase count differs"

    xunit_ids="$test_root/swift-testing-xunit.ids"
    index=1
    while [[ "$index" -le 12 ]]; do
        class="$(
            xmllint --xpath \
                "string(/testsuites/testsuite/testcase[$index]/@classname)" \
                "$xunit_file"
        )"
        name="$(
            xmllint --xpath \
                "string(/testsuites/testsuite/testcase[$index]/@name)" \
                "$xunit_file"
        )"
        [[ -n "$class" && -n "$name" ]] ||
            die "Swift Testing xUnit testcase identity is empty"
        printf '%s/%s\n' "$class" "$name"
        index=$((index + 1))
    done | LC_ALL=C sort > "$xunit_ids"
    frozen_swift_sorted="$test_root/swift-testing.frozen.sorted"
    LC_ALL=C sort "$frozen_inventory_root/swift-testing.list" \
        > "$frozen_swift_sorted"
    cmp -s "$xunit_ids" "$frozen_swift_sorted" ||
        die "Swift Testing xUnit identities differ"

    large_expected="$test_root/large.expected"
    printf '%s\n' \
        'PrimeCoreTests.PrimeDurableArtifactsTests/testGeneratedDescriptorPublishesSparseMultiGigabyteSafetensors' \
        > "$large_expected"
    large_log="$test_root/large-artifact.log"
    PRIME_PMHNP_COMPANION_ROOT="$companion_root" \
    PRIME_NATIVE_COMPANION_ROOT="$companion_root" \
    PRIME_TEST_PINNED_MLX_METALLIB="$root_pinned_metallib" \
    PRIME_RUN_LARGE_ARTIFACT_TESTS=1 \
    CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift test \
        --package-path "$prime_root" \
        --configuration release \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --skip-build \
        --disable-swift-testing \
        --filter '^PrimeCoreTests\.PrimeDurableArtifactsTests/testGeneratedDescriptorPublishesSparseMultiGigabyteSafetensors$' \
        2>&1 | tee "$large_log"
    assert_final_xctest_summary \
        "$large_log" \
        'Executed 1 test, with 0 failures (0 unexpected)' \
        root-large-artifact
    assert_xctest_execution "$large_log" "$large_expected" root-large-artifact
    assert_no_skips "$large_log" root-large-artifact

    xctest_live="$test_root/xctest.list"
    PRIME_PMHNP_COMPANION_ROOT="$companion_root" \
    PRIME_NATIVE_COMPANION_ROOT="$companion_root" \
    PRIME_TEST_PINNED_MLX_METALLIB="$root_pinned_metallib" \
    CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift test \
        --package-path "$prime_root" \
        --configuration release \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --skip-build \
        --disable-swift-testing \
        list > "$xctest_live" 2> "$test_root/xctest-list.stderr"

    swift_live="$test_root/swift-testing.list"
    PRIME_PMHNP_COMPANION_ROOT="$companion_root" \
    PRIME_NATIVE_COMPANION_ROOT="$companion_root" \
    PRIME_TEST_PINNED_MLX_METALLIB="$root_pinned_metallib" \
    CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift test \
        --package-path "$prime_root" \
        --configuration release \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --skip-build \
        --disable-xctest \
        list > "$swift_live" 2> "$test_root/swift-testing-list.stderr"

    cmp -s "$xctest_live" "$frozen_inventory_root/xctest.list" ||
        die "live XCTest inventory bytes differ"
    cmp -s "$swift_live" "$frozen_inventory_root/swift-testing.list" ||
        die "live Swift Testing inventory bytes differ"
    assert_file_sha "$xctest_live" "$expected_xctest_sha" live-xctest
    assert_file_sha "$swift_live" "$expected_swift_testing_sha" live-swift-testing
    xctest_lines="$(wc -l < "$xctest_live")"
    xctest_bytes="$(wc -c < "$xctest_live")"
    swift_lines="$(wc -l < "$swift_live")"
    swift_bytes="$(wc -c < "$swift_live")"
    [[ "$xctest_lines" -eq 892 && "$xctest_bytes" -eq 114186 ]] ||
        die "live XCTest inventory dimensions differ"
    [[ "$swift_lines" -eq 12 && "$swift_bytes" -eq 1287 ]] ||
        die "live Swift Testing inventory dimensions differ"
}

run_nested_tests() {
    local configuration="$1"
    local nested_root="$prime_root/Tests/PrimeValidationWorkflow"
    local test_root log inventory swift_inventory lines sorted duplicates
    local release_test_id

    case "$configuration" in
        debug|release)
            ;;
        *)
            die "nested configuration must be debug or release"
            ;;
    esac

    test_root="$(
        mktemp -d "$runner_temp/prime-nested-$configuration.XXXXXX"
    )"
    test_root="$(cd "$test_root" && pwd -P)"
    prepare_swift_root "$test_root"
    log="$test_root/test.log"

    PRIME_PMHNP_COMPANION_ROOT="$companion_root" \
    CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift test \
        --package-path "$nested_root" \
        --configuration "$configuration" \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --disable-swift-testing \
        2>&1 | tee "$log"

    inventory="$test_root/xctest.list"
    PRIME_PMHNP_COMPANION_ROOT="$companion_root" \
    CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift test \
        --package-path "$nested_root" \
        --configuration "$configuration" \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --skip-build \
        --disable-swift-testing \
        list > "$inventory" 2> "$test_root/xctest-list.stderr"
    lines="$(wc -l < "$inventory")"
    [[ "$lines" -eq 95 ]] || die "nested $configuration inventory count differs"
    sorted="$test_root/xctest.sorted"
    duplicates="$test_root/xctest.duplicates"
    LC_ALL=C sort "$inventory" > "$sorted"
    uniq -d "$sorted" > "$duplicates"
    [[ ! -s "$duplicates" ]] ||
        die "nested $configuration inventory contains duplicates"

    swift_inventory="$test_root/swift-testing.list"
    PRIME_PMHNP_COMPANION_ROOT="$companion_root" \
    CLANG_MODULE_CACHE_PATH="$test_root/module-cache" \
    SWIFTPM_MODULECACHE_OVERRIDE="$test_root/module-cache" \
        swift test \
        --package-path "$nested_root" \
        --configuration "$configuration" \
        --cache-path "$test_root/cache" \
        --config-path "$test_root/config" \
        --security-path "$test_root/security" \
        --scratch-path "$test_root/build" \
        --disable-dependency-cache \
        --manifest-cache local \
        --disable-netrc \
        --disable-keychain \
        --force-resolved-versions \
        --skip-build \
        --disable-xctest \
        list > "$swift_inventory" 2> "$test_root/swift-testing-list.stderr"
    [[ ! -s "$swift_inventory" ]] ||
        die "nested $configuration unexpectedly contains Swift Testing cases"

    release_test_id='PrimeValidationWorkflowDriverCoreTests.PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/testPublicReleaseAdmissionUsesEmbeddedSourceAuthority'
    if [[ "$configuration" == "debug" ]]; then
        assert_final_xctest_summary \
            "$log" \
            'Executed 95 tests, with 1 test skipped and 0 failures (0 unexpected)' \
            nested-debug
        assert_xctest_execution "$log" "$inventory" nested-debug
        assert_exact_skip \
            "$log" \
            nested-debug \
            "$release_test_id" \
            'public embedded-source admission is Release-only'
    else
        assert_final_xctest_summary \
            "$log" \
            'Executed 95 tests, with 0 failures (0 unexpected)' \
            nested-release
        assert_xctest_execution "$log" "$inventory" nested-release
        assert_no_skips "$log" nested-release
        grep -F -x \
            $'passed\t'"$release_test_id" \
            "$last_xctest_events" > "$test_root/release-admission-pass"
        [[ "$(wc -l < "$test_root/release-admission-pass")" -eq 1 ]] ||
            die "nested Release admission did not pass exactly once"
    fi
}

assert_final_inputs() {
    local final_prime_head final_prime_tree

    final_prime_head="$(git -C "$prime_root" rev-parse HEAD)"
    final_prime_tree="$(git -C "$prime_root" rev-parse 'HEAD^{tree}')"
    [[ "$final_prime_head" == "$expected_prime_head" ]] ||
        die "Prime HEAD changed during the gate"
    [[ "$final_prime_tree" == "$prime_initial_tree" ]] ||
        die "Prime tree changed during the gate"
    assert_static_inputs
}

main() {
    local mode="${1:-}"

    case "$mode" in
        hosted-image)
            [[ "$#" -eq 1 ]] || die "hosted-image accepts no extra arguments"
            ;;
        root-release)
            [[ "$#" -eq 1 ]] || die "root-release accepts no extra arguments"
            ;;
        nested)
            [[ "$#" -eq 2 ]] || die "nested requires one configuration"
            ;;
        *)
            die "usage: prime-driver-v2-ci.sh hosted-image | root-release | nested debug|release"
            ;;
    esac

    assert_runner
    pin_companion_transport_origin
    assert_static_inputs
    configure_local_mlx_transport

    case "$mode" in
        hosted-image)
            assert_driver_target_graph
            run_driver_canaries
            ;;
        root-release)
            assert_driver_target_graph
            run_driver_canaries
            run_root_tests
            ;;
        nested)
            run_nested_tests "$2"
            ;;
    esac

    remove_mlx_rewrite
    assert_final_inputs
    trap - EXIT
    echo "prime-driver-v2-ci: $mode passed"
}

main "$@"
