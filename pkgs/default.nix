{
  pkgs ? import <nixpkgs> { },
}:
{
  huami-token = pkgs.callPackage ./huami-token.nix { };
}
