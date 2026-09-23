return {
  "castai/kimchi-nvim",
  name = "kimchi.nvim",
  keys = {
    { "<leader>okt", "<cmd>KimchiToggle<cr>", desc = "Toggle Kimchi terminal" },
    { "<leader>okn", "<cmd>KimchiNew<cr>", desc = "New Kimchi session" },
    { "<leader>okr", "<cmd>KimchiContinue<cr>", desc = "Continue last Kimchi session" },
    { "<leader>okf", "<cmd>KimchiAttachFile<cr>", desc = "Attach file to Kimchi" },
    { "<leader>oks", "<cmd>KimchiAttachSelection<cr>", desc = "Attach selection to Kimchi" },
  },
  config = function()
    require("kimchi").setup({
      -- see Configuration section below
    })
  end,
}
