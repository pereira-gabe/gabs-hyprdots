-- Disable LSP inlay hints for filetypes handled by clangd.
-- clangd shows parameter names as ghost text (for example "format:" before a
-- printf argument). Toggle hints manually with <leader>uh when needed.
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      vim.list_extend(opts.inlay_hints.exclude, {
        "c",
        "cpp",
        "objc",
        "objcpp",
        "cuda",
        "proto",
      })
    end,
  },
}
