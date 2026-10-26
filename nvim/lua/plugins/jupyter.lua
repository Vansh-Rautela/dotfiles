return {
  {
    "GCBallesteros/jupytext.nvim",
    config = true,
  },
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    ft = { "python", "markdown" },
  },
}
