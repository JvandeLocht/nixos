{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.filen-webdav;
in
{
  options.services.filen-webdav = {
    enable = lib.mkEnableOption "Filen WebDAV server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Port to listen on for WebDAV connections";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "filen";
      description = "User to run the service as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = "Group to run the service as";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/persist/filen";
      description = "Directory to store filen-webdav data";
    };

    wUserFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to file containing WebDAV username";
    };

    wPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to file containing WebDAV password";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    sops = {
      secrets = {
        "filen/.filen-cli-auth-config" = {
          path = "/persist/filen/.filen-cli-auth-config";
          owner = cfg.user;
          group = cfg.group;
        };
      };
    };

    users.groups.${cfg.group} = { };

    systemd.services.filen-webdav = {
      description = "Filen WebDAV Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        Restart = "always";
        RestartSec = 10;

        ExecStart =
          let
            wUserArg = lib.optionalString (cfg.wUserFile != null) "${pkgs.busybox}/bin/cat ${cfg.wUserFile}";
            wPasswordArg = lib.optionalString (
              cfg.wPasswordFile != null
            ) "${pkgs.busybox}/bin/cat ${cfg.wPasswordFile}";
          in
          "${pkgs.filen-cli}/bin/filen webdav start --w-port ${toString cfg.port} --w-user ${wUserArg} --w-password ${wPasswordArg}";

        # Security settings
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;

        # Allow reading secret files
        ReadOnlyPaths = lib.optionals (cfg.wUserFile != null || cfg.wPasswordFile != null) (
          lib.filter (x: x != null) [
            cfg.wUserFile
            cfg.wPasswordFile
          ]
        );
      };

      preStart = ''
        # Ensure data directory exists
        mkdir -p ${cfg.dataDir}
        chown ${cfg.user}:${cfg.group} ${cfg.dataDir}
      '';
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.enable [ cfg.port ];
  };
}
