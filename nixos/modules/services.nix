{
  lib,
  config,
  ...
}:
{
  options.services = {
    enable = lib.mkEnableOption "Services that should run";
  };

  config = lib.mkIf config.services.enable {
    services = {
      asusd = {
        enable = true;
        enableUserService = true;
      };

      supergfxd.enable = true;

      upower.enable = true;

      gnome.sushi.enable = true;
      smartd.enable = true;
      fwupd.enable = true;
      # spacenavd = {
      #   enable = true;
      #   enableUserService = true;
      # };
    };
  };
}
