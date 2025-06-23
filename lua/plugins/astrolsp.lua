---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    autocmds = {
      yaml_to_helm_detection = {
        cond = function(_, bufnr)
          local bufname = vim.api.nvim_buf_get_name(bufnr) -- Get full file path
          local ext = bufname:match "^.+%.(.+)$" -- Extract extension
          if ext == "yaml" or ext == "yml" then return true end
          return false
        end,
        {
          event = { "BufNewFile", "BufRead", "BufWrite", "BufEnter", "FileReadPre" },
          callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

            for _, line in ipairs(lines) do
              if line:match "{{.+}}" then
                vim.bo[bufnr].filetype = "helm"
                local clients = vim.lsp.get_clients { bufnr = bufnr }
                for _, client in ipairs(clients) do
                  if client.name == "yamlls" then -- Replace with the LSP name you want to disable
                    vim.lsp.buf_detach_client(bufnr, client.id)
                  end
                end
                return
              end
            end
          end,
        },
      },
    },
    commands = {
      FormatBuffer = {
        function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
        desc = "Format file with LSP",
      },
    },
    -- Configuration table of features provided by AstroLSP
    features = {
      autoformat = false, -- enable or disable auto formatting on start
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = true, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      async = true, -- enable or disable async formatting

      -- control auto formatting on save
      format_on_save = {
        enabled = false, -- enable or disable format on save globally
        -- allow_filetypes = { -- enable format on save for specified filetypes only
        --   -- "go",
        -- },
        -- ignore_filetypes = { -- disable format on save for specified filetypes
        --   -- "python",
        -- },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
        "protols",
      },
      timeout_ms = 8000, -- default format timeout
    },
    -- -- enable servers that you already have installed without mason
    servers = {
      "terraformls",
      "gopls",
      "starpls",
      "lua_ls",
      "yamlls",
      "marksman",
      "djlsp",
      "cssls",
      "protols",
      "sqlls",
      "dartls",
    },
    -- handlers = {
    --   gopols = function(_, opts)
    --     print("opts.capabilities:", vim.inspect(opts.capabilities))
    --     opts.capabilities["inlayHintProvider"] = true
    --     require("lspconfig").gopls.setup(opts)
    --   end,
    -- },
  },
}
