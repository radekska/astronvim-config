return {
	{
		"kevinhwang91/nvim-bqf",
		event = "VeryLazy",
		dependencies = {
			"junegunn/fzf",
			config = function()
				vim.fn["fzf#install"]()
			end,
		},
	},
}
