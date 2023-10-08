--return {
  -- Add the community repository of plugin specifications
  --"AstroNvim/astrocommunity",
  -- example of importing a plugin, comment out to use it or add your own
  -- available plugins can be found at https://github.com/AstroNvim/astrocommunity

 -- { import = "astrocommunity.pack.python" },
  -- { import = "astrocommunity.completion.copilot-lua-cmp" },
--}
local utils = require "astronvim.utils"
return {
  {
    "jay-babu/mason-null-ls.nvim",
    opts = function(_, opts)
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "black", "isort" })
    end,
  },
}
