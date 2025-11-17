{
  config,
  lib,
  pkgs,
  ...
}:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = "jan@vandelocht.uk";
    certs."vandelocht.uk" = {
      domain = "*.vandelocht.uk";
      extraDomainNames = [
        "vandelocht.uk"
        "img.lan.vandelocht.uk"
        "jellyfin.lan.vandelocht.uk"
      ];
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."cloudflare-acme".path;
      group = "nginx";
    };
  };
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "img.lan.vandelocht.uk" = {
        useACMEHost = "vandelocht.uk";
        forceSSL = true;
        locations."/".extraConfig = ''
          proxy_pass http://127.0.0.1:2283;
          proxy_set_header Host $host;
          proxy_redirect http:// https://;
          proxy_http_version 1.1;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
        '';
      };
      "jellyfin.lan.vandelocht.uk" = {
        useACMEHost = "vandelocht.uk";
        forceSSL = true;
        locations."/".extraConfig = ''
          proxy_pass http://127.0.0.1:8096;
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
  sops = {
    secrets = {
      "cloudflare-acme" = { };
    };
  };
  networking.firewall.allowedTCPPorts = [
    443
    80
  ];
}
