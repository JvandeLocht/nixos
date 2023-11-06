{ pkgs, ... }: {
  programs.waybar = {
    package = pkgs.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or [ ]) ++ [ "-Dexperimental=true" ];
      patches = (oa.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          name = "fix waybar hyprctl";
          url =
            "https://aur.archlinux.org/cgit/aur.git/plain/hyprctl.patch?h=waybar-hyprland-git";
          sha256 = "sha256-pY3+9Dhi61Jo2cPnBdmn3NUTSA8bAbtgsk2ooj4y7aQ=";
        })
      ];
    });
    enable = true;
    style = ./style.css;

    settings = [{

      layer = "top"; # Waybar at top layer
      # "position"= "bottom", # Waybar position (top|bottom|left|right)
      height = 35; # Waybar height (to be removed for auto height)
      # "width"= 1280; # Waybar width
      spacing = 5; # Gaps between modules (4px)
      # Choose the order of the modules
      modules-left = [ "hyprland/workspaces" "wlr/taskbar" ];
      modules-center = [ "clock" ];
      modules-right = [
        "idle_inhibitor"
        "bluetooth"
        "custom/swaync"
        "battery"
        "pulseaudio"
        "cpu"
        "memory"
        "custom/wvkbd"
        "tray"
      ];
      # Modules configuration
      "hyprland/workspaces" = {
        "disable-scroll" = true;
        "max-length" = 200;
        "seperate-outputs" = true;
        # "all-outputs" = true;
        "warp-on-scroll" = false;
      };
      "wlr/taskbar" = {
        "format" = "{icon}";
        "icon-size" = 30;
        "icon-theme" = "Numix-Circle";
        "tooltip-format" = "{title}";
        "on-click" = "activate";
        "on-click-middle" = "close";
      };
      "bluetooth" = {
        "format" = " {status}";
        "format-connected" = " {device_alias}";
        "format-connected-battery" =
          " {device_alias} {device_battery_percentage}%";
        # "format-device-preference"= [ "device1" "device2" ]; # preference list deciding the displayed device
        "tooltip-format" = ''
          {controller_alias}	{controller_address}

          {num_connections} connected'';
        "tooltip-format-connected" = ''
          {controller_alias}	{controller_address}

          {num_connections} connected

          {device_enumerate}'';
        "tooltip-format-enumerate-connected" =
          "{device_alias}	{device_address}";
        "tooltip-format-enumerate-connected-battery" =
          "{device_alias}	{device_address}	{device_battery_percentage}%";
        on-click = "blueberry";
      };
      "keyboard-state" = {
        numlock = true;
        capslock = true;
        format = "{name} {icon}";
        format-icons = {
          "locked" = "";
          "unlocked" = "";
        };
      };
      "sway/mode" = { "format" = ''<span style="italic">{}</span>''; };
      "sway/scratchpad" = {
        format = "{icon} {count}";
        show-empty = false;
        format-icons = [ "" "" ];
        tooltip = true;
        tooltip-format = "{app}: {title}";
      };
      "mpd" = {
        format =
          "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
        format-disconnected = "Disconnected ";
        format-stopped =
          "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
        unknown-tag = "N/A";
        interval = 2;
        consume-icons = { "on" = " "; };
        random-icons = {
          "off" = ''<span color="#f53c3c"></span> '';
          "on" = " ";
        };
        repeat-icons = { "on" = " "; };
        single-icons = { "on" = "1 "; };
        state-icons = {
          "paused" = "";
          "playing" = "";
        };
        tooltip-format = "MPD (connected)";
        tooltip-format-disconnected = "MPD (disconnected)";
      };
      "idle_inhibitor" = {
        format = "{icon}";
        format-icons = {
          "activated" = "";
          "deactivated" = "";
        };
      };
      "tray" = {
        "icon-size" = 21;
        spacing = 10;
      };
      "clock" = {
        # "timezone"= "America/New_York";
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>'';
        format-alt = "{:%Y-%m-%d}";
      };
      "cpu" = {
        format = "{usage}% ";
        tooltip = false;
      };
      memory = { "format" = "{}% "; };
      temperature = {
        # "thermal-zone"= 2;
        # "hwmon-path"= "/sys/class/hwmon/hwmon2/temp1_input";
        critical-threshold = 80;
        # "format-critical"= "{temperatureC}°C {icon}";
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
      };
      "backlight" = {
        # "device"= "acpi_video1",
        format = "{percent}% {icon}";
        format-icons = [ "" "" "" "" "" "" "" "" "" ];
      };
      "battery" = {
        states = {
          # "good"= 95,
          "warning" = 30;
          "critical" = 15;
        };
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% ";
        format-plugged = "{capacity}% ";
        format-alt = "{time} {icon}";
        # "format-good"= "", # An empty format will hide the module
        # "format-full"= "",
        format-icons = [ "" "" "" "" "" ];
      };
      "battery#bat2" = { "bat" = "BAT2"; };
      "network" = {
        # "interface"= "wlp2*", # (Optional) To force the use of this interface
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ipaddr}/{cidr} ";
        tooltip-format = "{ifname} via {gwaddr} ";
        format-linked = "{ifname} (No IP) ";
        format-disconnected = "Disconnected ⚠";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };
      "pulseaudio" = {
        # scroll-step= 1, # %, can be a float;
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
          "headphone" = "";
          "hands-free" = "";
          "headset" = "";
          "phone" = "";
          "portable" = "";
          "car" = "";
          "default" = [ "" "" "" ];
        };
        on-click = "pavucontrol";
      };
      "custom/media" = {
        format = "{icon} {}";
        return-type = "json";
        max-length = 40;
        format-icons = {
          "spotify" = "";
          "default" = "🎜";
        };
        escape = true;
        exec =
          "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder
        # "exec"= "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" # Filter player based on name
      };
      "custom/swaync" = {
        "format" = " ";
        "on-click" = pkgs.writeScript "swaync-skript" ''
          #!/usr/bin/env bash
          sleep 0.1
          ${pkgs.swaynotificationcenter}/bin/swaync-client -t &
          disown
        '';
        "on-click-right" = "swaync-client -C";
        "tooltip" = false;
      };
      "custom/wvkbd" = {
        "format" = " ";
        "on-click" = pkgs.writeScript "wvkbd-skript" ''
          #!/usr/bin/env bash
          if ${pkgs.toybox}/bin/pgrep -x 'wvkbd-mobintl' > /dev/null; then
            ${pkgs.killall}/bin/killall wvkbd-mobintl
          else
            ${pkgs.wvkbd}/bin/wvkbd-mobintl -L 300
          fi
        '';
        "tooltip" = false;
      };
    }];
  };
}
