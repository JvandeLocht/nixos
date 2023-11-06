{ config, pkgs, inputs, ... }: {

  imports = [ ./config.nix ./hyprpaper.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    enableNvidiaPatches = true;
  };

  home.packages = (with pkgs; [
    libnotify
    mpd
    gnome.gnome-keyring
    gnome.seahorse
    libgnome-keyring
    libsecret
    wl-clipboard
    hyprpaper
    pavucontrol
    grimblast
    blueberry
    swaynotificationcenter
    wlogout
    (callPackage ../../../pkgs/iio-hyprland.nix { })
  ]);
}
