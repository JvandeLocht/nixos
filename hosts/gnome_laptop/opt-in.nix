{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      # "/run/secrets"
      # "/run/secrets-for-users"
      "/root/.local/share/nix"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/etc/asusd"
      "/etc/passwd"
      "/etc/shadow"
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
        parentDirectory = {mode = "u=rwx,g=,o=";};
      }
    ];
    # users.talyz = {
    #   directories = [
    #     "Downloads"
    #     "Music"
    #     "Pictures"
    #     "Documents"
    #     "Videos"
    #     "VirtualBox VMs"
    #     { directory = ".gnupg"; mode = "0700"; }
    #     { directory = ".ssh"; mode = "0700"; }
    #     { directory = ".nixops"; mode = "0700"; }
    #     { directory = ".local/share/keyrings"; mode = "0700"; }
    #     ".local/share/direnv"
    #   ];
    #   files = [
    #     ".screenrc"
    #   ];
    # };
  };
  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
}
