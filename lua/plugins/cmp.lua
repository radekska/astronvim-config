return { -- override nvim-cmp plugin
  "hrsh7th/nvim-cmp",
  dependecies = {
    "zbirenbaum/copilot-cmp",
  },
  -- override the options table that is used in the `require("cmp").setup()` call
  opts = function(_, opts)
    -- opts parameter is the default options table
    -- the function is lazy loaded so cmp is able to be required
    local cmp = require("cmp")
    -- modify the sources part of the options table
    opts.sources = cmp.config.sources({
      { name = "codeium",  priority = 1500 },
      { name = "copilot",  priority = 1200 },
      { name = "nvim_lsp", priority = 1000 },
      { name = "luasnip",  priority = 750 },
      { name = "buffer",   priority = 500 },
      { name = "path",     priority = 250 },
    })
  end,
}
