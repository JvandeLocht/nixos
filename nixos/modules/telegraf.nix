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

    collectTemperatureMetrics = mkOption {
      type = types.bool;
      default = true;
      description = "Collect system temperature metrics (CPU, motherboard, etc.)";
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
      templates = {
        "influxdb.env" = {
          content = ''
            influx_token=${config.sops.placeholder."telegraf/influxdb_token"}
          '';
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
      environmentFiles = [ config.sops.templates."influxdb.env".path ];

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

        inputs = {
          # System metrics
          cpu = [
            {
              percpu = true;
              totalcpu = true;
              collect_cpu_time = false;
              report_active = false;
            }
          ];

          zfs = {
            poolMetrics = true;
            datasetMetrics = true;
          };

          smart = [
            {
              use_sudo = true;
              attributes = true;
              excludes = [ "/dev/pass*" ];
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

          procstat = [
            # Monitor all processes (top processes by CPU/memory)
            {
              pattern = ".*";
              pid_finder = "native";

              # Fields to collect
              fieldpass = [
                "cpu_usage"
                "memory_rss"
                "memory_vms"
                "memory_swap"
                "num_threads"
                "pid"
              ];

              # This will give us a percentage
              pid_tag = false;
              process_name = "process_name";
            }
          ];

          # Temperature sensors
          sensors = mkIf cfg.collectTemperatureMetrics [
            {
              # Remove sensors that you don't want to monitor
              # remove_numbers = true;
              # Timeout for running the sensors command
              timeout = "5s";
            }
          ];

          # Temperature monitoring via thermal zones (alternative/additional method)
          temp = mkIf cfg.collectTemperatureMetrics [
            {
              # This monitors /sys/class/thermal/thermal_zone*/temp
            }
          ];

          exec = [
            {
              commands =
                let
                  zfsHealthScript = pkgs.writeShellScript "zfs-health-monitor" ''
                    #!${pkgs.bash}/bin/bash
                    # Get all ZFS pools
                    pools=$(${pkgs.zfs}/bin/zpool list -H -o name 2>/dev/null)

                    if [ -z "$pools" ]; then
                      exit 0
                    fi

                    # Function to convert health status to numeric value
                    health_to_numeric() {
                      case "$1" in
                        "ONLINE") echo 0 ;;
                        "DEGRADED") echo 1 ;;
                        "FAULTED") echo 2 ;;
                        "OFFLINE") echo 3 ;;
                        "REMOVED") echo 4 ;;
                        "UNAVAIL") echo 5 ;;
                        *) echo 99 ;;
                      esac
                    }

                    # Output metrics in InfluxDB line protocol format
                    for pool in $pools; do
                      # Get pool health and statistics
                      health=$(${pkgs.zfs}/bin/zpool list -H -o health "$pool" 2>/dev/null | tr -d '[:space:]')
                      health_numeric=$(health_to_numeric "$health")

                      # Get pool statistics in one call
                      stats=$(${pkgs.zfs}/bin/zpool list -Hp -o size,allocated,free,fragmentation,capacity "$pool" 2>/dev/null)

                      if [ -n "$stats" ]; then
                        read -r size allocated free frag capacity <<< "$stats"

                        # Remove % from capacity if present
                        capacity=''${capacity%\%}

                        # Handle dash values for fragmentation
                        if [ "$frag" = "-" ]; then
                          frag=0
                        fi

                        # Output in InfluxDB line protocol format
                        echo "zpool_health,pool=$pool health=\"$health\",health_numeric=$health_numeric"
                        echo "zpool_stats,pool=$pool size=$size,allocated=$allocated,free=$free,fragmentation=$frag,capacity=$capacity"
                      fi
                    done
                  '';
                in
                [ "${zfsHealthScript}" ];
              timeout = "5s";
              interval = "60s";
              data_format = "influx";
              name_suffix = "_health";
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
