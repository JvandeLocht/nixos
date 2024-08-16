#!/usr/bin/env bash

# Prompt user for necessary variables
# read -p "Enter your SSH key: " SSH_KEY
SSH_KEY=""
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
  read -p "Specify the swap partition (should be 3 or p3): " BOOT
  parted $DISK set ${BOOT} esp on
  mkfs.fat -F32 -n boot ${DISK}${BOOT}
fi

lsblk

echo "-----"
#
echo "Initialize swap"
echo ""
read -p "Specify the swap partition (should be 2 or p2): " SWAP
echo ""
mkswap -L swap ${DISK}${SWAP}

echo "-----"
echo "Creating ZFS root pool"
read -p "Specify the root partition (should be 1 or p1): " ROOT
echo ""
zpool create -f rpool ${DISK}${ROOT}
zfs set compression=on rpool

echo "-----"
echo "Creating ZFS datasets and mount them"
zfs create -p -o mountpoint=legacy rpool/eyd/root
zfs set xattr=sa rpool/eyd/root
zfs set acltype=posixacl rpool/eyd/root
zfs snapshot rpool/eyd/root@blank
zfs create -p -o mountpoint=legacy rpool/eyd/nix
zfs create -p -o mountpoint=legacy rpool/eyd/per
mkdir -p /mnt
mount -t zfs rpool/eyd/root /mnt
mkdir -p /mnt/{nix,boot,per}
mount -t zfs rpool/eyd/nix /mnt/nix
mount -t zfs rpool/eyd/per /mnt/per

if [ "$BOOT_TYPE" == "BIOS" ]; then
echo "-----"
  zfs create -p -o mountpoint=legacy rpool/eyd/boot
  mount -t zfs rpool/eyd/boot /mnt/boot
else
echo "-----"
  mount ${DISK}${BOOT} /mnt/boot
fi

echo "-----"
echo "Generate NixOS configuration file"
nixos-generate-config --root /mnt

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

cat <<EOF > /mnt/etc/nixos/configuration.patch
--- configuration.nix	2024-08-16 12:08:39.856491846 +0000
+++ /mnt/etc/nixos/configuration.nix	2024-08-16 12:21:37.473561228 +0000
@@ -12,6 +12,10 @@
 
   # Use the GRUB 2 boot loader.
   boot.loader.grub.enable = true;
+  boot.supportedFilesystems = [ "zfs" ];
+  boot.loader.grub.device = "${DISK}${ROOT}";  # replace  with the actual disk name, eg /dev/nvme0n1
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
+          trusted-users = ["jan"]; # Add your own username to the trusted list
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

patch /mnt/etc/nixos/configuration.nix < /mnt/etc/nixos/configuration.patch

echo "Performing NixOS installation"
nixos-install --verbose --no-root-password
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
