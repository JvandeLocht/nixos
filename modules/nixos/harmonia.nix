{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.harmonia = {
    enable = lib.mkEnableOption "Set up a Harmonia binary cache server";
  };

  config = lib.mkIf config.harmonia.enable {
    services.harmonia = {
      enable = true;
      signKeyPaths = [ config.sops.secrets."harmonia/signing-key".path ];
    };

    sops = {
      secrets = {
        "harmonia/signing-key" = { };
        "cloudflare-acme" = { };
      };
    };

    # Open firewall for Harmonia
    networking.firewall.allowedTCPPorts = [
      443
      80
    ];

    # Ensure Nix daemon trusts the harmonia user for builds
    nix.settings.trusted-users = [ "harmonia" ];

    # Optional: configure log level
    systemd.services.harmonia.environment = {
      RUST_LOG = "info";
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "jan@vandelocht.uk";
      certs."vandelocht.uk" = {
        domain = "*.vandelocht.uk";
        extraDomainNames = [
          "vandelocht.uk"
          "cache.lan.vandelocht.uk"
        ];
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets."cloudflare-acme".path;
        group = "nginx";
      };
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      virtualHosts."cache.lan.vandelocht.uk" = {
        enableACME = true;
        forceSSL = true;

        locations."/".extraConfig = ''
          proxy_pass http://127.0.0.1:5000;
          proxy_set_header Host $host;
          proxy_redirect http:// https://;
          proxy_http_version 1.1;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
        '';
      };
    };
  };
}
