{ pkgs
, lib
, config
, ...
}: {
  options.gnome = {
    enable = lib.mkEnableOption "Set up GNOME desktop environment";
  };

  config = lib.mkIf config.gnome.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
