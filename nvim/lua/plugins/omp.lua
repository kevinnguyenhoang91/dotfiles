return {
  {
    "omaclaren/pi-nvim-context",
    config = function()
      require("pi-nvim-context").setup({
        -- Optional configuration options go here
      })
    end,
  },
  {
    "rauls-kjarners/omp.nvim",
    event = "VeryLazy",
    config = function()
      require("omp").setup()
    end,
  },
  {
    "dabstractor/pi-nvim-bridge",
    lazy = false,
    config = function()
      require("pi-bridge").setup({})
    end,
  },
}
