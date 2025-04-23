-- Configuration for CodeCompanion.nvim - An AI coding assistant for Neovim
return {

  {
    -- Plugin source: https://github.com/olimorris/codecompanion.nvim
    "olimorris/codecompanion.nvim",

    -- Required dependencies
    dependencies = {
      "nvim-lua/plenary.nvim",     -- Common Lua functions
      "nvim-treesitter/nvim-treesitter", -- Code parsing
    },

    opts = {
      -- Configure AI adapters (providers)
      adapters = {
        -- Setup Anthropic/Claude as an adapter
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              -- Get API key from environment variable
              -- Make sure to set: export ANTHROPIC_API_KEY="your-key-here"
              -- api_key = os.getenv("ANTHROPIC_API_KEY"),
            },
          })
        end,
      },

      -- Configure different interaction strategies
      strategies = {
        chat = {
          -- Set Anthropic/Claude as the default chat adapter
          adapter = "anthropic",
        },
        inline = {
          -- Set Anthropic/Claude as the default inline adapter
          adapter = "anthropic",
        },
      },

      opts = {
        -- Enable debug logging for troubleshooting
        -- Options: "DEBUG", "INFO", "WARN", "ERROR"
        log_level = "DEBUG",
      },
    },
  },
}
