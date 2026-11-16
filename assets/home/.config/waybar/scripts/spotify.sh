#!/usr/bin/env bash
set -euo pipefail

# Waybar JSON output for Spotify using playerctl.
# Requires: playerctl.

player="spotify"
status="$(playerctl -p "$player" status 2>/dev/null || true)"

if [[ -z "$status" ]]; then
	printf '{"text":""}\n'
	exit 0
fi

artist="$(playerctl -p "$player" metadata artist 2>/dev/null || true)"
title="$(playerctl -p "$player" metadata title 2>/dev/null || true)"
album="$(playerctl -p "$player" metadata album 2>/dev/null || true)"

json_escape() {
	printf '%s' "$1" | tr '\n' ' ' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

if [[ -n "$artist" && -n "$title" ]]; then
	track="$artist - $title"
else
	track="$title"
fi

if [[ "$status" == "Playing" ]]; then
	text="$(json_escape "$track") <span color='#1db954'></span>"
	class="playing"
else
	text=" $(json_escape "$track") <span color='#1db954'></span>"
	class="paused"
fi

tooltip="$(json_escape "$status${album:+ · $album}")"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
