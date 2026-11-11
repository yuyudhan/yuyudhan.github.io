#!/usr/bin/env bash
# Publishes each app's installer at https://yuyudhan.github.io/<app>/install, so that
#   curl -fsSL https://yuyudhan.github.io/<app>/install | sh
# runs the install.sh attached to that app's latest GitHub release, byte for byte.
#
# For every app it downloads releases/latest/download/install.sh and the release's SHA256SUMS,
# checks the script's SHA-256 against its SHA256SUMS line, that it is a POSIX sh script
# (`#!/bin/sh`, since the one-liner pipes it into sh) and that `sh -n` parses it, and only then
# writes it to <app>/install. Any failure stops the run before anything is written, so the site
# keeps serving the previous good installer. The sync-installers workflow runs this on a
# schedule and on demand and commits what changed.
#
# Usage: .github/scripts/sync-installers.sh [SITE_DIR]   (default: the repository root)
set -euo pipefail

site="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
apps=(nomouse quickhop)

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

for app in "${apps[@]}"; do
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
    if [ "$(head -n 1 "${work}/${app}/install")" != "#!/bin/sh" ]; then
        echo "::error::${app}: the latest release's install.sh is not a #!/bin/sh script; not publishing it" >&2
        exit 1
    fi
    sh -n "${work}/${app}/install"
    echo "${app}: install.sh ${actual}"
done

for app in "${apps[@]}"; do
    mkdir -p "${site}/${app}"
    install -m 644 "${work}/${app}/install" "${site}/${app}/install"
done
