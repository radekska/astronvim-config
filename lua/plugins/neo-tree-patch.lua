-- Use personal fork with git_status_scope_to_path support.
-- Replaces the previous monkey-patch approach.

return {
  "radekska/neo-tree.nvim",
  branch = "feat/git-status-scope-to-path",
  opts = function(_, opts)
    opts.git_status_scope_to_path = true
  end,
}
