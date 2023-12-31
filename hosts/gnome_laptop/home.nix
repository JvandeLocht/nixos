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
  imports = [ ../../home-manager/modules/dconf.nix ../common/home.nix ];

  # Packages that should be installed to the user profile.
  home.packages = (with pkgs; [ ]) ++ (with pkgs.gnomeExtensions; [
    arcmenu
    caffeine
    forge
    space-bar
    gsconnect
    appindicator
    screen-rotate
  ]);

  services.syncthing.enable = true;

  systemd.user.services.protonmail-bridge = {
    Unit = {
      Description = "Protonmail Bridge";
      # Requires = [ "pass-secret-service.service" "gpg-agent.service" ];
    };

    Service = {
      Restart = "always";
      ExecStart =
        "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --noninteractive";
      Environment = [
        "PATH=${pkgs.gnome3.gnome-keyring}/bin:${pkgs.pass}/bin"
        "PASSWORD_STORE_DIR=/home/jan/.local/share/password-store"
      ];
    };

    Install = { WantedBy = [ "network.target" ]; };
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
