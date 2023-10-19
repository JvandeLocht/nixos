{ pkgs, ... }: {
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
}
