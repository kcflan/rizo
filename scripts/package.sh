#!/usr/bin/env bash
# Build dist/rizo-<version>.zip for a GitHub release: the two theme files, the rizo/ folder, LICENSE and README.
# Usage: scripts/package.sh 1.0.0
set -euo pipefail

VERSION="${1:?usage: scripts/package.sh <version>}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/dist/rizo-$VERSION.zip"

mkdir -p "$REPO/dist"
rm -f "$OUT"
cd "$REPO"
zip -rq "$OUT" rizo.css rizo-dark.css rizo LICENSE README.md -x '*.DS_Store'
echo "$OUT ($(du -h "$OUT" | cut -f1))"
