#!/usr/bin/env bash
set -euo pipefail

# Restart the portals used for screen sharing and screen capture.
# Prefer systemd user units; fall back to starting the binaries directly.
if systemctl --user cat xdg-desktop-portal-hyprland.service >/dev/null 2>&1; then
	systemctl --user restart xdg-desktop-portal-hyprland.service
	systemctl --user restart xdg-desktop-portal.service
else
	pkill -x xdg-desktop-portal-hyprland 2>/dev/null || true
	pkill -x xdg-desktop-portal-wlr 2>/dev/null || true
	pkill -x xdg-desktop-portal 2>/dev/null || true

	/usr/lib/xdg-desktop-portal-hyprland >/dev/null 2>&1 &
	sleep 2
	/usr/lib/xdg-desktop-portal >/dev/null 2>&1 &
fi
