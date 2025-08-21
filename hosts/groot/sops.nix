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
      jan-groot = {
        neededForUsers = true;
      };
    };
    defaultSopsFile = ../../secrets/secrets-groot.yaml;
  };
}
