{
  # environment.etc = {
  #   "group".source = "/nix/persist/etc/group";
  #   "passwd".source = "/nix/persist/etc/passwd";
  #   "shadow".source = "/nix/persist/etc/shadow";
  # };
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      # "/run/secrets"
      # "/run/secrets-for-users"
      "/root/.local/share/nix"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/libvirt"
      "/var/cache/libvirt"
      "/var/lib/systemd/coredump"
      "/var/lib/private/ollama"
      "/var/lib/ollama"
      "/etc/NetworkManager/system-connections"
      "/etc/asusd"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
      # "/etc/passwd"
      # "/etc/shadow"
      {
        file = "/var/keys/secret_file";
        parentDirectory = {mode = "u=rwx,g=,o=";};
      }
    ];
  };
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
}
