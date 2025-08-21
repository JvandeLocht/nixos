{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.zfs-impermanence;
  zfsUtils = import ../../lib/zfs.nix { inherit lib pkgs config; };
in
{
  options.zfs-impermanence = {
    enable = lib.mkEnableOption "ZFS with impermanence (stateless root)";

    hostId = lib.mkOption {
      type = lib.types.str;
      description = "ZFS host ID (8 hex characters)";
    };

    rollbackDataset = lib.mkOption {
      type = lib.types.str;
      default = "rpool/local/root@blank";
      description = "ZFS dataset to rollback to on boot";
    };

    autoScrub = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable automatic ZFS scrubbing";
    };
  };

  config = lib.mkIf cfg.enable {
    # Set the host ID for ZFS
    networking.hostId = cfg.hostId;

    # Boot configuration with ZFS support
    boot = {
      # Use latest ZFS-compatible kernel
      kernelPackages = zfsUtils.getLatestZfsKernel;
      
      # Bootloader with ZFS support
      loader.grub = {
        enable = true;
        zfsSupport = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        mirroredBoots = [
          {
            devices = [ "nodev" ];
            path = "/boot";
          }
        ];
      };

      # Impermanence: rollback root filesystem on boot
      initrd.postMountCommands = lib.mkAfter ''
        zfs rollback -r ${cfg.rollbackDataset}
      '';

      # Request encryption credentials for encrypted datasets
      zfs.requestEncryptionCredentials = true;
      
      # Prevent hibernation (incompatible with ZFS)
      kernelParams = [ "nohibernate" ];
    };

    # Enable ZFS auto-scrub if requested
    services.zfs.autoScrub.enable = cfg.autoScrub;
  };
}