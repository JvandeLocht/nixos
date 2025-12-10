{
  pkgs,
  lib,
  ...
}:
{
  home = {
    username = "jan";
    homeDirectory = "/home/jan";
    stateVersion = "24.11"; # Please read the comment before changing.
  };

  imports = [
    ../../home-manager/modules/zsh.nix
    ../../home-manager/modules/bash.nix
    ../../home-manager/modules/tmux.nix
    ../../home-manager/modules/yazi.nix
    ../../home-manager/modules/emacs
  ];

  programs = {
    git = {
      enable = true;
      userName = "Jan van de Locht";
      userEmail = "jan@vandelocht.uk";
    };
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "/home/jan/.setup";
    };
  };

  zsh.enable = true;
  bash.enable = true;
  yazi.enable = true;
  emacs.enable = true;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    typst
    htop

    python3Full
    devenv

    peazip
    fira-code
    fira
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
