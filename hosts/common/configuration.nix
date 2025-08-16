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
        glances
        attic-client
        attic-server
      ]
      ++ (with inputs; [
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
    packages = with pkgs; [
      fira-code
      cantarell-fonts
      notonoto
      meslo-lgs-nf
      vistafonts
    ];
    # ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    optimise.automatic = true;
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 30d";
    # };
    settings.substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cache.lan.vandelocht.uk/"
    ];
    settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.lan.vandelocht.uk:uY5NlU5/9D6UTirWyuY8WTI+oEucGbSINnQfe6xrQbM="
    ];
  };
}
