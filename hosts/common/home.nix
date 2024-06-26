{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home-manager/modules/alacritty.nix
    ../../home-manager/modules/desktop.nix
    ../../home-manager/modules/firefox.nix
    ../../home-manager/modules/fish.nix
    ../../home-manager/modules/zsh.nix
    ../../home-manager/modules/bash.nix
    ../../home-manager/modules/kitty.nix
    ../../home-manager/modules/wezterm.nix
    ../../home-manager/modules/starship.nix
    ../../home-manager/modules/neovim
    ../../home-manager/modules/lf
  ];

  nixpkgs.config.allowUnfree = true;

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Jan van de Locht";
    userEmail = "jan@vandelocht.uk";
  };

  home.file = {
    ".nixos_wallpaper.jpg" = {
      source = ../../img/nixos_wallpaper.jpg;
      recursive = true;
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    protonmail-desktop
    nextcloud-client
    bitwarden
    jameica
    spacenavd
    libreoffice-qt
    remmina
    solaar
    AusweisApp2
    antimicrox
    octaveFull
    # super-slicer-latest
    #   yuzu-mainline
    waydroid
    freetube
    webcord
    evince # pdf viewer
    thunderbird
    qownnotes
    obs-studio
    vlc
    zoom-us
    signal-desktop
    xournalpp
    logseq
    onlyoffice-bin
    appimage-run
    element-desktop

    # archives
    zip
    xz
    unzip
    p7zip

    # CLI
    yq-go
    kubeconform
    kustomize
    zellij
    talosctl
    kubectl
    kubernetes-helm
    k9s
    fluxcd
    kompose

    sops
    age

    abduco # Allows programs to be run independently from its controlling terminal
    neofetch
    lazygit
    evtest # test Input Events (for example LidSwitch)
    usbutils
    android-tools
    auto-cpufreq
    sshfs
    tree # Display filetree
    htop
    tldr
    killall
  ];

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
