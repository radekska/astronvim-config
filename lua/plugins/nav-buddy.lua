return {
  {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
      "numToStr/Comment.nvim",         -- Optional
      "nvim-telescope/telescope.nvim", -- Optional
    },
    config = function()
      require("nvim-navbuddy").setup { window = { size = "90%" }, lsp = { auto_attach = true } }
    end,
  },
}
