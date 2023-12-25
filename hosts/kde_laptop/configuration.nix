# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }: {
  imports = [ ../common/configuration.nix ];
  # Enable the X11 windowing system.
  services.xserver = {
    displayManager.defaultSession = "plasmawayland";

    displayManager.lightdm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [ libsForQt5.bismuth ];
}
