# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ../../nixos/modules/services.nix
    ../../nixos/modules/gnome.nix
    ../../nixos/modules/podman
    ../common/configuration.nix
    ./opt-in.nix
  ];
  services.zfs.autoScrub.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/leds/asus::kbd_backlight/brightness"
  '';
  boot = {
    # Bootloader.
    loader = {
      #      systemd-boot.enable = true;
      #      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        zfsSupport = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        mirroredBoots = [
          {
            devices = ["nodev"];
            path = "/boot";
          }
        ];
      };
    };
    # Setup keyfile
    #    initrd.secrets = {"/crypto_keyfile.bin" = null;};
    #    kernelPackages = pkgs.linuxPackages_latest;
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';
    zfs.requestEncryptionCredentials = true;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = ["nohibernate"];
    kernelPatches = [
      {
        name = "amd-tablet-sfh";
        patch = ../../kernel/patch/amd-tablet-sfh.patch;
      }
    ];
  };
  networking.hostId = "e4f8879e";
  networking.hostName = "jans-nixos"; # Define your hostname.
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["jan"]; # Add your own username to the trusted list
  };
  # Enable Accelerometer
  hardware.sensor.iio.enable = true;

  users.users = {
    jan = {
      isNormalUser = true;
      description = "Jan";
      hashedPasswordFile = "/persist/passwords/user";
      extraGroups = ["networkmanager" "wheel" "video" "libvirtd"];
    };
  };
  # Enable the X11 windowing system.
  services = {
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
    displayManager = {
      defaultSession = "gnome";
      # Enable automatic login for the user.
      autoLogin = {
        enable = true;
        user = "jan";
      };
    };
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
    };
  };
  programs.dconf.enable = true;
}
