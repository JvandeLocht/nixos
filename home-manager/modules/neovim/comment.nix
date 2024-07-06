{
  lib,
  config,
  pkgs,
  ...
}: {
  options.neovim.comment = {
    enable = lib.mkEnableOption "comment-nvim plugin for Neovim";
  };

  config = lib.mkIf config.neovim.comment.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        {
          plugin = comment-nvim;
          type = "lua";
          config =
            /*
            lua
            */
            ''
              require('Comment').setup()
            '';
        }
      ];
    };
  };
}
