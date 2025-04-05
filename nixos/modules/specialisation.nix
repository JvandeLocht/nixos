{
  config,
  lib,
  ...
}: {
  options.specialisationConfig = {
    enable = lib.mkEnableOption "Enable specialisation for gnome and hyprland";
  };
  config = lib.mkIf config.specialisationConfig.enable {
    specialisation = {
      gnome.configuration = {
        gnome.enable = lib.mkForce true;
        hyprland.enable = lib.mkForce false;
      };
    };
  };
}
