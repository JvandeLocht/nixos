{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.networking = {
    enable = lib.mkEnableOption "Set up networking and SSH";
  };

  config = lib.mkIf config.networking.enable {
    # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.enableIPv6 = true;
    networking.networkmanager = {
      enable = true;
    };

    # Open ports in the firewall.
    networking.firewall = {
      enable = true;
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
        {
          from = 9898;
          to = 9898;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
    # programs.ssh.startAgent = true;
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no"; # disable root login
        PasswordAuthentication = true; # disable password login
      };
      openFirewall = true;
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
