#!/bin/bash

set -euo pipefail

if [[ "$#" -ne 4 ]]; then
    echo "usage: prime-ci-checkout-pinned.sh OWNER/REPO SHA DESTINATION SUBMODULE_MODE" >&2
    exit 2
fi

repository="$1"
revision="$2"
destination="$3"
submodule_mode="$4"
checkout_token="${CHECKOUT_TOKEN:-}"

[[ "$repository" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || {
    echo "refuse: invalid repository identity" >&2
    exit 2
}
[[ "$revision" =~ ^[0-9a-f]{40}$ ]] || {
    echo "refuse: revision must be an exact lowercase commit SHA" >&2
    exit 2
}
[[ "$destination" =~ ^[A-Za-z0-9_.-]+$ ]] || {
    echo "refuse: destination must be one new top-level directory" >&2
    exit 2
}
case "$submodule_mode" in
    none|recursive) ;;
    *)
        echo "refuse: unsupported submodule mode" >&2
        exit 2
        ;;
esac
[[ -n "$checkout_token" ]] || {
    echo "refuse: CHECKOUT_TOKEN is required" >&2
    exit 2
}
[[ ! -e "$destination" && ! -L "$destination" ]] || {
    echo "refuse: checkout destination already exists" >&2
    exit 2
}

canonical_origin="https://github.com/${repository}"
credential_base="https://x-access-token:${checkout_token}@github.com/"

git init "$destination"
git -C "$destination" remote add origin "$canonical_origin"

# The credential rewrite exists only in this process environment. The stored
# origin and every submodule origin remain canonical and credential-free.
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="url.${credential_base}.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/"

git -C "$destination" fetch \
    --depth=1 \
    --no-tags \
    --no-write-fetch-head \
    origin \
    "$revision"
git -C "$destination" checkout --detach "$revision"

if [[ "$submodule_mode" == "recursive" ]]; then
    git -C "$destination" submodule sync --recursive
    git -C "$destination" submodule update \
        --init \
        --recursive \
        --depth=1
fi

unset GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0

[[ "$(git -C "$destination" rev-parse HEAD)" == "$revision" ]] || {
    echo "refuse: checkout HEAD differs from the requested revision" >&2
    exit 2
}
[[ "$(git -C "$destination" remote get-url origin)" == "$canonical_origin" ]] || {
    echo "refuse: checkout origin is not canonical" >&2
    exit 2
}
[[ -z "$(git -C "$destination" status --porcelain=v1 --untracked-files=all)" ]] || {
    echo "refuse: checkout is dirty" >&2
    exit 2
}

while IFS= read -r config_file; do
    if grep -Fq -- "$checkout_token" "$config_file"; then
        echo "refuse: checkout credential persisted in Git configuration" >&2
        exit 2
    fi
done < <(find "$destination/.git" -type f -name config -print)

echo "OK: pinned checkout ${repository}@${revision}"
