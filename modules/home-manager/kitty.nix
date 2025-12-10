{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    kitty.enable =
      lib.mkEnableOption "enables kitty";
  };

  config = lib.mkIf config.kitty.enable {
    programs.kitty = {
      enable = true;
      font = {
        size = 14;
        package = pkgs.fira-code;
        name = "Fira Code";
      };
      themeFile = "OneDark";
      shellIntegration.enableFishIntegration = true;
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
      };
      extraConfig = ''
        # hide_window_decorations yes
        # background_opacity 0.8
      '';
    };
  };
}
