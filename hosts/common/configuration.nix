# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../nixos/modules/gaming.nix
    ../../nixos/modules/locale_keymap.nix
    ../../nixos/modules/networking.nix
    ../../nixos/modules/nvidia.nix
    ../../nixos/modules/printing.nix
    ../../nixos/modules/sound.nix
    ../../nixos/modules/services.nix
  ];

  # Needed for Solaar to see Logitech devices.
  hardware.logitech.wireless.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
    nerdfonts
    kitty
    evtest
    gnugrep
    llvmPackages_9.libcxxClang
    powertop
    protonmail-bridge
    smartmontools
    nvtop-nvidia
    tmux
    pika-backup
  ];
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
  users.defaultUserShell = pkgs.fish;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.kdeconnect.enable = true;

  hardware.bluetooth.enable = true;

  nix.optimise.automatic = true;
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 30d";
  # };
  nixpkgs.config.permittedInsecurePackages = ["electron-24.8.6" "electron-22.3.27" "electron-25.9.0"];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
