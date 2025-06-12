return {
  "zaldih/themery.nvim",
  lazy = false,
  config = function()
    require("themery").setup {
      themes = vim.fn.getcompletion('', 'color'), -- Dynamically fetch themes using Neovim's completion for colorschemes.
      livePreview = true,
      -- add the config here
    }
  end,
}
