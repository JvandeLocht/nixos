{pkgs, ...}: {
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
              highlight = { enable = true}
            }
          '';
      }
    ];
  };
}
