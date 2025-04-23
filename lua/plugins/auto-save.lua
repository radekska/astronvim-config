return {
  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup {
        execution_message = {
          message = function() -- message to print on save
            return ("AutoSave: saved at " .. vim.fn.strftime "%H:%M:%S")
          end,
        },
      }
    end,
  },
}
