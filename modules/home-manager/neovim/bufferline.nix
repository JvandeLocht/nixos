{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.bufferline = {
    enable = lib.mkEnableOption "bufferline-nvim plugin for Neovim";
  };

  config = lib.mkIf config.neovim.bufferline.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = bufferline-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("bufferline").setup{}
            '';
        }
      ];
    };
  };
}
