#!/usr/bin/env bash
# Symlink rizo into Typora's themes folder (macOS, Linux) for development.
# On Windows use scripts/install.ps1 instead.
# Edits in this repo show up in Typora after Themes > rizo is re-selected or Typora restarts.
# Usage: scripts/install.sh [--uninstall]
# Set TYPORA_THEMES to override the themes folder.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ITEMS=(rizo.css rizo-dark.css rizo)

case "$(uname -s)" in
  Darwin) DEFAULT_THEMES="$HOME/Library/Application Support/abnerworks.Typora/themes" ;;
  Linux)  DEFAULT_THEMES="${XDG_CONFIG_HOME:-$HOME/.config}/Typora/themes" ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "On Windows, run this from PowerShell instead: scripts\\install.ps1" >&2
    exit 1 ;;
  *)
    DEFAULT_THEMES="" ;;
esac
THEMES="${TYPORA_THEMES:-$DEFAULT_THEMES}"

if [[ -z "$THEMES" || ! -d "$THEMES" ]]; then
  echo "Typora themes folder not found: ${THEMES:-(unknown OS)}" >&2
  echo "Open Typora > Settings > Appearance > Open Theme Folder once, or set TYPORA_THEMES." >&2
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
