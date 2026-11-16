#!/usr/bin/env bash
set -euo pipefail

# Reload Waybar after a wallpaper change. Keep wallpaper-specific accent
# logic in one place if you add it later.
if pgrep -x waybar >/dev/null 2>&1; then
	pkill -SIGUSR2 -x waybar 2>/dev/null || true
fi
