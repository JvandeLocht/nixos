#!/usr/bin/env bash

# Helper function to ask for confirmation
confirm() {
    local message="$1"
    local response
    while true; do
        read -p "$message (y/n): " response
        case $response in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) echo "Please answer yes or no." ;;
        esac
    done
}

# Prompt user for necessary variables
read -p "Enter your SSH key: " SSH_KEY
# SSH_KEY=""
#
# # Add SSH key (optional)
# mkdir -p /home/nixos/.ssh
# echo "$SSH_KEY" > /home/nixos/.ssh/authorized_keys
# chmod 700 /home/nixos/.ssh
# chmod 600 /home/nixos/.ssh/authorized_keys
# chown -R nixos /home/nixos/.ssh
#
# # Become root
# sudo su
#
echo "Checking if the system is UEFI or BIOS"

echo "-----"

if [ -d /sys/firmware/efi ]; then
    echo "UEFI detected"
    BOOT_TYPE="UEFI"
else
    echo "BIOS detected"
    BOOT_TYPE="BIOS"
fi

echo "-----"
# List partitions
lsblk

echo "-----"

read -p "Enter the disk name (e.g., /dev/sda): " DISK
read -p "Enter the desired partition size (e.g., 150G): " PART_SIZE

echo "-----"
echo "WARNING: This will DELETE ALL existing partitions on $DISK"
if ! confirm "Do you want to continue with deleting all partitions on $DISK?"; then
    echo "Aborted by user."
    exit 1
fi

echo "-----"
echo "Deleting all existing partitions"
echo "-----"
for part in $(parted -s $DISK print | awk '/^ / {print $1}'); do
    parted -s $DISK rm $part
done

echo "-----"
if ! confirm "Create new partition table and partitions on $DISK?"; then
    echo "Aborted by user."
    exit 1
fi

echo "Creating boot table and root & swap partitions"
echo "-----"
if [ "$BOOT_TYPE" == "BIOS" ]; then
    parted --script --align optimal $DISK mklabel msdos
    parted --script --align optimal $DISK mkpart primary 2MB $PART_SIZE
    parted --script --align optimal $DISK mkpart primary linux-swap $PART_SIZE 100%
else
    parted --script --align optimal $DISK mklabel gpt
    parted --script --align optimal $DISK mkpart primary 512MB $PART_SIZE
    parted --script --align optimal $DISK mkpart primary linux-swap $PART_SIZE 100%
    parted --script --align optimal $DISK mkpart ESP fat32 1MB 512MB
    lsblk
    read -p "Specify the boot partition (should be 3 or p3): " BOOT
    parted --script $DISK set ${BOOT} esp on
    mkfs.fat -F32 -n BOOT ${DISK}${BOOT}
fi

lsblk

echo "-----"
#
echo "Initialize swap"
echo ""
read -p "Specify the swap partition (should be 2 or p2): " SWAP
echo ""
if ! confirm "Initialize swap on ${DISK}${SWAP}?"; then
    echo "Aborted by user."
    exit 1
fi
mkswap -L swap ${DISK}${SWAP}

echo "-----"
echo "Creating root pool, enabling compression"
mkdir -p /mnt
read -p "Specify the root partition (should be 1 or p1): " ROOT

if confirm "Do you want to encrypt the ZFS root pool?"; then
    echo "Creating encrypted ZFS root pool..."
    zpool create -O encryption=on -O keyformat=passphrase -O keylocation=prompt -O compression=on -f rpool ${DISK}${ROOT}
else
    echo "Creating unencrypted ZFS root pool..."
    zpool create -O compression=on -f rpool ${DISK}${ROOT}
fi
zfs create -p -o mountpoint=legacy rpool/local/root
echo "Creating initial snapshot"
zfs snapshot rpool/local/root@blank
echo "Mounting root pool"
mount -t zfs rpool/local/root /mnt
echo "Creating dataset for the nix store"
zfs create -p -o mountpoint=legacy rpool/local/nix
mkdir /mnt/nix
echo "Mounting dataset"
mount -t zfs rpool/local/nix /mnt/nix
echo "Creating dataset for the home folder"
zfs create -p -o mountpoint=legacy rpool/safe/home
echo "Mounting dataset"
mkdir /mnt/home
mount -t zfs rpool/safe/home /mnt/home
echo "Creating dataset for persistent data"
zfs create -p -o mountpoint=legacy rpool/safe/persist
echo "Mounting dataset"
mkdir /mnt/persist
mount -t zfs rpool/safe/persist /mnt/persist

if [ "$BOOT_TYPE" == "BIOS" ]; then
    echo "-----"
    zfs create -p -o mountpoint=legacy rpool/safe/boot
    mount -t zfs rpool/safe/boot /mnt/boot
else
    echo "-----"
    mkdir /mnt/boot
    mount ${DISK}${BOOT} /mnt/boot
fi

zfs list

echo "-----"
if ! confirm "Generate NixOS configuration files?"; then
    echo "Aborted by user."
    exit 1
fi
echo "Generate NixOS configuration file"
rm /mnt/etc/nixos/*
nixos-generate-config --root /mnt
echo "Backing up old config to /mnt/etc/nixos/configuration.bak"
cp /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/configuration.bak

echo "-----"
echo "Edit configuration.nix"
read -p "Enter your username: " USERNAME
read -p "Enter your host ID (or leave empty to create a random one): " HOST_ID_INPUT

if [ "$HOST_ID_INPUT" == "" ]; then
    HOST_ID=$(head -c4 /dev/urandom | od -t x4 | awk '{print $2}')
    echo "Generated host ID: $HOST_ID"
else
    HOST_ID=$HOST_ID_INPUT
fi

if [ "$BOOT_TYPE" == "BIOS" ]; then
    cat <<EOF >/mnt/etc/nixos/configuration.patch
--- configuration.nix	2024-08-16 12:08:39.856491846 +0000
+++ /mnt/etc/nixos/configuration.nix	2024-08-16 12:21:37.473561228 +0000
@@ -12,6 +12,10 @@
 
   # Use the GRUB 2 boot loader.
   boot.loader.grub.enable = true;
+  boot.supportedFilesystems = [ "zfs" ];
+  boot.loader.grub.device = "${DISK}";  # replace  with the actual disk name, eg /dev/nvme0n1
+  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
+
   # boot.loader.grub.efiSupport = true;
   # boot.loader.grub.efiInstallAsRemovable = true;
   # boot.loader.efi.efiSysMountPoint = "/boot/efi";
@@ -19,12 +23,13 @@
   # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
 
   # networking.hostName = "nixos"; # Define your hostname.
+  networking.hostId = "$HOST_ID";
   # Pick only one of the below networking options.
   # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
-  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
+  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
 
   # Set your time zone.
-  # time.timeZone = "Europe/Amsterdam";
+  time.timeZone = "Europe/Amsterdam";
 
   # Configure network proxy if necessary
   # networking.proxy.default = "http://user:password@proxy:port/";
@@ -74,13 +79,53 @@
   #     tree
   #   ];
   # };
+  services.openssh.enable = true;  # If using VPS
+
+  security.sudo.wheelNeedsPassword = false;
+  users.users."$USERNAME" = {
+    isNormalUser = true;
+      password = "password";  # Change this once your computer is set up!
+        home = "/home/$USERNAME";
+          extraGroups = [ "wheel" "networkmanager" ];
+            openssh.authorizedKeys.keys = [ "<your ssh key>" ];  # If using VPS
+            };
+    
+  nix.settings = {
+      experimental-features = ["nix-command" "flakes"];
+          trusted-users = ["$USERNAME"]; # Add your own username to the trusted list
+            };
+    # Select internationalisation properties.
+    i18n.defaultLocale = "de_DE.UTF-8";
+
+    i18n.extraLocaleSettings = {
+      LC_ADDRESS = "de_DE.UTF-8";
+      LC_IDENTIFICATION = "de_DE.UTF-8";
+      LC_MEASUREMENT = "de_DE.UTF-8";
+      LC_MONETARY = "de_DE.UTF-8";
+      LC_NAME = "de_DE.UTF-8";
+      LC_NUMERIC = "de_DE.UTF-8";
+      LC_PAPER = "de_DE.UTF-8";
+      LC_TELEPHONE = "de_DE.UTF-8";
+      LC_TIME = "de_DE.UTF-8";
+    };
+
+    # Configure keymap in X11
+    services.xserver.xkb = {
+      layout = "de";
+      variant = "";
+    };
+
+    # Configure console keymap
+    console.keyMap = "de";
+
 
   # List packages installed in system profile. To search, run:
   # $ nix search wget
-  # environment.systemPackages = with pkgs; [
-  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
-  #   wget
-  # ];
+  environment.systemPackages = with pkgs; [
+    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
+    wget
+    git
+  ];
 
   # Some programs need SUID wrappers, can be configured further or are
   # started in user sessions.
EOF
else
    cat <<EOF >/mnt/etc/nixos/configuration.patch
diff --git a/configuration.bak b/configuration.nix
index d742cbb..91d7f68 100644
--- a/configuration.bak
+++ b/configuration.nix
@@ -2,25 +2,135 @@
 # your system. Help is available in the configuration.nix(5) man page, on
 # https://search.nixos.org/options and in the NixOS manual ($(nixos-help)).

-{ config, lib, pkgs, ... }:
-
 {
-  imports =
-    [ # Include the results of the hardware scan.
-      ./hardware-configuration.nix
-    ];
+  config,
+  lib,
+  pkgs,
+  ...
+}:

-  # Use the systemd-boot EFI boot loader.
-  boot.loader.systemd-boot.enable = true;
-  boot.loader.efi.canTouchEfiVariables = true;
+{
+  imports = [
+    # Include the results of the hardware scan.
+    ./hardware-configuration.nix
+  ];
+  services.qemuGuest.enable = true;
+
+  boot = {
+    # Bootloader.
+    loader = {
+      #      systemd-boot.enable = true;
+      #      efi.canTouchEfiVariables = true;
+      grub = {
+        enable = true;
+        zfsSupport = true;
+        efiSupport = true;
+        efiInstallAsRemovable = true;
+        mirroredBoots = [
+          {
+            devices = [ "nodev" ];
+            path = "/boot";
+          }
+        ];
+      };
+    };
+  };
+  services.zfs.autoScrub.enable = true;
+  boot.initrd.postDeviceCommands = lib.mkAfter ''
+    zfs rollback -r rpool/local/root@blank
+  '';

   # networking.hostName = "nixos"; # Define your hostname.
+  networking.hostId = "94fc84db";
   # Pick only one of the below networking options.
   # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
-  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
+  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

   # Set your time zone.
-  # time.timeZone = "Europe/Amsterdam";
+  time.timeZone = "Europe/Amsterdam";
+
+  environment = {
+    shellAliases = {
+      get-config = "git clone https://github.com/JvandeLocht/nixos";
+      v = "nix run github:JvandeLocht/nvf-config#";
+      ns = "sudo nixos-rebuild switch --flake";
+    };
+    interactiveShellInit = ''
+      echo "Available aliases:"
+      alias
+    '';
+    systemPackages = with pkgs; [
+      tmux
+      vim
+      git
+      wget
+      sops
+      age
+    ];
+  };
+
+  nix.settings = {
+    experimental-features = [
+      "nix-command"
+      "flakes"
+    ];
+    trusted-users = [ "jan" ]; # Add your own username to the trusted list
+  };
+
+  security.sudo.wheelNeedsPassword = false;
+  users.users."jan" = {
+    isNormalUser = true;
+    password = "password"; # Change this once your computer is set up!
+    home = "/home/jan";
+    extraGroups = [
+      "wheel"
+      "networkmanager"
+    ];
+    openssh.authorizedKeys.keys = [ "<your ssh key>" ]; # If using VPS
+  };
+
+  # Enable SSH server
+  services.openssh = {
+    enable = true;
+    permitRootLogin = "yes";
+    passwordAuthentication = true;
+  };
+
+  # Make sure sshd service starts on boot
+  systemd.services.sshd.wantedBy = [ "multi-user.target" ];
+
+  programs.tmux = {
+    enable = true;
+    clock24 = true;
+    extraConfig = ''
+      set-option -g status-position top
+      set-option -g status-style "bg=black,fg=green"
+      set -g status-right ""
+
+      # split panes using | and -
+      bind | split-window -h
+      bind - split-window -v
+      unbind '"'
+      unbind %
+
+      # reload config file (change file location to your the tmux.conf you want to use)
+      bind r source-file ~/.config/tmux/tmux.conf
+
+      # switch panes using Alt-arrow without prefix
+      bind -n M-h select-pane -L
+      bind -n M-l select-pane -R
+      bind -n M-j select-pane -U
+      bind -n M-k select-pane -D
+
+      # remap prefix from 'C-b' to 'C-a'
+      unbind C-b
+      set-option -g prefix C-Space
+      bind-key C-Space send-prefix
+
+      # Enable mouse control (clickable windows, panes, resizable panes)
+      set -g mouse on
+    '';
+  };

   # Configure network proxy if necessary
   # networking.proxy.default = "http://user:password@proxy:port/";
@@ -37,9 +147,6 @@
   # Enable the X11 windowing system.
   # services.xserver.enable = true;

-
-
-
   # Configure keymap in X11
   # services.xserver.xkb.layout = "us";
   # services.xserver.xkb.options = "eurosign:e,caps:escape";
@@ -120,4 +227,3 @@
   system.stateVersion = "25.11"; # Did you read the comment?

 }
-
EOF
fi

if ! confirm "Apply configuration patch to /mnt/etc/nixos/configuration.nix?"; then
    echo "Aborted by user."
    exit 1
fi
patch /mnt/etc/nixos/configuration.nix </mnt/etc/nixos/configuration.patch
echo "Patching complete"

if ! confirm "Move NixOS configuration into persistent storage?"; then
    echo "Aborted by user."
    exit 1
fi
echo "Move NixOS configuration into persistent storage"
mkdir -p /persist/etc
cp -r /mnt/etc/nixos /persist/etc/

if ! confirm "Perform NixOS installation? This is the final step."; then
    echo "Aborted by user."
    exit 1
fi
echo "Performing NixOS installation"
nixos-install --verbose --no-root-password
#
