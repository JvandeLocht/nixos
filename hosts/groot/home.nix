{
  config,
  pkgs,
  inputs,
  ...
}:
let
  stable = import inputs.nixpkgs {
    localSystem = pkgs.system;
  };
in
{
  imports = [
    ../common/home.nix
    ../../home-manager/modules
  ];

  zsh.enable = true;
  yazi.enable = true;
  emacs.enable = true;
  tmux.enable = true;
  firefox.enable = true;
  alacritty.enable = true;
  ghostty.enable = true;
  kitty.enable = true;
  pass.enable = true;
  rofi.enable = true;
  home = {
    username = "jan";
    homeDirectory = "/home/jan";
    # Packages that should be installed to the user profile.
    packages =
      (with pkgs; [
        bitwarden-desktop
        chafa # terminal graphics
        prusa-slicer
        jameica
        spacenavd
        libreoffice-qt
        solaar # logitech gear
        ausweisapp
        antimicrox
        waydroid
        freetube
        evince # pdf viewer
        thunderbird
        claws-mail
        obs-studio
        vlc
        zoom-us
        signal-desktop
        xournalpp
        onlyoffice-desktopeditors
        appimage-run
        element-desktop
        zathura
        pdf4qt
        brave
        ungoogled-chromium
        mediawriter
        gnome-disk-utility

        (writeShellScriptBin "freecad-x11" ''
          GDK_BACKEND=x11 QT_QPA_PLATFORM=xcb ${freecad}/bin/freecad "$@"
        '')
        freecad
        inputs.zen-browser.packages."${system}".default # beta
        spotube
        claude-code

        golden-cheetah
        rclone-browser
        rclone
        python313
        notify-client
        bitwarden-cli

        typst
        pandoc
        yq-go
        kubeconform
        kustomize
        talosctl
        kubectl
        kubernetes-helm
        k9s
        fluxcd
        kompose
        nvf
        minio-client
        velero
        opencode

        evtest # test Input Events (for example LidSwitch)
        usbutils
        android-tools
        auto-cpufreq
      ])
      ++ (with stable; [
      ]);
  };

  systemd.user.services = {
    keyboard_light = {
      Unit = {
        Description = "Set keyboard light to 1";
      };
      Service = {
        Restart = "never";
        ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl --device='asus::kbd_backlight' set 1";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    keyboard_color = {
      Unit = {
        Description = "Set keyboard color";
      };
      Service = {
        Restart = "never";
        ExecStart = "${pkgs.asusctl}/bin/asusctl led-mode static -c 00ff00";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    charge_limit = {
      Unit = {
        Description = "Set charge limit to 80%";
      };
      Service = {
        Restart = "never";
        ExecStart = "${pkgs.asusctl}/bin/asusctl -c 80";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    backlight = {
      Unit = {
        Description = "Set display brightness";
      };
      Service = {
        Restart = "never";
        ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl --device='amdgpu_bl2' set 15";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

}
