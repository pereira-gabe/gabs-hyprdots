-- blink.cmp adjustments.
--
-- The default "enter" preset accepts completion with <CR>, which makes it
-- hard to insert a plain newline in languages such as Python. Keep <CR> free
-- and accept with <Tab> or <C-y> instead.
--
-- Remove the LSP/path fallbacks so the buffer source is always queried along
-- with the LSP; otherwise local identifiers rarely appear in the menu.
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",

        ["<Tab>"] = { "snippet_forward", "select_and_accept", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<C-y>"] = { "select_and_accept" },
      },
      sources = {
        providers = {
          lsp = { fallbacks = function() return {} end },
          path = { fallbacks = function() return {} end },
        },
      },
    },
  },
}
