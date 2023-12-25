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
  imports = [ ../common/home.nix ];

  home.file = {
    ".nixos_wallpaper.jpg" = {
      source = ../../img/nixos_wallpaper.jpg;
      recursive = true;
    };

  };
  # Packages that should be installed to the user profile.
  home.packages = (with pkgs; [ ]);
}
