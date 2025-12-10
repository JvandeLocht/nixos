{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.niri = {
    enable = lib.mkEnableOption "Set up niri desktop environment";
  };

  config = lib.mkIf config.niri.enable {
    programs.niri.enable = true;
  };
}
