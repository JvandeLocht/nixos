{pkgs, ...}: {
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
}
