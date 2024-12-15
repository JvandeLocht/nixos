# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config
, pkgs
, lib
, ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs
    (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name) != null
        && (builtins.tryEval kernelPackages).success
        && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    )
    pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ../common/configuration.nix
    ./opt-in.nix
  ];

  #enable custom modules
  podman = {
    enable = true;
    openWebUI.enable = false;
    nvidia.enable = false;
  };
  virtSupport.enable = true;
  gaming.enable = true;
  hyprland.enable = true;
  locale.enable = true;
  networking.enable = true;
  nvidia.enable = true;
  # power.enable = true;
  printing.enable = true;
  services.enable = true;
  soundConfig.enable = true;

  boot = {
    # Bootloader.
    loader = {
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
    initrd.postMountCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';
    zfs.requestEncryptionCredentials = true;
    # Note this might jump back and forth as kernels are added or removed.
    kernelPackages = latestKernelPackage;
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [ "nohibernate" ];
    kernelPatches = [
      {
        name = "amd-tablet-sfh";
        patch = ../../patches/amd-tablet-sfh.patch;
      }
    ];
  };

  networking = {
    hostId = "e4f8879e";
    hostName = "groot"; # Define your hostname.
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "jan" ]; # Add your own username to the trusted list
  };

  hardware = {
    # Enable Accelerometer
    sensor.iio.enable = true;
    # Needed for Solaar to see Logitech devices.
    logitech.wireless.enable = true;
    bluetooth.enable = true;
  };

  users.users = {
    jan = {
      isNormalUser = true;
      description = "Jan";
      hashedPasswordFile = "/persist/passwords/user";
      extraGroups = [ "networkmanager" "wheel" "video" "libvirtd" ];
    };
  };
  # Enable the X11 windowing system.
  services = {
    restic = {
      backups.groot = {
        initialize = true;
        inhibitsSleep = true;
        repository = "rclone:filen:Backups/restic/groot";
        paths = [ "/home/jan" "/persist" ];
        exclude = [ "/var/cache" "/home/*/.cache" "/home/*/.local/share" "/home/*/Bilder" "/persist/var/lib/ollama" "/persist/var/lib/ollama" "/persist/var/lib/libvirt" "/persist/var/lib/containers" "/persist/var/lib/systemd" ];
        passwordFile = "${config.age.secrets.jan-groot-restic.path}";
        rcloneConfigFile = "${config.age.secrets.rclone-config.path}";
        pruneOpts = [
          "--keep-weekly 4"
          "--keep-monthly 3"
        ];
      };
    };
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
    displayManager = {
      # defaultSession = "gnome";
      # Enable automatic login for the user.
      autoLogin = {
        enable = true;
        user = "jan";
      };
    };
    ollama = {
      enable = false;
      acceleration = "cuda";
    };
    zfs.autoScrub.enable = true;
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/leds/asus::kbd_backlight/brightness"
    '';
  };
  nixpkgs.config.permittedInsecurePackages = [ "electron-24.8.6" "electron-22.3.27" "electron-25.9.0" "electron-27.3.11" ];
  # This value determines the NixOS rele se from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
