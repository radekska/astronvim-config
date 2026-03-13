-- Scopes neo-tree's git status to cwd instead of the entire worktree root.
-- Fixes performance in monorepos where the worktree root is far above the
-- project directory (e.g. kubecast/ vs kubecast/services/users/).
--
-- Key insight: patches MUST be applied BEFORE require("neo-tree").setup()
-- because setup can trigger netrw hijack → neo-tree opens → git status
-- spawns immediately, before any post-setup patches take effect.

return {
  "nvim-neo-tree/neo-tree.nvim",
  config = function(_, opts)
    -- Scope to cwd on startup; narrowed to the saved file's directory on write.
    local scope_dir = vim.fn.getcwd()

    local neo_tree_git = require("neo-tree.git")
    local git_utils = require("neo-tree.git.utils")

    -- Patch 1: sync path — wrap M.status to inject status_opts.paths,
    -- which make_git_status_args uses to append `-- <path>` to the command.
    local original_status = neo_tree_git.status
    neo_tree_git.status = function(path, base_lookup, skip_bubbling, status_opts)
      if scope_dir then
        local worktree_root = neo_tree_git.find_worktree_info(
          path or (vim.uv or vim.loop).cwd()
        )
        if worktree_root
          and scope_dir:sub(1, #worktree_root) == worktree_root
          and scope_dir ~= worktree_root
        then
          status_opts = status_opts or {}
          if not status_opts.paths then
            status_opts.paths = { scope_dir }
          end
        end
      end
      return original_status(path, base_lookup, skip_bubbling, status_opts)
    end

    -- Patch 2: async path — wrap git_utils.git_job to append `-- <scope_dir>`
    -- to any git status command args before they reach uv.spawn.
    local original_git_job = git_utils.git_job
    git_utils.git_job = function(git_args, on_exit, cwd)
      if scope_dir then
        local is_status = false
        for _, arg in ipairs(git_args) do
          if arg == "status" then is_status = true; break end
        end
        if is_status then
          -- args: {"--no-optional-locks", "-C", worktree_root, "status", ...}
          local worktree_root = git_args[3]
          if worktree_root
            and scope_dir:sub(1, #worktree_root) == worktree_root
            and scope_dir ~= worktree_root
          then
            local has_pathspec = false
            for _, arg in ipairs(git_args) do
              if arg == "--" then has_pathspec = true; break end
            end
            if not has_pathspec then
              git_args = vim.deepcopy(git_args)
              git_args[#git_args + 1] = "--"
              git_args[#git_args + 1] = scope_dir
            end
          end
        end
      end
      return original_git_job(git_args, on_exit, cwd)
    end

    -- Now that both paths are patched, it's safe to run setup.
    require("neo-tree").setup(opts)

    -- Refine scope to saved file's directory on write.
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("NeoTreeGitPatch", { clear = true }),
      callback = function(ev)
        local buf_path = vim.api.nvim_buf_get_name(ev.buf)
        if buf_path and buf_path ~= "" then
          scope_dir = vim.fn.fnamemodify(buf_path, ":h")
        end
      end,
    })
  end,
}
