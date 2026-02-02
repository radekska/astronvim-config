return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    -- Opencode keymaps under <Leader>a prefix.
    vim.keymap.set(
      { "n", "x" },
      "<Leader>aa",
      function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "Ask opencode…" }
    )
    vim.keymap.set(
      { "n", "x" },
      "<Leader>ax",
      function() require("opencode").select() end,
      { desc = "Execute opencode action…" }
    )
    vim.keymap.set({ "n", "t" }, "<Leader>at", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

    vim.keymap.set(
      { "n", "x" },
      "<Leader>ao",
      function() return require("opencode").operator "@this " end,
      { desc = "Add range to opencode", expr = true }
    )
    vim.keymap.set(
      "n",
      "<Leader>aoo",
      function() return require("opencode").operator "@this " .. "_" end,
      { desc = "Add line to opencode", expr = true }
    )

    vim.keymap.set(
      "n",
      "<Leader>au",
      function() require("opencode").command "session.half.page.up" end,
      { desc = "Scroll opencode up" }
    )
    vim.keymap.set(
      "n",
      "<Leader>ad",
      function() require("opencode").command "session.half.page.down" end,
      { desc = "Scroll opencode down" }
    )
  end,
}
