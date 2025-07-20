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

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address to bind the WebDAV server to";
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

    wUser = lib.mkOption {
      type = lib.types.str;
      default = "Filen";
      description = "filen-webdav User";
    };

    wPassword = lib.mkOption {
      type = lib.types.str;
      default = "Password";
      description = "filen-webdav Password";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
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

        ExecStart = "${pkgs.filen-cli}/bin/filen-cli webdav start --port ${toString cfg.port} --hostname ${cfg.bindAddress} --w-user ${cfg.wUser} --w-password ${cfg.wPassword}";

        # Security settings
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
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
