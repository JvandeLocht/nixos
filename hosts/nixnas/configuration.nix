# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  zfsCompatibleKernelPackages =
    lib.filterAttrs
    (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name)
        != null
        && (builtins.tryEval kernelPackages).success
        && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    )
    pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in {
  imports = [
    ./hardware-configuration.nix
    ../common/configuration.nix
    ./opt-in.nix
  ];

  podman = {
    enable = true;
    minio.enable = true;
    proxmox-backup-server.enable = true;
  };

  locale.enable = true;
  # gnome.enable = true;
  nvidia.enable = false;
  gaming.enable = false;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jan/.setup";
  };

  systemd.services = {
    tank-usb-mount = {
      enable = true;
      after = ["network.target"];
      wantedBy = ["default.target"];
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
    # Note this might jump back and forth as kernels are added or removed.
    kernelPackages = latestKernelPackage;
    # Bootloader.
    loader = {
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
    initrd.postMountCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';
  };

  networking = {
    hostName = "nixnas"; # Define your hostname.
    hostId = "3901c199";
    networkmanager.enable = true;
    firewall = {
      allowPing = true;
      extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
    };
  };

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
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          security = "user";
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          #"use sendfile" = "yes";
          # "max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "192.168.178. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        "tank" = {
          "path" = "/tank";
          "valid users" = "jan";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "jan";
          "force group" = "users";
        };
        "arm" = {
          "path" = "/tank/arm";
          "valid users" = "arm";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "arm";
          "force group" = "users";
        };
        "JackyJan" = {
          "path" = "/tank/JackyJan";
          "valid users" = "jan, jacky";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "arm";
          "force group" = "users";
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
    avahi.enable = true;

    openssh.enable = true;
    zfs.autoScrub.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    spice-vdagentd.enable = true;
    spice-autorandr.enable = true;
    spice-webdavd.enable = true;
    qemuGuest.enable = true;
    backrest = {
      enable = true;
      bindAddress = "0.0.0.0";
      port = 9898;
      configSecret = "backrest-nixnas";
    };
  };

  # security.sudo.wheelNeedsPassword = false;
  users = {
    # groups.samba = {};
    users = {
      "jan" = {
        isNormalUser = true;
        # password = "password"; # Change this once your computer is set up!
        hashedPasswordFile = config.age.secrets.jan-nixnas.path;
        home = "/home/jan";
        extraGroups = ["wheel" "networkmanager" "users"];
        linger = true;
      };
      "arm" = {
        isSystemUser = true;
        group = "users";
      };
      "jacky" = {
        isSystemUser = true;
        group = "users";
      };
    };
  };
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["jan"]; # Add your own username to the trusted list
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      git
      # nixvim
      spice
      tmux
    ])
    ++ (with inputs; [
      # agenix.packages.x86_64-linux.default
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
