{
  pkgs ? import <nixpkgs> { },
}:
{
  huami-token = pkgs.callPackage ./huami-token.nix { };
  gpu-drm-devices = pkgs.callPackage ./gpu-drm-devices.nix { };
}
