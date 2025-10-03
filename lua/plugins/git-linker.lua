return {
  {
    "ruifm/gitlinker.nvim",
    event = "BufRead",
    config = function()
      require("gitlinker").setup {
        opts = {
          -- remote = 'github', -- force the use of a specific remote
          -- adds current line nr in the url for normal mode
          add_current_line_on_normal_mode = true,
          -- callback for what to do with the url/
          action_callback = require("gitlinker.actions").open_in_browser,
          -- print the url after performing the action
          print_url = false,
          -- mapping to call url generation
          mappings = "<leader>gy",
        },
        callbacks = {
          ["github-cast"] = function(url_data)
            url_data.host = "github.com"
            print(url_data)

            return require("gitlinker.hosts").get_github_type_url(url_data)
          end,
          ["github-cruxmate"] = function(url_data)
            url_data.host = "github.com"
            return require("gitlinker.hosts").get_github_type_url(url_data)
          end,
        },
      }
    end,
    dependencies = "nvim-lua/plenary.nvim",
  },
}
