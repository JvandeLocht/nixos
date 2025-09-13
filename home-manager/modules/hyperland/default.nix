{
  lib,
  config,
  osConfig,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./config.nix
    ./hyprpaper.nix
    ./touch.nix
  ];

  options.hyprlandConfig = {
    enable = lib.mkEnableOption "Custom Hyprland configuration";
  };

  config = lib.mkIf osConfig.programs.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      plugins = with pkgs.hyprlandPlugins; [ hyprgrass ];
    };

    waybar.enable = true;
    wofi.enable = true;
    gtkThemes.enable = true;
    hyprlock.enable = true;
    hypridle.enable = true;
    services.walker = {
      enable = true;
      settings = {
        list = {
          height = 200;
        };
        websearch = {
          prefix = "?";
          entries = [
            {
              name = "DuckDuckGo";
              url = "https://duckduckgo.com/?q=%TERM%";
            }
          ];
        };
        switcher.prefix = "/";
      };
    };
    services = {
      # swaync.enable = true;
      hyprpolkitagent.enable = true;
    };

    systemd.user.services = {
    };

    home.packages = with pkgs; [
      libnotify
      mpd
      wl-clipboard
      hyprpaper
      grimblast
      blueberry
      swaynotificationcenter
      wlogout
      networkmanagerapplet
      iio-hyprland
      jq
      zip
    ];
  };
}
