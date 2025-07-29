{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.homelab.telegraf;
in
{
  options.services.homelab.telegraf = {
    enable = mkEnableOption "Telegraf metrics collection for HomeLab";

    influxdbUrl = mkOption {
      type = types.str;
      default = "http://192.168.178.153:80";
      description = "InfluxDB server URL";
    };

    organization = mkOption {
      type = types.str;
      default = "HomeLab";
      description = "InfluxDB organization";
    };

    bucket = mkOption {
      type = types.str;
      default = "nixnas";
      description = "InfluxDB bucket name";
    };

    collectZfsMetrics = mkOption {
      type = types.bool;
      default = true;
      description = "Collect ZFS pool and dataset metrics";
    };

    collectSmartMetrics = mkOption {
      type = types.bool;
      default = true;
      description = "Collect SMART disk health metrics";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "telegraf";
      description = "User to run the service as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "telegraf";
      description = "Group to run the service as";
    };
  };

  config = mkIf cfg.enable {
    sops = {
      secrets = {
        "telegraf/influxdb_token" = {
          owner = cfg.user;
          group = cfg.group;
        };
      };
    };

    users.users.${cfg.user} = {
      extraGroups = [ "disk" ];
    };

    services.telegraf = {
      enable = true;
      environmentFiles = [ config.sops.secrets."telegraf/influxdb_token".path ];

      extraConfig = {
        agent = {
          interval = "30s";
          round_interval = true;
          metric_batch_size = 1000;
          metric_buffer_limit = 10000;
          collection_jitter = "0s";
          flush_interval = "10s";
          flush_jitter = "0s";
          precision = "";
          hostname = config.networking.hostName;
          omit_hostname = false;
        };

        outputs.influxdb_v2 = [
          {
            urls = [ cfg.influxdbUrl ];
            token = "\${influx_token}";
            organization = cfg.organization;
            bucket = cfg.bucket;
            timeout = "5s";
          }
        ];

        inputs =
          {
            # System metrics
            cpu = [
              {
                percpu = true;
                totalcpu = true;
                collect_cpu_time = false;
                report_active = false;
              }
            ];

            disk = [
              {
                ignore_fs = [
                  "tmpfs"
                  "devtmpfs"
                  "devfs"
                  "iso9660"
                  "overlay"
                  "aufs"
                  "squashfs"
                ];
              }
            ];

            diskio = [ { } ];

            kernel = [ { } ];

            mem = [ { } ];

            processes = [ { } ];

            swap = [ { } ];

            system = [ { } ];

            # Network metrics
            net = [
              {
                interfaces = [ "*" ];
              }
            ];

            netstat = [ { } ];

            # Additional system metrics
            interrupts = [ { } ];

            linux_sysctl_fs = [ { } ];
          }
          // optionalAttrs cfg.collectZfsMetrics {
            # ZFS metrics
            zfs = [
              {
                kstatPath = "/proc/spl/kstat/zfs";
                poolMetrics = true;
                datasetMetrics = true;
              }
            ];
          }
          // optionalAttrs cfg.collectSmartMetrics {
            # SMART disk health metrics
            smart = [
              {
                use_sudo = true;
                attributes = true;
                excludes = [ "/dev/pass*" ];
              }
            ];
          };
      };
    };

    # Required for SMART monitoring
    security.sudo.extraRules = mkIf cfg.collectSmartMetrics [
      {
        commands = [
          {
            command = "/run/current-system/sw/bin/smartctl";
            options = [ "NOPASSWD" ];
          }
        ];
        users = [ cfg.user ];
      }
    ];

    # Add required packages to telegraf systemd service path
    systemd.services.telegraf = {
      path = with pkgs; [
        smartmontools
        lm_sensors
        nvme-cli
      ];
      environment = {
        PATH = lib.mkForce "/run/wrappers/bin:/run/current-system/sw/bin:${
          lib.makeBinPath (
            with pkgs;
            [
              smartmontools
              lm_sensors
              nvme-cli
            ]
          )
        }";
      };
    };
  };
}
