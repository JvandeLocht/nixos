{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./nvidia.nix
    ./minio.nix
    ./proxmox-backup-server.nix
    ./headscale-admin.nix
  ];

  options.podman = {
    enable = lib.mkEnableOption "Set up containerization environment";
  };

  config = lib.mkIf config.podman.enable {
    environment.systemPackages = with pkgs; [ docker-compose ];

    virtualisation = {
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        # Create a `docker` alias for podman, to use it as a drop-in replacement
        # dockerCompat = true;
        dockerSocket.enable = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
        # extraPackages = [ pkgs.zfs ]; # Required if the host is running ZFS
      };
    };
  };
}
