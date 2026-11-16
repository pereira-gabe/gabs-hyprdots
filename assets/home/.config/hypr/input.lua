hl.config({
	input = {
		kb_layout = "br",
		follow_mouse = 1,
		sensitivity = 0.7,
		force_no_accel = true,
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
