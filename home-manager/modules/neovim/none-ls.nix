{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.nonels = {
    enable = lib.mkEnableOption "none-ls-nvim (null-ls) plugin for Neovim";
  };

  config = lib.mkIf config.neovim.nonels.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = none-ls-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              local null_ls = require("null-ls")
              local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
              null_ls.setup({
                  debug = true,
                  sources = {
                      null_ls.builtins.formatting.alejandra.with({
                          command = "${pkgs.alejandra}/bin/alejandra"
                      }),
                      null_ls.builtins.formatting.google_java_format.with({
                          command = "${pkgs.google-java-format}/bin/google-java-format"
                      }),
                      null_ls.builtins.formatting.clang_format.with({
                          command = "${pkgs.clang-tools}/bin/clang-format"
                      }),
                      null_ls.builtins.formatting.black.with({
                          command = "${pkgs.black}/bin/black"
                      })
                  },

                  on_attach = function(client, bufnr)
                      if client.supports_method("textDocument/formatting") then
                          vim.api.nvim_clear_autocmds({group = augroup, buffer = bufnr})
                          vim.api.nvim_create_autocmd("BufWritePre", {
                              group = augroup,
                              buffer = bufnr,
                              callback = function()
                                  vim.lsp.buf.format({
                                      bufnr = bufnr,
                                      filter = function(client)
                                          return client.name == "null-ls"
                                      end
                                  })
                              end
                          })
                      end
                  end
              })
            '';
        }
      ];
    };
  };
}
