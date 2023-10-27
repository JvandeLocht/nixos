{ config, pkgs-unstable, ... }: {

  imports = [ ./config.nix ./hyprpaper.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs-unstable.hyprland;
    xwayland.enable = true;
    enableNvidiaPatches = true;
  };

  home.packages = (with pkgs-unstable; [
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
  ]);
}
