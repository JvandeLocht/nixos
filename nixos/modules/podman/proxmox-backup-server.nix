{ pkgs
, lib
, config
, ...
}: {
  options.podman.proxmox-backup-server = {
    enable = lib.mkEnableOption "Set up proxmox-backup-server container";
  };

  config = lib.mkIf config.podman.proxmox-backup-server.enable {
    #Create directories and run scripts for the containers
    system.activationScripts = {
      script.text = ''
        mkdir -p /apps/proxmox-backup-server/backups
        mkdir -p /apps/proxmox-backup-server/logs
        mkdir -p /apps/proxmox-backup-server/etc
        mkdir -p /apps/proxmox-backup-server/lib
      '';
    };
    networking.firewall = {
      enable = true;
      allowedTCPPortRanges = [
        {
          from = 8007;
          to = 8007;
        }
      ];
    };
    systemd.services = {
      podman-usb-mount-pbs = {
        enable = true;
        after = [ "network.target" ];
        wantedBy = [ "default.target" ];
        description = "wait for usb mount";
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 5;
          ExecStart = "${pkgs.busybox}/bin/mountpoint -q /apps/proxmox-backup-server/";
        };
      };
    };
    virtualisation.oci-containers.containers = {
      proxmox-backup-server = {
        image = "docker.io/ayufan/proxmox-backup-server:latest";

        dependsOn = [ "usb-mount-pbs" ];

        environment = {
          "TZ" = "Europe/Amsterdam";
        };

        volumes = [
          "/apps/proxmox-backup-server/backups:/backups"
          "/apps/proxmox-backup-server/etc:/etc/proxmox-backup"
          "/apps/proxmox-backup-server/logs:/var/log/proxmox-backup"
          "/apps/proxmox-backup-server/lib:/var/lib/proxmox-backup"
        ];

        ports = [
          "8007:8007"
        ];


        extraOptions = [
          "--name=proxmox-backup-server"
          "--hostname=proxmox-backup-server"
          "--tmpfs=/run"
          "--memory=2g"
        ];
      };
    };
  };
}

