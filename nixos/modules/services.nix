{pkgs, ...}: {
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };

    supergfxd.enable = true;

    upower.enable = true;

    gnome.sushi.enable = true;
    smartd.enable = true;

    # spacenavd = {
    #   enable = true;
    #   enableUserService = true;
    # };
  };
}
