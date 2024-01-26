{pkgs, ...}: {
  environment = {
    etc = {
      "NetworkManager/system-connections" = {
        source = "/persist/etc/NetworkManager/system-connections/";
      };
      "shadow" = {
        source = "/persist/etc/shadow";
      };
      "passwd" = {
        source = "/persist/etc/passwd";
      };
      "asusd" = {
        source = "/persist/etc/asusd";
      };
    };
  };

  systemd = {
    tmpfiles.rules = [
      "L /run/secrets - - - - /persist/run/secrets"
      "L /run/secrets-for-users - - - - /persist/run/secrets-for-users"
      "L /root/.local/share/nix/trusted-settings.json - - - - /persist/root/.local/share/nix/trusted-settings.json"
    ];
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
}
