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
  };
}
