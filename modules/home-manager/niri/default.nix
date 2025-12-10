{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  config = lib.mkIf osConfig.programs.niri.enable {
    programs.alacritty.enable = true; # Super+T in the default setting (terminal)
    programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
    programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
    services.mako.enable = true; # notification daemon
    services.swayidle.enable = true; # idle management daemon
    services.polkit-gnome.enable = true; # polkit

    waybar.enable = true;
    home.packages = with pkgs; [
      swaybg # wallpaper
    ];
    xdg.configFile."niri/config.kdl".source = ./config.kdl;
  };
}
