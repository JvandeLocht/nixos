{ config
, pkgs
, ...
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
      source = ./AstroNvimUser;
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
    neofetch
    gnome.dconf-editor

    nextcloud-client
    betterbird
    # firefox
    grc #for fish

    # archives
    zip
    xz
    unzip
    p7zip

    tree #Display filetree

    btop # replacement of htop/nmon
  ]) ++ (with pkgs.gnomeExtensions;[
    arcmenu
    caffeine
    dash-to-dock
    forge
    space-bar
  ]);

  # firefox
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = {
        # Gnome shell native connector
        enableGnomeExtensions = true;
        # Tridactyl native connector
        enableTridactylNative = true;
      };
    };
    profiles = {
      "main" = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          floccus
          ublock-origin
          gnome-shell-integration
          tridactyl
        ];
        search = {
          default = "DuckDuckGo";
          force = true;
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };

            "NixOS Wiki" = {
              urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };

            "Bing".metaData.hidden = true;
            "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
        settings = {
          # Performance settings
          "gfx.webrender.all" = true; # Force enable GPU acceleration
          "media.ffmpeg.vaapi.enabled" = true;
          "widget.dmabuf.force-enabled" = true; # Required in recent Firefoxes

          # Keep the reader button enabled at all times; really don't
          # care if it doesn't work 20% of the time, most websites are
          # crap and unreadable without this
          "reader.parse-on-load.force-enabled" = true;

          # Hide the "sharing indicator", it's especially annoying
          # with tiling WMs on wayland
          "privacy.webrtc.legacyGlobalIndicator" = false;


          # Actual settings
          "app.shield.optoutstudies.enabled" = false;
          "app.update.auto" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.contentblocking.category" = "strict";
          "browser.ctrlTab.recentlyUsedOrder" = false;
          "browser.discovery.enabled" = false;
          "browser.laterrun.enabled" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "";
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.pinned" = false;
          "browser.protections_panel.infoMessage.seen" = true;
          "browser.quitShortcut.disabled" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.ssb.enabled" = true;
          "browser.toolbars.bookmarks.visibility" = "always";
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.suggest.openpage" = false;
          "datareporting.policy.dataSubmissionEnable" = false;
          "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_ever_enabled" = true;
          "extensions.getAddons.showPane" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "extensions.pocket.enabled" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "identity.fxaccounts.enabled" = false;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "layout.forms.reveal-password-context-menu.enabled" = false;
          "signon.autofillForms" = false;
          "intl.accept_languages" = "de";
          "browser.translations.automaticallyPopup" = false;
        };
      };
    };
  };

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

      extraPackages = (with pkgs; [
        #lua
        lua-language-server

        #bash
        nodePackages_latest.bash-language-server

        #python
        nodePackages_latest.pyright
        black
        isort

        #nix
        rnix-lsp

        #stuff
        libgccjit #gcc
        nodejs_20
        rustup
        xclip
        wl-clipboard
      ]) ++ (with pkgs.vimPlugins;[
        nvim-treesitter-parsers.python
        nvim-treesitter-parsers.toml
        nvim-treesitter-parsers.lua
        nvim-treesitter-parsers.bash
        nvim-treesitter-parsers.vim
        nvim-treesitter-parsers.rust
        nvim-treesitter-parsers.query
        nvim-treesitter-parsers.markdown
        nvim-treesitter-parsers.json
        nvim-treesitter-parsers.cmake
        nvim-treesitter-parsers.c
        nvim-treesitter-parsers.c_sharp
      ]);
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
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    #Wallpaper
    "org/gnome/desktop/background" = {
      picture-uri = "/home/jan/.setup/nixos_wallpaper.jpg";
      picture-uri-dark = "/home/jan/.setup/nixos_wallpaper.jpg";
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
    };

    # dash-to-dock Settings
    "org/gnome/shell/extensions/dash-to-dock" = {
      hot-keys = false;
    };

    # Space-Bar
    "org/gnome/desktop/wm/keybindings" = {
      move-to-workspace-1 = "<Super><Shift>1";
      move-to-workspace-2 = "<Super><Shift>2";
      move-to-workspace-3 = "<Super><Shift>3";
      move-to-workspace-4 = "<Super><Shift>4";
      move-to-workspace-5 = "<Super><Shift>5";
      move-to-workspace-6 = "<Super><Shift>6";
      move-to-workspace-7 = "<Super><Shift>7";
      move-to-workspace-8 = "<Super><Shift>8";
      move-to-workspace-9 = "<Super><Shift>9";
      move-to-workspace-10 = "<Super><Shift>10";
    };
    "org/gnome/shell/extensions/space-bar/shortcuts" = {
      enable-activate-workspace-shortcuts = true;
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;

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
        "dash-to-dock@micxgx.gmail.com"
        "space-bar@luchrioh"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    # Enable fractional scaling
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
      dynamic-workspaces = true;
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
