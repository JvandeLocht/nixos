{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./ollama-webui.nix ./minio.nix ./proxmox-backup-server.nix];

  options.podman.nvidia = {
    enable = lib.mkEnableOption "Enable nvidia support for podman";
  };

  config = lib.mkIf config.podman.nvidia.enable {
    environment.systemPackages = with pkgs; [nvidia-podman];
    hardware = {
      nvidia-container-toolkit.enable = true;
      nvidia.datacenter.enable = true;
    };
  };
}
