{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.webDevicons = {
    enable = lib.mkEnableOption "nvim-web-devicons plugin for Neovim";
  };

  config = lib.mkIf config.neovim.webDevicons.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-web-devicons;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("nvim-web-devicons").setup{}
            '';
        }
      ];
    };
  };
}
