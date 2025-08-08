{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.podman.minio = {
    enable = lib.mkEnableOption "Set up minio container";
  };

  config = lib.mkIf config.podman.minio.enable {
    sops = {
      secrets = {
        "minio/accessKey" = { };
        "minio/secretKey" = { };
      };
    };
    # Create directories and run scripts for the containers
    system.activationScripts = {
      script.text = ''
        mkdir -p /tank/apps/minio
        if ! ${pkgs.podman}/bin/podman secret exists minio_root_user; then
          ${pkgs.podman}/bin/podman secret create minio_root_user ${
            config.sops.secrets."minio/accessKey".path
          }
        fi
        if ! ${pkgs.podman}/bin/podman secret exists minio_root_password; then
          ${pkgs.podman}/bin/podman secret create minio_root_password ${
            config.sops.secrets."minio/secretKey".path
          }
        fi
      '';
    };
    networking.firewall = {
      enable = true;
      allowedTCPPortRanges = [
        {
          from = 9000;
          to = 9001;
        }
      ];
    };
    virtualisation.oci-containers.containers = {
      minio = {
        image = "quay.io/minio/minio";

        environment = {
          "TZ" = "Europe/Amsterdam";
        };

        volumes = [
          "/tank/apps/minio:/data"
        ];

        ports = [
          "9000:9000"
          "9001:9001"
        ];

        cmd = [
          "server"
          "/data"
          "--console-address=:9001"
        ];

        extraOptions = [
          "--secret=minio_root_user,type=env,target=MINIO_ROOT_USER"
          "--secret=minio_root_password,type=env,target=MINIO_ROOT_PASSWORD"
          "--name=minio"
          "--hostname=minio"
        ];
      };
    };
  };
}
