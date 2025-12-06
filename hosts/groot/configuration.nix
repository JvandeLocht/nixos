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
    ../../lib/systemd.nix
  ];

  specialisationConfig.enable = true;
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

  environment.systemPackages = with pkgs; [
    cifs-utils
  ];
  sops = {
    secrets = {
      "smb/truenas/username" = { };
      "smb/truenas/domain" = { };
      "smb/truenas/password" = { };
      "minio/accessKey" = { };
      "minio/secretKey" = { };
      "restic/groot/password" = { };
      "restic/groot/healthcheck" = { };
      "restic/groot/ntfy" = { };
    };
    templates = {
      smb-secret = {
        content = ''
          username=${config.sops.placeholder."smb/truenas/username"}
          domain=${config.sops.placeholder."smb/truenas/domain"}
          password=${config.sops.placeholder."smb/truenas/password"}
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
    device = "//192.168.178.58/jan";
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
    restic =
      let
        notifyScript = pkgs.writeShellScript "restic-notify" ''
          USERNAME=$(${pkgs.coreutils}/bin/who | ${pkgs.coreutils}/bin/head -1 | ${pkgs.gawk}/bin/awk '{print $1}' || echo "")
          if [ -n "$USERNAME" ]; then
            USER_UID=$(${pkgs.coreutils}/bin/id -u "$USERNAME" 2>/dev/null || echo "")
            if [ -n "$USER_UID" ]; then
              DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_UID/bus"
              USER_DISPLAY=":0"
              ${pkgs.sudo}/bin/sudo -u "$USERNAME" \
                DISPLAY="$USER_DISPLAY" \
                DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
                ${pkgs.libnotify}/bin/notify-send "$@" 2>/dev/null || true
            fi
          fi
        '';
      in
      {
        backups = {
          remotebackup = {
            passwordFile = "${config.sops.secrets."restic/groot/password".path}";
            environmentFile = "${config.sops.templates.restic-env.path}";
            initialize = true;
            timerConfig = {
              OnCalendar = "hourly";
              Persistent = true;
            };
            paths = [
              "/persist"
              "/home/jan"
            ];
            exclude = [
              "/var/cache"
              "/home/*/.cache"
              "/home/*/.local/share"
              "/home/*/Bilder"
              "/home/*/.ollama"
              "/home/*/BackupK8sCSI"
              "/persist/var/lib/ollama"
              "/persist/var/lib/libvirt"
              "/persist/var/lib/containers"
              "/persist/var/lib/systemd"
            ];
            repository = "s3:http://192.168.178.58:9000/groot-restic";
            progressFps = 0.001;
            pruneOpts = [
              "--keep-daily 3"
              "--keep-weekly 5"
              "--keep-monthly 5"
              "--keep-yearly 5"
            ];
            extraBackupArgs = [ "--verbose" ];
            backupPrepareCommand = ''
              ${notifyScript} "Restic Backup" "Starting backup to remote repository..."
            '';
            backupCleanupCommand = ''
              if [ $? -eq 0 ]; then
                ${notifyScript} "Restic Backup" "Backup completed successfully at $(${pkgs.coreutils}/bin/date)"
                ${pkgs.curl}/bin/curl -fsS --retry 3 $(${pkgs.busybox}/bin/cat ${
                  config.sops.secrets."restic/groot/healthcheck".path
                })
              else
                ${notifyScript} -u critical "Restic Backup" "Backup failed at $(${pkgs.coreutils}/bin/date)"
              fi
            '';
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

  # This value determines the NixOS rele se from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
