{pkgs ? import <nixpkgs> {}}: pkgs.callPackage ./iio-hyprland.nix {}
  huami-token = pkgs.callPackage ./huami-token.nix { };
