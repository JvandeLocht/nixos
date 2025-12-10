{
  pkgs,
  lib,
  config,
  ...
}: {
  options.alacritty = {
    enable = lib.mkEnableOption "Custom Alacritty configuration";
  };

  config = lib.mkIf config.alacritty.enable {
    programs.alacritty = {
      enable = true;
      # custom settings
      settings = {
        env.TERM = "xterm-256color";
        font = {
          size = 14;
          normal = {
            family = "Fira Code";
          };
        };
        scrolling = {
          history = 10000;
          multiplier = 5;
        };
        selection.save_to_clipboard = true;
        bell.animation = "Linear";
        bell.duration = 0;
        window = {
          # opacity = 0.8;
          decorations = "none";
          padding = {
            x = 8;
            y = 8;
          };
        };
        colors = {
          # OneDark theme colors
          primary = {
            background = "#282c34";
            foreground = "#abb2bf";
          };
          normal = {
            black = "#282c34";
            red = "#e06c75";
            green = "#98c379";
            yellow = "#e5c07b";
            blue = "#61afef";
            magenta = "#c678dd";
            cyan = "#56b6c2";
            white = "#abb2bf";
          };
          bright = {
            black = "#5c6370";
            red = "#e06c75";
            green = "#98c379";
            yellow = "#e5c07b";
            blue = "#61afef";
            magenta = "#c678dd";
            cyan = "#56b6c2";
            white = "#ffffff";
          };
        };
      };
    };
  };
}
