{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.backrest;
in {
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
      default = [];
      description = "Additional packages to add to the PATH of the Backrest service.";
    };
  };

  config = mkIf cfg.enable {
    age.secrets = {
      rclone-config = {
        file = ../../secrets/rclone-config.age;
        path = "/persist/secrets/rclone-config";
        symlink = false;
      };
      ${cfg.configSecret} = {
        file = ../../secrets/${cfg.configSecret}.age;
        path = "/persist/secrets/${cfg.configSecret}";
        symlink = false;
      };
    };
    systemd.tmpfiles.rules = [
      "L /root/.config/rclone/rclone.conf - - - - ${config.age.secrets.rclone-config.path}"
      "L /root/.config/backrest/config.json - - - - ${config.age.secrets.${cfg.configSecret}.path}"
    ];

    systemd.services.backrest = {
      enable = true;
      environment = {
        HOME = "/root";
      };
      path = with pkgs; [rclone busybox bash curl] ++ cfg.additionalPath;

      after = ["network.target"];
      wantedBy = ["multi-user.target"];
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
