#!/usr/bin/env bash
set -euo pipefail

# Lock before suspending. Suspending first can expose the desktop on wake.
if ! pgrep -x hyprlock >/dev/null 2>&1; then
	if ! command -v hyprlock >/dev/null 2>&1; then
		notify-send -u critical -a "Lid" "hyprlock is not installed; refusing to suspend."
		exit 1
	fi
	hyprlock --immediate-render &
fi

# Give the compositor time to map the lock surface before suspending.
sleep 1.5

if ! pgrep -x hyprlock >/dev/null 2>&1; then
	notify-send -u critical -a "Lid" "hyprlock failed to start; refusing to suspend."
	exit 1
fi

systemctl suspend
