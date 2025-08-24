# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/configuration.nix
    ./opt-in.nix
    ./sops.nix
  ];
  services.printing = {
    listenAddresses = ["*:631"];
    openFirewall = true;
    allowFrom = ["all"];
    browsing = true;
    defaultShared = true;
  };

  podman = {
    enable = true;
    minio.enable = true;
    proxmox-backup-server.enable = true;
  };

  locale.enable = true;
  # gnome.enable = true;
  nvidia.enable = false;
  gaming.enable = false;
  copyparty.enable = true;
  filen-webdav.enable = true;
  printing.enable = true;
  services.homelab.telegraf.enable = true;
  networking.enable = true;
  zfs-impermanence = {
    enable = true;
    hostId = "3901c199";
  };

  # Enable Tailscale VPN with subnet routing and exit node functionality
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both"; # Enable subnet routing and exit node
    authKeyFile = config.sops.secrets."tailscale/auth-key".path;
    authKeyParameters.baseURL = "headscale.vandelocht.uk";
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jan/.setup";
  };

  #  systemd.services = {
  #    tank-usb-mount = {
  #      enable = true;
  #      after = [ "network.target" ];
  #      wantedBy = [ "default.target" ];
  #      description = "Import zfs pool tank";
  #      serviceConfig = {
  #        Type = "simple";
  #        Restart = "on-failure";
  #        RestartSec = 30;
  #        ExecStart = "${pkgs.zfs}/bin/zpool import tank";
  #      };
  #    };
  #  };

  boot = {
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };

  networking = {
    hostName = "nixnas"; # Define your hostname.
    networkmanager.enable = true;
    firewall = {
      allowPing = true;
      # Enable connection tracking for better NAT traversal
      connectionTrackingModules = [
        "ftp"
        "tftp"
      ];
      extraCommands = ''
        iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns

        # Enable NAT for Tailscale exit node functionality
        # Allow forwarding from Tailscale interface to the internet
        iptables -I FORWARD -i tailscale0 -j ACCEPT
        iptables -I FORWARD -o tailscale0 -j ACCEPT

        # NAT outgoing traffic from Tailscale clients to internet
        # Get the default interface more reliably
        DEFAULT_IFACE=$(${pkgs.iproute2}/bin/ip route show default | ${pkgs.gawk}/bin/awk '/default/ { print $5; exit }' | ${pkgs.coreutils}/bin/head -n1)
        if [ -n "$DEFAULT_IFACE" ]; then
          iptables -t nat -I POSTROUTING -s 100.64.0.0/10 -o "$DEFAULT_IFACE" -j MASQUERADE
        fi
      '';
      extraStopCommands = ''
        # Clean up NAT rules for Tailscale
        iptables -D FORWARD -i tailscale0 -j ACCEPT 2>/dev/null || true
        iptables -D FORWARD -o tailscale0 -j ACCEPT 2>/dev/null || true

        # Clean up MASQUERADE rule more reliably
        DEFAULT_IFACE=$(${pkgs.iproute2}/bin/ip route show default | ${pkgs.gawk}/bin/awk '/default/ { print $5; exit }' | ${pkgs.coreutils}/bin/head -n1)
        if [ -n "$DEFAULT_IFACE" ]; then
          iptables -t nat -D POSTROUTING -s 100.64.0.0/10 -o "$DEFAULT_IFACE" -j MASQUERADE 2>/dev/null || true
        fi
      '';
    };
  };

  sops = {
    secrets = {
      "filen/.filen-cli-auth-config" = {
      };
      "filen/webdav/user" = {};
      "filen/webdav/password" = {};
      "tailscale/auth-key" = {};
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
      # The users must still get created and get a smbpasswd
      # sudo smbpasswd -a User
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
        "k8s" = {
          "path" = "/tank/k8s-csi";
          "valid users" = "k8s";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "k8s";
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
        "media" = {
          "path" = "/tank/media";
          "valid users" = "media";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "media";
          "force group" = "users";
        };
        "haBackup" = {
          "path" = "/tank/haBackup";
          "valid users" = "ha";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "ha";
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
    restic = {
      backups = {
        system = {
          passwordFile = "${config.sops.secrets."restic/nixnas/password".path}";
          environmentFile = "${config.sops.templates.restic-env.path}";
          initialize = true;
          timerConfig = {
            OnCalendar = "*-*-* 22:00:00";
            Persistent = true;
          };
          paths = [
            "/home/jan"
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
          repository = "s3:http://192.168.178.58:9000/nixnas-restic";
          progressFps = 0.001;
          pruneOpts = [
            "--keep-daily 1"
            "--keep-weekly 1"
            "--keep-monthly 1"
            "--keep-yearly 1"
          ];
          extraBackupArgs = ["--verbose"];
          backupPrepareCommand = ''
            ${pkgs.curl}/bin/curl -d "Restic Backup: Starting system backup..." $(${pkgs.busybox}/bin/cat ${config.sops.secrets."restic/nixnas/ntfy".path})
          '';
          backupCleanupCommand = ''
            if [ $? -eq 0 ]; then
              ${pkgs.curl}/bin/curl -d "Restic Backup: System backup completed successfully at $(${pkgs.coreutils}/bin/date)" $(${pkgs.busybox}/bin/cat ${config.sops.secrets."restic/nixnas/ntfy".path})
              ${pkgs.curl}/bin/curl -fsS --retry 3 $(${pkgs.busybox}/bin/cat ${config.sops.secrets."restic/nixnas/healthcheck".path})
            else
              ${pkgs.curl}/bin/curl -d "Restic Backup: System backup failed at $(${pkgs.coreutils}/bin/date)" $(${pkgs.busybox}/bin/cat ${config.sops.secrets."restic/nixnas/ntfy".path})
            fi
          '';
        };
        apps = {
          passwordFile = "${config.sops.secrets."restic/nixnas/password".path}";
          environmentFile = "${config.sops.templates.restic-env.path}";
          initialize = true;
          timerConfig = {
            OnCalendar = "Sun *-*-* 00:00:00";
            Persistent = true;
          };
          paths = [
            "/tank/k8s-csi"
          ];
          repository = "s3:http://192.168.178.58:9000/nixnas-restic";
          progressFps = 0.001;
          pruneOpts = [
            "--keep-last 1"
          ];
          extraBackupArgs = ["--verbose"];
          backupPrepareCommand = ''
            ${pkgs.curl}/bin/curl -d "Restic Backup: Starting apps backup..." $(${pkgs.busybox}/bin/cat ${config.sops.secrets."restic/nixnas/ntfy".path})
          '';
          backupCleanupCommand = ''
            if [ $? -eq 0 ]; then
              ${pkgs.curl}/bin/curl -d "Restic Backup: Apps backup completed successfully at $(${pkgs.coreutils}/bin/date)" $(${pkgs.busybox}/bin/cat ${config.sops.secrets."restic/nixnas/ntfy".path})
              ${pkgs.curl}/bin/curl -m 10 --retry 5 $(${pkgs.busybox}/bin/cat ${config.sops.secrets."restic/nixnas/healthcheck".path})
            else
              ${pkgs.curl}/bin/curl -d "Restic Backup: Apps backup failed at $(${pkgs.coreutils}/bin/date)" $(${pkgs.busybox}/bin/cat ${config.sops.secrets."restic/nixnas/ntfy".path})
            fi
          '';
        };
      };
    };
    gvfs.enable = true;
    udisks2.enable = true;
    spice-vdagentd.enable = false;
    spice-autorandr.enable = false;
    spice-webdavd.enable = false;
    qemuGuest.enable = false;
  };

  # security.sudo.wheelNeedsPassword = false;
  users = {
    # groups.samba = {};
    users = {
      "jan" = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.jan-nixnas.path;
        home = "/home/jan";
        extraGroups = [
          "wheel"
          "networkmanager"
          "users"
        ];
        linger = true;
      };
      # For Samba shares
      "k8s" = {
        isSystemUser = true;
        group = "users";
      };
      "jacky" = {
        isSystemUser = true;
        group = "users";
      };
      "media" = {
        isSystemUser = true;
        group = "users";
      };
      "ha" = {
        isSystemUser = true;
        group = "users";
      };
    };
  };
  nix-settings.maxJobs = 1;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (with pkgs; [
      # nixvim
      spice
      tmux
    ])
    ++ (with inputs; [
      ]);

  sops = {
    secrets = {
      "filen/webdav/user" = {};
      "filen/webdav/password" = {};
      "restic/nixnas/password" = {};
      "restic/nixnas/healthcheck" = {};
      "restic/nixnas/ntfy" = {};
      "tailscale/auth-key" = {};
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
      restic-env = {
        content = ''
          AWS_ACCESS_KEY_ID=${config.sops.placeholder."minio/accessKey"}
          AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."minio/secretKey"}
        '';
      };
    };
  };

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
