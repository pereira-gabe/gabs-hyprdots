local internal = "eDP-1"

hl.monitor({
	output = internal,
	mode = "preferred",
	position = "0x0",
	scale = 1,
})

local function mirrorHdmi(monitor)
	if not monitor then
		return
	end

	local name = monitor.name
	if not name or name == internal or not name:match("^HDMI") then
		return
	end

	hl.monitor({
		output = name,
		mode = "preferred",
		position = "0x0",
		scale = 1,
		mirror = internal,
	})
end

hl.on("monitor.added", mirrorHdmi)

hl.on("hyprland.start", function()
	for _, monitor in ipairs(hl.get_monitors({ all = true })) do
		mirrorHdmi(monitor)
	end
end)
