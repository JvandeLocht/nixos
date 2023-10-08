{ config, pkgs, lib, ... }:
{
  #Add support for ./local/bin
  #Needed for nvim
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  programs.neovim =
    let
      toLua = str: "lua << EOF\n${str}\nEOF\n";
      toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
    in
    {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages = (with pkgs; [
        #lua
        lua-language-server

        #bash
        nodePackages_latest.bash-language-server

        #python
        nodePackages_latest.pyright
        black
        isort

        #nix
        rnix-lsp

        #stuff
        libgccjit #gcc
        nodejs_20
        rustup
        xclip
        wl-clipboard
      ]) ++ (with pkgs.vimPlugins;[
        nvim-treesitter-parsers.python
        nvim-treesitter-parsers.toml
        nvim-treesitter-parsers.lua
        nvim-treesitter-parsers.bash
        nvim-treesitter-parsers.vim
        nvim-treesitter-parsers.rust
        nvim-treesitter-parsers.query
        nvim-treesitter-parsers.markdown
        nvim-treesitter-parsers.json
        nvim-treesitter-parsers.cmake
        nvim-treesitter-parsers.c
        nvim-treesitter-parsers.c_sharp
      ]);
    };
}
