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
        "filen/webdav/user" = { };
        "filen/webdav/password" = { };
      templates = {
        rclone-config.content = ''
          [filen]
          type = webdav
          url = http://192.168.178.152:9090
          vendor = other
          user = "${config.sops.placeholder."filen/webdav/user"}"
          pass = "${config.sops.placeholder."filen/webdav/password"}"
        '';
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
