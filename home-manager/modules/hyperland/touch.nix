{
  inputs,
  pkgs,
  osConfig,
  lib,
  ...
}: {
  config = lib.mkIf osConfig.programs.hyprland.enable {
    i18n = {
      glibcLocales = pkgs.glibcLocales.override {
        allLocales = false;
        locales = ["de_DE.UTF-8/UTF-8"];
      };
      inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = [inputs.fcitx-virtual-keyboard-adapter.packages.${pkgs.system}.default];
      };
    };

    home.packages = [pkgs.wvkbd];

    xdg.configFile."fcitx5/conf/virtualkeyboardadapter.conf".text = ''
      ActivateCmd="systemctl kill --signal=SIGUSR2 --user wvkbd.service"
      DeactivateCmd="systemctl kill --signal=SIGUSR1 --user wvkbd.service"
    '';

    systemd.user.services = {
      wvkbd = {
        Unit.Description = "On Screen Keyboard";
        Service = {
          ExecStart = "${lib.getExe pkgs.wvkbd} --hidden -L 300";
          Restart = "unless-stopped";
        };
      };
    };
  };
}
