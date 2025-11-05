{ lib, ... }:

let
  persistenceLib = import ../../lib/persistence.nix { inherit lib; };
in
persistenceLib.mkPersistenceConfig {
  extraDirectories = [
    "/var/cache/restic-backups-nixnas"
    "/var/lib/acme"
  ];
}
