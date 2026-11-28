# gabs-hyprdots

Personal Arch Linux setup built around Hyprland (Lua config), Waybar, Dunst,
Rofi, Kitty, Zsh, and LazyVim.

## Preview

| Desktop | Terminal |
| --- | --- |
| <img src="assets/screenshots/screenshot1.png?v=20261128" alt="Hyprland desktop" width="100%"> | <img src="assets/screenshots/screenshot2.png?v=20261128" alt="Kitty, fastfetch and installer" width="100%"> |

## Included

| Area | Files |
| --- | --- |
| Hyprland | `hypr/*.lua`, `hyprlock.conf`, `wallpaper-restart.sh`, `scripts/` |
| Status bar | `waybar/config.jsonc`, `style.css`, `restart.sh`, `scripts/` |
| Notifications | `dunst/dunstrc`, `scripts/playNotificationSound.sh` |
| Launcher | `rofi/config.rasi`, `colors.rasi`, `fonts.rasi` |
| Terminals | `kitty/kitty.conf` |
| Editor | `nvim/` |
| Shell | `.zshrc`, `.zshenv`, `.bashrc`, `.bash_profile`, `.inputrc`, `.editrc`, `.blerc` |
| Assets | `assets/wallpapers/`, `assets/screenshots/` |
| Other | `btop`, `clangd`, `clang-format`, `gtk-3.0`, `gtk-4.0`, `gh`, `opencode`, `Code/User`, `hyfetch`, `pavucontrol`, `user-dirs`, `flameshot` |

## Requirements

- Arch Linux (or an Arch-based distribution)
- Hyprland 0.57 or newer (Lua configuration support)
- Zsh 5.9 or newer 
- A Nerd Font: `ttf-jetbrains-mono-nerd`
- `otf-font-awesome` for a few Waybar icons
- NVIDIA GPU (optional): `nvidia-open-dkms` (Turing+/50xx) or `nvidia-dkms` (older) + `nvidia-utils`, `egl-wayland`, `libva-nvidia-driver`; AMD/Intel works with mesa (drop the NVIDIA vars in `hypr/env.lua`)

The package lists are in `packages/pacman.txt` and `packages/aur.txt`.

## Install

```sh
cd ~/Dotfiles/gabs-hyprdots
./install.sh
```

Useful options:

| Option | Effect |
| --- | --- |
| `--packages` | Install official packages with `pacman` and AUR packages with `yay` |
| `--reload` | Reload Hyprland, Waybar and Dunst after installing |
| `--shell` | Set zsh as the login shell with `chsh` |
| `--force` | Replace an existing `~/.gitconfig` (the default is to skip it) |
| `--dry-run` | Print actions without changing files |
| `--help` | Show the built-in help |

The installer:

1. Backs up every replaced file under
   `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backups/<timestamp>/`.
2. Copies files from `assets/home/` to `$HOME/`, preserving permissions.
3. Replaces `@HOME@` with the real home directory where needed
   (`flameshot.ini`).
4. Creates `~/.config/hypr/wallpapers/` and copies any images from
   `assets/wallpapers/`.
5. Enables the `hyprpolkitagent` user service when available.
6. Sets zsh as the login shell when `--shell` is used.
7. Leaves `~/.gitconfig` untouched unless `--force` is used.

## Post-install

### Git identity

```sh
$EDITOR ~/.gitconfig        # set user.name and user.email
gh auth login               # credentials are delegated to gh
```

### Shell

`.zshrc` and `.zshenv` are installed to `$HOME` and are used by every zsh
process. The interactive config enables autosuggestions, history substring
search, fzf bindings, and syntax highlighting, loading each plugin from
`/usr/share/` and skipping any plugin that is not installed.

Set zsh as the login shell (or pass `--shell` to `install.sh`):

```sh
chsh -s /usr/bin/zsh
```

The prompt is a two-line Kali-style prompt and history is written to
`~/.zsh_history`. The Bash files remain available as a fallback.

### Kitty palette

`kitty.conf` can load a [pywal](https://github.com/dylanaraps/pywal) palette
from `~/.cache/wal/colors-kitty.conf`. The `include` line is commented out by
default; uncomment it after generating that file.

Remote control (`allow_remote_control` and `listen_on`) is left disabled: a
socket under `/tmp` can be reached by other local users. Enable it only when
needed.

### Wallpaper

The bundled images are installed automatically:

```sh
~/.config/hypr/wallpaper-restart.sh
```

To add another image:

```sh
cp /path/to/image.jpg ~/.config/hypr/wallpapers/
~/.config/hypr/wallpaper-restart.sh
```

Without an image, the script falls back to a solid `#0f161e` background.
`hyprlock.conf` references `wallpapers/mountains.png`, which is included.

Set `WALLPAPER_MODE` to `fit`, `stretch`, `center`, `tile`, or `solid_color`
to override the default `fill` mode.

### Hyprspace overview (optional)

```sh
hyprpm add https://github.com/KZDKM/Hyprspace
hyprpm enable Hyprspace
```

The `SUPER + Tab` bind is guarded, so it does nothing when the plugin is not
loaded.

### Hardware-specific settings

- `hypr/monitors.lua`: output is `eDP-1`. Change it if your panel has another
  name.
- `hypr/input.lua`: keyboard layout is `br`.
- `hypr/env.lua`: NVIDIA VA-API/GLX variables. Remove both lines on systems
  without an NVIDIA GPU.
- `hypr/autostart.lua`: locks immediately after greetd autologin. Remove the
  `hyprlock` line if your display manager already asks for a password.
- `waybar/config.jsonc`: the temperature module reads Intel `coretemp`; the
  GPU module uses `nvidia-smi`. Adjust or remove either module on other
  hardware.

### Lid switch

Closing the lid runs `hypr/scripts/lid.sh`, which starts `hyprlock`, waits for
it to map, and then suspends. If `hyprlock` cannot start, the script refuses to
suspend instead of leaving the session unlocked.

Useful checks:

```sh
hyprctl devices | grep -A1 Switches
hyprctl binds | grep -A8 'Lid Switch'
```

## Structure

```text
gabs-hyprdots/
├── install.sh
├── packages/
│   ├── pacman.txt
│   └── aur.txt
└── assets/
    ├── screenshots/      
    ├── wallpapers/       
    └── home/
        ├── .zshrc
        ├── .zshenv
        ├── .bashrc
        ├── .gitconfig
        └── .config/
            ├── hypr/
            ├── waybar/
            ├── dunst/
            ├── rofi/
            ├── kitty/
            ├── nvim/
            └── ...
```

## Keybindings

`SUPER` is the main modifier.

| Keys | Action |
| --- | --- |
| `SUPER + Return` | Kitty |
| `SUPER + B` | Firefox |
| `SUPER + E` | PCManFM |
| `SUPER + D` | Rofi application launcher |
| `SUPER + Tab` | Hyprspace overview (if loaded) |
| `SUPER + Q/W` | Close window |
| `SUPER + C` | VS Code in `~/Temp` |
| `SUPER + N` | VS Code in `~/Code/Neetcode` |
| `SUPER + T` | Toggle floating |
| `SUPER + F` | Toggle maximize |
| `SUPER + Shift + F` | Toggle fullscreen |
| `SUPER + h/j/k/l` | Focus left/down/up/right |
| `SUPER + Shift + h/j/k/l` | Move window |
| `SUPER + arrows` | Resize window |
| `SUPER + 1..0` | Switch workspace |
| `SUPER + Shift + 1..0` | Move window to workspace |
| `SUPER + Shift + S` | Area screenshot to clipboard |
| `Shift + Print` | Area screenshot to clipboard |
| `Print` | Flameshot |
| `SUPER + Shift + C` | Color picker |
| `SUPER + Shift + E` | Logout menu (`wlogout`) |
| `SUPER + P` | Cycle wallpaper |
| `SUPER + Escape` | Lock |
| `SUPER + mouse drag` | Move window |
| `SUPER + right mouse drag` | Resize window |
| `Alt + Tab` | Cycle windows |
| Media keys | Volume, brightness, player control |
| Lid close | Lock and suspend |

## Useful commands

```sh
hyprctl reload
hyprctl configerrors
~/.config/waybar/restart.sh
~/.config/waybar/restart.sh --reload
~/.config/hypr/wallpaper-restart.sh
~/.config/hypr/scripts/screensharing.sh
```
- Hyprspace plugin by [KZDKM](https://github.com/KZDKM/Hyprspace).
