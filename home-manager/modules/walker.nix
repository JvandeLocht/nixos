{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.walker = {
    enable = lib.mkEnableOption "Custom Walker configuration";
  };

  config = lib.mkIf config.walker.enable {
    programs.walker = {
      enable = true;
      runAsService = true;

      # All options from the config.json can be used here.
      config = {
        list = {
          height = 200;
        };
        websearch = {
          prefix = "?";
          entries = [
            {
              name = "DuckDuckGo";
              url = "https://duckduckgo.com/?q=%TERM%";
            }
          ];
        };
        switcher.prefix = "/";
      };
    };
  };
}
