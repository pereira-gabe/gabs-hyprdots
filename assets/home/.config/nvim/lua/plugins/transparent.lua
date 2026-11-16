-- Transparent background for LazyVim.
-- The terminal provides the opacity; these settings only remove the editor
-- background so the wallpaper shows through.

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local ok, theme = pcall(require, "lualine.themes.tokyonight")
      if not ok then
        return opts
      end

      for _, mode in pairs(theme) do
        for _, section in ipairs({ "a", "b", "c" }) do
          if type(mode) == "table" and type(mode[section]) == "table" then
            mode[section].bg = nil
          end
        end
      end

      opts.options = opts.options or {}
      opts.options.theme = theme
      return opts
    end,
  },
}
