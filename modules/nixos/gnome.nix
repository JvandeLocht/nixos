{ pkgs, ... }: {
  services = {
    xserver = { desktopManager.gnome.enable = true; };
    gnome = { gnome-browser-connector.enable = true; };
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnome-extension-manager
  ];
}
