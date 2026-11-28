#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$DOTFILES_DIR/assets/home"
BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

INSTALL_PACKAGES=0
RELOAD=0
DRY_RUN=0
FORCE_CONFIGS=0
SET_SHELL=0

usage() {
	cat <<'EOF'
Usage: ./install.sh [options]

Options:
  -p, --packages   Install the packages listed in packages/ (pacman + yay).
  -r, --reload     Reload Hyprland, Waybar and Dunst after installing.
  -s, --shell      Set zsh as the login shell for the current user.
  -f, --force      Replace ~/.gitconfig when it already exists.
  -n, --dry-run    Print the actions without changing files.
  -h, --help       Show this help.

Existing files are backed up under
$XDG_STATE_HOME/dotfiles-backups/<timestamp> (default: ~/.local/state).
EOF
}

while (($#)); do
	case "$1" in
	-p | --packages) INSTALL_PACKAGES=1 ;;
	-r | --reload) RELOAD=1 ;;
	-s | --shell) SET_SHELL=1 ;;
	-f | --force) FORCE_CONFIGS=1 ;;
	-n | --dry-run) DRY_RUN=1 ;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		printf 'install.sh: unknown option: %s\n' "$1" >&2
		usage >&2
		exit 2
		;;
	esac
	shift
done

if [[ $EUID -eq 0 ]]; then
	printf 'install.sh: run as your user, not root.\n' >&2
	exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
	printf 'install.sh: missing directory: %s\n' "$SOURCE_DIR" >&2
	exit 1
fi

if [[ -r /etc/os-release ]]; then
	# shellcheck disable=SC1091
	. /etc/os-release
	case " ${ID:-} ${ID_LIKE:-} " in
	*" arch "*) ;;
	*) printf 'install.sh: warning: this installer targets Arch Linux.\n' >&2 ;;
	esac
fi

run() {
	if ((DRY_RUN)); then
		printf 'dry-run:'
		printf ' %q' "$@"
		printf '\n'
	else
		"$@"
	fi
}

backup_path() {
	local dest="$1"
	local rel="${dest#"$HOME"/}"
	local backup="$BACKUP_DIR/$rel"
	mkdir -p "$(dirname "$backup")"
	cp -a "$dest" "$backup"
}

install_file() {
	local src="$1"
	local dest="$2"
	local rel="${dest#"$HOME"/}"

	if [[ -e "$dest" ]]; then
		if [[ "$rel" == ".gitconfig" && $FORCE_CONFIGS -eq 0 ]]; then
			printf 'skip %s (already exists; use --force to replace)\n' "$rel"
			return 0
		fi
		if ((DRY_RUN)); then
			printf 'backup %s\n' "$rel"
		else
			backup_path "$dest"
		fi
	fi

	if ((DRY_RUN)); then
		printf 'install %s\n' "$rel"
		return 0
	fi

	mkdir -p "$(dirname "$dest")"
	cp -a "$src" "$dest"

	case "$rel" in
	.config/hypr/scripts/* | .config/waybar/scripts/* | .config/dunst/scripts/*)
		chmod +x "$dest"
		;;
	.config/hypr/wallpaper-restart.sh | .config/waybar/restart.sh)
		chmod +x "$dest"
		;;
	esac

	# Flameshot and similar tools store absolute paths.
	if grep -Iq '@HOME@' "$dest" 2>/dev/null; then
		sed -i "s|@HOME@|$HOME|g" "$dest"
	fi
}

install_packages() {
	local -a pacman_pkgs=()
	local -a aur_pkgs=()

	mapfile -t pacman_pkgs < <(grep -vE '^[[:space:]]*(#|$)' "$DOTFILES_DIR/packages/pacman.txt")
	mapfile -t aur_pkgs < <(grep -vE '^[[:space:]]*(#|$)' "$DOTFILES_DIR/packages/aur.txt")

	if ((${#pacman_pkgs[@]})); then
		if ! command -v sudo >/dev/null 2>&1; then
			printf 'install.sh: sudo is required for --packages.\n' >&2
			exit 1
		fi
		run sudo pacman -S --needed "${pacman_pkgs[@]}"
	fi

	if ((${#aur_pkgs[@]})); then
		if command -v yay >/dev/null 2>&1; then
			run yay -S --needed "${aur_pkgs[@]}"
		else
			printf 'install.sh: yay is not installed; skipping AUR packages:\n' >&2
			printf '  %s\n' "${aur_pkgs[@]}" >&2
		fi
	fi
}

set_login_shell() {
	local zsh_path current_shell
	zsh_path="$(command -v zsh || true)"

	if [[ -z "$zsh_path" ]]; then
		printf 'install.sh: zsh is not installed; skipping login shell change.\n' >&2
		return 0
	fi

	current_shell="$(getent passwd "$(id -un)" 2>/dev/null | cut -d: -f7 || true)"
	if [[ "$current_shell" == "$zsh_path" ]]; then
		printf 'skip login shell (already %s)\n' "$zsh_path"
		return 0
	fi

	run chsh -s "$zsh_path"
}

if ((INSTALL_PACKAGES)); then
	install_packages
fi

if ! command -v git >/dev/null 2>&1 || ! git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	printf 'install.sh: a git checkout is required to select files to install.\n' >&2
	exit 1
fi

while IFS= read -r -d '' tracked; do
	src="$DOTFILES_DIR/$tracked"
	[[ -f "$src" ]] || continue
	rel="${tracked#assets/home/}"
	install_file "$src" "$HOME/$rel"
done < <(git -C "$DOTFILES_DIR" ls-files -z -- assets/home)

if ((!DRY_RUN)); then
	mkdir -p "$HOME/.config/hypr/wallpapers"

	if compgen -G "$DOTFILES_DIR/assets/wallpapers/*" >/dev/null; then
		find "$DOTFILES_DIR/assets/wallpapers" -maxdepth 1 -type f \
			\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
			-o -iname '*.webp' -o -iname '*.gif' \) \
			-exec cp -n {} "$HOME/.config/hypr/wallpapers/" \;
	fi

	if command -v systemctl >/dev/null 2>&1; then
		systemctl --user enable --now hyprpolkitagent.service 2>/dev/null || true
	fi
fi

if ((SET_SHELL)); then
	set_login_shell
fi

if ((RELOAD)) && ((!DRY_RUN)); then
	if command -v hyprctl >/dev/null 2>&1 && hyprctl version >/dev/null 2>&1; then
		hyprctl reload || true
	fi
	if [[ -x "$HOME/.config/waybar/restart.sh" ]]; then
		"$HOME/.config/waybar/restart.sh" --reload || true
	fi
	if command -v dunstctl >/dev/null 2>&1; then
		dunstctl reload 2>/dev/null || true
	fi
fi

cat <<EOF
Installed from: $DOTFILES_DIR
Backups:        $BACKUP_DIR

Next steps:
  1. Edit ~/.gitconfig with your name and e-mail (and run: gh auth login).
  2. Put wallpapers in ~/.config/hypr/wallpapers, then run:
       ~/.config/hypr/wallpaper-restart.sh
  3. Log out and select Hyprland in your display manager.
  4. Use zsh as your login shell (skip if you passed --shell):
       chsh -s /usr/bin/zsh
  5. Optional Hyprspace plugin:
       hyprpm add https://github.com/KZDKM/Hyprspace
       hyprpm enable Hyprspace
EOF
