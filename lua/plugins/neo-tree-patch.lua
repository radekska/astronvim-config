return {
  "nvim-neo-tree/neo-tree.nvim",
  config = function(_, opts)
    require("neo-tree").setup(opts)

    local ok, git_utils = pcall(require, "neo-tree.git.utils")
    if not ok then
      vim.notify("neo-tree-git-patch: could not load neo-tree.git.utils", vim.log.levels.WARN)
      return
    end

    -- Track the directory of the last saved buffer so we can scope
    -- git status to it instead of scanning the entire worktree root.
    local last_saved_dir = nil
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("NeoTreeGitPatch", { clear = true }),
      callback = function(ev)
        local buf_path = vim.api.nvim_buf_get_name(ev.buf)
        if buf_path and buf_path ~= "" then
          last_saved_dir = vim.fn.fnamemodify(buf_path, ":h")
        end
      end,
    })

    local original_git_job = git_utils.git_job

    git_utils.git_job = function(args, cb)
      -- Only intercept git status calls
      local is_status = false
      for _, arg in ipairs(args) do
        if arg == "status" then is_status = true; break end
      end

      if is_status and last_saved_dir then
        -- args structure: {"--no-optional-locks", "-C", worktree_root, "status", ...}
        local worktree_root = args[3]

        local has_pathspec = false
        for _, arg in ipairs(args) do
          if arg == "--" then has_pathspec = true; break end
        end

        if not has_pathspec
          and worktree_root
          and last_saved_dir:sub(1, #worktree_root) == worktree_root
          and last_saved_dir ~= worktree_root
        then
          local scoped_args = vim.deepcopy(args)
          scoped_args[#scoped_args + 1] = "--"
          scoped_args[#scoped_args + 1] = last_saved_dir
          return original_git_job(scoped_args, cb)
        end
      end

      return original_git_job(args, cb)
    end
  end,
}
