return {
  {
    "epwalsh/obsidian.nvim",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/notes",
        },
      },

      notes_subdir = "zettel",

      daily_notes = {
        folder = "logs",
        date_format = "%Y-%m-%d",
      },

      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      completion = {
        nvim_cmp = false,
      },
      ui = {
        enable = false,
      },
    },
  },
}
