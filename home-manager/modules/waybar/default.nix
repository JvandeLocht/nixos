{ pkgs, ... }: {
  programs.waybar = {
    enable = true;
    style = ./style.css;
    settings = [{

      layer = "top"; # Waybar at top layer
      # "position"= "bottom", # Waybar position (top|bottom|left|right)
      height = 35; # Waybar height (to be removed for auto height)
      # "width"= 1280; # Waybar width
      spacing = 10; # Gaps between modules (4px)
      # Choose the order of the modules
      mode = "hidden";
      modules-left = [
        "hyprland/workspaces"
        "sway/mode"
        "sway/scratchpad"
        "custom/media"
        "wlr/taskbar"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        # "mpd"
        "idle_inhibitor"
        "battery"
        # "battery#bat2"
        "pulseaudio"
        # "network"
        "cpu"
        "memory"
        # "temperature"
        # "backlight"
        # "keyboard-state"
        # "sway/language"
        "tray"
      ];
      # Modules configuration
      # "hyprland/workspaces"= {
      #     "disable-scroll"= true;
      #     "all-outputs"= true;
      #     "warp-on-scroll"= false;
      #     "format"= "{name}: {icon}";
      #     "format-icons"= {
      #         "1"= "";
      #         "2"= "";
      #         "3"= "";
      #         "4"= "";
      #         "5"= "";
      #         "urgent"= "";
      #         "focused"= "";
      #         "default"= ""
      #     }
      # };
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
        # "icon-size"= 21;
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
        format-charging = "{capacity}% ";
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
    }];
  };
}
# layer = "top";
# position = "top";
# height = 30;
# # output = [ "eDP-1" "HDMI-A-1" ];
# modules-left = [ "hyprland/workspaces" "sway/mode" "wlr/taskbar" ];
# modules-center = [ "sway/window" "custom/hello-from-waybar" ];
# modules-right = [ "mpd" "custom/mymodule#with-css-id" "temperature" ];
#
# "hyprland/workspaces" = {
#   disable-scroll = true;
#   all-outputs = true;
# };
# "custom/hello-from-waybar" = {
#   format = "hello {}";
#   max-length = 40;
#   interval = "once";
#   exec = pkgs.writeShellScript "hello-from-waybar" ''
#     echo "from within waybar"
#   '';
# settings = [{
#   mainBar = {
#     layer = "top"; # Waybar at top layer
#     # "position"= "bottom", # Waybar position (top|bottom|left|right)
#     height = 30; # Waybar height (to be removed for auto height)
#     # "width"= 1280; # Waybar width
#     spacing = 4; # Gaps between modules (4px)
#     # Choose the order of the modules
#     modules-left = [
#       "hyprland/workspaces"
#       "sway/mode"
#       "sway/scratchpad"
#       "custom/media"
#     ];
#     modules-center = [ "sway/window" ];
#     modules-right = [
#       "mpd"
#       "idle_inhibitor"
#       "pulseaudio"
#       "network"
#       "cpu"
#       "memory"
#       "temperature"
#       "backlight"
#       "keyboard-state"
#       "sway/language"
#       "battery"
#       "battery#bat2"
#       "clock"
#       "tray"
#     ];
#     # Modules configuration
#     # "hyprland/workspaces"= {
#     #     "disable-scroll"= true;
#     #     "all-outputs"= true;
#     #     "warp-on-scroll"= false;
#     #     "format"= "{name}: {icon}";
#     #     "format-icons"= {
#     #         "1"= "";
#     #         "2"= "";
#     #         "3"= "";
#     #         "4"= "";
#     #         "5"= "";
#     #         "urgent"= "";
#     #         "focused"= "";
#     #         "default"= ""
#     #     }
#     # };
#     "keyboard-state" = {
#       numlock = true;
#       capslock = true;
#       format = "{name} {icon}";
#       format-icons = {
#         "locked" = "";
#         "unlocked" = "";
#       };
#     };
#     "sway/mode" = { "format" = ''<span style="italic">{}</span>''; };
#     "sway/scratchpad" = {
#       format = "{icon} {count}";
#       show-empty = false;
#       format-icons = [ "" "" ];
#       tooltip = true;
#       tooltip-format = "{app}: {title}";
#     };
#     "mpd" = {
#       format =
#         "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
#       format-disconnected = "Disconnected ";
#       format-stopped =
#         "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
#       unknown-tag = "N/A";
#       interval = 2;
#       consume-icons = { "on" = " "; };
#       random-icons = {
#         "off" = ''<span color="#f53c3c"></span> '';
#         "on" = " ";
#       };
#       repeat-icons = { "on" = " "; };
#       single-icons = { "on" = "1 "; };
#       state-icons = {
#         "paused" = "";
#         "playing" = "";
#       };
#       tooltip-format = "MPD (connected)";
#       tooltip-format-disconnected = "MPD (disconnected)";
#     };
#     "idle_inhibitor" = {
#       format = "{icon}";
#       format-icons = {
#         "activated" = "";
#         "deactivated" = "";
#       };
#     };
#     "tray" = {
#       # "icon-size"= 21;
#       spacing = 10;
#     };
#     "clock" = {
#       # "timezone"= "America/New_York";
#       tooltip-format = ''
#         <big>{:%Y %B}</big>
#         <tt><small>{calendar}</small></tt>'';
#       format-alt = "{:%Y-%m-%d}";
#     };
#     "cpu" = {
#       format = "{usage}% ";
#       tooltip = false;
#     };
#     memory = { "format" = "{}% "; };
#     temperature = {
#       # "thermal-zone"= 2;
#       # "hwmon-path"= "/sys/class/hwmon/hwmon2/temp1_input";
#       critical-threshold = 80;
#       # "format-critical"= "{temperatureC}°C {icon}";
#       format = "{temperatureC}°C {icon}";
#       format-icons = [ "" "" "" ];
#     };
#     "backlight" = {
#       # "device"= "acpi_video1",
#       format = "{percent}% {icon}";
#       format-icons = [ "" "" "" "" "" "" "" "" "" ];
#     };
#     "battery" = {
#       states = {
#         # "good"= 95,
#         "warning" = 30;
#         "critical" = 15;
#       };
#       format = "{capacity}% {icon}";
#       format-charging = "{capacity}% ";
#       format-plugged = "{capacity}% ";
#       format-alt = "{time} {icon}";
#       # "format-good"= "", # An empty format will hide the module
#       # "format-full"= "",
#       format-icons = [ "" "" "" "" "" ];
#     };
#     "battery#bat2" = { "bat" = "BAT2"; };
#     "network" = {
#       # "interface"= "wlp2*", # (Optional) To force the use of this interface
#       format-wifi = "{essid} ({signalStrength}%) ";
#       format-ethernet = "{ipaddr}/{cidr} ";
#       tooltip-format = "{ifname} via {gwaddr} ";
#       format-linked = "{ifname} (No IP) ";
#       format-disconnected = "Disconnected ⚠";
#       format-alt = "{ifname}: {ipaddr}/{cidr}";
#     };
#     "pulseaudio" = {
#       # scroll-step= 1, # %, can be a float;
#       format = "{volume}% {icon} {format_source}";
#       format-bluetooth = "{volume}% {icon} {format_source}";
#       format-bluetooth-muted = " {icon} {format_source}";
#       format-muted = " {format_source}";
#       format-source = "{volume}% ";
#       format-source-muted = "";
#       format-icons = {
#         "headphone" = "";
#         "hands-free" = "";
#         "headset" = "";
#         "phone" = "";
#         "portable" = "";
#         "car" = "";
#         "default" = [ "" "" "" ];
#       };
#       on-click = "pavucontrol";
#     };
#     "custom/media" = {
#       format = "{icon} {}";
#       return-type = "json";
#       max-length = 40;
#       format-icons = {
#         "spotify" = "";
#         "default" = "🎜";
#       };
#       escape = true;
#       exec =
#         "$HOME/.config/waybar/mediaplayer.py 2> /dev/null"; # Script in resources folder
#       # "exec"= "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" # Filter player based on name
#     };
#   };
# }];

# {
#   mainBar = {
#     layer = "top";
#     position = "top";
#     height = 34;
#     # output = [ "eDP-1" ];
#     modules-left = [
#       "hyprland/workspaces"
#       "idle_inhibitor"
#       "pulseaudio"
#       "backlight"
#       "network"
#       # "custom/updates"
#     ];
#     modules-center = [ "hyprland/window" ];
#     modules-right =
#       [ "cpu" "memory" "temperature" "battery" "tray" "clock" ];
#
#     "hyprland/workspaces" = {
#       disable-scroll = true;
#       on-click = "activate";
#       # all-outputs = true;
#       # format = "{name}: {icon}";
#       format = "{name}";
#       on-scroll-up = "hyprctl dispatch workspace m-1 > /dev/null";
#       on-scroll-down = "hyprctl dispatch workspace m+1 > /dev/null";
#       format-icons = {
#         "1" = "";
#         "2" = "";
#         "3" = "";
#         "4" = "";
#         "5" = "";
#         "urgent" = "";
#         "focused" = "";
#         "default" = "";
#       };
#     };
#     "keyboard-state" = {
#       numlock = false;
#       capslock = false;
#       format = "{name}: {icon}";
#       format-icons = {
#         "locked" = "";
#         "unlocked" = "";
#       };
#     };
#     "hyprland/window" = {
#       max-length = 50;
#       separate-outputs = true;
#     };
#     "sway/mode" = { format = ''<span style="italic">{}</span>''; };
#     "sway/scratchpad" = {
#       format = "{icon} {count}";
#       show-empty = false;
#       format-icons = [ "" "" ];
#       tooltip = true;
#       tooltip-format = "{app}: {title}";
#     };
#     "mpd" = {
#       "format" =
#         "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
#       "format-disconnected" = "Disconnected ";
#       "format-stopped" =
#         "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
#       "unknown-tag" = "N/A";
#       "interval" = 2;
#       "consume-icons" = { "on" = " "; };
#       "random-icons" = {
#         "off" = ''<span color="#f53c3c"></span> '';
#         "on" = " ";
#       };
#       "repeat-icons" = { "on" = " "; };
#       "single-icons" = { "on" = "1 "; };
#       "state-icons" = {
#         "paused" = "";
#         "playing" = "";
#       };
#       "tooltip-format" = "MPD (connected)";
#       "tooltip-format-disconnected" = "MPD (disconnected)";
#     };
#     "idle_inhibitor" = {
#       "format" = "{icon}";
#       "format-icons" = {
#         "activated" = "";
#         "deactivated" = "";
#       };
#     };
#     "tray" = {
#       # "icon-size": 21,
#       "spacing" = 0;
#     };
#     "clock" = {
#       # "timezone"= "America/New_York";
#       "tooltip-format" = ''
#         <big>{:%Y %B}</big>
#         <tt><small>{calendar}</small></tt>'';
#       "format-alt" = "{:%Y-%m-%d}";
#     };
#     "cpu" = {
#       "format" = "{usage}% ";
#       "tooltip" = false;
#     };
#     "memory" = { "format" = "{}% "; };
#     "temperature" = {
#       # "thermal-zone"= 2;
#       # "hwmon-path"= "/sys/class/hwmon/hwmon2/temp1_input";
#       "critical-threshold" = 80;
#       # "format-critical"= "{temperatureC}°C {icon}";
#       "format" = "{temperatureC}°C {icon}";
#       "format-icons" = [ "" "" "" ];
#     };
#     "backlight" = {
#       # "device"= "acpi_video1";
#       "format" = "{percent}% {icon}";
#       "format-icons" = [ "" "" "" "" "" "" "" "" "" ];
#     };
#     "battery" = {
#       "states" = {
#         # "good"= 95;
#         "warning" = 30;
#         "critical" = 15;
#       };
#       "format" = "{capacity}% {icon}";
#       "format-charging" = "{capacity}% 🗲";
#       "format-plugged" = "{capacity}% ";
#       "format-alt" = "{time} {icon}";
#       # "format-good"= ""; // An empty format will hide the module
#       # "format-full"= "";
#       "format-icons" = [ "" "" "" "" "" ];
#     };
#     "battery#bat2" = { "bat" = "BAT2"; };
#     "network" = {
#       "interface" = "wlan0"; # (Optional) To force the use of this interface
#       "format-wifi" = "{essid} ";
#       "format-ethernet" = "{ipaddr}/{cidr} ";
#       "tooltip-format" = "{ifname} via {gwaddr} ";
#       "format-linked" = "{ifname} (No IP) ";
#       "format-disconnected" = "Disconnected ⚠";
#       "format-alt" = "{ifname}: {ipaddr}/{cidr}";
#     };
#     "pulseaudio" = {
#       # "scroll-step"= 10; # %, can be a float
#       "format" = "{volume}%{icon} {format_source}";
#       "format-bluetooth" = "{volume}% {icon} {format_source}";
#       "format-bluetooth-muted" = " {icon} {format_source}";
#       "format-muted" = " {format_source}";
#       "format-source" = "{volume}% ";
#       "format-source-muted" = "";
#       "format-icons" = {
#         "headphone" = "";
#         "hands-free" = "";
#         "headset" = "";
#         "phone" = "";
#         "portable" = "";
#         "car" = "";
#         "default" = [ "" "" "" ];
#       };
#       "on-click" = "pavucontrol";
#     };
#     "custom/notification" = {
#       "tooltip" = false;
#       "format" = "{} {icon}";
#       "format-icons" = {
#         "notification" = "<span foreground='red'><sup></sup></span> ";
#         "none" = "";
#         "dnd-notification" = "<span foreground='red'><sup></sup></span> ";
#         "dnd-none" = "";
#         "inhibited-notification" =
#           "<span foreground='red'><sup></sup></span> ";
#         "inhibited-none" = "";
#         "dnd-inhibited-notification" =
#           "<span foreground='red'><sup></sup></span> ";
#         "dnd-inhibited-none" = "";
#       };
#       "return-type" = "json";
#       "exec-if" = "which swaync-client";
#       "exec" = "swaync-client -swb";
#       "on-click" = "sleep 0.1 && swaync-client -t -sw";
#       "on-click-right" = "swaync-client -d -sw";
#       "escape" = true;
#     };
#     "custom/updates" = {
#       "format" = "{} {icon}";
#       "return-type" = "json";
#       "format-icons" = {
#         "has-updates" = "󱍷";
#         "updated" = "󰂪";
#       };
#       "exec-if" = "which waybar-module-pacman-updates";
#       "exec" = "waybar-module-pacman-updates";
#     };
#
#     # "custom/hello-from-waybar" = {
#     #   format = "hello {}";
#     #   max-length = 40;
#     #   interval = "once";
#     #   exec = pkgs.writeShellScript "hello-from-waybar" ''
#     #     echo "from within waybar"
#     #   '';
#     # };
#   };
# }
