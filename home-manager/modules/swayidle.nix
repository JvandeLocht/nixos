{
  lib,
  config,
  pkgs,
  ...
}: {
  options.swayidle = {
    enable = lib.mkEnableOption "Swayidle with custom configuration";
  };

  config = lib.mkIf config.swayidle.enable {
    services.swayidle = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.swaylock-effects}/bin/swaylock";
        }
        {
          timeout = 330;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };
}
