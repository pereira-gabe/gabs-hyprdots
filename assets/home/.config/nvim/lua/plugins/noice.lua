-- Hide the LSP progress indicator.
-- pyright emits a progress message on every change, which makes the noice
-- progress area flicker while typing. Diagnostics and hover are unaffected.
return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = { enabled = false },
      },
    },
  },
}
