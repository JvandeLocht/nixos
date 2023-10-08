{ config, pkgs, lib, vars, ... }:
let
  vars = {
    # Variables Used In Flake
    user = "jan";
    homeDir = "/home/jan";
    location = "$HOME/.setup";
    terminal = "alacritty";
    editor = "nvim";
  };
in
{
  imports = [
    ../modules/home-manager/firefox.nix
    ../modules/home-manager/neovim.nix
  ];


  home.username = "${vars.user}";
  home.homeDirectory = "${vars.homeDir}";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.file = {
    #AstroNvim
    ".config/nvim" = {
      source = pkgs.fetchFromGitHub {
        owner = "AstroNvim";
        repo = "AstroNvim";
        rev = "16e267c";
        sha256 = "0AbAs8MEbezmo4hnMHZzpgUWaV1xN55fr8RmSdhUDTA=";
      };
      recursive = true;
    };

    ".config/nvim/lua/user" = {
      source = ../dotfiles/AstroNvimUser;
      recursive = true;
    };

    ".nixos_wallpaper.jpg" = {
      source = ../img/nixos_wallpaper.jpg;
      recursive = true;
    };

  };

  # home.activation = {
  #   myActivationAction = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     #!/bin/sh
  #
  #     DIRECTORY="$HOME/tank"
  #
  #     # Checks if the directory allready exists
  #     if [ ! -d "$DIRECTORY" ]; then
  #       mkdir -p $HOME/tank
  #     fi
  #
  #     # Checks if the directory is allready a mountpoint
  #     if ! mount | grep $HOME/tank > /dev/null; then
  #       ${pkgs.tmux}/bin/tmux ${pkgs.sshfs}/bin/sshfs jan@192.168.178.40:/tank $HOME/tank -o IdentityFile=/etc/ssh/ssh_host_rsa_key.pub
  #     fi
  #   '';
  # };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Jan van de Locht";
    userEmail = "jan.vandelocht@startmail.com";
  };

  # Packages that should be installed to the user profile.
  home.packages = (with pkgs; [
    neofetch
    gnome.dconf-editor
    gnome-browser-connector

    nextcloud-client
    bitwarden
    jameica
    betterbird
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

    evtest # test Input Events (for example LidSwitch)

    # fish
    fishPlugins.z
    grc #for fish

    # archives
    zip
    xz
    unzip
    p7zip

    auto-cpufreq
    sshfs
    tree #Display filetree
    ranger
    btop # replacement of htop/nmon
    tldr
  ]) ++ (with pkgs.gnomeExtensions;[
    arcmenu
    caffeine
    forge
    space-bar
    gsconnect
    appindicator
    screen-rotate
  ]);


  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 16;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
      window = {
        opacity = 0.9;
        decorations = "none";
      };
    };
  };



  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
    ];
    shellAliases = {
      p = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
      nr = "sudo nixos-rebuild switch --flake ~/.setup#jans-nixos";
      j = "z";
      sj = "ssh jan@192.168.178.40";
      sa = "ssh ae@192.168.178.40";
    };
  };



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
