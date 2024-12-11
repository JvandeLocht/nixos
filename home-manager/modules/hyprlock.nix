{ lib
, config
, pkgs
, ...
}: {
  options.hyprlock = {
    enable = lib.mkEnableOption "hyprlock with custom configuration";
  };

  config = lib.mkIf config.hyprlock.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 15;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "~/.setup/img/nixos_wallpaper.jpg";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [{
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "TryIt";
          shadow_passes = 2;
        }];
      };
    };
  };
}
