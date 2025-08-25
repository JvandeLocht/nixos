{
  config,
  lib,
  pkgs,
  ...
}: {
  sops = {
    age = {
      keyFile = "/persist/sops/age/keys.txt";
      generateKey = false;
    };
    secrets = {
      jan-nixcache = {
        neededForUsers = true;
      };
    };
    defaultSopsFile = ../../secrets/secrets-nixcache.yaml;
  };
}
