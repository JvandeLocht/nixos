{ config
, pkgs
, ...
}: {
  imports = [
    ../common/home.nix
  ];

  home = {
    username = "jan";
    homeDirectory = "/home/jan";
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
