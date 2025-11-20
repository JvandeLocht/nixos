{
  lib,
  pkgs,
  osConfig,
  inputs,
  ...
}: let
  unstable = import inputs.nixpkgs-unstable {
    localSystem = pkgs.stdenv.hostPlatform.system;
  };
in {
  config = lib.mkIf osConfig.gnome.enable {
    home.packages =
      (with pkgs; [
        ])
      ++ (with pkgs.gnomeExtensions; [
        caffeine
        forge
        space-bar
        gsconnect
        appindicator
        screen-rotate
        dash-to-dock
        syncthing-indicator
      ])
      ++ (with unstable; [
        gnomeExtensions.arcmenu
      ]);
  };
}
