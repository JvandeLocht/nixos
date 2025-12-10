{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.onedark = {
    enable = lib.mkEnableOption "onedark-nvim colorscheme for Neovim";
  };

  config = lib.mkIf config.neovim.onedark.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = onedark-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              vim.cmd[[colorscheme onedark]]
            '';
        }
      ];
    };
  };
}
