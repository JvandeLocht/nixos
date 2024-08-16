#!/usr/bin/env bash

# Prompt user for necessary variables
# read -p "Enter your SSH key: " SSH_KEY
# read -p "Enter your host ID: " HOST_ID
# read -p "Enter your username: " USERNAME
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
#
echo "-----"
echo "Creating boot table and root & swap partitions"
echo "-----"
if [ "$BOOT_TYPE" == "BIOS" ]; then
  parted $DISK mklabel msdos
  parted $DISK mkpart primary 2M $PART_SIZE
  parted $DISK mkpart primary linux-swap $PART_SIZE 100%
else
  parted $DISK mklabel gpt
  parted $DISK mkpart primary 512MB $PART_SIZE
  parted $DISK mkpart primary linux-swap $PART_SIZE 100%
  parted $DISK mkpart ESP fat32 1MB 512MB
  parted $DISK set 3 esp on
  mkfs.fat -F32 -n boot ${DISK}3
fi

lsblk

echo "-----"
#
# Initialize swap
# mkswap -L swap ${DISK}2
#
# # Create ZFS root pool
# zpool create -f rpool ${DISK}1
# zfs set compression=on rpool
#
# # Create ZFS datasets and mount them
# zfs create -p -o mountpoint=legacy rpool/eyd/root
# zfs set xattr=sa rpool/eyd/root
# zfs set acltype=posixacl rpool/eyd/root
# zfs snapshot rpool/eyd/root@blank
# zfs create -p -o mountpoint=legacy rpool/eyd/nix
# zfs create -p -o mountpoint=legacy rpool/eyd/per
# mkdir -p /mnt
# mount -t zfs rpool/eyd/root /mnt
# mkdir -p /mnt/{nix,boot,per}
# mount -t zfs rpool/eyd/nix /mnt/nix
# mount -t zfs rpool/eyd/per /mnt/per
#
# if [ "$BOOT_TYPE" == "BIOS" ]; then
  # zfs create -p -o mountpoint=legacy rpool/eyd/boot
  # mount -t zfs rpool/eyd/boot /mnt/boot
# else
  # mount ${DISK}3 /mnt/boot
# fi
#
# # Generate NixOS configuration file
# nixos-generate-config --root /mnt
#
# # Edit configuration.nix
# cat <<EOF > /mnt/etc/nixos/configuration.nix
# ## Boot stuff ##
# boot.supportedFilesystems = [ "zfs" ];
# boot.loader.grub.device = "${DISK}";
#
# # Might be required if running on a virtual machine
# boot.zfs.devNodes = "/dev/disk/by-path";
#
# # Required by zfs. generate with 'head -c4 /dev/urandom | od -t x4 | cut -c9-16'
# networking.hostId = "$HOST_ID";
#
# boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages;
#
# ## User and SSH stuff ##
# services.openssh.enable = true;
#
# security.sudo.wheelNeedsPassword = false;
# users.users."$USERNAME" = {
# isNormalUser = true;
# password = "password";  # Change this once your computer is set up!
#   home = "/home/$USERNAME";
#     extraGroups = [ "wheel" "networkmanager" ];
#       openssh.authorizedKeys.keys = [ "$SSH_KEY" ];
#       };
#
#       ## Packages ##
#       environment.systemPackages = with pkgs; [ vim wirelesstools git ];
#
#       # Enable nmcli
#       networking.wireless.enable = false;
#       networking.networkmanager.enable = true;
#       networking.useDHCP = false;
#       networking.networkmanager.wifi.scanRandMacAddress = false;
#       EOF
#
#       # Perform NixOS installation
#       nixos-install --verbose --no-root-password
#
#       # Move NixOS configuration into persistent storage and enable wipe-on-boot
#       mkdir -p /per/etc
#       mv /etc/nixos /per/etc
#
#       # Edit configuration for persistent storage
#       cat <<EOF >> /per/etc/nixos/configuration.nix
#       # Make NixOS read config from /per
#       environment.etc = { nixos.source = /per/etc/nixos; };
#
#       # Enables wipe-on-boot
#       boot.initrd.postDeviceCommands = lib.mkBefore ''
#         zfs rollback -r rpool/eyd/root@blank
#         '';
#         EOF
#
#         # Activate the new config
#         nixos-rebuild -I nixos-config=/per/etc/nixos/configuration.nix switch
#
#         # Test persistence
#         touch /per/hello
#         touch /etc/hello
#
#         echo "Installation complete. Please reboot the machine and verify persistence."
#       '
# }
