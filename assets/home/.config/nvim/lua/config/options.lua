-- Options are loaded before lazy.nvim starts.

-- Indentation: 4 spaces.
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Do not render trailing whitespace or listchars.
vim.opt.listchars:remove({ "trail", "nbsp", "space" })

-- Only scroll horizontally when the cursor leaves the screen.
vim.opt.sidescrolloff = 0

-- Transparent background: opacity comes from the terminal
-- (background_opacity in kitty.conf). LazyVim applies its colorscheme on
-- VeryLazy, so clear the backgrounds again after it loads.
local transparent_groups = {
  "Normal",
  "NormalNC",
  "SignColumn",
  "EndOfBuffer",
  "StatusLine",
  "StatusLineNC",
  "TabLine",
  "TabLineFill",
  "WinSeparator",
  "Pmenu",
}

local function clear_backgrounds()
  for _, name in ipairs(transparent_groups) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok then
      hl.bg = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("transparent_background", { clear = true }),
  callback = clear_backgrounds,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = "transparent_background",
  callback = function()
    vim.schedule(clear_backgrounds)
  end,
})

clear_backgrounds()
