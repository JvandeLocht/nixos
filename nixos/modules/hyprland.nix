{ pkgs
, lib
, config
, ...
}:
let
  session = "${pkgs.hyprland}/bin/Hyprland";
  username = "jan"; # Replace with your actual username
in
{
  options.hyprland = {
    enable = lib.mkEnableOption "Set up Hyprland desktop environment";
  };

  config = lib.mkIf config.hyprland.enable {
    # stuff for hyperland
    programs.hyprland = {
      # Install the packages from nixpkgs
      enable = true;
      # Whether to enable XWayland
      xwayland.enable = true;
    };
    services = {
      greetd = {
        enable = true;
        settings = {
          initial_session = {
            command = "${session}";
            user = "${username}";
          };
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${session}";
            user = "greeter";
          };
        };
      };
      gvfs.enable = true; # Mount, trash, and other functionalities
      tumbler.enable = true; # Thumbnail support for images
      supergfxd.enable = true;
      upower.enable = true;
      gnome.sushi.enable = true;
    };

    nixpkgs.overlays = [
      (final: prev: {
        wvkbd = prev.wvkbd.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [ ../../patches/switchYandZ.patch ];
        });
      })
    ];

    environment = {
      variables.XCURSOR_SIZE = "15";
      sessionVariables = {
        # If your cursor becomes invisible
        WLR_NO_HARDWARE_CURSORS = "1";
        # Hint electron apps to use wayland
        NIXOS_OZONE_WL = "1";
        # GTK: Use wayland if available, fall back to x11 if not.
        GDK_BACKEND = "wayland,x11";
        # Qt: Use wayland if available, fall back to x11 if not.
        QT_QPA_PLATFORM = "wayland;xcb";
        # Run SDL2 applications on Wayland.
        # Remove or set to x11 if games that provide
        # older versions of SDL cause compatibility issues
        SDL_VIDEODRIVER = "wayland";
        # Clutter package already has wayland enabled,
        # this variable will force Clutter applications
        # to try and use the Wayland backend
        CLUTTER_BACKEND = "wayland";
        # XDG specific environment variables are often detected
        # through portals and applications that may set those for you,
        # however it is not a bad idea to set them explicitly.
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
        # (From the Qt documentation) enables automatic scaling,
        # based on the monitor’s pixel density
        # https://doc.qt.io/qt-5/highdpi.html
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      };
      systemPackages = with pkgs; [
        lxqt.lxqt-policykit
        brightnessctl
        xbindkeys
        qt5.qtwayland
        qt6.qtwayland
        file-roller
        nautilus
        nautilus-open-any-terminal
      ];
    };

    security.polkit.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
    security.pam.services.swaylock = { };
    programs.dconf.enable = true;

    systemd = {
      user.services.lxqt-policykit-agent = {
        description = "lxqt-policykit-agent";
        wantedBy = [ "hyprland-session.target" ];
        wants = [ "hyprland-session.target" ];
        after = [ "hyprland-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

  };
}
