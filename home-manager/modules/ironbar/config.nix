{
  systemd.user.services.ironbar.Service.Environment = "RUST_BACKTRACE=full";
  programs.ironbar = {
    config = {
      position = "top";
      height = 42;
      start = [
        # Workspaces
        {
          "type" = "workspaces";
          "name_map" = { "1" = ""; };
          "favorites" = [ "1" "2" "3" ];
          "all_monitors" = false;
        }
        # Running Programs
        {
          "type" = "launcher";
          "favourites" = [ "firefox" "discord" ];
          "show_names" = false;
          "show_icons" = true;
        }
      ];
      center = [
        # Clock and Date
        {
          "type" = "clock";
          "format" = "%d/%m/%Y %H:%M";
        }
      ];
      end = [
        #Sysinfo
        {
          "format" = [
            " {cpu_percent}%"
            " {memory_used} / {memory_total} GB ({memory_percent}%)"
          ];
          "interval" = {
            "cpu" = 1;
            "memory" = 30;
          };
          "type" = "sys_info";
        }
        # Battery
        {
          "type" = "upower";
          "format" = "{percentage}%";
        }
        # Powermenu
        # { "type" = "clock"; }
        {
          "bar" = [{
            "label" = "";
            "name" = "power-btn";
            "on_click" = "popup:toggle";
            "type" = "button";
          }];
          "class" = "power-menu";
          "popup" = [{
            "orientation" = "vertical";
            "type" = "box";
            "widgets" = [
              {
                "label" = "Power menu";
                "name" = "header";
                "type" = "label";
              }
              {
                "type" = "box";
                "widgets" = [
                  {
                    "class" = "power-btn";
                    "label" = "<span font-size='40pt'></span>";
                    "on_click" = "!shutdown now";
                    "type" = "button";
                  }
                  {
                    "class" = "power-btn";
                    "label" = "<span font-size='40pt'></span>";
                    "on_click" = "!reboot";
                    "type" = "button";
                  }
                ];
              }
              {
                "label" = "Uptime: {{30000:uptime -p | cut -d ' ' -f2-}}";
                "name" = "uptime";
                "type" = "label";
              }
            ];
          }];
          "tooltip" = "Up: {{30000:uptime -p | cut -d ' ' -f2-}}";
          "type" = "custom";
        }

        { "type" = "tray"; }
      ];
    };
  };
}
