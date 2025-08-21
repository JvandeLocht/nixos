{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops = {
    age = {
      keyFile = "/persist/sops/age/keys.txt";
      generateKey = false;
    };
    secrets = {
      jan-hetzner = {
        neededForUsers = true;
      };
    };
    defaultSopsFile = ../../secrets/secrets-hetzner.yaml;
  };
}
