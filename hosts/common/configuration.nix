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
    ../../nixos/modules/gaming.nix
    ../../nixos/modules/locale_keymap.nix
    ../../nixos/modules/networking.nix
    ../../nixos/modules/nvidia.nix
    ../../nixos/modules/printing.nix
    ../../nixos/modules/sound.nix
    ../../nixos/modules/services.nix
    # sops-nix/modules/sops
  ];
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
  services.zfs.autoScrub.enable = true;
  networking.hostId = "e4f8879e";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    # Enable automatic login for the user.
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "jan";
  };

  # Enable Accelerometer
  hardware.sensor.iio.enable = true;

  # Needed for Solaar to see Logitech devices.
  hardware.logitech.wireless.enable = true;

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = ["/home/jan/.ssh/id_ed25519"];
  # This is the actual specification of the secrets.
  sops.secrets = {
    github = {
      owner = "jan";
      group = "users";
    };
    login_jan = {neededForUsers = true;};
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jan = {
    isNormalUser = true;
    description = "Jan";
    # initialPassword = "pw321";
    # password = "${pkgs.coreutils-full}/bin/cat /run/secrets-for-users/login_jan";
    # hashedPasswordFile = config.sops.secrets.login_jan.path;
    extraGroups = ["networkmanager" "wheel"];
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
    powertop
    protonmail-bridge
    sops
    smartmontools
    nvtop-nvidia
  ];
  programs.partition-manager.enable = true;

  # Nix Settings
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["jan"]; # Add your own username to the trusted list
  };

  # Set default editor to vim
  environment.variables.EDITOR = "nvim";
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.kdeconnect.enable = true;

  hardware.bluetooth.enable = true;

  nix.optimise.automatic = true;
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 30d";
  # };
  nixpkgs.config.permittedInsecurePackages = ["electron-24.8.6" "electron-22.3.27"];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
