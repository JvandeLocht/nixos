#!/bin/sh

DIRECTORY="$HOME/tank"

# Checks if the directory allready exists
if [ ! -d "$DIRECTORY" ]; then
  mkdir -p $HOME/tank
fi

# Checks if the directory is allready a mountpoint
if ! mount | grep $HOME/tank > /dev/null; then
    ($pkgs.tmux)/bin  sshfs jan@192.168.178.40:/tank $HOME/tank
fi

