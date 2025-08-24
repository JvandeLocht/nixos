{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.filen-webdav = {
    enable = lib.mkEnableOption "Enable Filen WebDAV service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Port for the WebDAV server";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Hostname/IP to bind the WebDAV server to";
    };
  };

  config = lib.mkIf config.filen-webdav.enable {
    # Ensure SOPS secrets are available
    sops = {
      secrets = {
        "filen/.filen-cli-auth-config" = {
          owner = "filen";
          group = "filen";
        };
        "filen/webdav/user" = {
          owner = "filen";
          group = "filen";
        };
        "filen/webdav/password" = {
          owner = "filen";
          group = "filen";
        };
      };
    };

    # Create system user for filen service
    users = {
      groups.filen = {};
      users.filen = {
        isSystemUser = true;
        group = "filen";
        home = "/var/lib/filen";
        createHome = true;
      };
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ config.filen-webdav.port ];

    # Create directories and setup auth config
    system.activationScripts = {
      filen-webdav-setup = {
        text = ''
          mkdir -p /var/lib/filen/.config/filen-cli
          cp ${config.sops.secrets."filen/.filen-cli-auth-config".path} /var/lib/filen/.config/filen-cli/.filen-cli-auth-config
          chown -R filen:filen /var/lib/filen/.config
          chmod 600 /var/lib/filen/.config/filen-cli/.filen-cli-auth-config
        '';
        deps = [ "setupSecrets" ];
      };
    };

    # SystemD service for Filen WebDAV
    systemd.services.filen-webdav = {
      description = "Filen WebDAV Server";
      after = [ "network.target" "sops-nix.service" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "sops-nix.service" ];

      serviceConfig = {
        Type = "simple";
        User = "filen";
        Group = "filen";
        Restart = "always";
        RestartSec = 10;
        WorkingDirectory = "/var/lib/filen";
        
        # Environment variables
        Environment = [
          "HOME=/var/lib/filen"
          "FILEN_CLI_DATA_DIR=/var/lib/filen/.config/filen-cli"
        ];

        # Security settings
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/filen" ];
        
        # Load WebDAV credentials from SOPS secrets
        LoadCredential = [
          "webdav-user:${config.sops.secrets."filen/webdav/user".path}"
          "webdav-password:${config.sops.secrets."filen/webdav/password".path}"
        ];
      };

      script = ''
        WEBDAV_USER=$(cat $CREDENTIALS_DIRECTORY/webdav-user)
        WEBDAV_PASSWORD=$(cat $CREDENTIALS_DIRECTORY/webdav-password)
        
        exec ${pkgs.filen-cli}/bin/filen webdav \
          --w-user "$WEBDAV_USER" \
          --w-password "$WEBDAV_PASSWORD" \
          --w-port ${toString config.filen-webdav.port} \
          --w-hostname ${config.filen-webdav.hostname}
      '';
    };
  };
}