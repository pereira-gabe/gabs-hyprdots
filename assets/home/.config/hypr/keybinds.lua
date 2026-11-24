local mainMod = "SUPER"

-- Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Notebook Lid
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/lid.sh"), { locked = true })

-- Apps
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("vesktop"))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("pcmanfm"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("rofi -modi emoji -show emoji"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("code ~/Temp"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("code ~/Code/Neetcode/"))

-- Fullscreen
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Other
hl.bind(mainMod .. " + Tab", function()
	if hl.plugin.overview then
		hl.plugin.overview.toggle()
	end
end, { description = "Hyprspace overview" })
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/hyprPicker.sh"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" - | wl-copy']]))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-cycle.sh"))

-- Media
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume mute"), { locked = true, repeating = true })
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/volume down"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/volume up"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness up"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness down"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Focus / Movement
local dirs = { h = "l", j = "d", k = "u", l = "r" }
for key, dir in pairs(dirs) do
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- Resize
local step = 40

hl.bind(mainMod .. " + left", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + right", hl.dsp.window.resize({ x = step, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + up", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })
hl.bind(mainMod .. " + down", hl.dsp.window.resize({ x = 0, y = step, relative = true }), { repeating = true })

-- Workspaces 1-10
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Alt + Tab cycle
hl.bind("ALT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next())
	hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- Screenshot
hl.bind("Print", hl.dsp.exec_cmd("flameshot gui"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" - | wl-copy']]))
