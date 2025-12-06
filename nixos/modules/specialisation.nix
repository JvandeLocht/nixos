{
  config,
  lib,
  ...
}:
{
  options.specialisationConfig = {
    enable = lib.mkEnableOption "Enable specialisation for gnome, niri and hyprland";
  };
  config = lib.mkIf config.specialisationConfig.enable {
    specialisation = {
      gnome.configuration = {
        gnome.enable = lib.mkForce true;
        hyprland.enable = lib.mkForce false;
      };
      niri.configuration = {
        niri.enable = lib.mkForce true;
        hyprland.enable = lib.mkForce false;
      };
    };
  };
}
