#!/usr/bin/env bash
#
# update-roc.sh — pin the latest (or a specific) roc nightly for flake.nix.
#
# Usage:
#   ./update-roc.sh              # pin the latest nightly
#   ./update-roc.sh <tag_name>   # pin a specific release, e.g. nightly-2026-August-01-1c1cecc
#
# Then rebuild the dev shell:
#   nix develop            # or: nix flake check
#
# Requires: curl, jq, nix. Writes roc-pin.json next to this script.
# Only the x86_64-linux asset is pinned (matches flake.nix).

set -euo pipefail

repo="roc-lang/nightlies"
asset_glob='roc_nightly-linux_x86_64-*.tar.gz'
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$here/roc-pin.json"

if [ "$#" -ge 1 ]; then
  api="https://api.github.com/repos/$repo/releases/tags/$1"
else
  api="https://api.github.com/repos/$repo/releases/latest"
fi

echo "Fetching release metadata from $api ..." >&2
release="$(curl -fsSL -H 'Accept: application/vnd.github+json' "$api")"

version="$(printf '%s' "$release" | jq -r '.tag_name')"
url="$(printf '%s' "$release" \
  | jq -r --arg glob "$asset_glob" \
      '.assets[] | select(.name | test($glob | gsub("\\*"; ".*"))) | .browser_download_url' \
  | head -n1)"

if [ -z "$url" ] || [ "$url" = "null" ]; then
  echo "error: no asset matching '$asset_glob' found in release '$version'" >&2
  exit 1
fi

echo "Prefetching $url ..." >&2
sha256="$(nix store prefetch-file --json "$url" | jq -r '.hash')"

jq -n --arg version "$version" --arg url "$url" --arg sha256 "$sha256" \
  '{version: $version, url: $url, sha256: $sha256}' > "$out"

echo "Wrote $out:" >&2
cat "$out" >&2
