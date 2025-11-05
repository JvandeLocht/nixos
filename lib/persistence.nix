{ lib, ... }:

{
  # Base directories that should be persisted on most impermanence systems
  baseSystemDirectories = [
    "/root/.local/share/nix"
    "/var/log"
    "/var/lib/nixos"
    "/var/lib/libvirt"
    "/var/cache/libvirt"
    "/var/lib/containers/storage"
    "/var/lib/systemd/coredump"
    "/etc/NetworkManager/system-connections"
    "/etc/ssh"
  ];

  # Special directory configurations that need specific permissions
  baseSystemDirectoriesWithPerms = [
    {
      directory = "/var/lib/colord";
      user = "colord";
      group = "colord";
      mode = "u=rwx,g=rx,o=";
    }
  ];

  # Base files that should be persisted on most impermanence systems
  baseSystemFiles = [
    "/etc/machine-id"
    {
      file = "/var/keys/secret_file";
      parentDirectory = {
        mode = "u=rwx,g=,o=";
      };
    }
  ];

  # Helper function to create a persistence configuration
  # Usage:
  #   mkPersistenceConfig {
  #     extraDirectories = [ "/var/lib/custom" ];
  #     extraFiles = [ "/etc/custom-config" ];
  #     includeBaseFiles = true;  # optional, defaults to true
  #   }
  mkPersistenceConfig =
    {
      extraDirectories ? [ ],
      extraFiles ? [ ],
      includeBaseFiles ? true,
      persistPath ? "/persist",
    }:
    {
      environment.persistence.${persistPath} = {
        hideMounts = true;
        directories = lib.lists.unique (
          baseSystemDirectories
          ++ baseSystemDirectoriesWithPerms
          ++ extraDirectories
        );
        files = if includeBaseFiles then baseSystemFiles ++ extraFiles else extraFiles;
      };

      # Disable sudo lecture since impermanence resets cause it to show on every boot
      security.sudo.extraConfig = ''
        # rollback results in sudo lectures after each reboot
        Defaults lecture = never
      '';
    };
}
