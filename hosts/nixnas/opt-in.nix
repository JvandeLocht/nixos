{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/root/.local/share/nix"
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/libvirt"
      "/var/cache/libvirt"
      "/var/lib/containers/storage"
      "/var/lib/systemd/coredump"
      "/var/lib/ollama/models"
      "/var/lib/minio"
      "/etc/NetworkManager/system-connections"
      "/etc/asusd"
      "/etc/ssh"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
      {
        file = "/var/keys/secret_file";
        parentDirectory = { mode = "u=rwx,g=,o="; };
      }
    ];
  };
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
}
