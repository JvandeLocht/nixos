let
  vars = {
    # Variables Used In Flake
    user = "jan";
    homeDir = "/home/jan";
    location = "$HOME/.setup";
    terminal = "alacritty";
    editor = "nvim";
  };
in {
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        binding = "<Alt>q";
        command = "alacritty";
        name = "Alacritty";
      };

    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };

    #Wallpaper
    "org/gnome/desktop/background" = {
      picture-uri = "${vars.homeDir}/.nixos_wallpaper.jpg";
      picture-uri-dark = "${vars.homeDir}/.nixos_wallpaper.jpg";
    };

    # Touchpad
    "org/gnome/desktop/peripherals/touchpad" = {
      speed = 1.0;
      tap-to-click = true;
    };

    # Arcmenu Setting
    "org/gnome/shell/extensions/arcmenu" = {
      hide-overview-on-startup = true;
      enable-standlone-runner-menu = true;
      search-provider-recent-files = true;
      search-provider-open-windows = true;
      arc-menu-icon = 15;
      runner-menu-custom-hotkey = [ "<Alt>r" ];
      pinned-app-list = [
        "Dateien"
        "org.gnome.Nautilus"
        "org.gnome.Nautilus.desktop"
        "Alacritty"
        "Alacritty"
        "Alacritty.desktop"
        "Jameica"
        "jameica"
        "jameica.desktop"
      ];
    };

    # # Space-Bar
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = "<Super>1";
      switch-to-workspace-2 = "<Super>2";
      switch-to-workspace-3 = "<Super>3";
      switch-to-workspace-4 = "<Super>4";
      switch-to-workspace-5 = "<Super>5";
      switch-to-workspace-6 = "<Super>6";
      switch-to-workspace-7 = "<Super>7";
      switch-to-workspace-8 = "<Super>8";
      switch-to-workspace-9 = "<Super>9";
      switch-to-workspace-10 = "<Super>10";
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
      move-to-workspace-5 = [ "<Super><Shift>5" ];
      move-to-workspace-6 = [ "<Super><Shift>6" ];
      move-to-workspace-7 = [ "<Super><Shift>7" ];
      move-to-workspace-8 = [ "<Super><Shift>8" ];
      move-to-workspace-9 = [ "<Super><Shift>9" ];
      move-to-workspace-10 = [ "<Super><Shift>0" ];
      close = [ "<Alt>c" ];
    };
    "org/gnome/shell/extensions/space-bar/shortcuts" = {
      enable-activate-workspace-shortcuts = true;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;

      show-screenshot-ui = [ "<Super>d" ];

      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "Alacritty.desktop"
        "betterbird.desktop"
      ];

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "arcmenu@arcmenu.com"
        "caffeine@patapon.info"
        "forge@jmmaranan.com"
        "space-bar@luchrioh"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "gsconnect@andyholmes.github.io"
        "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
        "screen-rotate@shyzus.github.io"
      ];
    };

    # Enable fractional scaling
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
      dynamic-workspaces = true;
    };
  };
}
