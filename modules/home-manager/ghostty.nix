{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.ghostty = {
    enable = lib.mkEnableOption "Custom Ghostty configuration";
  };

  config = lib.mkIf config.ghostty.enable {
    programs.ghostty = {
      enable = true;
      # custom settings
      settings = {
        font-size = 14;
        keybind = [
          "ctrl+h=goto_split:left"
          "ctrl+l=goto_split:right"
          "ctrl+shift+l=new_split:right"
          "ctrl+shift+n=new_tab"
          "alt+tab=toggle_tab_overview"
        ];
      };
    };
  };
}
