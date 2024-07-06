{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.treesitter = {
    enable = lib.mkEnableOption "nvim-treesitter plugin for Neovim";
  };

  config = lib.mkIf config.neovim.treesitter.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-treesitter.withAllGrammars; # Syntax Highlighting
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require('nvim-treesitter.configs').setup {
                highlight = { enable = true }
              }
            '';
        }
      ];
    };
  };
}
