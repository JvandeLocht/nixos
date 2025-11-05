{ lib, ... }:

let
  persistenceLib = import ../../lib/persistence.nix { inherit lib; };
in
persistenceLib.mkPersistenceConfig {
  extraDirectories = [
    "/var/lib/bluetooth"
    "/var/lib/cups"
    "/var/lib/tailscale"
    "/var/cache/tailscale"
    "/var/spool/cups"
    "/var/cache/restic-backups-groot"
    "/var/cache/restic-backups-remotebackup"
    "/etc/asusd"
  ];
}
