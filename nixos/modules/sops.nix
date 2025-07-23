{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.sops-config;
in
{
  options.sops-config = {
    enable = mkEnableOption "sops-nix configuration";
  };

  config = mkIf cfg.enable {
    sops = {
      age = {
        keyFile = "/persist/sops/age/keys.txt";
        generateKey = false;
      };
      secrets = {
        jan-groot = {
          neededForUsers = true;
        };
      defaultSopsFile = ../../secrets/secrets.yaml;
    };

    # Install sops package for manual operations
    environment.systemPackages = with pkgs; [
      sops
      age
    ];
  };
}
