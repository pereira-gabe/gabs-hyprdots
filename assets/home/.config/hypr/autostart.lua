hl.on("hyprland.start", function()
	hl.exec_cmd(
		[[hyprctl plugin list | grep -q Hyprspace || hyprctl plugin load "$HOME/.local/share/hyprspace/Hyprspace/Hyprspace.so"]]
	)
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("waybar")
	hl.exec_cmd("dunst")
	hl.exec_cmd("$HOME/.config/hypr/wallpaper-restart.sh")

	-- greetd autologin starts Hyprland directly, so lock immediately.
	hl.exec_cmd("hyprlock")
end)
