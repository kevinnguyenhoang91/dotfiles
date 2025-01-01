return {
  {
    "CopilotC-NVim/CopilotChat.nvim",
    opts = {
      auto_insert_mode = false,
      insert_at_end = false,
      window = {
        width = 0.25,
      },
      prompts = {
        Summary = {
          prompt = "Please summary this code.",
          system_prompt = "You are very good at summarizing stuff",
          mapping = "<leader>am",
          description = "My custom prompt description",
        },
      },
      mappings = {
        reset = {
          normal = "",
          insert = "<C-l>",
        },
      },
    },
  },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   config = function()
  --     require("copilot").setup({
  --       panel = {
  --         enabled = false,
  --       },
  --       suggestion = {
  --         enabled = false,
  --       },
  --       filetypes = {
  --         yaml = true,
  --         markdown = false,
  --         help = false,
  --         gitcommit = false,
  --         gitrebase = false,
  --         hgcommit = false,
  --         svn = false,
  --         cvs = false,
  --         ["."] = true,
  --       },
  --     })
  --   end,
  -- },
}
