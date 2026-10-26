return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-jest",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/nvim-nio", -- REQUIRED
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-jest"),
      },
    })
  end,
}
