local floating = {
    "Rofi",
    "pavucontrol",
    "^(blueman-manager)$",
    "^(xdg-desktop-portal-gtk)$",
    "^(geeqie)$",
    "^(org.twosheds.iwgtk)$",
    "^(blueberry.py)$",
}
for _, class in ipairs(floating) do
    hl.window_rule({ match = { class = class }, float = true })
end

hl.window_rule({
    match  = { class = "^(org.gnome.Calculator)$" },
    float  = true,
    center = true,
    size   = { 400, 600 },
})

hl.window_rule({
    match          = { class = "^(kitty)$" },
    suppress_event = "fullscreen maximize",
})

hl.window_rule({
    name      = "ultrakill-tearing",
    match     = { class = "^(steam_app_1229490)$" },
    immediate = true,
})
