{
  config,
  pkgs,
  ...
}:
{
  home.username = "jan";
  home.homeDirectory = "/home/jan";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

   home.file = {
     ".background-image" = {
       source = ./nixos_wallpaper.jpg;
     };
     # ".config/nvim" = {
     #   source = ./nvim;
     #   recursive = true;
     #   # onChange = builtins.readFile ./nvim.sh; 
     # };
     
     ".config/nvim" = {
      source = pkgs.fetchFromGitHub {
        owner = "AstroNvim";
        repo = "AstroNvim";
        rev = "16e267c";
        sha256 = "0AbAs8MEbezmo4hnMHZzpgUWaV1xN55fr8RmSdhUDTA=";
      };
      recursive = true;
     };

   };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Jan van de Locht";
    userEmail = "jan@vandelocht.uk";
  };

  # Packages that should be installed to the user profile.
  home.packages = (with pkgs; [
    neofetch
    gnome.dconf-editor

    betterbird
    firefox
    grc #for fish

    # archives
    zip
    xz
    unzip
    p7zip

    tree #Display filetree

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    btop # replacement of htop/nmon
  ]) ++ (with pkgs.gnomeExtensions;[
    arcmenu
    caffeine
    dash-to-dock
    forge
    space-bar
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

  #Add support for ./local/bin
  #Needed for nvim
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  programs.neovim = 
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in
  {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      luajitPackages.lua-lsp
      nil
      nodejs_20
      rustup
      xclip
      wl-clipboard
    ];
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
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    # "org/gnome/shell/favorite-apps" = { 
    #  ["org.gnome.Nautilus.desktop", "org.gnome.firefox.desktop", "org.gnome.alacritty.desktop"];
    # };

    # Arcmenu Setting
    "org/gnome/shell/extensions/arcmenu" = {
      hide-overview-on-startup = true;
      enable-standlone-runner-menu = true;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      
      # `gnome-extensions list` for a list
      enabled-extensions = [
      "arcmenu@arcmenu.com"
      "caffeine@patapon.info"
      "forge@jmmaranan.com"
      "dash-to-dock@micxgx.gmail.com"
      "space-bar@luchrioh"
      "drive-menu@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    # Enable fractional scaling
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
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
