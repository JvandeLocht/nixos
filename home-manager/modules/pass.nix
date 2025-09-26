{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    pass.enable = lib.mkEnableOption "enables pass";
  };

  config = lib.mkIf config.pass.enable {
    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [
        exts.pass-otp
        exts.pass-import
      ]);
    };

    home = {
      packages = with pkgs; [
        passff-host
      ];
      file = {
        passff-host-workaround-firefox = {
          target = "${config.home.homeDirectory}/.mozilla/native-messaging-hosts/passff.json";
          source = "${pkgs.passff-host}/share/passff-host/passff.json";
        };
        passff-host-workaround-zen = {
          target = "${config.home.homeDirectory}/.zen/native-messaging-hosts/passff.json";
          source = "${pkgs.passff-host}/share/passff-host/passff.json";
        };
      };

    };
  };
}
