{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.backrest;
in
{
  options.services.backrest = {
    enable = mkEnableOption "Backrest service";

    bindAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The IP address to bind Backrest to.";
    };

    port = mkOption {
      type = types.port;
      default = 9898;
      description = "The port number for Backrest to listen on.";
    };

    configSecret = mkOption {
      type = types.str;
      description = "The name of the age secret for Backrest configuration.";
    };

    additionalPath = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to add to the PATH of the Backrest service.";
    };
  };

  config = mkIf cfg.enable {
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
    # age.secrets = {
    #   rclone-config = {
    #     file = ../../secrets/rclone-config.age;
    #     path = "/persist/secrets/rclone-config";
    #     symlink = false;
    #   };
    #   ${cfg.configSecret} = {
    #     file = ../../secrets/${cfg.configSecret}.age;
    #     path = "/persist/secrets/${cfg.configSecret}";
    #     symlink = false;
    #   };
    # };
    # systemd.tmpfiles.rules = [
    #   "L /root/.config/rclone/rclone.conf - - - - ${config.age.secrets.rclone-config.path}"
    #   "L /root/.config/backrest/config.json - - - - ${config.age.secrets.${cfg.configSecret}.path}"
    # ];

    systemd.services.backrest = {
      enable = true;
      environment = {
        HOME = "/root";
      };
      path =
        with pkgs;
        [
          rclone
          busybox
          bash
          curl
        ]
        ++ cfg.additionalPath;

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "Run backrest";
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 30;
        ExecStart = "${pkgs.backrest}/bin/backrest -bind-address ${cfg.bindAddress}:${toString cfg.port}";
      };
    };
  };
}
