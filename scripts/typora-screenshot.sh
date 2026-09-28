#!/usr/bin/env bash
# Capture the gallery thumbnail from a real Typora window, in both themes:
#   1. open samples/sample.md in Typora and size the window to 1290x1145
#   2. for Rizo and Rizo Dark: switch theme, capture the window (no shadow)
#   3. crop the top-left 750x600 (sidebar + title) and scale it to 250x200
#   4. build two combined thumbnails:
#        split    two narrow windows side by side, light on the left, dark on the right
#        cascade  two small overlapping windows, dark behind, light in front
#   5. switch Typora back to the theme it was on
#
# Writes dist/gallery/rizo-light.png, rizo-dark.png, rizo-split.png and rizo-cascade.png,
# plus the full-window captures as rizo-light-full.png and rizo-dark-full.png.
#
# Usage: scripts/typora-screenshot.sh [--use light|dark|split|cascade]
#   --use  also copy that thumbnail over dist/gallery/rizo.png (the one the gallery post uses)
#
# Needs ImageMagick (brew install imagemagick), and your terminal needs Accessibility
# and Screen Recording permission (System Settings > Privacy & Security).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

USE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --use) USE="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "error: unknown argument $1" >&2; exit 1 ;;
  esac
done
[[ -z "$USE" || "$USE" =~ ^(light|dark|split|cascade)$ ]] || { echo "error: --use takes light, dark, split or cascade" >&2; exit 1; }

die() { echo "error: $*" >&2; exit 1; }
command -v magick >/dev/null || die "ImageMagick not found. Install it with: brew install imagemagick"

OUT="dist/gallery"
SAMPLE="$REPO/samples/sample.md"
WIN_W=1290 WIN_H=1145        # window size, in points
CROP_W=750 CROP_H=600        # top-left region to keep, in points (5:4, same as 250x200)
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"

menu() { osascript -e "tell application \"System Events\" to tell process \"Typora\" to $1"; }

# 1. Open the sample, bring Typora forward, size the window, scroll to the top
open -a Typora "$SAMPLE"
sleep 2
osascript -e 'tell application "Typora" to activate'
menu "set size of window 1 to {$WIN_W, $WIN_H}" >/dev/null \
  || die "couldn't control Typora. Give your terminal Accessibility permission in System Settings."
menu 'key code 126 using command down'   # cmd-up: top of document
sleep 0.5

# Remember the current theme so we can put it back
ORIG_THEME="$(osascript -e '
  tell application "System Events" to tell process "Typora"
    repeat with m in (menu items of menu "Themes" of menu bar 1)
      if value of attribute "AXMenuItemMarkChar" of m is not missing value then return name of m
    end repeat
  end tell' 2>/dev/null || true)"

# Window id of the sample.md window, for screencapture -l
cat > "$TMP/winid.swift" <<'EOF'
import CoreGraphics
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as! [[String: Any]]
for w in list where (w["kCGWindowOwnerName"] as? String) == "Typora" && (w["kCGWindowLayer"] as? Int) == 0 {
  if (w["kCGWindowName"] as? String ?? "").hasPrefix("sample") { print(w["kCGWindowNumber"]!); break }
}
EOF
WIN_ID="$(swift "$TMP/winid.swift" 2>/dev/null)"
[[ -n "$WIN_ID" ]] || die "couldn't find the sample.md window in Typora"

# 2-3. Capture and crop each theme
capture() {  # capture <menu name> <label>
  menu "click menu item \"$1\" of menu \"Themes\" of menu bar 1" >/dev/null
  sleep 1.5
  screencapture -x -o -l "$WIN_ID" "$OUT/rizo-$2-full.png" \
    || die "screencapture failed. Give your terminal Screen Recording permission in System Settings."
  # Retina captures are 2x the window's point size
  local px
  px="$(magick identify -format %w "$OUT/rizo-$2-full.png")"
  SCALE=$(( (px + WIN_W / 2) / WIN_W ))
  magick "$OUT/rizo-$2-full.png" -crop "$((CROP_W * SCALE))x$((CROP_H * SCALE))+0+0" +repage \
    -background white -flatten -resize '250x200!' "$OUT/rizo-$2.png"
  echo "  $2: $OUT/rizo-$2.png"
}
echo "Capturing Typora window $WIN_ID"
capture "Rizo" light
capture "Rizo Dark" dark

# 4. Combined thumbnails, cut from the full captures so each window keeps its own sidebar
full() { magick "$OUT/rizo-$1-full.png" -background white -flatten -crop "$2" +repage -resize "$3" "$TMP/$1.png"; }

# Split: each half is the top-left 560x896 of a window (sidebar + title), 2px ink gap between
full light "$((560 * SCALE))x$((896 * SCALE))+0+0" '124x200!'
full dark  "$((560 * SCALE))x$((896 * SCALE))+0+0" '124x200!'
magick -size 250x200 xc:'#1D1A2C' "$TMP/light.png" -geometry +0+0 -composite \
  "$TMP/dark.png" -geometry +126+0 -composite "$OUT/rizo-split.png"
echo "  split: $OUT/rizo-split.png"

# Cascade: the top 1290x1030 of each window at 180x144, on paper, light outlined in ink
full light "$((WIN_W * SCALE))x$((1030 * SCALE))+0+0" '180x144!'
full dark  "$((WIN_W * SCALE))x$((1030 * SCALE))+0+0" '180x144!'
magick -size 250x200 xc:'#E9E1D0' "$TMP/dark.png" -geometry +62+12 -composite \
  \( "$TMP/light.png" -bordercolor '#1D1A2C' -border 1 \) -geometry +8+46 -composite "$OUT/rizo-cascade.png"
echo "  cascade: $OUT/rizo-cascade.png"

# 5. Restore the theme
if [[ -n "$ORIG_THEME" && "$ORIG_THEME" != "Rizo Dark" ]]; then
  menu "click menu item \"$ORIG_THEME\" of menu \"Themes\" of menu bar 1" >/dev/null
fi

if [[ -n "$USE" ]]; then
  cp "$OUT/rizo-$USE.png" "$OUT/rizo.png"
  echo "copied rizo-$USE.png to $OUT/rizo.png"
fi
