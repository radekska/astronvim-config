return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function(_, opts)
      local function gitsigns_source()
        local gs = vim.b.gitsigns_status_dict
        return gs and { added = gs.added, modified = gs.changed, removed = gs.removed }
      end
      -- Replace lualine's diff component with gitsigns-backed one
      if opts.sections then
        for _, section in ipairs(opts.sections.lualine_b or {}) do
          if section[1] == "diff" or section == "diff" then section.source = gitsigns_source end
        end
      end
      return opts
    end,
  },
}
