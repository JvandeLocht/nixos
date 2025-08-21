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

  nix-settings.enable = true;

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
        smartmontools
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
        sops
        age
      ]
      ++ (with inputs; [
      ])
      ++ (with unstable; [
      ]);
    # Set default editor to vim
    variables = {
      EDITOR = "nvim";
      RESTIC_PROGRESS_FPS = "1";
    };
  };

  # networking.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs = {
    zsh.enable = true;
    partition-manager.enable = true;
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      fira-code
      fira-sans
      cantarell-fonts
      notonoto
      meslo-lgs-nf
      vistafonts
      nerd-fonts.fantasque-sans-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      fira-code-symbols
    ];
    # ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix = {
    optimise.automatic = true;
  };
}
