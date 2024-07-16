{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    yazi.enable =
      lib.mkEnableOption "enables preconfigured yazi";
  };

  config = lib.mkIf config.yazi.enable {
    programs.yazi = {
      enable = true;
      settings = {
        manager = {
          show_hidden = true;
        };
        preview = {
          max_width = 1000;
          max_height = 1000;
        };
      };
    };
    home.packages = with pkgs; [
      ueberzugpp
    ];
  };
}
