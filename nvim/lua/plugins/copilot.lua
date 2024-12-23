return {
  {
    "CopilotC-NVim/CopilotChat.nvim",
    opts = {
      auto_insert_mode = false,
      insert_at_end = true,
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
}
