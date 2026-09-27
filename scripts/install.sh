#!/usr/bin/env bash
# Symlink rizo into Typora's themes folder (macOS) for development.
# Edits in this repo show up in Typora after Themes > rizo is re-selected or Typora restarts.
# Usage: scripts/install.sh [--uninstall]
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEMES="${TYPORA_THEMES:-$HOME/Library/Application Support/abnerworks.Typora/themes}"
ITEMS=(rizo.css rizo-dark.css rizo)

if [[ ! -d "$THEMES" ]]; then
  echo "Typora themes folder not found: $THEMES" >&2
  echo "Open Typora > Preferences > Appearance > Open Theme Folder once, or set TYPORA_THEMES." >&2
  exit 1
fi

for item in "${ITEMS[@]}"; do
  target="$THEMES/$item"
  if [[ "${1:-}" == "--uninstall" ]]; then
    if [[ -L "$target" ]]; then rm "$target"; echo "removed $target"; fi
    continue
  fi
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "refusing to replace a real file or folder: $target (move it first)" >&2
    exit 1
  fi
  ln -sfn "$REPO/$item" "$target"
  echo "linked $target -> $REPO/$item"
done
