{ lib
, config
, osConfig
, pkgs
, inputs
, ...
}: {
  imports = [ ./config.nix ./hyprpaper.nix ./touch.nix ];

  options.hyprlandConfig = {
    enable = lib.mkEnableOption "Custom Hyprland configuration";
  };

  config = lib.mkIf osConfig.programs.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      plugins = with pkgs.hyprlandPlugins;[ hyprgrass ];
    };

    waybar.enable = true;
    wofi.enable = true;
    gtkThemes.enable = true;
    hyprlock.enable = true;
    hypridle.enable = true;
    services = {
      swaync.enable = true;
      gnome-keyring.enable = true;
    };

    systemd.user.services = {
      hideFilen = {
        Unit = {
          Description = "hide filen";
          After = "filen.service";
        };
        Service = {
          Restart = "never";
          ExecStartPre = "${pkgs.toybox}/bin/sleep 5";

          ExecStart = "${pkgs.hyprland}/bin/hyprctl dispatch togglespecialworkspace Filen";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
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
      fractal # Matrix client
      qimgv # image viewer
    ];
  };
}
