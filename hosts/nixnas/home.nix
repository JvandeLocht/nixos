{ config
, pkgs
, osConfig
, ...
}: {
  imports = [
    ../common/home.nix
  ];

  tmux.enable = false;


  home = {
    username = "jan";
    homeDirectory = "/home/jan";
    packages =
      (with pkgs; [
      ])
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
  # Packages that should be installed to the user profile.
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
