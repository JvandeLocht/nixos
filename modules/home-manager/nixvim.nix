{ config, pkgs, nixvim, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.gruvbox ];
    colorscheme = "gruvbox";
  };
}
