{
  config,
  inputs,
  pkgs,
  osConfig,
  ...
}: let
  unstable = import inputs.nixpkgs-unstable {
    localSystem = pkgs.stdenv.hostPlatform.system;
  };
in {
  imports = [
    ../common/home.nix
    # ../../home-manager/modules/emacs
    ../../home-manager/modules/tmux.nix
    ../../home-manager/modules/zsh.nix
    ../../home-manager/modules/yazi.nix
    ../../home-manager/modules/lf
  ];

  tmux.enable = true;
  # emacs.enable = true;
  zsh.enable = true;
  yazi.enable = true;
  lf.enable = true;

  home = {
    username = "jan";
    homeDirectory = "/home/jan";
    packages =
      (with pkgs; [
        # appimage-run
        claude-code
        vim
      ])
      ++ (with unstable; [
        ]);
  };
  # Packages that should be installed to the user profile.

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
