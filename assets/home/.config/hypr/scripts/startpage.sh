#!/usr/bin/env bash
set -euo pipefail

# Serve a local start page. Override the directory or port with
# STARTPAGE_DIR / STARTPAGE_PORT.
page_dir="${STARTPAGE_DIR:-$HOME/Projects/startpage}"
port="${STARTPAGE_PORT:-10002}"

if [[ ! -d "$page_dir" ]]; then
	printf 'startpage: directory not found: %s\n' "$page_dir" >&2
	exit 1
fi

cd "$page_dir"
exec python -m http.server "$port"
