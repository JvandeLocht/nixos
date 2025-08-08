{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.podman.proxmox-backup-server = {
    enable = lib.mkEnableOption "Set up proxmox-backup-server container";
  };

  config = lib.mkIf config.podman.proxmox-backup-server.enable {
    #Create directories and run scripts for the containers
    system.activationScripts = {
      script.text = ''
        mkdir -p /tank/apps/proxmox-backup-server/backups
        mkdir -p /tank/apps/proxmox-backup-server/logs
        mkdir -p /tank/apps/proxmox-backup-server/etc
        mkdir -p /tank/apps/proxmox-backup-server/lib
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
    virtualisation.oci-containers.containers = {
      proxmox-backup-server = {
        image = "docker.io/ayufan/proxmox-backup-server:latest";

        environment = {
          "TZ" = "Europe/Amsterdam";
        };

        volumes = [
          "/tank/apps/proxmox-backup-server/backups:/backups"
          "/tank/apps/proxmox-backup-server/etc:/etc/proxmox-backup"
          "/tank/apps/proxmox-backup-server/logs:/var/log/proxmox-backup"
          "/tank/apps/proxmox-backup-server/lib:/var/lib/proxmox-backup"
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
