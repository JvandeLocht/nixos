{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../home-manager/modules/dconf.nix
    ../../home-manager/modules/podman
    ../common/home.nix
  ];

  home = {
    username = "jan";
    homeDirectory = "/home/jan";
    # Packages that should be installed to the user profile.
    packages =
      (with pkgs; [])
      ++ (with pkgs.gnomeExtensions; [
        arcmenu
        caffeine
        forge
        space-bar
        gsconnect
        appindicator
        screen-rotate
        dash-to-dock
        syncthing-indicator
      ]);
  };

  services.syncthing.enable = true;

  systemd.user.services = {
    protonmail-bridge = {
      Unit = {
        Description = "Protonmail Bridge";
      };
      Service = {
        Restart = "always";
        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive";
        Environment = [
          "PATH=${pkgs.gnome3.gnome-keyring}/bin:${pkgs.pass}/bin"
          "PASSWORD_STORE_DIR=/home/jan/.local/share/password-store"
        ];
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };

    keyboard_light = {
      Unit = {
        Description = "Set keyboard light to 1";
      };
      Service = {
        Restart = "never";
        ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl --device='asus::kbd_backlight' set 1";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };
    keyboard_color = {
      Unit = {
        Description = "Set keyboard color";
      };
      Service = {
        Restart = "never";
        ExecStart = "${pkgs.asusctl}/bin/asusctl led-mode static -c 00ff00";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };
    backlight = {
      Unit = {
        Description = "Set keyboard light to 1";
      };
      Service = {
        Restart = "never";
        ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl --device='amdgpu_bl1' set 20";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };
    ollama = {
      Unit = {
        Description = "start ollama server";
      };
      Service = {
        Restart = "always";
        ExecStart = "${pkgs.nix}/bin/nix run github:havaker/ollama-nix serve";
      };
      Install = {WantedBy = ["graphical-session.target"];};
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
