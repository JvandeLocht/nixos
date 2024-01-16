{pkgs, ...}: {
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
}
