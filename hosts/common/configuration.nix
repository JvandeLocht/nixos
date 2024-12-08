# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ pkgs
, inputs
, ...
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
    systemPackages = with pkgs;
      [
        git
        neovim
        wget
        curl
        nerdfonts
        evtest
        gnugrep
        powertop
        protonmail-bridge
        smartmontools
        nvtopPackages.nvidia
        pika-backup
      ]
      ++ (with unstable; [
        proton-pass
      ]);
    # Set default editor to vim
    variables.EDITOR = "nvim";
  };

  users.defaultUserShell = pkgs.zsh;

  programs = {
    bash.blesh.enable = true;
    fish.enable = true;
    zsh.enable = true;
    kdeconnect.enable = true;
    partition-manager.enable = true;
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "/home/jan/.setup";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.optimise.automatic = true;
}
