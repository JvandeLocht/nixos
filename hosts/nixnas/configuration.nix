# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/configuration.nix
      ./opt-in.nix
    ];

  podman = {
    enable = true;
    minio.enable = true;
    proxmox-backup-server.enable = true;
  };

  gaming.enable = true;
  locale.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.samba.enable = true;
  services.spice-vdagentd.enable = true;
  services.spice-autorandr.enable = true;
  services.spice-webdavd.enable = true;
  services.samba.openFirewall = true;
  gnome.enable = true;
  services.qemuGuest.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jan/.setup";
  };


  systemd.services = {
    tank-usb-mount = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      description = "Import zfs pool tank";
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 30;
        ExecStart = "${pkgs.zfs}/bin/zpool import tank";
      };
    };
  };


  boot = {
    # zfs.extraPools = [ "tank" ];
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
            devices = [ "nodev" ];
            path = "/boot";
          }
        ];
      };
    };
    initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';
  };
  services.zfs.autoScrub.enable = true;

  networking.hostName = "nixnas"; # Define your hostname.
  networking.hostId = "3901c199";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";



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
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  services.openssh.enable = true; # If using VPS

  security.sudo.wheelNeedsPassword = false;
  users.users = {
    "jan" = {
      isNormalUser = true;
      # password = "password"; # Change this once your computer is set up!
      hashedPasswordFile = config.age.secrets.jan-nixnas.path;
      home = "/home/jan";
      extraGroups = [ "wheel" "networkmanager" "users" ];
    };
  };


  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "jan" ]; # Add your own username to the trusted list
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    nixvim
    spice
  ]) ++ (with inputs;[
    agenix.packages.x86_64-linux.default
  ]);


  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

