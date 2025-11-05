{ lib, ... }:

let
  persistenceLib = import ../../lib/persistence.nix { inherit lib; };
in
persistenceLib.mkPersistenceConfig {
  extraDirectories = [
    "/var/lib/tailscale"
    "/var/cache/tailscale"
    "/var/cache/restic-backups-nixnas"
    "/var/lib/ollama/models"
    "/var/lib/minio"
    "/etc/samba"
    "/var/lib/samba"
    "/var/lib/cups"
    "/var/spool/cups"
    "/var/lib/acme"
  ];
  includeBaseFiles = false; # Files were commented out in original config
}
