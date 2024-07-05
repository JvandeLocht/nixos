{
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
          size = 16;
          # draw_bold_text_with_bright_colors = true;
        };
        scrolling.multiplier = 5;
        selection.save_to_clipboard = true;
        window = {
          opacity = 0.9;
          decorations = "none";
        };
      };
    };
  };
}
