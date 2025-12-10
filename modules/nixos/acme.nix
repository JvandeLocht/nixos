{
  pkgs,
  lib,
  config,
  ...
}: {
  options.acme-cloudflare = {
    enable = lib.mkEnableOption "Set up acme client for cloudflare";
  };

  config = lib.mkIf config.acme-cloudflare.enable {
    sops = {
      secrets = {
        "cloudflare-acme" = {};
      };
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
  };
}
