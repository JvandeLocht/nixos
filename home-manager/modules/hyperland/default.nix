{ config, pkgs, inputs, ... }: {

  imports = [ ./config.nix ./hyprpaper.nix ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    # plugins = [ inputs.hyprgrass.packages.${pkgs.system}.default ];
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
    wvkbd # On screen keyboard
    fractal # Matrix client
  ]);
}
