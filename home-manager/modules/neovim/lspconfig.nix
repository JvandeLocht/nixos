{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.lspconfig = {
    enable = lib.mkEnableOption "nvim-lspconfig plugin for Neovim";
  };

  config = lib.mkIf config.neovim.lspconfig.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require('lspconfig').nil_ls.setup({
                cmd = { "${pkgs.nil}/bin/nil" }
              })
              require'lspconfig'.clangd.setup({
                cmd = { "${pkgs.clang-tools}/bin/clangd" }
              })
              require('lspconfig').java_language_server.setup({
                capabilities = capabilities,
                cmd = { "${pkgs.java-language-server}/bin/java-language-server" },
                settings = {
                  java = {
                    classPath = {"carnett3/483libs.jar"}
                  }
                }
              })
              require('lspconfig').pyright.setup({
                cmd = { "${pkgs.nodePackages.pyright}/bin/pyright" },
              })
              vim.diagnostic.config({
                virtual_text = false,
                float = {
                  focusable = false,
                  border = "rounded",
                  source = "always",
                },
              })
              vim.o.updatetime = 250
            '';
        }
      ];
    };
  };
}
