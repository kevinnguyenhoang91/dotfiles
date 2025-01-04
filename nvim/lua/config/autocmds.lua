-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Exit insert mode after 0.5 minutes of inactivity
vim.cmd(
  [[
     autocmd CursorHoldI * stopinsert
   ]],
  false
)

-- Exit visual mode after 0.5 minutes of inactivity
vim.cmd(
  [[
     autocmd CursorHold * if mode() ==# 'v' || mode() ==# 'V' || mode() ==# "\<C-v>" | normal! <Esc> | endif
   ]],
  false
)
