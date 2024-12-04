{ lib
, config
, osConfig
, pkgs
, inputs
, ...
}: {
  imports = [ ./config.nix ./hyprpaper.nix ];

  options.hyprlandConfig = {
    enable = lib.mkEnableOption "Custom Hyprland configuration";
  };

  config = lib.mkIf osConfig.programs.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      # plugins = [ inputs.hyprgrass.packages.${pkgs.system}.default ];
    };

    waybar.enable = true;
    wofi.enable = true;
    gtkThemes.enable = true;
    swayidle.enable = true;
    swaylock.enable = true;
    services = {
      swaync.enable = true;
      gnome-keyring.enable = true;
    };

    home.packages = with pkgs; [
      libnotify
      mpd
      gnome-keyring
      seahorse
      libgnome-keyring
      libsecret
      wl-clipboard
      hyprpaper
      grimblast
      blueberry
      swaynotificationcenter
      wlogout
      networkmanagerapplet
      libsForQt5.kdeconnect-kde
      # (callPackage ../../../pkgs/iio-hyprland.nix { })
      iio-hyprland
      wvkbd # On screen keyboard
      fractal # Matrix client
      qimgv # image viewer
    ];
  };
}
