return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.enable_git_status = false
    opts.git_status_async = false
    if opts.sources then
      local filtered = {}
      for _, s in ipairs(opts.sources) do
        if s ~= "git_status" then
          filtered[#filtered + 1] = s
        end
      end
      opts.sources = filtered
    end
  end,
  config = function(_, opts)
    -- Patch BEFORE setup — setup() can trigger netrw hijack which
    -- opens neo-tree and spawns async git status jobs immediately.
    local neo_tree_git = require("neo-tree.git")
    neo_tree_git.status = function()
      return nil, nil
    end
    neo_tree_git.status_async = function() end

    require("neo-tree").setup(opts)
    vim.notify("neo-tree-patch: git status fully disabled", vim.log.levels.DEBUG)
  end,
}
