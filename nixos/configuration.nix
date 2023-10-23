# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./modules
  ];
  boot = {
    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Setup keyfile
    initrd.secrets = { "/crypto_keyfile.bin" = null; };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # stuff for hyperland
  programs.hyprland.enable = true;
  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # GTK: Use wayland if available, fall back to x11 if not.
    GDK_BACKEND = "wayland,x11";
    # Qt: Use wayland if available, fall back to x11 if not.
    QT_QPA_PLATFORM = "wayland;xcb";
    # Run SDL2 applications on Wayland.
    # Remove or set to x11 if games that provide
    # older versions of SDL cause compatibility issues
    SDL_VIDEODRIVER = "wayland";
    # Clutter package already has wayland enabled,
    # this variable will force Clutter applications
    # to try and use the Wayland backend
    CLUTTER_BACKEND = "wayland";
    # XDG specific environment variables are often detected
    # through portals and applications that may set those for you,
    # however it is not a bad idea to set them explicitly.
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    # (From the Qt documentation) enables automatic scaling,
    # based on the monitor’s pixel density
    # https://doc.qt.io/qt-5/highdpi.html
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };
  security.polkit.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
  security.pam.services.swaylock = { };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    # Enable automatic login for the user.
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "jan";
    displayManager.defaultSession = "hyprland";

    # displayManager.gdm.enable = true;
  };

  # Enable Accelerometer
  hardware.sensor.iio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jan = {
    isNormalUser = true;
    description = "Jan";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
    nerdfonts
    kitty
    evtest
    gnugrep
    llvmPackages_9.libcxxClang
    lxqt.lxqt-policykit
    brightnessctl
    xbindkeys
    networkmanagerapplet
    qt5.qtwayland
    qt6.qtwayland
    libappindicator-gtk3
    libappindicator
  ];
  programs.partition-manager.enable = true;

  # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "jan" ]; # Add your own username to the trusted list
  };

  # Set default editor to vim
  environment.variables.EDITOR = "nvim";
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  hardware.bluetooth.enable = true;
  powerManagement.enable = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
