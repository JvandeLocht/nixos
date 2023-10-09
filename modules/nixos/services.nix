{ config, pkgs, ... }:
{
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    supergfxd.enable = true;
    # spacenavd = {
    #   enable = true;
    #   enableUserService = true;
    # };
  };
}
