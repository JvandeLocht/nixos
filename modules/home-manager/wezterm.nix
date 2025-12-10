{
  lib,
  config,
  ...
}: {
  options.wezterm = {
    enable = lib.mkEnableOption "WezTerm terminal emulator";
  };

  config = lib.mkIf config.wezterm.enable {
    programs.wezterm = {
      enable = true;
      enableBashIntegration = true;
      extraConfig =
        /*
        lua
        */
        ''
          -- Pull in the wezterm API
          local wezterm = require 'wezterm'

          -- This will hold the configuration.
          local config = wezterm.config_builder()

          -- This is where you actually apply your config choices

          -- For example, changing the color scheme:
          config.color_scheme = 'One Dark (Gogh)'
          -- config.window_decorations = "NONE"
          config.hide_tab_bar_if_only_one_tab = true
          config.window_background_opacity = 0.8
          config.font_size = 14

          -- and finally, return the configuration to wezterm
          return config
        '';
    };
  };
}
