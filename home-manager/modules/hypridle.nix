{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.hypridle = {
    enable = lib.mkEnableOption "hypridle with custom configuration";
  };

  config = lib.mkIf config.hypridle.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          # after_sleep_cmd = "sleep 1 && hyprctl dispatch dpms on"; # delay to avoid race conditions during resume
          lock_cmd = "${pkgs.busybox}/bin/pidof ${pkgs.hyprland}/bin/hyprlock || ${pkgs.hyprland}/bin/hyprlock"; # avoid starting multiple hyprlock instances.
          # before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
        };

        listeners = [
          # Monitor backlight control
          {
            timeout = 150; # 2.5 minutes
            # Set monitor backlight to minimum (10), avoiding 0 on OLED monitors
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 1";
            # Restore monitor backlight
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
          }
          # Keyboard backlight control
          # Comment out this section if you don't have a keyboard backlight
          {
            timeout = 150; # 2.5 minutes
            # Turn off keyboard backlight
            on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd asus::kbd_backlight set 0";
            # Turn on keyboard backlight
            on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd asus::kbd_backlight";
          }
          # Screen locking
          {
            timeout = 300; # 5 minutes
            # Lock screen when timeout has passed
            on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
          }
          # Display power management
          {
            timeout = 310; # 5 minutes 10 seconds - closer to lock timeout to reduce race conditions
            # Turn off screen when timeout has passed
            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            # Turn on screen when activity is detected after timeout has fired
            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
          # System suspension
          {
            timeout = 1800; # 30 minutes
            # Suspend PC
            on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
      };
    };
  };
}
