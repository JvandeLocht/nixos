# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }: {
  imports = [
    ../../nixos/modules/services.nix
    ../../nixos/modules/gnome.nix
    ../../nixos/modules/podman
    ../common/configuration.nix
  ];
  # Enable the X11 windowing system.
  services.xserver = {
    displayManager = {
      defaultSession = "gnome";
      gdm.enable = true;
    };
  };
  programs.dconf.enable = true;
}
