{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.catppuccin = {
    enable = lib.mkEnableOption "catppuccin-nvim colorscheme for Neovim";
  };

  config = lib.mkIf config.neovim.catppuccin.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = catppuccin-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              vim.cmd[[colorscheme catppuccin-mocha]]
            '';
        }
      ];
    };
  };
}
