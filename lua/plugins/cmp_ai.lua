return {
  "saghen/blink.cmp",
  dependencies = {
    {
      "supermaven-inc/supermaven-nvim",
      opts = {
        disable_inline_completion = true, -- disables inline completion for use with cmp
        disable_keymaps = true, -- disables built in keymaps for more manual control
      },
    },
    {
      "huijiro/blink-cmp-supermaven",
    },
    {
      "Kaiser-Yang/blink-cmp-avante",
    },
  },
  opts = {
    sources = {
      default = { "avante", "lsp", "path", "supermaven", "snippets", "buffer" },
      providers = {
        supermaven = {
          name = "supermaven",
          module = "blink-cmp-supermaven",
          async = true,
        },
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {
            -- options for blink-cmp-avante
          },
        },
      },
    },
  },
}
