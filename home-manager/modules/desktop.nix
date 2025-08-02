{ config, ... }:
{
  xdg.desktopEntries = {
    steam-abduco = {
      name = "Steam";
      genericName = "Game Client";
      exec = "abduco -c steam steam";
      terminal = false;
    };
    schildchat = {
      name = "Schildchat";
      genericName = "Matrix Client";
      exec = "schildichat-desktop";
      terminal = false;
    };
    freecad = {
      exec = "freecad-x11";
      name = "Freecad-x11";
      icon = "${config.home.homeDirectory}/.setup/img/freecad.png";
    };
  };
}
