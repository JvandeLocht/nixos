{ pkgs, ... }: {
  systemd = {
    user.services.lxqt-policykit-agent = {
      description = "lxqt-policykit-agent";
      wantedBy = [ "hyprland-session.target" ];
      wants = [ "hyprland-session.target" ];
      after = [ "hyprland-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    user.services.nextcloud = {
      description = "Nextcloud Sync Client";
      wantedBy = [ "hyprland-session.target" ];
      wants = [ "hyprland-session.target" ];
      after = [ "hyprland-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    user.services.nmapplet = {
      description = "Networkmanger";
      wantedBy = [ "hyprland-session.target" ];
      wants = [ "hyprland-session.target" ];
      after = [ "hyprland-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };

    supergfxd.enable = true;
    # spacenavd = {
    #   enable = true;
    #   enableUserService = true;
    # };
  };
}
