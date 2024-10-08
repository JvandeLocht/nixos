# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config
, pkgs
, inputs
, lib
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

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jan/.setup";
  };

  # Needed for Solaar to see Logitech devices.
  hardware.logitech.wireless.enable = true;

  environment.systemPackages = with pkgs;
    [
      git
      neovim
      wget
      curl
      nerdfonts
      evtest
      gnugrep
      # llvmPackages_9.libcxxClang
      powertop
      protonmail-bridge
      smartmontools
      nvtopPackages.nvidia
      pika-backup
    ]
    ++ (with unstable; [
      proton-pass
    ]);

  programs.partition-manager.enable = true;

  # # Nix Settings
  # nix.settings = {
  #   experimental-features = ["nix-command" "flakes"];
  #   trusted-users = ["jan"]; # Add your own username to the trusted list
  # };

  # Set default editor to vim
  environment.variables.EDITOR = "nvim";
  programs.bash.blesh.enable = true;
  programs.fish.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.kdeconnect.enable = true;


  nix.optimise.automatic = true;
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 30d";
  # };
  # This value determines the NixOS rele se from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "23.05"; # Did you read the comment?
}
