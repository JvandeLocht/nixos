{
  pkgs,
  lib,
  config,
  ...
}: {
  options.gnome = {
    enable = lib.mkEnableOption "Set up GNOME desktop environment";
  };

  config = lib.mkIf config.gnome.enable {
    services = {
      xserver = {desktopManager.gnome.enable = true;};
      gnome = {gnome-browser-connector.enable = true;};
      udev.packages = with pkgs; [gnome.gnome-settings-daemon];
    };

    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnome-extension-manager
    ];
  };
}
