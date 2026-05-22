return {
  "castai/kimchi-nvim",
  name = "kimchi.nvim",
  keys = {
    { "<leader>kc", "<cmd>KimchiToggle<cr>", desc = "Toggle Kimchi terminal" },
    { "<leader>kn", "<cmd>KimchiNew<cr>", desc = "New Kimchi session" },
    { "<leader>kr", "<cmd>KimchiContinue<cr>", desc = "Continue last Kimchi session" },
    { "<leader>kf", "<cmd>KimchiAttachFile<cr>", desc = "Attach file to Kimchi" },
    { "<leader>ks", "<cmd>KimchiAttachSelection<cr>", desc = "Attach selection to Kimchi" },
  },
  config = function()
    require("kimchi").setup({
      -- see Configuration section below
    })
  end,
}
