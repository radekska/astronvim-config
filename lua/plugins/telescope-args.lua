return {
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = { "telescope.nvim" },
    config = function() require("telescope").load_extension "live_grep_args" end,
  },
}
