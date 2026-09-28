#!/usr/bin/env bash
# Refresh an existing GitHub release in place, for small fixes that don't deserve a new version:
#   1. make sure the working tree is clean and main is pushed
#   2. move the release tag to the current commit and force-push it
#   3. rebuild dist/rizo-<version>.zip
#   4. replace the zip attached to the release
#
# Usage: scripts/refresh-release.sh [version] [--yes]
#   version  defaults to the newest v* tag, e.g. 1.0.0
#   --yes    skip the confirmation prompt
#
# Needs the GitHub CLI: brew install gh && gh auth login
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

VERSION="" YES=0
for arg in "$@"; do
  case "$arg" in
    --yes|-y) YES=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) VERSION="${arg#v}" ;;
  esac
done

die() { echo "error: $*" >&2; exit 1; }

command -v gh >/dev/null || die "GitHub CLI not found. Install it with: brew install gh && gh auth login"
gh auth status >/dev/null 2>&1 || die "GitHub CLI is not logged in. Run: gh auth login"

if [[ -z "$VERSION" ]]; then
  VERSION="$(git tag --list 'v*' --sort=-v:refname | head -1)"
  VERSION="${VERSION#v}"
  [[ -n "$VERSION" ]] || die "no v* tags found; pass a version, e.g. scripts/refresh-release.sh 1.0.0"
fi
TAG="v$VERSION"
ZIP="dist/rizo-$VERSION.zip"

# 1. Clean tree, on main, main pushed
[[ -z "$(git status --porcelain)" ]] || die "you have uncommitted changes. Commit or stash them first."
BRANCH="$(git branch --show-current)"
[[ "$BRANCH" == "main" ]] || die "you're on '$BRANCH'. Switch to main first."
gh release view "$TAG" >/dev/null 2>&1 || die "no GitHub release named $TAG. Create it on GitHub first."

git fetch --quiet origin main --tags --force
HEAD_SHA="$(git rev-parse HEAD)"
BEHIND="$(git rev-list --count HEAD..origin/main)"
AHEAD="$(git rev-list --count origin/main..HEAD)"
[[ "$BEHIND" == "0" ]] || die "main is $BEHIND commit(s) behind origin/main. Pull first."
OLD_TAG_SHA="$(git rev-parse -q --verify "refs/tags/$TAG^{commit}" || echo none)"

echo "Refreshing release $TAG"
echo "  commit:   $(git log -1 --format='%h %s')"
[[ "$AHEAD" != "0" ]] && echo "  push:     main is $AHEAD commit(s) ahead of origin, will push it"
if [[ "$OLD_TAG_SHA" == "$HEAD_SHA" ]]; then
  echo "  tag:      $TAG already points here"
else
  echo "  tag:      move $TAG ${OLD_TAG_SHA:0:7} -> ${HEAD_SHA:0:7} and force-push"
fi
echo "  zip:      rebuild $ZIP and replace it on the release"

if [[ "$YES" != "1" ]]; then
  read -r -p "Continue? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || { echo "aborted"; exit 1; }
fi

# 1b. Push main so the tag never points at an unpushed commit, and links to main (the gallery post screenshot) are current
if [[ "$AHEAD" != "0" ]]; then
  git push origin main
fi

# 2. Move and push the tag
if [[ "$OLD_TAG_SHA" != "$HEAD_SHA" ]]; then
  git tag -f "$TAG" >/dev/null
  git push -f origin "refs/tags/$TAG"
fi

# 3. Rebuild the zip
scripts/package.sh "$VERSION"

# 4. Replace the asset, then check GitHub has the new one
gh release upload "$TAG" "$ZIP" --clobber
LOCAL_SIZE="$(wc -c < "$ZIP" | tr -d ' ')"
REMOTE_SIZE="$(gh release view "$TAG" --json assets --jq ".assets[] | select(.name == \"rizo-$VERSION.zip\") | .size")"
[[ "$LOCAL_SIZE" == "$REMOTE_SIZE" ]] || die "uploaded asset size ($REMOTE_SIZE) doesn't match local zip ($LOCAL_SIZE)"

echo "done: $TAG now points at ${HEAD_SHA:0:7}, rizo-$VERSION.zip replaced ($LOCAL_SIZE bytes)"
echo "      $(gh release view "$TAG" --json url --jq .url)"
