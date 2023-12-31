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
  imports = [ ../../home-manager/modules ];

  nixpkgs.config.allowUnfree = true;

  home.username = "${vars.user}";
  home.homeDirectory = "${vars.homeDir}";

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Jan van de Locht";
    userEmail = "jan.vandelocht@startmail.com";
  };

  # Packages that should be installed to the user profile.
  home.packages = (with pkgs; [
    nextcloud-client
    bitwarden
    jameica
    spacenavd
    libreoffice-qt
    remmina
    solaar
    AusweisApp2
    # schildichat-desktop-wayland
    antimicrox
    super-slicer-latest
    yuzu-mainline
    waydroid
    freetube
    webcord
    evince # pdf viewer
    thunderbird
    qownnotes
    obs-studio
    vlc
    nomacs # image viewer
    gnome.nautilus
    gnome.sushi
    zoom-us
    signal-desktop

    # archives
    zip
    xz
    unzip
    p7zip

    # CLI
    abduco # Allows programs to be run independently from its controlling terminal
    neofetch
    lazygit
    evtest # test Input Events (for example LidSwitch)
    usbutils
    android-tools
    auto-cpufreq
    sshfs
    tree # Display filetree
    btop # replacement of htop/nmon
    tldr
    killall
  ]);

  services.syncthing.enable = true;

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
