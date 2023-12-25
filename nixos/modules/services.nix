{ pkgs, ... }: {
  systemd = {
    user.services.proton-bridge = {
      description = "Proton-Bridge";
      wantedBy = [ "graphical.target" ];
      wants = [ "graphical.target" ];
      after = [ "graphical.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --cli";
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

    upower.enable = true;

    gnome.sushi.enable = true;
    # spacenavd = {
    #   enable = true;
    #   enableUserService = true;
    # };
  };
}
