{
  lib,
  config,
  pkgs,
  ...
}: {
  options.hypridle = {
    enable = lib.mkEnableOption "hypridle with custom configuration";
  };

  config = lib.mkIf config.hypridle.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
        };

        listeners = [
          # Monitor backlight control
          {
            timeout = 150; # 2.5 minutes
            # Set monitor backlight to minimum (10), avoiding 0 on OLED monitors
            onTimeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 1";
            # Restore monitor backlight
            onResume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
          }
          # Keyboard backlight control
          # Comment out this section if you don't have a keyboard backlight
          {
            timeout = 150; # 2.5 minutes
            # Turn off keyboard backlight
            onTimeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd asus::kbd_backlight set 0";
            # Turn on keyboard backlight
            onResume = "${pkgs.brightnessctl}/bin/brightnessctl -rd asus::kbd_backlight";
          }
          # Screen locking
          {
            timeout = 300; # 5 minutes
            # Lock screen when timeout has passed
            onTimeout = "${pkgs.systemd}/bin/loginctl lock-session";
          }
          # Display power management
          {
            timeout = 330; # 5.5 minutes
            # Turn off screen when timeout has passed
            onTimeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            # Turn on screen when activity is detected after timeout has fired
            onResume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
          # System suspension
          {
            timeout = 1800; # 30 minutes
            # Suspend PC
            onTimeout = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
      };
    };
  };
}
