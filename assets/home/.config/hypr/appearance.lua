hl.config({
	general = {
		layout = "dwindle",
		gaps_in = 1,
		gaps_out = 1,
		border_size = 1,
		allow_tearing = true,
		col = {
			active_border = "rgba(ffffffff)",
			inactive_border = "rgba(33333366)",
		},
	},

	decoration = {
		rounding = 0,
		shadow = {
			enabled = false,
			range = 15,
			color = "rgba(a7caff44)",
			color_inactive = "rgba(00000050)",
		},
		blur = {
			enabled = true,
			size = 6,
			passes = 2,
			new_optimizations = true,
		},
	},

	animations = {
		enabled = true,
	},

	dwindle = {
		force_split = 1,
	},

	master = {
		new_on_top = true,
	},

	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		mouse_move_enables_dpms = true,
		vrr = 0,
		enable_swallow = false,
	},
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "myBezier" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "default" })

-- hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
