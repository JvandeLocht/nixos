{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.nvimAutopairs = {
    enable = lib.mkEnableOption "nvim-autopairs plugin for Neovim";
  };

  config = lib.mkIf config.neovim.nvimAutopairs.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-autopairs;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require("nvim-autopairs").setup {}
            '';
        }
      ];
    };
  };
}
