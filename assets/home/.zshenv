# Environment shared by all zsh processes.
if [[ ":$PATH:" != *":$HOME/.platformio/penv/bin:"* ]]; then
	export PATH="$HOME/.platformio/penv/bin:$PATH"
fi
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R}"
export TERMINAL=kitty
