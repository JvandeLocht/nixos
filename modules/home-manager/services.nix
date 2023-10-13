{ config, pkgs, ... }:
{
  systemd.user.services = {
    sshfs-tank = {
      Unit = {
        Description = "Mount tank folder";
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };

      Service = {
        # StandartOutput = null;
        ExecStart = toString (
          pkgs.writeShellScript "sshfs-tank" ''
            #!/usr/bin/env bash

            DIRECTORY="$HOME/tank"

            # Checks if the directory allready exists
            if [ ! -d "$DIRECTORY" ]; then
              mkdir -p $HOME/tank
            fi

            # Checks if the directory is allready a mountpoint
            if ! ${pkgs.mount}/bin/mount | ${pkgs.gnugrep}/bin/grep $HOME/tank > /dev/null; then
              ${pkgs.sshfs}/bin/sshfs jan@192.168.178.40:/tank $HOME/tank -o IdentityFile=/etc/ssh/ssh_host_rsa_key.pub
            fi
          ''
        );
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
