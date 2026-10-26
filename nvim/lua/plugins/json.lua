return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {
          settings = {
            json = {
              validate = { enable = true },
            },
          },
        },
      },
    },
  },
}
