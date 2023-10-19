{ config, pkgs, ... }:
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
  imports = [ ./modules ];

  nixpkgs.config.allowUnfree = true;

  home.username = "${vars.user}";
  home.homeDirectory = "${vars.homeDir}";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.file = {
    ".nixos_wallpaper.jpg" = {
      source = ../img/nixos_wallpaper.jpg;
      recursive = true;
    };

  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Jan van de Locht";
    userEmail = "jan.vandelocht@startmail.com";
  };

  # Packages that should be installed to the user profile.
  home.packages = (with pkgs; [
    gnome.dconf-editor
    gnome-browser-connector

    nextcloud-client
    bitwarden
    librewolf
    jameica
    betterbird
    claws-mail
    steam
    spacenavd
    freecad
    onlyoffice-bin_7_4
    schildichat-desktop
    remmina
    solaar
    AusweisApp2
    antimicrox
    super-slicer-latest
    yuzu-mainline
    waydroid
    discordo
    freetube
    tmux

    # archives
    zip
    xz
    unzip
    p7zip

    #programing
    octaveFull

    # CLI
    neofetch
    evtest # test Input Events (for example LidSwitch)
    usbutils
    android-tools
    auto-cpufreq
    sshfs
    tree # Display filetree
    ranger
    btop # replacement of htop/nmon
    tldr
  ]) ++ (with pkgs.gnomeExtensions; [
    arcmenu
    caffeine
    forge
    space-bar
    gsconnect
    appindicator
    screen-rotate
  ]);

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
