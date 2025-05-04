# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  ...
}:
let
  unstable = import inputs.nixpkgs-unstable {
    localSystem = pkgs.system;
  };
in
{
  imports = [
    ../../nixos/modules
  ];

  environment = {
    systemPackages =
      with pkgs;
      [
        git
        neovim
        wget
        curl
        evtest
        gnugrep
        powertop
        protonmail-bridge
        smartmontools
        nvtopPackages.nvidia
        pika-backup
        borgbackup
        rclone
        restic
        zellij
        backrest
        filen-cli
        immich-cli
        gnome-disk-utility
      ]
      ++ (with inputs; [
        agenix.packages.x86_64-linux.default
      ])
      ++ (with unstable; [
        proton-pass
      ]);
    # Set default editor to vim
    variables = {
      EDITOR = "nvim";
      RESTIC_PROGRESS_FPS = "1";
    };
  };

  networking.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs = {
    bash.blesh.enable = true;
    fish.enable = true;
    zsh.enable = true;
    kdeconnect.enable = true;
    partition-manager.enable = true;
  };

  fonts = {
    fontDir.enable = true;
    packages =
      with pkgs;
      [
        fira-code
        cantarell-fonts
        notonoto
        meslo-lgs-nf
        vistafonts
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.optimise.automatic = true;
}
