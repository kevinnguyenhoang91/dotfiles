-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Color scheme
vim.cmd("colorscheme catppuccin-frappe")

-- Open Neo-tree automatically when Neovim starts
vim.cmd("autocmd VimEnter * Neotree")
