{
  lib,
  config,
  pkgs,
  ...
}: {
  options.firefox = {
    enable = lib.mkEnableOption "Custom LibreWolf configuration";
  };

  config = lib.mkIf config.firefox.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.librewolf;
      profiles = {
        "main" = {
          # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          #   ublock-origin
          #   proton-pass
          #   i-dont-care-about-cookies
          # ];
        };
      };
    };
  };
}
