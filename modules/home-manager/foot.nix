{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    foot.enable =
      lib.mkEnableOption "enables preconfigured foot";
  };

  config = lib.mkIf config.foot.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          font = "MesloLGM Nerd Font Mono:size=11";
          dpi-aware = "yes";
          term = "foot";
          pad = "0x0"; # optionally append 'center'
        };
        colors.alpha = 0.9;
        # csd = {
        #   # hide-when-maximized = "yes";
        #   size = 0;
        #   border-width = 2;
        #   border-color = "ff404040";
        # };
      };
    };
  };
}
