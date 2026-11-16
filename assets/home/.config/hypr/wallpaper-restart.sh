#!/usr/bin/env bash
set -euo pipefail

# Restart swaybg with the requested wallpaper, the last wallpaper, or the
# first image found in the wallpaper directory. Falls back to a solid color
# when no image is available.

WALL_DIR="${WALLPAPER_DIR:-$HOME/.config/hypr/wallpapers}"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
STATE_FILE="$STATE_DIR/last-wallpaper"
MODE="${WALLPAPER_MODE:-fill}"

# Recover the Wayland session when run from a cron job or SSH shell.
if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
	for sock in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/wayland-*; do
		[[ -S "$sock" ]] || continue
		export WAYLAND_DISPLAY="${sock##*/}"
		break
	done
fi

first_wallpaper() {
	find "$WALL_DIR" -maxdepth 1 -type f \
		\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
		-o -iname '*.webp' -o -iname '*.gif' \) 2>/dev/null |
		sort | head -n1 || true
}

WALL="${1:-}"
if [[ -z "$WALL" && -s "$STATE_FILE" ]]; then
	WALL="$(<"$STATE_FILE")"
fi
if [[ -z "$WALL" || ! -f "$WALL" ]]; then
	WALL="$(first_wallpaper)"
fi
WALL="${WALL/#\~/$HOME}"

# Stop the current instance and wait for it to release the output.
pkill -x swaybg 2>/dev/null || true
for _ in {1..20}; do
	pgrep -x swaybg >/dev/null 2>&1 || break
	sleep 0.1
done
pkill -9 -x swaybg 2>/dev/null || true

# Detach from the calling terminal or session.
if [[ -n "$WALL" && -f "$WALL" ]]; then
	setsid -f swaybg -o '*' -i "$WALL" -m "$MODE" >/dev/null 2>&1
	mkdir -p "$STATE_DIR"
	printf '%s\n' "$WALL" >"$STATE_FILE"
	"$HOME/.config/waybar/scripts/wallpaper-colors.sh" "$WALL" || true
	printf 'wallpaper-restart: %s (%s)\n' "$WALL" "$MODE"
else
	setsid -f swaybg -o '*' -c '#0f161e' >/dev/null 2>&1
	printf 'wallpaper-restart: no wallpaper found; using solid color\n' >&2
fi
