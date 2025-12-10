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
    networking.enableIPv6 = true;
    networking.networkmanager = {
      enable = true;
    };

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no";
        PasswordAuthentication = true;
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
