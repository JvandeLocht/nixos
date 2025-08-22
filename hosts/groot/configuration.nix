# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ../common/configuration.nix
    ./opt-in.nix
    ./sops.nix
  ];

  gaming.enable = true;
  hyprland.enable = true;
  locale.enable = true;
  nvidia.enable = true;
  networking.enable = true;
  power.enable = true;
  printing.enable = true;
  services.enable = true;
  soundConfig.enable = true;
  zfs-impermanence = {
    enable = true;
    hostId = "e4f8879e";
  };

  environment.systemPackages = [ pkgs.cifs-utils ];
  sops = {
    secrets = {
      "smb/nixnas/username" = { };
      "smb/nixnas/domain" = { };
      "smb/nixnas/password" = { };
      "minio/accessKey" = { };
      "minio/secretKey" = { };
    };
    templates = {
      smb-secret = {
        content = ''
          username=${config.sops.placeholder."smb/nixnas/username"}
          domain=${config.sops.placeholder."smb/nixnas/domain"}
          password=${config.sops.placeholder."smb/nixnas/password"}
        '';
      };
      restic-env = {
        content = ''
          AWS_ACCESS_KEY_ID=${config.sops.placeholder."minio/accessKey"}
          AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."minio/secretKey"}
        '';
      };
    };
  };
  fileSystems."/mnt/share" = {
    device = "//192.168.178.58/tank";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in
      [ "${automount_opts},credentials=${config.sops.templates.smb-secret.path},uid=1000,gid=100" ];
  };

  boot = {
    kernelPatches = [
      {
        name = "amd-tablet-sfh";
        patch = ../../patches/amd-tablet-sfh.patch;
      }
    ];
    # For Makemkv
    kernelModules = [ "sg" ];
  };

  networking = {
    hostName = "groot"; # Define your hostname.
  };

  hardware = {
    # Enable Accelerometer
    sensor.iio.enable = true;
    # Needed for Solaar to see Logitech devices.
    logitech.wireless.enable = true;
    bluetooth.enable = true;
    spacenavd.enable = true;
  };

  users.users = {
    jan = {
      isNormalUser = true;
      description = "Jan";
      hashedPasswordFile = config.sops.secrets.jan-groot.path;
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "libvirtd"
        "dialout"
      ];
    };
  };
  # Enable the X11 windowing system.
  services = {
    tailscale = {
      enable = true;
    };
    backrest = {
      enable = true;
      bindAddress = "127.0.0.1"; # or "0.0.0.0" for the second snippet
      port = 9898;
      # configSecret = "backrest-groot"; # or "backrest-nixnas" for the second snippet
      additionalPath = with pkgs; [ mako ];
    };
    restic = {
      backups = {
        remotebackup = {
          passwordFile = "${config.sops.secrets."restic/groot/password".path}";
          environmentFile = "${config.sops.templates.restic-env.path}";
          initialize = true;
          paths = [
            "/persist"
          ];
          exclude = [
            "/var/cache"
            "/home/*/.cache"
            "/home/*/.local/share"
            "/home/*/Bilder"
            "/persist/var/lib/ollama"
            "/persist/var/lib/libvirt"
            "/persist/var/lib/containers"
            "/persist/var/lib/systemd"
          ];
          repository = "s3:http://192.168.178.58:9000/groot-restic";
        };
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
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl1", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/leds/asus::kbd_backlight/brightness"
    '';
  };
  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6"
    "electron-22.3.27"
    "electron-25.9.0"
    "electron-27.3.11"
    "libsoup-2.74.3"
  ];

  sops = {
    secrets = {
      "filen/webdav/user" = { };
      "filen/webdav/password" = { };
      "restic/groot/password" = { };
      "restic/groot/healthcheck" = { };
      "restic/groot/ntfy" = { };
      "backrest/groot/password" = { };
    };
    templates = {
      "rclone.conf" = {
        path = "/root/.config/rclone/rclone.conf";
        content = ''
          [filen]
          type = webdav
          url = http://192.168.178.152:9090
          vendor = other
          user = ${config.sops.placeholder."filen/webdav/user"}
          pass = ${config.sops.placeholder."filen/webdav/password"}
        '';
      };
      backrest-groot = {
        path = "/root/.config/backrest/config.json";
        content = ''
          {
            "modno": 4,
            "version": 3,
            "instance": "groot",
            "repos": [
              {
                "id": "groot",
                "uri": "rclone:filen:Backups/restic/groot",
                "password": "${config.sops.placeholder."restic/groot/password"}",
                "prunePolicy": {
                  "schedule": {
                    "maxFrequencyDays": 30,
                    "clock": "CLOCK_LAST_RUN_TIME"
                  },
                  "maxUnusedPercent": 10
                },
                "checkPolicy": {
                  "schedule": {
                    "maxFrequencyDays": 30,
                    "clock": "CLOCK_LAST_RUN_TIME"
                  },
                  "readDataSubsetPercent": 10
                },
                "autoUnlock": true,
                "commandPrefix": {}
              }
            ],
            "plans": [
              {
                "id": "backup",
                "repo": "groot",
                "paths": [
                  "/home/jan",
                  "/persist"
                ],
                "excludes": [
                  "/var/cache",
                  "/home/*/.cache",
                  "/home/*/.local/share",
                  "/home/*/Bilder",
                  "/persist/var/lib/ollama",
                  "/persist/var/lib/libvirt",
                  "/persist/var/lib/containers",
                  "/persist/var/lib/systemd"
                ],
                "schedule": {
                  "maxFrequencyDays": 1,
                  "clock": "CLOCK_LAST_RUN_TIME"
                },
                "retention": {
                  "policyTimeBucketed": {
                    "daily": 1,
                    "weekly": 1,
                    "monthly": 1,
                    "yearly": 1
                  }
                },
                "hooks": [
                  {
                    "conditions": [
                      "CONDITION_SNAPSHOT_SUCCESS"
                    ],
                    "actionCommand": {
                      "command": "curl -fsS --retry 3 ${config.sops.placeholder."restic/groot/healthcheck"}"
                    }
                  },
                  {
                    "conditions": [
                      "CONDITION_SNAPSHOT_END"
                    ],
                    "actionCommand": {
                      "command": "curl -d {{ .ShellEscape .Summary }} ${
                        config.sops.placeholder."restic/groot/ntfy"
                      }"
                    }
                  },
                  {
                    "conditions": [
                      "CONDITION_SNAPSHOT_START"
                    ],
                    "actionCommand": {
                      "command": "curl -d {{ .ShellEscape .Summary }} ${
                        config.sops.placeholder."restic/groot/ntfy"
                      }"
                    }
                  }
                ]
              }
            ],
            "auth": {
              "users": [
                {
                  "name": "jan",
                  "passwordBcrypt": "${config.sops.placeholder."backrest/groot/password"}"
                }
              ]
            }
          }
        '';
      };
    };
  };

  # This value determines the NixOS rele se from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
