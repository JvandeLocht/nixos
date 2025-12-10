{
  pkgs ? import <nixpkgs> { },
}:
{
  gpu-drm-devices = pkgs.callPackage ./gpu-drm-devices.nix { };
}
