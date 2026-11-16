-- Use a fixed output name for the internal panel. Replace "preferred" with a
-- specific mode (e.g. "1920x1080@60") only when the EDID is unreliable.
hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = 1,
})

-- Example external monitor:
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "1920x0", scale = 1 })
