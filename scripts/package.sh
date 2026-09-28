#!/usr/bin/env bash
# Build dist/rizo.zip for a GitHub release: the two theme files, the rizo/ folder, LICENSE and README.
# The zipped README gets absolute GitHub URLs for its images and links, since docs/ isn't shipped.
# Images are pinned to the v<version> tag, so push that tag before publishing the release.
# The zip has no version in its name, so releases/latest/download/rizo.zip always gets the newest one.
# Usage: scripts/package.sh 1.0.0
set -euo pipefail

VERSION="${1:?usage: scripts/package.sh <version>}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/dist/rizo.zip"

mkdir -p "$REPO/dist"
rm -f "$OUT"
cd "$REPO"
zip -rq "$OUT" rizo.css rizo-dark.css rizo LICENSE -x '*.DS_Store'

GITHUB="https://github.com/kcflan/rizo"
RAW="https://raw.githubusercontent.com/kcflan/rizo/v$VERSION"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT
sed -e "s#\"docs/#\"$RAW/docs/#g" -e "s#(docs/#($RAW/docs/#g" -e "s#\.\./\.\./releases#$GITHUB/releases#g" \
  README.md > "$STAGE/README.md"
(cd "$STAGE" && zip -q "$OUT" README.md)
echo "$OUT ($(du -h "$OUT" | cut -f1))"
