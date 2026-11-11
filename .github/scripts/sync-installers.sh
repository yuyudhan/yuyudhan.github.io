#!/usr/bin/env bash
# Publishes each project's installer at https://yuyudhan.github.io/<app>/install, so that
#   curl -fsSL https://yuyudhan.github.io/<app>/install | sh
# runs the install.sh of that project's latest GitHub release, byte for byte.
#
# Release-asset apps (nomouse, quickhop, simple-voice) attach install.sh and SHA256SUMS to every
# release: the script downloads both from releases/latest/download and requires install.sh's
# SHA-256 to match its SHA256SUMS line.
# Tagged-source apps (toli) ship install.sh in the repository: the script finds the latest
# release's tag (github.com/<repo>/releases/latest redirects to it), downloads install.sh at that
# tag from raw.githubusercontent.com, and requires its git blob hash to match the blob GitHub's
# API reports for install.sh at that tag.
# Every installer must also be a POSIX sh script (`#!/bin/sh`, since the one-liner pipes it into
# sh) that `sh -n` parses. Any failure stops the run before anything is written, so the site
# keeps serving the previous good installers. The sync-installers workflow runs this on a
# schedule and on demand and commits what changed.
#
# Usage: .github/scripts/sync-installers.sh [SITE_DIR]   (default: the repository root)
#   GH_TOKEN, when set, authenticates the GitHub API request (the workflow passes its token).
set -euo pipefail

site="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
release_apps=(nomouse quickhop simple-voice)
tag_apps=(toli)

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fetch() {
    curl --fail --silent --show-error --location --retry 5 --retry-delay 2 --connect-timeout 15 \
        --output "$2" "$1"
}

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d ' ' -f 1
    else
        shasum -a 256 "$1" | cut -d ' ' -f 1
    fi
}

# check_posix_sh APP FILE: the installer the one-liner pipes into sh must be sh.
check_posix_sh() {
    if [ "$(head -n 1 "$2")" != "#!/bin/sh" ]; then
        echo "::error::$1: the latest release's install.sh is not a #!/bin/sh script; not publishing it" >&2
        exit 1
    fi
    sh -n "$2"
}

for app in "${release_apps[@]}"; do
    release="https://github.com/yuyudhan/${app}/releases/latest/download"
    mkdir -p "${work}/${app}"
    fetch "${release}/install.sh" "${work}/${app}/install"
    fetch "${release}/SHA256SUMS" "${work}/${app}/SHA256SUMS"
    expected="$(awk '$2 == "install.sh" || $2 == "*install.sh" { print $1 }' "${work}/${app}/SHA256SUMS")"
    actual="$(sha256_of "${work}/${app}/install")"
    if [ -z "$expected" ]; then
        echo "::error::${app}: SHA256SUMS of the latest release has no install.sh line" >&2
        exit 1
    fi
    if [ "$expected" != "$actual" ]; then
        echo "::error::${app}: install.sh checksum mismatch (SHA256SUMS ${expected}, download ${actual})" >&2
        exit 1
    fi
    check_posix_sh "$app" "${work}/${app}/install"
    echo "${app}: install.sh ${actual}"
done

for app in "${tag_apps[@]}"; do
    repo="yuyudhan/${app}"
    mkdir -p "${work}/${app}"
    latest="$(curl --fail --silent --show-error --location --retry 5 --retry-delay 2 --connect-timeout 15 \
        --output /dev/null --write-out '%{url_effective}' "https://github.com/${repo}/releases/latest")"
    tag="${latest##*/}"
    if ! [[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "::error::${app}: the latest release resolved to '${latest}', not a vX.Y.Z tag" >&2
        exit 1
    fi
    fetch "https://raw.githubusercontent.com/${repo}/${tag}/install.sh" "${work}/${app}/install"
    auth=()
    if [ -n "${GH_TOKEN:-}" ]; then
        auth=(--header "Authorization: Bearer ${GH_TOKEN}")
    fi
    curl --fail --silent --show-error --location --retry 5 --retry-delay 2 --connect-timeout 15 \
        "${auth[@]}" --header "Accept: application/vnd.github+json" \
        --output "${work}/${app}/contents.json" \
        "https://api.github.com/repos/${repo}/contents/install.sh?ref=${tag}"
    expected="$(jq -r '.sha // empty' "${work}/${app}/contents.json")"
    actual="$(git hash-object "${work}/${app}/install")"
    if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
        echo "::error::${app}: install.sh at ${tag} does not match GitHub's blob (API ${expected:-none}, download ${actual})" >&2
        exit 1
    fi
    check_posix_sh "$app" "${work}/${app}/install"
    echo "${app}: install.sh at ${tag}, sha256 $(sha256_of "${work}/${app}/install")"
done

for app in "${release_apps[@]}" "${tag_apps[@]}"; do
    mkdir -p "${site}/${app}"
    install -m 644 "${work}/${app}/install" "${site}/${app}/install"
done
