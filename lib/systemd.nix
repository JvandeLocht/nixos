{ lib, pkgs, config, ... }:

with lib;

{
  options.systemdTimers = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        command = mkOption {
          type = types.str;
          description = "The command to execute";
          example = "\${pkgs.rclone}/bin/rclone sync /home remote:backup";
        };

        timer = mkOption {
          type = types.str;
          description = "Timer specification (systemd timer format)";
          example = "daily";
        };

        user = mkOption {
          type = types.str;
          default = "root";
          description = "User to run the service as";
        };

        serviceType = mkOption {
          type = types.str;
          default = "oneshot";
          description = "Systemd service type";
        };
      };
    });
    default = {};
    description = "Simple systemd timer definitions";
    example = {
      backup-task = {
        command = "\${pkgs.rclone}/bin/rclone sync /home remote:backup";
        timer = "daily";
      };
    };
  };

  config = mkIf (config.systemdTimers != {}) {
    systemd.timers = mapAttrs (name: cfg: 
      let
        # Determine if timer is a calendar spec or interval spec
        timerConfig = if (builtins.match ".*[0-9]+[smhd].*" cfg.timer) != null then {
          # Interval-based (e.g., "5m", "1h", "30s")
          OnBootSec = cfg.timer;
          OnUnitActiveSec = cfg.timer;
          Unit = "${name}.service";
        } else {
          # Calendar-based (e.g., "daily", "weekly", "*:0/10")
          OnCalendar = cfg.timer;
          Unit = "${name}.service";
          Persistent = true;
        };
      in {
        wantedBy = [ "timers.target" ];
        timerConfig = timerConfig;
      }
    ) config.systemdTimers;

    systemd.services = mapAttrs (name: cfg: {
      script = ''
        set -eu
        ${cfg.command}
      '';
      serviceConfig = {
        Type = cfg.serviceType;
        User = cfg.user;
      };
    }) config.systemdTimers;
  };
}