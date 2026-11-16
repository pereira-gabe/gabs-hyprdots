#!/usr/bin/env bash
set -euo pipefail

picker="$(command -v hyprpicker || true)"
if [[ -z "$picker" ]]; then
	picker="$HOME/.config/hypr/scripts/hyprpicker"
fi

color="$("$picker" --format hex | tr -d '\n')"
[[ -n "$color" ]] || exit 0

printf '%s' "$color" | wl-copy

preview="$(mktemp --suffix=.png)"
trap 'rm -f "$preview"' EXIT

if command -v magick >/dev/null 2>&1; then
	magick -size 100x100 "xc:${color}" "$preview"
else
	convert -size 100x100 "xc:${color}" "$preview"
fi

dunstify --icon="$preview" "$color" "Copied to clipboard"
