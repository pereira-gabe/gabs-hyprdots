-- Ctrl+Backspace in insert mode: delete the word before the cursor.
vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete word before cursor" })

-- Alt+Up/Down in normal mode: move the current line.
vim.keymap.set("n", "<M-Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<M-Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" })
