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
      jan-nixnas = {
        neededForUsers = true;
      };
    };
    defaultSopsFile = ../../secrets/secrets-nixnas.yaml;
  };
}
