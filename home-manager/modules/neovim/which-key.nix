{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.whichKey = {
    enable = lib.mkEnableOption "which-key-nvim plugin for Neovim";
  };

  config = lib.mkIf config.neovim.whichKey.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = which-key-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("which-key").setup {}
            '';
        }
      ];
    };
  };
}
