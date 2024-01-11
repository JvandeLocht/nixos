{ config, lib, pkgs, ... }:

{
  # imports = [ ./ollama.nix ];
  environment.systemPackages = [ pkgs.nvidia-podman ];

  virtualisation = {
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      enableNvidia = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      # extraPackages = [ pkgs.zfs ]; # Required if the host is running ZFS
    };
  };
}
