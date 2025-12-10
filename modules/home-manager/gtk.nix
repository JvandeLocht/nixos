{
  lib,
  config,
  pkgs,
  ...
}: {
  options.gtkThemes = {
    enable = lib.mkEnableOption "Custom pointer cursor and GTK theme configuration";
  };

  config = lib.mkIf config.gtkThemes.enable {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 15;
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };
      iconTheme = {
        package = pkgs.libsForQt5.breeze-icons;
        name = "breeze-dark";
      };
      font = {
        name = "Fira Code";
        size = 11;
      };
    };
  };
}
