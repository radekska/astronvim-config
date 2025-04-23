return {
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        virtual_text = {
          enabled = true,
          key_bindings = {
            accept = "<C-y>",
            next = "<C->>",
            prev = "<C-<>",
          }
        },
      })
      require('codeium.virtual_text').set_statusbar_refresh(function()
        require('lualine').refresh()
      end)
    end
  }
}
