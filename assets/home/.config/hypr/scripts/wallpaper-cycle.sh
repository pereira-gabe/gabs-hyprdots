#!/usr/bin/env bash

set -euo pipefail

WALL_DIR="$HOME/.config/hypr/wallpapers"
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/hypr/last-wallpaper"
RESTART="$HOME/.config/hypr/wallpaper-restart.sh"

current=""
if pgrep -x swaybg >/dev/null 2>&1; then
    current="$(pgrep -a -x swaybg | sed -nE 's/.* -i ([^ ]+).*/\1/p' | head -n1)"
fi
if [[ -z "$current" && -s "$STATE_FILE" ]]; then
    current="$(<"$STATE_FILE")"
fi
current="${current/#\~/$HOME}"

mapfile -t walls < <(
    find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
        -o -iname '*.webp' -o -iname '*.gif' \) | sort
)

if [[ ${#walls[@]} -eq 0 ]]; then
    printf 'wallpaper-cycle: no wallpaper found in %s\n' "$WALL_DIR" >&2
    exit 1
fi

next=0
for i in "${!walls[@]}"; do
    if [[ "${walls[$i]}" == "$current" ]]; then
        next=$(((i + 1) % ${#walls[@]}))
        break
    fi
done

exec "$RESTART" "${walls[$next]}"
