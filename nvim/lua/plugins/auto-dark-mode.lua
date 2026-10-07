return {
  {
    "f-person/auto-dark-mode.nvim",
    config = function()
      require("auto-dark-mode").setup({
        update_interval = 1000,
        set_light_mode = function()
          vim.cmd("colorscheme catppuccin-latte")
        end,
        set_dark_mode = function()
          vim.cmd("colorscheme catppuccin-frappe")
        end,
      })
    end,
  },
}
