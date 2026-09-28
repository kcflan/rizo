#!/usr/bin/env bash
# Export a document to PDF from Typora in both themes, to check print output:
#   1. open the document (default samples/sample.md) in Typora
#   2. for Rizo and Rizo Dark: switch theme, File > Export > PDF into dist/pdf/
#   3. render every page to PNG and put them side by side in one contact sheet per theme
#   4. switch Typora back to the theme it was on
#
# Writes dist/pdf/rizo-light.pdf and rizo-dark.pdf, plus rizo-light-pages.png and
# rizo-dark-pages.png (needs pdftoppm from poppler for the PNGs: brew install poppler).
#
# Usage: scripts/typora-pdf.sh [file.md]
#
# Needs ImageMagick, and your terminal needs Accessibility permission (System Settings >
# Privacy & Security). Don't touch the keyboard while it runs: it types into the Save dialog.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

case "${1:-}" in -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac
DOC="$(cd "$(dirname "${1:-samples/sample.md}")" && pwd)/$(basename "${1:-samples/sample.md}")"
[[ -f "$DOC" ]] || { echo "error: no such file $DOC" >&2; exit 1; }

die() { echo "error: $*" >&2; exit 1; }
command -v magick >/dev/null || die "ImageMagick not found. Install it with: brew install imagemagick"

OUT="$REPO/dist/pdf"
mkdir -p "$OUT"

menu() { osascript -e "tell application \"System Events\" to tell process \"Typora\" to $1"; }

open -a Typora "$DOC"
sleep 2
osascript -e 'tell application "Typora" to activate'
menu 'get name of window 1' >/dev/null \
  || die "couldn't control Typora. Give your terminal Accessibility permission in System Settings."

ORIG_THEME="$(osascript -e '
  tell application "System Events" to tell process "Typora"
    repeat with m in (menu items of menu "Themes" of menu bar 1)
      if value of attribute "AXMenuItemMarkChar" of m is not missing value then return name of m
    end repeat
  end tell' 2>/dev/null || true)"

export_pdf() {  # export_pdf <menu name> <label>
  local pdf="$OUT/rizo-$2.pdf"
  rm -f "$pdf"
  menu "click menu item \"$1\" of menu \"Themes\" of menu bar 1" >/dev/null
  sleep 1.5
  osascript -e 'tell application "Typora" to activate'
  menu 'click menu item "PDF" of menu 1 of menu item "Export" of menu "File" of menu bar 1' >/dev/null
  sleep 1.5
  # Typing "/" in the Save As field opens Go To Folder; type the rest of the folder, then the name
  osascript - "$OUT" "rizo-$2.pdf" <<'EOF' >/dev/null
on run argv
  tell application "System Events" to tell process "Typora"
    set sg to splitter group 1 of sheet 1 of window 1
    set focused of text field "Save As:" of sg to true
    keystroke "a" using command down
    keystroke "/"
    delay 1
    keystroke (text 2 thru -1 of (item 1 of argv))
    delay 1
    key code 36
    delay 1
    set value of text field "Save As:" of sg to (item 2 of argv)
    delay 0.3
    click button "Save" of sg
  end tell
end run
EOF
  local i
  for i in $(seq 1 60); do
    [[ -s "$pdf" ]] && break
    sleep 1
  done
  [[ -s "$pdf" ]] || die "Typora didn't write $pdf. Check for an open dialog in Typora."
  sleep 1  # let Typora finish writing
  echo "  $2: $pdf"

  if command -v pdftoppm >/dev/null; then
    local tmp; tmp="$(mktemp -d)"
    pdftoppm -r 60 -png "$pdf" "$tmp/p"
    magick "$tmp"/p-*.png -bordercolor '#888' -border 1 +append "$OUT/rizo-$2-pages.png"
    rm -rf "$tmp"
    echo "         $OUT/rizo-$2-pages.png"
  fi
}

echo "Exporting $(basename "$DOC")"
export_pdf "Rizo" light
export_pdf "Rizo Dark" dark

if [[ -n "$ORIG_THEME" && "$ORIG_THEME" != "Rizo Dark" ]]; then
  menu "click menu item \"$ORIG_THEME\" of menu \"Themes\" of menu bar 1" >/dev/null
fi
