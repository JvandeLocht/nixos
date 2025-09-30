# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/configuration.nix
    ./opt-in.nix
    ./sops.nix
    ../../lib/systemd.nix
  ];

  systemdTimers = {
    build-groot = {
      command = ''${pkgs.busybox}/bin/su jan -c "cd /home/jan/.setup && ${pkgs.nix}/bin/nix flake update && ${pkgs.nix}/bin/nix build .#nixosConfigurations.groot.config.system.build.toplevel"'';
      timer = "daily";
    };
  };

  locale.enable = true;
  harmonia.enable = true;
  zfs-impermanence = {
    enable = true;
    hostId = "3901c199";
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/jan/.setup";
  };

  networking = {
    hostName = "nixcache"; # Define your hostname.
    networkmanager.enable = true;
    firewall = {
      allowPing = true;
      extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
    };
  };

  services = {
    openssh.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    spice-vdagentd.enable = true;
    spice-autorandr.enable = true;
    spice-webdavd.enable = true;
    qemuGuest.enable = true;
  };

  users = {
    # groups.samba = {};
    users = {
      "jan" = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.jan-nixcache.path;
        home = "/home/jan";
        extraGroups = [
          "wheel"
          "networkmanager"
          "users"
        ];
        linger = true;
      };
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
