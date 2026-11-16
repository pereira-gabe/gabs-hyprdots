#!/usr/bin/env bash
set -euo pipefail

# Save an area screenshot and copy it to the clipboard.
# Uses grimblast when available and falls back to grim + slurp.
out_dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$out_dir"
file="$out_dir/$(date +%s)_screenshot.png"

if command -v grimblast >/dev/null 2>&1; then
	grimblast --notify copysave area "$file"
else
	geometry="$(slurp)" || exit 0
	grim -g "$geometry" "$file"
	wl-copy <"$file"
	notify-send -a "Screenshot" "Saved to $file"
fi
