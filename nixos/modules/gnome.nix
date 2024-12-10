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
    systemd.services = {
      # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;

    };

    systemd.services = {
      # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;

    };


    # Enable the GNOME Desktop Environment.
    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
