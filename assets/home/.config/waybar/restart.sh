#!/usr/bin/env bash

set -u

WAYBAR_BIN="${WAYBAR_BIN:-waybar}"


if [ "${1:-}" = "--reload" ]; then
  if pgrep -x waybar >/dev/null 2>&1; then
    pkill -SIGUSR2 -x waybar
    exit 0
  fi
  echo "waybar not running; initializing..." >&2
fi

pkill -x waybar 2>/dev/null

for _ in $(seq 1 20); do
  pgrep -x waybar >/dev/null 2>&1 || break
  sleep 0.1
done

pkill -9 -x waybar 2>/dev/null

nohup "$WAYBAR_BIN" >/dev/null 2>&1 &
disown 2>/dev/null || true

exit 0
