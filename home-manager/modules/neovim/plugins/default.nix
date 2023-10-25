{ pkgs, ... }: {
  imports = [
    ./barbar.nix
    ./comment.nix
    ./floaterm.nix
    ./harpoon.nix
    ./lsp.nix
    ./lualine.nix
    ./markdown-preview.nix
    ./neorg.nix
    ./neo-tree.nix
    ./startify.nix
    ./tagbar.nix
    ./telescope.nix
    ./treesitter.nix
    ./vimtex.nix
    ./which-key.nix
    ./none-ls.nix
    ./cmp.nix
  ];

  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.awesome-vim-colorschemes ];
    colorscheme = "onedark";

    plugins = {
      gitsigns = {
        enable = true;
        signs = {
          add.text = "+";
          change.text = "~";
        };
      };

      trouble.enable = true;

      nvim-autopairs.enable = true;

      nvim-colorizer = {
        enable = true;
        userDefaultOptions.names = false;
      };

      oil.enable = true;
    };
  };
}
