-- Project management extension for telescope
-- Enables project switching, history and management features
-- Integrates with nvim-tree and git for seamless workflow
-- Provides quick access to project files and directories
return {
  {
    "nvim-telescope/telescope-project.nvim",
    dependencies = { "telescope.nvim" },
    config = function()
      -- Get project-specific actions from telescope
      local project_actions = require("telescope._extensions.project.actions")

      require("telescope").setup {
        extensions = {
          project = {
            -- Show all files including hidden ones in project view
            hidden_files = true,
            -- Automatically update nvim-tree when switching projects
            sync_with_nvim_tree = true,
            -- Custom handler when selecting a project
            on_project_selected = function(prompt_bufnr)
              -- Change working directory without closing telescope
              project_actions.change_working_directory(prompt_bufnr, false)
              -- Open git files picker after project selection
              require("telescope.builtin").find_files { hidden = true, no_ignore = true }
            end
          }
        }
      }
      -- Initialize telescope project extension
      require("telescope").load_extension "project"
    end,
  },
}
