{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    rofi.enable =
      lib.mkEnableOption "enables rofi application launcher";
  };

  config = lib.mkIf config.rofi.enable {
    programs.rofi = {
      enable = true;
      modes = [ "drun" "run" "ssh" ];
      location = "center";
      extraConfig = {
        show-icons = true;
        icon-theme = "Adwaita";
      };
      pass = {
        enable = true;
        package = pkgs.rofi-pass-wayland;
        stores = [ "~/.password-store" ];
      };
    };

    home.packages = with pkgs; [
      rofi-pass-wayland
    ];
  };
}