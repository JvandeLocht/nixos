{ pkgs
, lib
, ...
}: {
  specialisation = {
    gnome.configuration = {
      gnome.enable = lib.mkForce true;
      hyprland.enable = lib.mkForce false;
    };
  };
}
