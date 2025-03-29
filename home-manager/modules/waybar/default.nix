{
  lib,
  config,
  pkgs,
  ...
}: {
  options.waybar = {
    enable = lib.mkEnableOption "Custom Waybar configuration";
  };

  config = lib.mkIf config.waybar.enable {
    programs.waybar = {
      package = pkgs.waybar.overrideAttrs (oa: {
        mesonFlags = (oa.mesonFlags or []) ++ ["-Dexperimental=true"];
        patches =
          (oa.patches or [])
          ++ [
            (pkgs.fetchpatch {
              name = "fix waybar hyprctl";
              url = "https://aur.archlinux.org/cgit/aur.git/plain/hyprctl.patch?h=waybar-hyprland-git";
              sha256 = "sha256-pY3+9Dhi61Jo2cPnBdmn3NUTSA8bAbtgsk2ooj4y7aQ=";
            })
          ];
      });
      enable = true;
      style = ./style.css;

      settings = [
        {
          layer = "top";
          height = 35;
          spacing = 5;
          modules-left = ["hyprland/workspaces" "wlr/taskbar"];
          modules-center = ["clock"];
          modules-right = [
            "tray"
            # "idle_inhibitor"
            "bluetooth"
            "custom/swaync"
            "battery"
            "pulseaudio"
            "cpu"
            "memory"
            # "custom/wvkbd"
          ];

          # Module configurations
          "tray" = {
            "icon-size" = 21;
            "spacing" = 10;
          };
          "pulseaudio" = {
            "format" = "{volume}% {icon}";
            "format-bluetooth" = "{volume}% {icon}";
            "format-muted" = "";
            "format-icons" = {
              "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
              "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
              "headphone" = "";
              "hands-free" = "";
              "headset" = "";
              "phone" = "";
              "phone-muted" = "";
              "portable" = "";
              "car" = "";
              "default" = ["" ""];
            };
            "scroll-step" = 1;
            "on-click-right" = "${pkgs.lxqt.pavucontrol-qt}/bin/pavucontrol-qt";
            "on-click" =
              pkgs.writeShellScript "sink_cycle.sh"
              /*
              bash
              */
              ''
                #!/usr/bin/env bash
                default_sink=$(${pkgs.pulseaudio}/bin/pactl get-default-sink)

                readarray -t sinks < <(${pkgs.pulseaudio}/bin/pactl list short sinks | ${pkgs.busybox}/bin/awk '{print $1,$2}')

                i=0
                for element in "''${sinks[@]}"; do
                  sink=$(echo "$element" | ${pkgs.busybox}/bin/awk '{print $2}')
                  if [[ $sink == "$default_sink" ]]; then
                    default_sink_index=$i
                  fi
                  echo "$element"
                  echo $i
                  i=$((i + 1))
                done

                echo "Default sink: $(echo "''${sinks[$default_sink_index]}" | ${pkgs.busybox}/bin/awk '{print $2}') , default sink id = $(echo "''${sinks[$default_sink_index]}" | ${pkgs.busybox}/bin/awk '{print $1}')"
                echo "setting sink: $(echo "''${sinks[$((default_sink_index - 1))]}" | ${pkgs.busybox}/bin/awk '{print $2}') , default sink id = $(echo "''${sinks[$((default_sink_index - 1))]}" | ${pkgs.busybox}/bin/awk '{print $1}')"
                ${pkgs.pulseaudio}/bin/pactl set-default-sink "$(echo "''${sinks[$((default_sink_index - 1))]}" | ${pkgs.busybox}/bin/awk '{print $1}')"
              '';
            "ignored-sinks" = ["Easy Effects Sink"];
          };
          "battery" = {
            "bat" = "BAT0";
            "interval" = 60;
            "states" = {
              "warning" = 30;
              "critical" = 15;
            };
            "format" = "{capacity}% {icon}";
            "format-icons" = ["" "" "" "" ""];
            "max-length" = 25;
          };
          "hyprland/workspaces" = {
            "disable-scroll" = true;
            "max-length" = 200;
            "seperate-outputs" = true;
            "warp-on-scroll" = false;
            "ignore-workspaces" = ["Filen"];
          };
          "idle_inhibitor" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "";
              "deactivated" = "";
            };
          };
          "wlr/taskbar" = {
            "format" = "{icon}";
            "icon-size" = 30;
            "icon-theme" = "Numix-Circle";
            "tooltip-format" = "{title}";
            "on-click" = "activate";
            "on-click-middle" = "close";
            "ignore-list" = ["Filen"];
          };
          "bluetooth" = {
            "format" = " {status}";
            "format-connected" = " {device_alias}";
            "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
            "tooltip-format" = ''
              {controller_alias}	{controller_address}

              {num_connections} connected'';
            "tooltip-format-connected" = ''
              {controller_alias}	{controller_address}

              {num_connections} connected

              {device_enumerate}'';
            "tooltip-format-enumerate-connected" = "{device_alias}	{device_address}";
            "tooltip-format-enumerate-connected-battery" = "{device_alias}	{device_address}	{device_battery_percentage}%";
            on-click = "blueberry";
          };
          "cpu" = {
            "format" = "{icon0} {icon1} {icon2} {icon3} {icon4} {icon5} {icon6} {icon7}";
            "format-icons" = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
          };
          "memory" = {
            "interval" = 30;
            "format" = "{}% ";
            "max-length" = 10;
          };

          "custom/swaync" = {
            "format" = " ";
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
            "format" = " ";
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
        }
      ];
    };
  };
}
